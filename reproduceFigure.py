"""
python reproduceFigure.py --mq-dda "L:\promec\Animesh\nDDA\MaxQuant\DDA\combined\txt\proteinGroups.txt" --mq-dia "L:\promec\Animesh\nDDA\MaxQuant\DIA\combined\txt\proteinGroups.txt" --diann-dda "L:\promec\Animesh\nDDA\DIANN\DDA\report.DDA9.2p6.pg_matrix.tsv" --diann-dia "L:\promec\Animesh\nDDA\DIANN\DIA\report.DIA9.2p6.pg_matrix.tsv" --tesorai-dda "L:\promec\Animesh\nDDA\tesorAI\DDA\nDDA_quantified_protein_fdr.r.tsv.txt" --tesorai-dia "L:\promec\Animesh\nDDA\tesorAI\DIA\nDIA_quantified_protein_fdr.r.tsv.txt" --conc 1ng,100ng,1ug --min-reps 1 --out reproduceFigure.html

  --min-reps 1  = at least 1 replicate has a value  (most permissive)
  --min-reps 2  = at least 2 of 3 replicates
  --min-reps 3  = all 3 replicates (most stringent)

Reproduce O'Sullivan et al. (2026) Figure 2A-B style plot from raw pipeline outputs:
  Panel A -- protein group counts per concentration, DDA vs DIA, all pipelines
  Panel B -- DIA % gain over DDA per pipeline per concentration

Protein group detection is defined purely by replicate completeness:
  a protein is "detected" at a concentration if it has a quantified value
  (non-zero, non-NaN) in at least --min-reps out of the N replicates
  for that concentration group.

  No MS/MS vs MBR distinction. No software-specific filtering.
  Same rule applied identically to MaxQuant, DIA-NN, and Tesorai.

Paper reference numbers (FragPipe, Orbitrap Astral) are overlaid automatically.
"""

import argparse
import os
import re
import sys
import numpy as np
import pandas as pd
import plotly.graph_objects as go
from plotly.subplots import make_subplots

# ---------------------------------------------------------------------------
# Paper reference (O'Sullivan et al. 2026, Fig 2B, FragPipe)
# ---------------------------------------------------------------------------
PAPER = {
    "FragPipe DDA": {"1ng": 3361, "100ng": 6210, "1ug": 6558},
    "FragPipe nDIA": {"1ng": 4440, "100ng": 7361, "1ug": 7592},
}

# ---------------------------------------------------------------------------
# Colour palette
# ---------------------------------------------------------------------------
COLORS = {
    "MQ DDA":       "#42A5F5",
    "MQ DIA":       "#EF5350",
    "DIA-NN DDA":   "#2E7D32",
    "DIA-NN DIA":   "#81C784",
    "Tesorai DDA":  "#7B1FA2",
    "Tesorai DIA":  "#CE93D8",
    "FragPipe DDA": "#AAAAAA",
    "FragPipe nDIA":"#555555",
}

# ---------------------------------------------------------------------------
# Concentration token normalisation
# MQ uses truncated tokens in column names; we map them to canonical labels
# ---------------------------------------------------------------------------
def norm_token(tok, conc_order):
    """Map a raw column token to the canonical concentration label."""
    tok_l = tok.lower()
    # direct match
    if tok_l in [c.lower() for c in conc_order]:
        return next(c for c in conc_order if c.lower() == tok_l)
    # MQ-specific truncations: try substring match both ways
    for c in conc_order:
        if tok_l in c.lower() or c.lower() in tok_l:
            return c
    return None


# ---------------------------------------------------------------------------
# LOADER: MaxQuant proteinGroups.txt
# Returns dict: conc -> list of per-replicate Intensity columns (not LFQ,
# because LFQ is normalised across runs -- raw Intensity is more comparable
# to what FragPipe IonQuant reports per-file)
# ---------------------------------------------------------------------------
def load_mq(path, conc_order):
    if not path or not os.path.exists(path):
        print(f"  [skip] {path}", file=sys.stderr)
        return None, None

    df = pd.read_csv(path, sep="\t", low_memory=False)

    # standard contaminant / decoy / site filter
    for col in ["Potential contaminant", "Decoy", "Only identified by site"]:
        if col in df.columns:
            df = df[df[col].astype(str) != "+"]
    df = df.reset_index(drop=True)

    # Use raw Intensity columns (not LFQ) -- same per-file signal as IonQuant
    int_cols = [c for c in df.columns
                if re.match(r"^Intensity [^ ]", c) and "_R" in c]

    # group by concentration
    groups = {}   # conc -> [col, ...]
    for col in int_cols:
        tag = col.replace("Intensity ", "")
        m = re.search(r"(100ng|00ng|1ng|ng|1ug|ug)(?:_|$)", tag, re.IGNORECASE)
        if not m:
            continue
        tok = m.group(1)
        conc = norm_token(tok, conc_order)
        if conc:
            groups.setdefault(conc, []).append(col)

    # zero -> NaN
    for cols in groups.values():
        df[cols] = df[cols].replace(0, np.nan).astype(float)

    return df, groups


