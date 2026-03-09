#!/usr/bin/env Rscript
# Minimal generator: uniform, poisson, normal, negbin; optional rescale to 1..maxval
args <- commandArgs(trailingOnly = TRUE)

as_int <- function(x, d) { v <- if (!is.na(x)) as.integer(x) else NA; if (is.na(v) || v < 1) d else v }

seed   <- if (length(args) >= 1) as.integer(args[1]) else 1
ngenes <- as_int(if (length(args) >= 2) args[2] else NA, 4)
nA     <- as_int(if (length(args) >= 3) args[3] else NA, 3)
nB     <- as_int(if (length(args) >= 4) args[4] else NA, 3)
maxval <- as_int(if (length(args) >= 5) args[5] else NA, 20)

dist   <- tolower(if (length(args) >= 6) args[6] else "uniform")
param1 <- if (length(args) >= 7) as.numeric(args[7]) else NA
param2 <- if (length(args) >= 8) as.numeric(args[8]) else NA
rescale_flag <- FALSE
if (length(args) >= 9) rescale_flag <- tolower(args[9]) %in% c("yes","y","true","1","rescale")

if (!(dist %in% c("uniform","poisson","normal","nb","negbin"))) dist <- "uniform"

set.seed(ifelse(is.na(seed), 1, seed))
n <- ngenes * (nA + nB)

vals <- switch(dist,
  uniform = sample(1:maxval, n, replace = TRUE),
  poisson = {
    lambda <- ifelse(is.na(param1), maxval, param1)
    rpois(n, lambda = lambda)
  },
  normal = {
    mu <- ifelse(is.na(param1), 0, param1)
    sdv <- ifelse(is.na(param2), 1, param2)
    rnorm(n, mean = mu, sd = sdv)
  },
  nb = ,
  negbin = {
    mu <- ifelse(is.na(param1), maxval, param1)
    size <- ifelse(is.na(param2), 1, param2)
    rnbinom(n, size = size, mu = mu)
  },
  sample(1:maxval, n, replace = TRUE)
)

if (rescale_flag) {
  vmin <- min(vals)
  vmax <- max(vals)
  if (vmax == vmin) {
    vals <- rep(round((maxval + 1) / 2), length(vals))
  } else {
    vals <- round((vals - vmin) / (vmax - vmin) * (maxval - 1) + 1)
  }
} else {
  vals <- round(vals)
  vals[vals < 1] <- 1
  vals[vals > maxval] <- maxval
}

y <- matrix(vals, nrow = ngenes,
            dimnames = list(paste0("G", seq_len(ngenes)), paste0("S", seq_len(nA + nB))))

fmt <- function(x, na = "auto") {
  if (is.na(x)) return(na)
  gsub("\\.", "p", format(x, scientific = FALSE))
}

suffix <- if (rescale_flag) "_rescaled" else ""
if (dist %in% c("poisson")) {
  p1 <- fmt(param1, maxval)
  mfile <- sprintf("random_%d_gene_matrix_seed%d_nA%d_nB%d_max%d_dist%s_param1_%s%s.csv",
                   ngenes, seed, nA, nB, maxval, dist, p1, suffix)
  dfile <- sprintf("random_%d_gene_design_seed%d_nA%d_nB%d_max%d_dist%s_param1_%s%s.csv",
                   ngenes, seed, nA, nB, maxval, dist, p1, suffix)
} else if (dist == "normal") {
  p1 <- fmt(param1, 0); p2 <- fmt(param2, 1)
  mfile <- sprintf("random_%d_gene_matrix_seed%d_nA%d_nB%d_max%d_dist%s_param1_%s_param2_%s%s.csv",
                   ngenes, seed, nA, nB, maxval, dist, p1, p2, suffix)
  dfile <- sprintf("random_%d_gene_design_seed%d_nA%d_nB%d_max%d_dist%s_param1_%s_param2_%s%s.csv",
                   ngenes, seed, nA, nB, maxval, dist, p1, p2, suffix)
} else if (dist %in% c("nb","negbin")) {
  p1 <- fmt(param1, maxval); p2 <- fmt(param2, 1)
  mfile <- sprintf("random_%d_gene_matrix_seed%d_nA%d_nB%d_max%d_distnb_param1_%s_param2_%s%s.csv",
                   ngenes, seed, nA, nB, maxval, p1, p2, suffix)
  dfile <- sprintf("random_%d_gene_design_seed%d_nA%d_nB%d_max%d_distnb_param1_%s_param2_%s%s.csv",
                   ngenes, seed, nA, nB, maxval, p1, p2, suffix)
} else {
  mfile <- sprintf("random_%d_gene_matrix_seed%d_nA%d_nB%d_max%d_dist%s%s.csv",
                   ngenes, seed, nA, nB, maxval, dist, suffix)
  dfile <- sprintf("random_%d_gene_design_seed%d_nA%d_nB%d_max%d_dist%s%s.csv",
                   ngenes, seed, nA, nB, maxval, dist, suffix)
}

dir.create("scripts", showWarnings = FALSE)
write.csv(as.data.frame(y), file = mfile, row.names = TRUE)
design_df <- data.frame(sample = colnames(y), group = rep(c("A","B"), c(nA, nB)), stringsAsFactors = FALSE)
write.csv(design_df, file = dfile, row.names = FALSE)
cat("Wrote:", mfile, dfile, "\n")
