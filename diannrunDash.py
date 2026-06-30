"""
mqrunDashDIA.py  —  DIA-NN QC Dashboard
Run:  python mqrunDashDIA.py [path/to/mqrunDIA.duckdb]
Default DB: F:/promec/TIMSTOF/QC/DIA/mqrunDIA.duckdb
Deps: pip install dash plotly duckdb pandas numpy
Port: 8051 (mqrunDash.py for MaxQuant DDA uses 8050 -- runs alongside it)

COLUMN MAPPING NOTES (vs mqrunDash.py / MaxQuant proteinGroups):
  Intensity        -> PG.MaxLFQ            (protein-group-level LFQ quantity)
  iBAQ              -> Genes.MaxLFQ         (repurposed 2nd intensity track --
                                              NOT the same concept, just parallel)
  Top3              -> dropped              (no DIA-NN equivalent)
  Score              -> dropped              (no Andromeda-style score)
  Q-value            -> PG.Q.Value           (protein-group FDR, not precursor)
  Peptides            -> COUNT(DISTINCT Stripped.Sequence)
  Unique peptides    -> Proteotypic peptides (closest analog)
  Razor+unique        -> dropped              (no razor-peptide concept in DIA-NN)
  Seq coverage/MW/Seq length -> dropped (would need a FASTA join, not wired up)
  Reverse/Site-only    -> dropped (decoys pre-filtered at ingestion; no site-only mode)
  Potential contaminant -> derived from "Protein.Names" ILIKE '%cRAP%'
                           VERIFIED against real data: "Protein.Ids"-based tagging
                           over-counted by 5 (48 vs ground-truth 43, confirmed via
                           independent FASTA-digest check) on 231030_..._5576 --
                           5 protein groups had 'crap' in Protein.Ids but NOT in
                           Protein.Names. Protein.Names matches ground truth exactly.
  Precursors (NEW)     -> DIA-NN gives this for free, no MaxQuant equivalent
"""

import sys, os, numpy as np
import duckdb, pandas as pd
import plotly.graph_objects as go
from dash import Dash, dcc, html, Input, Output, callback, ALL
from dash.exceptions import PreventUpdate

DB = sys.argv[1] if len(sys.argv) > 1 else "F:/promec/TIMSTOF/QC/DIA/diannrun.duckdb"
# Optional second CLI argument for direct precursor-level parquet heatmaps.
# Defaults to the DB directory, recursively looking for DIA-NN *.d.report.parquet files.
PARQUET_GLOB = sys.argv[2] if len(sys.argv) > 2 else os.path.join(os.path.dirname(DB), "**", "*.d.report.parquet").replace("\\", "/")

FONT = "'Inter', 'Helvetica Neue', Arial, sans-serif"
MONO = "'JetBrains Mono', 'Fira Code', 'Courier New', monospace"

C_BLUE   = "#2563eb"
C_RED    = "#dc2626"
C_AMBER  = "#d97706"
C_VIOLET = "#7c3aed"
C_GREY   = "#6b7280"
C_TREND  = "#059669"
C_GREEN  = "#059669"

FC = {
    "target":      C_BLUE,
    "contaminant": C_AMBER,
}

METRICS = {
    "proteins":           ("Protein groups identified",  "target"),
    "median_lfq":         ("Median PG.MaxLFQ",            "median_lfq"),
    "total_lfq":          ("Total PG.MaxLFQ",              "total_lfq"),
    "median_genes_lfq":   ("Median Genes.MaxLFQ",          "median_genes_lfq"),
    "median_qval":        ("Median PG Q-value",            "median_qval"),
    "median_peptides":    ("Median Peptides/Protein",      "median_peptides"),
    "median_proteotypic": ("Median Proteotypic Peptides",  "median_proteotypic"),
    "median_precursors":  ("Median Precursors/Protein",    "median_precursors"),
}

# ── data ──────────────────────────────────────────────────────────────────────
def run_label(rid):
    """Short display label: YYMMDD_<last_numeric_token>."""
    parts = rid.split('_')
    date_part = parts[0] if parts else rid
    numeric = [p for p in parts[1:] if p.isdigit()]
    suffix = numeric[-1] if numeric else (parts[-1] if len(parts) > 1 else '')
    return f"{date_part}_{suffix}" if suffix else date_part

_SUMMARY_CACHE = None

def load_summary(force=False):
    """Contaminant tagging confirmed via real-data verification: "Protein.Names"
    ILIKE '%cRAP%' matches ground truth (independently confirmed by digesting
    the cRAP FASTA directly). "Protein.Ids" over-counts by including 5 extra
    protein groups whose Ids contain 'crap' but whose Names do not.
    """
    global _SUMMARY_CACHE
    if _SUMMARY_CACHE is not None and not force:
        return _SUMMARY_CACHE
    con = duckdb.connect(DB, read_only=True)
    q = """
        SELECT run_id,
            COUNT(*)                                                            AS total,
            COUNT(*) FILTER (WHERE "Protein.Names" NOT ILIKE '%cRAP%'
                               OR "Protein.Names" IS NULL)                      AS target,
            COUNT(*) FILTER (WHERE "Protein.Names" ILIKE '%cRAP%')              AS n_cont,
            MEDIAN("PG.MaxLFQ")                                                  AS median_lfq,
            SUM("PG.MaxLFQ")                                                     AS total_lfq,
            MEDIAN("Genes.MaxLFQ")                                               AS median_genes_lfq,
            MEDIAN("PG.Q.Value")                                                 AS median_qval,
            MEDIAN("Peptides")                                                   AS median_peptides,
            MEDIAN("Proteotypic peptides")                                       AS median_proteotypic,
            MEDIAN("Precursors")                                                 AS median_precursors
        FROM proteinGroupsDIA
        GROUP BY run_id ORDER BY run_id
    """
    df = con.execute(q).df()
    con.close()
    _SUMMARY_CACHE = df
    return df

def load_run(run_id):
    con = duckdb.connect(DB, read_only=True)
    df  = con.execute("""
        SELECT "Genes","Protein.Names","Protein.Ids","PG.MaxLFQ","Genes.MaxLFQ",
               "PG.Q.Value","Peptides","Proteotypic peptides","Precursors"
        FROM proteinGroupsDIA WHERE run_id=?
        ORDER BY "PG.MaxLFQ" DESC NULLS LAST LIMIT 3000
    """, [run_id]).df()
    con.close()
    return df


# ── In-memory indexes (built once at startup) ─────────────────────────────────
# Same architecture as mqrunDash.py: three exact-match dict indexes, no DB
# round-trips during search. See that file's header comment for the full
# rationale (was a SQL ILIKE wildcard scan before, far too slow at this scale).
#
#   _GENE_IDX    : gene_name.lower()    -> {run_id: row_dict}
#   _UNIPROT_IDX : protein_id.lower()   -> {run_id: row_dict}
#   _PEP_IDX     : peptide_seq.upper()  -> {run_id: True}
#   _PEP_STORE   : gene_name.lower()    -> {run_id: set(peptide_seqs)}
#   _PEP_TO_ROW  : peptide_seq.upper()  -> (gene_lower, run_id)  -- dominant
#                  (highest PG.MaxLFQ) row, for stable single-gene/uid labels
#   _RUNS_ORDERED: sorted list of all run_ids

_GENE_IDX     = {}
_UNIPROT_IDX  = {}
_PEP_IDX      = {}
_PEP_STORE    = {}
_PEP_TO_ROW   = {}
_RUNS_ORDERED = []
_PROFILE_LOADED = False
_Y_RANGES = {}
_TOP_GENES_MAP = {}

_TOP_GENES    = []
_TOP_UNIPROT  = []
_TOP_PEPTIDES = []


