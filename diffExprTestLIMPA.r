# ============================================================
# Purpose:
#   1) Run LIMPA once through peptide -> protein quantification
#   2) Fit TWO equivalent DE parameterizations on the SAME y.protein object:
#        A. Six-group model:   ~ 0 + Group6   (Group6 = Cell_Rep)
#        B. Interaction model: ~ Cell * Experiment
#   3) Export full results for both models
#   4) Export a contrast translation table
#   5) Export detailed comparison tables and summary tables showing
#      whether the mapped contrasts agree numerically
#   6) Add observed-only group log2-median columns per protein
#      to the final DE reports, computed from the ORIGINAL data
#      without imputation, treating 0 / non-finite as missing
#   7) ACTIVATE explicit interaction-only tests (difference-in-differences)
#      and export their results as well.
#
# Biological design:
#   - Ignore treatment (C / MB / USMB)
#   - Use the 6 biological groups:
#       CT26_1, CT26_2, CT26_3, KPC_1, KPC_2, KPC_3
#   - Each sample is treated as a biological replicate (unique tumor)
#
# Files expected in the working directory:
#   - Groups.txt
#   - peptides.txt
# ============================================================

library(limpa)

set.seed(1)

labelF <- "F:/promec/TIMSTOF/LARS/2024/240605_Veronica/saga/txt/Groups.txt"
inpF   <- "F:/promec/TIMSTOF/LARS/2024/240605_Veronica/saga/txt/peptides.txt"

outdir <- "F:/promec/TIMSTOF/LARS/2024/240605_Veronica/saga/txt/limpa_models_output"
dir.create(outdir, showWarnings = FALSE)
dir.create(file.path(outdir, "six_group"), showWarnings = FALSE)
dir.create(file.path(outdir, "cell_by_experiment"), showWarnings = FALSE)
dir.create(file.path(outdir, "comparisons"), showWarnings = FALSE)
dir.create(file.path(outdir, "observed_group_medians"), showWarnings = FALSE)
dir.create(file.path(outdir, "interaction_only"), showWarnings = FALSE)

safe_median <- function(x) {
  x <- x[is.finite(x)]
  if (length(x) == 0L) return(NA_real_)
  median(x)
}

compute_observed_group_medians <- function(y.peptide, annoData, protein_col = "Leading razor protein") {
  stopifnot(protein_col %in% colnames(y.peptide$genes))

  obs_log2 <- y.peptide$E
  obs_log2[!is.finite(obs_log2)] <- NA_real_

  protein_id <- as.character(y.peptide$genes[[protein_col]])
  keep <- !is.na(protein_id) & nzchar(protein_id)
  obs_log2 <- obs_log2[keep, , drop = FALSE]
  protein_id <- protein_id[keep]

  idx_list <- split(seq_len(nrow(obs_log2)), protein_id)
  protein_ids <- names(idx_list)

  protein_sample_obs <- matrix(
    NA_real_,
    nrow = length(idx_list),
    ncol = ncol(obs_log2),
    dimnames = list(protein_ids, colnames(obs_log2))
  )

  for (i in seq_along(idx_list)) {
    idx <- idx_list[[i]]
    protein_sample_obs[i, ] <- apply(obs_log2[idx, , drop = FALSE], 2, safe_median)
  }

  group_levels <- c("CT26_1", "CT26_2", "CT26_3", "KPC_1", "KPC_2", "KPC_3")
  group_factor <- factor(annoData$Group6, levels = group_levels)

  out <- data.frame(ProteinID = rownames(protein_sample_obs), stringsAsFactors = FALSE)
  for (g in group_levels) {
    samp_idx <- which(group_factor == g)
    grp_mat <- protein_sample_obs[, samp_idx, drop = FALSE]
    out[[paste0("obs_groupMedian_log2_", g)]] <- apply(grp_mat, 1, safe_median)
    out[[paste0("obs_groupN_nonmissing_", g)]] <- apply(grp_mat, 1, function(x) sum(is.finite(x)))
  }

  list(
    protein_sample_obs = protein_sample_obs,
    protein_group_medians = out
  )
}

