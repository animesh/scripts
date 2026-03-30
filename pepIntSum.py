#python pepIntSum.py  "F:\maxlLFQ\combined\txt\peptides.txt" "F:\maxlLFQ\combined\txt\proteinGroups.txt" "F:\maxlLFQ\\mqpar.xml"
# maxLFQsimple_peptides.py  peptides.txt  proteinGroups.txt  [mqpar.xml]
#
# MaxLFQ (Cox et al. MCP 2014) from peptides.txt
# Species = Sequence (charge states collapsed to sum by MaxQuant)
# Anchor  = first experiment in mqpar.xml if provided, else first sample alphabetically
#
# Compared to evidence version:
#   + simpler input (no Type filtering, no SECPEP handling)
#   − charge-state sum inflation biases N_j on large datasets
#     (peptides.txt Intensity = sum of all charge states;
#      evidence version uses max per charge state, closer to MaxQuant's internal species)
#   = use evidence version when available; this version when only peptides.txt is at hand
#
# Algorithm:
#   1. Build peptide × sample matrix from peptides.txt Intensity columns
#   2. Global N_j via Levenberg-Marquardt: minimise H(N) = Σ(log N_a·I_pa − log N_b·I_pb)²
#   3. Apply N_j: normalised_I = N_j · raw_I
#   4. Per-protein: pairwise median log2-ratios over shared peptides → lstsq → rescale
#      Connected components (_cc): isolated samples get LFQ = normalised intensity directly
#
# Merge: peptides 'Leading razor protein' (first token) ↔
#        proteinGroups 'Majority protein IDs' (first token)
import sys, os, warnings
import numpy as np, pandas as pd
from itertools import combinations
from scipy.optimize import least_squares
warnings.filterwarnings('ignore')

# ── load & filter peptides ────────────────────────────────────────────────────
pep = pd.read_csv(sys.argv[1], sep='\t', low_memory=False)
for c in ['Reverse','Potential contaminant','Contaminant']:
    if c in pep.columns: pep = pep[pep[c].astype(str).str.strip()!='+']
pep['_razor'] = pep['Leading razor protein'].astype(str).str.split(';').str[0].str.strip()

int_cols = [c for c in pep.columns if c.startswith('Intensity ')]
samples  = [c.removeprefix('Intensity ') for c in int_cols]
for c in int_cols: pep[c] = pd.to_numeric(pep[c], errors='coerce').replace(0, np.nan)

n_multi = pep['Charges'].astype(str).str.contains(';',na=False).sum() if 'Charges' in pep.columns else 0

print(f"\npeptides.txt: {len(pep)} peptides  |  {len(samples)} samples  |  "
      f"{pep['_razor'].nunique()} proteins")
if n_multi:
    print(f"  note: {n_multi} multi-charge peptides — "
          f"intensity is sum of charge states (may slightly bias N_j vs evidence version)")

# ── peptide × sample matrix ───────────────────────────────────────────────────
# One row per (Sequence, razor protein); Intensity already charge-sum aggregated by MaxQuant
wide = (pep.set_index(['Sequence','_razor'])[int_cols]
           .rename(columns={f'Intensity {s}': s for s in samples})
           .replace(0, np.nan))

# ── N_j via Levenberg-Marquardt ───────────────────────────────────────────────
# Residuals: log(N_a) + log(I_pa) − log(N_b) − log(I_pb) = 0
# N_j ∝ 1/intensity: high-intensity sample gets small N_j (scales it down)
logX  = np.log(wide.values.astype(float))
pairs = list(combinations(range(len(samples)), 2))

def _nj_res(nv):
    out = []
    for a, b in pairs:
        ok = np.isfinite(logX[:,a]) & np.isfinite(logX[:,b])
        if ok.any(): out.append((logX[ok,a]+nv[a]) - (logX[ok,b]+nv[b]))
    return np.concatenate(out) if out else np.array([0.])

Nj = np.exp(least_squares(_nj_res, np.zeros(len(samples)), method='lm', max_nfev=2000).x)

