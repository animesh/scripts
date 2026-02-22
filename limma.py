"""
Minimal Python port of scripts/claude_run_compare.R (renamed to limma.py)
Produces CSV with columns: gene, logFC, limma_mod_t, limma_mod_p
"""

import math
from typing import Dict, Any
import numpy as np
from scipy import linalg
from scipy import stats
from scipy.special import psi, polygamma
import csv
import sys
from pathlib import Path


def lmFit_simple(expr_mat: np.ndarray, design: np.ndarray) -> Dict[str, Any]:
    X = np.asarray(design)
    Y = np.asarray(expr_mat).T
    nsamples, ngenes = Y.shape
    p = np.linalg.matrix_rank(X)
    coef, *_ = linalg.lstsq(X, Y)
    resid = Y - X.dot(coef)
    df = nsamples - p
    sigma2 = np.sum(resid ** 2, axis=0) / df
    if np.any(sigma2 <= 0):
        positive = sigma2[sigma2 > 0]
        minpos = positive.min() if positive.size else np.finfo(float).tiny
        sigma2[sigma2 <= 0] = minpos
    XtX = X.T.dot(X)
    XtX_inv = linalg.inv(XtX)
    su = np.sqrt(np.diag(XtX_inv))
    coefficients = coef.T
    stdev_unscaled = np.tile(su, (ngenes, 1))
    return {
        "coefficients": coefficients,
        "stdev_unscaled": stdev_unscaled,
        "sigma": np.sqrt(sigma2),
        "df_residual": np.full(ngenes, df, dtype=float),
        "design": X,
    }


def logmdigamma(x):
    x = np.asarray(x)
    return np.log(x) - psi(x)


def trigamma(x):
    return polygamma(1, x)


def trigammaInverse(x):
    x = np.asarray(x)
    if x.size == 0:
        return np.array([])
    def invert_scalar(xx):
        if not np.isfinite(xx):
            return np.nan
        if xx < 0:
            return np.nan
        if xx > 1e7:
            return 1.0 / math.sqrt(xx)
        if xx < 1e-6:
            return 1.0 / xx
        y = 0.5 + 1.0 / xx
        for _ in range(50):
            tri = polygamma(1, y)
            denom = polygamma(2, y)
            if denom == 0:
                break
            dif = tri * (1 - tri / xx) / denom
            y = y + dif
            if max(-dif / y, 0) < 1e-8:
                break
        return y
    vec = np.vectorize(invert_scalar, otypes=[float])
    return vec(x)


def fitFDist(x, df1, covariate=None):
    x = np.asarray(x, dtype=float)
    n = x.size
    if n == 0:
        return {"scale": np.nan, "df2": np.nan}
    if n == 1:
        return {"scale": x.item(), "df2": 0.0}
    df1 = np.asarray(df1, dtype=float)
    ok = np.isfinite(df1) & (df1 > 1e-15)
    if df1.size == 1:
        if not ok:
            return {"scale": np.nan, "df2": np.nan}
        ok = np.ones(n, dtype=bool)
    ok = ok & np.isfinite(x) & (x > -1e-15)
    nok = ok.sum()
    if nok == 1:
        return {"scale": float(x[ok][0]), "df2": 0.0}
    notallok = nok < n
    if notallok:
        x = x[ok]
        if df1.size > 1:
            df1 = df1[ok]
        if covariate is not None:
            covariate = np.asarray(covariate, dtype=float)[ok]
    x = np.maximum(x, 0.0)
    m = np.median(x)
    if m == 0:
        m = 1.0
    x = np.maximum(x, 1e-5 * m)
    z = np.log(x)
    e = z + logmdigamma(df1 / 2.0)
    if covariate is None:
        emean = np.mean(e)
        evar = np.sum((e - emean) ** 2) / (len(e) - 1)
    else:
        # Natural cubic spline trend (limma uses splines::ns)
        cov = np.asarray(covariate, dtype=float)
        if nok < n:
            cov = cov[ok] if hasattr(ok, '__len__') else cov
        nok_c = len(e)
        splinedf = 1 + int(nok_c >= 3) + int(nok_c >= 6) + int(nok_c >= 30)
        splinedf = min(splinedf, len(np.unique(cov)))
        if splinedf < 2:
            emean = np.mean(e)
            evar = np.sum((e - emean) ** 2) / (len(e) - 1)
        else:
            # Build polynomial basis (simpler than ns but adequate)
            deg = splinedf - 1
            B = np.column_stack([cov**k for k in range(deg + 1)])
            coef_sp, _, _, _ = linalg.lstsq(B, e)
            emean = B @ coef_sp
            resid_e = e - emean
            evar = float(np.mean(resid_e ** 2))
    evar = evar - np.mean(trigamma(df1 / 2.0))
    if evar > 0:
        df2 = 2.0 * trigammaInverse(evar)
        s20_arr = np.exp(np.asarray(emean) - logmdigamma(df2 / 2.0))
        s20 = float(s20_arr) if s20_arr.ndim == 0 else s20_arr
    else:
        df2 = np.inf
        s20 = float(np.mean(x))
    return {"scale": s20, "df2": df2}