write_full_results <- function(fit_obj, contrast_names, out_prefix, extra_by_protein = NULL) {
  summary_list <- vector("list", length(contrast_names))
  names(summary_list) <- contrast_names

  for (cn in contrast_names) {
    tt <- topTable(fit_obj, coef = cn, number = Inf, sort.by = "P")
    tt$ProteinID <- rownames(tt)
    if (!is.null(extra_by_protein)) {
      tt <- merge(tt, extra_by_protein, by = "ProteinID", all.x = TRUE, sort = FALSE)
      rownames(tt) <- tt$ProteinID
    }
    write.csv(tt, file = paste0(out_prefix, "_", cn, ".csv"), row.names = TRUE)

    tt50 <- head(tt[order(tt$adj.P.Val, tt$P.Value), ], 50)
    tt50$Contrast <- cn
    summary_list[[cn]] <- tt50
  }

  combined_top50 <- do.call(rbind, summary_list)
  write.csv(combined_top50, file = paste0(out_prefix, "_top50_each_contrast_combined.csv"), row.names = FALSE)
}

compare_one_contrast <- function(fit_a, fit_b, coef_name, label_a, label_b) {
  tt_a <- topTable(fit_a, coef = coef_name, number = Inf, sort.by = "none")
  tt_b <- topTable(fit_b, coef = coef_name, number = Inf, sort.by = "none")
  tt_a$ProteinID <- rownames(tt_a)
  tt_b$ProteinID <- rownames(tt_b)
  merged <- merge(tt_a, tt_b, by = "ProteinID", suffixes = c(paste0("_", label_a), paste0("_", label_b)), all = FALSE)

  numeric_metrics <- c("logFC", "AveExpr", "t", "P.Value", "adj.P.Val", "B")
  summary_row <- data.frame(Contrast = coef_name, NProteinsCompared = nrow(merged), stringsAsFactors = FALSE)
  for (m in numeric_metrics) {
    a <- paste0(m, "_", label_a)
    b <- paste0(m, "_", label_b)
    if (all(c(a, b) %in% colnames(merged))) {
      diff_col <- abs(merged[[a]] - merged[[b]])
      merged[[paste0("absDiff_", m)]] <- diff_col
      summary_row[[paste0("maxAbsDiff_", m)]]  <- max(diff_col, na.rm = TRUE)
      summary_row[[paste0("meanAbsDiff_", m)]] <- mean(diff_col, na.rm = TRUE)
    }
  }
  list(detail = merged, summary = summary_row)
}

annoData <- read.table(file = labelF, header = TRUE, sep = "\t", row.names = 1, check.names = FALSE, quote = "")
stopifnot("Cell_Rep" %in% colnames(annoData))
stopifnot("Cell" %in% colnames(annoData))
stopifnot("Rep" %in% colnames(annoData))

y.peptide <- readMaxQuant(inpF)
#y.peptide <- filterNonProteotypicPeptides(y.peptide)
annoData <- annoData[colnames(y.peptide$E), , drop = FALSE]
stopifnot(identical(rownames(annoData), colnames(y.peptide$E)))

annoData$Group6 <- factor(annoData$Cell_Rep, levels = c("CT26_1", "CT26_2", "CT26_3", "KPC_1", "KPC_2", "KPC_3"))
annoData$Cell <- factor(annoData$Cell, levels = c("CT26", "KPC"))
annoData$Experiment <- factor(annoData$Rep, levels = c(1, 2, 3), labels = c("Exp1", "Exp2", "Exp3"))

cat("Computing observed-only group log2 medians per protein...\n")
obs_summary <- compute_observed_group_medians(y.peptide = y.peptide, annoData = annoData, protein_col = "Leading razor protein")
observed_group_medians <- obs_summary$protein_group_medians
write.csv(observed_group_medians, file = file.path(outdir, "observed_group_medians", "observed_group_log2_medians_per_protein.csv"), row.names = FALSE)
write.csv(obs_summary$protein_sample_obs, file = file.path(outdir, "observed_group_medians", "observed_protein_by_sample_log2_medians_from_original_data.csv"))

cat("Estimating DPC...\n")
dpcFit <- dpc(y.peptide)
pdf(file = file.path(outdir, "DPC_plot.pdf"), width = 7, height = 6)
plotDPC(dpcFit)
dev.off()

cat("Quantifying proteins with dpcQuant()...\n")
y.protein <- dpcQuant(y.peptide, "Leading razor protein", dpc = dpcFit)
write.csv(y.protein$E, file = file.path(outdir, "protein_log2_expression_matrix.csv"))

