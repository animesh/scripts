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

# ── palette ───────────────────────────────────────────────────────────────────
BG     = "#08090a"
SURF   = "#111318"
BORDER = "#1e2229"
TEXT   = "#dce3ed"
MUTED  = "#5a6478"
CYAN   = "#4dd9c0"
RED    = "#e05a5a"
AMBER  = "#e8a838"
VIOLET = "#9b72f2"
GRID   = "#161a20"
FONT   = "'IBM Plex Mono', 'Courier New', monospace"

FC = {"target": CYAN, "Reverse": RED,
      "Potential contaminant": AMBER, "Only identified by site": VIOLET}

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
    df  = con.execute("""
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
    """).df()
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

SUM = load_summary()

# ── plotly helpers ────────────────────────────────────────────────────────────
def base(title="", tb=44):
    return dict(
        title       = dict(text=title, font=dict(size=11, color=MUTED, family=FONT),
                           x=0.0, xanchor="left", pad=dict(l=2)),
        paper_bgcolor=BG, plot_bgcolor=SURF,
        font        = dict(family=FONT, color=TEXT, size=10),
        margin      = dict(l=54, r=16, t=tb, b=44),
        xaxis       = dict(gridcolor=GRID, linecolor=BORDER, tickfont=dict(size=9)),
        yaxis       = dict(gridcolor=GRID, linecolor=BORDER, tickfont=dict(size=9)),
        legend      = dict(bgcolor="rgba(0,0,0,0)", font=dict(size=10),
                           orientation="h", yanchor="bottom", y=1.01, xanchor="left", x=0),
        hoverlabel  = dict(bgcolor="#1a1f28", bordercolor=BORDER,
                           font=dict(family=FONT, size=11)),
        hovermode   = "x unified",
    )

def card(label, val, color=CYAN):
    return html.Div([
        html.Div(label, style={"fontSize":"9px","color":MUTED,
                               "letterSpacing":"0.12em","textTransform":"uppercase"}),
        html.Div(val,   style={"fontSize":"19px","fontWeight":"600",
                               "color":color,"marginTop":"4px"}),
    ], style={"background":SURF,"border":f"1px solid {BORDER}","borderRadius":"3px",
              "padding":"11px 15px","minWidth":"115px"})

# ── app ───────────────────────────────────────────────────────────────────────
app = Dash(__name__, title="MQ QC")
app.index_string = app.index_string.replace("</head>",
    '<link rel="preconnect" href="https://fonts.googleapis.com">'
    '<link href="https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;600&display=swap" rel="stylesheet">'
    "</head>")

_ctrl_label = {"fontSize":"9px","color":MUTED,"letterSpacing":"0.12em","marginBottom":"5px"}
_chk_label  = {"marginRight":"20px","fontSize":"12px","color":TEXT,"cursor":"pointer"}

app.layout = html.Div(style={"background":BG,"minHeight":"100vh","color":TEXT,"fontFamily":FONT}, children=[

    # ── header ────────────────────────────────────────────────────────────
    html.Div(style={"padding":"14px 24px","borderBottom":f"1px solid {BORDER}",
                    "display":"flex","alignItems":"baseline","gap":"20px"}, children=[
        html.Span("PROMEC · MaxQuant QC",
                  style={"fontSize":"14px","fontWeight":"600","letterSpacing":"0.06em"}),
        html.Span(f"{len(SUM)} runs  ·  {SUM['total'].sum():,} protein groups",
                  style={"fontSize":"11px","color":MUTED}),
    ]),

    # ── controls ──────────────────────────────────────────────────────────
    html.Div(style={"padding":"12px 24px","borderBottom":f"1px solid {BORDER}",
                    "display":"flex","gap":"36px","alignItems":"flex-end","flexWrap":"wrap"}, children=[
        html.Div([
            html.Div("METRIC", style=_ctrl_label),
            dcc.Dropdown(id="dd-metric",
                options=[{"label":v[0],"value":k} for k,v in METRICS.items()],
                value="proteins", clearable=False,
                style={"width":"215px","fontSize":"12px"}),
        ]),
        html.Div([
            html.Div("FILTER LAYERS", style=_ctrl_label),
            dcc.Checklist(id="chk-filters",
                options=[{"label":"  Reverse",    "value":"Reverse"},
                         {"label":"  Contaminant","value":"Potential contaminant"},
                         {"label":"  Site only",  "value":"Only identified by site"}],
                value=["Reverse","Potential contaminant","Only identified by site"],
                inline=True,
                inputStyle={"marginRight":"4px"},
                labelStyle=_chk_label),
        ]),
        html.Div([
            html.Div("ROLLING AVG", style=_ctrl_label),
            dcc.Checklist(id="chk-trend",
                options=[{"label":"  Show","value":"y"}],
                value=["y"], inline=True,
                inputStyle={"marginRight":"4px"},
                labelStyle=_chk_label),
        ]),
    ]),

    # ── stat cards ────────────────────────────────────────────────────────
    html.Div(id="cards", style={"display":"flex","gap":"10px","padding":"14px 24px","flexWrap":"wrap"}),

    # ── main trend chart ──────────────────────────────────────────────────
    dcc.Graph(id="trend", config={"displayModeBar":False},
              style={"height":"370px","margin":"0 24px 2px"}),

    html.Div("↑  click any bar or point to inspect that run",
             style={"fontSize":"10px","color":MUTED,"padding":"2px 26px 10px"}),

    # ── detail row ────────────────────────────────────────────────────────
    html.Div(style={"display":"flex","gap":"10px","padding":"0 24px 28px"}, children=[
        dcc.Graph(id="breakdown",  config={"displayModeBar":False}, style={"flex":"1","height":"250px"}),
        dcc.Graph(id="ibaq-hist",  config={"displayModeBar":False}, style={"flex":"1","height":"250px"}),
        dcc.Graph(id="score-hist", config={"displayModeBar":False}, style={"flex":"1","height":"250px"}),
    ]),

    dcc.Store(id="sel-run"),
])