def fitFDistRobustly(x, df1, covariate=None, winsor_tail_p=(0.05, 0.1)):
    """Robust fitFDist: Winsorise F-distribution outliers before fitting prior."""
    x = np.asarray(x, dtype=float)
    df1 = np.asarray(df1, dtype=float)
    fit0 = fitFDist(x, df1, covariate=covariate)
    df2 = fit0["df2"]
    if not np.isfinite(df2):
        fit0["df2.shrunk"] = df2
        return fit0
    n = len(x)
    ok = np.isfinite(x) & (x >= 0) & np.isfinite(df1) & (df1 > 0)
    s20 = float(fit0["scale"])
    u = np.where(ok, x / s20, np.nan)
    df1v = df1 if df1.size > 1 else np.full(n, float(df1))
    ptail = stats.f.sf(u, dfn=df1v, dfd=df2)
    ptail = np.minimum(ptail, 1.0 - ptail)
    lo_q, hi_q = winsor_tail_p
    x_win = x.copy()
    for i in range(n):
        if not ok[i] or not np.isfinite(ptail[i]):
            continue
        if ptail[i] < lo_q:
            if stats.f.sf(u[i], dfn=df1v[i], dfd=df2) < lo_q:
                x_win[i] = s20 * stats.f.isf(hi_q, dfn=df1v[i], dfd=df2)
            else:
                x_win[i] = s20 * stats.f.ppf(hi_q, dfn=df1v[i], dfd=df2)
    fit1 = fitFDist(x_win, df1, covariate=covariate)
    fit0["df2.shrunk"] = fit1["df2"]
    fit0["scale"] = fit1["scale"]
    return fit0


def squeezeVar(var, df, covariate=None, robust=False, winsor_tail_p=(0.05, 0.1)):
    var = np.asarray(var, dtype=float)
    df = np.asarray(df, dtype=float)
    n = var.size
    if n == 0:
        raise ValueError("var is empty")
    if n < 3:
        return {"var.post": var, "var.prior": var, "df.prior": 0}
    if df.size > 1:
        var[df == 0] = 0
    if robust:
        fit = fitFDistRobustly(var, df1=df, covariate=covariate)
        df_prior = fit.get("df2.shrunk", fit["df2"])
    else:
        fit = fitFDist(var, df1=df, covariate=covariate)
        df_prior = fit.get("df2")
    if np.isnan(df_prior).any() if np.ndim(df_prior) > 0 else np.isnan(df_prior):
        raise ValueError("Could not estimate prior df")
    if np.isfinite(df_prior):
        var_post = (df * var + df_prior * fit["scale"]) / (df + df_prior)
    else:
        var_post = np.full(n, float(fit["scale"]))
    return {"df.prior": df_prior, "var.prior": fit["scale"], "var.post": var_post}