design6 <- model.matrix(~ 0 + Group6, data = annoData)
colnames(design6) <- levels(annoData$Group6)
contr6 <- makeContrasts(
  CellLine_KPC_vs_CT26 = (KPC_1 + KPC_2 + KPC_3) / 3 - (CT26_1 + CT26_2 + CT26_3) / 3,
  Exp2_vs_1_overall = (KPC_2 + CT26_2) / 2 - (KPC_1 + CT26_1) / 2,
  Exp3_vs_1_overall = (KPC_3 + CT26_3) / 2 - (KPC_1 + CT26_1) / 2,
  Exp3_vs_2_overall = (KPC_3 + CT26_3) / 2 - (KPC_2 + CT26_2) / 2,
  KPC_2_vs_1 = KPC_2 - KPC_1,
  KPC_3_vs_1 = KPC_3 - KPC_1,
  KPC_3_vs_2 = KPC_3 - KPC_2,
  CT26_2_vs_1 = CT26_2 - CT26_1,
  CT26_3_vs_1 = CT26_3 - CT26_1,
  CT26_3_vs_2 = CT26_3 - CT26_2,
  levels = design6
)

# Six-group equivalents of interaction-only tests
contr6_interactionOnly <- makeContrasts(
  Interaction_Exp2_vs_1 = (KPC_2 - KPC_1) - (CT26_2 - CT26_1),
  Interaction_Exp3_vs_1 = (KPC_3 - KPC_1) - (CT26_3 - CT26_1),
  Interaction_Exp3_vs_2 = (KPC_3 - KPC_2) - (CT26_3 - CT26_2),
  levels = design6
)

designInt <- model.matrix(~ Cell * Experiment, data = annoData)
colnames(designInt) <- c("Intercept", "CellKPC", "ExperimentExp2", "ExperimentExp3", "CellKPC_x_ExperimentExp2", "CellKPC_x_ExperimentExp3")
contrInt <- makeContrasts(
  CellLine_KPC_vs_CT26 = CellKPC + (1/3) * CellKPC_x_ExperimentExp2 + (1/3) * CellKPC_x_ExperimentExp3,
  Exp2_vs_1_overall = ExperimentExp2 + (1/2) * CellKPC_x_ExperimentExp2,
  Exp3_vs_1_overall = ExperimentExp3 + (1/2) * CellKPC_x_ExperimentExp3,
  Exp3_vs_2_overall = (ExperimentExp3 - ExperimentExp2) + (1/2) * (CellKPC_x_ExperimentExp3 - CellKPC_x_ExperimentExp2),
  KPC_2_vs_1 = ExperimentExp2 + CellKPC_x_ExperimentExp2,
  KPC_3_vs_1 = ExperimentExp3 + CellKPC_x_ExperimentExp3,
  KPC_3_vs_2 = (ExperimentExp3 - ExperimentExp2) + (CellKPC_x_ExperimentExp3 - CellKPC_x_ExperimentExp2),
  CT26_2_vs_1 = ExperimentExp2,
  CT26_3_vs_1 = ExperimentExp3,
  CT26_3_vs_2 = ExperimentExp3 - ExperimentExp2,
  levels = designInt
)

# EXPLICIT interaction-only tests (uncommented / ACTIVE)
contrIntExtra <- makeContrasts(
  Interaction_Exp2_vs_1 = CellKPC_x_ExperimentExp2,
  Interaction_Exp3_vs_1 = CellKPC_x_ExperimentExp3,
  Interaction_Exp3_vs_2 = CellKPC_x_ExperimentExp3 - CellKPC_x_ExperimentExp2,
  levels = designInt
)

