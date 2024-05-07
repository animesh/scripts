#$HOME/bin/python3 proteinGroupsCombine.py combined/
# %%setup
import sys
from pathlib import Path
pathFiles = Path(sys.argv[1])
pathFiles=Path("L:/promec/TIMSTOF/LARS/2024/240221_Tom_Kelt/combined/txtv252/proteinGroups.txt")
ID1='Protein IDs'
ID2='Uniprot'
print(pathFiles)
#%%data 
import pandas as pd
if pathFiles.stat().st_size > 0:
    print(pathFiles.parts)
    proteinHits=pd.read_csv(f,low_memory=False,sep='\t')
    if ID1 in proteinHits:
        print(proteinHits.columns)
        proteinHits.rename({ID1:'ID'},inplace=True,axis='columns')
        proteinHits.ID=proteinHits.ID.str.split(';')
        proteinHits=proteinHits.explode('ID')
print(proteinHits.columns)
#%%intensity
print("Intensity common")
dfIp=dfI.pivot(index='ID', columns='Name', values='Intensity')
dfIp.dropna(axis=1, how='all', inplace=True)
dfIpDD=dfIp.drop_duplicates()    
print(dfIpDD.notna().all(axis=1).sum())
print(dfIpDD.count(axis=0))
import numpy as np
dfIpDDlog2=np.log2(dfIpDD+1)
dfIpDDlog2.to_csv(fileName +'.dfIpDDlog2.csv')
print(dfIpDDlog2.corr(method='spearman'))
#import matplotlib.pyplot as plt
#dfIpDDlog2.plot()
#plt.show()
dfCp=dfC.pivot(index='ID', columns='Name', values='Score')
dfCp['SumC']=dfCp.astype(str).sum(axis=1)
dfCp=dfCp[dfCp['SumC']!=0]
dfCp=dfCp.sort_values('SumC',ascending=False)
dfCp.to_csv(fileName+"Combo.score.csv")#.with_suffix('.combo.csv'))
#%%results
print("procesed"+str(len(trainList))+fileName+str(pathFiles))
print("results"+(fileName+"Combo.score.csv")+fileName +'.dfIpDDlog2.csv')
# %%
pathFiles/(fileName+"Combo.score.csv")#.with_suffix('.combo.csv')
