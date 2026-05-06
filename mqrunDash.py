"""
mqrunDash.py  —  MaxQuant QC Dashboard
Run:  python mqrunDash.py [path/to/mqrun.duckdb]
Default DB: L:/promec/TIMSTOF/QC/mqrun.duckdb
Deps: pip install dash plotly duckdb pandas numpy
"""

import sys, re, numpy as np
from datetime import datetime
import duckdb, pandas as pd
import plotly.graph_objects as go
from dash import Dash, dcc, html, Input, Output, callback
from dash.exceptions import PreventUpdate

DB = sys.argv[1] if len(sys.argv) > 1 else "L:/promec/TIMSTOF/QC/mqrun.duckdb"

FONT = "'Inter', 'Helvetica Neue', Arial, sans-serif"
MONO = "'JetBrains Mono', 'Fira Code', 'Courier New', monospace"

C_BLUE   = "#2563eb"
C_RED    = "#dc2626"
C_AMBER  = "#d97706"
C_VIOLET = "#7c3aed"
C_GREY   = "#6b7280"
C_TREND  = "#059669"

FC = {
    "target":                  C_BLUE,
    "Reverse":                 C_RED,
    "Potential contaminant":   C_AMBER,
    "Only identified by site": C_VIOLET,
}

METRICS = {
    "proteins":        ("Proteins identified",     "target"),
    "median_ibaq":     ("Median iBAQ",              "median_ibaq"),
    "total_intensity": ("Total Intensity",          "total_intensity"),
    "median_score":    ("Median Score",             "median_score"),
    "median_seqcov":   ("Median Seq. Coverage [%]", "median_seqcov"),
    "median_peptides": ("Median Peptides/Protein",  "median_peptides"),
}

# ── data ──────────────────────────────────────────────────────────────────────
def parse_date(rid):
    m = re.match(r'^(\d{6,8})_', rid)
    if not m: return None
    s = m.group(1)
    s = s if len(s) == 8 else "20" + s
    try:    return datetime.strptime(s, "%Y%m%d").date()
    except: return None

_SUMMARY_CACHE = None

def load_summary(force=False):
    global _SUMMARY_CACHE
    if _SUMMARY_CACHE is not None and not force:
        return _SUMMARY_CACHE
    con = duckdb.connect(DB, read_only=True)
    q = """
        SELECT run_id,
            COUNT(*)                                                           AS total,
            COUNT(*) FILTER (WHERE "Reverse"                IS NULL
                               AND "Potential contaminant"  IS NULL
                               AND "Only identified by site" IS NULL)          AS target,
            COUNT(*) FILTER (WHERE "Reverse"                = '+')            AS n_rev,
            COUNT(*) FILTER (WHERE "Potential contaminant"  = '+')            AS n_cont,
            COUNT(*) FILTER (WHERE "Only identified by site"= '+')            AS n_site,
            MEDIAN("iBAQ")                                                     AS median_ibaq,
            SUM("Intensity")                                                   AS total_intensity,
            MEDIAN("Score")                                                    AS median_score,
            MEDIAN("Sequence coverage [%]")                                    AS median_seqcov,
            MEDIAN("Peptides")                                                 AS median_peptides
        FROM proteinGroups
        GROUP BY run_id ORDER BY run_id
    """
    df = con.execute(q).df()
    con.close()
    df["date"] = df["run_id"].apply(parse_date)
    _SUMMARY_CACHE = df
    return df

def load_run(run_id):
    con = duckdb.connect(DB, read_only=True)
    df  = con.execute("""
        SELECT "Gene names","Protein names","iBAQ","Score","Peptides",
               "Sequence coverage [%]","Reverse","Potential contaminant",
               "Only identified by site"
        FROM proteinGroups WHERE run_id=?
        ORDER BY "iBAQ" DESC NULLS LAST LIMIT 3000
    """, [run_id]).df()
    con.close()
    return df


