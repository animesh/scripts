#!/usr/bin/env python3
r"""pepSearch.py

Usage example (PowerShell):
  python .\pepSearch.py `
    "L:/promec/TIMSTOF/LARS/2025/251031_MAREN/251030_MAREN_DIALYSE_DDA_Slot1-37_1_11507.d/251030_MAREN_DIALYSE_DDA_Slot1-37_1_11507_6.1.452.mgf.csv" `
    "L:/promec/FastaDB/UP000000589_10090.fasta" `
    "L:/promec/FastaDB/uniprot-human-iso-jan24.fasta" `
    --out results_peptide_matches.csv
"""

import argparse
import re
from pathlib import Path
from typing import List, Tuple, Optional
import pandas as pd
from Bio import SeqIO
import csv

PEPTIDE_COL_CANDIDATES = [
    "Peptide", "peptide", "Sequence", "sequence", "Sequence (mod)", "Modified sequence",
    "PeptideSequence", "peptide_sequence", "sequence_mod"
]


def detect_peptide_column(df: pd.DataFrame) -> str:
    for c in df.columns:
        if c in PEPTIDE_COL_CANDIDATES:
            return c
    # fallback: choose first column that looks like peptides (letters, brackets, short)
    for c in df.columns:
        sample = df[c].dropna().astype(str).head(50).tolist()
        if not sample:
            continue
        score = sum(bool(re.search(r'[A-Z]', s)) and len(re.sub(r'[^A-Z]', '', s)) >= 4 for s in sample)
        if score >= 1:
            return c
    raise ValueError("Could not auto-detect peptide column. Use --col to specify the column name.")


def clean_peptide(peptide: str) -> str:
    """
    Remove PTM annotations like M[+15.99], (Oxidation), numbers, and keep A-Z letters only.
    """
    if peptide is None:
        return ""
    s = str(peptide)
    # remove parentheses content and square-bracket content (# common PTM annotations)
    s = re.sub(r'\([^)]*\)', '', s)
    s = re.sub(r'\[[^\]]*\]', '', s)
    # remove non-letters
    s = re.sub(r'[^A-Za-z]', '', s)
    # uppercase
    s = s.upper()
    return s


def load_fasta_indexed(fasta_paths: List[Path]) -> List[Tuple[str, str, str, str]]:
    """
    Load all sequences into a list of tuples (db_label, seq_id, description, seq)
    """
    records = []
    for p in fasta_paths:
        label = p.name
        with p.open("r", encoding="utf-8", errors="ignore") as fh:
            for rec in SeqIO.parse(fh, "fasta"):
                sid = rec.id
                desc = rec.description
                seq = str(rec.seq).upper()
                records.append((label, sid, desc, seq))
    return records


def find_all_occurrences(seq: str, peptide: str) -> List[int]:
    """Return 0-based start indices of all occurrences (possibly overlapping)."""
    starts = []
    start = 0
    while True:
        idx = seq.find(peptide, start)
        if idx == -1:
            break
        starts.append(idx)
        start = idx + 1
    return starts


def sniff_delimiter(path: Path) -> Optional[str]:
    try:
        with path.open('r', encoding='utf-8', errors='ignore') as fh:
            sample = fh.read(8192)
        # csv.Sniffer accepts a string of possible delimiters
        dialect = csv.Sniffer().sniff(sample, delimiters=",\t;|")
        return dialect.delimiter
    except Exception:
        return None


def main():
    p = argparse.ArgumentParser(description="Extract peptides from a CSV and search them in FASTA(s).")
    p.add_argument("mgf_csv", type=Path, help="Path to MGF CSV that contains peptide sequences")
    p.add_argument("fasta", type=Path, nargs="+", help="One or more FASTA files to search")
    p.add_argument("--col", type=str, default=None, help="Column name that contains peptides (optional)")
    p.add_argument("--minlen", type=int, default=5, help="Minimum peptide length to search (after cleaning)")
    p.add_argument("--out", type=Path, default=Path("peptide_fasta_matches.csv"), help="Output CSV path")
    args = p.parse_args()

    if not args.mgf_csv.exists():
        raise SystemExit(f"Input CSV not found: {args.mgf_csv}")
    for f in args.fasta:
        if not f.exists():
            raise SystemExit(f"FASTA not found: {f}")

    # Robust read: try sniff, then common separators, then python engine fallback
    delim = sniff_delimiter(args.mgf_csv)
    df = None
    read_err = None
    if delim:
        try:
            df = pd.read_csv(args.mgf_csv, dtype=str, keep_default_na=False, sep=delim)
        except Exception as e:
            read_err = e
    if df is None:
        for sep_try in ['\t', ',', ';', '|']:
            try:
                df = pd.read_csv(args.mgf_csv, dtype=str, keep_default_na=False, sep=sep_try)
                read_err = None
                break
            except Exception as e:
                read_err = e
    if df is None:
        try:
            df = pd.read_csv(args.mgf_csv, dtype=str, keep_default_na=False, sep=None, engine='python')
        except Exception as e:
            raise SystemExit(f"Failed to read input CSV/TSV: {e}\nTry opening the file to inspect delimiter or provide a clean CSV.\nOriginal error: {read_err}")

    col = args.col or detect_peptide_column(df)
    peptides_raw = df[col].astype(str).tolist()

    peptides = [clean_peptide(x) for x in peptides_raw]
    # build unique list preserving order
    seen = set()
    unique_peptides = []
    for pep in peptides:
        if pep and pep not in seen:
            seen.add(pep)
            unique_peptides.append(pep)

    unique_peptides = [p for p in unique_peptides if len(p) >= args.minlen]

    fasta_records = load_fasta_indexed(args.fasta)

    results = []
    for pep in unique_peptides:
        matched = False
        for db_label, sid, desc, seq in fasta_records:
            if len(pep) > len(seq):
                continue
            starts = find_all_occurrences(seq, pep)
            for s0 in starts:
                matched = True
                results.append({
                    "peptide": pep,
                    "fasta_file": db_label,
                    "protein_id": sid,
                    "protein_description": desc,
                    "start_1based": s0 + 1,
                    "end_1based": s0 + len(pep),
                    "peptide_length": len(pep)
                })
        if not matched:
            results.append({
                "peptide": pep,
                "fasta_file": None,
                "protein_id": None,
                "protein_description": None,
                "start_1based": None,
                "end_1based": None,
                "peptide_length": len(pep)
            })

    out_df = pd.DataFrame(results, columns=[
        "peptide", "peptide_length", "fasta_file", "protein_id", "protein_description",
        "start_1based", "end_1based"
    ])
    args.out.parent.mkdir(parents=True, exist_ok=True)
    out_df.to_csv(args.out, index=False)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
