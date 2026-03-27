#python pepIntSum.py  "F:\maxlLFQ\combined\txt\peptides.txt" "F:\maxlLFQ\combined\txt\proteinGroups.txt" "F:\maxlLFQ\\mqpar.xml"
# maxLFQsimple_peptides.py  peptides.txt  proteinGroups.txt
# MaxLFQ (Cox et al. MCP 2014) using peptides.txt as species input.
#
# Key difference from evidence.txt version:
#   peptides.txt has one row per sequence; intensity = sum of all charge states.
#   Multi-charge peptides (Charges column contains ';') are inflated vs evidence max-per-species.
#   This biases N_j on large datasets. On sparse datasets the LM may be underdetermined anyway.
#   Use evidence.txt version for better N_j accuracy when available.
#
# Species = Sequence (charge states collapsed to sum by MaxQuant).
# Anchor = first sample alphabetically (N[anchor] = 1).
import sys, warnings
import numpy as np, pandas as pd
from itertools import combinations
from scipy.optimize import least_squares
warnings.filterwarnings('ignore')

# ── load peptides ─────────────────────────────────────────────────────────────
pep = pd.read_csv(sys.argv[1], sep='\t', low_memory=False)
for c in ['Reverse','Potential contaminant','Contaminant']:
    if c in pep.columns: pep = pep[pep[c].astype(str).str.strip()!='+']

pep['_razor'] = pep['Leading razor protein'].astype(str).str.split(';').str[0].str.strip()
int_cols = [c for c in pep.columns if c.startswith('Intensity ')]
samples  = [c.removeprefix('Intensity ') for c in int_cols]
for c in int_cols: pep[c] = pd.to_numeric(pep[c], errors='coerce').replace(0, np.nan)

# ── peptide × sample matrix ───────────────────────────────────────────────────
# one row per (Sequence, razor protein); intensity already summed across charge states
wide = (pep.set_index(['Sequence','_razor'])[int_cols]
           .rename(columns={f'Intensity {s}':s for s in samples})
           .replace(0, np.nan))

print(f"\npeptides.txt: {len(pep)} peptides  |  {len(samples)} samples: {samples}")
print(f"matrix: {wide.shape[0]} rows × {len(samples)} samples")
multi_charge = pep['Charges'].astype(str).str.contains(';').sum()
if multi_charge:
    print(f"warning: {multi_charge} multi-charge peptides — "
          f"intensity is sum of charge states (may bias N_j)")

# ── N_j via Levenberg-Marquardt; anchor = first sample ────────────────────────
logX  = np.log(wide.values.astype(float))
pairs = list(combinations(range(len(samples)), 2))
def _res(nv):
    out=[]
    for a,b in pairs:
        ok=np.isfinite(logX[:,a])&np.isfinite(logX[:,b])
        if ok.any(): out.append((logX[ok,a]+nv[a])-(logX[ok,b]+nv[b]))
    return np.concatenate(out) if out else np.array([0.])

Nj = np.exp(least_squares(_res, np.zeros(len(samples)), method='lm', max_nfev=2000).x)

# ── anchor: read from mqpar.xml if provided, else first sample alphabetically ─
# MaxQuant anchors N_j to the first experiment listed in mqpar.xml.
# This sets the absolute scale of LFQ values. Wrong anchor = global log2 offset.
_mqpar = sys.argv[3] if len(sys.argv) > 3 else None
if _mqpar:
    import xml.etree.ElementTree as _ET
    _root = _ET.parse(_mqpar).getroot()
    _exps = [el.text for el in _root.findall('.//experiments/string')]
    _anchor = str(_exps[0]).strip() if _exps else samples[0]
    # zfill to match our padded experiment names
    _zlen = max(len(s) for s in samples)
    _anchor = _anchor.zfill(_zlen) if _anchor.isdigit() else _anchor
    if _anchor not in samples:
        print(f"WARNING: mqpar anchor '{_anchor}' not in samples {samples} — using {samples[0]}")
        _anchor = samples[0]
else:
    _anchor = samples[0]

Nj = Nj / Nj[samples.index(_anchor)]

print(f"\nanchor : {_anchor}  (N = 1.000000)")
for s,v in zip(samples,Nj): print(f"  N[{s}] = {v:.6f}")

# ── per-protein MaxLFQ ────────────────────────────────────────────────────────
wide_N  = wide.multiply(Nj, axis='columns')
wide_Nr = wide_N.reset_index()

def maxlfq(mat):
    logP=np.log2(mat); ns=logP.shape[1]; profile=np.full(ns,np.nan)
    nm=np.nanmax(mat,axis=0)
    rat=np.full((ns,ns),np.nan)
    for j,k in combinations(range(ns),2):
        sh=np.isfinite(logP[:,j])&np.isfinite(logP[:,k])
        if sh.sum()<1: continue
        m=float(np.median((logP[:,j]-logP[:,k])[sh]))
        rat[j,k]=m; rat[k,j]=-m
    has_r=np.any(np.isfinite(rat),axis=1)
    if not has_r.any(): return profile
    rows,vals=[],[]
    for j,k in combinations(range(ns),2):
        if np.isfinite(rat[j,k]) and has_r[j] and has_r[k]:
            r=np.zeros(ns); r[j]=1.; r[k]=-1.; rows.append(r); vals.append(rat[j,k])
    if not rows:
        profile[has_r]=nm[has_r]; return profile
    sol,_,_,_=np.linalg.lstsq(np.array(rows),np.array(vals),rcond=None)
    p=2.**sol; p[~has_r]=np.nan
    act=has_r&np.isfinite(p)&(p>0)&np.isfinite(nm)
    if act.any(): p*=np.nansum(nm[act])/np.nansum(p[act])
    p[~has_r]=np.nan; return p