# ── In-memory indexes (built once at startup) ─────────────────────────────────
# All searches are exact-match on lowercased keys → O(1) dict lookup.
# Three separate indexes so gene / UniProt / peptide never mix.
#
#   _GENE_IDX    : gene_name.lower()    -> {run_id: row_dict}
#   _UNIPROT_IDX : uniprot_id.lower()   -> {run_id: row_dict}
#   _PEP_IDX     : peptide_seq.upper()  -> {run_id: True}
#   _PEP_GENE_IDX: peptide_seq.upper()  -> set of canonical gene_names (display)
#   _PEP_STORE   : gene_name.lower()    -> {run_id: set(peptide_seqs)}
#   _RUNS_ORDERED: sorted list of all run_ids

_GENE_IDX     = {}
_UNIPROT_IDX  = {}
_PEP_IDX      = {}
_PEP_GENE_IDX = {}
_PEP_STORE    = {}
_RUNS_ORDERED = []
_PROFILE_LOADED = False

# Summary tables (built at same time, used for top-N panels)
_TOP_GENES    = []   # list of dicts: gene, n_runs, med_rank, miss_pct
_TOP_UNIPROT  = []
_TOP_PEPTIDES = []   # sorted by fewest missing


def _build_profile_store():
    """One DB query, one Python pass. Builds all indexes."""
    global _GENE_IDX, _UNIPROT_IDX, _PEP_IDX, _PEP_GENE_IDX, _PEP_STORE
    global _RUNS_ORDERED, _PROFILE_LOADED
    global _TOP_GENES, _TOP_UNIPROT, _TOP_PEPTIDES

    con = duckdb.connect(DB, read_only=True)
    _RUNS_ORDERED = con.execute(
        'SELECT DISTINCT run_id FROM proteinGroups ORDER BY run_id'
    ).df()['run_id'].tolist()
    n_runs = len(_RUNS_ORDERED)

    raw = con.execute("""
        WITH totals AS (
            SELECT run_id,
                   SUM("Intensity") FILTER (
                       WHERE "Reverse" IS NULL AND "Potential contaminant" IS NULL
                         AND "Only identified by site" IS NULL AND "Intensity" > 0
                   ) AS sum_intensity
            FROM proteinGroups GROUP BY run_id
        )
        SELECT p.run_id,
               COALESCE(p."Protein IDs",       '')  AS protein_ids,
               COALESCE(p."Gene names",        '')  AS gene_names,
               COALESCE(p."Protein names",     '')  AS protein_names,
               COALESCE(p."Peptide sequences", '')  AS pep_seqs,
               p."Intensity", p."iBAQ", p."Score",
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
    """).df()
    con.close()

    gene_idx    = {}
    uniprot_idx = {}
    pep_idx     = {}
    pep_gene    = {}
    pep_str     = {}

    # accumulators for summary tables
    # Each dict maps key -> {name, ranks: list, seen_runs: set}
    # seen_runs prevents duplicate rank entries when a gene appears in
    # multiple protein groups within the same run.
    gene_runs  = {}   # gene_lower  -> {name, ranks, seen_runs, uniprots}
    uprot_runs = {}   # uniprot_lower -> {name, gene, ranks, seen_runs}
    # pep_runs is derived from _PEP_IDX after the loop (counts distinct runs)

    for _, row in raw.iterrows():
        run  = row['run_id']
        rd   = {
            'gene_names':    row['gene_names'],
            'protein_names': row['protein_names'],
            'protein_ids':   row['protein_ids'],
            'Intensity':     row['Intensity'],
            'iBAQ':          row['iBAQ'],
            'Score':         row['Score'],
            'frac_intensity':row['frac_intensity'],
            'intensity_rank':row['intensity_rank'],
            'sum_intensity': row['sum_intensity'],
        }

        # Gene names (semicolon-separated)
        genes = [g.strip() for g in str(row['gene_names']).split(';') if g.strip()]
        for g in genes:
            k = g.lower()
            gene_idx.setdefault(k, {})[run] = rd
            entry = gene_runs.setdefault(k, {'name': g, 'ranks': [], 'seen_runs': set(), 'uniprots': set()})
            if run not in entry['seen_runs']:   # one rank entry per run
                entry['seen_runs'].add(run)
                if pd.notna(row['intensity_rank']):
                    entry['ranks'].append(row['intensity_rank'])
            entry['uniprots'].update(u.strip() for u in str(row['protein_ids']).split(';') if u.strip())

        # UniProt IDs (semicolon-separated)
        uniprots = [u.strip() for u in str(row['protein_ids']).split(';') if u.strip()]
        for u in uniprots:
            k = u.lower()
            uniprot_idx.setdefault(k, {})[run] = rd
            entry = uprot_runs.setdefault(k, {'name': u, 'gene': row['gene_names'], 'ranks': [], 'seen_runs': set()})
            if run not in entry['seen_runs']:
                entry['seen_runs'].add(run)
                if pd.notna(row['intensity_rank']):
                    entry['ranks'].append(row['intensity_rank'])

        # Peptide sequences
        seqs = {s.strip().upper() for s in str(row['pep_seqs']).split(';') if s.strip()}
        for seq in seqs:
            pep_idx.setdefault(seq, {})[run] = True   # run_id -> True
            for g in genes:
                pep_gene.setdefault(seq, set()).add(g)
                pep_str.setdefault(g.lower(), {}).setdefault(run, set()).add(seq)

    _GENE_IDX     = gene_idx
    _UNIPROT_IDX  = uniprot_idx
    _PEP_IDX      = pep_idx
    _PEP_GENE_IDX = pep_gene
    _PEP_STORE    = pep_str
    _PROFILE_LOADED = True

    # Build combined gene+uniprot summary table
    # n_det = distinct runs from seen_runs set (not ranks list length)
    combined = []
    for k, v in gene_runs.items():
        n_det = len(v['seen_runs'])
        miss  = 100.0 * (n_runs - n_det) / n_runs if n_runs else 0
        ranks = v['ranks']
        med_r = float(np.median(ranks)) if ranks else float('inf')
        uids  = sorted(v['uniprots'])[:4]   # up to 4 UniProt IDs
        combined.append({'gene': v['name'], 'uniprots': uids,
                         'n_runs': n_det, 'miss_pct': miss, 'med_rank': med_r})
    # Sort by median rank (lower = more abundant = better), then miss_pct
    _TOP_GENES   = sorted(combined, key=lambda x: (x['med_rank'], x['miss_pct']))[:50]
    _TOP_UNIPROT = []   # no longer used separately

    # Peptide summary: count distinct run_ids per peptide.
    # Intersect with valid_runs to guard against any stray keys.
    valid_runs = set(_RUNS_ORDERED)
    pep_summary = []
    for seq, run_dict in pep_idx.items():
        n_det = len(set(run_dict.keys()) & valid_runs)
        miss  = 100.0 * (n_runs - n_det) / n_runs if n_runs else 0
        genes_str = ', '.join(sorted(pep_gene.get(seq, set()))[:3])
        pep_summary.append({'peptide': seq, 'n_runs': n_det,
                            'miss_pct': miss, 'genes': genes_str})
    _TOP_PEPTIDES = sorted(pep_summary, key=lambda x: x['miss_pct'])[:50]

    print(f"Store: {len(gene_idx):,} genes  {len(uniprot_idx):,} UniProts  "
          f"{len(pep_idx):,} peptides  {n_runs} runs")


