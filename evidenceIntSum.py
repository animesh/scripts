import pandas as pd
import numpy as np
from itertools import combinations


# ============================================================
# Input files
# ============================================================

# This can be:
# 1. evidence.txt from MaxQuant
# 2. a custom peptide-species table with modified sequences, charges, proteins, and intensities
peptide_species_file = r"F:\BSA\txt\evidence.txt"

# Actual MaxQuant proteinGroups output for comparison
protein_groups_file = r"F:\BSA\txt\proteinGroups.txt"

from pathlib import Path
import matplotlib.pyplot as plt

protein_groups_path = Path(protein_groups_file)
output_dir = protein_groups_path.parent / "maxlfq_repl_outputs"
output_dir.mkdir(parents=True, exist_ok=True)

out_calculated_lfq = output_dir / "calculated_lfq_from_peptide_species.csv"
out_summary = output_dir / "calculated_lfq_vs_proteinGroups_summary.tsv"
out_sample_bias = output_dir / "calculated_lfq_vs_proteinGroups_by_sample.tsv"
out_cellwise = output_dir / "calculated_lfq_vs_proteinGroups_cellwise.tsv"
out_normalization = output_dir / "calculated_lfq_normalization_factors.tsv"
out_peptide_species_matrix = output_dir / "peptide_species_intensity_matrix.csv"

out_plot_scatter = output_dir / "plot_log2_calculated_vs_proteinGroups.png"
out_plot_residual_hist = output_dir / "plot_log2_residual_histogram.png"
out_plot_sample_bias = output_dir / "plot_sample_median_bias.png"
out_plot_sample_sums = output_dir / "plot_sample_sum_comparison.png"

# ============================================================
# User-adjustable options
# ============================================================

# Minimum number of shared peptide species required to define a ratio
# MaxLFQ commonly uses 2, but testing 1 can be useful for sparse data.
min_ratio_count = 1

# Pairwise peptide-to-protein ratio aggregation.
# The MaxLFQ paper uses pairwise peptide ratios and takes robust ratio information.
# Median is usually the safest approximation.
pairwise_ratio_aggregation = "median"  # "median" or "mean"

# Peptide species intensity aggregation when multiple rows map to same
# protein + modified sequence + charge + sample.
# For evidence.txt, "sum" is usually the most natural first test.
peptide_species_aggregation = "sum"  # "sum" or "max"

# Which rows to use from evidence-like input.
# These are simple, explicit filters for tracing/debugging.
remove_reverse = True
remove_contaminants = True
require_nonzero_intensity = True

# If True, only rows with Type containing "MSMS" are used.
# Start with False for baseline.
use_only_msms_type_rows = False

# If True, only rows with MS/MS count > 0 are used.
# Start with False for baseline.
use_only_msms_count_positive_rows = False


# ============================================================
# Small utility functions
# ============================================================

def first_existing_column(df, candidates):
    """
    Return the first column from candidates that exists in df.
    """
    for c in candidates:
        if c in df.columns:
            return c
    return None


def safe_first_protein(series):
    """
    Convert semicolon-separated protein IDs to the first protein ID.
    This is used to match proteinGroups Majority protein IDs convention.
    """
    return series.astype(str).str.split(";").str[0].str.strip()


def log2_ratio(a, b):
    """
    Safe log2(a / b).
    """
    return np.log2(a / b)


# ============================================================
# Step 0. Load peptide/evidence input
# ============================================================

peptides_raw = pd.read_csv(peptide_species_file, sep="\t", low_memory=False)

# Convert common numeric columns if present
for c in ["Intensity", "Charge", "Score", "Delta score", "PEP", "MS/MS count"]:
    if c in peptides_raw.columns:
        peptides_raw[c] = pd.to_numeric(peptides_raw[c], errors="coerce")

# Detect whether input is long evidence-like format or wide peptide table format.
# Long format has one "Intensity" column and one "Experiment" or "Raw file" column.
# Wide format has columns like "Intensity sample1", "Intensity sample2", ...
wide_intensity_cols = [c for c in peptides_raw.columns if c.startswith("Intensity ")]
has_long_intensity = "Intensity" in peptides_raw.columns
has_experiment = "Experiment" in peptides_raw.columns

