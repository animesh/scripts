#$HOME/bin/python3 proteinGroupsCombine.py combined/
# %%setup
import sys
from pathlib import Path
pathFiles = Path(sys.argv[1])
<<<<<<< Updated upstream
#pathFiles=Path("L23")
=======
#pathFiles=Path("L:/promec/TIMSTOF/LARS/2023/231128_plasma_KF/")
>>>>>>> Stashed changes
fileName='proteinGroups.txt'
trainList=list(pathFiles.rglob(fileName))
print(trainList)
#%%data 
#trainList=[fN for fN in trainList if "MGUS" in str(fN)]
#!pip3 install pandas --user
import pandas as pd
#df = pd.concat(map(pd.read_table, trainList))
#df.to_csv(pathFiles.with_suffix('.combinedT.txt'),sep="\t")#,rownames=FALSE)
dfI=pd.DataFrame()
dfC=pd.DataFrame()
<<<<<<< Updated upstream
=======
dfB=pd.DataFrame()
>>>>>>> Stashed changes
i=0
for f in trainList:
    #f=trainList[i]
    i=i+1
    if Path(f).stat().st_size > 0:
        print(i,f.parts)
        proteinHits=pd.read_csv(f,low_memory=False,sep='\t')
<<<<<<< Updated upstream
        if 'Protein IDs' in proteinHits:
            cN=proteinHits.columns
            proteinHits=proteinHits[proteinHits['Reverse']!="+"]
            proteinHits=proteinHits[proteinHits['Potential contaminant']!="+"]
            proteinHits=proteinHits[proteinHits['Only identified by site']!="+"]
            proteinHits.rename({'Protein IDs':'ID'},inplace=True,axis='columns')
            proteinHits=proteinHits[~proteinHits['ID'].str.contains("_HUMAN",na=False)]
            proteinHitsC=proteinHits.ID.str.split(';', expand=True).set_index(proteinHits.Score).stack().reset_index(level=0, name='ID')
            proteinHitsI=proteinHits.ID.str.split(';', expand=True).set_index(proteinHits.Intensity).stack().reset_index(level=0, name='ID')
            proteinHitsI['Name']=str(f.parts)+str(i)
            proteinHitsC['Name']=str(f.parts)+str(i)
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
=======
        cN=proteinHits.columns
        proteinHits=proteinHits[proteinHits['Reverse']!="+"]
        proteinHits=proteinHits[proteinHits['Potential contaminant']!="+"]
        proteinHits=proteinHits[proteinHits['Only identified by site']!="+"]
        proteinHits.rename({'Protein IDs':'ID'},inplace=True,axis='columns')
        proteinHits=proteinHits[~proteinHits['ID'].str.contains("_HUMAN",na=False)]
        proteinHitsC=proteinHits.ID.str.split(';', expand=True).set_index(proteinHits.Score).stack().reset_index(level=0, name='ID')
        proteinHitsI=proteinHits.ID.str.split(';', expand=True).set_index(proteinHits.Intensity).stack().reset_index(level=0, name='ID')
        proteinHitsB=proteinHits.ID.str.split(';', expand=True).set_index(proteinHits.iBAQ).stack().reset_index(level=0, name='ID')
        proteinHitsI['Name']=f.parts[-4]+f.parts[-1]+str(i)
        proteinHitsC['Name']=f.parts[-4]+f.parts[-1]+str(i)
        proteinHitsB['Name']=f.parts[-4]+f.parts[-1]+str(i)
        dfI=pd.concat([dfI,proteinHitsI],sort=False)
        dfC=pd.concat([dfC,proteinHitsC],sort=False)
        dfB=pd.concat([dfB,proteinHitsB],sort=False)
print(dfI.columns)
print(dfC.columns)
print(dfB.columns)
print("Intensity")
dfIp=dfI.pivot(index='ID', columns='Name', values='Intensity')
dfIp.to_csv(pathFiles / (fileName +'.dfIp.csv'))
dfIp.dropna(axis=1, how='all', inplace=True)
dfIpDD=dfIp.drop_duplicates()    
dfIpDD.notna().all(axis=1).sum()
print(dfIpDD.count(axis=0))
#dfIp['cat']=dfIp.astype(str).sum(axis=1)
#dfIp = dfIp.reset_index()
dfIpDD=dfIp.fillna(0)
dfIpDD.to_csv(pathFiles / (fileName +'.dfIpDD.csv'))
#print("Scatter of Intensit in",writeDPpng)
writeDPpng=(pathFiles / (fileName +'.dfIpDD.csv'))
df.plot(kind='hist').figure.savefig(writeDPpng.absolute(),dpi=100,bbox_inches = "tight")
dfIp.to_csv(pathFiles / (fileName +'.dfIp.csv'))
dfCp=dfC.pivot(index='ID', columns='Name', values='Score')
dfBp=dfB.pivot(index='ID', columns='Name', values='iBAQ')
dfBp['SumB']=dfBp.astype(str).sum(axis=1)
dfCp['SumC']=dfCp.astype(str).sum(axis=1)
dfIp.groupby('cat').
dfI=dfI[dfI['SumI']!=0]
dfB=dfB[dfB['SumB']!=0]
dfC=dfC[dfC['SumC']!=0]
dfI=dfI.sort_values('SumI',ascending=False)
dfB=dfB.sort_values('SumB',ascending=False)
dfC=dfC.sort_values('SumC',ascending=False)
dfI.to_csv(pathFiles/(fileName+"Combo.intensityL.csv"))#.with_suffix('.combo.csv'))
dfB.to_csv(pathFiles/(fileName+"Combo.iBAQL.csv"))#.with_suffix('.combo.csv'))
dfC.to_csv(pathFiles/(fileName+"Combo.score.csv"))#.with_suffix('.combo.csv'))
histScores=pathFiles/(fileName+"HistInt.svg")
>>>>>>> Stashed changes
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
