#!/usr/bin/env Rscript
# Generate a simple expression matrix and design CSV for a given seed

args <- commandArgs(trailingOnly = TRUE)
seed <- if (length(args) >= 1) as.integer(args[1]) else 1
if (is.na(seed)) seed <- 1
# optional second argument: number of genes (default 4)
ngenes <- if (length(args) >= 2) as.integer(args[2]) else 4
if (is.na(ngenes) || ngenes < 1) ngenes <- 4

# optional third/fourth args: nA and nB (defaults 3)
nA <- if (length(args) >= 3) as.integer(args[3]) else 3
if (is.na(nA) || nA < 1) nA <- 3
nB <- if (length(args) >= 4) as.integer(args[4]) else 3
if (is.na(nB) || nB < 1) nB <- 3

# optional fifth arg: max value for sampling range 1:maxval (default 20)
maxval <- if (length(args) >= 5) as.integer(args[5]) else 20
if (is.na(maxval) || maxval < 1) maxval <- 20

# If any argument is missing, print usage and the defaults/parsed values
if (length(args) < 5) {
    cat("Usage: Rscript scripts/gen_input.R [seed] [ngenes] [nA] [nB] [maxval]\n")
    cat("  seed   : integer (default 1)\n")
    cat("  ngenes : integer, number of genes (default 4)\n")
    cat("  nA     : integer, samples in group A (default 3)\n")
    cat("  nB     : integer, samples in group B (default 3)\n")
    cat("  maxval : integer, sample values drawn from 1:maxval (default 20)\n\n")
    cat("Current (resolved) values:\n")
    cat(sprintf("  seed=%d, ngenes=%d, nA=%d, nB=%d, maxval=%d\n", seed, ngenes, nA, nB, maxval))
    cat("Proceeding with these values...\n\n")
}

set.seed(seed)
group <- factor(rep(c("A","B"), c(nA, nB)))

y <- matrix(sample(1:maxval, ngenes * (nA + nB), replace = TRUE), nrow = ngenes,
            dimnames = list(paste0("G", 1:ngenes), paste0("S", 1:(nA + nB))))

dir.create("scripts", showWarnings = FALSE)
# include all CLI args in the generated filenames for traceability
mfile <- sprintf("random_%d_gene_matrix_seed%d_nA%d_nB%d_max%d.csv", ngenes, seed, nA, nB, maxval)
dfile <- sprintf("random_%d_gene_design_seed%d_nA%d_nB%d_max%d.csv", ngenes, seed, nA, nB, maxval)
write.csv(as.data.frame(y), file = mfile, row.names = TRUE)
design_df <- data.frame(sample = colnames(y), group = as.character(group), stringsAsFactors = FALSE)
write.csv(design_df, file = dfile, row.names = FALSE)
cat("Wrote:", mfile, dfile, "\n")
