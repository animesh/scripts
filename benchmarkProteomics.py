"""
python benchmarkProteomics.py --mq-dda "L:\promec\Animesh\nDDA\MaxQuant\DDA\combined\txt\proteinGroups.txt" --mq-dia "L:\promec\Animesh\nDDA\MaxQuant\DIA\combined\txt\proteinGroups.txt" --diann-dda "L:\promec\Animesh\nDDA\DIANN\DDA\report.DDA9.2p6.pg_matrix.tsv" --diann-dia "L:\promec\Animesh\nDDA\DIANN\DIA\report.DIA9.2p6.pg_matrix.tsv" --tesorai-dda "L:\promec\Animesh\nDDA\tesorAI\DDA\nDDA_quantified_protein_fdr.r.tsv.txt" --tesorai-dia "L:\promec\Animesh\nDDA\tesorAI\DIA\nDIA_quantified_protein_fdr.r.tsv.txt" --conc 1ng,100ng,1ug --conc-ng 1,100,1000 --out "L:\promec\Animesh\nDDA\report.html" --merge-out "L:\promec\Animesh\nDDA\report_merge_matrix.csv"

Build a single merged intensity matrix from MaxQuant, DIA-NN, and Tesorai
results, then use that merged matrix to generate summary plots and an HTML report.
"""

import argparse
import os
import re
import pandas as pd
import numpy as np
import plotly.graph_objects as go
from plotly.subplots import make_subplots
from scipy.stats import linregress, spearmanr

PALETTE = {
    "MQ-DDA Raw":"#90CAF9","MQ-DDA iBAQ":"#42A5F5","MQ-DDA Top3":"#1E88E5","MQ-DDA LFQ":"#0D47A1",
    "MQ-DIA Raw":"#EF9A9A","MQ-DIA iBAQ":"#EF5350","MQ-DIA Top3":"#E53935","MQ-DIA LFQ":"#B71C1C",
    "DIA-NN DDA":"#A5D6A7","DIA-NN DIA":"#2E7D32",
    "Tesorai-DDA iBAQ":"#CE93D8","Tesorai-DDA Top3":"#AB47BC",
    "Tesorai-DDA UA":"#7B1FA2","Tesorai-DDA LFQ":"#4A148C",
    "Tesorai-DIA iBAQ":"#FFE082","Tesorai-DIA Top3":"#FFB300",
    "Tesorai-DIA UA":"#FF6F00","Tesorai-DIA LFQ":"#E65100",
}

MQ_QUANTS = ["Intensity","iBAQ","Top3","LFQ intensity"]
MQ_SHORT = {"Intensity":"Raw","iBAQ":"iBAQ","Top3":"Top3","LFQ intensity":"LFQ"}
TQ_NAMES = ["intensity_IBAQ","intensity_top3","intensity_uncertainty_aware","intensity_lfq"]
TQ_SHORT = {"intensity_IBAQ":"iBAQ","intensity_top3":"Top3","intensity_uncertainty_aware":"UA","intensity_lfq":"LFQ"}


def pcol(label):
    return PALETTE.get(label, "#888888")


def sh(label):
    return label.replace("Tesorai-", "Tsr-").replace("DIA-NN ", "DNN-")


def to_ids(value):
    if pd.isna(value):
        return []
    ids = []
    for token in str(value).split(";"):
        token = token.strip()
        if not token:
            continue
        if "|" in token:
            parts = token.split("|")
            ids.append(parts[1] if len(parts) >= 2 else parts[0])
        else:
            ids.append(token)
    return list(dict.fromkeys(ids))


def explode_ids(df, id_col):
    df = df.copy()
    df["_orig_id"] = df[id_col].astype(str)
    df["_AC"] = df[id_col].apply(to_ids)
    df = df.explode("_AC").reset_index(drop=True)
    df = df[df["_AC"].notna() & (df["_AC"] != "")].copy()
    df["_AC"] = df["_AC"].astype(str)
    return df


def _mq_groups(df, prefix, conc_order):
    def normalize_token(token):
        token = token.lower()
        if token == "00ng":
            return "100ng"
        if token == "ng":
            return "1ng"
        if token == "ug":
            return "1ug"
        return token

    cols = [c for c in df.columns if c.startswith(prefix + " ") and "_R" in c]
    groups = {}
    for c in cols:
        tag = c.replace(prefix + " ", "")
        match = re.search(r"(00ng|100ng|1ng|ng|1ug|ug)(?:_|$)", tag, re.IGNORECASE)
        if match:
            token = normalize_token(match.group(1))
        else:
            token = tag

        mapped = next((conc for conc in conc_order if conc == token), None)
        if mapped is None:
            mapped = next((conc for conc in conc_order if conc in token), token)

        groups.setdefault(mapped, []).append(c)
    return groups


def _replace_zero_intensities(df, cols):
    cols = [c for c in cols if c in df.columns]
    for col in cols:
        df[col] = df[col].astype(float).replace(0, np.nan)
    return df


def load_mq(path, conc_order):
    if not os.path.exists(path):
        return None
    df = pd.read_csv(path, sep="\t", low_memory=False)
    keep = pd.Series(True, index=df.index)
    for col in ["Potential contaminant", "Decoy", "Only identified by site"]:
        if col in df.columns:
            keep &= df[col].astype(str) != "+"
    df = df[keep].copy().reset_index(drop=True)
    mq_cols = [c for c in df.columns if any(c.startswith(prefix + " ") and "_R" in c for prefix in MQ_QUANTS)]
    df = _replace_zero_intensities(df, mq_cols)
    protein_col = "Protein IDs" if "Protein IDs" in df.columns else "Majority protein IDs"
    if protein_col not in df.columns:
        return None
    df = explode_ids(df, protein_col)
    return df