translation_table <- data.frame(
  Contrast = c(
    "CellLine_KPC_vs_CT26", "Exp2_vs_1_overall", "Exp3_vs_1_overall", "Exp3_vs_2_overall",
    "KPC_2_vs_1", "KPC_3_vs_1", "KPC_3_vs_2", "CT26_2_vs_1", "CT26_3_vs_1", "CT26_3_vs_2",
    "Interaction_Exp2_vs_1", "Interaction_Exp3_vs_1", "Interaction_Exp3_vs_2"
  ),
  SixGroupFormula = c(
    "(KPC_1 + KPC_2 + KPC_3)/3 - (CT26_1 + CT26_2 + CT26_3)/3",
    "(KPC_2 + CT26_2)/2 - (KPC_1 + CT26_1)/2",
    "(KPC_3 + CT26_3)/2 - (KPC_1 + CT26_1)/2",
    "(KPC_3 + CT26_3)/2 - (KPC_2 + CT26_2)/2",
    "KPC_2 - KPC_1",
    "KPC_3 - KPC_1",
    "KPC_3 - KPC_2",
    "CT26_2 - CT26_1",
    "CT26_3 - CT26_1",
    "CT26_3 - CT26_2",
    "(KPC_2 - KPC_1) - (CT26_2 - CT26_1)",
    "(KPC_3 - KPC_1) - (CT26_3 - CT26_1)",
    "(KPC_3 - KPC_2) - (CT26_3 - CT26_2)"
  ),
  InteractionFormula = c(
    "CellKPC + (1/3)*CellKPC_x_ExperimentExp2 + (1/3)*CellKPC_x_ExperimentExp3",
    "ExperimentExp2 + (1/2)*CellKPC_x_ExperimentExp2",
    "ExperimentExp3 + (1/2)*CellKPC_x_ExperimentExp3",
    "(ExperimentExp3 - ExperimentExp2) + (1/2)*(CellKPC_x_ExperimentExp3 - CellKPC_x_ExperimentExp2)",
    "ExperimentExp2 + CellKPC_x_ExperimentExp2",
    "ExperimentExp3 + CellKPC_x_ExperimentExp3",
    "(ExperimentExp3 - ExperimentExp2) + (CellKPC_x_ExperimentExp3 - CellKPC_x_ExperimentExp2)",
    "ExperimentExp2",
    "ExperimentExp3",
    "ExperimentExp3 - ExperimentExp2",
    "CellKPC_x_ExperimentExp2",
    "CellKPC_x_ExperimentExp3",
    "CellKPC_x_ExperimentExp3 - CellKPC_x_ExperimentExp2"
  ),
  Comment = c(
    "Equal-weight average KPC-vs-CT26 difference across experiments.",
    "Equal-weight average Exp2-vs-Exp1 difference across both cell lines.",
    "Equal-weight average Exp3-vs-Exp1 difference across both cell lines.",
    "Equal-weight average Exp3-vs-Exp2 difference across both cell lines.",
    "KPC-specific Exp2-vs-Exp1 effect.",
    "KPC-specific Exp3-vs-Exp1 effect.",
    "KPC-specific Exp3-vs-Exp2 effect.",
    "CT26-specific Exp2-vs-Exp1 effect.",
    "CT26-specific Exp3-vs-Exp1 effect.",
    "CT26-specific Exp3-vs-Exp2 effect.",
    "Difference-in-differences: does Exp2-vs-Exp1 differ between KPC and CT26?",
    "Difference-in-differences: does Exp3-vs-Exp1 differ between KPC and CT26?",
    "Difference-in-differences: does Exp3-vs-Exp2 differ between KPC and CT26?"
  ),
  stringsAsFactors = FALSE
)
write.csv(translation_table, file = file.path(outdir, "comparisons", "contrast_translation_table.csv"), row.names = FALSE)

cat("Fitting six-group model with dpcDE()...\n")
pdf(file = file.path(outdir, "six_group", "dpcDE_variance_trend_six_group.pdf"), width = 7, height = 6)
fit6_base <- dpcDE(y.protein, design6, plot = TRUE)
dev.off()
fit6 <- eBayes(contrasts.fit(fit6_base, contr6))
fit6_interactionOnly <- eBayes(contrasts.fit(fit6_base, contr6_interactionOnly))

cat("Fitting Cell * Experiment model with dpcDE()...\n")
pdf(file = file.path(outdir, "cell_by_experiment", "dpcDE_variance_trend_cell_by_experiment.pdf"), width = 7, height = 6)
fitInt_base <- dpcDE(y.protein, designInt, plot = TRUE)
dev.off()
fitInt <- eBayes(contrasts.fit(fitInt_base, contrInt))
fitIntExtra <- eBayes(contrasts.fit(fitInt_base, contrIntExtra))

contrast_names <- colnames(contr6)
write_full_results(fit6, contrast_names, file.path(outdir, "six_group", "limpa_six_group"), observed_group_medians)
write_full_results(fitInt, contrast_names, file.path(outdir, "cell_by_experiment", "limpa_cell_by_experiment"), observed_group_medians)

