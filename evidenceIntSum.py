#python evidenceIntSum.py "Z:\Download\eColi\combined\txt - Copy\evidence.txt" "Z:\Download\eColi\combined\txt - Copy\proteinGroups.txt" "" 1_01
# %% setup
#install dependencies: pip install matplotlib pandas scipy
import sys,matplotlib.pyplot as plt,numpy as np,pandas as pd
from scipy.optimize import least_squares
from itertools import combinations

# %% data
pathFiles=sys.argv[1]
pgPath=sys.argv[2] if len(sys.argv)>2 else None
stabilize=len(sys.argv)>3   #third arg (any value) enables large-ratio stabilisation (Cox et al. Eq.5)
anchorSamp=sys.argv[4] if len(sys.argv)>4 else None  #fourth arg: exact sample name to anchor N_j (default: most-loaded = max N_j)
#eg. data: https://ftp.pride.ebi.ac.uk/pride/data/archive/2014/09/PXD000279/dynamicrangebenchmark.zip
#pathFiles="dynamicrangebenchmark/combined/txt/evidence.txt"
dfE=pd.read_csv(pathFiles,low_memory=False,sep='\t')
#filter decoys, contaminants, and non-quantifiable Types
for _col in ['Reverse','Potential contaminant','Contaminant']:
    if _col in dfE.columns: dfE=dfE[dfE[_col].astype(str).str.strip()!='+']
dfE=dfE[dfE['Type'].isin({'MULTI-MSMS','MULTI-MATCH','MULTI-SECPEP',
                           'MSMS','MULTI-MATCH-MSMS','ISO-MSMS'})].copy()
dfE['Intensity']=pd.to_numeric(dfE['Intensity'],errors='coerce')
dfE=dfE[dfE['Intensity']>0].copy()
dfE['_razor']=dfE['Leading razor protein'].astype(str).str.split(';').str[0].str.strip()
#species = (Modified sequence, Charge) — one entry per peptide-charge state per run
dfE['_species']=dfE['Modified sequence'].astype(str)+'_z'+dfE['Charge'].astype(str)
dfE['Experiment']=dfE['Experiment'].astype(str)
sampNames=sorted(dfE['Experiment'].unique())

# %% pivot to species × sample matrix: max intensity per (species, razor, experiment)
#   max not sum: duplicate evidence rows (e.g. two MSMS for same species) should not inflate
dfSp=(dfE.groupby(['_species','_razor','Experiment'])['Intensity']
         .max()
         .unstack('Experiment')
         .reindex(columns=sampNames)
         .replace(0,np.nan))
intCols=sampNames   #column names are sample names directly (not 'Intensity {s}')

# %% groupby protein: sum of max-per-species intensities (all protein tokens via explode)
#   this matches how MaxQuant computes proteinGroups Intensity — exactly, no rounding
dfSpR=dfSp.reset_index()
dfSEG=(dfSpR.assign(IDs=dfSpR['_razor'].str.split(';'))
            .explode('IDs')
            .groupby('IDs')[sampNames].sum()
            .replace(0,np.nan))
dfSEG.to_csv(pathFiles+'.combinedIntensity.csv')

# %% check for example protein A5A614 (E.coli PXD000279); skip if absent
if "A5A614" in dfSpR['_razor'].values:
    dfA5A614=dfSpR[dfSpR['_razor']=="A5A614"].set_index('_species')[sampNames]
    dfA5A614.T.plot.line().figure.savefig(pathFiles+'speciesSel.maxIntensity.png',
                                          dpi=100,bbox_inches="tight")
    dfA5A614.to_csv(pathFiles+'speciesSel.maxIntensity.csv')
    plt.close('all')

# %% log2 intensities per species
dfSEint=dfSp[sampNames].replace(0,np.nan)
dfSEintLog2=np.log2(dfSEint)

