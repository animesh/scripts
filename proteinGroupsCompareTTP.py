#!pip3 install pandas matplotlib pathlib --user
#python proteinGroupsCompareTTP.py ID  L:\promec\TIMSTOF\LARS\2024\240626_Mira\2de755bb378949183b1b6b89a359e507\processing-run\PSMs.sum.csv L:\promec\TIMSTOF\LARS\2024\240626_Mira\b3093c79d999b9393e121db1af7c0438\processing-run\PSMs.sum.csv 
# %% setup
import sys
from pathlib import Path
import pandas as pd
# %% read
#pathFiles=Path("L:/promec/TIMSTOF/LARS/2024/240626_Mira/2de755bb378949183b1b6b89a359e507/processing-run/PSMs.sum.csv","L:/promec/TIMSTOF/LARS/2024/240626_Mira/b3093c79d999b9393e121db1af7c0438/processing-run/PSMs.sum.csv")
#pathFiles=Path()
cID=sys.argv[1]
#cID="ID"
pathFile1 = Path(sys.argv[2])  
#pathFile1 = Path("L:/promec/TIMSTOF/LARS/2024/240626_Mira/2de755bb378949183b1b6b89a359e507/processing-run/PSMs.sum.csv")  
pathFile2 = Path(sys.argv[3])  
#pathFile2 = Path("L:/promec/TIMSTOF/LARS/2024/240626_Mira/b3093c79d999b9393e121db1af7c0438/processing-run/PSMs.sum.csv")  
#compare
pdHits1=pd.read_csv(pathFile1,low_memory=False)
print(pdHits1.columns)
pdHits2=pd.read_csv(pathFile2,low_memory=False)
print(pdHits2.columns)
# %% compare
pdHits1.rename({cID:'ID'},inplace=True,axis='columns')
pdHits2.rename({cID:'ID'},inplace=True,axis='columns')
pdHits=pd.merge(pdHits1,pdHits2,on='ID',how='outer',suffixes=('_pathFile1', '_pathFile2'))
pdHits=pdHits.fillna(0)
print(pdHits.describe())
print(pdHits.columns)
pdHitsDiff=pd.DataFrame()
for c in pdHits.columns:
    if c.endswith('_pathFile1'):
        c2=c.replace('_pathFile1','_pathFile2')
        if c2 in pdHits.columns:
            print(c,c2)
            c0=c.replace('_pathFile1','')
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
pdHitsDiff.to_csv(pathFile1.with_name(pathFile1.stem+".diff."+pathFile2.stem+".csv"))
# %% plot
print(pdHitsDiff.columns)
pdHitsDiff.drop("PSMs",inplace=True,axis=1)
plotcsv=pathFile1.with_name(pathFile1.stem+".diff."+pathFile2.stem+".histogram.svg")
pdHitsDiff.plot(kind='hist',alpha=0.5,bins=100).figure.savefig(plotcsv,dpi=100,bbox_inches = "tight")
print(plotcsv)
# %%
