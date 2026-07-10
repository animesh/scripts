#  uv run evidenceIntSum.py $HOME/promec/promec/Animesh/Download/BSA/evidence.txt $HOME/promec/promec/Animesh/Download/BSA/proteinGroups.txt 
# Usage:
#   python evidenceIntSum.py evidence.txt proteinGroups.txt
#   python evidenceIntSum.py evidence.txt proteinGroups.txt mqpar.xml
#
# This script keeps the corrected maxLFQsimple logic:
#   1. MULTI-SECPEP rows are summed per species/protein/sample.
#   2. All other evidence rows are maxed per species/protein/sample.
#   3. Pairwise ratios accept one shared peptide species: min_ratio_count = 1.
#   4. Protein profile rescaling uses nanmax of normalized peptide species, not nansum.
#
# It then scans normalization anchor conventions:
#   geomean
#   each sample set to N = 1
#   mqpar first experiment set to N = 1, if mqpar.xml is supplied

import sys
import os
import warnings
from pathlib import Path
from itertools import combinations
import xml.etree.ElementTree as ET

import numpy as np
import pandas as pd
from scipy.optimize import least_squares

warnings.filterwarnings("ignore")

# -----------------------------
# Inputs
# -----------------------------
if len(sys.argv) < 3:
    raise SystemExit("Usage: python evidenceIntSum.py evidence.txt proteinGroups.txt [mqpar.xml]")

evidence_file = sys.argv[1]
protein_groups_file = sys.argv[2]
mqpar_file = sys.argv[3] if len(sys.argv) > 3 else None

outdir = Path(evidence_file).resolve().parent / "maxLFQ_anchor_scan_fixed_outputs"
outdir.mkdir(parents=True, exist_ok=True)

# -----------------------------
# Load evidence
# -----------------------------
ev = pd.read_csv(evidence_file, sep="\t", low_memory=False)

allowed_types = {
    "MULTI-MSMS",
    "MULTI-MATCH",
    "MULTI-SECPEP",
    "MSMS",
    "MULTI-MATCH-MSMS",
    "ISO-MSMS",
}
if "Type" in ev.columns:
    ev = ev[ev["Type"].isin(allowed_types)].copy()

for c in ["Reverse", "Potential contaminant", "Contaminant"]:
    if c in ev.columns:
        ev = ev[ev[c].astype(str).str.strip() != "+"].copy()

ev["Intensity"] = pd.to_numeric(ev["Intensity"], errors="coerce")
ev_noint = ev[~(ev["Intensity"] > 0)].copy()
ev = ev[ev["Intensity"] > 0].copy()

required = ["Leading razor protein", "Modified sequence", "Charge", "Experiment", "Intensity"]
missing = [c for c in required if c not in ev.columns]
if missing:
    raise ValueError(f"Missing required evidence columns: {missing}")

ev["_razor"] = ev["Leading razor protein"].astype(str).str.split(";").str[0].str.strip()
ev["_species"] = ev["Modified sequence"].astype(str) + "_z" + ev["Charge"].astype(str)

ev["Experiment"] = ev["Experiment"].astype(str)

# Only zero-pad if all experiment names are purely numeric.
# Do not pad mixed names like "251203_bsa" or "20251125_HF_QC_BSA_01",
# because that breaks matching to proteinGroups.txt LFQ columns.
_exps = ev["Experiment"].dropna().astype(str).unique().tolist()

if all(x.isdigit() for x in _exps):
    _zlen = max(len(x) for x in _exps)
    ev["Experiment"] = ev["Experiment"].str.zfill(_zlen)

samples = sorted(ev["Experiment"].unique())

# -----------------------------
# Build species × sample matrix using corrected SECPEP split
# -----------------------------
# MULTI-SECPEP rows are summed.
# All other rows are maxed.
# Final intensity = SECPEP_sum + non_SECPEP_max.
sec = ev[ev["Type"] == "MULTI-SECPEP"].copy() if "Type" in ev.columns else ev.iloc[0:0].copy()
rest = ev[ev["Type"] != "MULTI-SECPEP"].copy() if "Type" in ev.columns else ev.copy()

