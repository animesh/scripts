# uv add xlrd openpyxl
# uv run pepIntSum.py 
#
# REPL-friendly MaxLFQ trace script.
#
# Purpose:
#   Trace every step from an exported MaxQuant peptide table to reconstructed LFQ,
#   then compare against proteinGroups.txt.
#
# Designed for your small last example:
#   peptides opy.txt
#   proteinGroups - Copy.txt
#
# Also works for peptides.txt and modificationSpecificPeptides.txt style wide tables.
#
# How to run in one go:
#   python pepIntSum.py  "F:\maxlLFQ\txt1LFQ\peptides opy.txt" "F:\maxlLFQ\txt1LFQ\proteinGroups - Copy.txt"
#
# How to use in REPL:
#   Paste and run block by block. The variables are intentionally left visible:
#   peptide_table, species_matrix, normalization_table, raw_to_norm_trace,
#   pairwise_ratio_trace, protein_profile_trace, comparison_trace, summary_table.

import sys
from pathlib import Path
from itertools import combinations

import numpy as np
import pandas as pd
from scipy.optimize import least_squares


# ============================================================
# User input area
# ============================================================

# If running interactively, edit these two paths manually.
# If running from command line, sys.argv overrides these.
peptide_table_file = r"peptides.txt"
protein_groups_file = r"proteinGroups.txt"

# Best setting for your last simple example.
# In that dataset all variants collapse to the same values, but this is the clean default.
anchor_sample = "UPS1_03"
peptide_species_aggregation = "max"
protein_rescale_target = "max"
min_ratio_count = 1
pairwise_ratio_method = "median"

# Run-time override from command line.
if len(sys.argv) >= 2:
    peptide_table_file = sys.argv[1]
if len(sys.argv) >= 3:
    protein_groups_file = sys.argv[2]

output_dir = Path(peptide_table_file).resolve().parent / "maxlfq_step_trace_outputs"
output_dir.mkdir(parents=True, exist_ok=True)


# ============================================================
# Small helper functions
# ============================================================

def read_table(path):
    path = str(path)
    suffix = Path(path).suffix.lower()

    if suffix in [".txt", ".tsv"]:
        return pd.read_csv(path, sep="\t", low_memory=False)
    if suffix == ".csv":
        return pd.read_csv(path, low_memory=False)
    if suffix == ".xlsx":
        return pd.read_excel(path, engine="openpyxl")
    if suffix == ".xls":
        return pd.read_excel(path, engine="xlrd")

    return pd.read_csv(path, sep=None, engine="python")


def first_existing_column(df, candidates):
    for col in candidates:
        if col in df.columns:
            return col
    return None


def first_token(value):
    return str(value).split(";")[0].strip()


def safe_nanmax_vector(matrix):
    out = np.full(matrix.shape[1], np.nan)
    for j in range(matrix.shape[1]):
        col = matrix[:, j]
        ok = np.isfinite(col)
        if ok.any():
            out[j] = np.nanmax(col)
    return out


def safe_nansum_vector(matrix):
    out = np.full(matrix.shape[1], np.nan)
    for j in range(matrix.shape[1]):
        col = matrix[:, j]
        ok = np.isfinite(col)
        if ok.any():
            out[j] = np.nansum(col)
    return out


def connected_components_from_ratio_matrix(ratio_matrix):
    # Samples are connected when at least one valid pairwise LFQ ratio exists.
    n = ratio_matrix.shape[0]
    adjacency = np.isfinite(ratio_matrix)
    labels = np.full(n, -1, dtype=int)
    component_id = 0

    for start in range(n):
        if labels[start] != -1:
            continue
        if not adjacency[start].any():
            continue

        stack = [start]
        labels[start] = component_id

        while stack:
            node = stack.pop()
            for neighbor in np.where(adjacency[node])[0]:
                if labels[neighbor] == -1:
                    labels[neighbor] = component_id
                    stack.append(neighbor)

        component_id += 1

    return labels