input_is_long = has_long_intensity and has_experiment
input_is_wide = len(wide_intensity_cols) > 0

if not input_is_long and not input_is_wide:
    raise ValueError(
        "Input must be either evidence-like long format with columns "
        "'Intensity' and 'Experiment', or wide format with columns starting "
        "with 'Intensity '."
    )


# ============================================================
# Step 0a. Apply basic filters
# ============================================================

peptides = peptides_raw.copy()

if remove_reverse and "Reverse" in peptides.columns:
    peptides = peptides[~peptides["Reverse"].astype(str).eq("+")].copy()

if remove_contaminants and "Potential contaminant" in peptides.columns:
    peptides = peptides[~peptides["Potential contaminant"].astype(str).eq("+")].copy()

if input_is_long:
    peptides["Intensity"] = pd.to_numeric(peptides["Intensity"], errors="coerce")
    if require_nonzero_intensity:
        peptides["Intensity"] = peptides["Intensity"].replace(0, np.nan)
        peptides = peptides[peptides["Intensity"].notna()].copy()

if input_is_wide:
    peptides[wide_intensity_cols] = peptides[wide_intensity_cols].apply(
        pd.to_numeric,
        errors="coerce",
    )
    peptides[wide_intensity_cols] = peptides[wide_intensity_cols].replace(0, np.nan)
    if require_nonzero_intensity:
        peptides = peptides[peptides[wide_intensity_cols].notna().any(axis=1)].copy()

if use_only_msms_type_rows and "Type" in peptides.columns:
    peptides = peptides[
        peptides["Type"].astype(str).str.contains("MSMS", case=False, na=False)
    ].copy()

if use_only_msms_count_positive_rows and "MS/MS count" in peptides.columns:
    peptides = peptides[
        pd.to_numeric(peptides["MS/MS count"], errors="coerce").fillna(0).gt(0)
    ].copy()


# ============================================================
# Step 0b. Define protein key and peptide species key
# ============================================================

# Protein key:
# Prefer Leading razor protein for evidence.txt.
# Otherwise use Razor, Proteins, or Majority protein IDs if present.
protein_col = first_existing_column(
    peptides,
    [
        "Leading razor protein",
        "Razor",
        "Proteins",
        "Majority protein IDs",
        "Protein",
    ],
)

if protein_col is None:
    raise ValueError(
        "Could not find a protein column. Expected one of: "
        "Leading razor protein, Razor, Proteins, Majority protein IDs, Protein."
    )

peptides["_protein"] = safe_first_protein(peptides[protein_col])

# Modified peptide sequence:
# Prefer "Modified sequence" if available because it contains modification state.
# Otherwise use Sequence + Modifications.
modified_sequence_col = first_existing_column(
    peptides,
    [
        "Modified sequence",
        "Modified Sequence",
        "Modified peptide sequence",
    ],
)

sequence_col = first_existing_column(peptides, ["Sequence", "Peptide sequence"])

modifications_col = first_existing_column(peptides, ["Modifications", "Modification"])

if modified_sequence_col is not None:
    peptides["_modified_sequence"] = peptides[modified_sequence_col].astype(str)
elif sequence_col is not None and modifications_col is not None:
    peptides["_modified_sequence"] = (
        peptides[sequence_col].astype(str)
        + "|mods="
        + peptides[modifications_col].astype(str)
    )
elif sequence_col is not None:
    peptides["_modified_sequence"] = peptides[sequence_col].astype(str)
else:
    raise ValueError(
        "Could not find modified sequence information. Expected 'Modified sequence' "
        "or at least 'Sequence'."
    )

# Charge:
# This script expects charge-specific rows.
# If the input has collapsed Charges like "2;3", this is not truly charge-specific.
charge_col = first_existing_column(peptides, ["Charge", "Charges"])

if charge_col is None:
    raise ValueError("Could not find a charge column. Expected 'Charge' or 'Charges'.")

peptides["_charge"] = peptides[charge_col].astype(str).str.strip()

