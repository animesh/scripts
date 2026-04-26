#python plotPSM_dash.py "L:\promec\HF\Lars\2026\260330_Essa\combined\txt\msms.txt"
#Raw precursor m/z = m/z + isotope_index * (1.003355 / charge)

import argparse, re, sys
from pathlib import Path
import numpy as np
import pandas as pd
import plotly.graph_objects as go
from dash import Dash, dcc, html, Input, Output, callback

# ── Constants ─────────────────────────────────────────────────────────────────
ION_COLORS = {
    'y':     '#2166ac',
    'b':     '#d6604d',
    'a':     '#f4a582',
    'c':     '#4dac26',
    'z':     '#91cf60',
    'IM':    '#7b3294',
    'other': '#888888',
    'grey':  '#cccccc',
}

# ── Helpers ───────────────────────────────────────────────────────────────────
def sanitize(seq: str) -> str:
    return ''.join(re.findall(r'[A-Z]', str(seq).upper()))

def parse_semi(s) -> np.ndarray:
    if pd.isna(s) or str(s).strip() == '':
        return np.array([], dtype=float)
    parts = [x for x in str(s).split(';') if x.strip() not in ('', 'nan')]
    try:
        return np.array([float(x) for x in parts], dtype=float)
    except Exception:
        return np.array([], dtype=float)

def ion_type(label: str) -> str:
    for t in ('IM', 'y', 'b', 'a', 'c', 'z'):
        if label.startswith(t):
            return t
    return 'other'

def format_label(raw: str, seq: str, mz: float) -> str:
    """ion(charge+) fragment mz  — e.g.  y11(2+) PVVALAGNVIR 1108.7"""
    n = len(seq)
    has_charge = bool(re.search(r'\(\d+\+\)', raw))
    suffix = '' if has_charge else '(1+)'
    base = re.sub(r'\(\d+\+\)', '', raw)
    core = re.split(r'[-]', base)[0]
    m = re.match(r'^([aby])(\d+)$', core)
    if not m:
        return f"{raw}{suffix} {mz:.1f}"
    t, num = m.group(1), min(int(m.group(2)), n)
    frag = seq[:num] if t in ('b', 'a') else seq[n - num:]
    return f"{raw}{suffix} {frag} {mz:.1f}"

def raw_precursor_mz(row) -> float:
    try:
        return float(row['m/z']) + int(row.get('Isotope index', 0)) * (1.003355 / int(float(row.get('Charge', 1))))
    except Exception:
        return float(row.get('m/z', 0))

# ── Data loading ──────────────────────────────────────────────────────────────
def load_msms(path: Path) -> pd.DataFrame:
    df = pd.read_csv(path, sep='\t', low_memory=False)
    df = df[df['Sequence'].notna() & (df['Sequence'].astype(str).str.strip() != '')]
    df['_seq'] = df['Sequence'].apply(sanitize)
    return df

def protein_list(df: pd.DataFrame) -> list[str]:
    prots = set()
    for val in df['Proteins'].dropna():
        for p in str(val).split(';'):
            p = p.strip()
            if p:
                prots.add(p)
    return sorted(prots)

def peptide_list(df: pd.DataFrame, protein: str) -> list[str]:
    mask = df['Proteins'].astype(str).str.contains(re.escape(protein), case=False, na=False)
    seqs = df[mask]['_seq'].unique().tolist()
    return sorted(seqs)

def best_row(df: pd.DataFrame, protein: str, peptide: str) -> pd.Series | None:
    mask = (
        df['Proteins'].astype(str).str.contains(re.escape(protein), case=False, na=False) &
        (df['_seq'] == sanitize(peptide))
    )
    sub = df[mask]
    if sub.empty:
        return None
    return sub.loc[sub['Score'].astype(float).idxmax()]