# ============================================================
# Load peptide table and identify relevant columns
# ============================================================

peptide_table_raw = read_table(peptide_table_file)

# Remove reverse/contaminant rows if present.
peptide_table = peptide_table_raw.copy()
for flag_col in ["Reverse", "Potential contaminant", "Contaminant"]:
    if flag_col in peptide_table.columns:
        peptide_table = peptide_table[peptide_table[flag_col].astype(str).str.strip() != "+"].copy()

# Detect peptide intensity columns.
# MaxQuant peptide tables usually have columns like "Intensity 05630".
intensity_cols = [c for c in peptide_table.columns if str(c).startswith("Intensity ")]
if not intensity_cols:
    raise ValueError("No peptide intensity columns found. Expected columns starting with 'Intensity '.")

samples = [c.replace("Intensity ", "", 1) for c in intensity_cols]

# Convert zero to missing. This matches LFQ logic: zero means no usable intensity.
peptide_table[intensity_cols] = (
    peptide_table[intensity_cols]
    .apply(pd.to_numeric, errors="coerce")
    .replace(0, np.nan)
)
peptide_table = peptide_table[peptide_table[intensity_cols].notna().any(axis=1)].copy()

# Protein column.
protein_col = first_existing_column(
    peptide_table,
    ["Leading razor protein", "Razor", "Razor protein", "Proteins", "Protein", "Protein IDs"],
)
if protein_col is None:
    raise ValueError("Could not find a protein column.")

# Modified peptide species.
# For your last simple example, modification and charge do not matter,
# but we still build the species key explicitly.
modified_sequence_col = first_existing_column(
    peptide_table,
    ["Modified sequence", "Modified Sequence", "Modified peptide sequence"],
)
sequence_col = first_existing_column(peptide_table, ["Sequence", "Peptide sequence", "Peptide"])
modifications_col = first_existing_column(peptide_table, ["Modifications", "Modification"])
charge_col = first_existing_column(peptide_table, ["Charge", "Charges", "z"])

if modified_sequence_col is not None:
    peptide_table["_modseq"] = peptide_table[modified_sequence_col].astype(str)
    modification_source = modified_sequence_col
elif sequence_col is not None and modifications_col is not None:
    peptide_table["_modseq"] = peptide_table[sequence_col].astype(str) + "|mods=" + peptide_table[modifications_col].astype(str)
    modification_source = sequence_col + " + " + modifications_col
elif sequence_col is not None:
    peptide_table["_modseq"] = peptide_table[sequence_col].astype(str)
    modification_source = sequence_col
else:
    raise ValueError("Could not find Sequence or Modified sequence column.")

if charge_col is not None:
    peptide_table["_charge"] = peptide_table[charge_col].astype(str).str.strip()
else:
    peptide_table["_charge"] = "NA"

peptide_table["_protein"] = peptide_table[protein_col].apply(first_token)
peptide_table["_species"] = peptide_table["_modseq"] + "|z=" + peptide_table["_charge"]

# Rename intensity columns to sample names for easier math.
rename_map = {col: sample for col, sample in zip(intensity_cols, samples)}
working = peptide_table[["_protein", "_species"] + intensity_cols].rename(columns=rename_map).copy()


# ============================================================
# Build peptide species matrix
# ============================================================

# Rows are protein plus peptide species.
# Columns are samples.
# Values are raw peptide intensities.
if peptide_species_aggregation == "max":
    species_matrix = working.groupby(["_protein", "_species"], sort=True)[samples].max()
elif peptide_species_aggregation == "sum":
    species_matrix = working.groupby(["_protein", "_species"], sort=True)[samples].sum(min_count=1)
else:
    raise ValueError("peptide_species_aggregation must be 'max' or 'sum'.")

species_matrix = species_matrix.replace(0, np.nan)


# ============================================================
# Eq. 2 normalization factor estimation
# ============================================================