agg_sec = sec.groupby(["_species", "_razor", "Experiment"], dropna=False)["Intensity"].sum()
agg_rest = rest.groupby(["_species", "_razor", "Experiment"], dropna=False)["Intensity"].max()

combined = (
    pd.concat([agg_sec.rename("secpep_sum"), agg_rest.rename("rest_max")], axis=1)
    .fillna(0)
)
combined["Intensity"] = combined["secpep_sum"] + combined["rest_max"]
combined = combined.replace(0, np.nan)["Intensity"]

wide = combined.unstack("Experiment").reindex(columns=samples).replace(0, np.nan)
wide.to_csv(outdir / "species_matrix_corrected.csv")

# -----------------------------
# Estimate raw N_j via paper Eq. 2 residuals
# H(N) = sum_p sum_A<B [log(N_A * I_pA) - log(N_B * I_pB)]^2
# Raw solution is scale-free. Anchors are applied afterwards.
# -----------------------------
logX = np.log(wide.values.astype(float))
pairs = list(combinations(range(len(samples)), 2))

def residuals(logN):
    out = []
    for a, b in pairs:
        ok = np.isfinite(logX[:, a]) & np.isfinite(logX[:, b])
        if ok.any():
            out.append((logX[ok, a] + logN[a]) - (logX[ok, b] + logN[b]))
    return np.concatenate(out) if out else np.array([0.0])

fit = least_squares(residuals, np.zeros(len(samples)), method="lm", max_nfev=2000)
N_raw = np.exp(fit.x)

# -----------------------------
# Anchor variants
# -----------------------------
def anchor_geomean(N):
    return N / np.exp(np.mean(np.log(N)))

def anchor_sample(N, sample):
    return N / N[samples.index(sample)]

def mqpar_first_experiment(path):
    if path is None:
        return None
    root = ET.parse(path).getroot()
    exps = [el.text for el in root.findall(".//experiments/string")]
    if not exps:
        return None
    anchor = str(exps[0]).strip()
    zlen = max(len(s) for s in samples)
    anchor = anchor.zfill(zlen) if anchor.isdigit() else anchor
    return anchor

anchor_variants = []
anchor_variants.append(("geomean", "", anchor_geomean(N_raw)))
for s in samples:
    anchor_variants.append(("anchor_" + s, s, anchor_sample(N_raw, s)))

mq_anchor = mqpar_first_experiment(mqpar_file)
if mq_anchor is not None:
    if mq_anchor in samples:
        anchor_variants.append(("mqpar_first_experiment", mq_anchor, anchor_sample(N_raw, mq_anchor)))
    else:
        print(f"WARNING: mqpar first experiment {mq_anchor!r} not found in samples {samples}; skipping mqpar anchor")

# Remove duplicate N variants while retaining labels.
seen = set()
unique_anchor_variants = []
for name, anchor, N in anchor_variants:
    key = tuple(np.round(N, 12))
    if key not in seen:
        seen.add(key)
        unique_anchor_variants.append((name, anchor, N))
anchor_variants = unique_anchor_variants