# ── Plotly figure builder ─────────────────────────────────────────────────────
def build_figure(row: pd.Series, seq: str,
                 show_types: list[str], show_labels: bool, show_unmatched: bool) -> go.Figure:

    full_mz  = parse_semi(row.get('Masses2'))
    full_int = parse_semi(row.get('Intensities2'))
    ann_mz   = parse_semi(row.get('Masses'))
    ann_int  = parse_semi(row.get('Intensities'))
    raw_lbls = [x for x in str(row.get('Matches', '')).split(';')
                if x.strip() not in ('', 'nan')]
    if len(raw_lbls) != len(ann_mz):
        raw_lbls = [''] * len(ann_mz)

    if not full_int.size:
        return go.Figure()

    max_int  = full_int.max()
    full_pct = full_int / max_int * 100.0
    ann_pct  = ann_int  / max_int * 100.0

    ann_set = set(ann_mz.tolist())

    fig = go.Figure()

    # ── Unannotated peaks ─────────────────────────────────────────────────────
    if show_unmatched:
        x_grey, y_grey = [], []
        for mz, pct in zip(full_mz, full_pct):
            if mz not in ann_set:
                x_grey += [mz, mz, None]
                y_grey += [0,  pct, None]
        fig.add_trace(go.Scatter(
            x=x_grey, y=y_grey,
            mode='lines', line=dict(color=ION_COLORS['grey'], width=0.8),
            name='unmatched', hoverinfo='skip', opacity=0.7,
            legendgroup='unmatched',
        ))

    # ── Annotated peaks, one trace per ion type ───────────────────────────────
    type_data: dict[str, dict] = {}
    for mz, pct, lbl in zip(ann_mz, ann_pct, raw_lbls):
        t = ion_type(lbl)
        if t not in type_data:
            type_data[t] = {'x': [], 'y': [], 'hover': [], 'lbl_x': [], 'lbl_y': [], 'lbl_text': []}
        type_data[t]['x'] += [mz, mz, None]
        type_data[t]['y'] += [0, pct, None]
        type_data[t]['hover'].append(f"{lbl}<br>m/z {mz:.4f}<br>{pct:.1f}%")
        type_data[t]['lbl_x'].append(mz)
        type_data[t]['lbl_y'].append(pct)
        type_data[t]['lbl_text'].append(format_label(lbl, seq, mz) if show_labels else '')

    for t, d in type_data.items():
        color   = ION_COLORS.get(t, ION_COLORS['other'])
        visible = t in show_types

        fig.add_trace(go.Scatter(
            x=d['x'], y=d['y'],
            mode='lines', line=dict(color=color, width=1.2),
            name=t, legendgroup=t,
            visible=visible,
            hoverinfo='skip',
        ))
        # Dot markers at peak tips (every 3rd point = non-None tip)
        tips_x = [d['x'][i] for i in range(1, len(d['x']), 3)]
        tips_y = [d['y'][i] for i in range(1, len(d['y']), 3)]
        hover_text = []
        for mz, pct, lbl in zip(ann_mz, ann_pct, raw_lbls):
            if ion_type(lbl) == t:
                hover_text.append(f"<b>{lbl}</b><br>m/z {mz:.4f}<br>{pct:.1f}% ({pct/100*max_int:.0f})")
        fig.add_trace(go.Scatter(
            x=tips_x, y=tips_y,
            mode='markers+text' if show_labels else 'markers',
            marker=dict(color=color, size=6),
            text=d['lbl_text'],
            textposition='top center',
            textfont=dict(size=9, color=color),
            name=t, legendgroup=t, showlegend=False,
            visible=visible,
            hovertext=hover_text,
            hoverinfo='text',
        ))

    # ── Header annotation ─────────────────────────────────────────────────────
    proteins  = str(row.get('Proteins', ''))
    raw_file  = str(row.get('Raw file', ''))
    scan      = row.get('Scan number', '')
    analyzer  = row.get('Mass analyzer', '')
    frag      = row.get('Fragmentation', '')
    charge    = row.get('Charge', '')
    score     = row.get('Score', '')
    prec_mz   = raw_precursor_mz(row)
    mod_seq   = str(row.get('Modified sequence', seq)) if pd.notna(row.get('Modified sequence')) else seq

    method = '; '.join(filter(None, [str(analyzer), str(frag)]))
    subtitle = f"{raw_file}   Scan {scan}   {method}   z {charge}+   Score {score}   MS/MS m/z {prec_mz:.6f}"

    fig.update_layout(
        title=dict(
            text=f"<b>{proteins}</b><br><span style='font-size:12px;color:#555'>{subtitle}</span>"
                 f"<br><span style='font-size:11px;font-family:monospace;color:#333'>Peptide: {mod_seq}</span>",
            x=0, xanchor='left', font=dict(size=14),
        ),
        xaxis=dict(title='m/z', showgrid=False, zeroline=False, tickfont=dict(size=11)),
        yaxis=dict(title='Relative intensity (%)', range=[0, 115],
                   showgrid=True, gridcolor='#eeeeee', zeroline=True, zerolinecolor='#aaa'),
        yaxis2=dict(
            title='Raw intensity',
            overlaying='y', side='right',
            range=[0, 115],
            tickvals=[0, 20, 40, 60, 80, 100],
            ticktext=[f"{v/100*max_int:.3g}" for v in [0, 20, 40, 60, 80, 100]],
            showgrid=False,
        ),
        legend=dict(orientation='v', x=1.08, y=1, font=dict(size=11)),
        plot_bgcolor='white',
        paper_bgcolor='white',
        margin=dict(l=60, r=140, t=120, b=60),
        hovermode='closest',
        font=dict(family='IBM Plex Mono, monospace', size=11),
    )
    return fig

