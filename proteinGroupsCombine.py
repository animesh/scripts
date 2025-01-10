# mqrun.bat
# python proteinGroupsCombine.py L:\promec\TIMSTOF\LARS\2025\250107_Hela_Coli\DDA
# %%setup
#python -m pip install pandas seaborn pathlib supervenn
import sys
from pathlib import Path
# %% read
if len(sys.argv) != 2: sys.exit("\n\nREQUIRED: pandas, seaborn, supervenn, pathlib\nUSAGE: python peptideGroupsCombine.py <path to folder containing proteinGroups.txt file(s)> <species filter> <species include>")
pathFiles = Path(sys.argv[1])
#pathFiles=Path("L:\\promec\\TIMSTOF\\LARS\\2025\\250107_Hela_Coli\\DDA")
fileName='proteinGroups.txt'
trainList=list(pathFiles.rglob(fileName))
print(trainList)
print(len(trainList),"files found in",pathFiles)
#%%data 
#trainList=[fN for fN in trainList if "DIA" in str(fN)]
#!pip3 install pandas --user
import pandas as pd
#df = pd.concat(map(pd.read_table, trainList))
#df.to_csv(pathFiles.with_suffix('.combinedT.txt'),sep="\t")#,rownames=FALSE)
dfI=pd.DataFrame()
dfC=pd.DataFrame()
i=0
#f=trainList[i]
for f in trainList:
    i=i+1
    if Path(f).stat().st_size > 0:
        print(i,f.parts)
        proteinHits=pd.read_csv(f,low_memory=False,sep='\t')
        if 'Protein IDs' in proteinHits:
            #print(proteinHits.columns)
            proteinHits.rename({'Protein IDs':'ID'},inplace=True,axis='columns')
            proteinHits=proteinHits[proteinHits['Reverse']!="+"]
            proteinHits=proteinHits[proteinHits['Potential contaminant']!="+"]
            #proteinHits=proteinHits[proteinHits['Only identified by site']!="+"]
            proteinHits=proteinHits[~proteinHits['ID'].str.contains("_HUMAN",na=False)]
            proteinHitsC=proteinHits.ID.str.split(';', expand=True).set_index(proteinHits.Score).stack().reset_index(level=0, name='ID')
            proteinHitsI=proteinHits.ID.str.split(';', expand=True).set_index(proteinHits.Intensity).stack().reset_index(level=0, name='ID')
            proteinHitsI['Name']=str(f.parts[-2])[12:27]
            proteinHitsC['Name']=str(f.parts[-2])[12:22]
            dfI=pd.concat([dfI,proteinHitsI],sort=False)
            dfC=pd.concat([dfC,proteinHitsC],sort=False)
print(dfI.columns)
print(dfC.columns)
#%%intensity
print("Intensity common",dfI.duplicated().sum())
print(dfI[dfI.duplicated(keep=False)])
dfIDD=dfI#.drop_duplicates()    
print(dfIDD[dfIDD.duplicated(keep=False)])
#dfIp=dfIDD.pivot_table(index='ID', columns='Name', values='Intensity',aggfunc='max')
dfIp=dfIDD.pivot(index='ID', columns='Name', values='Intensity')
dfIp.dropna(axis=1, how='all', inplace=True)
dfIpDD=dfIp.drop_duplicates()    
print(dfIpDD.notna().all(axis=1).sum())
print(dfIpDD.count(axis=0))
import numpy as np
dfIpDDlog2=np.log2(dfIpDD+1)
dfIpDDlog2.to_csv(pathFiles/(fileName+'.dfIpDDlog2.csv'))
print(dfIpDDlog2.corr(method='pearson'))
dfIpDDlog2.T.plot(kind='line',alpha=0.6,legend=False,rot=90,fontsize=10).figure.savefig(pathFiles/(fileName+"dfIpDDlog2.line.svg"),dpi=100,bbox_inches = "tight")
print(pathFiles/(fileName+"dfIpDDlog2.line.svg"))
#%%scatter
import seaborn as sns
ppS=sns.PairGrid(dfIpDDlog2)
coefV=dfIpDDlog2.corr()
ppS.fig.suptitle(coefV)
ppS.map_diag(sns.histplot)
ppS.map_lower(sns.kdeplot)
ppS.map_upper(sns.regplot)
ppS.savefig(pathFiles/(fileName+"dfIpDDlog2.scatter.svg"), dpi=100, bbox_inches="tight")
#%%score
dfC=dfC[~dfC['ID'].duplicated()]
dfCp=dfC.pivot(index='ID', columns='Name', values='Score')
dfCp['SumC']=dfCp.astype(str).sum(axis=1)
dfCp=dfCp[dfCp['SumC']!=0]
dfCp=dfCp.sort_values('SumC',ascending=False)
dfCp.to_csv(pathFiles/(fileName+"Combo.score.csv"))#.with_suffix('.combo.csv'))
dfCpDD=dfCp.drop_duplicates()    
print(dfCpDD.notna().all(axis=1).sum())
print(dfCpDD.count(axis=0))
#%%results
print("procesed "+str(len(trainList))+" "+fileName+" in dir "+str(pathFiles))
print("results")
print(str(pathFiles)+"\\"+fileName+"Combo.score.csv")
# %% venn
from supervenn import supervenn, make_sets_from_chunk_sizes
import matplotlib.pyplot as plt
plt.figure(figsize=(10, 10))
dfPGIvenn = dfIpDDlog2.notna()
dfPGIvenn['size'] = 1#dfPGIvenn.sum(axis=1)
sets, labels = make_sets_from_chunk_sizes(dfPGIvenn)
supervenn(sets, labels)
#plt.show()
plt.savefig(pathFiles/(fileName+"dfPGI.venn.svg"), dpi=100, bbox_inches="tight")
plt.close()
plt.figure(figsize=(10, 10))
dfPepGSvenn = dfCpDD.notna()
dfPepGSvenn['size'] = 1#dfPGIvenn.sum(axis=1)
sets, labels = make_sets_from_chunk_sizes(dfPepGSvenn)
supervenn(sets, labels)
#plt.show()
plt.savefig(pathFiles/(fileName+"dfPGS.venn.svg"), dpi=100, bbox_inches="tight")
plt.close()