def load_diann(path, conc_order):
    if not os.path.exists(path):
        return None
    df = pd.read_csv(path, sep="\t")
    if "Protein.Group" not in df.columns:
        return None
    raw_cols = [c for c in df.columns if c.endswith(".raw")]
    df = _replace_zero_intensities(df, raw_cols)
    df = explode_ids(df, "Protein.Group")
    return df


def load_tesorai(path, conc_order):
    if not os.path.exists(path):
        return None
    df = pd.read_csv(path, sep="\t")
    if "protein_group_id" not in df.columns:
        return None
    if "is_decoy" in df.columns:
        df = df[~df["is_decoy"]].copy()
    else:
        df = df.copy()
    tq_cols = [c for c in TQ_NAMES if c in df.columns]
    df = _replace_zero_intensities(df, tq_cols)
    df["file_name"] = df["file_name"].str.replace(r"_R(\\d+)_\\d+\\.raw$", r"_R\\1.raw", regex=True)
    df = explode_ids(df, "protein_group_id")
    return df


def build_merge_matrix(mq_dda, mq_dia, dn_dda, dn_dia, t_dda, t_dia, conc_order):
    parts = []
    added_sources = set()

    def store_source_ids(df, name):
        if df is None:
            return None
        src = df.groupby("_AC")["_orig_id"].agg(
            lambda values: ";".join(sorted(dict.fromkeys(v for v in values.astype(str) if v.strip()))))
        return src.rename(f"{name}_ID")

    def add_summary(df, label, source_name=None, summary_cols=None):
        if df is None:
            return
        if source_name is not None and source_name not in added_sources:
            src = store_source_ids(df, source_name)
            if src is not None:
                parts.append(src)
                added_sources.add(source_name)
        if summary_cols is None:
            return
        for conc, cols in summary_cols.items():
            if not cols:
                continue
            summary = df.groupby("_AC")[cols].median().median(axis=1).rename(f"{label}@{conc}")
            parts.append(summary)
            for col in cols:
                rep_name = col.replace(" ", "_")
                rep_series = df.groupby("_AC")[col].median().rename(f"{label} {rep_name}")
                parts.append(rep_series)

    if mq_dda is not None:
        mq_dda_groups = {q: _mq_groups(mq_dda, q, conc_order) for q in MQ_QUANTS}
        for q in MQ_QUANTS:
            add_summary(mq_dda, f"MQ-DDA {MQ_SHORT[q]}", source_name="MQ-DDA", summary_cols=mq_dda_groups[q])

    if mq_dia is not None:
        mq_dia_groups = {q: _mq_groups(mq_dia, q, conc_order) for q in MQ_QUANTS}
        for q in MQ_QUANTS:
            add_summary(mq_dia, f"MQ-DIA {MQ_SHORT[q]}", source_name="MQ-DIA", summary_cols=mq_dia_groups[q])

    if dn_dda is not None:
        dn_dda_cols = [c for c in dn_dda.columns if c.endswith(".raw")]
        groups = {conc: [c for c in dn_dda_cols if f"_{conc}_" in c or f"Hela_{conc}_" in c] for conc in conc_order}
        add_summary(dn_dda, "DIA-NN DDA", source_name="DIA-NN DDA", summary_cols=groups)

    if dn_dia is not None:
        dn_dia_cols = [c for c in dn_dia.columns if c.endswith(".raw")]
        groups = {conc: [c for c in dn_dia_cols if f"_{conc}_" in c or f"Hela_{conc}_" in c] for conc in conc_order}
        add_summary(dn_dia, "DIA-NN DIA", source_name="DIA-NN DIA", summary_cols=groups)

    def tesorai_groups(df):
        out = {}
        for conc in conc_order:
            cols = [col for col in df["file_name"].unique() if f"_{conc}_" in col]
            out[conc] = cols
        return out

    if t_dda is not None:
        groups = tesorai_groups(t_dda)
        for q in TQ_NAMES:
            pivot = t_dda.pivot_table(index="_AC", columns="file_name", values=q, aggfunc="median")
            for conc in conc_order:
                matched = [c for c in pivot.columns if f"_{conc}_" in c]
                if not matched:
                    continue
                parts.append(pivot[matched].median(axis=1).rename(f"Tesorai-DDA {TQ_SHORT[q]}@{conc}"))
                for col in matched:
                    parts.append(pivot[col].rename(f"Tesorai-DDA {TQ_SHORT[q]} {col}"))
        src = store_source_ids(t_dda, "Tesorai-DDA")
        if src is not None:
            parts.append(src)

    if t_dia is not None:
        for q in TQ_NAMES:
            pivot = t_dia.pivot_table(index="_AC", columns="file_name", values=q, aggfunc="median")
            for conc in conc_order:
                matched = [c for c in pivot.columns if f"_{conc}_" in c]
                if not matched:
                    continue
                parts.append(pivot[matched].median(axis=1).rename(f"Tesorai-DIA {TQ_SHORT[q]}@{conc}"))
                for col in matched:
                    parts.append(pivot[col].rename(f"Tesorai-DIA {TQ_SHORT[q]} {col}"))
        src = store_source_ids(t_dia, "Tesorai-DIA")
        if src is not None:
            parts.append(src)

    if not parts:
        return pd.DataFrame()

    merged = pd.concat(parts, axis=1, sort=False)
    merged.index.name = "UniprotID"
    return merged