# -----------------------------
# Correct MaxLFQ per-protein function
# -----------------------------
def maxlfq_correct(mat):
    # mat rows = peptide species for one protein, columns = samples, values = normalized intensities.
    mat = mat.astype(float).copy()
    mat[mat == 0] = np.nan
    logP = np.log2(mat)
    ns = logP.shape[1]
    profile = np.full(ns, np.nan)

    # Correct protein-specific rescaling target: nanmax per sample.
    nm = np.full(ns, np.nan)
    for j in range(ns):
        col = mat[:, j]
        finite = np.isfinite(col)
        if finite.any():
            nm[j] = np.nanmax(col)

    # Pairwise median log2 ratios. min_ratio_count = 1.
    rat = np.full((ns, ns), np.nan)
    for j, k in combinations(range(ns), 2):
        shared = np.isfinite(logP[:, j]) & np.isfinite(logP[:, k])
        if shared.sum() < 1:
            continue
        m = float(np.median((logP[:, j] - logP[:, k])[shared]))
        rat[j, k] = m
        rat[k, j] = -m

    has_r = np.any(np.isfinite(rat), axis=1)
    if not has_r.any():
        return profile

    rows = []
    vals = []
    for j, k in combinations(range(ns), 2):
        if np.isfinite(rat[j, k]) and has_r[j] and has_r[k]:
            row = np.zeros(ns)
            row[j] = 1.0
            row[k] = -1.0
            rows.append(row)
            vals.append(rat[j, k])

    if not rows:
        profile[has_r] = nm[has_r]
        return profile

    sol, *_ = np.linalg.lstsq(np.array(rows), np.array(vals), rcond=None)
    p = 2.0 ** sol
    p[~has_r] = np.nan

    active = has_r & np.isfinite(p) & (p > 0) & np.isfinite(nm) & (nm > 0)
    if active.any():
        p *= np.nansum(nm[active]) / np.nansum(p[active])

    p[~has_r] = np.nan
    profile = p
    return profile


def calculate_lfq(N):
    wide_norm_reset = wide.multiply(N, axis="columns").reset_index()
    records = []
    for prot, grp in wide_norm_reset.groupby("_razor", sort=True):
        mat = grp[samples].values.astype(float)
        mat[mat == 0] = np.nan
        prof = maxlfq_correct(mat)
        rec = {"Protein": prot}
        for s, v in zip(samples, prof):
            rec["LFQ intensity " + s] = float(v) if np.isfinite(v) and v > 0 else np.nan
        records.append(rec)
    return pd.DataFrame(records).set_index("Protein")

# -----------------------------
# Load proteinGroups LFQ
# -----------------------------
pg = pd.read_csv(protein_groups_file, sep="\t", low_memory=False)
for c in ["Reverse", "Potential contaminant", "Contaminant"]:
    if c in pg.columns:
        pg = pg[pg[c].astype(str).str.strip() != "+"].copy()

pg = pg.set_index("Majority protein IDs")
pg_lfq = pg[[c for c in pg.columns if c.startswith("LFQ intensity ")]].apply(pd.to_numeric, errors="coerce").replace(0, np.nan)
pg_lfq.columns = pg_lfq.columns.str.removeprefix("LFQ intensity ")
pg_lfq.index = [str(i).split(";")[0].strip() for i in pg_lfq.index]
shared_samples = [s for s in samples if s in pg_lfq.columns]