def _build_profile_store():
    """One DB query, one Python pass. Builds all indexes."""
    global _GENE_IDX, _UNIPROT_IDX, _PEP_IDX, _PEP_STORE, _PEP_TO_ROW
    global _RUNS_ORDERED, _PROFILE_LOADED
    global _TOP_GENES, _TOP_UNIPROT, _TOP_PEPTIDES, _TOP_GENES_MAP, _Y_RANGES

    con = duckdb.connect(DB, read_only=True)
    _RUNS_ORDERED = con.execute(
        'SELECT DISTINCT run_id FROM proteinGroupsDIA ORDER BY run_id'
    ).df()['run_id'].tolist()
    n_runs = len(_RUNS_ORDERED)

    raw = con.execute("""
        WITH totals AS (
            SELECT run_id,
                   SUM("PG.MaxLFQ") FILTER (
                       WHERE "Protein.Names" NOT ILIKE '%cRAP%' AND "PG.MaxLFQ" > 0
                   ) AS sum_lfq
            FROM proteinGroupsDIA GROUP BY run_id
        )
        SELECT p.run_id,
               p."Protein.Group"                       AS protein_group,
               COALESCE(p."Protein.Ids", '')         AS protein_ids,
               COALESCE(p."Genes",       '')          AS gene_names,
               COALESCE(p."Protein.Names", '')        AS protein_names,
               COALESCE(p."Peptide sequences", '')    AS pep_seqs,
               p."PG.MaxLFQ", p."Genes.MaxLFQ",
               p."PG.Q.Value"                          AS q_value,
               p."Peptides"                            AS peptides,
               p."Proteotypic peptides"                AS proteotypic_peptides,
               p."Precursors"                          AS precursors,
               t.sum_lfq,
               CASE WHEN t.sum_lfq > 0
                    THEN p."PG.MaxLFQ" / t.sum_lfq ELSE NULL END AS frac_intensity,
               RANK() OVER (
                   PARTITION BY p.run_id ORDER BY p."PG.MaxLFQ" DESC NULLS LAST
               ) AS intensity_rank
        FROM proteinGroupsDIA p
        JOIN totals t ON t.run_id = p.run_id
        WHERE p."Protein.Names" NOT ILIKE '%cRAP%'
    """).df()
    con.close()

    gene_idx    = {}
    uniprot_idx = {}
    pep_idx     = {}
    pep_str     = {}
    pep_to_row  = {}   # seq -> (gene_key, run_id, lfq)

    gene_runs  = {}    # gene_lower -> {name, ranks, seen_runs, uniprots}
    uprot_runs = {}    # uniprot_lower -> {name, gene, ranks, seen_runs}

    for _, row in raw.iterrows():
        run = row['run_id']
        rd  = {
            'gene_names':            row['gene_names'],
            'protein_names':         row['protein_names'],
            'protein_ids':           row['protein_ids'],
            'PG.MaxLFQ':             row['PG.MaxLFQ'],
            'Genes.MaxLFQ':          row['Genes.MaxLFQ'],
            'Q-value':               row['q_value'],
            'Peptides':              row['peptides'],
            'Proteotypic peptides':  row['proteotypic_peptides'],
            'Precursors':            row['precursors'],
            'frac_intensity':        row['frac_intensity'],
            'intensity_rank':        row['intensity_rank'],
            'sum_intensity':         row['sum_lfq'],
            'protein_group':         row['protein_group'],
        }

        genes = [g.strip() for g in str(row['gene_names']).split(';') if g.strip()]
        for g in genes:
            k = g.lower()
            gene_idx.setdefault(k, {})[run] = rd
            entry = gene_runs.setdefault(k, {'name': g, 'ranks': [], 'seen_runs': set(), 'uniprots': set()})
            if run not in entry['seen_runs']:
                entry['seen_runs'].add(run)
                if pd.notna(row['intensity_rank']):
                    entry['ranks'].append(row['intensity_rank'])
            entry['uniprots'].update(
                u.strip() for u in str(row['protein_ids']).split(';')
                if u.strip() and 'crap' not in u.strip().lower())

        uniprots = [u.strip() for u in str(row['protein_ids']).split(';')
                    if u.strip() and 'crap' not in u.strip().lower()]
        for u in uniprots:
            k = u.lower()
            uniprot_idx.setdefault(k, {})[run] = rd
            entry = uprot_runs.setdefault(k, {'name': u, 'gene': row['gene_names'], 'ranks': [], 'seen_runs': set()})
            if run not in entry['seen_runs']:
                entry['seen_runs'].add(run)
                if pd.notna(row['intensity_rank']):
                    entry['ranks'].append(row['intensity_rank'])

        seqs = {s.strip().upper() for s in str(row['pep_seqs']).split(';') if s.strip()}
        gene_key = genes[0].lower() if genes else ''
        for seq in seqs:
            pep_idx.setdefault(seq, {})[run] = True
            if seq not in pep_to_row or (
                    pd.notna(row['PG.MaxLFQ']) and
                    pd.notna(pep_to_row[seq][2]) and
                    row['PG.MaxLFQ'] > pep_to_row[seq][2]):
                pep_to_row[seq] = (gene_key, run, row['PG.MaxLFQ'])
            if gene_key:
                pep_str.setdefault(gene_key, {}).setdefault(run, set()).add(seq)

    # Post-filter gene→uniprot mapping (same rationale as mqrunDash.py):
    # only keep a UniProt ID under a gene key if that ID's own row maps
    # back to the same gene -- removes co-eluting proteins sharing peptides.
    for gkey, entry in gene_runs.items():
        clean = set()
        for uid in entry['uniprots']:
            ukey = uid.lower()
            if ukey in uniprot_idx:
                sample_run = next(iter(uniprot_idx[ukey]))
                uid_genes = str(uniprot_idx[ukey][sample_run]['gene_names']).lower()
                if gkey in uid_genes.split(';') or gkey == uid_genes.strip():
                    clean.add(uid)
        entry['uniprots'] = clean if clean else entry['uniprots']

    _GENE_IDX     = gene_idx
    _UNIPROT_IDX  = uniprot_idx
    _PEP_IDX      = pep_idx
    _PEP_STORE    = pep_str
    _PEP_TO_ROW   = {seq: (gk, rid) for seq, (gk, rid, _) in pep_to_row.items()}
    _PROFILE_LOADED = True

    # Top-table summaries are now built by DuckDB GROUP BY queries instead of
    # Python iterrows/rank-list bookkeeping. Keep UNNEST in an inner CTE; older
    # DuckDB builds do not like grouping directly on an UNNEST expression.
    con = duckdb.connect(DB, read_only=True)
    gene_agg = con.execute("""
        WITH ranked AS (
            SELECT unnest(string_split(COALESCE("Genes", ''), ';')) AS gene,
                   run_id,
                   RANK() OVER (PARTITION BY run_id ORDER BY "PG.MaxLFQ" DESC NULLS LAST) AS irank
            FROM proteinGroupsDIA
            WHERE "Protein.Names" NOT ILIKE '%cRAP%'
        )
        SELECT trim(gene) AS gene, COUNT(DISTINCT run_id) AS n_runs,
               100.0 * (? - COUNT(DISTINCT run_id)) / NULLIF(?, 0) AS miss_pct,
               MEDIAN(irank) AS med, AVG(irank) AS mean, MIN(irank) AS mn, MAX(irank) AS mx
        FROM ranked WHERE trim(gene) != ''
        GROUP BY lower(trim(gene)), trim(gene)
    """, [n_runs, n_runs]).df()
    uprot_agg = con.execute("""
        WITH ranked AS (
            SELECT unnest(string_split(COALESCE("Protein.Ids", ''), ';')) AS uid,
                   "Genes" AS genes, run_id,
                   RANK() OVER (PARTITION BY run_id ORDER BY "PG.MaxLFQ" DESC NULLS LAST) AS irank
            FROM proteinGroupsDIA
            WHERE "Protein.Names" NOT ILIKE '%cRAP%'
        )
        SELECT trim(uid) AS uid, any_value(split_part(genes, ';', 1)) AS gene,
               COUNT(DISTINCT run_id) AS n_runs,
               100.0 * (? - COUNT(DISTINCT run_id)) / NULLIF(?, 0) AS miss_pct,
               MEDIAN(irank) AS med, AVG(irank) AS mean, MIN(irank) AS mn, MAX(irank) AS mx
        FROM ranked WHERE trim(uid) != '' AND lower(trim(uid)) NOT LIKE '%crap%'
        GROUP BY lower(trim(uid)), trim(uid)
    """, [n_runs, n_runs]).df()
    pep_agg = con.execute("""
        WITH exploded AS (
            SELECT unnest(string_split(COALESCE("Peptide sequences", ''), ';')) AS peptide,
                   run_id, "Genes" AS genes, "Protein.Ids" AS protein_ids
            FROM proteinGroupsDIA
            WHERE "Protein.Names" NOT ILIKE '%cRAP%'
        )
        SELECT upper(trim(peptide)) AS peptide, COUNT(DISTINCT run_id) AS n_runs,
               100.0 * (? - COUNT(DISTINCT run_id)) / NULLIF(?, 0) AS miss_pct,
               any_value(split_part(genes, ';', 1)) AS gene,
               any_value(split_part(protein_ids, ';', 1)) AS uid
        FROM exploded WHERE trim(peptide) != ''
        GROUP BY upper(trim(peptide))
    """, [n_runs, n_runs]).df()
    con.close()
    _TOP_GENES   = gene_agg.sort_values(['miss_pct','med']).head(50).to_dict('records')
    _TOP_UNIPROT = uprot_agg.sort_values(['miss_pct','med']).head(50).to_dict('records')
    _TOP_GENES_MAP = {r['gene'].lower(): r for r in gene_agg.to_dict('records')}
    _TOP_PEPTIDES = pep_agg.sort_values(['miss_pct']).head(50).to_dict('records')
    range_cols = ["PG.MaxLFQ","Genes.MaxLFQ","Peptides","Proteotypic peptides",
                  "Precursors","frac_intensity"]
    _Y_RANGES = {}
    for col in range_cols:
        vals = []
        for gdata in gene_idx.values():
            for rd in gdata.values():
                v = rd.get(col)
                if v is not None and pd.notna(v) and v > 0:
                    vals.append(float(v))
        if vals:
            lo, hi = min(vals), max(vals)
            if col in ("PG.MaxLFQ","Genes.MaxLFQ","frac_intensity"):
                _Y_RANGES[col] = [np.log10(lo*0.5), np.log10(hi*2)]
            else:
                _Y_RANGES[col] = [lo*0.9, hi*1.1]
    print(f"Store: {len(gene_idx):,} genes  {len(uniprot_idx):,} UniProts  "
          f"{len(pep_idx):,} peptides  {n_runs} runs")


