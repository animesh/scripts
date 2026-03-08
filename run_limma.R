#!/usr/bin/env Rscript
# Run limma on matrix+design CSVs and write results as CSV

args <- commandArgs(trailingOnly = TRUE)
# default files created by scripts/gen_input.R
default_mat <- "random_10000gene_seed42_nA3_nB3_max50_lognorm_matrix.csv"
default_design <- "random_10000gene_seed42_nA3_nB3_max50_lognorm_design.csv"
if (length(args) < 2) {
  if (length(args) == 0) {
    matrix_file <- default_mat
    design_file <- default_design
    cat("No args provided — using defaults:\n  matrix=", matrix_file, "\n  design=", design_file, "\n", sep = "")
  } else if (length(args) == 1) {
    matrix_file <- args[1]
    design_file <- default_design
    cat("Only matrix arg provided — using design default:\n  matrix=", matrix_file, "\n  design=", design_file, "\n", sep = "")
  }
} else {
  matrix_file <- args[1]
  design_file <- args[2]
}
if (!file.exists(matrix_file)) stop("matrix file not found: ", matrix_file)
if (!file.exists(design_file)) stop("design file not found: ", design_file)

y <- as.matrix(read.csv(matrix_file, row.names = 1))
design <- read.csv(design_file, stringsAsFactors = FALSE)
# convert input to log2 scale (guard against non-positive values,add 1 to avoid log(0))
y <- log2(abs(y) + 1)
if (!"group" %in% names(design)) stop("design file must contain a 'group' column")
group <- factor(design$group)

if (!requireNamespace("limma", quietly = TRUE)) stop("Please install the 'limma' package")

design_mat <- model.matrix(~ group)
lfit <- limma::lmFit(y, design_mat)
leB <- limma::eBayes(lfit)

meanA <- rowMeans(y[, group == levels(group)[1], drop = FALSE])
meanB <- rowMeans(y[, group == levels(group)[2], drop = FALSE])
logFC <- meanB - meanA

res <- data.frame(
  gene = rownames(y),
  logFC = logFC,
  AveExpr = rowMeans(y),
  t = leB$t[, 2],
  P.Value = leB$p.value[, 2],
  adj.P.Val = p.adjust(leB$p.value[, 2], method = "BH"),
  stringsAsFactors = FALSE
)
res <- res[order(res$P.Value), ]
head(res)
cat("DE genes P-value < 0.05:", sum(res$P.Value<0.05,na.rm = TRUE),
    "| adj.P < 0.05:", sum(res$adj.P.Val<0.05,na.rm = TRUE),"\n")

# build output path: <matrix_base>_<design_base>_limmaR.csv
mbase <- tools::file_path_sans_ext(basename(matrix_file))
dbase <- tools::file_path_sans_ext(basename(design_file))
outpath <- paste0(mbase, "_", dbase, "_limmaR.csv")
write.csv(res, file = outpath, row.names = FALSE, quote = FALSE)
cat("result in: ", outpath, "\n", sep = "")
