# python proteinGroupsCombine.py D:\TMPDIR\mqpar.xml_20250403_135936 4 12
# D:\TMPDIR\mqpar.xml_20250403_135936 is output of mqrun.bat
# %%setup
#python -m pip install pandas seaborn pathlib supervenn
import sys
from pathlib import Path
# %% read
if len(sys.argv) != 4: sys.exit("\n\nREQUIRED: pandas, seaborn, supervenn, pathlib\nUSAGE: python proteinGroupsCombine.py <path to folder containing proteinGroups.txt file(s)> <ID position from last> <start position within ID string>")
pathFiles = Path(sys.argv[1])
#pathFiles=Path("D:\\TMPDIR\\mqpar.xml_20250403_135936")
fileName='proteinGroups.txt'
fNID=int(sys.argv[2])
#fNID=4
fnIDpart=int(sys.argv[3])
#fnIDpart=12
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
            #proteinHits=proteinHits[proteinHits['Potential contaminant']!="+"]
            #proteinHits=proteinHits[proteinHits['Only identified by site']!="+"]
            #proteinHits=proteinHits[~proteinHits['ID'].str.contains("_HUMAN",na=False)]
            proteinHitsC=proteinHits.ID.str.split(';', expand=True).set_index(proteinHits.Score).stack().reset_index(level=0, name='ID')
            proteinHitsI=proteinHits.ID.str.split(';', expand=True).set_index(proteinHits.Intensity).stack().reset_index(level=0, name='ID')
            proteinHitsI['Name']=str(f.parts[(-1)*fNID])[fnIDpart:]
            proteinHitsC['Name']=str(f.parts[(-1)*fNID])[fnIDpart:]
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
dfIpDD.to_csv(pathFiles/(fileName+'.dfIpDD.csv'))
import numpy as np
dfIpDDlog2=np.log2(dfIpDD+1)
dfIpDDlog2.to_csv(pathFiles/(fileName+'.dfIpDDlog2.csv'))
#%%score
dfCp=dfC.pivot(index='ID', columns='Name', values='Score')
dfCp['SumC']=dfCp.sum(axis=1)
dfCp=dfCp.sort_values('SumC',ascending=False)
dfCp.to_csv(pathFiles/(fileName+"Combo.score.csv"))#.with_suffix('.combo.csv'))
dfCpDD=dfCp.drop_duplicates()    
print(dfCpDD.notna().all(axis=1).sum())
print(dfCpDD.count(axis=0))
#%%results
print("procesed "+str(len(trainList))+" "+fileName+" in dir "+str(pathFiles))
print("results")
print(str(pathFiles)+"\\"+fileName+"Combo.score.csv")