def _runs_to_df(idx_data):
    rows = []
    for run_id in _RUNS_ORDERED:
        if run_id in idx_data:
            d = dict(idx_data[run_id])
            d['run_id'] = run_id
            d['present'] = True
        else:
            d = {'run_id': run_id, 'present': False,
                 'PG.MaxLFQ': None, 'Genes.MaxLFQ': None, 'Q-value': None,
                 'Peptides': None, 'Proteotypic peptides': None, 'Precursors': None,
                 'frac_intensity': None, 'intensity_rank': None, 'sum_intensity': None}
        rows.append(d)
    return pd.DataFrame(rows)


def _pep_matrix(gene_key):
    run_peps = _PEP_STORE.get(gene_key, {})
    if not run_peps:
        return pd.DataFrame()
    pep_rows = [{'run_id': r, 'peptide': s}
                for r, seqs in run_peps.items() for s in seqs]
    if not pep_rows:
        return pd.DataFrame()
    long = pd.DataFrame(pep_rows).drop_duplicates()
    mat  = long.assign(v=True).pivot_table(
        index='peptide', columns='run_id', values='v', aggfunc='any', fill_value=False)
    mat = mat.reindex(columns=_RUNS_ORDERED, fill_value=False)
    return mat.loc[mat.sum(axis=1).sort_values(ascending=False).index]


def load_gene_profile(gene):
    if not _PROFILE_LOADED:
        _build_profile_store()
    key = gene.strip().lower()
    if key not in _GENE_IDX:
        return pd.DataFrame(), pd.DataFrame(), gene
    label = _GENE_IDX[key][next(iter(_GENE_IDX[key]))]['gene_names']
    return _runs_to_df(_GENE_IDX[key]), _pep_matrix(key), label


def load_uniprot_profile(uid):
    if not _PROFILE_LOADED:
        _build_profile_store()
    key = uid.strip().lower()
    if key not in _UNIPROT_IDX:
        return pd.DataFrame(), pd.DataFrame(), uid
    d0 = _UNIPROT_IDX[key][next(iter(_UNIPROT_IDX[key]))]
    gene_label = d0['gene_names'].split(';')[0].strip()
    label = f"{uid.strip()} ({gene_label})"
    g = gene_label.lower()
    return _runs_to_df(_UNIPROT_IDX[key]), _pep_matrix(g), label


def load_peptide_profile(seq):
    """Same ground-truth-presence design as mqrunDash.py's version:
    presence comes from _PEP_IDX directly (not protein-level presence),
    label comes from the dominant (highest PG.MaxLFQ) row via _PEP_TO_ROW.
    Returns 4-tuple: (profile_df, mat_df, label, pep_mode=True)."""
    if not _PROFILE_LOADED:
        _build_profile_store()
    key = seq.strip().upper()
    if key not in _PEP_IDX:
        return pd.DataFrame(), pd.DataFrame(), seq, True

    pep_runs = set(_PEP_IDX[key].keys()) & set(_RUNS_ORDERED)
    gene_key, anchor_run = _PEP_TO_ROW.get(key, (None, None))
    label = key
    if gene_key and anchor_run:
        rd0 = _GENE_IDX.get(gene_key, {}).get(anchor_run, {})
        gene0 = str(rd0.get('gene_names', '')).split(';')[0].strip()
        uid0  = next((u.strip() for u in str(rd0.get('protein_ids', '')).split(';')
                      if u.strip() and 'crap' not in u.strip().lower()), '')
        if gene0: label += f'  {gene0}'
        if uid0:  label += f'  [{uid0}]'

    none_row = {k: None for k in ('PG.MaxLFQ','Genes.MaxLFQ','Q-value','Peptides',
                                   'Proteotypic peptides','Precursors',
                                   'frac_intensity','intensity_rank','sum_intensity')}
    g_idx = _GENE_IDX.get(gene_key, {}) if gene_key else {}
    rows = []
    for rid in _RUNS_ORDERED:
        if rid in pep_runs:
            rd = g_idx.get(rid, none_row)
            rows.append({**rd, 'run_id': rid, 'present': True})
        else:
            rows.append({**none_row, 'run_id': rid, 'present': False})
    profile = pd.DataFrame(rows)

    mat = pd.DataFrame([{r: (r in pep_runs) for r in _RUNS_ORDERED}], index=[key])
    mat.columns.name = 'run_id'
    return profile, mat, label, True


# ── plotly base (identical to mqrunDash.py for visual consistency) ────────────
def base(title="", mt=44):
    return dict(
        title         = dict(text=title,
                             font=dict(size=11, family=MONO, color="#6b7280"),
                             x=0.0, xanchor="left", pad=dict(l=2)),
        paper_bgcolor = "rgba(0,0,0,0)",
        plot_bgcolor  = "rgba(0,0,0,0)",
        font          = dict(family=FONT, size=11, color="#374151"),
        margin        = dict(l=56, r=16, t=mt, b=52),
        xaxis         = dict(showgrid=False,
                             linecolor="rgba(0,0,0,0.1)",
                             tickfont=dict(size=9, family=MONO, color="#6b7280"),
                             tickcolor="rgba(0,0,0,0.15)"),
        yaxis         = dict(gridcolor="rgba(0,0,0,0.06)",
                             linecolor="rgba(0,0,0,0)",
                             tickfont=dict(size=9, family=MONO, color="#6b7280"),
                             zeroline=False),
        legend        = dict(font=dict(size=11, color="#374151"),
                             orientation="h",
                             yanchor="bottom", y=1.02,
                             xanchor="left",   x=0,
                             bgcolor="rgba(0,0,0,0)"),
        hoverlabel    = dict(bgcolor="white",
                             bordercolor="rgba(0,0,0,0.1)",
                             font=dict(family=MONO, size=11, color="#111827")),
        hovermode     = "x unified",
    )