# ── anchor ────────────────────────────────────────────────────────────────────
_mqpar  = sys.argv[3] if len(sys.argv) > 3 else None
_anchor = samples[0]
if _mqpar:
    import xml.etree.ElementTree as _ET
    _exps = [el.text for el in _ET.parse(_mqpar).getroot().findall('.//experiments/string')]
    if _exps:
        _a = str(_exps[0]).strip()
        _anchor = _a if _a in samples else samples[0]
        if _a not in samples:
            print(f"WARNING: mqpar anchor '{_a}' not in samples — using {samples[0]}")

Nj = Nj / Nj[samples.index(_anchor)]
print(f"\nanchor : {_anchor}  (N = 1.000000)")
for s, v in zip(samples, Nj): print(f"  N[{s}] = {v:.6f}")

# ── per-protein MaxLFQ ────────────────────────────────────────────────────────
wide_N  = wide.multiply(Nj, axis='columns')
wide_Nr = wide_N.reset_index()

def _cc(logP):
    """Label samples by connected component in co-observation graph."""
    ns  = logP.shape[1]
    lbl = np.full(ns, -1, dtype=int)
    adj = (np.isfinite(logP).T @ np.isfinite(logP)) > 0
    np.fill_diagonal(adj, False)
    cc = 0
    for i in range(ns):
        if lbl[i] != -1 or not np.isfinite(logP[:,i]).any(): continue
        q = [i]; lbl[i] = cc
        while q:
            nd = q.pop()
            for nb in np.where(adj[nd])[0]:
                if lbl[nb] == -1: lbl[nb] = cc; q.append(nb)
        cc += 1
    return lbl

def maxlfq(mat):
    """
    MaxLFQ per-protein profile from normalised peptide matrix (n_peptides × n_samples).
    Returns profile (n_samples,) with NaN for unquantifiable samples.
    Single-sample connected components get LFQ = normalised intensity directly
    (classicLfqForSingleShots behaviour).
    """
    logP    = np.log2(mat)
    ns      = logP.shape[1]
    lbl     = _cc(logP)
    profile = np.full(ns, np.nan)

    for cc in range(int(lbl.max())+1 if lbl.max() >= 0 else 0):
        idx = np.where(lbl==cc)[0]
        nc  = len(idx)
        lp  = logP[:, idx]
        nm  = np.nanmax(mat[:, idx], axis=0)   # rescaling target per sample

        if nc == 1:
            profile[idx[0]] = nm[0]
            continue

        # pairwise median log2-ratios over shared peptides
        rat = np.full((nc, nc), np.nan)
        for j, k in combinations(range(nc), 2):
            sh = np.isfinite(lp[:,j]) & np.isfinite(lp[:,k])
            if sh.sum() < 1: continue
            m = float(np.median((lp[:,j] - lp[:,k])[sh]))
            rat[j,k] = m; rat[k,j] = -m

        has_r = np.any(np.isfinite(rat), axis=1)
        rows, vals = [], []
        for j, k in combinations(range(nc), 2):
            if np.isfinite(rat[j,k]) and has_r[j] and has_r[k]:
                r = np.zeros(nc); r[j]=1.; r[k]=-1.
                rows.append(r); vals.append(rat[j,k])

        if not rows:
            p = np.full(nc, np.nan); p[has_r] = nm[has_r]; profile[idx] = p; continue

        sol, _, _, _ = np.linalg.lstsq(np.array(rows), np.array(vals), rcond=None)
        p = 2.**sol; p[~has_r] = np.nan
        act = has_r & np.isfinite(p) & (p>0) & np.isfinite(nm)
        if act.any(): p *= np.nansum(nm[act]) / np.nansum(p[act])
        p[~has_r] = np.nan; profile[idx] = p

    return profile

recs = []
for prot, grp in wide_Nr.groupby('_razor'):
    mat  = grp[samples].values.astype(float); mat[mat==0] = np.nan
    if mat.shape[0] == 0: continue
    prof = maxlfq(mat)
    recs.append({'Protein': prot,
                 **{f'calc_{s}': float(v) if np.isfinite(v) and v>0 else np.nan
                    for s, v in zip(samples, prof)}})
dfCalc = pd.DataFrame(recs).set_index('Protein')

