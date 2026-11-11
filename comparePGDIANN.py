"""
compare_diann.py  <root_path>

Finds all DIANN* subfolders in root_path, reads every report*pg*matrix*.tsv
inside them, runs a comprehensive comparison, and writes a PDF report to
root_path/diann_comparison_report.pdf and a summary TSV alongside it.

Usage:
  python comparePGDIANN.py F:\\promec\\TIMSTOF\\LARS\\2026\\261026_Paola
"""

import sys, os, re, glob, warnings
from datetime import datetime
from pathlib import Path
from collections import defaultdict

import numpy as np
import pandas as pd
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
from matplotlib.backends.backend_pdf import PdfPages
from matplotlib.patches import Patch
import seaborn as sns
from scipy import stats
from scipy.cluster.hierarchy import dendrogram, linkage
from sklearn.decomposition import PCA
from sklearn.preprocessing import StandardScaler

warnings.filterwarnings("ignore")

# ── Styling ──────────────────────────────────────────────────────────────────
PALETTE  = ["#2196F3","#F44336","#4CAF50","#FF9800","#9C27B0",
            "#00BCD4","#795548","#607D8B","#E91E63","#009688"]
GREY     = "#EEEEEE"
DARKGREY = "#424242"
sns.set_style("whitegrid")
plt.rcParams.update({
    "font.family": "DejaVu Sans",
    "font.size": 8,
    "axes.titlesize": 9,
    "axes.labelsize": 8,
    "legend.fontsize": 7,
    "figure.dpi": 120,
})

# ── Helpers ───────────────────────────────────────────────────────────────────
def parse_params(folder_name, file_name):
    """Extract DIA-NN parameters from folder and file names."""
    p = {}
    # from filename
    for key, pat in [
        ("fr_min",   r"min-fr-mz-(\d+)"),
        ("fr_max",   r"max-fr-mz-(\d+)"),
        ("pr_min",   r"min-pr-mz-(\d+)"),
        ("pr_max",   r"max-pr-mz-(\d+)"),
        ("mass_acc", r"mass-acc-(\d+)_(\d+)_mass-acc-ms1"),
        ("ms1_acc",  r"mass-acc-ms1-(\d+)"),
    ]:
        m = re.search(pat, file_name)
        if m:
            if key == "mass_acc":
                p[key] = float(f"{m.group(1)}.{m.group(2)}")
            else:
                p[key] = int(m.group(1))
    # from folder name: DIANNv2P2.19.261109_125351.64.highacc
    m = re.search(r"DIANNv?([\d.P]+)[._](\d{6}_\d{6})[._](\d+)", folder_name, re.I)
    if m:
        p["version"]  = m.group(1)
        p["datetime"] = m.group(2)
        p["threads"]  = m.group(3)
    p["high_acc"] = "highacc" in folder_name.lower()
    return p

def short_label(folder_name, params):
    """Short label for plots."""
    fr  = f"fr{params.get('fr_min','?')}-{params.get('fr_max','?')}"
    pr  = f"pr{params.get('pr_min','?')}-{params.get('pr_max','?')}"
    acc = f"acc{params.get('mass_acc','?')}"
    dt  = params.get("datetime", folder_name[-12:])
    return f"{dt}\n{fr}/{pr}/{acc}"

def sample_name(col):
    """Strip path and slot info from sample column name."""
    base = Path(col).stem                        # remove .d
    base = re.sub(r"_Slot\d+-\d+_\d+_\d+$", "", base)  # remove slot suffix
    # remove common prefix (longest shared leading substring)
    return base

def strip_common_prefix(names):
    """Remove longest common prefix from a list of strings."""
    if not names:
        return names
    prefix = os.path.commonprefix(names)
    # trim to last underscore boundary
    cut = prefix.rfind("_")
    if cut > 0:
        prefix = prefix[:cut+1]
    return [n[len(prefix):] if n.startswith(prefix) else n for n in names]

def log2_matrix(df, cols):
    """Return log2 intensity matrix, NaN where missing or <= 0."""
    m = df[cols].copy().astype(float)
    m[m <= 0] = np.nan
    return np.log2(m)

def mean_log2(df, cols):
    """Per-protein mean log2 intensity across samples."""
    return log2_matrix(df, cols).mean(axis=1, skipna=True)

def add_page_header(fig, title, subtitle=""):
    fig.text(0.5, 0.97, title,  ha="center", va="top",
             fontsize=12, fontweight="bold", color=DARKGREY)
    if subtitle:
        fig.text(0.5, 0.945, subtitle, ha="center", va="top",
                 fontsize=8, color="#757575")

def fig_save(pdf, fig):
    pdf.savefig(fig, bbox_inches="tight")
    plt.close(fig)

def render_table(ax, df, col_widths=None, fontsize=7):
    ax.axis("off")
    if df.empty:
        return
    tbl = ax.table(
        cellText  = df.values,
        colLabels = df.columns,
        cellLoc   = "center",
        loc       = "center",
    )
    tbl.auto_set_font_size(False)
    tbl.set_fontsize(fontsize)
    if col_widths:
        for (r, c), cell in tbl.get_celld().items():
            if c < len(col_widths):
                cell.set_width(col_widths[c])
    # header style
    for c in range(len(df.columns)):
        tbl[(0, c)].set_facecolor("#1565C0")
        tbl[(0, c)].set_text_props(color="white", fontweight="bold")
    # alternating rows
    for r in range(1, len(df)+1):
        for c in range(len(df.columns)):
            tbl[(r, c)].set_facecolor("#E3F2FD" if r % 2 == 0 else "white")
    tbl.scale(1, 1.3)