# ---------------------------------------------------------------------------
# LOADER: DIA-NN pg_matrix (.tsv)
# Columns are full file paths ending in .raw; we extract conc from filename
# ---------------------------------------------------------------------------
def load_diann(path, conc_order):
    if not path or not os.path.exists(path):
        print(f"  [skip] {path}", file=sys.stderr)
        return None, None

    df = pd.read_csv(path, sep="\t")
    raw_cols = [c for c in df.columns if c.endswith(".raw")]

    groups = {}
    for col in raw_cols:
        # extract just the filename from a Windows or Unix path
        fname = col.replace("\\", "/").split("/")[-1]
        m = re.search(r"(1ng|100ng|1ug)", fname, re.IGNORECASE)
        if not m:
            continue
        conc = norm_token(m.group(1), conc_order)
        if conc:
            groups.setdefault(conc, []).append(col)

    df[raw_cols] = df[raw_cols].replace(0, np.nan).astype(float)
    return df, groups


# ---------------------------------------------------------------------------
# LOADER: Tesorai long-format TSV
# One row per protein per file; pivot to wide, group by conc
# ---------------------------------------------------------------------------
def load_tesorai(path, conc_order, quant_col="intensity_IBAQ"):
    if not path or not os.path.exists(path):
        print(f"  [skip] {path}", file=sys.stderr)
        return None, None

    df = pd.read_csv(path, sep="\t")
    if "is_decoy" in df.columns:
        df = df[~df["is_decoy"]].copy()

    # normalise R1_1 -> R1 suffix edge case
    df["file_name"] = df["file_name"].str.replace(
        r"_R(\d+)_\d+\.raw$", r"_R\1.raw", regex=True)

    if quant_col not in df.columns:
        print(f"  [warn] {quant_col} not in Tesorai file, using intensity_IBAQ",
              file=sys.stderr)
        quant_col = "intensity_IBAQ"

    df[quant_col] = df[quant_col].replace(0, np.nan).astype(float)

    # pivot: index=protein_group_id, columns=file_name
    pv = df.pivot_table(
        index="protein_group_id",
        columns="file_name",
        values=quant_col,
        aggfunc="first",
    )

    # group columns by concentration
    groups = {}
    for col in pv.columns:
        fname = str(col).replace("\\", "/").split("/")[-1]
        m = re.search(r"(1ng|100ng|1ug)", fname, re.IGNORECASE)
        if not m:
            continue
        conc = norm_token(m.group(1), conc_order)
        if conc:
            groups.setdefault(conc, []).append(col)

    return pv, groups


# ---------------------------------------------------------------------------
# COUNT: proteins detected in >= min_reps replicates at a concentration
# ---------------------------------------------------------------------------
def count_detected(df, cols, min_reps):
    """Number of rows with >= min_reps non-NaN values across cols."""
    if not cols:
        return 0
    subset = df[cols].copy()
    return int((subset.notna().sum(axis=1) >= min_reps).sum())