def make_vecs(merged, conc_order):
    vecs = {}
    for col in merged.columns:
        match = re.match(r"^(.*)@(.+)$", col)
        if match:
            label, conc = match.group(1), match.group(2)
            vecs.setdefault(label, {})[conc] = merged[col].dropna()
    return vecs


def rank_corr_matrix(vecs, conc_order):
    labels = sorted(vecs)
    out = {}
    for conc in conc_order:
        n = len(labels)
        rho = np.full((n, n), np.nan)
        for i, la in enumerate(labels):
            rho[i, i] = 1.0
            for j, lb in enumerate(labels):
                if j <= i:
                    rho[i, j] = rho[j, i]
                    continue
                a = vecs.get(la, {}).get(conc)
                b = vecs.get(lb, {}).get(conc)
                if a is None or b is None:
                    continue
                shared = a.index.intersection(b.index)
                if len(shared) < 10:
                    continue
                rho[i, j], _ = spearmanr(a.loc[shared], b.loc[shared])
        out[conc] = {"rho": rho, "labels": labels}
    return out


def linearity_stats(vecs, conc_order, conc_ng):
    rows = []
    for label, values in vecs.items():
        xs, ys, xs_raw, ys_raw = [], [], [], []
        for conc in conc_order:
            series = values.get(conc)
            if series is None or series.empty:
                continue
            total = series.sum()
            if total <= 0:
                continue
            xs.append(np.log2(conc_ng[conc]))
            ys.append(np.log2(total))
            xs_raw.append(conc_ng[conc])
            ys_raw.append(total)
        if len(xs) < 2:
            continue
        slope, intercept, r_value, _, _ = linregress(xs, ys)
        rows.append({
            "Pipeline": label,
            "Slope": round(slope, 3),
            "R2": round(r_value ** 2, 4),
            "_x": xs,
            "_y": ys,
            "_x_raw": xs_raw,
            "_y_raw": ys_raw,
            "_sl": slope,
            "_ic": intercept,
        })
    return pd.DataFrame(rows)


def collect_cv(merged, conc_order):
    def normalize_conc(token):
        token = token.lower()
        if token == "00ng":
            return "100ng"
        if token == "ng":
            return "1ng"
        if token == "ug":
            return "1ug"
        return token

    rows = []
    labels = sorted(set(re.sub(r"@.+", "", c) for c in merged.columns if "@" in c))
    for label in labels:
        cols = [c for c in merged.columns if c.startswith(f"{label} ") and not c.endswith("_ID") and "@" not in c]
        for conc in conc_order:
            matched = []
            for c in cols:
                match = re.search(r"(100ng|00ng|1ng|ng|1ug|ug)(?:_|$)", c, re.IGNORECASE)
                if not match:
                    continue
                token = normalize_conc(match.group(1))
                if token == conc:
                    matched.append(c)
            if not matched:
                continue
            values = merged[matched]
            cv = (values.std(axis=1) / values.mean(axis=1) * 100).replace([np.inf, -np.inf], np.nan).dropna()
            if not cv.empty:
                rows.append((label, conc, cv.values))
    return rows


def build_report(figs, tables, args, conc_order, conc_ng):
    with open(args.out, "w", encoding="utf-8") as f:
        f.write("<!DOCTYPE html><html><head><meta charset='utf-8'><title>Proteomics Benchmark</title></head><body>\n")
        f.write("<h1>Proteomics Benchmark</h1>\n")
        f.write("<p>Source files:<br>")
        f.write(f"MQ-DDA: {args.mq_dda}<br>MQ-DIA: {args.mq_dia}<br>DIA-NN DDA: {args.diann_dda}<br>DIA-NN DIA: {args.diann_dia}<br>")
        f.write(f"Tesorai DDA: {args.tesorai_dda}<br>Tesorai DIA: {args.tesorai_dia}<br>")
        if getattr(args, 'merge_matrix_path', None):
            f.write(f"Merged matrix: {args.merge_matrix_path}<br>")
        f.write(f"Concentrations: {', '.join(conc_order)}<br>\n")
        f.write("</p>\n")
        f.write("<div><strong>Contents</strong><ul>\n")
        for title, anchor, _ in figs:
            f.write(f"<li><a href='#{anchor}'>{title}</a></li>\n")
        f.write("</ul></div>\n")
        for title, html in tables:
            f.write(f"<h2>{title}</h2>\n{html}\n")
        for title, anchor, fig in figs:
            f.write(f"<h2 id='{anchor}'>{title}</h2>\n")
            f.write(fig.to_html(full_html=False, include_plotlyjs='cdn'))
            f.write("\n")
        f.write("</body></html>\n")
    print(f"Report saved to {args.out}")


def fig_pg_counts(vecs, conc_order):
    rows = []
    for label, values in vecs.items():
        for conc in conc_order:
            count = int(values.get(conc).notna().sum()) if values.get(conc) is not None else 0
            rows.append({"Pipeline": label, "Concentration": conc, "Count": count})
    df = pd.DataFrame(rows)
    fig = go.Figure()
    for label in df["Pipeline"].unique():
        sub = df[df["Pipeline"] == label]
        fig.add_trace(go.Bar(name=sh(label), x=sub["Concentration"], y=sub["Count"], marker_color=pcol(label)))
    fig.update_layout(title="1. Protein Groups Detected", barmode="group", template="plotly_white")
    return fig