# -----------------------------
# Evaluate each anchor
# -----------------------------
def evaluate(calc, variant_name, anchor_sample):
    common = calc.index.intersection(pg_lfq.index)
    all_diffs = []
    sample_rows = []
    cell_rows = []

    for s in shared_samples:
        calc_col = "LFQ intensity " + s
        c = calc.loc[common, calc_col]
        m = pg_lfq.loc[common, s]
        ok = c.notna() & m.notna() & (c > 0) & (m > 0)
        diffs = np.log2(c[ok].astype(float).values / m[ok].astype(float).values)
        all_diffs.extend(diffs.tolist())

        for prot, cv, mv, dv in zip(c.index[ok], c[ok].astype(float), m[ok].astype(float), diffs):
            cell_rows.append({
                "variant": variant_name,
                "anchor_sample": anchor_sample,
                "Protein": prot,
                "sample": s,
                "calculated_lfq": float(cv),
                "proteinGroups_lfq": float(mv),
                "log2_calc_over_actual": float(dv),
                "calc_over_actual": float(cv / mv),
            })

        sample_rows.append({
            "variant": variant_name,
            "anchor_sample": anchor_sample,
            "sample": s,
            "n": int(ok.sum()),
            "median_log2_calc_over_actual": float(np.median(diffs)) if len(diffs) else np.nan,
            "mean_log2_calc_over_actual": float(np.mean(diffs)) if len(diffs) else np.nan,
            "mae_log2": float(np.mean(np.abs(diffs))) if len(diffs) else np.nan,
            "sum_calculated": float(c.sum(skipna=True)),
            "sum_actual": float(m.sum(skipna=True)),
            "calc_over_actual_total_sample": float(c.sum(skipna=True) / m.sum(skipna=True)) if m.sum(skipna=True) > 0 else np.nan,
            "log2_sum_calc_over_actual": float(np.log2(c.sum(skipna=True) / m.sum(skipna=True))) if m.sum(skipna=True) > 0 else np.nan,
        })

    sample_df = pd.DataFrame(sample_rows)
    calc_total = calc.loc[common, ["LFQ intensity " + s for s in shared_samples]].sum(axis=0, skipna=True).sum()
    actual_total = pg_lfq.loc[common, shared_samples].sum(axis=0, skipna=True).sum()

    summary = {
        "variant": variant_name,
        "anchor_sample": anchor_sample,
        "common_proteins": int(len(common)),
        "shared_values": int(len(all_diffs)),
        "median_log2_calc_over_actual": float(np.median(all_diffs)) if len(all_diffs) else np.nan,
        "bias_mean_log2_calc_over_actual": float(np.mean(all_diffs)) if len(all_diffs) else np.nan,
        "mae_log2": float(np.mean(np.abs(all_diffs))) if len(all_diffs) else np.nan,
        "sample_median_range": float(sample_df["median_log2_calc_over_actual"].max() - sample_df["median_log2_calc_over_actual"].min()) if len(sample_df) else np.nan,
        "sum_calculated": float(calc_total),
        "sum_actual": float(actual_total),
        "calc_over_actual_total": float(calc_total / actual_total) if actual_total > 0 else np.nan,
        "log2_calc_over_actual_total": float(np.log2(calc_total / actual_total)) if actual_total > 0 else np.nan,
    }
    return summary, sample_df, pd.DataFrame(cell_rows)

summary_rows = []
sample_tables = []
cell_tables = []
N_rows = []

for variant_name, anchor_sample, N in anchor_variants:
    calc = calculate_lfq(N)
    calc.to_csv(outdir / f"calculated_lfq_{variant_name}.csv")
    summary, sample_df, cell_df = evaluate(calc, variant_name, anchor_sample)
    summary_rows.append(summary)
    sample_tables.append(sample_df)
    cell_tables.append(cell_df)
    for s, v in zip(samples, N):
        N_rows.append({
            "variant": variant_name,
            "anchor_sample": anchor_sample,
            "sample": s,
            "N": float(v),
            "log2_N": float(np.log2(v)),
        })

summary_df = pd.DataFrame(summary_rows).sort_values(["mae_log2", "median_log2_calc_over_actual"], na_position="last")
sample_df = pd.concat(sample_tables, ignore_index=True)
cell_df = pd.concat(cell_tables, ignore_index=True)
N_df = pd.DataFrame(N_rows)

summary_df.to_csv(outdir / "anchor_scan_fixed_summary.tsv", sep="\t", index=False)
sample_df.to_csv(outdir / "anchor_scan_fixed_by_sample.tsv", sep="\t", index=False)
cell_df.to_csv(outdir / "anchor_scan_fixed_cellwise.tsv", sep="\t", index=False)
N_df.to_csv(outdir / "anchor_scan_fixed_normalization_factors.tsv", sep="\t", index=False)

print("\nSamples:")
print(samples)
print("\nShared samples:")
print(shared_samples)
print("\nAnchor scan summary:")
print(summary_df.to_string(index=False))
print("\nWrote outputs to:")
print(outdir.resolve())