# ── Data loading ──────────────────────────────────────────────────────────────
def find_and_load(root):
    root = Path(root)
    runs = {}
    for folder in sorted(root.glob("DIANN*")):
        if not folder.is_dir():
            continue
        # try both naming conventions: report_pg_matrix* and report.pg_matrix*
        tsvs = sorted(list(folder.glob("report*pg*matrix*.tsv")) +
                      list(folder.glob("report.pg_matrix*.tsv")))
        if not tsvs:
            print(f"  no pg_matrix TSV in {folder.name}, skipping")
            continue
        tsv = tsvs[0]
        print(f"  loading {folder.name}/{tsv.name}")
        try:
            df = pd.read_csv(tsv, sep="\t")
        except Exception as e:
            print(f"  ERROR reading {tsv}: {e}")
            continue
        params = parse_params(folder.name, tsv.name)
        label  = short_label(folder.name, params)
        runs[folder.name] = {
            "df":      df,
            "params":  params,
            "label":   label,
            "folder":  folder.name,
            "file":    tsv.name,
            "scols":   [c for c in df.columns if c.endswith(".d")],
        }
    return runs

# ── Individual pages ──────────────────────────────────────────────────────────

def page_cover(pdf, root, runs):
    fig = plt.figure(figsize=(11, 8.5))
    fig.patch.set_facecolor("#1565C0")
    fig.text(0.5, 0.75, "DIA-NN Multi-Run Comparison Report",
             ha="center", va="center", fontsize=22, fontweight="bold", color="white")
    fig.text(0.5, 0.65, str(root),
             ha="center", va="center", fontsize=10, color="#BBDEFB")
    fig.text(0.5, 0.58, f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M')}",
             ha="center", va="center", fontsize=9, color="#90CAF9")
    fig.text(0.5, 0.50, f"Runs compared: {len(runs)}",
             ha="center", va="center", fontsize=11, color="white")
    for i, (fname, r) in enumerate(runs.items()):
        fig.text(0.5, 0.42 - i*0.045,
                 f"  {fname}  |  {r['file']}",
                 ha="center", va="center", fontsize=8, color="#E3F2FD")
    fig_save(pdf, fig)


def page_summary_table(pdf, runs):
    rows = []
    for fname, r in runs.items():
        p   = r["params"]
        df  = r["df"]
        sc  = r["scols"]
        per_s = df[sc].notna().sum()
        total = len(df)*len(sc)
        nans  = df[sc].isna().sum().sum()
        rows.append({
            "Folder":       fname,
            "PGs":          len(df),
            "Samples":      len(sc),
            "fr m/z":       f"{p.get('fr_min','?')}-{p.get('fr_max','?')}",
            "pr m/z":       f"{p.get('pr_min','?')}-{p.get('pr_max','?')}",
            "MS2 acc":      p.get("mass_acc","?"),
            "MS1 acc":      p.get("ms1_acc","?"),
            "High-acc":     "yes" if p.get("high_acc") else "no",
            "Threads":      p.get("threads","?"),
            "Mean/samp":    f"{per_s.mean():.0f}",
            "Missing %":    f"{100*nans/total:.1f}",
            "Med log2":     f"{np.nanmedian(np.log2(df[sc].replace(0,np.nan).values.flatten())):.2f}",
        })
    tdf = pd.DataFrame(rows)
    fig, ax = plt.subplots(figsize=(17, max(3, 1 + len(rows)*0.6)))
    add_page_header(fig, "Run Summary", "One row per DIANN* folder found")
    render_table(ax, tdf, fontsize=6.5)
    fig_save(pdf, fig)


def page_protein_counts(pdf, runs, colors):
    labels  = [r["label"] for r in runs.values()]
    pg_cnts = [len(r["df"]) for r in runs.values()]
    means   = [r["df"][r["scols"]].notna().sum().mean() for r in runs.values()]
    complete= [int(r["df"][r["scols"]].notna().all(axis=1).sum()) for r in runs.values()]

    fig, axes = plt.subplots(1, 3, figsize=(14, 5))
    add_page_header(fig, "Protein Group Counts & Per-Sample Depth")

    for ax, vals, title, ylabel in zip(
        axes,
        [pg_cnts, means, complete],
        ["Total protein groups", "Mean proteins per sample",
         f"Complete (all {list(runs.values())[0]['df'][list(runs.values())[0]['scols']].shape[1]} samples)"],
        ["Protein groups","Proteins","Protein groups"],
    ):
        bars = ax.bar(range(len(labels)), vals, color=colors[:len(labels)], edgecolor="white", width=0.6)
        ax.set_xticks(range(len(labels)))
        ax.set_xticklabels(labels, fontsize=6.5, rotation=0, ha="center")
        ax.set_title(title, fontsize=9)
        ax.set_ylabel(ylabel)
        for bar, v in zip(bars, vals):
            ax.text(bar.get_x()+bar.get_width()/2, bar.get_height()+2,
                    f"{v:.0f}", ha="center", va="bottom", fontsize=7)
        ymin = min(vals)*0.90
        ax.set_ylim(ymin, max(vals)*1.08)

    fig.tight_layout(rect=[0,0,1,0.93])
    fig_save(pdf, fig)


