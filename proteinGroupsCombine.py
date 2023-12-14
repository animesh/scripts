#python proteinGroupsCombine.py L:\promec\TIMSTOF\LARS\2023\231128_plasma_KF\
import sys
from pathlib import Path
pathFiles = Path(sys.argv[1])
#pathFiles=Path("L:/promec/TIMSTOF/LARS/2023/231128_plasma_KF/")
fileName='proteinGroups.txt'
trainList=list(pathFiles.rglob(fileName))
#trainList=[fN for fN in trainList if "MGUS" in str(fN)]
#trainList=list([Path('L:/promec/TIMSTOF/LARS/2022/mars/Elise3/combined/txt/proteinGroups.txt'),Path('L:/promec/TIMSTOF/LARS/2022/januar/220119_ELise_rerun/Oslo/txt/proteinGroups.txt')])
#!pip3 install pandas --user
import pandas as pd
#df = pd.concat(map(pd.read_table, trainList))
#df.to_csv(pathFiles.with_suffix('.combinedT.txt'),sep="\t")#,rownames=FALSE)
dfI=pd.DataFrame()
dfC=pd.DataFrame()
dfB=pd.DataFrame()
i=0
for f in trainList:
    #f=trainList[i]
    i=i+1
    if Path(f).stat().st_size > 0:
        print(i,f.parts[-4],f.parts[-1])
        proteinHits=pd.read_csv(f,low_memory=False,sep='\t')
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
print("Intensity common")
dfIp=dfI.pivot(index='ID', columns='Name', values='Intensity')
dfIp.to_csv(pathFiles / (fileName +'.dfIp.csv'))
dfIp.dropna(axis=1, how='all', inplace=True)
dfIpDD=dfIp.drop_duplicates()    
print(dfIpDD.notna().all(axis=1).sum())
print(dfIpDD.count(axis=0))
dfIpDD.to_csv(pathFiles / (fileName +'.dfIpDD.csv'))
#dfIp['cat']=dfIp.astype(str).sum(axis=1)
#dfIp = dfIp.reset_index()
import numpy as np
dfIpDDlog2=np.log2(dfIpDD)
dfIpDDlog2.to_csv(pathFiles / (fileName +'.dfIpDDlog2.csv'))
print(dfIpDDlog2.corr(method='spearman'))
dfIpDDlog2na=dfIpDDlog2.fillna(0)
dfIpDDlog2na.plot.scatter(dfIpDDlog2.columns[0],dfIpDDlog2.columns[1]).figure.savefig(pathFiles / (fileName +'.scatter.dfIpDDlog2na.png'),dpi=100,bbox_inches = "tight")
dfIpDDlog2na.plot(kind='hist',alpha=0.5,bins=100).figure.savefig(pathFiles / (fileName +'.hist.dfIpDDlog2.png'),dpi=100,bbox_inches = "tight")
dfCp=dfC.pivot(index='ID', columns='Name', values='Score')
dfBp=dfB.pivot(index='ID', columns='Name', values='iBAQ')
dfBp['SumB']=dfBp.astype(str).sum(axis=1)
dfCp['SumC']=dfCp.astype(str).sum(axis=1)
dfBp=dfBp[dfBp['SumB']!=0]
dfCp=dfCp[dfCp['SumC']!=0]
dfBp=dfBp.sort_values('SumB',ascending=False)
dfCp=dfCp.sort_values('SumC',ascending=False)
dfBp.to_csv(pathFiles/(fileName+"Combo.iBAQL.csv"))#.with_suffix('.combo.csv'))
dfCp.to_csv(pathFiles/(fileName+"Combo.score.csv"))#.with_suffix('.combo.csv'))