# %% pairwise subtract log2 sample values per species
dfSEintRepS=dfSEintLog2[np.repeat(dfSEintLog2.columns.values,dfSEintLog2.shape[1])]
dfSEintRepB=pd.concat([dfSEintLog2]*dfSEintLog2.shape[1],axis=1)
dfSEintRepS.columns=dfSEintRepS.columns+';'+dfSEintRepB.columns
dfSEintRepB.columns=dfSEintRepS.columns
dfSEintRepSB=(dfSEintRepS-dfSEintRepB).replace(0,np.nan)
dfSEintRepSB.dropna(axis=1,how='all',inplace=True)
dfSEintRepSB['Protein']=dfSpR['_razor'].values
dfSEintRepSB.sort_values('Protein',inplace=True)
dfSEintRepSB.to_csv(pathFiles+'sampleBySampleLog2IntensityDiff.csv')

# %% group species to protein using median of log2 differences
dfSEintRepSBPG=dfSEintRepSB.groupby('Protein').median()
dfSEintRepSBPG.to_csv(pathFiles+'proteins.merged.sampleBySampleIntensityMedian.csv')

# =============================================================================
# MaxLFQ classic linear (Cox et al. 2014, MCP 13:2513-2526)
# Species = (Modified sequence, Charge) — max intensity per species per experiment
# Steps: (1) N_j via LM over all pairwise log-residuals (unweighted, L2)
#        (2) normalise intensities by N_j; anchor max(N_j)=1
#        (3) per-protein: pairwise median log2-ratios -> lstsq profile
#            optional Eq.5: blend median ratio with sum-ratio for large-ratio pairs
#        (4) rescale profile so sum(LFQ)=sum(normalised) per protein
# =============================================================================

# %% maxlfq — species matrix already uses first-token razor; no explode needed
dfSraz=dfSp.copy()   #index: (_species, _razor); columns: sampNames
dfSraz=dfSraz[dfSraz.notna().any(axis=1)]

# %% maxlfq — delayed normalisation: N_j via LM (Cox et al. Eq.1-2), anchor max(N_j)=1
logX=np.log(dfSraz.values.astype(float))
pairs=list(combinations(range(len(sampNames)),2))
def _nj_residuals(nv):
    out=[]
    for a,b in pairs:
        ok=np.isfinite(logX[:,a])&np.isfinite(logX[:,b])
        if ok.any(): out.append((logX[ok,a]+nv[a])-(logX[ok,b]+nv[b]))
    return np.concatenate(out) if out else np.array([0.])
Nj=np.exp(least_squares(_nj_residuals,np.zeros(len(sampNames)),method='lm',max_nfev=2000).x)
if anchorSamp and anchorSamp in sampNames:
    Nj=Nj/Nj[sampNames.index(anchorSamp)]   #user-specified anchor
else:
    if anchorSamp: print(f"WARNING: anchor '{anchorSamp}' not in samples — using most-loaded")
    Nj=Nj/Nj.max()   #default: most-loaded sample = 1
print(f"anchor: {sampNames[int(np.argmin(np.abs(Nj-1.0)))]}")
for s,v in zip(sampNames,Nj): print(f"  N[{s}] = {v:.6f}")

# %% maxlfq — apply N_j
dfSrazNorm=dfSraz.multiply(Nj,axis=1)
dfSrazNorm=dfSrazNorm.reset_index()   #brings _species and _razor back as columns

# %% maxlfq — per-protein LFQ via pairwise median log2-ratios + lstsq + rescale
def _cc(logP):
    ns=logP.shape[1]; lbl=np.full(ns,-1,dtype=int)
    adj=(np.isfinite(logP).T@np.isfinite(logP))>0; np.fill_diagonal(adj,False)
    cc=0
    for i in range(ns):
        if lbl[i]!=-1 or not np.isfinite(logP[:,i]).any(): continue
        q=[i]; lbl[i]=cc
        while q:
            nd=q.pop()
            for nb in np.where(adj[nd])[0]:
                if lbl[nb]==-1: lbl[nb]=cc; q.append(nb)
        cc+=1
    return lbl