# Paper idea:
#   I_P,A(N) = N_A * raw_intensity_P,A
#   H(N) = sum over shared peptide species and sample pairs of
#          [log(I_P,A(N)) - log(I_P,B(N))]^2
#
# This estimates one normalization factor per sample.
# It only determines ratios between N values. Then we anchor one sample to N = 1.

logX = np.log(species_matrix.values.astype(float))
n_samples = len(samples)
sample_pairs = list(combinations(range(n_samples), 2))


def normalization_residuals(logN):
    blocks = []
    for a, b in sample_pairs:
        ok = np.isfinite(logX[:, a]) & np.isfinite(logX[:, b])
        if ok.any():
            blocks.append(logX[ok, a] + logN[a] - logX[ok, b] - logN[b])
    if not blocks:
        return np.array([0.0])
    return np.concatenate(blocks)

# H before normalization.
res_before = normalization_residuals(np.zeros(n_samples))
H_before = float(np.sum(res_before ** 2))

# Fit N using LM if enough residuals exist.
method = "lm" if len(res_before) >= n_samples else "trf"
fit = least_squares(normalization_residuals, np.zeros(n_samples), method=method, max_nfev=2000)
N_scale_free = np.exp(fit.x)

# Anchor selected sample to N = 1.
if anchor_sample not in samples:
    raise ValueError(f"anchor_sample {anchor_sample} is not in samples: {samples}")
anchor_index = samples.index(anchor_sample)
N = N_scale_free / N_scale_free[anchor_index]

res_after = normalization_residuals(np.log(N))
H_after = float(np.sum(res_after ** 2))

normalization_table = pd.DataFrame({
    "Sample": samples,
    "N": N,
    "log2_N": np.log2(N),
})


# ============================================================
# Eq. 1 raw to normalized peptide intensity trace
# ============================================================

# Eq. 1 in this table setting:
#   normalized_intensity = raw_intensity * N_sample
normalized_species_matrix = species_matrix.copy()
for sample, n_value in zip(samples, N):
    normalized_species_matrix[sample] = normalized_species_matrix[sample] * n_value

raw_to_norm_rows = []
for (protein, species), row in species_matrix.iterrows():
    for sample, n_value in zip(samples, N):
        raw_value = row[sample]
        norm_value = normalized_species_matrix.loc[(protein, species), sample]
        raw_to_norm_rows.append({
            "Protein": protein,
            "Species": species,
            "Sample": sample,
            "Raw_Intensity": raw_value,
            "N": n_value,
            "Normalized_Intensity_Eq1": norm_value,
        })
raw_to_norm_trace = pd.DataFrame(raw_to_norm_rows)


# ============================================================
# Pairwise ratios and Eq. 3 protein profiles
# ============================================================

# For each protein:
# 1. Compute pairwise protein ratios from shared peptide species.
# 2. Solve Eq. 3: log2(I_j) - log2(I_k) = log2(r_jk)
# 3. Rescale relative profile to protein-level anchor, max or sum over normalized species.

pairwise_rows = []
profile_rows = []
calculated_lfq_rows = []