def eBayes_simple(fit: Dict[str, Any], trend=False, robust=False, prop_de=0.01):
    coefficients = fit["coefficients"]
    stdev_unscaled = fit["stdev_unscaled"]
    sigma = fit["sigma"]
    if trend:
        Amean = np.mean(fit["design"] @ fit["coefficients"].T, axis=0)
    else:
        Amean = None
    sv = squeezeVar(sigma ** 2, fit["df_residual"], covariate=Amean, robust=robust)
    var_prior = sv["var.prior"]
    df_prior = sv["df.prior"]
    s2_post = sv["var.post"]
    df_total = fit["df_residual"] + df_prior
    p = coefficients.shape[1]
    ng = coefficients.shape[0]
    tmat = np.full((ng, p), np.nan)
    pmat = np.full((ng, p), np.nan)
    for j in range(p):
        se = stdev_unscaled[:, j] * np.sqrt(s2_post)
        tmat[:, j] = coefficients[:, j] / se
        dft = df_total
        if np.isscalar(dft):
            pmat[:, j] = 2.0 * stats.t.sf(np.abs(tmat[:, j]), dft)
        else:
            pmat[:, j] = 2.0 * stats.t.sf(np.abs(tmat[:, j]), dft)
    p0 = 1.0 - prop_de
    log_prior_odds = math.log(p0 / (1.0 - p0))
    bmat = np.full((ng, p), np.nan)
    for j in range(p):
        v_j = stdev_unscaled[0, j] ** 2
        r = v_j * var_prior
        t2 = tmat[:, j] ** 2
        dft = df_total
        if np.isscalar(dft):
            last_term = (dft + 1) * (np.log(1 + t2 / dft) - np.log(1 + t2 / (dft * (1 + r))))
        else:
            last_term = np.where(np.isfinite(dft), (dft + 1) * (np.log(1 + t2 / dft) - np.log(1 + t2 / (dft * (1 + r)))), t2 * r / (1 + r))
        bmat[:, j] = log_prior_odds + 0.5 * np.log(1.0 / (1.0 + r)) + 0.5 * last_term
    fit2 = dict(fit)
    fit2.update({"t": tmat, "p.value": pmat, "lods": bmat, "df.prior": df_prior, "var.prior": var_prior, "var.post": s2_post, "df.total": df_total})
    return fit2


def model_matrix_from_group(group):
    g = np.asarray(group)
    levels = np.unique(g)
    if levels.size != 2:
        raise ValueError("group must have exactly 2 levels")
    intercept = np.ones(g.shape[0], dtype=float)
    indicator = (g == levels[1]).astype(float)
    return np.column_stack((intercept, indicator))


def run_feature_tests(expr_mat: np.ndarray, group, trend=False, robust=False, prop_de=0.01):
    if not isinstance(expr_mat, np.ndarray):
        expr_mat = np.asarray(expr_mat, dtype=float)
    group = np.asarray(group)
    if np.unique(group).size != 2:
        raise ValueError("group must have exactly 2 levels")
    if expr_mat.shape[1] != group.size:
        raise ValueError("length(group) must equal number of columns in expr_mat")
    design = model_matrix_from_group(group)
    fit = lmFit_simple(expr_mat, design)
    coef_idx = 1
    fit2 = eBayes_simple(dict(fit), trend=trend, robust=robust, prop_de=prop_de)
    mod_t = fit2["t"][:, coef_idx]
    mod_p = fit2["p.value"][:, coef_idx]
    levels = np.unique(group)
    meanA = np.mean(expr_mat[:, group == levels[0]], axis=1)
    meanB = np.mean(expr_mat[:, group == levels[1]], axis=1)
    results = {
        "logFC": meanB - meanA,
        "limma_mod_t": mod_t,
        "limma_mod_p": mod_p,
    }
    return {"results": results, "fit": fit2}