# Peptide species according to the paper:
# peptide species = sequence + modification state + charge
peptides["_species"] = peptides["_modified_sequence"] + "|z=" + peptides["_charge"]


# ============================================================
# Step 0c. Build peptide species intensity matrix
# ============================================================

if input_is_long:
    # evidence-like input:
    # rows are evidence features, so pivot to:
    # index = protein + peptide species
    # columns = samples
    # values = intensity
    peptides["_sample"] = peptides["Experiment"].astype(str)

    if peptide_species_aggregation == "sum":
        peptide_matrix = peptides.pivot_table(
            index=["_protein", "_species"],
            columns="_sample",
            values="Intensity",
            aggfunc="sum",
        )
    elif peptide_species_aggregation == "max":
        peptide_matrix = peptides.pivot_table(
            index=["_protein", "_species"],
            columns="_sample",
            values="Intensity",
            aggfunc="max",
        )
    else:
        raise ValueError("peptide_species_aggregation must be 'sum' or 'max'.")

else:
    # wide peptide table:
    # rows are already peptide rows with sample intensity columns.
    samples = [c.replace("Intensity ", "") for c in wide_intensity_cols]

    tmp = peptides[["_protein", "_species"] + wide_intensity_cols].copy()
    tmp = tmp.rename(columns={c: c.replace("Intensity ", "") for c in wide_intensity_cols})

    if peptide_species_aggregation == "sum":
        peptide_matrix = tmp.groupby(["_protein", "_species"], sort=True)[samples].sum(
            min_count=1
        )
    elif peptide_species_aggregation == "max":
        peptide_matrix = tmp.groupby(["_protein", "_species"], sort=True)[samples].max()
    else:
        raise ValueError("peptide_species_aggregation must be 'sum' or 'max'.")

# Make sure sample order is stable
samples = list(peptide_matrix.columns)
peptide_matrix = peptide_matrix.apply(pd.to_numeric, errors="coerce")
peptide_matrix = peptide_matrix.replace(0, np.nan)

peptide_matrix.to_csv(out_peptide_species_matrix)

print("Peptide species rows:", peptide_matrix.shape[0])
print("Proteins:", peptide_matrix.index.get_level_values(0).nunique())
print("Samples:", samples)


# ============================================================
# Step 1. Eq. 1 from paper: delayed normalization
# ============================================================
#
# Paper idea:
#
#   I_{P,A}(N) = sum_k N_run(k) * XIC_k
#
# In this simplified peptide-species table:
#
#   normalized_intensity[p, sample] = N[sample] * raw_intensity[p, sample]
#
# We first estimate N in Step 2, then apply Eq. 1 below.


# ============================================================
# Step 2. Eq. 2 from paper: estimate normalization factors
# ============================================================
#
# Paper objective:
#
#   H(N) = sum_P sum_(A,B) | log(I_{P,A}(N) / I_{P,B}(N)) |^2
#
# Since:
#
#   log(I_{P,A}(N) / I_{P,B}(N))
#   = log(raw_{P,A}) - log(raw_{P,B}) + log(N_A) - log(N_B)
#
# We estimate log(N) from all shared peptide-species pairs.
# The absolute scale of N is arbitrary, so we force geometric mean N = 1.

def estimate_normalization_factors(matrix):
    """
    Estimate sample normalization factors using the Eq. 2 logic.

    Input:
        matrix: rows = peptide species, columns = samples, values = raw intensities

    Output:
        N: array of multiplicative normalization factors for samples
    """
    X = matrix.values.astype(float)
    X[X == 0] = np.nan
    logX = np.log(X)

    n_samples = X.shape[1]

    # Each sample pair contributes one equation:
    #
    #   logN_A - logN_B approx -mean(logRaw_A - logRaw_B)
    #
    # This is a compact least-squares version of Eq. 2.
    rows = []
    values = []

    for a, b in combinations(range(n_samples), 2):
        shared = np.isfinite(logX[:, a]) & np.isfinite(logX[:, b])

        if not shared.any():
            continue

        row = np.zeros(n_samples)
        row[a] = 1.0
        row[b] = -1.0

        # Right-hand side that makes average normalized log ratio close to zero.
        target = -np.nanmean(logX[shared, a] - logX[shared, b])

        rows.append(row)
        values.append(target)

    if len(rows) == 0:
        return np.ones(n_samples)

    A = np.asarray(rows)
    b = np.asarray(values)

    # Add a tiny centering equation to remove the arbitrary scale degree of freedom.
    A_aug = np.vstack([A, np.ones(n_samples) * 1e-8])
    b_aug = np.concatenate([b, [0.0]])

    logN, *_ = np.linalg.lstsq(A_aug, b_aug, rcond=None)

    # Force geometric mean N = 1.
    logN = logN - np.mean(logN)
    N = np.exp(logN)
    N = N / np.exp(np.mean(np.log(N)))

    return N