for protein, protein_df in normalized_species_matrix.groupby(level=0, sort=True):
    matrix = protein_df.values.astype(float)
    species_names = [idx[1] for idx in protein_df.index]
    log_matrix = np.log2(matrix)

    ratio_matrix = np.full((n_samples, n_samples), np.nan)
    shared_count_matrix = np.zeros((n_samples, n_samples), dtype=int)

    for j, k in combinations(range(n_samples), 2):
        ok = np.isfinite(log_matrix[:, j]) & np.isfinite(log_matrix[:, k])
        n_shared = int(ok.sum())
        shared_count_matrix[j, k] = n_shared
        shared_count_matrix[k, j] = n_shared

        if n_shared < min_ratio_count:
            continue

        peptide_log2_ratios = log_matrix[ok, j] - log_matrix[ok, k]
        if pairwise_ratio_method == "median":
            log2_ratio = float(np.median(peptide_log2_ratios))
        elif pairwise_ratio_method == "mean":
            log2_ratio = float(np.mean(peptide_log2_ratios))
        else:
            raise ValueError("pairwise_ratio_method must be 'median' or 'mean'.")

        ratio_matrix[j, k] = log2_ratio
        ratio_matrix[k, j] = -log2_ratio

        pairwise_rows.append({
            "Protein": protein,
            "Sample_A": samples[j],
            "Sample_B": samples[k],
            "Shared_Species_Count": n_shared,
            "Shared_Species": ";".join(np.array(species_names)[ok]),
            "log2_ratio_A_over_B": log2_ratio,
            "ratio_A_over_B": 2 ** log2_ratio,
        })

    labels = connected_components_from_ratio_matrix(ratio_matrix)
    output_profile = np.full(n_samples, np.nan)
    relative_profile_all = np.full(n_samples, np.nan)
    anchor_vector_all = np.full(n_samples, np.nan)

    for component_id in sorted(set(labels)):
        if component_id < 0:
            continue

        sample_idx = np.where(labels == component_id)[0]
        sub_ratios = ratio_matrix[np.ix_(sample_idx, sample_idx)]

        rows = []
        values = []
        for a, b in combinations(range(len(sample_idx)), 2):
            if np.isfinite(sub_ratios[a, b]):
                row = np.zeros(len(sample_idx))
                row[a] = 1.0
                row[b] = -1.0
                rows.append(row)
                values.append(sub_ratios[a, b])

        if not rows:
            continue

        solution, *_ = np.linalg.lstsq(np.asarray(rows), np.asarray(values), rcond=None)
        relative_profile = 2.0 ** solution

        component_matrix = matrix[:, sample_idx]
        if protein_rescale_target == "max":
            anchor_vector = safe_nanmax_vector(component_matrix)
        elif protein_rescale_target == "sum":
            anchor_vector = safe_nansum_vector(component_matrix)
        else:
            raise ValueError("protein_rescale_target must be 'max' or 'sum'.")

        active = (
            np.isfinite(relative_profile)
            & (relative_profile > 0)
            & np.isfinite(anchor_vector)
            & (anchor_vector > 0)
        )

        if active.any():
            scale = np.nansum(anchor_vector[active]) / np.nansum(relative_profile[active])
            final_profile = relative_profile * scale
            output_profile[sample_idx] = final_profile
            relative_profile_all[sample_idx] = relative_profile
            anchor_vector_all[sample_idx] = anchor_vector
        else:
            scale = np.nan

        for local_pos, sample_col_idx in enumerate(sample_idx):
            profile_rows.append({
                "Protein": protein,
                "Component": int(component_id),
                "Sample": samples[sample_col_idx],
                "Relative_Profile_Eq3": relative_profile[local_pos],
                "Protein_Anchor_Vector": anchor_vector[local_pos],
                "Protein_Profile_Scale": scale,
                "Calculated_LFQ": output_profile[sample_col_idx],
                "Rescale_Target": protein_rescale_target,
                "Species_Count_For_Protein": len(species_names),
            })

    calc_row = {"Protein": protein}
    for sample, value in zip(samples, output_profile):
        calc_row["LFQ intensity " + sample] = value if np.isfinite(value) and value > 0 else np.nan
    calculated_lfq_rows.append(calc_row)

pairwise_ratio_trace = pd.DataFrame(pairwise_rows)
protein_profile_trace = pd.DataFrame(profile_rows)
calculated_lfq = pd.DataFrame(calculated_lfq_rows).set_index("Protein")


# ============================================================
# Load proteinGroups and compare
# ============================================================

protein_groups = read_table(protein_groups_file)

for flag_col in ["Reverse", "Potential contaminant", "Contaminant"]:
    if flag_col in protein_groups.columns:
        protein_groups = protein_groups[protein_groups[flag_col].astype(str).str.strip() != "+"].copy()

if "Majority protein IDs" in protein_groups.columns:
    protein_groups["_protein"] = protein_groups["Majority protein IDs"].apply(first_token)