def fig_missing(merged, conc_order):
    rows = []
    summary_cols = [c for c in merged.columns if "@" in c]
    for col in summary_cols:
        label, conc = col.rsplit("@", 1)
        mv = merged[col].isna().mean() * 100
        rows.append({"Pipeline": label, "Concentration": conc, "Missing%": round(mv, 1)})
    df = pd.DataFrame(rows)
    fig = go.Figure()
    for label in df["Pipeline"].unique():
        sub = df[df["Pipeline"] == label]
        fig.add_trace(go.Bar(name=sh(label), x=sub["Concentration"], y=sub["Missing%"], marker_color=pcol(label)))
    fig.update_layout(title="2. Missing Value Rates", barmode="group", template="plotly_white", yaxis_title="Missing value %")
    return fig


def fig_cv_violin(cv_data):
    fig = go.Figure()
    for label, conc, values in cv_data:
        fig.add_trace(go.Violin(y=values, name=f"{sh(label)} {conc}", box_visible=True, meanline_visible=True))
    fig.update_layout(title="3. CV Distribution", template="plotly_white")
    return fig


def fig_intensity_violin(vecs, conc_order):
    fig = go.Figure()
    for label, values in vecs.items():
        for conc in conc_order:
            series = values.get(conc)
            if series is None or series.empty:
                continue
            fig.add_trace(go.Violin(y=series.values, name=f"{sh(label)} {conc}", box_visible=True, meanline_visible=True))
    fig.update_layout(title="4. Intensity Distribution", yaxis_title="Intensity", yaxis_type="log", template="plotly_white")
    return fig


def fig_split_violin(vecs, conc_order):
    pairs = [("MQ-DDA iBAQ", "MQ-DIA iBAQ", "MaxQuant iBAQ"),
             ("DIA-NN DDA", "DIA-NN DIA", "DIA-NN"),
             ("Tesorai-DDA iBAQ", "Tesorai-DIA iBAQ", "Tesorai iBAQ")]
    fig = make_subplots(rows=len(pairs), cols=len(conc_order), subplot_titles=[f"{name} @ {conc}" for name in [p[2] for p in pairs] for conc in conc_order])
    for ri, (dda, dia, name) in enumerate(pairs, start=1):
        for ci, conc in enumerate(conc_order, start=1):
            for label, side in [(dda, "DDA"), (dia, "DIA")]:
                series = vecs.get(label, {}).get(conc)
                if series is None or series.empty:
                    continue
                fig.add_trace(
                    go.Violin(
                        y=series.values,
                        name=sh(label),
                        side="positive" if side == "DIA" else "negative",
                        box_visible=True,
                        meanline_visible=True
                    ),
                    row=ri,
                    col=ci
                )
    fig.update_layout(title="5. DDA vs DIA Split Violin", template="plotly_white", violingap=0, yaxis_type="log")
    return fig


def fig_linearity(lin_df, conc_order, conc_ng):
    fig = go.Figure()
    for _, row in lin_df.iterrows():
        if "_x_raw" in row and "_y_raw" in row:
            fig.add_trace(go.Scatter(x=row["_x_raw"], y=row["_y_raw"], mode="markers+lines", name=sh(row["Pipeline"])))
        else:
            fig.add_trace(go.Scatter(x=row["_x"], y=row["_y"], mode="markers+lines", name=sh(row["Pipeline"])))
    fig.update_layout(title="6. Linearity", xaxis_title="ng", yaxis_title="total signal", xaxis_type="log", yaxis_type="log", template="plotly_white")
    return fig


def fig_linearity_bars(lin_df):
    fig = make_subplots(rows=1, cols=2, subplot_titles=["Slope", "R2"])
    fig.add_trace(go.Bar(x=lin_df["Pipeline"].map(sh), y=lin_df["Slope"], name="Slope"), row=1, col=1)
    fig.add_trace(go.Bar(x=lin_df["Pipeline"].map(sh), y=lin_df["R2"], name="R2"), row=1, col=2)
    fig.update_layout(title="7. Linearity Slope and R2", template="plotly_white")
    return fig


def fig_ratio_bars(lin_df):
    fig = go.Figure()
    for _, row in lin_df.iterrows():
        if len(row["_x"]) >= 2:
            observed = row["_y"][-1] - row["_y"][0]
            fig.add_trace(go.Bar(x=[sh(row["Pipeline"])], y=[observed], name=sh(row["Pipeline"]) ))
    fig.update_layout(title="8. Observed Ratio Differences", template="plotly_white")
    return fig


def fig_rank_heatmaps(rho_data, conc_order):
    fig = make_subplots(rows=1, cols=len(conc_order), subplot_titles=[f"{conc}" for conc in conc_order])
    for i, conc in enumerate(conc_order, start=1):
        data = rho_data[conc]
        fig.add_trace(go.Heatmap(z=data["rho"], x=data["labels"], y=data["labels"], colorscale="Viridis", zmin=-1, zmax=1, colorbar=dict(title="rho")), row=1, col=i)
    fig.update_layout(title="9. Rank Correlation Heatmaps", template="plotly_white")
    return fig