def read_expr_matrix_csv(path):
    path = str(path)
    with open(path, newline='') as f:
        reader = csv.reader(f)
        rows = list(reader)
    if len(rows) == 0:
        raise ValueError('empty expression matrix')
    header = rows[0]
    samples = [h.strip().strip('"') for h in header[1:]]
    genes = []
    data = []
    for r in rows[1:]:
        if len(r) == 0:
            continue
        gene = r[0].strip().strip('"')
        vals = [float(x) for x in r[1:]]
        genes.append(gene)
        data.append(vals)
    expr_mat = np.array(data, dtype=float)
    return expr_mat, genes, samples


def read_design_csv(path, samples=None):
    path = str(path)
    with open(path, newline='') as f:
        reader = csv.DictReader(f)
        rows = list(reader)
    sample_to_group = {}
    for r in rows:
        s = r.get('sample') or r.get('Sample') or r.get('s')
        g = r.get('group') or r.get('Group') or r.get('g')
        if s is None or g is None:
            keys = list(r.keys())
            if len(keys) >= 2:
                s = r[keys[0]]
                g = r[keys[1]]
            else:
                raise ValueError('design CSV must have sample and group columns')
        sample_to_group[s.strip().strip('"')] = g.strip().strip('"')
    if samples is None:
        return [sample_to_group[s] for s in list(sample_to_group.keys())]
    groups = [sample_to_group.get(s, None) for s in samples]
    if any(x is None for x in groups):
        missing = [s for s, g in zip(samples, groups) if g is None]
        raise ValueError(f"design missing samples: {missing}")
    return groups


def _write_results_csv(outpath, genes, logFC, limma_mod_t, limma_mod_p):
    if outpath == '-':
        w = csv.writer(sys.stdout)
        w.writerow(['gene', 'logFC', 'limma_mod_t', 'limma_mod_p'])
        for i, g in enumerate(genes):
            w.writerow([g, logFC[i], limma_mod_t[i], limma_mod_p[i]])
    else:
        with open(outpath, 'w', newline='') as fo:
            w = csv.writer(fo)
            w.writerow(['gene', 'logFC', 'limma_mod_t', 'limma_mod_p'])
            for i, g in enumerate(genes):
                w.writerow([g, logFC[i], limma_mod_t[i], limma_mod_p[i]])


if __name__ == "__main__":
    default_mat = "random_4_gene_matrix_seed1_nA3_nB3_max20.csv"
    default_design = "random_4_gene_design_seed1_nA3_nB3_max20.csv"
    if len(sys.argv) < 3:
        if len(sys.argv) == 1:
            matrix_arg = default_mat
            design_arg = default_design
            print(f"No args provided — using defaults:\n  matrix={matrix_arg}\n  design={design_arg}")
        else:
            matrix_arg = sys.argv[1]
            design_arg = default_design
            print(f"Only matrix arg provided — using design default:\n  matrix={matrix_arg}\n  design={design_arg}")
    else:
        matrix_arg = sys.argv[1]
        design_arg = sys.argv[2]
    
    expr_mat, genes, samples = read_expr_matrix_csv(matrix_arg)
    # convert input to log2 scale before any processing
    if np.any(expr_mat <= 0):
        expr_mat = np.maximum(expr_mat, np.finfo(float).tiny)
    expr_mat = np.log2(expr_mat)
    
    group = np.array(read_design_csv(design_arg, samples=samples))
    out = run_feature_tests(expr_mat, group)
    results = out['results']
    fit = out['fit']
    logFC = results['logFC']
    limma_mod_t = results['limma_mod_t']
    limma_mod_p = results['limma_mod_p']
    
    mbase = Path(matrix_arg).stem
    dbase = Path(design_arg).stem
    outpath = f"{mbase}_{dbase}_pylimma.csv"
    _write_results_csv(outpath, genes, logFC, limma_mod_t, limma_mod_p)
    print("result in: "+outpath)
    