# ---------------------------------------------------------------------------
# FIGURES
# ---------------------------------------------------------------------------
def build_figure(counts, conc_order, min_reps, paper_ref=None):
    """
    counts: dict  label -> {conc -> int}
    """
    fig = make_subplots(
        rows=1, cols=2,
        subplot_titles=[
            f"A. Protein Groups Detected<br>"
            f"<sup>(quantified in >= {min_reps} replicate(s) per concentration)</sup>",
            "B. DIA % Gain Over DDA",
        ],
        horizontal_spacing=0.13,
    )

    # ---- Panel A: grouped bars ----
    all_labels = list(counts.keys())
    if paper_ref:
        for lab, d in paper_ref.items():
            all_labels.append(lab)

    for lab in all_labels:
        is_paper = lab in (paper_ref or {})
        d = paper_ref[lab] if is_paper else counts[lab]
        is_dia = "DIA" in lab or "nDIA" in lab
        color = COLORS.get(lab, "#888888")
        fig.add_trace(go.Bar(
            name=lab,
            x=conc_order,
            y=[d.get(c, 0) for c in conc_order],
            marker=dict(
                color=color,
                pattern_shape="/" if is_dia else "",
                pattern_fillmode="overlay",
                opacity=0.6 if is_paper else 1.0,
                line=dict(
                    color="#333333" if is_paper else color,
                    width=2 if is_paper else 0
                ),
            ),
            text=[f"{d.get(c, 0):,}" for c in conc_order],
            textposition="outside",
            textfont=dict(size=8),
            legendgroup=lab,
            legendgrouptitle_text="Paper" if is_paper else None,
        ), row=1, col=1)

    # ---- Panel B: DIA % gain lines ----
    # pair DDA/DIA for each pipeline
    pairs = []
    labels_set = set(counts.keys())
    for dda_lab in [l for l in counts if "DDA" in l]:
        dia_lab = dda_lab.replace("DDA", "DIA")
        if dia_lab in labels_set:
            # derive short name
            short = dda_lab.replace(" DDA", "").replace("-DDA", "")
            pairs.append((short, dda_lab, dia_lab, COLORS.get(dda_lab, "#888")))

    if paper_ref:
        p_dda = paper_ref.get("FragPipe DDA")
        p_dia = paper_ref.get("FragPipe nDIA")
        if p_dda and p_dia:
            pairs.insert(0, ("FragPipe (paper)", "FragPipe DDA", "FragPipe nDIA",
                              COLORS["FragPipe DDA"]))

    for short, dda_lab, dia_lab, color in pairs:
        dda_d = paper_ref.get(dda_lab, {}) if dda_lab in (paper_ref or {}) \
                else counts.get(dda_lab, {})
        dia_d = paper_ref.get(dia_lab, {}) if dia_lab in (paper_ref or {}) \
                else counts.get(dia_lab, {})
        is_paper = dda_lab in (paper_ref or {})
        gains, valid_concs = [], []
        for c in conc_order:
            dda_n = dda_d.get(c, 0)
            dia_n = dia_d.get(c, 0)
            if dda_n > 0:
                gains.append(round((dia_n - dda_n) / dda_n * 100, 1))
                valid_concs.append(c)

        fig.add_trace(go.Scatter(
            x=valid_concs, y=gains,
            mode="lines+markers+text",
            name=short,
            line=dict(
                color=color,
                width=2.5,
            ),
            marker=dict(size=10, symbol="diamond" if is_paper else "circle"),
            text=[f"{g:+.0f}%" for g in gains],
            textposition="top center",
            textfont=dict(size=9),
            legendgroup=short,
            showlegend=True,
        ), row=1, col=2)

    fig.add_hline(y=0, line_color="black",
                  annotation_text="no gain", annotation_font_size=8,
                  row=1, col=2)

    fig.update_yaxes(title_text="Protein groups", row=1, col=1)
    fig.update_yaxes(title_text="DIA gain over DDA (%)", row=1, col=2)
    for col_idx in [1, 2]:
        fig.update_xaxes(title_text="Sample input", row=1, col=col_idx)

    fig.update_layout(
        template="plotly_white",
        height=560,
        barmode="group",
        title=dict(
            text=(
                "Replicating O'Sullivan et al. (2026) Figure 2 -- "
                "MaxQuant / DIA-NN / Tesorai<br>"
                f"<sup>Detection threshold: >= {min_reps} replicate(s) with quantified value. "
                "Paper (FragPipe, Orbitrap Astral) shown as reference (hatched bars / dashed lines).</sup>"
            ),
            font=dict(size=13),
        ),
        legend=dict(
            orientation="h", y=-0.28, x=0.5, xanchor="center",
            font=dict(size=10),
        ),
        margin=dict(t=100, b=150, r=120),
    )
    return fig