def _runs_to_df(idx_data):
    """Convert {run_id: row_dict} to a left-joined profile DataFrame."""
    rows = []
    for run_id in _RUNS_ORDERED:
        if run_id in idx_data:
            d = dict(idx_data[run_id])
            d['run_id'] = run_id
            d['present'] = True
        else:
            d = {'run_id': run_id, 'present': False,
                 'Intensity': None, 'iBAQ': None, 'Score': None,
                 'frac_intensity': None, 'intensity_rank': None, 'sum_intensity': None}
        rows.append(d)
    return pd.DataFrame(rows)


def _pep_matrix(gene_key):
    """Build peptide×run bool matrix from _PEP_STORE for a gene key."""
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
    for r in _RUNS_ORDERED:
        if r not in mat.columns:
            mat[r] = False
    mat = mat[_RUNS_ORDERED]
    return mat.loc[mat.sum(axis=1).sort_values(ascending=False).index]


def load_gene_profile(gene):
    """Exact case-insensitive gene name lookup. Returns (profile_df, mat_df, label)."""
    if not _PROFILE_LOADED:
        _build_profile_store()
    key = gene.strip().lower()
    if key not in _GENE_IDX:
        return pd.DataFrame(), pd.DataFrame(), gene
    label = _GENE_IDX[key][next(iter(_GENE_IDX[key]))]['gene_names']
    return _runs_to_df(_GENE_IDX[key]), _pep_matrix(key), label


