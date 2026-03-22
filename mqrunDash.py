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

def load_summary():
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
    dcc.Interval(id="interval", interval=3600*1000, n_intervals=0),
])

# ── callbacks ─────────────────────────────────────────────────────────────────

@callback(Output("cards","children"), Output("header-stats","children"), Input("dd-metric","value"), Input("interval","n_intervals"))
def update_cards(_, _n):
    SUM = load_summary()
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

    short = [re.match(r'^(\d{6,8})', r).group(1)
             if re.match(r'^(\d{6,8})', r) else r[:8]
             for r in df["run_id"]]

    layout = base(mt=52)
    layout["xaxis"].update(tickangle=-55, tickfont=dict(size=8, family=MONO, color="#9ca3af"),
                           tickmode="array", tickvals=list(df["run_id"]), ticktext=short)
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


if __name__ == "__main__":
    SUM = load_summary()
    print(f"DB   : {DB}")
    print(f"Runs : {len(SUM)}")
    print(f"Rows : {SUM['total'].sum():,}")
    app.run(host='0.0.0.0',debug=False, port=805)