# ---------------------------------------------------------------------------
# MAIN
# ---------------------------------------------------------------------------
def parse_args():
    p = argparse.ArgumentParser(description=__doc__,
                                formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("--mq-dda",       default="proteinGroups_DDA.txt")
    p.add_argument("--mq-dia",       default="proteinGroups_DIA.txt")
    p.add_argument("--diann-dda",    default="report_DDA9_2p6_pg_matrix.tsv")
    p.add_argument("--diann-dia",    default="report_DIA9_2p6_pg_matrix.tsv")
    p.add_argument("--tesorai-dda",  default="nDDA_quantified_protein_fdr_r_tsv.txt")
    p.add_argument("--tesorai-dia",  default="nDIA_quantified_protein_fdr_r_tsv.txt")
    p.add_argument("--tesorai-quant",default="intensity_IBAQ",
                   help="Tesorai quant column (intensity_IBAQ / intensity_top3 / "
                        "intensity_uncertainty_aware / intensity_lfq)")
    p.add_argument("--conc",         default="1ng,100ng,1ug",
                   help="Concentration labels low->high, comma-separated")
    p.add_argument("--min-reps",     type=int, default=1,
                   help="Min replicates with a value to count a protein as detected "
                        "(1=any, 2=majority, 3=all). Default: 1")
    p.add_argument("--no-paper",     action="store_true",
                   help="Omit the paper FragPipe reference numbers")
    p.add_argument("--out",          default="reproduceFigure.html")
    return p.parse_args()


def main():
    args = parse_args()
    conc_order = [c.strip() for c in args.conc.split(",")]
    min_reps   = args.min_reps
    n_reps     = 3   # expected replicates per concentration group

    if min_reps < 1 or min_reps > n_reps:
        sys.exit(f"--min-reps must be between 1 and {n_reps}")

    print(f"Detection threshold: >= {min_reps}/{n_reps} replicates")
    print(f"Concentrations: {conc_order}")
    print()

    # ---- load all pipelines ----
    pipelines = {}

    print("Loading MaxQuant DDA...")
    mq_dda_df, mq_dda_grps = load_mq(args.mq_dda, conc_order)
    print("Loading MaxQuant DIA...")
    mq_dia_df, mq_dia_grps = load_mq(args.mq_dia, conc_order)

    print("Loading DIA-NN DDA...")
    dn_dda_df, dn_dda_grps = load_diann(args.diann_dda, conc_order)
    print("Loading DIA-NN DIA...")
    dn_dia_df, dn_dia_grps = load_diann(args.diann_dia, conc_order)

    print(f"Loading Tesorai DDA ({args.tesorai_quant})...")
    ts_dda_df, ts_dda_grps = load_tesorai(
        args.tesorai_dda, conc_order, args.tesorai_quant)
    print(f"Loading Tesorai DIA ({args.tesorai_quant})...")
    ts_dia_df, ts_dia_grps = load_tesorai(
        args.tesorai_dia, conc_order, args.tesorai_quant)

    # ---- count detections ----
    def count_all(df, groups):
        if df is None or groups is None:
            return {}
        return {c: count_detected(df, groups.get(c, []), min_reps)
                for c in conc_order}

    counts = {
        "MQ DDA":      count_all(mq_dda_df, mq_dda_grps),
        "MQ DIA":      count_all(mq_dia_df, mq_dia_grps),
        "DIA-NN DDA":  count_all(dn_dda_df, dn_dda_grps),
        "DIA-NN DIA":  count_all(dn_dia_df, dn_dia_grps),
        "Tesorai DDA": count_all(ts_dda_df, ts_dda_grps),
        "Tesorai DIA": count_all(ts_dia_df, ts_dia_grps),
    }
    # drop pipelines where all counts are zero (file not provided)
    counts = {k: v for k, v in counts.items() if any(n > 0 for n in v.values())}

    # ---- print table ----
    print(f"\n{'Pipeline':20s}", "  ".join(f"{c:>8s}" for c in conc_order))
    print("-" * (20 + 11 * len(conc_order)))
    if not args.no_paper:
        for lab, d in PAPER.items():
            print(f"{'  '+lab:20s}", "  ".join(f"{d.get(c,0):>8,}" for c in conc_order))
        print()
    for lab, d in counts.items():
        print(f"{lab:20s}", "  ".join(f"{d.get(c,0):>8,}" for c in conc_order))

    print(f"\n{'Pipeline':20s}", "  ".join(f"{c:>9s}" for c in conc_order),
          "  (DIA % gain over DDA)")
    print("-" * (20 + 12 * len(conc_order)))
    if not args.no_paper:
        p_dda = PAPER["FragPipe DDA"]
        p_dia = PAPER["FragPipe nDIA"]
        gains = [f"{(p_dia[c]-p_dda[c])/p_dda[c]*100:>+8.1f}%"
                 if p_dda.get(c, 0) > 0 else "       -"
                 for c in conc_order]
        print(f"  FragPipe (paper):  ", "  ".join(gains))
    for dda_lab, dia_lab in [("MQ DDA","MQ DIA"),
                               ("DIA-NN DDA","DIA-NN DIA"),
                               ("Tesorai DDA","Tesorai DIA")]:
        if dda_lab not in counts or dia_lab not in counts:
            continue
        gains = []
        for c in conc_order:
            dda_n = counts[dda_lab].get(c, 0)
            dia_n = counts[dia_lab].get(c, 0)
            gains.append(f"{(dia_n-dda_n)/dda_n*100:>+8.1f}%"
                         if dda_n > 0 else "       -")
        print(f"{dda_lab.replace(' DDA',''):20s}", "  ".join(gains))

    # ---- build and save figure ----
    paper_ref = None if args.no_paper else PAPER
    fig = build_figure(counts, conc_order, min_reps, paper_ref=paper_ref)
    fig.write_html(args.out, include_plotlyjs="cdn")
    print(f"\nFigure written: {args.out}")


if __name__ == "__main__":
    main()
