#python mqrunDash_db_verify.py --db "Z:\\Download\\mqrun.duckdb" --mode peptide --term HLSGEFGK
import argparse
import re
import sys
from pathlib import Path

import duckdb
import pandas as pd


def normalized_term(token):
    return token.strip()


def token_in_semicolon_list(value, token, case_insensitive=True, ignore_prefix=None):
    if pd.isna(value):
        return False
    values = [item.strip() for item in str(value).split(';') if item.strip()]
    if ignore_prefix is not None:
        values = [item for item in values if not item.startswith(ignore_prefix)]
    if case_insensitive:
        values = [item.lower() for item in values]
        token = token.lower()
    return token in values


def load_direct_rows(con):
    sql = """
        WITH totals AS (
            SELECT run_id,
                   SUM("Intensity") FILTER (
                       WHERE "Reverse" IS NULL
                         AND "Potential contaminant" IS NULL
                         AND "Only identified by site" IS NULL
                         AND "Intensity" > 0
                   ) AS sum_intensity
            FROM proteinGroups GROUP BY run_id
        )
        SELECT p.run_id,
               COALESCE(p."Protein IDs",       '')  AS protein_ids,
               COALESCE(p."Gene names",        '')  AS gene_names,
               COALESCE(p."Protein names",     '')  AS protein_names,
               COALESCE(p."Peptide sequences", '')  AS pep_seqs,
               p."Intensity", p."iBAQ", p."Score",
               p."Top3",
               p."Peptides"                              AS peptides,
               p."Unique peptides"                       AS unique_peptides,
               p."Razor + unique peptides"               AS razor_peptides,
               p."Sequence coverage [%]"                 AS seq_cov,
               p."Q-value"                               AS q_value,
               p."Mol. weight [kDa]"                     AS mol_weight,
               p."Sequence length"                        AS seq_length,
               t.sum_intensity,
               CASE WHEN t.sum_intensity > 0
                    THEN p."Intensity" / t.sum_intensity ELSE NULL END AS frac_intensity,
               RANK() OVER (
                   PARTITION BY p.run_id ORDER BY p."Intensity" DESC NULLS LAST
               ) AS intensity_rank
        FROM proteinGroups p
        JOIN totals t ON t.run_id = p.run_id
        WHERE p."Reverse" IS NULL
          AND p."Potential contaminant" IS NULL
          AND p."Only identified by site" IS NULL
    """
    return con.execute(sql).df()


def direct_gene_profile(con, gene):
    gene = normalized_term(gene)
    rows = load_direct_rows(con)
    mask = rows['gene_names'].apply(lambda x: token_in_semicolon_list(x, gene, case_insensitive=True))
    return rows[mask].copy()


def direct_uniprot_profile(con, uid):
    uid = normalized_term(uid)
    rows = load_direct_rows(con)
    mask = rows['protein_ids'].apply(
        lambda x: token_in_semicolon_list(x, uid, case_insensitive=True, ignore_prefix='CON__')
    )
    return rows[mask].copy()


def direct_peptide_profile(con, seq):
    seq = normalized_term(seq).upper()
    rows = load_direct_rows(con)
    mask = rows['pep_seqs'].apply(lambda x: token_in_semicolon_list(x.upper(), seq, case_insensitive=False))
    return rows[mask].copy()


def summarize_profile(rows, term, kind):
    if rows.empty:
        print(f"No rows found for {kind} '{term}'")
        return

    runs = sorted(rows['run_id'].unique())
    n_present = len(runs)
    n_total = con.execute('SELECT COUNT(DISTINCT run_id) FROM proteinGroups').fetchone()[0]
    print(f"{kind.title()} '{term}'")
    print(f"  distinct runs present : {n_present}")
    print(f"  total runs in DB      : {n_total}")
    print(f"  detected in          : {n_present}/{n_total} ({100 * n_present / n_total:.1f}%)")
    print(f"  rows returned         : {len(rows)}")

    if kind == 'gene':
        genes = set(g.strip() for g in rows['gene_names'].str.split(';').explode().dropna() if g.strip())
        uniprots = set(u.strip() for u in rows['protein_ids'].str.split(';').explode().dropna() if u.strip() and not u.strip().startswith('CON__'))
        print(f"  gene names in rows    : {sorted(genes)[:10]}")
        print(f"  UniProt IDs in rows   : {sorted(uniprots)[:10]}")
    elif kind == 'uniprot':
        genes = set(g.strip() for g in rows['gene_names'].str.split(';').explode().dropna() if g.strip())
        print(f"  gene names in rows    : {sorted(genes)[:10]}")
    else:
        seqs = set(s.strip().upper() for s in rows['pep_seqs'].str.split(';').explode().dropna() if s.strip())
        print(f"  peptide rows           : {len(seqs)} distinct peptides in matching rows")

    rank = rows['intensity_rank'].dropna().astype(float)
    if not rank.empty:
        print(f"  intensity_rank median : {rank.median():.1f}")
        print(f"  intensity_rank mean   : {rank.mean():.1f}")
        print(f"  intensity_rank min    : {rank.min():.1f}")
        print(f"  intensity_rank max    : {rank.max():.1f}")

    print(f"  intensity sum         : {rows['Intensity'].sum():,.0f}")
    print(f"  iBAQ sum              : {rows['iBAQ'].sum():,.0f}")
    print(f"  Top3 sum              : {rows['Top3'].sum():,.0f}")
    print(f"  median peptides       : {rows['peptides'].median():.1f}" if not rows['peptides'].dropna().empty else "  median peptides       : n/a")


def main():
    parser = argparse.ArgumentParser(description="Directly verify mqrunDash data from DuckDB.")
    parser.add_argument("--db", required=True, help="Path to the DuckDB file")
    parser.add_argument("--mode", choices=['gene', 'uniprot', 'peptide'], required=True)
    parser.add_argument("--term", required=True)
    args = parser.parse_args()

    db_path = Path(args.db)
    if not db_path.exists():
        raise FileNotFoundError(f"DuckDB file not found: {db_path}")

    global con
    con = duckdb.connect(str(db_path), read_only=True)
    try:
        if args.mode == 'gene':
            rows = direct_gene_profile(con, args.term)
        elif args.mode == 'uniprot':
            rows = direct_uniprot_profile(con, args.term)
        else:
            rows = direct_peptide_profile(con, args.term)
        summarize_profile(rows, args.term, args.mode)
    finally:
        con.close()


if __name__ == '__main__':
    main()