recs=[]
for prot,grp in wide_Nr.groupby('_razor'):
    mat=grp[samples].values.astype(float); mat[mat==0]=np.nan
    if mat.shape[0]==0: continue
    prof=maxlfq(mat)
    recs.append({'Protein':prot,**{f'calc_{s}':float(v) if np.isfinite(v) and v>0 else np.nan
                                   for s,v in zip(samples,prof)}})
dfCalc=pd.DataFrame(recs).set_index('Protein')

# ── load proteinGroups ────────────────────────────────────────────────────────
# merge key: peptides._razor (first token of Leading razor protein)
#          ↔ proteinGroups.Majority_protein_IDs (first token, semicolons = protein group members)
pg=pd.read_csv(sys.argv[2], sep='\t', low_memory=False)
for c in ['Reverse','Potential contaminant','Contaminant']:
    if c in pg.columns: pg=pg[pg[c].astype(str).str.strip()!='+']
pg=pg.set_index('Majority protein IDs')
pgLFQ=pg[[c for c in pg.columns if c.startswith('LFQ intensity ')]]\
          .apply(pd.to_numeric,errors='coerce').replace(0,np.nan)
pgLFQ.columns=pgLFQ.columns.str.removeprefix('LFQ intensity ')
pgLFQ.index=[i.split(';')[0].strip() for i in pgLFQ.index]
shared_s=[s for s in samples if s in pgLFQ.columns]

# ── merge report ──────────────────────────────────────────────────────────────
common  = dfCalc.index.intersection(pgLFQ.index)
pep_only= dfCalc.index.difference(pgLFQ.index)
pg_only = pgLFQ.index.difference(dfCalc.index)

print(f"\nmerge: peptides._razor ↔ proteinGroups.Majority_protein_IDs (first token)")
print(f"  quantified in peptides : {len(dfCalc)}")
print(f"  in proteinGroups       : {len(pgLFQ)}")
print(f"  common (compared)      : {len(common)}")

if pep_only.size:
    print(f"\n  in peptides only ({len(pep_only)}):")
    for p in sorted(pep_only): print(f"    {p}")
if pg_only.size:
    print(f"\n  in proteinGroups only ({len(pg_only)}):")
    # check if they appear in peptides at all (zero intensity vs truly absent)
    pep_all_razors = set(pep['_razor'].unique())
    pep_zero_razors= set(pep[pep[int_cols].isna().all(axis=1)]['_razor'].unique())
    for p in sorted(pg_only):
        if p in pep_zero_razors:   reason="in peptides.txt but all intensities zero/NaN"
        elif p in pep_all_razors:  reason="in peptides.txt but filtered (decoy/contaminant)"
        else:                      reason="absent from peptides.txt entirely"
        print(f"    {p}  [{reason}]")

# ── comparison table ──────────────────────────────────────────────────────────
rows=[]
for prot in sorted(common):
    rec={'Protein':prot}
    for s in shared_s:
        c=dfCalc.loc[prot,f'calc_{s}']; m=pgLFQ.loc[prot,s]
        rec[f'calc_{s}']=c; rec[f'pg_{s}']=m
        rec[f'log2diff_{s}']=(np.log2(float(c))-np.log2(float(m))
                              if pd.notna(c) and c>0 and pd.notna(m) and m>0 else np.nan)
    rows.append(rec)
dfOut=pd.DataFrame(rows).set_index('Protein')
import os
_out=os.path.basename(sys.argv[1])+'.maxLFQ_comparison.tsv'
dfOut.to_csv(_out, sep='\t')

hdr=f"  {'Protein':<35}"+''.join(f"  {'calc_'+s:>14} {'pg_'+s:>14} {'Δlog2':>7}" for s in shared_s)
print(f"\n{'─'*len(hdr)}\n{hdr}\n{'─'*len(hdr)}")
for prot in sorted(common):
    row=f"  {prot:<35}"
    for s in shared_s:
        c=dfOut.loc[prot,f'calc_{s}']; m=dfOut.loc[prot,f'pg_{s}']; d=dfOut.loc[prot,f'log2diff_{s}']
        row+=(f"  {c:>14.4e}" if pd.notna(c) else f"  {'NaN':>14}")
        row+=(f" {m:>14.4e}" if pd.notna(m) else f" {'NaN':>14}")
        row+=(f" {d:>+7.3f}" if pd.notna(d) else f" {'NaN':>7}")
    print(row)

all_d=dfOut[[f'log2diff_{s}' for s in shared_s]].values.flatten()
all_d=all_d[np.isfinite(all_d)]
if len(all_d):
    print(f"\n  n={len(all_d)}  MAE={np.mean(np.abs(all_d)):.4f}  "
          f"bias={np.mean(all_d):+.4f}  95th|Δ|={np.percentile(np.abs(all_d),95):.4f}  log2")
print(f'\noutput → {_out}')