# Write explicit interaction-only test results
interaction_names <- colnames(contrIntExtra)
write_full_results(fit6_interactionOnly, interaction_names, file.path(outdir, "interaction_only", "limpa_six_group_interaction_only"), observed_group_medians)
write_full_results(fitIntExtra, interaction_names, file.path(outdir, "interaction_only", "limpa_cell_by_experiment_interaction_only"), observed_group_medians)

# Compare mapped 10 main contrasts
comparison_summary_list <- vector("list", length(contrast_names))
names(comparison_summary_list) <- contrast_names
for (cn in contrast_names) {
  cmp <- compare_one_contrast(fit6, fitInt, cn, "six", "int")
  write.csv(cmp$detail, file = file.path(outdir, "comparisons", paste0("comparison_detail_", cn, ".csv")), row.names = FALSE)
  comparison_summary_list[[cn]] <- cmp$summary
}
comparison_summary <- do.call(rbind, comparison_summary_list)
write.csv(comparison_summary, file = file.path(outdir, "comparisons", "comparison_summary_all_contrasts.csv"), row.names = FALSE)

# Compare explicit interaction-only contrasts between the two parameterizations
interaction_comparison_list <- vector("list", length(interaction_names))
names(interaction_comparison_list) <- interaction_names
for (cn in interaction_names) {
  cmp <- compare_one_contrast(fit6_interactionOnly, fitIntExtra, cn, "six", "int")
  write.csv(cmp$detail, file = file.path(outdir, "comparisons", paste0("comparison_detail_", cn, ".csv")), row.names = FALSE)
  interaction_comparison_list[[cn]] <- cmp$summary
}
interaction_comparison_summary <- do.call(rbind, interaction_comparison_list)
write.csv(interaction_comparison_summary, file = file.path(outdir, "comparisons", "comparison_summary_interaction_only.csv"), row.names = FALSE)

# Direct matrix-level comparisons
coef_diff <- abs(fit6$coefficients[, contrast_names, drop = FALSE] - fitInt$coefficients[, contrast_names, drop = FALSE])
coef_diff_summary <- data.frame(Contrast = contrast_names, maxAbsDiff_logFC = apply(coef_diff, 2, max, na.rm = TRUE), meanAbsDiff_logFC = apply(coef_diff, 2, mean, na.rm = TRUE), stringsAsFactors = FALSE)
write.csv(coef_diff_summary, file = file.path(outdir, "comparisons", "comparison_summary_direct_logFC_from_fit.csv"), row.names = FALSE)

coef_diff_intonly <- abs(fit6_interactionOnly$coefficients[, interaction_names, drop = FALSE] - fitIntExtra$coefficients[, interaction_names, drop = FALSE])
coef_diff_intonly_summary <- data.frame(Contrast = interaction_names, maxAbsDiff_logFC = apply(coef_diff_intonly, 2, max, na.rm = TRUE), meanAbsDiff_logFC = apply(coef_diff_intonly, 2, mean, na.rm = TRUE), stringsAsFactors = FALSE)
write.csv(coef_diff_intonly_summary, file = file.path(outdir, "comparisons", "comparison_summary_direct_logFC_interaction_only_from_fit.csv"), row.names = FALSE)