def _lfq_protein(matN,stab=False):
    logP=np.log2(matN); ns=logP.shape[1]; lbl=_cc(logP); profile=np.full(ns,np.nan)
    for c in range(int(lbl.max())+1 if lbl.max()>=0 else 0):
        idx=np.where(lbl==c)[0]; nc=len(idx); lp=logP[:,idx]
        nm=np.nanmax(matN[:,idx],axis=0)
        if nc==1: profile[idx[0]]=nm[0]; continue
        rat=np.full((nc,nc),np.nan)
        for j,k in combinations(range(nc),2):
            sh=np.isfinite(lp[:,j])&np.isfinite(lp[:,k])
            if sh.sum()<1: continue
            rm=float(np.median((lp[:,j]-lp[:,k])[sh]))
            if stab:
                #Eq.5: blend median ratio (rm) with log2 sum-ratio (rs)
                #x = max(n_j,n_k)/n_shared; blend weight w=(x-2.5)/2.5
                nj=int(np.isfinite(lp[:,j]).sum()); nk=int(np.isfinite(lp[:,k]).sum())
                x=max(nj,nk)/sh.sum()
                if x>2.5:
                    sj=float(np.nansum(matN[np.where(sh)[0],idx[j]]))
                    sk=float(np.nansum(matN[np.where(sh)[0],idx[k]]))
                    rs=float(np.log2(sj/sk)) if sj>0 and sk>0 else rm
                    w=min((x-2.5)/2.5,1.0); rm=(1-w)*rm+w*rs
            m=rm; rat[j,k]=m; rat[k,j]=-m
        has_r=np.any(np.isfinite(rat),axis=1)
        rows,vals=[],[]
        for j,k in combinations(range(nc),2):
            if np.isfinite(rat[j,k]) and has_r[j] and has_r[k]:
                r=np.zeros(nc); r[j]=1.; r[k]=-1.; rows.append(r); vals.append(rat[j,k])
        if not rows:
            p=np.full(nc,np.nan); p[has_r]=nm[has_r]; profile[idx]=p; continue
        sol,_,_,_=np.linalg.lstsq(np.array(rows),np.array(vals),rcond=None)
        p=2.**sol; p[~has_r]=np.nan
        act=has_r&np.isfinite(p)&(p>0)&np.isfinite(nm)
        if act.any(): p*=np.nansum(nm[act])/np.nansum(p[act])
        p[~has_r]=np.nan; profile[idx]=p
    return profile

# %% maxlfq — run over all proteins
lfqRecs=[]
for prot,grp in dfSrazNorm.groupby('_razor'):
    mat=grp[sampNames].values.astype(float); mat[mat==0]=np.nan
    if mat.shape[0]==0: continue
    prof=_lfq_protein(mat,stab=stabilize)
    lfqRecs.append({'Protein':prot,**{f'LFQ intensity {s}':
        float(v) if np.isfinite(v) and v>0 else np.nan for s,v in zip(sampNames,prof)}})
dfLFQ=pd.DataFrame(lfqRecs).set_index('Protein')

# %% maxlfq — raw sum per razor protein: sum of max-per-species per sample
dfRawSum=(dfSraz.reset_index()
                .groupby('_razor')[sampNames].sum()
                .replace(0,np.nan))
dfRawSum.columns=['rawSum '+c for c in dfRawSum.columns]
dfRawSum.index.name='Protein'

# %% maxlfq — merged output: rawSum + LFQ, one row per protein
dfRawSum.join(dfLFQ,how='outer').to_csv(pathFiles+'.proteins.rawSum_and_maxLFQ.csv')

# %% maxlfq — log2 LFQ profile plot
np.log2(dfLFQ.replace(0,np.nan)).T.plot.line(legend=False).figure.savefig(
    pathFiles+'proteins.maxLFQ.png',dpi=100,bbox_inches="tight")