N = estimate_normalization_factors(peptide_matrix)

normalization_df = pd.DataFrame({
    "sample": samples,
    "N": N,
    "log2_N": np.log2(N),
})

normalization_df.to_csv(out_normalization, sep="\t", index=False)

print("\nNormalization factors")
print(normalization_df.to_string(index=False))


# Apply Eq. 1
normalized_peptide_matrix = peptide_matrix.copy()

for j, sample in enumerate(samples):
    normalized_peptide_matrix[sample] = normalized_peptide_matrix[sample] * N[j]


# ============================================================
# Step 3. Eq. 3 from paper: solve protein profile
# ============================================================
#
# For one protein:
#
#   pairwise peptide ratio r_{j,k}
#     = median over peptide species p of intensity[p,j] / intensity[p,k]
#
# Eq. 3 minimizes:
#
#   sum_(j,k) (log r_{j,k} - log I_j + log I_k)^2
#
# Let:
#
#   x_j = log I_j
#
# Then every valid pair gives:
#
#   x_j - x_k = log r_{j,k}
#
# We solve this least-squares system for the relative protein profile.
# The result is relative only; absolute scale is fixed in Step 4.

def connected_components_from_ratio_matrix(ratio_matrix):
    """
    Find connected sample components from valid pairwise ratios.
    """
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


def pairwise_protein_log_ratios(protein_matrix):
    """
    Compute pairwise protein log-ratios from shared peptide species.

    Input:
        protein_matrix: rows = peptide species for one protein,
                        columns = samples,
                        values = normalized peptide intensities

    Output:
        ratio_matrix[j,k] = log ratio sample j / sample k
    """
    X = protein_matrix.astype(float).copy()
    X[X == 0] = np.nan
    logX = np.log(X)

    n_samples = X.shape[1]

    ratio_matrix = np.full((n_samples, n_samples), np.nan)
    count_matrix = np.zeros((n_samples, n_samples), dtype=int)

    for j, k in combinations(range(n_samples), 2):
        shared = np.isfinite(logX[:, j]) & np.isfinite(logX[:, k])
        n_shared = int(shared.sum())

        if n_shared < min_ratio_count:
            continue

        peptide_log_ratios = logX[shared, j] - logX[shared, k]

        if pairwise_ratio_aggregation == "median":
            log_ratio = np.nanmedian(peptide_log_ratios)
        elif pairwise_ratio_aggregation == "mean":
            log_ratio = np.nanmean(peptide_log_ratios)
        else:
            raise ValueError("pairwise_ratio_aggregation must be 'median' or 'mean'.")

        ratio_matrix[j, k] = log_ratio
        ratio_matrix[k, j] = -log_ratio

        count_matrix[j, k] = n_shared
        count_matrix[k, j] = n_shared

    return ratio_matrix, count_matrix


def solve_eq3_relative_profile(log_ratio_submatrix):
    """
    Solve Eq. 3 for one connected component.

    Eq. 3:
        minimize sum (log r_jk - log I_j + log I_k)^2

    Linearized:
        x_j - x_k = log r_jk
        where x_j = log I_j
    """
    n = log_ratio_submatrix.shape[0]

    rows = []
    values = []

    for j, k in combinations(range(n), 2):
        if not np.isfinite(log_ratio_submatrix[j, k]):
            continue

        row = np.zeros(n)
        row[j] = 1.0
        row[k] = -1.0

        rows.append(row)
        values.append(log_ratio_submatrix[j, k])

    if len(rows) == 0:
        return np.full(n, np.nan)

    A = np.asarray(rows)
    b = np.asarray(values)

    x, *_ = np.linalg.lstsq(A, b, rcond=None)

    # Convert log profile to linear relative intensities.
    profile = np.exp(x)

    return profile


