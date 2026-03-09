#!/usr/bin/env Rscript
# Differential expression analysis using homoscedastic two-sample t-tests.
#
# Preprocessing matches run_limma.R for fair comparison:
#   1. DGEList for integrated count + library-size bookkeeping
#   2. Low-count filtering via edgeR::filterByExpr()
#   3. TMM normalization via edgeR::calcNormFactors()
#   4. log2-CPM transformation (mirrors voom's input scale)
#   5. Per-gene t.test(var.equal = TRUE) — homoscedastic two-sample t-test
#   6. BH-adjusted p-values via p.adjust()

# ── Parse arguments ───────────────────────────────────────────────────────────
args <- commandArgs(trailingOnly = TRUE)
mat <- if (length(args) >= 1) args[1] else "random_10000gene_seed42_nA3_nB3_max50_lognorm_matrix.csv"
des <- if (length(args) >= 2) args[2] else "random_10000gene_seed42_nA3_nB3_max50_lognorm_design.csv"
if (!file.exists(mat) || !file.exists(des)) stop("input file missing")

if (!requireNamespace("edgeR", quietly = TRUE)) stop("install edgeR")
counts <- as.matrix(read.csv(mat, row.names = 1))
design <- read.csv(des)
group <- factor(design$group)
cat("Loaded:", nrow(counts), "genes x", ncol(counts), "samples | groups:",
    paste(names(table(group)), table(group), sep="=", collapse=", "), "\n")

dge <- edgeR::DGEList(counts = counts, group = group)
keep <- edgeR::filterByExpr(dge, model.matrix(~0 + group))
dge <- dge[keep,,keep.lib.sizes=FALSE]
cat("Genes after low-count filter:", sum(keep),"/",length(keep),"removed",sum(!keep),"\n")
dge <- edgeR::calcNormFactors(dge)
logcpm <- edgeR::cpm(dge, log=TRUE, prior.count=0.5)

# ── 5. Per-gene homoscedastic t-test (simple) ─────────────────────────────
# iterate row-wise with built-in t.test; compute fold-change and average
lvls <- levels(group)
ttbl <- apply(logcpm, 1, function(x) {
  out <- t.test(x[group == lvls[2]], x[group == lvls[1]], var.equal = TRUE)
  c(logFC   = unname(out$estimate[1] - out$estimate[2]),
    AveExpr = mean(x),
    t       = unname(out$statistic),
    P.Value = out$p.value)
})
ttest_mat <- t(ttbl)

res <- data.frame(gene=rownames(logcpm), ttest_mat)
res$adj.P.Val <- p.adjust(res$P.Value, "BH")
res <- res[order(res$P.Value), ]
cat("DE genes adj.P < 0.05:", sum(res$adj.P.Val<0.05),
    "| adj.P < 0.01:", sum(res$adj.P.Val<0.01),"\n")
out <- paste0(tools::file_path_sans_ext(basename(mat)),"_",
              tools::file_path_sans_ext(basename(des)),"_tTestR.csv")
write.csv(res, out, row.names=FALSE, quote=FALSE)
cat("Results written to:", out, "\n")