# ── load proteinGroups ────────────────────────────────────────────────────────
pg = pd.read_csv(sys.argv[2], sep='\t', low_memory=False)
for c in ['Reverse','Potential contaminant','Contaminant']:
    if c in pg.columns: pg = pg[pg[c].astype(str).str.strip()!='+']
pg = pg.set_index('Majority protein IDs')
pgLFQ = (pg[[c for c in pg.columns if c.startswith('LFQ intensity ')]]
           .apply(pd.to_numeric, errors='coerce').replace(0, np.nan))
pgLFQ.columns = pgLFQ.columns.str.removeprefix('LFQ intensity ')
pgLFQ.index   = [i.split(';')[0].strip() for i in pgLFQ.index]
shared_s = [s for s in samples if s in pgLFQ.columns]

# ── merge report ──────────────────────────────────────────────────────────────
common   = dfCalc.index.intersection(pgLFQ.index)
pep_only = dfCalc.index.difference(pgLFQ.index)
pg_only  = pgLFQ.index.difference(dfCalc.index)

print(f"\nmerge: peptides._razor ↔ proteinGroups.Majority_protein_IDs (first token)")
print(f"  quantified in peptides : {len(dfCalc)}")
print(f"  in proteinGroups       : {len(pgLFQ)}")
print(f"  common (compared)      : {len(common)}")

if pep_only.size:
    print(f"\n  in peptides only ({len(pep_only)}):")
    for p in sorted(pep_only): print(f"    {p}")
if pg_only.size:
    pep_all = set(pep['_razor'].unique())
    pep_zero= set(pep[pep[int_cols].isna().all(axis=1)]['_razor'].unique())
    print(f"\n  in proteinGroups only ({len(pg_only)}):")
    for p in sorted(pg_only):
        if p in pep_zero:    reason = "in peptides.txt but all intensities zero/NaN"
        elif p in pep_all:   reason = "in peptides.txt but filtered (decoy/contaminant)"
        else:                reason = "absent from peptides.txt entirely"
        print(f"    {p}  [{reason}]")

# ── comparison table ──────────────────────────────────────────────────────────
rows = []
for prot in sorted(common):
    rec = {'Protein': prot}
    for s in shared_s:
        c = dfCalc.loc[prot, f'calc_{s}']
        m = pgLFQ.loc[prot, s]
        rec[f'calc_{s}'] = c
        rec[f'pg_{s}']   = m
        rec[f'log2diff_{s}'] = (np.log2(float(c)) - np.log2(float(m))
                                 if pd.notna(c) and c>0 and pd.notna(m) and m>0
                                 else np.nan)
    rows.append(rec)
dfOut = pd.DataFrame(rows).set_index('Protein')

_out = os.path.basename(sys.argv[1]) + '.maxLFQ_comparison.tsv'
dfOut.to_csv(_out, sep='\t')

hdr = f"  {'Protein':<35}" + ''.join(
      f"  {'calc_'+s:>14} {'pg_'+s:>14} {'Δlog2':>7}" for s in shared_s)
print(f"\n{'─'*len(hdr)}\n{hdr}\n{'─'*len(hdr)}")
for prot in sorted(common):
    row = f"  {prot:<35}"
    for s in shared_s:
        c = dfOut.loc[prot, f'calc_{s}']
        m = dfOut.loc[prot, f'pg_{s}']
        d = dfOut.loc[prot, f'log2diff_{s}']
        row += (f"  {c:>14.4e}" if pd.notna(c) else f"  {'NaN':>14}")
        row += (f" {m:>14.4e}" if pd.notna(m) else f" {'NaN':>14}")
        row += (f" {d:>+7.3f}" if pd.notna(d) else f" {'NaN':>7}")
    print(row)

all_d = dfOut[[f'log2diff_{s}' for s in shared_s]].values.flatten()
all_d = all_d[np.isfinite(all_d)]
if len(all_d):
    print(f"\n  n={len(all_d)}  MAE={np.mean(np.abs(all_d)):.4f}  "
          f"bias={np.mean(all_d):+.4f}  95th|Δ|={np.percentile(np.abs(all_d),95):.4f}  log2")
print(f'\noutput → {_out}')
