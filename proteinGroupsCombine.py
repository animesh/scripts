# python proteinGroupsCombine.py L:/promec/TIMSTOF/LARS/2024/240827_Bead_test/batchCombine
#[ash022@login-1.SAGA ~/scripts]$# tar cvzf 240827_BeadsPG.tgz mqpar*/240827_B*/combined/txt/proteinGroups.txt
#[PROMEC] mkdir L:\promec\TIMSTOF\LARS\2024\240827_Bead_test\batchCombine\
# scp ash022@login-1.saga.sigma2.no:scripts/240827_BeadsPG.tgz L:\promec\TIMSTOF\LARS\2024\240827_Bead_test\batchCombine\
# tar xvzf L:\promec\TIMSTOF\LARS\2024\240827_Bead_test\batchCombine\240827_BeadsPG.tgz -C L:\promec\TIMSTOF\LARS\2024\240827_Bead_test\batchCombine\
# %%setup
import sys
from pathlib import Path
if len(sys.argv) != 2: sys.exit("\n\nREQUIRED: pandas, seaborn, pathlib\nUSAGE: python peptideGroupsCombine.py <path to folder containing peptides.txt file(s)>")
pathFiles = Path(sys.argv[1])
#pathFiles=Path("L:/promec/TIMSTOF/LARS/2024/240827_Bead_test/batchCombine/")
fileName='proteinGroups.txt'
trainList=list(pathFiles.rglob(fileName))
print(trainList)
#%%data 
#trainList=[fN for fN in trainList if "DIA" in str(fN)]
#!pip3 install pandas --user
import pandas as pd
#df = pd.concat(map(pd.read_table, trainList))
#df.to_csv(pathFiles.with_suffix('.combinedT.txt'),sep="\t")#,rownames=FALSE)
dfI=pd.DataFrame()
dfC=pd.DataFrame()
i=0
for f in trainList:
    #f=trainList[i]
    i=i+1
    if Path(f).stat().st_size > 0:
        print(i,f.parts)
        proteinHits=pd.read_csv(f,low_memory=False,sep='\t')
        if 'Protein IDs' in proteinHits:
            cN=proteinHits.columns
            proteinHits=proteinHits[proteinHits['Reverse']!="+"]
            proteinHits=proteinHits[proteinHits['Potential contaminant']!="+"]
            #proteinHits=proteinHits[proteinHits['Only identified by site']!="+"]
            proteinHits.rename({'Protein IDs':'ID'},inplace=True,axis='columns')
            #proteinHits=proteinHits[~proteinHits['ID'].str.contains("_HUMAN",na=False)]
            proteinHitsC=proteinHits.ID.str.split(';', expand=True).set_index(proteinHits.Score).stack().reset_index(level=0, name='ID')
            proteinHitsI=proteinHits.ID.str.split(';', expand=True).set_index(proteinHits.Intensity).stack().reset_index(level=0, name='ID')
            proteinHitsI['Name']=str(f.parts[-4])[13:28]
            proteinHitsC['Name']=str(f.parts[-4])[13:28]
            dfI=pd.concat([dfI,proteinHitsI],sort=False)
            dfC=pd.concat([dfC,proteinHitsC],sort=False)
print(dfI.columns)
print(dfC.columns)
#%%intensity
print("Intensity common")
dfIp=dfI.pivot(index='ID', columns='Name', values='Intensity')
dfIp.dropna(axis=1, how='all', inplace=True)
dfIpDD=dfIp.drop_duplicates()    
print(dfIpDD.notna().all(axis=1).sum())
print(dfIpDD.count(axis=0))
import numpy as np
dfIpDDlog2=np.log2(dfIpDD+1)
dfIpDDlog2.to_csv(pathFiles/(fileName +'.dfIpDDlog2.csv'))
print(dfIpDDlog2.corr(method='spearman'))
#import matplotlib.pyplot as plt
#dfIpDDlog2.plot()
#plt.show()
#%%score
dfCp=dfC.pivot(index='ID', columns='Name', values='Score')
dfCp['SumC']=dfCp.astype(str).sum(axis=1)
dfCp=dfCp[dfCp['SumC']!=0]
dfCp=dfCp.sort_values('SumC',ascending=False)
dfCp.to_csv(pathFiles/(fileName+"Combo.score.csv"))#.with_suffix('.combo.csv'))
#%%results
print("procesed "+str(len(trainList))+" "+fileName+" in dir "+str(pathFiles))
print("results")
print(str(pathFiles)+"\\"+fileName+"Combo.score.csv")