def load_uniprot_profile(uid):
    """Exact case-insensitive UniProt ID lookup. Returns (profile_df, mat_df, label)."""
    if not _PROFILE_LOADED:
        _build_profile_store()
    key = uid.strip().lower()
    if key not in _UNIPROT_IDX:
        return pd.DataFrame(), pd.DataFrame(), uid
    d0  = _UNIPROT_IDX[key][next(iter(_UNIPROT_IDX[key]))]
    label = f"{d0['protein_ids']} ({d0['gene_names']})"
    # pep matrix via first gene
    g = d0['gene_names'].split(';')[0].strip().lower()
    return _runs_to_df(_UNIPROT_IDX[key]), _pep_matrix(g), label


def load_peptide_profile(seq):
    """Exact peptide sequence lookup. Returns (profile_df, mat_df, label)."""
    if not _PROFILE_LOADED:
        _build_profile_store()
    key = seq.strip().upper()
    if key not in _PEP_IDX:
        return pd.DataFrame(), pd.DataFrame(), seq
    genes = sorted(_PEP_GENE_IDX.get(key, set()))
    label = f"{key}  [{', '.join(genes[:3])}]"
    # merge protein profiles for all genes carrying this peptide
    merged = {}
    for g in genes:
        for run_id, rd in _GENE_IDX.get(g.lower(), {}).items():
            if run_id not in merged or (
                rd['Intensity'] and
                (not merged[run_id]['Intensity'] or rd['Intensity'] > merged[run_id]['Intensity'])
            ):
                merged[run_id] = rd
    profile = _runs_to_df(merged)
    # single-row matrix: just this peptide
    presence = {r: True for r in _PEP_IDX[key]}
    mat = pd.DataFrame(
        [{r: (r in presence) for r in _RUNS_ORDERED}], index=[key])
    mat.columns.name = 'run_id'
    return profile, mat, label



# ── plotly base (transparent = follows page bg) ───────────────────────────────
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

# ── CSS ───────────────────────────────────────────────────────────────────────
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

/* Dash dropdown */
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

/* Dark mode */
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

# ── app ───────────────────────────────────────────────────────────────────────
app = Dash(__name__, title="MQ QC")
app.index_string = app.index_string.replace("</head>", CSS + "</head>")

def card(label, val, color="#111827"):
    return html.Div([
        html.Div(label, className="qc-card-label"),
        html.Div(val,   className="qc-card-value", style={"color": color}),
    ], className="qc-card")

_chk = {"marginRight":"18px", "fontSize":"13px", "cursor":"pointer", "color":"#374151"}