# ============================================================
# Step 4. Anchor/rescale protein profile
# ============================================================
#
# After Eq. 3, the profile has only relative scale.
#
# The paper describes rescaling the profile to cumulative peptide intensity.
#
# Here:
#
#   scale = sum(peptide species intensities across component samples)
#           / sum(relative profile across component samples)
#
# Then:
#
#   LFQ_j = relative_profile_j * scale

def anchor_profile(relative_profile, anchor_vector):
    """
    Scale relative profile to cumulative peptide species intensity.

    relative_profile:
        output from Eq. 3 for a connected component

    anchor_vector:
        summed normalized peptide species intensities for the same samples
    """
    relative_profile = np.asarray(relative_profile, dtype=float)
    anchor_vector = np.asarray(anchor_vector, dtype=float)

    valid = (
        np.isfinite(relative_profile)
        & (relative_profile > 0)
        & np.isfinite(anchor_vector)
        & (anchor_vector > 0)
    )

    anchored = np.full_like(relative_profile, np.nan, dtype=float)

    if not valid.any():
        return anchored

    scale = np.nansum(anchor_vector[valid]) / np.nansum(relative_profile[valid])
    anchored[valid] = relative_profile[valid] * scale

    return anchored


def maxlfq_one_protein(protein_norm_matrix):
    """
    Calculate LFQ profile for one protein from normalized peptide species matrix.
    """
    log_ratio_matrix, count_matrix = pairwise_protein_log_ratios(protein_norm_matrix)

    labels = connected_components_from_ratio_matrix(log_ratio_matrix)

    output_profile = np.full(protein_norm_matrix.shape[1], np.nan)

    for component_id in sorted(set(labels)):
        if component_id < 0:
            continue

        sample_idx = np.where(labels == component_id)[0]

        sub_ratios = log_ratio_matrix[np.ix_(sample_idx, sample_idx)]

        relative_profile = solve_eq3_relative_profile(sub_ratios)

        # Anchor vector is the summed normalized peptide species intensity
        # per sample for this protein and component.
        anchor_vector = np.nansum(protein_norm_matrix[:, sample_idx], axis=0)

        anchored_profile = anchor_profile(relative_profile, anchor_vector)

        output_profile[sample_idx] = anchored_profile

    return output_profile


# ============================================================
# Step 5. Run protein-by-protein LFQ reconstruction
# ============================================================

records = []

for protein, protein_df in normalized_peptide_matrix.groupby(level=0, sort=True):
    protein_matrix = protein_df.values.astype(float)

    lfq_profile = maxlfq_one_protein(protein_matrix)

    row = {"Protein": protein}

    for sample, value in zip(samples, lfq_profile):
        row["LFQ intensity " + sample] = value if np.isfinite(value) and value > 0 else np.nan

    records.append(row)

calculated_lfq = pd.DataFrame(records).set_index("Protein")
calculated_lfq = calculated_lfq.apply(pd.to_numeric, errors="coerce")
calculated_lfq.to_csv(out_calculated_lfq)

print("\nCalculated LFQ matrix written to:")
print(out_calculated_lfq)


# ============================================================
# Step 6. Load actual proteinGroups.txt LFQ
# ============================================================

protein_groups = pd.read_csv(protein_groups_file, sep="\t", low_memory=False)

protein_groups["Protein"] = safe_first_protein(protein_groups["Majority protein IDs"])
protein_groups = protein_groups.set_index("Protein")

actual_lfq_cols = [c for c in protein_groups.columns if c.startswith("LFQ intensity ")]
actual_lfq = protein_groups[actual_lfq_cols].apply(pd.to_numeric, errors="coerce")
actual_lfq = actual_lfq.replace(0, np.nan)

