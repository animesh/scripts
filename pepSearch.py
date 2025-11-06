#!/usr/bin/env python3
#python pepSearch.py "Z:/Download/casanovo_20251104183757.mztab" "L:/promec/FastaDB/UP000000589_10090.fasta" "L:/promec/FastaDB/uniprot-human-iso-jan24.fasta"  --mztab --out results_peptide_matches.mztab.csv
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


def parse_mztab(path: Path) -> pd.DataFrame:
    """Parse mzTab identification file (PSH header + PSM rows).
    Splits fields on whitespace and returns a DataFrame of PSM records.
    """
    headers = None
    records = []
    with path.open('r', encoding='utf-8', errors='ignore') as fh:
        for line in fh:
            line = line.rstrip('\n')
            if not line:
                continue
            if line.startswith('PSH'):
                parts = line.split()
                headers = parts[1:]
                continue
            if line.startswith('PSM'):
                if headers is None:
                    continue
                parts = line.split()
                values = parts[1:]
                # pad or collapse excess values into last column
                if len(values) < len(headers):
                    values += [None] * (len(headers) - len(values))
                elif len(values) > len(headers):
                    values = values[:len(headers) - 1] + [' '.join(values[len(headers) - 1:])]
                records.append(dict(zip(headers, values)))
    if not records:
        return pd.DataFrame(columns=headers if headers is not None else [])
    return pd.DataFrame.from_records(records)


def detect_peptide_column(df: pd.DataFrame) -> str:
    for c in df.columns:
        if c in PEPTIDE_COL_CANDIDATES:
            return c
    for c in df.columns:
        sample = df[c].dropna().astype(str).head(50).tolist()
        if not sample:
            continue
        score = sum(bool(re.search(r'[A-Z]', s)) and len(re.sub(r'[^A-Z]', '', s)) >= 4 for s in sample)
        if score >= 1:
            return c
    raise ValueError("Could not auto-detect peptide column. Use --col to specify the column name.")


def clean_peptide(peptide: str) -> str:
    if peptide is None:
        return ""
    s = str(peptide)
    s = re.sub(r'\([^)]*\)', '', s)
    s = re.sub(r'\[[^\]]*\]', '', s)
    s = re.sub(r'[^A-Za-z]', '', s)
    return s.upper()


def load_fasta_indexed(fasta_paths: List[Path]) -> List[Tuple[str, str, str, str]]:
    records: List[Tuple[str, str, str, str]] = []
    for p in fasta_paths:
        label = p.name
        with p.open('r', encoding='utf-8', errors='ignore') as fh:
            for rec in SeqIO.parse(fh, 'fasta'):
                records.append((label, rec.id, rec.description, str(rec.seq).upper()))
    return records


def find_all_occurrences(seq: str, peptide: str) -> List[int]:
    starts: List[int] = []
    i = 0
    while True:
        j = seq.find(peptide, i)
        if j == -1:
            break
        starts.append(j)
        i = j + 1
    return starts


def sniff_delimiter(path: Path) -> Optional[str]:
    try:
        with path.open('r', encoding='utf-8', errors='ignore') as fh:
            sample = fh.read(8192)
        dialect = csv.Sniffer().sniff(sample, delimiters=",\t;| ")
        return dialect.delimiter
    except Exception:
        return None


def join_unique(items: List[str]) -> Optional[str]:
    seen = set()
    out: List[str] = []
    for x in items:
        if x and x not in seen:
            seen.add(x)
            out.append(x)
    return ";".join(out) if out else None


def main() -> int:
    p = argparse.ArgumentParser(description='Search peptides against FASTA(s)')
    p.add_argument('mgf_csv', type=Path, help='Input CSV/TSV/mzTab')
    p.add_argument('fasta', type=Path, nargs='+', help='One or more FASTA files')
    p.add_argument('--col', type=str, default=None, help='Peptide column name (override)')
    p.add_argument('--mztab', action='store_true', help="Treat input as mzTab and read PSM 'sequence' column")
    p.add_argument('--minlen', type=int, default=5, help='Minimum peptide length after cleaning')
    p.add_argument('--out', type=Path, default=Path('peptide_fasta_matches.csv'), help='Output CSV')
    args = p.parse_args()

    if not args.mgf_csv.exists():
        raise SystemExit(f'Input not found: {args.mgf_csv}')
    for f in args.fasta:
        if not f.exists():
            raise SystemExit(f'FASTA not found: {f}')

    if args.mztab:
        df = parse_mztab(args.mgf_csv)
    else:
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
                df = pd.read_csv(args.mgf_csv, dtype=str, keep_default_na=False, sep=r'\s+', engine='python')
                read_err = None
            except Exception as e:
                read_err = e
        if df is None:
            try:
                df = pd.read_csv(args.mgf_csv, dtype=str, keep_default_na=False, sep=None, engine='python')
            except Exception as e:
                raise SystemExit(f'Failed to read input: {e}\nOriginal error: {read_err}')

    # choose peptide column
    if args.mztab:
        seq_cols = [c for c in df.columns if c.lower() == 'sequence']
        if not seq_cols:
            seq_cols = [c for c in df.columns if 'sequence' in c.lower()]
        if not seq_cols:
            raise SystemExit(f"mzTab requested but no 'sequence' column. Columns: {list(df.columns)}")
        col = seq_cols[0]
    else:
        col = args.col or detect_peptide_column(df)

    peptides_raw = df[col].astype(str).tolist()
    peptides = [clean_peptide(x) for x in peptides_raw]
    seen = set()
    unique_peptides: List[str] = []
    for pep in peptides:
        if pep and pep not in seen:
            seen.add(pep)
            unique_peptides.append(pep)
    unique_peptides = [p for p in unique_peptides if len(p) >= args.minlen]

    fasta_records = load_fasta_indexed(args.fasta)

    agg = {}
    for pep in unique_peptides:
        entries: List[Tuple[str, str, str, str, str]] = []
        for fasta_label, prot_id, desc, seq in fasta_records:
            if len(pep) > len(seq):
                continue
            starts = find_all_occurrences(seq, pep)
            for s0 in starts:
                entries.append((fasta_label, prot_id, desc, str(s0 + 1), str(s0 + len(pep))))
        if entries:
            agg[pep] = {
                'peptide': pep,
                'peptide_length': len(pep),
                'fasta_file': join_unique([e[0] for e in entries]),
                'protein_id': join_unique([e[1] for e in entries]),
                'protein_description': join_unique([e[2] for e in entries]),
                'start_1based': join_unique([e[3] for e in entries]),
                'end_1based': join_unique([e[4] for e in entries]),
            }
        else:
            agg[pep] = {
                'peptide': pep,
                'peptide_length': len(pep),
                'fasta_file': None,
                'protein_id': None,
                'protein_description': None,
                'start_1based': None,
                'end_1based': None,
            }

    out_df = pd.DataFrame(list(agg.values()), columns=[
        'peptide', 'peptide_length', 'fasta_file', 'protein_id', 'protein_description', 'start_1based', 'end_1based'
    ])
    args.out.parent.mkdir(parents=True, exist_ok=True)
    out_df.to_csv(args.out, index=False)
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