def fig_scatter_pairs(vecs, conc_order):
    pairs = [
        ("MQ-DDA Raw", "DIA-NN DDA"),
        ("MQ-DDA iBAQ", "DIA-NN DDA"),
        ("MQ-DDA Top3", "DIA-NN DDA"),
        ("MQ-DDA LFQ", "DIA-NN DDA"),
        ("MQ-DIA Raw", "DIA-NN DIA"),
        ("MQ-DIA iBAQ", "DIA-NN DIA"),
        ("MQ-DIA Top3", "DIA-NN DIA"),
        ("MQ-DIA LFQ", "DIA-NN DIA"),
        ("MQ-DDA iBAQ", "Tesorai-DDA iBAQ"),
        ("MQ-DDA Top3", "Tesorai-DDA Top3"),
        ("MQ-DDA LFQ", "Tesorai-DDA LFQ"),
        ("MQ-DIA iBAQ", "Tesorai-DIA iBAQ"),
        ("MQ-DIA Top3", "Tesorai-DIA Top3"),
        ("MQ-DIA LFQ", "Tesorai-DIA LFQ"),
    ]
    cols = 2
    rows = 21
    titles = [f"{a} vs {b} @ {conc}" for conc in conc_order for a, b in pairs]
    fig = make_subplots(
        rows=rows,
        cols=cols,
        subplot_titles=titles,
        vertical_spacing=0.03,
        horizontal_spacing=0.04,
        shared_xaxes=False,
        shared_yaxes=False,
    )
    for conc_idx, conc in enumerate(conc_order):
        for pair_idx, (a, b) in enumerate(pairs):
            idx = conc_idx * len(pairs) + pair_idx
            row = idx // cols + 1
            col = idx % cols + 1
            x = vecs.get(a, {}).get(conc)
            y = vecs.get(b, {}).get(conc)
            if x is None or y is None:
                continue
            shared = x.index.intersection(y.index)
            if shared.empty:
                continue
            fig.add_trace(
                go.Scatter(x=x.loc[shared], y=y.loc[shared], mode="markers", name=f"{sh(a)} vs {sh(b)} @ {conc}"),
                row=row,
                col=col,
            )
    fig.update_layout(
        title="10. Cross-Pipeline Scatter",
        template="plotly_white",
        height=8400,
        legend=dict(traceorder="normal", orientation="h", yanchor="bottom", y=-0.05, xanchor="center", x=0.5),
    )
    return fig


def fig_rho_trend(vecs, conc_order):
    labels = sorted(vecs)
    trends = []
    for i, label in enumerate(labels):
        for j, other in enumerate(labels):
            if j <= i:
                continue
            values = []
            for conc in conc_order:
                a = vecs[label].get(conc)
                b = vecs[other].get(conc)
                if a is None or b is None:
                    values.append(np.nan)
                    continue
                shared = a.index.intersection(b.index)
                if len(shared) < 10:
                    values.append(np.nan)
                    continue
                r, _ = spearmanr(a.loc[shared], b.loc[shared])
                values.append(r)
            trends.append((f"{sh(label)} vs {sh(other)}", values))
    fig = go.Figure()
    for name, values in trends:
        fig.add_trace(go.Scatter(x=conc_order, y=values, mode="lines+markers", name=name))
    fig.update_layout(title="11. Rho Trend Across Concentrations", template="plotly_white")
    return fig


def fig_mode_correlation(vecs, conc, title):
    fig = go.Figure()
    for label in vecs:
        if conc not in vecs[label]:
            continue
        values = vecs[label][conc]
        values = values[values > 0]
        if values.empty:
            continue
        fig.add_trace(go.Histogram(x=values, name=sh(label), opacity=0.6))
    fig.update_layout(title=title, barmode="overlay", xaxis_title="Intensity", xaxis_type="log", template="plotly_white")
    return fig


def fig_dynamic_range(vecs, conc_order):
    fig = go.Figure()
    for label, values in vecs.items():
        for conc in conc_order:
            series = values.get(conc)
            if series is None:
                continue
            clean = series.dropna().values
            if clean.size == 0:
                continue
            clean = np.sort(clean)[::-1]
            fig.add_trace(go.Scatter(x=np.arange(1, len(clean) + 1), y=clean, mode="lines", name=f"{sh(label)} {conc}"))
    fig.update_layout(
        title="15. Dynamic Range",
        xaxis_title="Rank",
        yaxis_title="Intensity",
        xaxis_type="log",
        yaxis_type="log",
        template="plotly_white"
    )
    return fig


def _detection_overlap_counts(merged, conc_order, dda_prefix, dia_prefix):
    rows = []
    for conc in conc_order:
        dda_cols = [c for c in merged.columns if c.startswith(dda_prefix) and c.endswith(f"@{conc}")]
        dia_cols = [c for c in merged.columns if c.startswith(dia_prefix) and c.endswith(f"@{conc}")]
        dda = merged[dda_cols].notna().any(axis=1) if dda_cols else pd.Series(False, index=merged.index)
        dia = merged[dia_cols].notna().any(axis=1) if dia_cols else pd.Series(False, index=merged.index)
        rows.append({"Concentration": conc, "Category": "DDA only", "Count": int((dda & ~dia).sum())})
        rows.append({"Concentration": conc, "Category": "DIA only", "Count": int((~dda & dia).sum())})
        rows.append({"Concentration": conc, "Category": "Both", "Count": int((dda & dia).sum())})
    return pd.DataFrame(rows)


def _fig_detection_overlap_family(merged, conc_order, family_name, dda_prefix, dia_prefix):
    df = _detection_overlap_counts(merged, conc_order, dda_prefix, dia_prefix)
    fig = go.Figure()
    for category in ["DDA only", "DIA only", "Both"]:
        sub = df[df["Category"] == category]
        fig.add_trace(go.Bar(name=category, x=sub["Concentration"], y=sub["Count"]))
    fig.update_layout(title=f"{family_name} DDA vs DIA Detection Overlap", barmode="group", template="plotly_white")
    return fig