def page_per_sample_depth(pdf, runs, colors):
    """Per-sample quantified protein count, all runs overlaid."""
    fig, ax = plt.subplots(figsize=(14, 5))
    add_page_header(fig, "Per-Sample Quantified Proteins")

    all_snames = None
    for i, (fname, r) in enumerate(runs.items()):
        sc   = r["scols"]
        vals = r["df"][sc].notna().sum().values
        raw  = [sample_name(c) for c in sc]
        if all_snames is None:
            all_snames = strip_common_prefix(raw)
        ax.plot(range(len(vals)), vals, color=colors[i], marker="o",
                markersize=4, linewidth=1.5, label=r["label"].replace("\n"," "))
    if all_snames:
        ax.set_xticks(range(len(all_snames)))
        ax.set_xticklabels(all_snames, rotation=45, ha="right", fontsize=7)
    ax.set_ylabel("Proteins quantified")
    ax.set_xlabel("Sample")
    ax.legend(fontsize=7, loc="lower right")
    fig.tight_layout(rect=[0,0,1,0.93])
    fig_save(pdf, fig)


def page_missing_heatmap(pdf, runs, colors):
    """Heatmap of missing values per sample per run."""
    n = len(runs)
    fig, axes = plt.subplots(1, n, figsize=(4*n, 7), sharey=False)
    if n == 1:
        axes = [axes]
    add_page_header(fig, "Missing Values per Sample",
                    "Dark = quantified, light = missing")

    for ax, (fname, r), col in zip(axes, runs.items(), colors):
        sc  = r["scols"]
        mat = r["df"][sc].notna().astype(int)
        raw = [sample_name(c) for c in sc]
        snames = strip_common_prefix(raw)
        mat.columns = snames
        sns.heatmap(mat.T, ax=ax, cmap="Blues", vmin=0, vmax=1,
                    cbar=False, xticklabels=False, yticklabels=True)
        ax.set_title(r["label"], fontsize=7)
        ax.tick_params(axis="y", labelsize=6)
        ax.set_xlabel(f"{mat.shape[0]} proteins", fontsize=7)

    fig.tight_layout(rect=[0,0,1,0.93])
    fig_save(pdf, fig)


def page_intensity_distribution(pdf, runs, colors):
    """Box plots of log2 intensities per sample per run."""
    fig, axes = plt.subplots(len(runs), 1,
                             figsize=(14, 3*len(runs)), sharex=False)
    if len(runs) == 1:
        axes = [axes]
    add_page_header(fig, "Log2 Intensity Distributions per Sample")

    for ax, (fname, r), col in zip(axes, runs.items(), colors):
        sc   = r["scols"]
        data = [r["df"][c].replace(0, np.nan).dropna().pipe(np.log2).values
                for c in sc]
        raw    = [sample_name(c) for c in sc]
        snames = strip_common_prefix(raw)
        bplot  = ax.boxplot(data, patch_artist=True, notch=False,
                            medianprops=dict(color="white", linewidth=1.5),
                            whiskerprops=dict(color="#9E9E9E"),
                            capprops=dict(color="#9E9E9E"),
                            flierprops=dict(marker=".", markersize=1,
                                           color="#BDBDBD", alpha=0.3))
        for patch in bplot["boxes"]:
            patch.set_facecolor(col)
            patch.set_alpha(0.7)
        ax.set_xticks(range(1, len(snames)+1))
        ax.set_xticklabels(snames, rotation=45, ha="right", fontsize=6)
        ax.set_ylabel("log2 intensity", fontsize=7)
        ax.set_title(r["label"].replace("\n"," "), fontsize=7, color=col)

    fig.tight_layout(rect=[0,0,1,0.95])
    fig_save(pdf, fig)


def page_pairwise_corr(pdf, runs, colors):
    """Pairwise correlation of mean log2 intensity on common proteins."""
    keys  = list(runs.keys())
    lbls  = [r["label"].replace("\n"," ") for r in runs.values()]

    # Build mean log2 per protein per run
    series = {}
    for fname, r in runs.items():
        df_g = r["df"].drop_duplicates("Genes").set_index("Genes")
        s = mean_log2(df_g, r["scols"])
        s = s[~s.index.duplicated(keep="first")]  # Ensure unique index labels
        s.name = fname
        series[fname] = s
    
    combined = pd.DataFrame(series).dropna()
    n = len(keys)
    fig, axes = plt.subplots(n, n, figsize=(3*n, 3*n))
    add_page_header(fig, f"Pairwise Correlations (n={len(combined)} common proteins)")

    for i, ki in enumerate(keys):
        for j, kj in enumerate(keys):
            ax = axes[i][j] if n > 1 else axes
            if i == j:
                ax.hist(combined[ki].dropna(), bins=40,
                        color=colors[i], alpha=0.7, edgecolor="none")
                ax.set_title(lbls[i], fontsize=6.5)
            else:
                x = combined[kj].dropna()
                y = combined[ki].dropna()
                idx = x.index.intersection(y.index)
                r_val, _ = stats.pearsonr(x[idx], y[idx])
                ax.scatter(x[idx], y[idx], s=2, alpha=0.3,
                           color=colors[i], rasterized=True)
                ax.text(0.05, 0.92, f"r={r_val:.4f}",
                        transform=ax.transAxes, fontsize=7,
                        color="black", fontweight="bold")
                slope, intercept, *_ = stats.linregress(x[idx], y[idx])
                xl = np.array([x[idx].min(), x[idx].max()])
                ax.plot(xl, slope*xl+intercept, "r-", linewidth=0.8, alpha=0.6)
            ax.tick_params(labelsize=5)
            if i == n-1:
                ax.set_xlabel(lbls[j], fontsize=6)
            if j == 0:
                ax.set_ylabel(lbls[i], fontsize=6)

    fig.tight_layout(rect=[0,0,1,0.95])
    fig_save(pdf, fig)