# ── CSS (identical to mqrunDash.py) ────────────────────────────────────────────
CSS = """
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&family=JetBrains+Mono:wght@400;600&display=swap" rel="stylesheet">
<style>
*, *::before, *::after { box-sizing: border-box; }
body { margin: 0; background: #f9fafb; }

.qc-card {
    background: white;
    border: 1px solid #e5e7eb;
    border-radius: 8px;
    padding: 14px 18px;
    min-width: 120px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.05), 0 1px 2px rgba(0,0,0,0.04);
}
.qc-card-label {
    font-size: 10px; font-weight: 600; letter-spacing: 0.08em;
    text-transform: uppercase; color: #9ca3af;
}
.qc-card-value {
    font-size: 22px; font-weight: 600; margin-top: 4px;
    font-family: 'JetBrains Mono', monospace; color: #111827;
}

.qc-header  { background: white; border-bottom: 1px solid #e5e7eb; padding: 16px 28px; display: flex; align-items: baseline; gap: 18px; }
.qc-toolbar { background: white; border-bottom: 1px solid #e5e7eb; padding: 14px 28px; display: flex; gap: 40px; align-items: flex-end; flex-wrap: wrap; }
.qc-cards   { display: flex; gap: 12px; padding: 18px 28px; flex-wrap: wrap; }
.qc-hint    { font-size: 11px; color: #9ca3af; padding: 4px 30px 10px; }
.qc-detail  { display: flex; gap: 12px; padding: 0 28px 32px; }
.qc-ctrl-label {
    font-size: 10px; font-weight: 600; letter-spacing: 0.08em;
    text-transform: uppercase; color: #9ca3af; margin-bottom: 6px;
}

.Select-control {
    background: white !important;
    border: 1.5px solid #e5e7eb !important;
    border-radius: 6px !important;
    font-size: 13px !important;
    color: #111827 !important;
    box-shadow: none !important;
    cursor: pointer !important;
    transition: border-color 0.15s !important;
}
.Select-control:hover { border-color: #2563eb !important; }
.Select.is-open .Select-control {
    border-color: #2563eb !important;
    box-shadow: 0 0 0 3px rgba(37,99,235,0.1) !important;
}
.Select-value-label { color: #111827 !important; }
.Select-placeholder { color: #9ca3af !important; }
.Select-arrow       { border-top-color: #9ca3af !important; }
.Select-menu-outer {
    background: white !important;
    border: 1.5px solid #e5e7eb !important;
    border-radius: 8px !important;
    box-shadow: 0 10px 40px rgba(0,0,0,0.1), 0 2px 8px rgba(0,0,0,0.06) !important;
    margin-top: 3px !important;
    z-index: 9999 !important;
}
.Select-option {
    background: white !important; color: #374151 !important;
    font-size: 13px !important; padding: 9px 14px !important; cursor: pointer !important;
}
.Select-option:hover, .Select-option.is-focused { background: #eff6ff !important; color: #1d4ed8 !important; }
.Select-option.is-selected { background: #dbeafe !important; color: #1d4ed8 !important; font-weight: 600 !important; }
.Select-input > input { color: #111827 !important; font-size: 13px !important; background: transparent !important; }

input[type=checkbox] { accent-color: #2563eb; cursor: pointer; width: 13px; height: 13px; }

::-webkit-scrollbar { width: 5px; height: 5px; }
::-webkit-scrollbar-track { background: #f9fafb; }
::-webkit-scrollbar-thumb { background: #d1d5db; border-radius: 3px; }
::-webkit-scrollbar-thumb:hover { background: #9ca3af; }

@media (prefers-color-scheme: dark) {
    body { background: #0f1117 !important; }
    .qc-header, .qc-toolbar { background: #161b27 !important; border-color: rgba(255,255,255,0.07) !important; }
    .qc-card { background: #161b27 !important; border-color: rgba(255,255,255,0.07) !important; box-shadow: none !important; }
    .qc-card-label { color: #4b5563 !important; }
    .qc-card-value { color: #f3f4f6 !important; }
    .qc-ctrl-label { color: #4b5563 !important; }
    .qc-hint { color: #4b5563 !important; }
    .Select-control { background: #1e2433 !important; border-color: rgba(255,255,255,0.08) !important; color: #e5e7eb !important; }
    .Select-value-label { color: #e5e7eb !important; }
    .Select-placeholder { color: #4b5563 !important; }
    .Select-menu-outer { background: #1e2433 !important; border-color: rgba(255,255,255,0.08) !important; box-shadow: 0 10px 40px rgba(0,0,0,0.5) !important; }
    .Select-option { background: #1e2433 !important; color: #9ca3af !important; }
    .Select-option:hover, .Select-option.is-focused { background: #252d40 !important; color: #60a5fa !important; }
    .Select-option.is-selected { background: #1e3a5f !important; color: #60a5fa !important; }
    .Select-input > input { color: #e5e7eb !important; }
}
</style>
"""

app = Dash(__name__, title="DIA-NN QC")
app.index_string = app.index_string.replace("</head>", CSS + "</head>")

def card(label, val, color="#111827"):
    return html.Div([
        html.Div(label, className="qc-card-label"),
        html.Div(val,   className="qc-card-value", style={"color": color}),
    ], className="qc-card")

_chk = {"marginRight":"18px", "fontSize":"13px", "cursor":"pointer", "color":"#374151"}

app.layout = html.Div(style={"minHeight":"100vh"}, children=[

    html.Div(className="qc-header", children=[
        html.Span("PROMEC · DIA-NN QC",
                  style={"fontSize":"15px","fontWeight":"600","letterSpacing":"0.04em",
                         "fontFamily":MONO,"color":"#111827"}),
        html.Span(id="header-stats",
                  style={"fontSize":"12px","color":"#9ca3af"}),
    ]),

    html.Div(className="qc-toolbar", children=[
        html.Div([
            html.Div("Metric", className="qc-ctrl-label"),
            dcc.Dropdown(id="dd-metric",
                options=[{"label":v[0],"value":k} for k,v in METRICS.items()],
                value="proteins", clearable=False, style={"width":"240px"}),
        ]),
        html.Div([
            html.Div("Filter layers", className="qc-ctrl-label"),
            dcc.Checklist(id="chk-filters",
                options=[{"label":"  Contaminant (cRAP)","value":"contaminant"}],
                value=["contaminant"],
                inline=True, inputStyle={"marginRight":"5px"}, labelStyle=_chk),
        ]),
        html.Div([
            html.Div("Rolling avg", className="qc-ctrl-label"),
            dcc.Checklist(id="chk-trend",
                options=[{"label":"  Show","value":"y"}],
                value=["y"], inline=True,
                inputStyle={"marginRight":"5px"}, labelStyle=_chk),
        ]),
    ]),

    html.Div(id="cards", className="qc-cards"),

    dcc.Graph(id="trend", config={"displayModeBar":False},
              style={"height":"400px","margin":"0 28px"}),

    html.Div("↑  click any bar or point to inspect that run",
             className="qc-hint"),

    html.Div(className="qc-detail", children=[
        dcc.Graph(id="breakdown", config={"displayModeBar":False}, style={"flex":"1","height":"270px"}),
        dcc.Graph(id="lfq-hist",  config={"displayModeBar":False}, style={"flex":"1","height":"270px"}),
        dcc.Graph(id="qval-hist", config={"displayModeBar":False}, style={"flex":"1","height":"270px"}),
    ]),

    html.Div(id="run-detail", style={
        "margin":"0 28px 12px","padding":"12px 16px",
        "background":"white","border":"1px solid #e5e7eb",
        "borderRadius":"8px","fontSize":"11px","fontFamily":MONO,
        "color":"#374151","lineHeight":"1.8","display":"none"
    }),

    dcc.Store(id="sel-run"),
    dcc.Store(id="sel-search"),
    dcc.Interval(id="interval", interval=3600*1000, n_intervals=0),

    html.Hr(style={"border":"none","borderTop":"1px solid #e5e7eb","margin":"8px 28px 0"}),

    html.Div(style={"padding":"12px 28px 0","display":"flex","gap":"14px"}, children=[
        html.Div([
            html.Div("Genes · by median rank", className="qc-ctrl-label", style={"marginBottom":"6px"}),
            html.Div(id="tbl-genes",   style={"fontSize":"11px","fontFamily":MONO,"lineHeight":"1.7"}),
        ], style={"flex":"1","background":"white","border":"1px solid #e5e7eb","borderRadius":"8px","padding":"12px 14px"}),
        html.Div([
            html.Div("UniProt IDs · by median rank", className="qc-ctrl-label", style={"marginBottom":"6px"}),
            html.Div(id="tbl-uniprot", style={"fontSize":"11px","fontFamily":MONO,"lineHeight":"1.7"}),
        ], style={"flex":"1","background":"white","border":"1px solid #e5e7eb","borderRadius":"8px","padding":"12px 14px"}),
        html.Div([
            html.Div("Peptides · by fewest missing", className="qc-ctrl-label", style={"marginBottom":"6px"}),
            html.Div(id="tbl-peptides",style={"fontSize":"11px","fontFamily":MONO,"lineHeight":"1.7"}),
        ], style={"flex":"1","background":"white","border":"1px solid #e5e7eb","borderRadius":"8px","padding":"12px 14px"}),
    ]),

    html.Div(className="qc-toolbar", style={"marginTop":"0"}, children=[
        html.Div([
            html.Div("Gene name (exact, e.g. ACTB)", className="qc-ctrl-label"),
            dcc.Input(id="inp-gene", type="text", debounce=True,
                placeholder="ACTB",
                style={"width":"180px","height":"36px","border":"1.5px solid #e5e7eb",
                       "borderRadius":"6px","padding":"0 10px","fontSize":"13px",
                       "fontFamily":MONO,"outline":"none"}),
        ]),
        html.Div([
            html.Div("UniProt ID (exact, e.g. P60709)", className="qc-ctrl-label"),
            dcc.Input(id="inp-uniprot", type="text", debounce=True,
                placeholder="P60709",
                style={"width":"180px","height":"36px","border":"1.5px solid #e5e7eb",
                       "borderRadius":"6px","padding":"0 10px","fontSize":"13px",
                       "fontFamily":MONO,"outline":"none"}),
        ]),
        html.Div([
            html.Div("Peptide sequence (exact, e.g. GYSFTTAER)", className="qc-ctrl-label"),
            dcc.Input(id="inp-peptide", type="text", debounce=True,
                placeholder="GYSFTTAER",
                style={"width":"240px","height":"36px","border":"1.5px solid #e5e7eb",
                       "borderRadius":"6px","padding":"0 10px","fontSize":"13px",
                       "fontFamily":MONO,"outline":"none"}),
        ]),
        html.Div(id="profile-missing-badge",
                 style={"fontSize":"12px","color":"#9ca3af","alignSelf":"flex-end","paddingBottom":"4px"}),
    ]),

    html.Div(id="profile-summary", style={
        "margin":"0 28px 0","padding":"10px 16px",
        "background":"white","border":"1px solid #e5e7eb","borderRadius":"8px",
        "fontSize":"11px","fontFamily":MONO,"color":"#374151",
        "lineHeight":"1.8","display":"none"
    }),

    html.Div(id="profile-section", className="qc-detail", style={"paddingTop":"12px"}, children=[
        dcc.Graph(id="profile-lfq",       config={"displayModeBar":False}, style={"flex":"1","height":"270px"}),
        dcc.Graph(id="profile-genes-lfq", config={"displayModeBar":False}, style={"flex":"1","height":"270px"}),
        dcc.Graph(id="profile-frac",      config={"displayModeBar":False}, style={"flex":"1","height":"270px"}),
        dcc.Graph(id="profile-qval",      config={"displayModeBar":False}, style={"flex":"1","height":"270px"}),
    ]),

    html.Div(id="profile-extra", className="qc-detail", style={"padding":"0 28px 8px"}, children=[
        dcc.Graph(id="profile-peptide-cnt", config={"displayModeBar":False}, style={"flex":"1","height":"220px"}),
        dcc.Graph(id="profile-proteotypic", config={"displayModeBar":False}, style={"flex":"1","height":"220px"}),
        dcc.Graph(id="profile-precursors",  config={"displayModeBar":False}, style={"flex":"1","height":"220px"}),
    ]),

    html.Div(className="qc-detail", style={"padding":"0 28px 12px"}, children=[
        dcc.Graph(id="profile-peptides", config={"displayModeBar":False}, style={"width":"100%","height":"380px"}),
    ]),
    html.Div(className="qc-detail", style={"padding":"0 28px 32px", "display":"grid", "gridTemplateColumns":"1fr 1fr", "gap":"12px"}, children=[
        dcc.Graph(id="prec-rt",   config={"displayModeBar":False}, style={"height":"420px"}),
        dcc.Graph(id="prec-im",   config={"displayModeBar":False}, style={"height":"420px"}),
        dcc.Graph(id="prec-qty",  config={"displayModeBar":False}, style={"height":"420px"}),
        dcc.Graph(id="prec-frag", config={"displayModeBar":False}, style={"height":"420px"}),
    ]),
])