plt.close('all')

# %% proteinGroups comparison (optional second argument)
if pgPath:
    pg=pd.read_csv(pgPath,sep='\t',low_memory=False)
    for _col in ['Reverse','Potential contaminant','Contaminant']:
        if _col in pg.columns: pg=pg[pg[_col].astype(str).str.strip()!='+']
    pg=pg.set_index('Majority protein IDs')
    pgRawCols=[c for c in pg.columns if c.startswith('Intensity ') and
               not c.startswith('Intensity unique')]
    pgRaw=pg[pgRawCols].apply(pd.to_numeric,errors='coerce').replace(0,np.nan)
    pgRaw.columns=pgRaw.columns.str.removeprefix('Intensity ')
    pgLFQ=pg[[c for c in pg.columns if c.startswith('LFQ intensity ')]].apply(pd.to_numeric,errors='coerce').replace(0,np.nan)

    # resolve semicolon protein group IDs by first token
    pgRaw.index=[i.split(';')[0].strip() for i in pgRaw.index]
    pgLFQ.index=[i.split(';')[0].strip() for i in pgLFQ.index]

    # proteins in proteinGroups not found in evidence-derived tables
    pg_only=pgRaw.index.difference(dfRawSum.index).union(pgLFQ.index.difference(dfLFQ.index))
    print(f"\nproteins in proteinGroups not found in evidence: {len(pg_only)}")
    if len(pg_only):
        print(f"  IDs: {pg_only.tolist()}")
        pgOnlyOut=pgRaw.loc[pgRaw.index.intersection(pg_only)].join(pgLFQ.loc[pgLFQ.index.intersection(pg_only)],how='outer')
        pgOnlyOut.columns=['pg_rawInt_'+c if not c.startswith('LFQ') else 'pg_'+c
                           for c in pgOnlyOut.columns]
        pgOnlyOut.index.name='Protein'
        pgOnlyOut.to_csv(pathFiles+'.pg_only_proteins.csv')

    # write comparison files
    dfRawSum.copy().set_axis(['calc_'+c for c in dfRawSum.columns],axis=1).join(pgRaw.add_prefix('pg_rawInt_'),how='inner').to_csv(pathFiles+'.compare.rawIntensity.csv')
    dfLFQ.copy().add_prefix('calc_').join(pgLFQ.add_prefix('pg_'),how='inner').to_csv(pathFiles+'.compare.LFQ.csv')

    # reload for summary
    dfRawComp=pd.read_csv(pathFiles+'.compare.rawIntensity.csv',index_col=0)
    dfLFQComp=pd.read_csv(pathFiles+'.compare.LFQ.csv',index_col=0)

    print("\nraw intensity comparison (calc rawSum vs proteinGroups Intensity):")
    for s in sampNames:
        cc=f'calc_rawSum {s}'; pc=f'pg_rawInt_{s}'
        if cc not in dfRawComp or pc not in dfRawComp: continue
        d=np.log2(dfRawComp[cc].astype(float))-np.log2(dfRawComp[pc].astype(float))
        d=d.replace([np.inf,-np.inf],np.nan).dropna()
        if len(d): print(f"  {s}: n={len(d)} MAE={np.mean(np.abs(d)):.4f} bias={np.mean(d):+.4f} log2")

    print("\nLFQ comparison (calc LFQ vs proteinGroups LFQ):")
    for s in sampNames:
        cc=f'calc_LFQ intensity {s}'; pc=f'pg_LFQ intensity {s}'
        if cc not in dfLFQComp or pc not in dfLFQComp: continue
        d=np.log2(dfLFQComp[cc].astype(float))-np.log2(dfLFQComp[pc].astype(float))
        d=d.replace([np.inf,-np.inf],np.nan).dropna()
        if len(d): print(f"  {s}: n={len(d)} MAE={np.mean(np.abs(d)):.4f} bias={np.mean(d):+.4f} log2")