# ── Dash app ──────────────────────────────────────────────────────────────────
def make_app(df: pd.DataFrame) -> Dash:
    prots = protein_list(df)
    init_prot = prots[0] if prots else ''
    init_peps = peptide_list(df, init_prot)
    init_pep  = init_peps[0] if init_peps else ''

    app = Dash(__name__, title='MS/MS Viewer')

    app.layout = html.Div(style={
        'fontFamily': "'IBM Plex Mono', monospace",
        'background': '#f5f5f2',
        'minHeight': '100vh',
        'display': 'flex',
        'flexDirection': 'column',
    }, children=[

        # ── Top bar ──────────────────────────────────────────────────────────
        html.Div(style={
            'background': '#1a1a2e',
            'color': '#e0e0e0',
            'padding': '12px 24px',
            'display': 'flex',
            'alignItems': 'center',
            'gap': '16px',
        }, children=[
            html.Span("MS/MS", style={'fontSize': '20px', 'fontWeight': '700',
                                       'color': '#e2b96f', 'letterSpacing': '2px'}),
            html.Span("Spectrum Viewer", style={'fontSize': '14px', 'color': '#888', 'letterSpacing': '1px'}),
        ]),

        # ── Main layout ───────────────────────────────────────────────────────
        html.Div(style={'display': 'flex', 'flex': '1', 'gap': '0'}, children=[

            # ── Sidebar ───────────────────────────────────────────────────────
            html.Div(style={
                'width': '260px', 'minWidth': '260px',
                'background': '#1a1a2e',
                'padding': '20px 16px',
                'display': 'flex',
                'flexDirection': 'column',
                'gap': '20px',
                'borderRight': '1px solid #2a2a4a',
            }, children=[

                html.Div([
                    html.Label("PROTEIN", style={'color': '#e2b96f', 'fontSize': '10px',
                                                  'letterSpacing': '2px', 'marginBottom': '6px', 'display': 'block'}),
                    dcc.Dropdown(
                        id='dd-protein',
                        options=[{'label': p, 'value': p} for p in prots],
                        value=init_prot,
                        clearable=False,
                        style={'fontSize': '12px'},
                    ),
                ]),

                html.Div([
                    html.Label("PEPTIDE", style={'color': '#e2b96f', 'fontSize': '10px',
                                                  'letterSpacing': '2px', 'marginBottom': '6px', 'display': 'block'}),
                    dcc.Dropdown(
                        id='dd-peptide',
                        options=[{'label': p, 'value': p} for p in init_peps],
                        value=init_pep,
                        clearable=False,
                        style={'fontSize': '11px'},
                    ),
                ]),

                html.Hr(style={'borderColor': '#2a2a4a', 'margin': '0'}),

                html.Div([
                    html.Label("ION TYPES", style={'color': '#e2b96f', 'fontSize': '10px',
                                                    'letterSpacing': '2px', 'marginBottom': '8px', 'display': 'block'}),
                    dcc.Checklist(
                        id='chk-ions',
                        options=[
                            {'label': html.Span('  y ions', style={'color': ION_COLORS['y']}),    'value': 'y'},
                            {'label': html.Span('  b ions', style={'color': ION_COLORS['b']}),    'value': 'b'},
                            {'label': html.Span('  a ions', style={'color': ION_COLORS['a']}),    'value': 'a'},
                            {'label': html.Span('  c/z ions', style={'color': ION_COLORS['c']}),  'value': 'c'},
                            {'label': html.Span('  immonium', style={'color': ION_COLORS['IM']}), 'value': 'IM'},
                            {'label': html.Span('  internal / other', style={'color': ION_COLORS['other']}), 'value': 'other'},
                        ],
                        value=['y', 'b', 'a', 'c', 'z', 'IM', 'other'],
                        labelStyle={'display': 'block', 'color': '#ccc',
                                    'fontSize': '12px', 'marginBottom': '6px', 'cursor': 'pointer'},
                        inputStyle={'marginRight': '8px', 'accentColor': '#e2b96f'},
                    ),
                ]),

                html.Hr(style={'borderColor': '#2a2a4a', 'margin': '0'}),

                html.Div([
                    html.Label("DISPLAY", style={'color': '#e2b96f', 'fontSize': '10px',
                                                  'letterSpacing': '2px', 'marginBottom': '8px', 'display': 'block'}),
                    dcc.Checklist(
                        id='chk-display',
                        options=[
                            {'label': '  Labels',            'value': 'labels'},
                            {'label': '  Unmatched peaks',   'value': 'unmatched'},
                        ],
                        value=['labels', 'unmatched'],
                        labelStyle={'display': 'block', 'color': '#ccc',
                                    'fontSize': '12px', 'marginBottom': '6px', 'cursor': 'pointer'},
                        inputStyle={'marginRight': '8px', 'accentColor': '#e2b96f'},
                    ),
                ]),

                # ── PSM stats panel ───────────────────────────────────────────
                html.Div(id='psm-stats', style={
                    'marginTop': 'auto',
                    'background': '#0d0d1a',
                    'borderRadius': '6px',
                    'padding': '12px',
                    'fontSize': '11px',
                    'color': '#888',
                    'lineHeight': '1.8',
                }),
            ]),

            # ── Plot area ────────────────────────────────────────────────────
            html.Div(style={'flex': '1', 'padding': '16px', 'minWidth': '0'}, children=[
                dcc.Graph(
                    id='spectrum-graph',
                    style={'height': 'calc(100vh - 60px)'},
                    config={'displayModeBar': True, 'scrollZoom': True,
                            'modeBarButtonsToRemove': ['select2d', 'lasso2d'],
                            'toImageButtonOptions': {'format': 'png', 'scale': 2}},
                ),
            ]),
        ]),
    ])

    # ── Callbacks ─────────────────────────────────────────────────────────────
    @app.callback(
        Output('dd-peptide', 'options'),
        Output('dd-peptide', 'value'),
        Input('dd-protein', 'value'),
    )
    def update_peptides(protein):
        peps = peptide_list(df, protein)
        opts = [{'label': p, 'value': p} for p in peps]
        val  = peps[0] if peps else None
        return opts, val

    @app.callback(
        Output('spectrum-graph', 'figure'),
        Output('psm-stats', 'children'),
        Input('dd-protein',  'value'),
        Input('dd-peptide',  'value'),
        Input('chk-ions',    'value'),
        Input('chk-display', 'value'),
    )
    def update_spectrum(protein, peptide, show_ions, display_opts):
        if not protein or not peptide:
            return go.Figure(), 'No data'

        row = best_row(df, protein, peptide)
        if row is None:
            return go.Figure(), 'No matching PSM'

        seq          = sanitize(str(row.get('Sequence', '')))
        show_types   = show_ions or []
        show_labels  = 'labels'    in (display_opts or [])
        show_unmatched = 'unmatched' in (display_opts or [])

        fig = build_figure(row, seq, show_types, show_labels, show_unmatched)

        # Stats panel
        n_matches = len([x for x in str(row.get('Matches','')).split(';') if x.strip()])
        stats = [
            html.Div(f"Scan  {row.get('Scan number','')}"),
            html.Div(f"Score {row.get('Score','')}"),
            html.Div(f"PEP   {float(row.get('PEP', 0)):.2e}"),
            html.Div(f"z     {row.get('Charge','')}+"),
            html.Div(f"m/z   {raw_precursor_mz(row):.4f}"),
            html.Div(f"Matches {n_matches}"),
            html.Div(f"RT    {float(row.get('Retention time',0)):.2f} min"),
        ]
        return fig, stats

    return app


# ── Entry point ───────────────────────────────────────────────────────────────
def main():
    parser = argparse.ArgumentParser(description='Interactive MS/MS spectrum viewer')
    parser.add_argument('msms', type=Path, help='msms.txt file')
    parser.add_argument('--port', type=int, default=806)
    parser.add_argument('--host', type=str, default='0.0.0.0')
    args = parser.parse_args()

    print(f"Loading {args.msms} ...", flush=True)
    df = load_msms(args.msms)
    print(f"Loaded {len(df)} PSMs, {len(protein_list(df))} proteins", flush=True)

    app = make_app(df)
    app.run(host=args.host, port=args.port, debug=False)


if __name__ == '__main__':
    main()