# ============================================================
# Step 7. Compare calculated LFQ to proteinGroups LFQ
# ============================================================

common_proteins = calculated_lfq.index.intersection(actual_lfq.index)
common_cols = [c for c in calculated_lfq.columns if c in actual_lfq.columns]

if len(common_cols) == 0:
    raise ValueError(
        "No matching LFQ sample columns between calculated LFQ and proteinGroups.txt. "
        "Check sample names."
    )

all_log2_diffs = []
sample_rows = []
cellwise_rows = []

for col in common_cols:
    sample_name = col.replace("LFQ intensity ", "")

    calc = calculated_lfq.loc[common_proteins, col]
    actual = actual_lfq.loc[common_proteins, col]

    valid = (
        calc.notna()
        & actual.notna()
        & (calc > 0)
        & (actual > 0)
    )

    valid_proteins = calc.index[valid]

    diffs = np.log2(calc[valid].astype(float).values / actual[valid].astype(float).values)

    all_log2_diffs.extend(diffs.tolist())

    for protein, calc_value, actual_value, diff_value in zip(
        valid_proteins,
        calc[valid].astype(float).values,
        actual[valid].astype(float).values,
        diffs,
    ):
        cellwise_rows.append({
            "Protein": protein,
            "sample": sample_name,
            "calculated_lfq": float(calc_value),
            "proteinGroups_lfq": float(actual_value),
            "log2_calculated_over_proteinGroups": float(diff_value),
            "calculated_over_proteinGroups": float(calc_value / actual_value),
        })

    sample_rows.append({
        "sample": sample_name,
        "n_shared_values": int(valid.sum()),
        "median_log2_calc_over_actual": float(np.median(diffs)) if len(diffs) else np.nan,
        "mean_log2_calc_over_actual": float(np.mean(diffs)) if len(diffs) else np.nan,
        "mae_log2": float(np.mean(np.abs(diffs))) if len(diffs) else np.nan,
        "sum_calculated": float(calc.sum(skipna=True)),
        "sum_actual": float(actual.sum(skipna=True)),
        "log2_sum_calculated_over_actual": float(
            np.log2(calc.sum(skipna=True) / actual.sum(skipna=True))
        ) if actual.sum(skipna=True) > 0 else np.nan,
    })

cellwise_comparison = pd.DataFrame(cellwise_rows)
sample_comparison = pd.DataFrame(sample_rows)

cellwise_comparison.to_csv(out_cellwise, sep="\t", index=False)
sample_comparison.to_csv(out_sample_bias, sep="\t", index=False)

calc_total = calculated_lfq.loc[common_proteins, common_cols].sum(axis=0, skipna=True).sum()
actual_total = actual_lfq.loc[common_proteins, common_cols].sum(axis=0, skipna=True).sum()

summary = pd.DataFrame([{
    "peptide_species_file": peptide_species_file,
    "protein_groups_file": protein_groups_file,
    "input_is_long": input_is_long,
    "input_is_wide": input_is_wide,
    "peptide_species_aggregation": peptide_species_aggregation,
    "pairwise_ratio_aggregation": pairwise_ratio_aggregation,
    "min_ratio_count": min_ratio_count,
    "remove_reverse": remove_reverse,
    "remove_contaminants": remove_contaminants,
    "use_only_msms_type_rows": use_only_msms_type_rows,
    "use_only_msms_count_positive_rows": use_only_msms_count_positive_rows,
    "peptide_species_rows": int(peptide_matrix.shape[0]),
    "proteins_calculated": int(calculated_lfq.shape[0]),
    "common_proteins": int(len(common_proteins)),
    "shared_lfq_values": int(len(all_log2_diffs)),
    "median_log2_calc_over_actual": float(np.median(all_log2_diffs)) if len(all_log2_diffs) else np.nan,
    "mean_log2_calc_over_actual": float(np.mean(all_log2_diffs)) if len(all_log2_diffs) else np.nan,
    "mae_log2": float(np.mean(np.abs(all_log2_diffs))) if len(all_log2_diffs) else np.nan,
    "sample_median_range": float(
        sample_comparison["median_log2_calc_over_actual"].max()
        - sample_comparison["median_log2_calc_over_actual"].min()
    ) if len(sample_comparison) else np.nan,
    "sum_calculated": float(calc_total),
    "sum_actual": float(actual_total),
    "calc_over_actual_total": float(calc_total / actual_total) if actual_total > 0 else np.nan,
    "actual_over_calc_total": float(actual_total / calc_total) if calc_total > 0 else np.nan,
    "log2_calc_over_actual_total": float(np.log2(calc_total / actual_total)) if actual_total > 0 else np.nan,
}])