def page_pca(pdf, runs, colors):
    """PCA of samples, all runs overlaid; colour=run, marker=sample."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    add_page_header(fig, "PCA of Samples (log2 intensities, common proteins)")

    # Build joint matrix: rows=samples, cols=common proteins
    all_genes = None
    for r in runs.values():
        g = set(r["df"]["Genes"].dropna())
        all_genes = g if all_genes is None else all_genes & g
    all_genes = sorted(all_genes)

    mats, run_labels, samp_labels, run_indices = [], [], [], []
    for ridx, (fname, r) in enumerate(runs.items()):
        sub = r["df"][r["df"]["Genes"].isin(all_genes)].drop_duplicates("Genes").set_index("Genes")
        log2_m = np.log2(sub[r["scols"]].replace(0, np.nan))
        log2_m = log2_m.reindex(all_genes)
        raw = [sample_name(c) for c in r["scols"]]
        for s, col in zip(strip_common_prefix(raw), r["scols"]):
            vec = log2_m[col].values
            mats.append(vec)
            run_labels.append(fname)
            samp_labels.append(s)
            run_indices.append(ridx)

    X = np.array(mats)
    # impute missing with column mean
    col_means = np.nanmean(X, axis=0)
    for i in range(X.shape[1]):
        X[np.isnan(X[:, i]), i] = col_means[i]
    X = StandardScaler().fit_transform(X)

    pca  = PCA(n_components=min(5, X.shape[0]-1))
    Xpc  = pca.fit_transform(X)
    var  = pca.explained_variance_ratio_ * 100

    for ax_idx, (pc_x, pc_y) in enumerate([(0,1),(0,2)]):
        ax = axes[ax_idx]
        for ridx, (fname, r) in enumerate(runs.items()):
            mask = np.array(run_indices) == ridx
            ax.scatter(Xpc[mask, pc_x], Xpc[mask, pc_y],
                       color=colors[ridx], s=40, alpha=0.85,
                       label=r["label"].replace("\n"," "), edgecolors="white", linewidths=0.4)
            for xi, yi, lab in zip(Xpc[mask, pc_x], Xpc[mask, pc_y],
                                   np.array(samp_labels)[mask]):
                ax.annotate(lab, (xi, yi), fontsize=5, alpha=0.7,
                            xytext=(2,2), textcoords="offset points")
        ax.set_xlabel(f"PC{pc_x+1} ({var[pc_x]:.1f}%)")
        ax.set_ylabel(f"PC{pc_y+1} ({var[pc_y]:.1f}%)")
        ax.set_title(f"PC{pc_x+1} vs PC{pc_y+1}")
        if ax_idx == 0:
            ax.legend(fontsize=6, loc="best")

    fig.tight_layout(rect=[0,0,1,0.93])
    fig_save(pdf, fig)


def page_set_overlap(pdf, runs, colors):
    """UpSet-style protein set overlap."""
    keys   = list(runs.keys())
    lbls   = [r["label"].replace("\n"," ") for r in runs.values()]
    gsets  = {k: set(r["df"]["Genes"].dropna()) for k, r in runs.items()}
    n      = len(keys)

    # All 2^n - 1 non-empty subsets
    from itertools import combinations
    all_genes = set.union(*gsets.values())

    # membership matrix
    membership = {}
    for g in all_genes:
        membership[g] = tuple(g in gsets[k] for k in keys)

    counts = defaultdict(int)
    for combo in membership.values():
        counts[combo] += 1

    # Sort by count descending, show top 20
    sorted_combos = sorted(counts.items(), key=lambda x: -x[1])[:20]

    fig = plt.figure(figsize=(14, 7))
    add_page_header(fig, "Protein Set Membership",
                    "Each column = one intersection category; bottom = which runs contribute")

    gs = gridspec.GridSpec(2, 1, figure=fig, height_ratios=[2, 1],
                           hspace=0.05, top=0.90, bottom=0.15)
    ax_bar  = fig.add_subplot(gs[0])
    ax_dots = fig.add_subplot(gs[1], sharex=ax_bar)

    bar_vals   = [c[1] for c in sorted_combos]
    combos_arr = [c[0] for c in sorted_combos]

    bar_colors = []
    for combo in combos_arr:
        active = [colors[i] for i, v in enumerate(combo) if v]
        bar_colors.append(active[0] if len(active)==1 else "#607D8B")

    ax_bar.bar(range(len(bar_vals)), bar_vals, color=bar_colors,
               edgecolor="white", width=0.6)
    for x, v in enumerate(bar_vals):
        ax_bar.text(x, v+1, str(v), ha="center", va="bottom", fontsize=6)
    ax_bar.set_ylabel("Protein groups")
    ax_bar.set_xticks([])
    ax_bar.set_title("")

    # Dot matrix
    for col_i, combo in enumerate(combos_arr):
        for row_i, active in enumerate(combo):
            ax_dots.scatter(col_i, row_i,
                            color=colors[row_i] if active else GREY,
                            s=60, zorder=3)
        # connect active dots
        active_rows = [i for i, v in enumerate(combo) if v]
        if len(active_rows) > 1:
            ax_dots.plot([col_i]*len(active_rows), active_rows,
                         color="#424242", linewidth=1.5, zorder=2)

    ax_dots.set_yticks(range(n))
    ax_dots.set_yticklabels(lbls, fontsize=6.5)
    ax_dots.set_xticks(range(len(sorted_combos)))
    ax_dots.set_xticklabels([""]* len(sorted_combos))
    ax_dots.set_xlim(-0.5, len(sorted_combos)-0.5)
    ax_dots.set_ylim(-0.5, n-0.5)
    ax_dots.grid(False)
    ax_dots.set_facecolor("white")

    # Legend
    patches = [Patch(color=colors[i], label=lbls[i]) for i in range(n)]
    fig.legend(handles=patches, loc="lower center",
               ncol=min(4, n), fontsize=6.5, frameon=True,
               bbox_to_anchor=(0.5, 0.02))

    fig_save(pdf, fig)


def page_unique_proteins(pdf, runs):
    """Table of proteins unique to each run."""
    keys  = list(runs.keys())
    gsets = {k: set(r["df"]["Genes"].dropna()) for k, r in runs.items()}

    fig, axes = plt.subplots(1, len(keys),
                             figsize=(5*len(keys), max(5, 2+len(keys)*0.5)))
    if len(keys) == 1:
        axes = [axes]
    add_page_header(fig, "Proteins Unique to Each Run (not in any other)")

    for ax, (k, r) in zip(axes, runs.items()):
        others = set.union(*[gsets[j] for j in keys if j != k])
        unique = sorted(gsets[k] - others)
        if not unique:
            ax.axis("off")
            ax.set_title(r["label"].replace("\n"," "), fontsize=7)
            ax.text(0.5, 0.5, "None", ha="center", va="center",
                    transform=ax.transAxes, fontsize=8)
            continue
        sub = r["df"][r["df"]["Genes"].isin(unique)][
            ["Genes","First.Protein.Description","N.Sequences","N.Proteotypic.Sequences"]
        ].copy()
        sub["N.Seq"] = sub["N.Sequences"].astype(int)
        sub["Desc"]  = sub["First.Protein.Description"].str[:35]
        tbl_df = sub[["Genes","Desc","N.Seq"]].rename(
            columns={"Genes":"Gene","Desc":"Description","N.Seq":"N.Seq"})
        ax.axis("off")
        ax.set_title(f"{r['label'].replace(chr(10),' ')} (n={len(unique)})", fontsize=7)
        render_table(ax, tbl_df.head(30), fontsize=6)

    fig.tight_layout(rect=[0,0,1,0.93])
    fig_save(pdf, fig)


def page_concordance_scatter(pdf, runs, colors):
    """All-pairs scatter: mean log2 of common proteins."""
    keys = list(runs.keys())
    n    = len(keys)
    if n < 2:
        return

    # mean log2 per protein per run
    series = {}
    for k, r in runs.items():
        df_g = r["df"].drop_duplicates("Genes").set_index("Genes")
        series[k] = mean_log2(df_g, r["scols"])

    pairs = [(i, j) for i in range(n) for j in range(i+1, n)]
    ncols = min(3, len(pairs))
    nrows = (len(pairs) + ncols - 1) // ncols
    fig, axes = plt.subplots(nrows, ncols,
                             figsize=(5*ncols, 4.5*nrows))
    axes = np.array(axes).flatten() if len(pairs) > 1 else [axes]
    add_page_header(fig, "Pairwise Scatter: Mean Log2 Intensity (common proteins)")

    for idx, (i, j) in enumerate(pairs):
        ax  = axes[idx]
        ki, kj = keys[i], keys[j]
        x   = series[ki]
        y   = series[kj]
        idx2 = x.dropna().index.intersection(y.dropna().index)
        xv, yv = x[idx2].values, y[idx2].values
        # density colouring
        ax.scatter(xv, yv, s=3, alpha=0.3, color="#607D8B", rasterized=True)
        r_val, _ = stats.pearsonr(xv, yv)
        slope, intercept, *_ = stats.linregress(xv, yv)
        xl = np.array([xv.min(), xv.max()])
        ax.plot(xl, slope*xl+intercept, "r-", linewidth=1, alpha=0.7)
        ax.plot(xl, xl, "k--", linewidth=0.6, alpha=0.4)
        # MA lines
        diff = yv - xv
        ax.text(0.03, 0.95, f"r={r_val:.4f}", transform=ax.transAxes,
                fontsize=7, va="top", fontweight="bold")
        ax.text(0.03, 0.88, f"median Δ={np.median(diff):+.3f} log2",
                transform=ax.transAxes, fontsize=6.5, va="top")
        ax.text(0.03, 0.82, f"n={len(idx2)}", transform=ax.transAxes,
                fontsize=6, va="top", color="#757575")
        ax.set_xlabel(runs[ki]["label"].replace("\n"," "), fontsize=6.5)
        ax.set_ylabel(runs[kj]["label"].replace("\n"," "), fontsize=6.5)

    for ax in axes[len(pairs):]:
        ax.axis("off")

    fig.tight_layout(rect=[0,0,1,0.93])
    fig_save(pdf, fig)


def page_ma_plots(pdf, runs, colors):
    """MA plots (M = log2 ratio, A = mean log2) for all pairs vs first run."""
    keys  = list(runs.keys())
    if len(keys) < 2:
        return
    ref_k = keys[0]
    ref_r = runs[ref_k]
    ref_df = ref_r["df"].drop_duplicates("Genes").set_index("Genes")
    ref_ml = mean_log2(ref_df, ref_r["scols"])

    comparisons = [(k, runs[k]) for k in keys[1:]]
    ncols = min(3, len(comparisons))
    nrows = (len(comparisons) + ncols - 1) // ncols
    fig, axes = plt.subplots(nrows, ncols,
                             figsize=(5*ncols, 4*nrows))
    axes = np.array(axes).flatten() if len(comparisons) > 1 else [axes]
    add_page_header(fig, f"MA Plots (reference = {ref_r['label'].replace(chr(10),' ')})",
                    "M = log2(run / reference), A = mean log2")

    for idx, (k, r) in enumerate(comparisons):
        ax  = axes[idx]
        df2 = r["df"].drop_duplicates("Genes").set_index("Genes")
        ml2 = mean_log2(df2, r["scols"])
        common_idx = ref_ml.dropna().index.intersection(ml2.dropna().index)
        A = (ref_ml[common_idx].values + ml2[common_idx].values) / 2
        M = ml2[common_idx].values - ref_ml[common_idx].values
        ax.scatter(A, M, s=3, alpha=0.3, color=colors[idx+1], rasterized=True)
        ax.axhline(0,   color="black", linewidth=0.8, linestyle="--")
        ax.axhline(np.median(M), color="red", linewidth=1, linestyle="-",
                   label=f"median={np.median(M):+.3f}")
        ax.set_xlabel("A (mean log2)", fontsize=7)
        ax.set_ylabel("M (log2 ratio)", fontsize=7)
        ax.set_title(r["label"].replace("\n"," "), fontsize=7)
        ax.legend(fontsize=6)

    for ax in axes[len(comparisons):]:
        ax.axis("off")

    fig.tight_layout(rect=[0,0,1,0.93])
    fig_save(pdf, fig)


def page_top_diff_proteins(pdf, runs, colors):
    """Top proteins with largest mean log2 difference between any two runs."""
    keys = list(runs.keys())
    if len(keys) < 2:
        return

    series = {}
    descs  = {}
    for k, r in runs.items():
        # Drop rows with missing gene names before setting index
        df_valid = r["df"].dropna(subset=["Genes"]).copy()
        df_g = df_valid.drop_duplicates("Genes").set_index("Genes")
        s = mean_log2(df_g, r["scols"])
        # Ensure index contains only valid, non-null string identifiers
        s = s[s.index.notna()]
        s.index = s.index.astype(str)
        series[k] = s
        descs.update(df_g["First.Protein.Description"].dropna().to_dict())

    all_genes = sorted(set.union(*[set(s.dropna().index) for s in series.values()]))

    rows = []
    for gene in all_genes:
        vals = {k: series[k].get(gene, np.nan) for k in keys}
        present = [v for v in vals.values() if not np.isnan(v)]
        if len(present) < 2:
            continue
        max_diff = max(present) - min(present)
        rows.append({
            "gene":     gene,
            "max_diff": max_diff,
            "desc":     str(descs.get(gene,""))[:50],
            **{k: f"{vals[k]:.2f}" if not np.isnan(vals[k]) else "—"
               for k in keys},
        })

    df_top = pd.DataFrame(rows).sort_values("max_diff", ascending=False).head(40)

    # Plot
    fig, (ax_bar, ax_tbl) = plt.subplots(1, 2, figsize=(17, 9),
                                          gridspec_kw={"width_ratios":[1,2]})
    add_page_header(fig, "Top 40 Proteins by Max Log2 Difference Across Runs")

    top20 = df_top.head(20)
    lbls  = [r["label"].replace("\n"," ") for r in runs.values()]
    x     = np.arange(len(top20))
    width = 0.8 / len(keys)
    for i, k in enumerate(keys):
        vals2 = top20[k].replace("—", np.nan).astype(float)
        ax_bar.bar(x + i*width, vals2, width, color=colors[i],
                   alpha=0.8, label=lbls[i])
    ax_bar.set_xticks(x + width*(len(keys)-1)/2)
    ax_bar.set_xticklabels(top20["gene"], rotation=60, ha="right", fontsize=6)
    ax_bar.set_ylabel("Mean log2 intensity")
    ax_bar.set_title("Top 20 by max diff (bar)")
    ax_bar.legend(fontsize=6)

    tbl_df = df_top[["gene","desc","max_diff"] + list(keys)].copy()
    tbl_df["max_diff"] = tbl_df["max_diff"].round(2)
    tbl_df.columns = (["Gene","Description","MaxΔlog2"] +
                      [r["label"].replace("\n"," ")[:18] for r in runs.values()])
    render_table(ax_tbl, tbl_df.reset_index(drop=True), fontsize=5.5)
    ax_tbl.set_title("Top 40 (table)")

    fig.tight_layout(rect=[0,0,1,0.93])
    fig_save(pdf, fig)


def page_concordance_summary(pdf, runs):
    """% proteins within X log2 threshold for all pairwise comparisons."""
    keys = list(runs.keys())
    if len(keys) < 2:
        return
    lbls = [r["label"].replace("\n"," ") for r in runs.values()]

    series = {}
    for k, r in runs.items():
        df_g = r["df"].drop_duplicates("Genes").set_index("Genes")
        series[k] = mean_log2(df_g, r["scols"])

    thresholds = [0.1, 0.25, 0.5, 1.0, 2.0]
    pairs      = [(i,j) for i in range(len(keys)) for j in range(i+1,len(keys))]

    rows_data = []
    for i, j in pairs:
        ki, kj = keys[i], keys[j]
        idx    = series[ki].dropna().index.intersection(series[kj].dropna().index)
        diff   = (series[ki][idx] - series[kj][idx]).abs()
        row    = {"Comparison": f"{lbls[i][:20]} vs {lbls[j][:20]}", "n": len(diff)}
        for t in thresholds:
            row[f"<{t}log2"] = f"{100*(diff<t).mean():.1f}%"
        rows_data.append(row)

    tdf = pd.DataFrame(rows_data)

    fig, ax = plt.subplots(figsize=(14, max(3, 1.5+len(rows_data)*0.5)))
    add_page_header(fig, "Quantitative Concordance Between Runs",
                    "% of common proteins within X log2 of each other")
    render_table(ax, tdf, fontsize=7)
    fig.tight_layout(rect=[0,0,1,0.93])
    fig_save(pdf, fig)


def page_cv_analysis(pdf, runs, colors):
    """Coefficient of variation per protein across samples, per run."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    add_page_header(fig, "Coefficient of Variation (CV) Across Samples",
                    "Computed on linear intensities; lower = more reproducible")

    lbls = [r["label"].replace("\n"," ") for r in runs.values()]

    cv_data = []
    for k, r in runs.items():
        mat = r["df"][r["scols"]].replace(0, np.nan)
        cv  = (mat.std(axis=1) / mat.mean(axis=1) * 100).dropna()
        cv_data.append(cv.values)

    # Violin
    parts = axes[0].violinplot(cv_data, positions=range(len(cv_data)),
                               showmedians=True, showextrema=False)
    for body, col in zip(parts["bodies"], colors):
        body.set_facecolor(col)
        body.set_alpha(0.7)
    parts["cmedians"].set_color("white")
    axes[0].set_xticks(range(len(lbls)))
    axes[0].set_xticklabels(lbls, fontsize=6.5)
    axes[0].set_ylabel("CV (%)")
    axes[0].set_title("Distribution of per-protein CV")

    # CDF
    for cv, col, lbl in zip(cv_data, colors, lbls):
        s = np.sort(cv)
        axes[1].plot(s, np.arange(len(s))/len(s)*100,
                     color=col, linewidth=1.5, label=lbl)
    axes[1].set_xlabel("CV (%)")
    axes[1].set_ylabel("Cumulative %")
    axes[1].set_title("CDF of per-protein CV")
    axes[1].set_xlim(0, 100)
    axes[1].legend(fontsize=6)
    axes[1].axvline(20, color="grey", linestyle="--", linewidth=0.8, alpha=0.7)

    fig.tight_layout(rect=[0,0,1,0.93])
    fig_save(pdf, fig)