def fig_detection_overlap(merged, conc_order):
    return _fig_detection_overlap_family(merged, conc_order, "MaxQuant", "MQ-DDA", "MQ-DIA")


def fig_detection_overlap_diann(merged, conc_order):
    return _fig_detection_overlap_family(merged, conc_order, "DIA-NN", "DIA-NN DDA", "DIA-NN DIA")


def fig_detection_overlap_tesorai(merged, conc_order):
    return _fig_detection_overlap_family(merged, conc_order, "Tesorai", "Tesorai-DDA", "Tesorai-DIA")


def _venn_concentration_counts(merged, conc_order, prefix):
    if len(conc_order) != 3:
        raise ValueError("Venn plots require exactly three concentrations")
    sets = []
    for conc in conc_order:
        cols = [c for c in merged.columns if c.startswith(prefix) and c.endswith(f"@{conc}")]
        sets.append(merged[cols].notna().any(axis=1) if cols else pd.Series(False, index=merged.index))
    a, b, c = sets
    return {
        "100": int((a & ~b & ~c).sum()),
        "010": int((~a & b & ~c).sum()),
        "001": int((~a & ~b & c).sum()),
        "110": int((a & b & ~c).sum()),
        "101": int((a & ~b & c).sum()),
        "011": int((~a & b & c).sum()),
        "111": int((a & b & c).sum()),
    }


def _fig_venn(merged, conc_order, family_name, prefix, mode_label):
    counts = _venn_concentration_counts(merged, conc_order, prefix)
    fig = go.Figure()
    circle_style = dict(
        type="circle",
        xref="x",
        yref="y",
        line=dict(color="rgba(55, 83, 109, 0.8)", width=2),
        fillcolor="rgba(55, 83, 109, 0.12)",
    )
    fig.add_shape(dict(circle_style, x0=0.18, y0=0.2, x1=0.52, y1=0.54))
    fig.add_shape(dict(circle_style, x0=0.48, y0=0.2, x1=0.82, y1=0.54))
    fig.add_shape(dict(circle_style, x0=0.33, y0=0.46, x1=0.67, y1=0.8))
    annotations = [
        dict(x=0.18, y=0.63, text=conc_order[0], showarrow=False, font=dict(size=12), xanchor="center"),
        dict(x=0.82, y=0.63, text=conc_order[1], showarrow=False, font=dict(size=12), xanchor="center"),
        dict(x=0.5, y=0.88, text=conc_order[2], showarrow=False, font=dict(size=12), xanchor="center"),
        dict(x=0.18, y=0.35, text=str(counts["100"]), showarrow=False, font=dict(size=14, color="#000"), xanchor="center"),
        dict(x=0.82, y=0.35, text=str(counts["010"]), showarrow=False, font=dict(size=14, color="#000"), xanchor="center"),
        dict(x=0.5, y=0.74, text=str(counts["001"]), showarrow=False, font=dict(size=14, color="#000"), xanchor="center"),
        dict(x=0.5, y=0.43, text=str(counts["110"]), showarrow=False, font=dict(size=14, color="#000"), xanchor="center"),
        dict(x=0.33, y=0.58, text=str(counts["101"]), showarrow=False, font=dict(size=14, color="#000"), xanchor="center"),
        dict(x=0.67, y=0.58, text=str(counts["011"]), showarrow=False, font=dict(size=14, color="#000"), xanchor="center"),
        dict(x=0.5, y=0.53, text=str(counts["111"]), showarrow=False, font=dict(size=14, color="#000", family="Arial Black"), xanchor="center"),
    ]
    fig.update_layout(
        title=f"{family_name} {mode_label} Concentration Venn",
        annotations=annotations,
        xaxis=dict(visible=False, range=[0, 1]),
        yaxis=dict(visible=False, range=[0, 1], scaleanchor="x", scaleratio=1),
        template="plotly_white",
        margin=dict(l=20, r=20, t=50, b=20),
        showlegend=False,
    )
    return fig


def _tool_presence(merged, prefixes):
    presence = pd.Series(False, index=merged.index)
    for prefix in prefixes:
        cols = [c for c in merged.columns if c.startswith(prefix) and "@" in c]
        if cols:
            presence = presence | merged[cols].notna().any(axis=1)
    return presence


def _three_tool_overlap_counts(merged, prefixes, labels):
    presence = [_tool_presence(merged, [prefix]) for prefix in prefixes]
    a, b, c = presence
    return {
        labels[0]: int((a & ~b & ~c).sum()),
        labels[1]: int((~a & b & ~c).sum()),
        labels[2]: int((~a & ~b & c).sum()),
        f"{labels[0]} + {labels[1]}": int((a & b & ~c).sum()),
        f"{labels[0]} + {labels[2]}": int((a & ~b & c).sum()),
        f"{labels[1]} + {labels[2]}": int((~a & b & c).sum()),
        "All three": int((a & b & c).sum()),
    }


