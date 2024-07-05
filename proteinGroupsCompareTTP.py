#!pip3 install pandas matplotlib pathlib --user
#python proteinGroupsCompareTTP.py "Protein accession"  L:\promec\TIMSTOF\LARS\2024\240626_Mira\Mira.tsv L:\promec\TIMSTOF\LARS\2024\240626_Mira\Mira2.tsv
# %% setup
import sys
from pathlib import Path
import pandas as pd
# %% read
#cID=sys.argv[1]
cID="Protein accession"
#pathFile1 = Path(sys.argv[2])  
pathFile1 = Path("L:/promec/TIMSTOF/LARS/2024/240626_Mira/Mira.tsv")  
#pathFile2 = Path(sys.argv[3])  
pathFile2 = Path("L:/promec/TIMSTOF/LARS/2024/240626_Mira/Mira2.tsv")  
#compare
pdHits1=pd.read_csv(pathFile1,low_memory=False,sep='\t')
print(pdHits1.columns)
pdHits2=pd.read_csv(pathFile2,low_memory=False,sep='\t')
print(pdHits2.columns)
# %% combine
pdHits1.rename({cID:'ID'},inplace=True,axis='columns')
pdHits2.rename({cID:'ID'},inplace=True,axis='columns')
pdHits=pd.merge(pdHits1,pdHits2,on='ID',how='outer',suffixes=('_pathFile1', '_pathFile2'))
pdHits=pdHits.fillna(0)
print(pdHits.describe())
print(pdHits.columns)
# %% compare
pdHitsDiff=pd.DataFrame()
for c in pdHits.columns:
    if c.endswith('_pathFile1'):
        c2=c.replace('_pathFile1','_pathFile2')
        if c2 in pdHits.columns:
            c0=c.replace('_pathFile1','')
            print(c0,c,c2)
            if pdHits[c].dtype == 'float64':
                pdHitsDiff[c0]=pdHits[c]-pdHits[c2]
                print(pdHitsDiff[c0].describe())
print(pdHitsDiff.columns)
print(pdHitsDiff.shape)
pdHitsDiff.index=pdHits.ID
pdHitsDiff.to_csv(pathFile1.with_name(pathFile1.stem+".diffall."+pathFile2.stem+".csv"))
# %% cleanup
import numpy as np
pdHitsDiff.replace(0, np.nan, inplace=True)
pdHitsDiff.dropna(axis=1, how='all', inplace=True)
pdHitsDiff.dropna(axis=0, how='all', inplace=True)
print(pdHitsDiff.describe())
print(pdHitsDiff.shape)
print(pdHitsDiff.columns)
pdHitsDiff.to_csv(pathFile1.with_name(pathFile1.stem+".diff."+pathFile2.stem+".csv"))
# %% plot
pdHitsDiff=pdHitsDiff[pdHitsDiff.columns[~pdHitsDiff.columns.str.endswith(' avg')]]
plotcsv=pathFile1.with_name(pathFile1.stem+".diff."+pathFile2.stem+".histogram.svg")
pdHitsDiff.plot(kind='hist',alpha=0.5,bins=100,legend=False).figure.savefig(plotcsv,dpi=320,bbox_inches = "tight")
print(plotcsv)
# %%