summary.to_csv(out_summary, sep="\t", index=False)


# ============================================================
# Step 8. Make diagnostic plots
# ============================================================

if len(cellwise_comparison) > 0:
    x = np.log2(cellwise_comparison["proteinGroups_lfq"].astype(float).values)
    y = np.log2(cellwise_comparison["calculated_lfq"].astype(float).values)

    finite = np.isfinite(x) & np.isfinite(y)

    min_axis = min(np.min(x[finite]), np.min(y[finite]))
    max_axis = max(np.max(x[finite]), np.max(y[finite]))

    plt.figure(figsize=(6, 6))
    plt.scatter(x[finite], y[finite], alpha=0.7)
    plt.plot([min_axis, max_axis], [min_axis, max_axis], linewidth=1)
    plt.xlabel("log2 proteinGroups LFQ")
    plt.ylabel("log2 calculated LFQ")
    plt.title("Calculated LFQ vs proteinGroups LFQ")
    plt.tight_layout()
    plt.savefig(out_plot_scatter, dpi=180)
    plt.close()

    plt.figure(figsize=(7, 4))
    plt.hist(
        cellwise_comparison["log2_calculated_over_proteinGroups"].dropna().values,
        bins=30,
    )
    plt.axvline(0, linewidth=1)
    plt.xlabel("log2(calculated LFQ / proteinGroups LFQ)")
    plt.ylabel("Count")
    plt.title("LFQ residual distribution")
    plt.tight_layout()
    plt.savefig(out_plot_residual_hist, dpi=180)
    plt.close()

if len(sample_comparison) > 0:
    plt.figure(figsize=(8, 4))
    plt.bar(
        sample_comparison["sample"],
        sample_comparison["median_log2_calc_over_actual"],
    )
    plt.axhline(0, linewidth=1)
    plt.xticks(rotation=45, ha="right")
    plt.ylabel("Median log2(calculated / proteinGroups)")
    plt.title("Per-sample median LFQ bias")
    plt.tight_layout()
    plt.savefig(out_plot_sample_bias, dpi=180)
    plt.close()

    x_pos = np.arange(len(sample_comparison))
    width = 0.4

    plt.figure(figsize=(8, 4))
    plt.bar(
        x_pos - width / 2,
        sample_comparison["sum_actual"],
        width,
        label="proteinGroups",
    )
    plt.bar(
        x_pos + width / 2,
        sample_comparison["sum_calculated"],
        width,
        label="calculated",
    )
    plt.xticks(x_pos, sample_comparison["sample"], rotation=45, ha="right")
    plt.ylabel("LFQ sum")
    plt.title("LFQ total intensity by sample")
    plt.legend()
    plt.tight_layout()
    plt.savefig(out_plot_sample_sums, dpi=180)
    plt.close()


# ============================================================
# Step 9. Print absolute output paths
# ============================================================

print("\nSample-level comparison")
print(sample_comparison.to_string(index=False))

print("\nOverall comparison")
print(summary.to_string(index=False))

print("\nWrote output directory")
print(output_dir.resolve())

print("\nWrote tables")
for path in [
    out_peptide_species_matrix,
    out_normalization,
    out_calculated_lfq,
    out_cellwise,
    out_sample_bias,
    out_summary,
]:
    print(path.resolve())

print("\nWrote plots")
for path in [
    out_plot_scatter,
    out_plot_residual_hist,
    out_plot_sample_bias,
    out_plot_sample_sums,
]:
    print(path.resolve())