def page_completeness(pdf, runs, colors):
    """Proteins quantified in at least N samples."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    add_page_header(fig, "Data Completeness at Different Sample Thresholds")

    n_samp_max = max(len(r["scols"]) for r in runs.values())
    thresholds = list(range(1, n_samp_max+1))
    lbls = [r["label"].replace("\n"," ") for r in runs.values()]

    for col, (k, r) in zip(colors, runs.items()):
        sc  = r["scols"]
        n   = r["df"][sc].notna().sum(axis=1)
        pct = [(n >= t).mean()*100 for t in thresholds]
        axes[0].plot(thresholds, pct, color=col, linewidth=1.5,
                     label=r["label"].replace("\n"," "), marker="o", markersize=3)
        cnt = [(n >= t).sum() for t in thresholds]
        axes[1].plot(thresholds, cnt, color=col, linewidth=1.5,
                     label=r["label"].replace("\n"," "), marker="o", markersize=3)

    for ax, ylabel in zip(axes, ["% protein groups", "# protein groups"]):
        ax.set_xlabel("Min samples with quantification")
        ax.set_ylabel(ylabel)
        ax.legend(fontsize=6)
        ax.axvline(n_samp_max, color="grey", linestyle="--",
                   linewidth=0.8, alpha=0.5)

    fig.tight_layout(rect=[0,0,1,0.93])
    fig_save(pdf, fig)


def page_peptide_evidence(pdf, runs, colors):
    """N.Sequences and N.Proteotypic.Sequences distributions."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    add_page_header(fig, "Peptide Evidence per Protein Group")
    lbls = [r["label"].replace("\n"," ") for r in runs.values()]

    for col_idx, col_name, title in [
        (0, "N.Sequences",             "All sequences per protein group"),
        (1, "N.Proteotypic.Sequences", "Proteotypic sequences per protein group"),
    ]:
        ax = axes[col_idx]
        data = [r["df"][col_name].clip(0,30).values for r in runs.values()]
        bplot = ax.boxplot(data, patch_artist=True, notch=False,
                           medianprops=dict(color="white", linewidth=1.5))
        for patch, col in zip(bplot["boxes"], colors):
            patch.set_facecolor(col)
            patch.set_alpha(0.75)
        ax.set_xticks(range(1, len(lbls)+1))
        ax.set_xticklabels(lbls, fontsize=6.5, rotation=15, ha="right")
        ax.set_ylabel("Count (clipped at 30)")
        ax.set_title(title)

    fig.tight_layout(rect=[0,0,1,0.93])
    fig_save(pdf, fig)


