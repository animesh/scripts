# gen_input.R — Simulation Tests

Tests run on: 2026-03-06  
R version: 4.5.0  
Script: `gen_input.R`

All tests mock `commandArgs()` in a local environment so the script can be
sourced with arbitrary parameters from within an R session.

---

## Results summary

| Test | Status | Description |
|------|--------|-------------|
| T01  | ✅ PASS | Default run produces correct dimensions (4 × 6) |
| T02  | ✅ PASS | Custom ngenes/nA/nB produces correct matrix dimensions |
| T03  | ✅ PASS | Design file has correct sample count and group labels |
| T04  | ✅ PASS | Same seed produces identical output (lognorm) |
| T05  | ✅ PASS | Different seeds produce different output |
| T06  | ✅ PASS | Poisson mode RNG matches pure `rpois` with same seed |
| T07  | ✅ PASS | Poisson mode: observed mean ≈ lambda (within 5%) |
| T08  | ✅ PASS | Poisson mode: mean ≈ variance (within 5%) |
| T09  | ✅ PASS | Lognorm mode: variance > mean (mixture overdispersion) |
| T10  | ✅ PASS | Nbinom (size=0.5) variance > lognorm variance at same params |
| T11  | ✅ PASS | Nbinom: smaller size → larger variance (more overdispersion) |
| T12  | ✅ PASS | All simulated counts are non-negative |
| T13  | ✅ PASS | Minimum samples (nA=1, nB=1) runs without error |
| T14  | ✅ PASS | Single gene (ngenes=1) runs without error |
| T15  | ✅ PASS | Invalid dist value falls back to lognorm |

**15 / 15 passed**

---

## Test details

### T01 — Default run dimensions
**Command:** `Rscript gen_input.R` (no args)  
**Expected:** matrix of 4 genes × 6 samples (3A + 3B defaults)  
**Result:** `dim: 4 x 6` ✅

---

### T02 — Custom dimensions
**Command:** `Rscript gen_input.R 1 10000 4 5 20 lognorm`  
**Expected:** 10,000 genes × 9 samples (nA=4, nB=5)  
**Result:** `dim: 10000 x 9` ✅

---

### T03 — Design group labels
**Command:** `Rscript gen_input.R 1 100 4 2 20 lognorm`  
**Expected:** 6 rows, groups = A A A A B B  
**Result:** `groups: A A A A B B` ✅

---

### T04 — Reproducibility (same seed)
**Command:** run twice with `seed=42, ngenes=200, lognorm`  
**Expected:** identical output matrices  
**Result:** matrices identical ✅

---

### T05 — Different seeds give different output
**Commands:** seed=1 vs seed=99, same other params  
**Expected:** different output matrices  
**Result:** `sum(seed=1)=48076, sum(seed=99)=31864` ✅

---

### T06 — Poisson RNG correctness
**Motivation:** an earlier bug caused `gene_means` to be drawn unconditionally,
silently shifting the RNG state before Poisson draws even in `poisson` mode.
This test confirms the fix: `poisson` mode now produces counts that exactly
match a standalone `set.seed(seed); rpois(n, lambda)` call.  
**Command:** `Rscript gen_input.R 1 10 3 3 20 poisson`  
**Expected:** matches `set.seed(1); rpois(60, lambda=20)`  
**Result:** first 6 counts: `17 25 25 21 13 22` ✅

---

### T07 — Poisson mean ≈ lambda
**Command:** `Rscript gen_input.R 1 10000 3 3 50 poisson`  
**Expected:** grand mean within 5% of lambda=50  
**Result:** `lambda=50, observed mean=50.01` ✅

---

### T08 — Poisson mean ≈ variance
The defining property of the Poisson distribution is that mean equals
variance. This is tested across all 60,000 cells (10,000 genes × 6 samples),
which gives a reliable estimate.  
**Result:** `mean=50.01, var=50.09` ✅

---

### T09 — Lognorm mixture overdispersion
A Poisson-lognormal mixture has variance > mean because of the additional
between-gene variance from the log-normal component:
`Var(Y) = E[μ] + Var(μ)`, where `Var(μ)` can be very large.  
**Result:** `mean=48.2, var=65,820.8, ratio=1,365` ✅  
The variance/mean ratio of ~1,365 is expected — the wide log-normal spread
(sdlog=2) dominates and is by design to mimic the dynamic range of real RNA-seq.

---

### T10 — Nbinom more overdispersed than lognorm
At the same gene means, negative binomial adds within-gene overdispersion
(`μ²/size`) on top of the between-gene variance from the log-normal.  
**Result:** `var(lognorm)=65,821, var(nbinom, size=0.5)=115,189` ✅

---

### T11 — Smaller size → more overdispersion ⚠️ weak signal
**Expected:** `var(size=0.5) > var(size=5)`  
**Result:** `var(size=0.5)=115,189, var(size=5)=114,515` ✅ (margin: ~0.6%)

> **Note:** The signal is very weak. When sdlog=2, the between-gene log-normal
> variance dominates the total pooled variance so strongly that the within-gene
> NB overdispersion term (`μ²/size`) is relatively small in comparison. At the
> global pooled level, the `size` parameter's effect is hard to distinguish.
>
> **Recommendation:** To properly validate the `size` parameter, test at the
> per-gene level — compute the variance-to-mean ratio for each gene and check
> that its median is higher for smaller `size`. A future test should do:
> ```r
> vmr <- apply(y, 1, var) / rowMeans(y)
> # expect median(vmr) higher for size=0.5 than size=5
> ```

---

### T12 — Non-negative counts
All three distributions (`poisson`, `lognorm`, `nbinom`) must produce counts
≥ 0. Tested on `nbinom` with size=0.5 (most extreme settings).  
**Result:** `min count: 0` ✅

---

### T13 — Minimum samples (nA=1, nB=1)
**Command:** `Rscript gen_input.R 1 100 1 1 20 lognorm`  
**Expected:** 100 × 2 matrix, no error  
**Result:** `dim: 100 x 2` ✅

---

### T14 — Single gene (ngenes=1)
**Command:** `Rscript gen_input.R 1 1 3 3 20 nbinom 1`  
**Expected:** 1 × 6 matrix, no error  
**Result:** `counts: 0 2 0 0 0 0` ✅

---

### T15 — Invalid dist falls back to lognorm
**Command:** `Rscript gen_input.R 1 10 3 3 20 badval`  
**Expected:** script silently falls back to `lognorm`; `gene_means` is
populated (would be NULL if `poisson` path were taken).  
**Result:** `gene_means present (lognorm path)` ✅

---

## Known limitations / future tests

1. **T11 per-gene VMR test** (see T11 note above) — global pooled variance is
   a poor test of the `size` parameter. A per-gene variance-to-mean ratio test
   would be more robust.

2. **Output file names** — no test currently verifies that the generated CSV
   file names contain the correct parameter values (traceability filenames).

3. **Large maxval with poisson mode** — at high lambda (e.g. 1,000,000), counts
   never reach 0 and the distribution is nearly Gaussian. This is statistically
   expected but worth documenting as a user-facing caveat.

4. **NB size < 1 with very high gene means** — with `size=0.01` and
   `maxval=1e6`, NB draws could produce very large outliers. Not yet stress-tested.