elif "Protein IDs" in protein_groups.columns:
    protein_groups["_protein"] = protein_groups["Protein IDs"].apply(first_token)
elif "Protein" in protein_groups.columns:
    protein_groups["_protein"] = protein_groups["Protein"].apply(first_token)
else:
    raise ValueError("Could not find protein identifier column in proteinGroups.")

lfq_cols = [c for c in protein_groups.columns if str(c).startswith("LFQ intensity ")]
reference_lfq = protein_groups[["_protein"] + lfq_cols].copy()
reference_lfq = reference_lfq.set_index("_protein")
reference_lfq = reference_lfq.apply(pd.to_numeric, errors="coerce").replace(0, np.nan)
reference_lfq.columns = [c.replace("LFQ intensity ", "", 1) for c in reference_lfq.columns]

comparison_rows = []
common_proteins = calculated_lfq.index.intersection(reference_lfq.index)
shared_samples = [s for s in samples if s in reference_lfq.columns]

for protein in common_proteins:
    for sample in shared_samples:
        calc_col = "LFQ intensity " + sample
        calc = calculated_lfq.loc[protein, calc_col] if calc_col in calculated_lfq.columns else np.nan
        ref = reference_lfq.loc[protein, sample]

        if pd.notna(calc) and pd.notna(ref) and calc > 0 and ref > 0:
            log2_diff = float(np.log2(calc / ref))
            fold = float(calc / ref)
        else:
            log2_diff = np.nan
            fold = np.nan

        comparison_rows.append({
            "Protein": protein,
            "Sample": sample,
            "Calculated_LFQ": calc,
            "ProteinGroups_LFQ": ref,
            "Log2_Calc_over_PG": log2_diff,
            "Calc_over_PG": fold,
            "Compared": bool(np.isfinite(log2_diff)),
        })

comparison_trace = pd.DataFrame(comparison_rows)
valid_diffs = comparison_trace["Log2_Calc_over_PG"].dropna().values

summary_table = pd.DataFrame([{
    "peptide_table_file": peptide_table_file,
    "protein_groups_file": protein_groups_file,
    "anchor_sample": anchor_sample,
    "peptide_species_aggregation": peptide_species_aggregation,
    "protein_rescale_target": protein_rescale_target,
    "min_ratio_count": min_ratio_count,
    "samples": ";".join(samples),
    "shared_reference_samples": ";".join(shared_samples),
    "proteins_calculated": int(calculated_lfq.shape[0]),
    "common_proteins": int(len(common_proteins)),
    "possible_cells": int(len(common_proteins) * len(shared_samples)),
    "shared_values_compared": int(len(valid_diffs)),
    "H_before_normalization": H_before,
    "H_after_normalization": H_after,
    "median_log2_calc_over_pg": float(np.median(valid_diffs)) if len(valid_diffs) else np.nan,
    "mean_log2_calc_over_pg": float(np.mean(valid_diffs)) if len(valid_diffs) else np.nan,
    "mae_log2": float(np.mean(np.abs(valid_diffs))) if len(valid_diffs) else np.nan,
    "sum_calculated": float(calculated_lfq[["LFQ intensity " + s for s in shared_samples]].sum(axis=0, skipna=True).sum()),
    "sum_proteinGroups": float(reference_lfq.loc[common_proteins, shared_samples].sum(axis=0, skipna=True).sum()),
}])
summary_table["calc_over_pg_total"] = summary_table["sum_calculated"] / summary_table["sum_proteinGroups"]
summary_table["log2_calc_over_pg_total"] = np.log2(summary_table["calc_over_pg_total"])

# Protein residual summary with peptide/species counts and missing counts.
species_counts = species_matrix.reset_index().groupby("_protein").agg(
    species_count=("_species", "nunique"),
).reset_index().rename(columns={"_protein": "Protein"})

valid_counts = comparison_trace.groupby("Protein").agg(
    compared_cells=("Compared", "sum"),
    possible_cells=("Compared", "size"),
    mean_log2_diff=("Log2_Calc_over_PG", "mean"),
    max_abs_log2_diff=("Log2_Calc_over_PG", lambda x: np.nanmax(np.abs(x)) if x.notna().any() else np.nan),
).reset_index()