app.layout = html.Div(style={"minHeight":"100vh"}, children=[

    html.Div(className="qc-header", children=[
        html.Span("PROMEC · MaxQuant QC",
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
                value="proteins", clearable=False, style={"width":"220px"}),
        ]),
        html.Div([
            html.Div("Filter layers", className="qc-ctrl-label"),
            dcc.Checklist(id="chk-filters",
                options=[{"label":"  Reverse",    "value":"Reverse"},
                         {"label":"  Contaminant","value":"Potential contaminant"},
                         {"label":"  Site only",  "value":"Only identified by site"}],
                value=["Reverse","Potential contaminant","Only identified by site"],
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
        dcc.Graph(id="breakdown",  config={"displayModeBar":False}, style={"flex":"1","height":"270px"}),
        dcc.Graph(id="ibaq-hist",  config={"displayModeBar":False}, style={"flex":"1","height":"270px"}),
        dcc.Graph(id="score-hist", config={"displayModeBar":False}, style={"flex":"1","height":"270px"}),
    ]),

    dcc.Store(id="sel-run"),
    dcc.Store(id="sel-search"),   # {"mode": gene|uniprot|peptide, "term": str}
    dcc.Interval(id="interval", interval=3600*1000, n_intervals=0),

    html.Hr(style={"border":"none","borderTop":"1px solid #e5e7eb","margin":"8px 28px 0"}),

    html.Div(style={"padding":"12px 28px 0","display":"flex","gap":"16px","alignItems":"flex-start"}, children=[
        html.Div([
            html.Div("Gene [UniProt IDs]  sorted by median rank", className="qc-ctrl-label", style={"marginBottom":"6px"}),
            html.Div(id="tbl-genes", style={"fontSize":"11px","fontFamily":MONO,"lineHeight":"1.7","color":"#374151"}),
        ], style={"flex":"2","background":"white","border":"1px solid #e5e7eb","borderRadius":"8px","padding":"12px 16px"}),
        html.Div([
            html.Div("Most consistent peptides  sorted by fewest missing", className="qc-ctrl-label", style={"marginBottom":"6px"}),
            html.Div(id="tbl-peptides",style={"fontSize":"11px","fontFamily":MONO,"lineHeight":"1.7","color":"#374151"}),
        ], style={"flex":"1","background":"white","border":"1px solid #e5e7eb","borderRadius":"8px","padding":"12px 16px"}),
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

    html.Div(id="profile-section", className="qc-detail", style={"paddingTop":"12px"}, children=[
        dcc.Graph(id="profile-intensity", config={"displayModeBar":False}, style={"flex":"1","height":"270px"}),
        dcc.Graph(id="profile-ibaq",      config={"displayModeBar":False}, style={"flex":"1","height":"270px"}),
        dcc.Graph(id="profile-score",     config={"displayModeBar":False}, style={"flex":"1","height":"270px"}),
        dcc.Graph(id="profile-frac",      config={"displayModeBar":False}, style={"flex":"1","height":"270px"}),
    ]),

    html.Div(className="qc-detail", style={"padding":"0 28px 32px"}, children=[
        dcc.Graph(id="profile-peptides", config={"displayModeBar":False}, style={"width":"100%","height":"340px"}),
    ]),
])

# ── callbacks ─────────────────────────────────────────────────────────────────

@callback(Output("cards","children"), Output("header-stats","children"), Input("dd-metric","value"), Input("interval","n_intervals"))
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
        fmap  = {"Reverse":"n_rev","Potential contaminant":"n_cont","Only identified by site":"n_site"}
        fname = {"Reverse":"Reverse","Potential contaminant":"Contaminant","Only identified by site":"Site only"}
        for fc in ["Reverse","Potential contaminant","Only identified by site"]:
            if active and fc in active:
                fig.add_trace(go.Bar(x=x, y=df[fmap[fc]], name=fname[fc],
                                     marker_color=FC[fc], marker_line_width=0,
                                     hovertemplate=f"%{{x}}<br>{fname[fc]}: %{{y:,}}<extra></extra>"))
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

    layout = base(mt=52)
    layout["xaxis"].update(tickangle=-55, tickfont=dict(size=7, family=MONO, color="#9ca3af"))
    layout["yaxis"]["title"] = dict(text=ytitle, font=dict(size=11))
    layout["bargap"]         = 0.12
    layout["margin"]["b"]    = 80
    fig.update_layout(**layout)
    return fig


@callback(Output("sel-run","data"), Input("trend","clickData"), Input("interval","n_intervals"))
def store_sel(cd, _n):
    if not cd: return load_summary()["run_id"].iloc[-1]
    return cd["points"][0]["x"]


@callback(Output("breakdown","figure"), Input("sel-run","data"))
def update_breakdown(run_id):
    SUM = load_summary()
    row = SUM[SUM["run_id"] == run_id]
    if row.empty: return go.Figure()
    r      = row.iloc[0]
    total  = r["total"]
    cats   = ["Target", "Reverse", "Contaminant", "Site only"]
    vals   = [r["target"], r["n_rev"], r["n_cont"], r["n_site"]]
    colors = [C_BLUE, C_RED, C_AMBER, C_VIOLET]
    pct    = [f"{v:,}  ({100*v/total:.1f}%)" if total else f"{v:,}" for v in vals]
    fig = go.Figure(go.Bar(x=cats, y=vals, marker_color=colors, marker_line_width=0,
                           text=pct, textposition="outside",
                           textfont=dict(size=10, family=MONO, color="#374151"),
                           hovertemplate="%{x}: %{y:,}<extra></extra>"))
    short  = (run_id[:20] + "…") if len(run_id) > 20 else run_id
    layout = base(f"breakdown  ·  {short}", mt=40)
    layout["yaxis"]["title"] = dict(text="Count", font=dict(size=10))
    layout["hovermode"]      = "closest"
    layout["margin"]["t"]    = 40
    fig.update_layout(**layout)
    return fig


@callback(Output("ibaq-hist","figure"), Input("sel-run","data"))
def update_ibaq(run_id):
    df    = load_run(run_id)
    clean = df[df["Reverse"].isna() & df["Potential contaminant"].isna()]
    ibaq  = clean["iBAQ"].dropna()
    ibaq  = ibaq[ibaq > 0]
    if ibaq.empty: return go.Figure()
    log_i = np.log10(ibaq)
    med   = float(log_i.median())
    fig = go.Figure(go.Histogram(x=log_i, nbinsx=50,
                                 marker_color=C_BLUE, marker_line_width=0, opacity=0.7,
                                 hovertemplate="log₁₀(iBAQ) %{x:.2f}<br>n=%{y}<extra></extra>"))
    fig.add_vline(x=med, line_color=C_AMBER, line_dash="dash", line_width=2,
                  annotation_text=f"med {med:.1f}",
                  annotation_font_size=10, annotation_font_color=C_AMBER,
                  annotation_font_family=MONO)
    short  = (run_id[:20] + "…") if len(run_id) > 20 else run_id
    layout = base(f"iBAQ  ·  {short}", mt=40)
    layout["xaxis"]["title"] = dict(text="log₁₀(iBAQ)", font=dict(size=10))
    layout["yaxis"]["title"] = dict(text="Proteins",    font=dict(size=10))
    layout["hovermode"]      = "closest"
    layout["margin"]["t"]    = 40
    fig.update_layout(**layout)
    return fig


@callback(Output("score-hist","figure"), Input("sel-run","data"))
def update_score(run_id):
    df    = load_run(run_id)
    clean = df[df["Reverse"].isna() & df["Potential contaminant"].isna()]
    score = clean["Score"].dropna()
    if score.empty: return go.Figure()
    med = float(score.median())
    fig = go.Figure(go.Histogram(x=score, nbinsx=50,
                                 marker_color=C_VIOLET, marker_line_width=0, opacity=0.7,
                                 hovertemplate="Score %{x:.1f}<br>n=%{y}<extra></extra>"))
    fig.add_vline(x=med, line_color=C_AMBER, line_dash="dash", line_width=2,
                  annotation_text=f"med {med:.0f}",
                  annotation_font_size=10, annotation_font_color=C_AMBER,
                  annotation_font_family=MONO)
    short  = (run_id[:20] + "…") if len(run_id) > 20 else run_id
    layout = base(f"Score  ·  {short}", mt=40)
    layout["xaxis"]["title"] = dict(text="Andromeda Score", font=dict(size=10))
    layout["yaxis"]["title"] = dict(text="Proteins",        font=dict(size=10))
    layout["hovermode"]      = "closest"
    layout["margin"]["t"]    = 40
    fig.update_layout(**layout)
    return fig


@callback(Output("tbl-genes","children"),
          Output("tbl-peptides","children"),
          Input("interval","n_intervals"))
def update_top_tables(_n):
    if not _PROFILE_LOADED:
        return "loading...", "loading..."
    def _gene_rows():
        rows = []
        for r in _TOP_GENES[:20]:
            uid_str = ";".join(r["uniprots"]) if r["uniprots"] else ""
            rank_str = f"{r['med_rank']:,.0f}" if r["med_rank"] < float("inf") else "?"
            rows.append(html.Div([
                html.Span(r["gene"], style={"color":C_BLUE,"fontWeight":"600",
                    "cursor":"pointer","textDecoration":"underline dotted",
                    "marginRight":"4px"},
                    id={"type":"top-gene-link","index":r["gene"]}),
                html.Span(f"[", style={"color":"#9ca3af"}),
                *[html.Span(u, style={"color":C_VIOLET,"cursor":"pointer",
                    "textDecoration":"underline dotted","marginRight":"2px"},
                    id={"type":"top-uprot-link","index":u})
                  for u in r["uniprots"]],
                html.Span(f"]", style={"color":"#9ca3af"}),
                html.Span(
                    f"  {r['n_runs']} runs  miss {r['miss_pct']:.0f}%  rank {rank_str}",
                    style={"color":"#6b7280","marginLeft":"6px"}),
            ]))
        return rows
    def _pep_rows():
        rows = []
        for r in _TOP_PEPTIDES[:20]:
            rows.append(html.Div([
                html.Span(r["peptide"], style={"color":C_AMBER,"fontWeight":"600",
                    "cursor":"pointer","textDecoration":"underline dotted",
                    "marginRight":"6px"},
                    id={"type":"top-pep-link","index":r["peptide"]}),
                html.Span(
                    f"{r['n_runs']} runs  miss {r['miss_pct']:.0f}%  {r['genes'][:24]}",
                    style={"color":"#6b7280"}),
            ]))
        return rows
    return _gene_rows(), _pep_rows()


from dash import MATCH, ALL

# Click handlers: fill text box AND immediately trigger profile update.
# Two outputs per callback: text box (visual feedback) + sel-search (triggers profile).
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

# Typed input: debounced, fires on blur/Enter
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


def _profile_fig(df, col, title_prefix, color, unit_label, log_scale=False):
    """Shared builder for profile scatter plots."""
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

    layout = base(f"{title_prefix}  ·  {n_missing}/{n_total} missing ({miss_pct:.0f}%)", mt=44)
    layout["xaxis"].update(tickangle=-55, tickfont=dict(size=7, family=MONO, color="#9ca3af"))
    layout["yaxis"]["title"] = dict(text=y_lbl, font=dict(size=10))
    layout["hovermode"] = "closest"
    fig.update_layout(**layout)
    return fig



def _build_frac_fig(df, gene):
    """Fractional intensity = protein_Intensity / total_run_Intensity.
    Shows true proportional abundance, comparable across runs.
    Right y-axis shows same value as parts-per-million for readability."""
    present = df[df["present"]].copy()
    missing = df[~df["present"]]
    if present.empty:
        return go.Figure()
    n_total   = len(df)
    n_missing = n_total - int(df["present"].sum())
    miss_pct  = 100 * n_missing / n_total if n_total else 0

    frac = present["frac_intensity"].fillna(0)
    rank = present["intensity_rank"]
    # -log10(1/rank) = log10(rank): rank 1 -> 0 (most abundant), rank 1000 -> 3
    log_rank = np.log10(rank.clip(lower=1))

    fig = go.Figure()
    fig.add_trace(go.Scatter(
        x=present["run_id"], y=frac * 100,
        mode="markers+lines",
        marker=dict(size=5, color=C_BLUE),
        line=dict(color=C_BLUE, width=1.5),
        name="% total intensity",
        customdata=np.stack([rank.values, (frac * 1e6).values], axis=1),
        hovertemplate="%{x}<br>%{y:.4f}% of run intensity<br>rank %{customdata[0]:.0f}  (%{customdata[1]:.1f} ppm)<extra></extra>",
    ))
    # -log10(1/rank) on secondary axis — lower = more abundant
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
        f"Fractional intensity  ·  {n_missing}/{n_total} missing ({miss_pct:.0f}%)", mt=44
    )
    layout["xaxis"].update(tickangle=-55, tickfont=dict(size=7, family=MONO, color="#9ca3af"))
    layout["yaxis"].update(title=dict(text="% of total run intensity", font=dict(size=10)))
    layout["yaxis2"] = dict(
        title=dict(text="-log₁₀(1/rank)", font=dict(size=10, color=C_TREND)),
        overlaying="y", side="right",
        tickfont=dict(size=9, family=MONO, color=C_TREND),
        showgrid=False, zeroline=False,
        autorange="reversed",   # rank 1 (most abundant) at top = low log_rank
    )
    layout["hovermode"] = "closest"
    fig.update_layout(**layout)
    return fig


def _build_peptide_fig(mat, gene, n_runs_total):
    """Peptide presence heatmap: rows=unique peptides (sorted by detection frequency),
    cols=runs (chronological). Blue=detected, light grey=not detected.
    Title shows total unique peptides and overall missing %.
    mat is pre-computed by load_profile — no extra DB call needed."""
    if mat.empty or mat is None:
        return go.Figure()
    n_pep   = len(mat)
    n_runs  = len(mat.columns)
    # Overall missing fraction across the whole matrix
    total_cells  = n_pep * n_runs
    present_cells = int(mat.values.sum())
    miss_pct = 100 * (total_cells - present_cells) / total_cells if total_cells else 0
    # Build z matrix (1=present, 0=absent), y=peptide labels, x=run labels
    z    = mat.values.astype(int).tolist()
    runs = list(mat.columns)
    peps = list(mat.index)
    # Hover: show run_id and peptide
    hover = [[f"{runs[c]}<br>{peps[r]}<br>{'detected' if mat.iloc[r,c] else 'not detected'}"
              for c in range(n_runs)] for r in range(n_pep)]
    fig = go.Figure(go.Heatmap(
        z=z, x=runs, y=peps,
        text=hover, hoverinfo="text",
        colorscale=[[0, "#f3f4f6"], [1, C_BLUE]],
        showscale=False,
        xgap=1, ygap=1,
    ))
    height = max(300, min(900, 16 * n_pep + 80))
    layout = base(
        f"Peptide presence  ·  {n_pep} unique peptides  ·  "
        f"{miss_pct:.0f}% missing across {n_runs} runs",
        mt=44
    )
    layout["xaxis"].update(
        tickangle=-55, tickfont=dict(size=7, family=MONO, color="#9ca3af"),
        side="bottom"
    )
    layout["yaxis"].update(
        tickfont=dict(size=8, family=MONO, color="#374151"),
        autorange="reversed",   # most-detected peptide at top
    )
    layout["hovermode"] = "closest"
    layout["margin"]["b"] = 120
    layout["margin"]["l"] = 160   # room for peptide sequence labels
    fig.update_layout(**layout)
    fig.update_layout(height=height)
    return fig

@callback(Output("profile-intensity","figure"),
          Output("profile-ibaq",     "figure"),
          Output("profile-score",    "figure"),
          Output("profile-frac",     "figure"),
          Output("profile-peptides", "figure"),
          Output("profile-missing-badge","children"),
          Input("sel-search","data"),
          Input("interval","n_intervals"))
def update_profile(search, _n):
    empty = go.Figure()
    if not search:
        return empty, empty, empty, empty, empty, ""
    mode, term = search.get("mode"), search.get("term", "")
    if   mode == "gene":    df, mat, label = load_gene_profile(term)
    elif mode == "uniprot": df, mat, label = load_uniprot_profile(term)
    elif mode == "peptide": df, mat, label = load_peptide_profile(term)
    else:
        return empty, empty, empty, empty, empty, ""
    if df.empty or not df["present"].any():
        return empty, empty, empty, empty, empty, f'No results for "{term}"'
    n_total   = len(df)
    n_present = int(df["present"].sum())
    badge = f"{label}  ·  detected in {n_present}/{n_total} runs  ({100*n_present/n_total:.0f}%)"
    fig_int  = _profile_fig(df, "Intensity", "Intensity",   C_BLUE,   "Intensity",      log_scale=True)
    fig_ibaq = _profile_fig(df, "iBAQ",      "iBAQ",        C_VIOLET, "iBAQ",           log_scale=True)
    fig_scr  = _profile_fig(df, "Score",     "Score",       C_AMBER,  "Andromeda Score", log_scale=False)
    fig_frac = _build_frac_fig(df, label)
    fig_pep  = _build_peptide_fig(mat, label, n_total)
    return fig_int, fig_ibaq, fig_scr, fig_frac, fig_pep, badge


if __name__ == "__main__":
    SUM = load_summary()
    print(f"DB   : {DB}")
    print(f"Runs : {len(SUM)}")
    print(f"Rows : {SUM['total'].sum():,}")
    print("Building profile store ...", flush=True)
    _build_profile_store()
    app.run(host='0.0.0.0',debug=False, port=8050)