# ── precursor-level heatmaps ───────────────────────────────────────────────────
def _protein_group_for_search(mode, term):
    """Resolve a search term to its Protein.Group string, reading directly
    from the existing _GENE_IDX/_UNIPROT_IDX/_PEP_TO_ROW indexes -- no
    separate lookup table needed, since every row dict already carries
    'protein_group'."""
    if not term:
        return None
    if mode == "gene":
        d = _GENE_IDX.get(term.strip().lower())
        return next(iter(d.values()))['protein_group'] if d else None
    if mode == "uniprot":
        d = _UNIPROT_IDX.get(term.strip().lower())
        return next(iter(d.values()))['protein_group'] if d else None
    if mode == "peptide":
        gk, rid = _PEP_TO_ROW.get(term.strip().upper(), (None, None))
        if gk and rid:
            return _GENE_IDX.get(gk, {}).get(rid, {}).get('protein_group')
        return None
    return None

_PRECURSOR_CACHE = {}
def _load_precursor_long(protein_group, stripped_sequence=None):
    if not protein_group:
        return pd.DataFrame()
    cache_key = (protein_group, (stripped_sequence or '').upper())
    if cache_key in _PRECURSOR_CACHE:
        return _PRECURSOR_CACHE[cache_key]
    frag_sum = "+".join([f'COALESCE("Fr.{i}.Quantity",0)' for i in range(12)])
    pep_filter = ' AND upper("Stripped.Sequence") = ?' if stripped_sequence else ''
    params = [PARQUET_GLOB, protein_group]
    if stripped_sequence:
        params.append(stripped_sequence.upper())
    con = duckdb.connect(read_only=False)
    try:
        df = con.execute(f"""
            SELECT "Run" AS run_id,
                   "Precursor.Id" AS precursor,
                   AVG("RT") AS RT,
                   AVG("IM") AS IM,
                   SUM("Precursor.Quantity") AS "Precursor.Quantity",
                   SUM({frag_sum}) AS "Frag.Quantity.Sum"
            FROM read_parquet(?, union_by_name=true)
            WHERE "Protein.Group" = ? AND "Decoy" = 0 {pep_filter}
            GROUP BY "Run", "Precursor.Id"
        """, params).df()
    finally:
        con.close()
    _PRECURSOR_CACHE[cache_key] = df
    return df

def _precursor_heatmap(long, value_col, title, colorscale, log10=False):
    if long is None or long.empty:
        fig = go.Figure()
        fig.update_layout(**base(title, mt=44))
        fig.add_annotation(text="no precursor parquet data", x=0.5, y=0.5,
                           xref="paper", yref="paper", showarrow=False,
                           font=dict(size=11, family=MONO, color="#9ca3af"))
        return fig
    rank = (long.groupby('precursor')
                .agg(n_det=('run_id','nunique'), med_qty=('Precursor.Quantity','median'))
                .sort_values(['n_det','med_qty'], ascending=[False, False])
                .head(100))
    precursors = rank.index.tolist()
    mat = (long[long['precursor'].isin(precursors)]
           .pivot_table(index='precursor', columns='run_id', values=value_col, aggfunc='mean')
           .reindex(index=precursors, columns=_RUNS_ORDERED))
    z = mat.where(mat > 0).apply(np.log10) if log10 else mat
    fig = go.Figure(go.Heatmap(
        z=z.values,
        x=list(z.columns),
        y=[p if len(p) <= 70 else p[:67] + '…' for p in z.index],
        colorscale=colorscale,
        colorbar=dict(title='log10' if log10 else value_col),
        hovertemplate="%{x}<br>%{y}<br>%{z:.4g}<extra></extra>",
    ))
    layout = base(title, mt=44)
    layout['xaxis'].update(tickangle=-55, tickfont=dict(size=7, family=MONO, color="#9ca3af"))
    layout['yaxis'].update(autorange='reversed', tickfont=dict(size=7, family=MONO, color="#374151"))
    layout['margin']['l'] = 230
    layout['margin']['b'] = 120
    fig.update_layout(**layout)
    fig.update_layout(height=max(320, min(900, 100 + 8 * len(z.index))))
    return fig

# ── callbacks ─────────────────────────────────────────────────────────────────

@callback(Output("cards","children"), Output("header-stats","children"),
          Input("dd-metric","value"), Input("interval","n_intervals"))
def update_cards(_, _n):
    SUM = load_summary(force=True)
    stats = f"{len(SUM)} runs  ·  {SUM['total'].sum():,} protein groups"
    cards = [
        card("Runs ingested",  str(len(SUM))),
        card("Avg target/run", f"{SUM['target'].mean():,.0f}"),
        card("Best run",       f"{SUM['target'].max():,}", C_BLUE),
        card("Worst run",      f"{SUM['target'].min():,}", C_RED),
        card("Total groups",   f"{SUM['total'].sum():,}",  C_GREY),
    ]
    return cards, stats


@callback(Output("trend","figure"),
          Input("dd-metric","value"),
          Input("chk-filters","value"),
          Input("chk-trend","value"),
          Input("interval","n_intervals"))
