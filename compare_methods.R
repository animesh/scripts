#!/usr/bin/env Rscript
# Compare p-values between two result files (e.g. limma and t-test outputs).
# Usage: Rscript compare_methods.R file1.csv file2.csv
# Output: prints summary and writes scatter plots.

# default result files (same as used by run_limma.R and run_tTest.R)
default1 <- "random_10000gene_seed42_nA3_nB3_max50_lognorm_matrix_random_10000gene_seed42_nA3_nB3_max50_lognorm_design_limmaR.csv"
default2 <- "random_10000gene_seed42_nA3_nB3_max50_lognorm_matrix_random_10000gene_seed42_nA3_nB3_max50_lognorm_design_tTestR.csv"
args <- commandArgs(trailingOnly = TRUE)
if (length(args) >= 2) {
  file1 <- args[1]
  file2 <- args[2]
} else if (length(args) == 1) {
  file1 <- args[1]
  file2 <- default2
  cat("Using default second file:", file2, "\n")
} else {
  file1 <- default1
  file2 <- default2
  cat("No arguments provided, using defaults:\n  ", file1, "\n  ", file2, "\n")
}
if (!file.exists(file1) || !file.exists(file2)) stop("one or both files not found")

res1 <- read.csv(file1)
res2 <- read.csv(file2)
for (col in c("gene","P.Value","adj.P.Val")) {
  if (!(col %in% names(res1))) stop(file1, " missing column ", col)
  if (!(col %in% names(res2))) stop(file2, " missing column ", col)
}

# merge on gene
merged <- merge(res1, res2, by = "gene", suffixes = c(".1",".2"))
cat("Merged", nrow(merged), "genes\n")

# additional logFC diagnostics if both present
if (all(c("logFC.1","logFC.2") %in% names(merged))) {
  corval <- cor(merged$logFC.1, merged$logFC.2, use = "pairwise.complete.obs")
  cat("Correlation logFC1 vs logFC2:", corval, "\n")
  diff <- merged$logFC.1 - merged$logFC.2
  cat("Difference summary:\n")
  print(summary(diff))
  # we will plot these in the PDF later as extra pages
}
# additional t-statistic diagnostics: expect columns 't.1' and 't.2'
tcol1 <- if ("t.1" %in% names(merged)) "t.1" else NULL
tcol2 <- if ("t.2" %in% names(merged)) "t.2" else NULL
if (!is.null(tcol1) && !is.null(tcol2)) {
  cor_t <- cor(merged[[tcol1]], merged[[tcol2]], use = "pairwise.complete.obs")
  cat("Correlation t-stat1 vs t-stat2:", cor_t, "\n")
  cat("t difference summary:\n")
  print(summary(merged[[tcol1]] - merged[[tcol2]]))
}

# color points by mean logFC across the two files if available
color_vec <- rgb(0,0,0,0.5)  # fallback grey
if (all(c("logFC.1","logFC.2") %in% names(merged))) {
  meanFC <- rowMeans(merged[,c("logFC.1","logFC.2")], na.rm=TRUE)
  # simple blue-white-red gradient centered at zero
  ramp <- colorRampPalette(c("blue","white","red"))
  cols <- ramp(100)
  norm <- (meanFC - min(meanFC, na.rm=TRUE)) /
          (max(meanFC, na.rm=TRUE) - min(meanFC, na.rm=TRUE))
  color_vec <- cols[pmax(1, pmin(100, ceiling(norm*99)))]
  cat("Coloring points by mean logFC\n")
}

# summaries
cat("Summary P.Value in file1:\n")
print(summary(merged$P.Value.1))
cat("Summary P.Value in file2:\n")
print(summary(merged$P.Value.2))

# determine a descriptive output name using common prefix and test types
name1 <- basename(file1)
name2 <- basename(file2)
# determine common prefix character-by-character
chars1 <- strsplit(name1, "", fixed=TRUE)[[1]]
chars2 <- strsplit(name2, "", fixed=TRUE)[[1]]
matchlen <- 0
for (i in seq_len(min(length(chars1), length(chars2)))) {
  if (chars1[i] == chars2[i]) matchlen <- i else break
}
common <- paste(chars1[seq_len(matchlen)], collapse="")
# remove trailing underscores or dots
common <- sub("[_.]+$", "", common)
if (nchar(common) == 0) common <- "comparison"
# test identifiers
test1 <- sub(".*_(.*)\\.csv$", "\\1", name1)
test2 <- sub(".*_(.*)\\.csv$", "\\1", name2)
pdfname <- paste0(common, "_", test1, "_vs_", test2, ".pdf")

# create a PDF with both comparisons
pdf(pdfname, width=6, height=6)
# raw p-values
plot(merged$P.Value.1, merged$P.Value.2,
     xlab=paste0("P.Value (", test1, ")"),
     ylab=paste0("P.Value (", test2, ")"),
     main="Raw p-value comparison", pch=20, col=color_vec)
abline(0,1,col="red")
# adjusted p-values on next page
plot(merged$adj.P.Val.1, merged$adj.P.Val.2,
     xlab=paste0("adj.P.Val (", test1, ")"),
     ylab=paste0("adj.P.Val (", test2, ")"),
     main="Adjusted p-value comparison", pch=20, col=color_vec)
abline(0,1,col="red")
# additional logFC diagnostics
if (all(c("logFC.1","logFC.2") %in% names(merged))) {
  plot(merged$logFC.1, merged$logFC.2,
       xlab=paste0("logFC (", test1, ")"), ylab=paste0("logFC (", test2, ")"),
       main="logFC scatter", pch=20, col=color_vec)
  plot(merged$logFC.1 - merged$logFC.2,
       main="logFC difference", ylab=paste0("", test1, " - ", test2), pch=20, col=color_vec)
}
# t-stat scatter (using tcol1/tcol2)
if (!is.null(tcol1) && !is.null(tcol2)) {
  plot(merged[[tcol1]], merged[[tcol2]],
       xlab=paste0("t (", test1, ")"), ylab=paste0("t (", test2, ")"),
       main="t-stat comparison", pch=20, col=color_vec)
  # t difference plot
  plot(merged[[tcol1]] - merged[[tcol2]],
       main="t difference", ylab=paste0(test1, " - ", test2), pch=20, col=color_vec)
}
dev.off()
cat("Plots saved to pvalue_comparison.pdf\n")
