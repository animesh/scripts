#!/usr/bin/env Rscript
# Generate a simulated expression matrix and sample design CSV.

# ── Helpers ───────────────────────────────────────────────────────────────────
parse_int <- function(x, default, min_val = 1L) {
  v <- suppressWarnings(as.integer(x))
  if (is.na(v) || v < min_val) default else v
}

parse_num <- function(x, default, min_val = 0) {
  v <- suppressWarnings(as.numeric(x))
  if (is.na(v) || v < min_val) default else v
}

# ── Parse arguments ───────────────────────────────────────────────────────────
args   <- commandArgs(trailingOnly = TRUE)
seed   <- parse_int(args[1], 42L,  min_val = 1L)
ngenes <- parse_int(args[2], 10000L,  min_val = 1L)
nA     <- parse_int(args[3], 3L,  min_val = 1L)
nB     <- parse_int(args[4], 3L,  min_val = 1L)
maxval <- parse_int(args[5], 50L, min_val = 1L)
dist   <- if (length(args) >= 6 && tolower(trimws(args[6])) %in% c("poisson", "lognorm", "nbinom"))
              tolower(trimws(args[6])) else "lognorm"
# size controls overdispersion for nbinom (smaller = more overdispersed)
size   <- parse_num(args[7], 1.0, min_val = 0.01)

if (length(args) < 7) {
  cat(sprintf(
    "Usage: Rscript gen_input.R [seed] [ngenes] [nA] [nB] [maxval] [dist] [size]

Parameters:
  seed   : RNG seed (default 1)
  ngenes : number of genes (default 4)
  nA     : samples in group A (default 3)
  nB     : samples in group B (default 3)
  maxval : mean count center — lambda for 'poisson', log-normal center for
           'lognorm' and 'nbinom' (default 20)
  dist   : 'poisson'  — fixed Poisson lambda = maxval
           'lognorm'  — gene-specific Poisson means drawn from log-normal (default)
           'nbinom'   — negative binomial with gene-specific means (log-normal)
                        and dispersion controlled by size
  size   : NB dispersion parameter (default 1.0, ignored for poisson/lognorm)
           smaller values = more overdispersion (e.g. 0.5 for heavy tails)

Examples:
  # Run with all defaults (4 genes, 3+3 samples, lognorm, maxval=20)
  Rscript gen_input.R

  # 10,000 genes, lognorm centered at 1,000,000
  Rscript gen_input.R 42 10000 3 3 1000000 lognorm

  # Fixed Poisson lambda=50, 5 samples per group
  Rscript gen_input.R 1 10000 5 5 50 poisson

  # Negative binomial, high overdispersion (size=0.5), unbalanced groups
  Rscript gen_input.R 7 10000 4 2 100 nbinom 0.5

Resolved: seed=%d ngenes=%d nA=%d nB=%d maxval=%d dist=%s size=%.2f\n\n",
    seed, ngenes, nA, nB, maxval, dist, size))
}

# ── Simulate ──────────────────────────────────────────────────────────────────
set.seed(seed)
n_samples    <- nA + nB
gene_names   <- paste0("G", seq_len(ngenes))
sample_names <- paste0("S", seq_len(n_samples))

# gene_means only drawn when needed — avoids consuming RNG draws in poisson mode
gene_means <- if (dist %in% c("lognorm", "nbinom")) {
  # log-normal gene means: mean(gene_means) == maxval, wide spread via sdlog=2
  rlnorm(ngenes, meanlog = log(maxval) - 2, sdlog = 2)
} else {
  NULL
}

y <- matrix(
  switch(dist,
    # poisson: all genes share a fixed lambda = maxval
    poisson = rpois(ngenes * n_samples, lambda = maxval),
    # lognorm: Poisson-lognormal mixture — Poisson counts with gene-specific means
    lognorm = rpois(ngenes * n_samples,  lambda = rep(gene_means, times = n_samples)),
    # nbinom: negative binomial with same gene-specific means; size controls overdispersion
    nbinom  = rnbinom(ngenes * n_samples, mu = rep(gene_means, times = n_samples), size = size)
  ),
  nrow     = ngenes,
  dimnames = list(gene_names, sample_names)
)

# ── Write output ──────────────────────────────────────────────────────────────
group     <- factor(rep(c("A", "B"), c(nA, nB)))
design_df <- data.frame(sample = sample_names, group = as.character(group))

stem  <- sprintf("random_%dgene_seed%d_nA%d_nB%d_max%d_%s", ngenes, seed, nA, nB, maxval, dist)
mfile <- paste0(stem, "_matrix.csv")
dfile <- paste0(stem, "_design.csv")

write.csv(as.data.frame(y), file = mfile, row.names = TRUE)
write.csv(design_df,         file = dfile, row.names = FALSE)
cat("Wrote:", mfile, "\n     ", dfile, "\n")