# ── callbacks ─────────────────────────────────────────────────────────────────

@callback(Output("cards","children"), Input("dd-metric","value"))
def update_cards(_):
    return [
        card("Runs ingested",  str(len(SUM))),
        card("Avg target/run", f"{SUM['target'].mean():,.0f}"),
        card("Best run",       f"{SUM['target'].max():,}",  CYAN),
        card("Worst run",      f"{SUM['target'].min():,}",  RED),
        card("Total groups",   f"{SUM['total'].sum():,}",   MUTED),
    ]


@callback(Output("trend","figure"),
          Input("dd-metric","value"),
          Input("chk-filters","value"),
          Input("chk-trend","value"))
def update_trend(metric, active, trend_on):
    df  = SUM.copy()
    x   = df["run_id"]
    fig = go.Figure()

    if metric == "proteins":
        fig.add_trace(go.Bar(x=x, y=df["target"], name="Target",
                             marker_color=CYAN, marker_line_width=0,
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
                                 line=dict(color=CYAN, width=1.5),
                                 marker=dict(size=4, color=CYAN),
                                 name=label,
                                 hovertemplate="%{x}<br>" + label + ": %{y:,.3g}<extra></extra>"))
        ytitle = label

    if trend_on and "y" in trend_on and len(df) >= 3:
        w    = max(3, len(df) // 8)
        roll = df["target"].rolling(w, center=True, min_periods=1).mean()
        fig.add_trace(go.Scatter(x=x, y=roll, mode="lines",
                                 name=f"{w}-run rolling avg",
                                 line=dict(color="#ffffff", width=1.5, dash="dot"),
                                 hoverinfo="skip"))

    layout = base(tb=48)
    layout["xaxis"].update(tickangle=-55, tickfont=dict(size=8))
    layout["yaxis"]["title"] = dict(text=ytitle, font=dict(size=10))
    layout["bargap"] = 0.1
    fig.update_layout(**layout)
    return fig


@callback(Output("sel-run","data"), Input("trend","clickData"))
def store_sel(cd):
    if not cd: return SUM["run_id"].iloc[-1]
    return cd["points"][0]["x"]


@callback(Output("breakdown","figure"), Input("sel-run","data"))
def update_breakdown(run_id):
    row = SUM[SUM["run_id"] == run_id]
    if row.empty: return go.Figure()
    r      = row.iloc[0]
    total  = r["total"]
    cats   = ["Target", "Reverse", "Contaminant", "Site only"]
    vals   = [r["target"], r["n_rev"], r["n_cont"], r["n_site"]]
    colors = [CYAN, RED, AMBER, VIOLET]
    pct    = [f"{v:,}  ({100*v/total:.1f}%)" if total else f"{v:,}" for v in vals]
    fig = go.Figure(go.Bar(x=cats, y=vals, marker_color=colors, marker_line_width=0,
                           text=pct, textposition="outside",
                           textfont=dict(size=9, color=TEXT),
                           hovertemplate="%{x}: %{y:,}<extra></extra>"))
    short  = (run_id[:20] + "…") if len(run_id) > 20 else run_id
    layout = base(f"breakdown  ·  {short}", tb=50)
    layout["yaxis"]["title"]  = dict(text="Count", font=dict(size=9))
    layout["hovermode"]       = "closest"
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
                                 marker_color=CYAN, marker_line_width=0, opacity=0.85,
                                 hovertemplate="log₁₀(iBAQ) %{x:.2f}<br>n=%{y}<extra></extra>"))
    fig.add_vline(x=med, line_color=AMBER, line_dash="dot", line_width=1.5,
                  annotation_text=f"med {med:.1f}",
                  annotation_font_size=9, annotation_font_color=AMBER)
    short  = (run_id[:20] + "…") if len(run_id) > 20 else run_id
    layout = base(f"iBAQ  ·  {short}", tb=50)
    layout["xaxis"]["title"] = dict(text="log₁₀(iBAQ)", font=dict(size=9))
    layout["yaxis"]["title"] = dict(text="Proteins",    font=dict(size=9))
    layout["hovermode"]      = "closest"
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
                                 marker_color=VIOLET, marker_line_width=0, opacity=0.85,
                                 hovertemplate="Score %{x:.1f}<br>n=%{y}<extra></extra>"))
    fig.add_vline(x=med, line_color=AMBER, line_dash="dot", line_width=1.5,
                  annotation_text=f"med {med:.0f}",
                  annotation_font_size=9, annotation_font_color=AMBER)
    short  = (run_id[:20] + "…") if len(run_id) > 20 else run_id
    layout = base(f"Andromeda score  ·  {short}", tb=50)
    layout["xaxis"]["title"] = dict(text="Score",    font=dict(size=9))
    layout["yaxis"]["title"] = dict(text="Proteins", font=dict(size=9))
    layout["hovermode"]      = "closest"
    fig.update_layout(**layout)
    return fig


if __name__ == "__main__":
    print(f"DB   : {DB}")
    print(f"Runs : {len(SUM)}")
    print(f"Rows : {SUM['total'].sum():,}")
    print("Open : http://localhost:8050")
    app.run(debug=False, port=8050)
