#!/usr/bin/env Rscript
# Simple per-gene two-sample t-test on supplied matrix.
# No preprocessing is performed; the script directly applies t.test to each row.
# BH adjustment of p-values is applied at the end.

# ── Parse arguments ───────────────────────────────────────────────────────────
args <- commandArgs(trailingOnly = TRUE)
mat <- if (length(args) >= 1) args[1] else "random_10000gene_seed42_nA3_nB3_max50_lognorm_matrix.csv"
des <- if (length(args) >= 2) args[2] else "random_10000gene_seed42_nA3_nB3_max50_lognorm_design.csv"
if (!file.exists(mat) || !file.exists(des)) stop("input file missing")

counts <- as.matrix(read.csv(mat, row.names = 1))
design <- read.csv(des)
group <- factor(design$group)
cat("Loaded:", nrow(counts), "genes x", ncol(counts), "samples | groups:",
    paste(names(table(group)), table(group), sep="=", collapse=", "), "\n")

# convert input to log2 scale (guard against non-positive values,add 1 to avoid log(0))
logcpm <- log2(abs(counts) + 1)

# ── 5. Per-gene homoscedastic t-test (simple) ─────────────────────────────
# iterate row-wise with built-in t.test; compute fold-change and average
lvls <- levels(group)
ttbl <- apply(logcpm, 1, function(x) {
  res <- tryCatch({
    out <- t.test(x[group == lvls[2]], x[group == lvls[1]], var.equal = TRUE)
    c(logFC   = unname(out$estimate[1] - out$estimate[2]),
      AveExpr = mean(x),
      t       = unname(out$statistic),
      P.Value = out$p.value)
  }, error = function(e) {
    c(logFC = NA_real_, AveExpr = mean(x), t = NA_real_, P.Value = NA_real_)
  })
  res
})
ttest_mat <- t(ttbl)
res <- data.frame(gene=rownames(logcpm),ttest_mat)
summary(res$P.Value)
res$adj.P.Val <- p.adjust(res$P.Value, "BH")
summary(res$adj.P.Val)
res <- res[order(res$P.Value), ]
head(res)
cat("DE genes P-value < 0.05:", sum(res$P.Value<0.05,na.rm = TRUE),
    "| adj.P < 0.05:", sum(res$adj.P.Val<0.05,na.rm = TRUE),"\n")
out <- paste0(tools::file_path_sans_ext(basename(mat)),"_",
              tools::file_path_sans_ext(basename(des)),"_tTestR.csv")
if (file.exists(out)) unlink(out)
write.csv(res, out, row.names=FALSE, quote=FALSE)
cat("Results written to:", out, "\n")