def page_heatmap_top_proteins(pdf, runs, colors):
    """Heatmap of log2 intensity for top 60 most variable proteins, all runs side-by-side."""
    # Find common proteins across all runs
    gsets = {k: set(r["df"]["Genes"].dropna()) for k, r in runs.items()}
    common = sorted(set.intersection(*gsets.values()))
    if len(common) < 5:
        return

    # Build a wide matrix: runs side by side, proteins as rows
    block_dfs = []
    col_labels = []
    dividers   = [0]
    for k, r in runs.items():
        sub = (r["df"][r["df"]["Genes"].isin(common)]
               .drop_duplicates("Genes").set_index("Genes"))
        log2_m = np.log2(sub[r["scols"]].replace(0, np.nan))
        log2_m = log2_m.reindex(common)
        sc_short = strip_common_prefix([sample_name(c) for c in r["scols"]])
        log2_m.columns = sc_short
        block_dfs.append(log2_m)
        col_labels.extend(sc_short)
        dividers.append(dividers[-1] + len(r["scols"]))

    wide = pd.concat(block_dfs, axis=1)
    wide.columns = col_labels

    # Select top 60 by row variance
    rowvar = wide.var(axis=1, skipna=True).sort_values(ascending=False)
    top_genes = rowvar.head(60).index
    wide_top  = wide.loc[top_genes]

    # Row-normalise (Z-score per protein)
    wide_z = wide_top.subtract(wide_top.mean(axis=1), axis=0).divide(
              wide_top.std(axis=1).replace(0, np.nan), axis=0)

    fig, ax = plt.subplots(figsize=(max(12, len(col_labels)*0.35), 14))
    add_page_header(fig, "Heatmap: Top 60 Most Variable Common Proteins (Z-scored)")

    sns.heatmap(wide_z, ax=ax, cmap="RdBu_r", center=0, vmin=-2, vmax=2,
                xticklabels=True, yticklabels=True,
                cbar_kws={"label":"Z-score", "shrink":0.5},
                linewidths=0, rasterized=True)
    ax.tick_params(axis="x", labelsize=5, rotation=90)
    ax.tick_params(axis="y", labelsize=5.5)

    # Draw vertical lines between runs
    for d in dividers[1:-1]:
        ax.axvline(d, color="black", linewidth=1.5)

    # Run labels above heatmap
    for i, (k, r) in enumerate(runs.items()):
        mid = (dividers[i] + dividers[i+1]) / 2
        ax.text(mid, -1, r["label"].replace("\n"," "), ha="center",
                va="bottom", fontsize=6, color=colors[i], fontweight="bold",
                transform=ax.transData)

    fig.tight_layout(rect=[0,0,1,0.95])
    fig_save(pdf, fig)


