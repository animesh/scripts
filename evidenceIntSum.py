#python evidenceIntSum.py  "F:\maxlLFQ\combined\txt\evidence.txt" "F:\maxlLFQ\combined\txt\proteinGroups.txt" "F:\maxlLFQ\\mqpar.xml"
# maxLFQsimple.py  evidence.txt  proteinGroups.txt
# MaxLFQ (Cox et al. MCP 2014): no stabilisation, no modifications filter, anchor=first sample
import sys, warnings
import numpy as np, pandas as pd
from itertools import combinations
from scipy.optimize import least_squares
warnings.filterwarnings('ignore')

# ── load evidence ────────────────────────────────────────────────────────────
ev = pd.read_csv(sys.argv[1], sep='\t', low_memory=False)
ev = ev[ev['Type'].isin({'MULTI-MSMS','MULTI-MATCH','MULTI-SECPEP','MSMS','MULTI-MATCH-MSMS','ISO-MSMS'})].copy()
for c in ['Reverse','Potential contaminant','Contaminant']:
    if c in ev.columns: ev = ev[ev[c].astype(str).str.strip()!='+']
ev['Intensity'] = pd.to_numeric(ev['Intensity'], errors='coerce')

# track rows with no intensity separately before dropping
ev_noint = ev[~(ev['Intensity']>0)].copy()
ev       = ev[ev['Intensity']>0].copy()

ev['_razor']   = ev['Leading razor protein'].astype(str).str.split(';').str[0].str.strip()
ev['_species'] = ev['Modified sequence'].astype(str) + '_z' + ev['Charge'].astype(str)
ev['Experiment']= ev['Experiment'].astype(str).str.zfill(
                     max(len(str(x)) for x in ev['Experiment'].unique()))
samples = sorted(ev['Experiment'].unique())

# ── species × sample matrix ─────────────────────────────────────────────────
# MULTI-SECPEP = secondary peptide IDs from the same precursor scan.
# MaxQuant sums all SECPEP rows for the same species per run (they are
# isotope clusters of one precursor, not independent observations).
# All other types: max per (species, experiment) to avoid MS-event inflation.
_sec  = ev[ev['Type']=='MULTI-SECPEP']
_rest = ev[ev['Type']!='MULTI-SECPEP']
_agg_sec  = _sec.groupby(['_species','_razor','Experiment'])['Intensity'].sum()
_agg_rest = _rest.groupby(['_species','_razor','Experiment'])['Intensity'].max()
_combined = (pd.concat([_agg_sec.rename('s'),_agg_rest.rename('r')],axis=1)
               .fillna(0).assign(I=lambda d:d['s']+d['r']).replace(0,np.nan)['I'])
wide = _combined.unstack('Experiment').reindex(columns=samples).replace(0,np.nan)

# ── N_j via Levenberg-Marquardt; anchor = first sample (N[0] = 1) ────────────
# H(N) = Σ_p Σ_{A<B} (log(N_A·I_pA) − log(N_B·I_pB))²
# scale-free: only ratios N_A/N_B matter; dividing by N[0] pins the absolute scale
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
# for each protein: pairwise median log2-ratios → lstsq → rescale to nanmax of normalised intensities
wide_Nr = wide.multiply(Nj, axis='columns').reset_index()

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
    p[~has_r]=np.nan; profile=p
    return profile

recs=[]
for prot,grp in wide_Nr.groupby('_razor'):
    mat=grp[samples].values.astype(float); mat[mat==0]=np.nan
    prof=maxlfq(mat)
    recs.append({'Protein':prot,**{f'calc_{s}':float(v) if np.isfinite(v) and v>0 else np.nan
                                   for s,v in zip(samples,prof)}})
dfCalc=pd.DataFrame(recs).set_index('Protein')

# ── load proteinGroups ────────────────────────────────────────────────────────
# Merge key:
#   evidence  : _razor = first token of 'Leading razor protein'
#   proteinGroups: first token of 'Majority protein IDs'  (semicolons = protein group members)
# MaxQuant assigns peptides to proteins via the razor rule; 'Majority protein IDs' lists
# all proteins with >= 50% of the leading protein's peptides. The first token matches
# the razor protein used in evidence quantification.
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
common  =dfCalc.index.intersection(pgLFQ.index)
ev_only =dfCalc.index.difference(pgLFQ.index)
pg_only =pgLFQ.index.difference(dfCalc.index)

print(f"\nmerge: evidence._razor ↔ proteinGroups.Majority_protein_IDs (first token)")
print(f"  quantified in evidence : {len(dfCalc)}")
print(f"  in proteinGroups       : {len(pgLFQ)}")
print(f"  common (compared)      : {len(common)}")

razors_noint = set(ev_noint['Leading razor protein'].astype(str).str.split(';').str[0].str.strip().unique())
if ev_only.size:
    print(f"\n  in evidence only ({len(ev_only)}):")
    for p in sorted(ev_only): print(f"    {p}")
if pg_only.size:
    print(f"\n  in proteinGroups only ({len(pg_only)}):")
    for p in sorted(pg_only):
        reason=("identified but Intensity=NaN" if p in razors_noint else "absent from evidence")
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