def update_trend(metric, active, trend_on, _n):
    df  = load_summary()
    x   = df["run_id"]
    fig = go.Figure()

    if metric == "proteins":
        fig.add_trace(go.Bar(x=x, y=df["target"], name="Target",
                             marker_color=C_BLUE, marker_line_width=0,
                             hovertemplate="%{x}<br>Target: %{y:,}<extra></extra>"))
        if active and "contaminant" in active:
            fig.add_trace(go.Bar(x=x, y=df["n_cont"], name="Contaminant",
                                 marker_color=FC["contaminant"], marker_line_width=0,
                                 hovertemplate="%{x}<br>Contaminant: %{y:,}<extra></extra>"))
        fig.update_layout(barmode="stack")
        ytitle = "Protein groups per run"
    else:
        label, col = METRICS[metric]
        fig.add_trace(go.Scatter(x=x, y=df[col], mode="lines+markers",
                                 line=dict(color=C_BLUE, width=2),
                                 marker=dict(size=4, color=C_BLUE),
                                 name=label,
                                 hovertemplate="%{x}<br>" + label + ": %{y:,.3g}<extra></extra>"))
        ytitle = label

    if trend_on and "y" in trend_on and len(df) >= 3:
        w    = max(3, len(df) // 8)
        roll = df["target"].rolling(w, center=True, min_periods=1).mean()
        fig.add_trace(go.Scatter(x=x, y=roll, mode="lines",
                                 name=f"{w}-run rolling avg",
                                 line=dict(color=C_TREND, width=2, dash="dot"),
                                 hoverinfo="skip"))

    labels = [run_label(r) for r in df["run_id"]]
    layout = base(mt=52)
    layout["xaxis"].update(tickangle=-55, tickfont=dict(size=7, family=MONO, color="#9ca3af"),
                           tickmode="array", tickvals=list(df["run_id"]), ticktext=labels)
    layout["yaxis"]["title"] = dict(text=ytitle, font=dict(size=11))
    layout["bargap"]         = 0.12
    layout["margin"]["b"]    = 80
    fig.update_layout(**layout)
    return fig


@callback(Output("sel-run","data"), Input("trend","clickData"), Input("interval","n_intervals"))
def store_sel(cd, _n):
    if not cd: return load_summary()["run_id"].iloc[-1]
    return cd["points"][0]["x"]


@callback(Output("breakdown","figure"),
          Output("run-detail","children"),
          Output("run-detail","style"),
          Input("sel-run","data"))
def update_breakdown(run_id):
    base_style = {"margin":"0 28px 12px","padding":"12px 16px",
                  "background":"white","border":"1px solid #e5e7eb",
                  "borderRadius":"8px","fontSize":"11px","fontFamily":MONO,
                  "color":"#374151","lineHeight":"1.8"}
    SUM = load_summary()
    row = SUM[SUM["run_id"] == run_id]
    if row.empty: return go.Figure(), "", {**base_style, "display":"none"}
    r      = row.iloc[0]
    total  = r["total"]
    cats   = ["Target", "Contaminant"]
    vals   = [r["target"], r["n_cont"]]
    colors = [C_BLUE, C_AMBER]
    pct    = [f"{v:,}  ({100*v/total:.1f}%)" if total else f"{v:,}" for v in vals]
    fig = go.Figure(go.Bar(x=cats, y=vals, marker_color=colors, marker_line_width=0,
                           text=pct, textposition="outside",
                           textfont=dict(size=10, family=MONO, color="#374151"),
                           hovertemplate="%{x}: %{y:,}<extra></extra>"))
    layout = base(f"breakdown  ·  {run_label(run_id)}", mt=40)
    layout["yaxis"]["title"] = dict(text="Count", font=dict(size=10))
    layout["hovermode"]      = "closest"
    layout["margin"]["t"]    = 40
    fig.update_layout(**layout)

    def _sp(lbl, val):
        return html.Span([
            html.Span(f"{lbl}: ", style={"color":"#9ca3af"}),
            html.Span(val, style={"color":"#111827","fontWeight":"600","marginRight":"20px"}),
        ])
    def _f(v): return f"{v:,.3g}" if pd.notna(v) else "n/a"
    detail_cols = [
        ('Target',                r['target']),
        ('Contaminant',           r['n_cont']),
        ('Total groups',          r['total']),
        ('Median PG.MaxLFQ',      r.get('median_lfq', float('nan'))),
        ('Median Genes.MaxLFQ',   r.get('median_genes_lfq', float('nan'))),
        ('Median PG Q-value',     r.get('median_qval', float('nan'))),
        ('Median peptides/prot',  r.get('median_peptides', float('nan'))),
        ('Median proteotypic',    r.get('median_proteotypic', float('nan'))),
        ('Median precursors',     r.get('median_precursors', float('nan'))),
        ('Total PG.MaxLFQ',       r.get('total_lfq', float('nan'))),
    ]
    cells = [_sp(lbl, _f(val)) for lbl, val in detail_cols]
    detail_children = [
        html.Div(run_id, style={"fontWeight":"700","color":C_BLUE,
                                "marginBottom":"6px","fontSize":"12px"}),
        html.Div(cells, style={"display":"flex","flexWrap":"wrap"}),
    ]
    return fig, detail_children, {**base_style, "display":"block"}


@callback(Output("lfq-hist","figure"), Input("sel-run","data"))
def update_lfq_hist(run_id):
    df    = load_run(run_id)
    clean = df[~df["Protein.Names"].str.contains('crap', case=False, na=False)]
    lfq   = clean["PG.MaxLFQ"].dropna()
    lfq   = lfq[lfq > 0]
    if lfq.empty: return go.Figure()
    log_i = np.log10(lfq)
    med   = float(log_i.median())
    fig = go.Figure(go.Histogram(x=log_i, nbinsx=50,
                                 marker_color=C_BLUE, marker_line_width=0, opacity=0.7,
                                 hovertemplate="log₁₀(PG.MaxLFQ) %{x:.2f}<br>n=%{y}<extra></extra>"))
    fig.add_vline(x=med, line_color=C_AMBER, line_dash="dash", line_width=2,
                  annotation_text=f"med {med:.1f}",
                  annotation_font_size=10, annotation_font_color=C_AMBER,
                  annotation_font_family=MONO)
    layout = base(f"PG.MaxLFQ  ·  {run_label(run_id)}", mt=40)
    layout["xaxis"]["title"] = dict(text="log₁₀(PG.MaxLFQ)", font=dict(size=10))
    layout["yaxis"]["title"] = dict(text="Protein groups",   font=dict(size=10))
    layout["hovermode"]      = "closest"
    layout["margin"]["t"]    = 40
    fig.update_layout(**layout)
    return fig


@callback(Output("qval-hist","figure"), Input("sel-run","data"))
def update_qval_hist(run_id):
    """Replaces mqrunDash.py's Score histogram -- DIA-NN has no Andromeda-style
    score, PG.Q.Value is the closest available per-protein quality signal."""
    df    = load_run(run_id)
    clean = df[~df["Protein.Names"].str.contains('crap', case=False, na=False)]
    qval  = clean["PG.Q.Value"].dropna()
    if qval.empty: return go.Figure()
    med = float(qval.median())
    fig = go.Figure(go.Histogram(x=qval, nbinsx=50,
                                 marker_color=C_VIOLET, marker_line_width=0, opacity=0.7,
                                 hovertemplate="PG.Q.Value %{x:.4f}<br>n=%{y}<extra></extra>"))
    fig.add_vline(x=med, line_color=C_AMBER, line_dash="dash", line_width=2,
                  annotation_text=f"med {med:.4f}",
                  annotation_font_size=10, annotation_font_color=C_AMBER,
                  annotation_font_family=MONO)
    layout = base(f"PG Q-value  ·  {run_label(run_id)}", mt=40)
    layout["xaxis"]["title"] = dict(text="PG.Q.Value", font=dict(size=10))
    layout["yaxis"]["title"] = dict(text="Protein groups", font=dict(size=10))
    layout["hovermode"]      = "closest"
    layout["margin"]["t"]    = 40
    fig.update_layout(**layout)
    return fig


@callback(Output("tbl-genes","children"),
          Output("tbl-uniprot","children"),
          Output("tbl-peptides","children"),
          Input("interval","n_intervals"))
def update_top_tables(_n):
    if not _PROFILE_LOADED:
        return "loading...", "loading...", "loading..."

    def _rs(r): return f"med:{r['med']:.0f} mean:{r['mean']:.0f} min:{r['mn']:.0f} max:{r['mx']:.0f}"

    gene_divs = [html.Div([
        html.Span(r["gene"],
            style={"color":C_BLUE,"fontWeight":"600","cursor":"pointer",
                   "textDecoration":"underline dotted","marginRight":"6px"},
            id={"type":"top-gene-link","index":r["gene"]}),
        html.Span(f"{r['n_runs']} runs  miss {r['miss_pct']:.1f}%  {_rs(r)}",
            style={"color":"#6b7280","fontSize":"10px"}),
    ]) for r in _TOP_GENES[:20]]

    uprot_divs = [html.Div([
        html.Span(r["uid"],
            style={"color":C_VIOLET,"fontWeight":"600","cursor":"pointer",
                   "textDecoration":"underline dotted","marginRight":"6px"},
            id={"type":"top-uprot-link","index":r["uid"]}),
        html.Span(f"{r['gene'][:12]}  {r['n_runs']} runs  miss {r['miss_pct']:.1f}%  {_rs(r)}",
            style={"color":"#6b7280","fontSize":"10px"}),
    ]) for r in _TOP_UNIPROT[:20]]

    pep_divs = [html.Div([
        html.Span(r["peptide"],
            style={"color":C_AMBER,"fontWeight":"600","cursor":"pointer",
                   "textDecoration":"underline dotted","marginRight":"6px"},
            id={"type":"top-pep-link","index":r["peptide"]}),
        html.Span(
            f"{r['n_runs']} runs  miss {r['miss_pct']:.1f}%"
            + (f"  [{r['gene']}]" if r.get('gene') else "")
            + (f"  [{r['uid']}]"  if r.get('uid')  else ""),
            style={"color":"#6b7280","fontSize":"10px"}),
    ]) for r in _TOP_PEPTIDES[:20]]

    return gene_divs, uprot_divs, pep_divs


@callback(Output("inp-gene",   "value", allow_duplicate=True),
          Output("sel-search", "data",  allow_duplicate=True),
          Input({"type":"top-gene-link","index":ALL}, "n_clicks"),
          prevent_initial_call=True)
def click_gene_link(n_clicks):
    from dash import ctx
    if not any(n_clicks): raise PreventUpdate
    term = ctx.triggered_id["index"]
    return term, {"mode": "gene", "term": term}

@callback(Output("inp-uniprot","value", allow_duplicate=True),
          Output("sel-search", "data",  allow_duplicate=True),
          Input({"type":"top-uprot-link","index":ALL}, "n_clicks"),
          prevent_initial_call=True)
def click_uprot_link(n_clicks):
    from dash import ctx
    if not any(n_clicks): raise PreventUpdate
    term = ctx.triggered_id["index"]
    return term, {"mode": "uniprot", "term": term}

@callback(Output("inp-peptide","value", allow_duplicate=True),
          Output("sel-search", "data",  allow_duplicate=True),
          Input({"type":"top-pep-link","index":ALL}, "n_clicks"),
          prevent_initial_call=True)
def click_pep_link(n_clicks):
    from dash import ctx
    if not any(n_clicks): raise PreventUpdate
    term = ctx.triggered_id["index"]
    return term, {"mode": "peptide", "term": term}

@callback(Output("sel-search","data", allow_duplicate=True),
          Input("inp-gene",    "value"),
          Input("inp-uniprot", "value"),
          Input("inp-peptide", "value"),
          prevent_initial_call=True)
def store_search(gene, uniprot, peptide):
    from dash import ctx
    tid = ctx.triggered_id if ctx.triggered_id else None
    if tid == "inp-gene"    and gene:    return {"mode": "gene",    "term": gene.strip()}
    if tid == "inp-uniprot" and uniprot: return {"mode": "uniprot", "term": uniprot.strip()}
    if tid == "inp-peptide" and peptide: return {"mode": "peptide", "term": peptide.strip()}
    raise PreventUpdate


def _profile_fig(df, col, title_prefix, color, unit_label, log_scale=False, fixed_range=None):
    if df is None or df.empty:
        return go.Figure()
    n_total   = len(df)
    n_present = int(df["present"].sum())
    n_missing = n_total - n_present
    miss_pct  = 100 * n_missing / n_total if n_total else 0

    present = df[df["present"]]
    missing = df[~df["present"]]

    y_vals = np.log10(present[col].clip(lower=1e-6)) if log_scale else present[col]
    y_lbl  = f"log₁₀({col})" if log_scale else col

    fig = go.Figure()
    fig.add_trace(go.Scatter(
        x=present["run_id"], y=y_vals,
        mode="markers+lines",
        marker=dict(size=5, color=color),
        line=dict(color=color, width=1.5),
        name=col,
        hovertemplate="%{x}<br>" + y_lbl + ": %{y:,.3g}<extra></extra>",
    ))
    if not missing.empty:
        fig.add_trace(go.Scatter(
            x=missing["run_id"],
            y=[y_vals.min() * 0.85 if not y_vals.empty else 0] * len(missing),
            mode="markers",
            marker=dict(size=6, color="#d1d5db", symbol="x"),
            name="Missing",
            hovertemplate="%{x}<br>not detected<extra></extra>",
        ))

    layout = base(f"{title_prefix}  ·  {n_missing}/{n_total} missing ({miss_pct:.1f}%)", mt=44)
    labels = [run_label(r) for r in df["run_id"]]
    layout["xaxis"].update(tickangle=-55, tickfont=dict(size=7, family=MONO, color="#9ca3af"),
                           tickmode="array", tickvals=list(df["run_id"]), ticktext=labels)
    layout["yaxis"]["title"] = dict(text=y_lbl, font=dict(size=10))
    if fixed_range is not None:
        layout["yaxis"]["range"] = fixed_range
    layout["hovermode"] = "closest"
    fig.update_layout(**layout)
    return fig


def _build_frac_fig(df, label):
    present = df[df["present"]].copy()
    missing = df[~df["present"]]
    if present.empty:
        return go.Figure()
    n_total   = len(df)
    n_missing = n_total - int(df["present"].sum())
    miss_pct  = 100 * n_missing / n_total if n_total else 0

    frac = present["frac_intensity"].fillna(0)
    rank = present["intensity_rank"]
    log_rank = np.log10(rank.clip(lower=1)).clip(upper=5)

    fig = go.Figure()
    fig.add_trace(go.Scatter(
        x=present["run_id"], y=frac * 100,
        mode="markers+lines",
        marker=dict(size=5, color=C_BLUE),
        line=dict(color=C_BLUE, width=1.5),
        name="% total PG.MaxLFQ",
        customdata=np.stack([rank.values, (frac * 1e6).values], axis=1),
        hovertemplate="%{x}<br>%{y:.4f}% of run total<br>rank %{customdata[0]:.0f}  (%{customdata[1]:.1f} ppm)<extra></extra>",
    ))
    fig.add_trace(go.Scatter(
        x=present["run_id"], y=log_rank,
        mode="lines",
        line=dict(color=C_TREND, width=1, dash="dot"),
        name="-log10(1/rank) right axis",
        yaxis="y2",
        hoverinfo="skip",
    ))
    if not missing.empty:
        fig.add_trace(go.Scatter(
            x=missing["run_id"],
            y=[0] * len(missing),
            mode="markers",
            marker=dict(size=6, color="#d1d5db", symbol="x"),
            name="Missing",
            hovertemplate="%{x}<br>not detected<extra></extra>",
        ))
    layout = base(
        f"Fractional intensity (PG.MaxLFQ)  ·  {n_missing}/{n_total} missing ({miss_pct:.1f}%)", mt=44
    )
    labels_f = [run_label(r) for r in present["run_id"]]
    layout["xaxis"].update(tickangle=-55, tickfont=dict(size=7, family=MONO, color="#9ca3af"),
                           tickmode="array", tickvals=list(present["run_id"]), ticktext=labels_f)
    layout["yaxis"].update(title=dict(text="% of total run PG.MaxLFQ", font=dict(size=10)),
                           range=[0, 5])
    layout["yaxis2"] = dict(
        title=dict(text="-log₁₀(1/rank)", font=dict(size=10, color=C_TREND)),
        overlaying="y", side="right",
        tickfont=dict(size=9, family=MONO, color=C_TREND),
        showgrid=False, zeroline=False,
        range=[5, 0],
    )
    layout["hovermode"] = "closest"
    fig.update_layout(**layout)
    return fig


def _build_peptide_fig(mat, label, n_runs_total):
    if mat.empty or mat is None:
        return go.Figure()
    n_pep_all = len(mat)
    n_runs    = len(mat.columns)
    total_cells   = n_pep_all * n_runs
    present_cells = int(mat.values.sum())
    miss_pct = 100 * (total_cells - present_cells) / total_cells if total_cells else 0
    CLIP     = 100
    mat_plot = mat.iloc[:CLIP]
    n_pep    = len(mat_plot)
    pep_lbl  = f"{n_pep_all}+ (top {CLIP} shown)" if n_pep_all > CLIP else str(n_pep_all)
    runs = list(mat_plot.columns)
    pep_row_counts = mat_plot.sum(axis=1)
    peps = [f"{idx}  {100*(n_runs - int(pep_row_counts[idx]))/n_runs:.1f}% miss"
            for idx in mat_plot.index]
    hover = [[f"{runs[c]}<br>{mat_plot.index[r]}<br>{'detected' if mat_plot.iloc[r,c] else 'not detected'}"
              for c in range(n_runs)] for r in range(n_pep)]
    fig = go.Figure(go.Heatmap(
        z=mat_plot.values.astype(int).tolist(), x=runs, y=peps,
        text=hover, hoverinfo="text",
        colorscale=[[0, "#f3f4f6"], [1, C_BLUE]],
        showscale=False, xgap=1, ygap=1,
    ))
    height = max(300, min(900, 16 * n_pep + 80))
    layout = base(
        f"Peptide presence  ·  {pep_lbl} peptides  ·  {miss_pct:.1f}% missing",
        mt=44
    )
    layout["xaxis"].update(
        tickangle=-55, tickfont=dict(size=7, family=MONO, color="#9ca3af"),
        side="bottom"
    )
    layout["yaxis"].update(
        tickfont=dict(size=8, family=MONO, color="#374151"),
        autorange="reversed",
    )
    layout["hovermode"] = "closest"
    layout["margin"]["b"] = 120
    layout["margin"]["l"] = 220
    fig.update_layout(**layout)
    fig.update_layout(height=height)
    return fig


@callback(Output("profile-lfq",        "figure"),
          Output("profile-genes-lfq",  "figure"),
          Output("profile-frac",       "figure"),
          Output("profile-qval",       "figure"),
          Output("profile-peptides",   "figure"),
          Output("profile-peptide-cnt","figure"),
          Output("profile-proteotypic","figure"),
          Output("profile-precursors", "figure"),
          Output("prec-rt",           "figure"),
          Output("prec-im",           "figure"),
          Output("prec-qty",          "figure"),
          Output("prec-frag",         "figure"),
          Output("profile-missing-badge","children"),
          Output("profile-summary",    "children"),
          Output("profile-summary",    "style"),
          Input("sel-search","data"),
          Input("interval","n_intervals"))
def update_profile(search, _n):
    e   = go.Figure()
    emp = tuple(e for _ in range(12))
    base_style = {"margin":"0 28px 0","padding":"10px 16px",
                  "background":"white","border":"1px solid #e5e7eb",
                  "borderRadius":"8px","fontSize":"11px","fontFamily":MONO,
                  "color":"#374151","lineHeight":"1.8"}
    hide = {**base_style, "display":"none"}
    if not search:
        return *emp, "", None, hide
    mode, term = search.get("mode"), search.get("term", "")
    pep_mode = False
    if   mode == "gene":    df, mat, label = load_gene_profile(term)
    elif mode == "uniprot": df, mat, label = load_uniprot_profile(term)
    elif mode == "peptide": df, mat, label, pep_mode = load_peptide_profile(term)
    else:
        return *emp, "", None, hide
    if df.empty or not df["present"].any():
        return *emp, f'No results for "{term}"', None, hide
    n_total   = len(df)
    n_present = int(df["present"].sum())
    badge = f"{label}  ·  detected in {n_present}/{n_total} runs  ({100*n_present/n_total:.0f}%)"
    gr = _Y_RANGES

    fig_lfq   = _profile_fig(df, "PG.MaxLFQ",            "PG.MaxLFQ",            C_BLUE,   "LFQ",         log_scale=True,  fixed_range=[0, 10])
    fig_glfq  = _profile_fig(df, "Genes.MaxLFQ",          "Genes.MaxLFQ",         C_VIOLET, "Gene LFQ",    log_scale=True,  fixed_range=[0, 10])
    fig_frac  = _build_frac_fig(df, label)
    fig_qval  = _profile_fig(df, "Q-value",               "PG Q-value",           C_AMBER,  "Q-value",     log_scale=False, fixed_range=[0, 1])
    fig_pep   = _build_peptide_fig(mat, label, n_total)
    fig_pcnt  = _profile_fig(df, "Peptides",              "Peptides / protein",   C_BLUE,   "Peptides",    log_scale=False, fixed_range=[0, 100])
    fig_proteo= _profile_fig(df, "Proteotypic peptides",  "Proteotypic peptides", C_VIOLET, "Proteotypic", log_scale=False, fixed_range=[0, 100])
    fig_prec  = _profile_fig(df, "Precursors",            "Precursors / protein", C_GREEN,  "Precursors",  log_scale=False, fixed_range=gr.get("Precursors"))
    protein_group = _protein_group_for_search(mode, term)
    # Peptide searches should show only precursors belonging to that stripped peptide.
    # Gene/UniProt searches still show the resolved protein group's top precursors.
    peptide_filter = term.strip().upper() if mode == "peptide" else None
    prec_long = _load_precursor_long(protein_group, peptide_filter)
    fig_rt    = _precursor_heatmap(prec_long, "RT", "Precursor RT", "Viridis", log10=False)
    fig_im    = _precursor_heatmap(prec_long, "IM", "Precursor IM", "Plasma", log10=False)
    fig_pqty  = _precursor_heatmap(prec_long, "Precursor.Quantity", "Precursor.Quantity", "Blues", log10=True)
    fig_frag  = _precursor_heatmap(prec_long, "Frag.Quantity.Sum", "Frag.Quantity.Sum", "Oranges", log10=True)

    def _sp(lbl, val):
        return html.Span([
            html.Span(f"{lbl}: ", style={"color":"#9ca3af"}),
            html.Span(val, style={"color":"#111827","fontWeight":"600","marginRight":"20px"}),
        ])
    pres = df[df["present"]]
    if pep_mode:
        summ = [
            html.Div(label, style={"fontWeight":"700","color":C_BLUE,
                                   "marginBottom":"6px","fontSize":"12px"}),
            html.Div([
                _sp("Detected", f"{n_present}/{n_total} ({100*n_present/n_total:.1f}%)"),
                _sp("Missing",  f"{n_total-n_present}/{n_total} ({100*(n_total-n_present)/n_total:.1f}%)"),
            ], style={"display":"flex","flexWrap":"wrap"}),
        ]
        return (fig_lfq, fig_glfq, fig_frac, fig_qval, fig_pep, fig_pcnt, fig_proteo, fig_prec,
                fig_rt, fig_im, fig_pqty, fig_frag,
                badge, summ, {**base_style, "display":"block"})

    ranks = pres["intensity_rank"].dropna()
    def _s(v, fmt=",.3g"): return format(float(v), fmt) if pd.notna(v) else "n/a"
    summary_cells = [
        _sp("Detected",     f"{n_present}/{n_total} runs ({100*n_present/n_total:.1f}%)"),
        _sp("Missing",      f"{n_total-n_present}/{n_total} ({100*(n_total-n_present)/n_total:.1f}%)"),
        _sp("Rank med",     _s(ranks.median()) if not ranks.empty else "n/a"),
        _sp("Rank mean",    _s(ranks.mean())   if not ranks.empty else "n/a"),
        _sp("Rank min",     _s(ranks.min())    if not ranks.empty else "n/a"),
        _sp("Rank max",     _s(ranks.max())    if not ranks.empty else "n/a"),
        _sp("Rank mode",    _s(pd.Series(ranks).mode().iloc[0]) if not ranks.empty else "n/a"),
        _sp("Median LFQ",       _s(pres["PG.MaxLFQ"].median())),
        _sp("Median gene LFQ",  _s(pres["Genes.MaxLFQ"].median())),
        _sp("Median Q-value",   _s(pres["Q-value"].median())),
        _sp("Median peptides",  _s(pres["Peptides"].median())),
        _sp("Median proteotypic", _s(pres["Proteotypic peptides"].median())),
        _sp("Median precursors",  _s(pres["Precursors"].median())),
    ]
    summary_content = [
        html.Div(label, style={"fontWeight":"700","color":C_BLUE,
                               "marginBottom":"6px","fontSize":"12px"}),
        html.Div(summary_cells, style={"display":"flex","flexWrap":"wrap"}),
    ]
    return (fig_lfq, fig_glfq, fig_frac, fig_qval, fig_pep, fig_pcnt, fig_proteo, fig_prec,
            fig_rt, fig_im, fig_pqty, fig_frag,
            badge, summary_content, {**base_style, "display":"block"})


if __name__ == "__main__":
    SUM = load_summary()
    print(f"DB   : {DB}")
    print(f"PARQ : {PARQUET_GLOB}")
    print(f"Runs : {len(SUM)}")
    print(f"Rows : {SUM['total'].sum():,}")
    print("Building profile store ...", flush=True)
    _build_profile_store()
    app.run(host='0.0.0.0', debug=False, port=8051)