if (!is.null(fit6$t) && !is.null(fitInt$t)) {
  t_diff <- abs(fit6$t[, contrast_names, drop = FALSE] - fitInt$t[, contrast_names, drop = FALSE])
  t_diff_summary <- data.frame(Contrast = contrast_names, maxAbsDiff_t = apply(t_diff, 2, max, na.rm = TRUE), meanAbsDiff_t = apply(t_diff, 2, mean, na.rm = TRUE), stringsAsFactors = FALSE)
  write.csv(t_diff_summary, file = file.path(outdir, "comparisons", "comparison_summary_direct_t_from_fit.csv"), row.names = FALSE)
}
if (!is.null(fit6_interactionOnly$t) && !is.null(fitIntExtra$t)) {
  t_diff <- abs(fit6_interactionOnly$t[, interaction_names, drop = FALSE] - fitIntExtra$t[, interaction_names, drop = FALSE])
  t_diff_summary <- data.frame(Contrast = interaction_names, maxAbsDiff_t = apply(t_diff, 2, max, na.rm = TRUE), meanAbsDiff_t = apply(t_diff, 2, mean, na.rm = TRUE), stringsAsFactors = FALSE)
  write.csv(t_diff_summary, file = file.path(outdir, "comparisons", "comparison_summary_direct_t_interaction_only_from_fit.csv"), row.names = FALSE)
}
if (!is.null(fit6$p.value) && !is.null(fitInt$p.value)) {
  p_diff <- abs(fit6$p.value[, contrast_names, drop = FALSE] - fitInt$p.value[, contrast_names, drop = FALSE])
  p_diff_summary <- data.frame(Contrast = contrast_names, maxAbsDiff_PValue = apply(p_diff, 2, max, na.rm = TRUE), meanAbsDiff_PValue = apply(p_diff, 2, mean, na.rm = TRUE), stringsAsFactors = FALSE)
  write.csv(p_diff_summary, file = file.path(outdir, "comparisons", "comparison_summary_direct_pvalue_from_fit.csv"), row.names = FALSE)
}
if (!is.null(fit6_interactionOnly$p.value) && !is.null(fitIntExtra$p.value)) {
  p_diff <- abs(fit6_interactionOnly$p.value[, interaction_names, drop = FALSE] - fitIntExtra$p.value[, interaction_names, drop = FALSE])
  p_diff_summary <- data.frame(Contrast = interaction_names, maxAbsDiff_PValue = apply(p_diff, 2, max, na.rm = TRUE), meanAbsDiff_PValue = apply(p_diff, 2, mean, na.rm = TRUE), stringsAsFactors = FALSE)
  write.csv(p_diff_summary, file = file.path(outdir, "comparisons", "comparison_summary_direct_pvalue_interaction_only_from_fit.csv"), row.names = FALSE)
}

saveRDS(list(
  annoData = annoData,
  dpcFit = dpcFit,
  y.peptide = y.peptide,
  y.protein = y.protein,
  observed_group_medians = observed_group_medians,
  observed_protein_sample_matrix = obs_summary$protein_sample_obs,
  design6 = design6,
  contr6 = contr6,
  contr6_interactionOnly = contr6_interactionOnly,
  fit6 = fit6,
  fit6_interactionOnly = fit6_interactionOnly,
  designInt = designInt,
  contrInt = contrInt,
  contrIntExtra = contrIntExtra,
  fitInt = fitInt,
  fitIntExtra = fitIntExtra,
  translation_table = translation_table,
  comparison_summary = comparison_summary,
  interaction_comparison_summary = interaction_comparison_summary
), file = file.path(outdir, "limpa_both_models_analysis_objects.rds"))

writeLines(capture.output(sessionInfo()), con = file.path(outdir, "limpa_sessionInfo.txt"))

file_index <- data.frame(
  Path = c(
    file.path(outdir, "DPC_plot.pdf"),
    file.path(outdir, "protein_log2_expression_matrix.csv"),
    file.path(outdir, "observed_group_medians", "observed_group_log2_medians_per_protein.csv"),
    file.path(outdir, "comparisons", "contrast_translation_table.csv"),
    file.path(outdir, "comparisons", "comparison_summary_all_contrasts.csv"),
    file.path(outdir, "comparisons", "comparison_summary_interaction_only.csv"),
    file.path(outdir, "comparisons", "comparison_summary_direct_logFC_from_fit.csv"),
    file.path(outdir, "comparisons", "comparison_summary_direct_logFC_interaction_only_from_fit.csv"),
    file.path(outdir, "limpa_both_models_analysis_objects.rds"),
    file.path(outdir, "limpa_sessionInfo.txt")
  ),
  Description = c(
    "DPC plot from dpc()",
    "Protein-level log2 expression matrix from dpcQuant()",
    "Observed-only group log2 medians per protein from original data (0/non-finite treated as missing)",
    "Side-by-side contrast translation table including interaction-only tests",
    "One-row-per-contrast summary of differences for the 10 mapped biological contrasts",
    "One-row-per-contrast summary of differences for the 3 explicit interaction-only tests",
    "Direct comparison of fitted contrast logFC values for the 10 mapped contrasts",
    "Direct comparison of fitted contrast logFC values for the 3 interaction-only tests",
    "Saved R objects from the analysis",
    "sessionInfo()"
  ),
  stringsAsFactors = FALSE
)
write.csv(file_index, file = file.path(outdir, "file_index.csv"), row.names = FALSE)

cat("\nAnalysis complete. Outputs written under:\n")
cat(normalizePath(outdir), "\n")