# ── Main ──────────────────────────────────────────────────────────────────────
def main():
    if len(sys.argv) < 2:
        print("Usage: python compare_diann.py <root_path>")
        sys.exit(1)

    root = Path(sys.argv[1])
    if not root.exists():
        print(f"ERROR: path not found: {root}")
        sys.exit(1)

    print(f"\nScanning {root} for DIANN* folders...")
    runs = find_and_load(root)

    if not runs:
        print("No runs found. Check that DIANN* folders contain report*pg*matrix*.tsv files.")
        sys.exit(1)

    print(f"\nFound {len(runs)} run(s):")
    for k, r in runs.items():
        print(f"  {k}: {len(r['df'])} protein groups, {len(r['scols'])} samples")

    colors = PALETTE[:len(runs)]
    out_pdf = root / "diann_comparison_report.pdf"
    out_tsv = root / "diann_comparison_summary.tsv"

    print(f"\nGenerating PDF: {out_pdf}")
    with PdfPages(str(out_pdf)) as pdf:
        pdf.infodict().update({
            "Title":   "DIA-NN Multi-Run Comparison",
            "Author":  "compare_diann.py",
            "Subject": str(root),
            "CreationDate": datetime.now(),
        })

        print("  cover page...")
        page_cover(pdf, root, runs)

        print("  summary table...")
        page_summary_table(pdf, runs)

        print("  protein counts...")
        page_protein_counts(pdf, runs, colors)

        print("  per-sample depth...")
        page_per_sample_depth(pdf, runs, colors)

        print("  missing value heatmap...")
        page_missing_heatmap(pdf, runs, colors)

        print("  intensity distributions...")
        page_intensity_distribution(pdf, runs, colors)

        print("  pairwise correlation matrix...")
        page_pairwise_corr(pdf, runs, colors)

        print("  PCA...")
        page_pca(pdf, runs, colors)

        print("  set overlap (UpSet-style)...")
        page_set_overlap(pdf, runs, colors)

        print("  unique proteins...")
        page_unique_proteins(pdf, runs)

        print("  concordance scatter...")
        page_concordance_scatter(pdf, runs, colors)

        print("  MA plots...")
        page_ma_plots(pdf, runs, colors)

        print("  top differentially quantified proteins...")
        page_top_diff_proteins(pdf, runs, colors)

        print("  concordance summary table...")
        page_concordance_summary(pdf, runs)

        print("  CV analysis...")
        page_cv_analysis(pdf, runs, colors)

        print("  completeness...")
        page_completeness(pdf, runs, colors)

        print("  peptide evidence...")
        page_peptide_evidence(pdf, runs, colors)

        print("  heatmap top variable proteins...")
        page_heatmap_top_proteins(pdf, runs, colors)

    print(f"\nPDF written: {out_pdf}")

    # -- Summary TSV --
    print(f"Writing summary TSV: {out_tsv}")
    rows = []
    for k, r in runs.items():
        p  = r["params"]
        df = r["df"]
        sc = r["scols"]
        per_s = df[sc].notna().sum()
        rows.append({
            "folder":        k,
            "file":          r["file"],
            "protein_groups":len(df),
            "samples":       len(sc),
            "fr_mz":         f"{p.get('fr_min','?')}-{p.get('fr_max','?')}",
            "pr_mz":         f"{p.get('pr_min','?')}-{p.get('pr_max','?')}",
            "mass_acc_ms2":  p.get("mass_acc","?"),
            "mass_acc_ms1":  p.get("ms1_acc","?"),
            "high_acc":      p.get("high_acc","?"),
            "threads":       p.get("threads","?"),
            "mean_per_sample": round(per_s.mean(), 1),
            "missing_pct":   round(100*df[sc].isna().sum().sum()/(len(df)*len(sc)), 2),
            "median_log2":   round(float(np.nanmedian(
                                np.log2(df[sc].replace(0,np.nan).values.flatten()))), 3),
        })
    pd.DataFrame(rows).to_csv(str(out_tsv), sep="\t", index=False)
    print(f"TSV written: {out_tsv}")
    print("\nDone.")

if __name__ == "__main__":
    main()