protein_residual_summary = valid_counts.merge(species_counts, on="Protein", how="left")
protein_residual_summary["missing_or_zero_cells"] = protein_residual_summary["possible_cells"] - protein_residual_summary["compared_cells"]


# ============================================================
# Save trace outputs
# ============================================================

normalization_table.to_csv(output_dir / "trace_01_normalization_factors.tsv", sep="\t", index=False)
raw_to_norm_trace.to_csv(output_dir / "trace_02_eq1_raw_to_normalized.tsv", sep="\t", index=False)
pairwise_ratio_trace.to_csv(output_dir / "trace_03_pairwise_ratios.tsv", sep="\t", index=False)
protein_profile_trace.to_csv(output_dir / "trace_04_eq3_profile_and_lfq.tsv", sep="\t", index=False)
calculated_lfq.to_csv(output_dir / "trace_05_calculated_lfq.csv")
comparison_trace.to_csv(output_dir / "trace_06_compare_to_proteinGroups.tsv", sep="\t", index=False)
protein_residual_summary.to_csv(output_dir / "trace_07_protein_residual_summary.tsv", sep="\t", index=False)
summary_table.to_csv(output_dir / "trace_00_summary.tsv", sep="\t", index=False)

with pd.ExcelWriter(output_dir / "maxlfq_full_step_trace.xlsx", engine="openpyxl") as writer:
    summary_table.to_excel(writer, sheet_name="summary", index=False)
    normalization_table.to_excel(writer, sheet_name="normalization_N", index=False)
    raw_to_norm_trace.to_excel(writer, sheet_name="eq1_raw_to_norm", index=False)
    pairwise_ratio_trace.to_excel(writer, sheet_name="pairwise_ratios", index=False)
    protein_profile_trace.to_excel(writer, sheet_name="eq3_profile_lfq", index=False)
    calculated_lfq.reset_index().to_excel(writer, sheet_name="calculated_lfq", index=False)
    comparison_trace.to_excel(writer, sheet_name="compare_pg", index=False)
    protein_residual_summary.to_excel(writer, sheet_name="protein_residuals", index=False)


# ============================================================
# Console report with expected values for your last small example
# ============================================================

print()
print("Trace finished")
print("Output folder:", output_dir)
print()
print("Detected samples:", samples)
print("Protein column:", protein_col)
print("Modified sequence source:", modification_source)
print("Charge column:", charge_col if charge_col is not None else "none")
print()
print("Normalization factors")
print(normalization_table.to_string(index=False))
print()
print("Summary")
print(summary_table.to_string(index=False))
print()
print("Protein residual summary")
print(protein_residual_summary.to_string(index=False))
print()
print("Expected values for your last example, if using peptides opy.txt and proteinGroups - Copy.txt")
print("N should be approximately: 05630 = 1.000000, 41408 = 0.952563, 50441 = 1.835247")
print("H before normalization should be about: 13.58034")
print("H after normalization should be about: 8.77154")
print("shared compared values should be: 17")
print("median log2(calc / proteinGroups) should be approximately: 0")
print("mean log2(calc / proteinGroups) should be about: 0.005756")
print("MAE log2 should be about: 0.061760")
print("total calc / proteinGroups should be about: 1.002741")
print()
print("Written files")
for path in [
    "trace_00_summary.tsv",
    "trace_01_normalization_factors.tsv",
    "trace_02_eq1_raw_to_normalized.tsv",
    "trace_03_pairwise_ratios.tsv",
    "trace_04_eq3_profile_and_lfq.tsv",
    "trace_05_calculated_lfq.csv",
    "trace_06_compare_to_proteinGroups.tsv",
    "trace_07_protein_residual_summary.tsv",
    "maxlfq_full_step_trace.xlsx",
]:
    print(output_dir / path)
