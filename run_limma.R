#!/usr/bin/env Rscript
# Differential expression analysis using the limma-voom pipeline.
#
# Best practices applied:
#   1. DGEList for integrated count + library-size bookkeeping
#   2. Low-count filtering via edgeR::filterByExpr()
#   3. TMM normalization via edgeR::calcNormFactors()
#   4. Precision weights via limma::voom()
#   5. Explicit contrast via limma::makeContrasts() + contrasts.fit()
#   6. Moderated t-statistics via limma::eBayes()
#   7. BH-adjusted p-values via limma::topTable()

# ── Parse arguments ───────────────────────────────────────────────────────────
args           <- commandArgs(trailingOnly = TRUE)
default_mat    <- "random_10000gene_seed42_nA3_nB3_max50_lognorm_matrix.csv"
default_design <- "random_10000gene_seed42_nA3_nB3_max50_lognorm_design.csv"

if (length(args) == 0) {
  matrix_file <- default_mat
  design_file <- default_design
  cat("No args — using defaults:\n  matrix=", matrix_file,
      "\n  design=", design_file, "\n", sep = "")
} else if (length(args) == 1) {
  matrix_file <- args[1]
  design_file <- default_design
  cat("Using default design:", design_file, "\n")
} else {
  matrix_file <- args[1]
  design_file <- args[2]
}
if (!file.exists(matrix_file)) stop("matrix file not found: ", matrix_file)
if (!file.exists(design_file)) stop("design file not found: ", design_file)

# ── Check packages ────────────────────────────────────────────────────────────
for (pkg in c("limma", "edgeR")) {
  if (!requireNamespace(pkg, quietly = TRUE))
    stop("Please install '", pkg, "' before running this script.")
}

# ── Load data ─────────────────────────────────────────────────────────────────
counts <- as.matrix(read.csv(matrix_file, row.names = 1))
design <- read.csv(design_file)
if (!"group" %in% names(design)) stop("design file must contain a 'group' column")
group  <- factor(design$group)
cat(sprintf("Loaded: %d genes x %d samples  |  groups: %s\n",
            nrow(counts), ncol(counts),
            paste(paste0(names(table(group)), "=", table(group)), collapse = ", ")))

# ── 1. DGEList ────────────────────────────────────────────────────────────────
dge <- edgeR::DGEList(counts = counts, group = group)

# ── 2. Low-count filtering ────────────────────────────────────────────────────
# Keeps genes with CPM > ~10/median_lib_size in at least min.count samples.
# Removes noise genes that cannot be reliably tested.
design_mat <- model.matrix(~ 0 + group)
colnames(design_mat) <- levels(group)
keep <- edgeR::filterByExpr(dge, design_mat)
dge  <- dge[keep, , keep.lib.sizes = FALSE]
cat(sprintf("Genes after low-count filter: %d / %d (removed %d)\n",
            sum(keep), length(keep), sum(!keep)))

# ── 3. TMM normalization ──────────────────────────────────────────────────────
# Corrects for compositional differences in library size across samples.
dge <- edgeR::calcNormFactors(dge, method = "TMM")

# ── 4. Voom ───────────────────────────────────────────────────────────────────
# Estimates mean-variance trend and assigns precision weights per observation,
# making count data suitable for limma's linear model framework.
v    <- limma::voom(dge, design_mat)
lfit <- limma::lmFit(v, design_mat)

# ── 5. Contrast: second group vs first (alphabetical) ────────────────────────
lvls         <- levels(group)
contrast_str <- paste0(lvls[2], " - ", lvls[1])
cm           <- limma::makeContrasts(contrasts = contrast_str, levels = design_mat)
lfit         <- limma::contrasts.fit(lfit, cm)

# ── 6. Empirical Bayes moderation ─────────────────────────────────────────────
# Borrows variance information across genes to stabilise per-gene variance
# estimates — especially important for small sample sizes.
leB <- limma::eBayes(lfit)

# ── 7. Extract and write results ──────────────────────────────────────────────
# topTable returns logFC, AveExpr, t, P.Value, adj.P.Val (BH), B (log-odds DE)
res <- limma::topTable(leB, coef = 1, number = Inf,
                       adjust.method = "BH", sort.by = "P")
res <- cbind(gene = rownames(res), res)
rownames(res) <- NULL

cat(sprintf("DE genes adj.P < 0.05: %d  |  adj.P < 0.01: %d\n",
            sum(res$adj.P.Val < 0.05), sum(res$adj.P.Val < 0.01)))

# print top results to console as well
print(head(res))

mbase   <- tools::file_path_sans_ext(basename(matrix_file))
dbase   <- tools::file_path_sans_ext(basename(design_file))
outpath <- paste0(mbase, "_", dbase, "_limmaR.csv")
write.csv(res, file = outpath, row.names = FALSE, quote = FALSE)
cat("Results written to:", outpath, "\n")