def _fig_three_tool_venn(merged, prefixes, labels, title):
    counts = _three_tool_overlap_counts(merged, prefixes, labels)
    fig = go.Figure()
    circle_style = dict(
        type="circle",
        xref="x",
        yref="y",
        line=dict(color="rgba(55, 83, 109, 0.8)", width=2),
        fillcolor="rgba(55, 83, 109, 0.12)",
    )
    fig.add_shape(dict(circle_style, x0=0.12, y0=0.2, x1=0.52, y1=0.6))
    fig.add_shape(dict(circle_style, x0=0.32, y0=0.2, x1=0.72, y1=0.6))
    fig.add_shape(dict(circle_style, x0=0.22, y0=0.4, x1=0.62, y1=0.8))
    annotations = [
        dict(x=0.12, y=0.68, text=labels[0], showarrow=False, font=dict(size=12), xanchor="center"),
        dict(x=0.72, y=0.68, text=labels[1], showarrow=False, font=dict(size=12), xanchor="center"),
        dict(x=0.43, y=0.88, text=labels[2], showarrow=False, font=dict(size=12), xanchor="center"),
        dict(x=0.08, y=0.33, text=str(counts[labels[0]]), showarrow=False, font=dict(size=14), xanchor="center"),
        dict(x=0.86, y=0.33, text=str(counts[labels[1]]), showarrow=False, font=dict(size=14), xanchor="center"),
        dict(x=0.43, y=0.74, text=str(counts[labels[2]]), showarrow=False, font=dict(size=14), xanchor="center"),
        dict(x=0.43, y=0.42, text=str(counts[f"{labels[0]} + {labels[1]}"]), showarrow=False, font=dict(size=13), xanchor="center"),
        dict(x=0.33, y=0.58, text=str(counts[f"{labels[0]} + {labels[2]}"]), showarrow=False, font=dict(size=13), xanchor="center"),
        dict(x=0.63, y=0.58, text=str(counts[f"{labels[1]} + {labels[2]}"]), showarrow=False, font=dict(size=13), xanchor="center"),
        dict(x=0.43, y=0.53, text=str(counts["All three"]), showarrow=False, font=dict(size=14, family="Arial Black"), xanchor="center"),
    ]
    fig.update_layout(
        title=title,
        annotations=annotations,
        xaxis=dict(visible=False, range=[0, 1]),
        yaxis=dict(visible=False, range=[0, 1], scaleanchor="x", scaleratio=1),
        template="plotly_white",
        margin=dict(l=20, r=20, t=60, b=20),
        showlegend=False,
    )
    return fig


def fig_three_tool_dda_overlap(merged, conc_order):
    prefixes = ["MQ-DDA", "DIA-NN DDA", "Tesorai-DDA"]
    labels = ["MaxQuant", "DIA-NN", "Tesorai"]
    return _fig_three_tool_venn(merged, prefixes, labels, "Overlap across MaxQuant, DIA-NN, and Tesorai (DDA)")


def fig_three_tool_dia_overlap(merged, conc_order):
    prefixes = ["MQ-DIA", "DIA-NN DIA", "Tesorai-DIA"]
    labels = ["MaxQuant", "DIA-NN", "Tesorai"]
    return _fig_three_tool_venn(merged, prefixes, labels, "Overlap across MaxQuant, DIA-NN, and Tesorai (DIA)")


def fig_venn_maxquant_dda(merged, conc_order):
    return _fig_venn(merged, conc_order, "MaxQuant", "MQ-DDA", "DDA")


def fig_venn_maxquant_dia(merged, conc_order):
    return _fig_venn(merged, conc_order, "MaxQuant", "MQ-DIA", "DIA")


def fig_venn_diann_dda(merged, conc_order):
    return _fig_venn(merged, conc_order, "DIA-NN", "DIA-NN DDA", "DDA")


def fig_venn_diann_dia(merged, conc_order):
    return _fig_venn(merged, conc_order, "DIA-NN", "DIA-NN DIA", "DIA")


def fig_venn_tesorai_dda(merged, conc_order):
    return _fig_venn(merged, conc_order, "Tesorai", "Tesorai-DDA", "DDA")


def fig_venn_tesorai_dia(merged, conc_order):
    return _fig_venn(merged, conc_order, "Tesorai", "Tesorai-DIA", "DIA")


def fig_rho_matrix(rho_data, conc, title=None):
    data = rho_data[conc]
    fig = go.Figure(go.Heatmap(z=data["rho"], x=data["labels"], y=data["labels"], colorscale="Viridis", zmin=-1, zmax=1))
    fig.update_layout(title=title or f"Spearman rho @ {conc}", template="plotly_white")
    return fig


def parse_args():
    parser = argparse.ArgumentParser(description="Generate proteomics benchmark figures from merged matrix data.")
    parser.add_argument("--mq-dda", default="proteinGroups_DDA.txt")
    parser.add_argument("--mq-dia", default="proteinGroups_DIA.txt")
    parser.add_argument("--diann-dda", default="report_DDA9_2p6_pg_matrix.tsv")
    parser.add_argument("--diann-dia", default="report_DIA9_2p6_pg_matrix.tsv")
    parser.add_argument("--tesorai-dda", default="nDDA_quantified_protein_fdr_r_tsv.txt")
    parser.add_argument("--tesorai-dia", default="nDIA_quantified_protein_fdr_r_tsv.txt")
    parser.add_argument("--conc", default="1ng,100ng,1ug")
    parser.add_argument("--conc-ng", default="1,100,1000")
    parser.add_argument("--out", default="benchmarkProteomics.html")
    parser.add_argument("--merge-out", default=None,
                        help="Merged matrix CSV output path")
    return parser.parse_args()


def main():
    args = parse_args()
    conc_order = [c.strip() for c in args.conc.split(",")]
    conc_ng_values = [float(x.strip()) for x in args.conc_ng.split(",")]
    if len(conc_order) != len(conc_ng_values):
        raise SystemExit("--conc and --conc-ng must define the same number of concentrations")
    conc_ng = dict(zip(conc_order, conc_ng_values))

    mq_dda = load_mq(args.mq_dda, conc_order)
    mq_dia = load_mq(args.mq_dia, conc_order)
    dn_dda = load_diann(args.diann_dda, conc_order)
    dn_dia = load_diann(args.diann_dia, conc_order)
    t_dda = load_tesorai(args.tesorai_dda, conc_order)
    t_dia = load_tesorai(args.tesorai_dia, conc_order)

    merged = build_merge_matrix(mq_dda, mq_dia, dn_dda, dn_dia, t_dda, t_dia, conc_order)
    if merged.empty:
        raise SystemExit("No data available to build the merged matrix.")

    merge_path = args.merge_out if args.merge_out else os.path.splitext(args.out)[0] + "_merge_matrix.csv"
    merged.to_csv(merge_path)
    args.merge_matrix_path = merge_path
    print(f"Merged matrix saved to {merge_path}")

    vecs = make_vecs(merged, conc_order)
    rho_data = rank_corr_matrix(vecs, conc_order)
    lin_df = linearity_stats(vecs, conc_order, conc_ng)
    cv_data = collect_cv(merged, conc_order)

    figs = [
        ("1. Protein Groups Detected", "pg", fig_pg_counts(vecs, conc_order)),
        ("2. Missing Value Rates", "missing", fig_missing(merged, conc_order)),
        ("3. CV Distributions", "cv", fig_cv_violin(cv_data)),
        ("4. Intensity Distributions", "intensity", fig_intensity_violin(vecs, conc_order)),
        ("5. DDA vs DIA Split Violin", "split", fig_split_violin(vecs, conc_order)),
        ("6. Quantification Linearity", "linearity", fig_linearity(lin_df, conc_order, conc_ng)),
        ("7. Linearity Slope and R2", "linearity_bars", fig_linearity_bars(lin_df)),
        ("8. Observed Ratio Differences", "ratios", fig_ratio_bars(lin_df)),
        ("9. Rank Correlation Heatmaps", "heatmaps", fig_rank_heatmaps(rho_data, conc_order)),
        ("10. Cross-Pipeline Scatter", "scatter", fig_scatter_pairs(vecs, conc_order)),
        ("11. Rho Trend", "rho_trend", fig_rho_trend(vecs, conc_order)),
    ]
    low, mid, high = conc_order[0], conc_order[len(conc_order) // 2], conc_order[-1]
    figs += [
        (f"12. Within vs Cross-Mode Correlation @ {low}", "mode_low", fig_mode_correlation(vecs, low, f"12. Within vs Cross-Mode Correlation @ {low}")),
        (f"13. Within vs Cross-Mode Correlation @ {mid}", "mode_mid", fig_mode_correlation(vecs, mid, f"13. Within vs Cross-Mode Correlation @ {mid}")),
        (f"14. Within vs Cross-Mode Correlation @ {high}", "mode_high", fig_mode_correlation(vecs, high, f"14. Within vs Cross-Mode Correlation @ {high}")),
        ("15. Dynamic Range", "dynamic_range", fig_dynamic_range(vecs, conc_order)),
        ("16. MaxQuant DDA vs DIA Detection Overlap", "overlap_mq", fig_detection_overlap(merged, conc_order)),
        ("17. DIA-NN DDA vs DIA Detection Overlap", "overlap_diann", fig_detection_overlap_diann(merged, conc_order)),
        ("18. Tesorai DDA vs DIA Detection Overlap", "overlap_tesorai", fig_detection_overlap_tesorai(merged, conc_order)),
        ("19. MaxQuant DDA Concentration Venn", "venn_mq_dda", fig_venn_maxquant_dda(merged, conc_order)),
        ("20. MaxQuant DIA Concentration Venn", "venn_mq_dia", fig_venn_maxquant_dia(merged, conc_order)),
        ("21. DIA-NN DDA Concentration Venn", "venn_diann_dda", fig_venn_diann_dda(merged, conc_order)),
        ("22. DIA-NN DIA Concentration Venn", "venn_diann_dia", fig_venn_diann_dia(merged, conc_order)),
        ("23. Tesorai DDA Concentration Venn", "venn_tesorai_dda", fig_venn_tesorai_dda(merged, conc_order)),
        ("24. Tesorai DIA Concentration Venn", "venn_tesorai_dia", fig_venn_tesorai_dia(merged, conc_order)),
        ("25. Cross-Tool DDA Overlap", "venn_three_tool_dda", fig_three_tool_dda_overlap(merged, conc_order)),
        ("26. Cross-Tool DIA Overlap", "venn_three_tool_dia", fig_three_tool_dia_overlap(merged, conc_order)),
        (f"27. Full Spearman rho Matrix @ {mid}", "rho_mid", fig_rho_matrix(rho_data, mid, title=f"27. Full Spearman rho Matrix @ {mid}")),
        (f"28. Full Spearman rho Matrix @ {low}", "rho_low", fig_rho_matrix(rho_data, low, title=f"28. Full Spearman rho Matrix @ {low}")),
        (f"29. Full Spearman rho Matrix @ {high}", "rho_high", fig_rho_matrix(rho_data, high, title=f"29. Full Spearman rho Matrix @ {high}")),
    ]

    tables = [
        ("Linearity Summary", lin_df.to_html(index=False, border=0, classes="summary-table")),
    ]
    build_report(figs, tables, args, conc_order, conc_ng)


if __name__ == "__main__":
    main()
