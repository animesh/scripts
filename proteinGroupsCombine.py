# python proteinGroupsCombine.py L:/promec/TIMSTOF/LARS/2024/240924_hela5ng_evosep/1106/mqparTTPdda.xml.1727445966.results
# python proteinGroupsCombine.py L:/promec/TIMSTOF/LARS/2024/240924_hela5ng_evosep/1109/mqparTTPdda.xml.1727429393.results
# python proteinGroupsCombine.py L:/promec/TIMSTOF/LARS/2024/240924_hela5ng_evosep/1109/mqparTTPdda.xml.1727429303.results
# python proteinGroupsCombine.py L:/promec/TIMSTOF/LARS/2024/240924_hela5ng_evosep/bruker10/mqparTTPdia.xml.1727263522.results
# data
# mkdir helaDIAzoom
# rsync -Parv login.nird-lmd.sigma2.no:PD/TIMSTOF/LARS/2024/240924_hela5ng_evosep/bruker10/*dia*d helaDIAzoom/
# bash slurmMQrunTTP.sh /cluster/projects/nn9036k/MaxQuant_v2.6.3.0/bin/MaxQuantCmd.dll /cluster/projects/nn9036k/scripts/helaDIAzoom /cluster/projects/nn9036k/FastaDB/uniprotkb_proteome_UP000005640_2024_04_18.fasta mqparTTPdia.xml scratch.slurm
# rsync -Pirm --include='proteinGroups.txt' --include='*/' --exclude='*' ash022@login.saga.sigma2.no:scripts/mqparTTPdia.xml.1727263522.results  /mnt/l/promec/TIMSTOF/LARS/2024/240924_hela5ng_evosep/bruker10/
# mkdir c1106
# rsync -Parv login.nird-lmd.sigma2.no:PD/TIMSTOF/LARS/2024/240924_hela5ng_evosep/1106/*d c1106/
# bash slurmMQrunTTP.sh /cluster/projects/nn9036k/MaxQuant_v2.6.3.0/bin/MaxQuantCmd.dll /cluster/projects/nn9036k/scripts/c1106 /cluster/projects/nn9036k/FastaDB/uniprotkb_proteome_UP000005640_2024_04_18.fasta mqparTTPdda.xml scratch.slurm
# rsync -Pirm --include='proteinGroups.txt' --include='*/' --exclude='*' ash022@login.saga.sigma2.no:scripts/mqparTTPdda.xml.1727445966.results  /mnt/l/promec/TIMSTOF/LARS/2024/240924_hela5ng_evosep/1106/
# mkdir c1109
# rsync -Parv login.nird-lmd.sigma2.no:PD/TIMSTOF/LARS/2024/240924_hela5ng_evosep/1109/*d c1109/
# bash slurmMQrunTTP.sh /cluster/projects/nn9036k/MaxQuant_v2.6.3.0/bin/MaxQuantCmd.dll /cluster/projects/nn9036k/scripts/c1109 /cluster/projects/nn9036k/FastaDB/uniprotkb_proteome_UP000005640_2024_04_18.fasta mqparTTPdda.xml scratch.slurm
# rsync -Pirm --include='proteinGroups.txt' --include='*/' --exclude='*' ash022@login.saga.sigma2.no:scripts/mqparTTPdda.xml.1727429393.results  /mnt/l/promec/TIMSTOF/LARS/2024/240924_hela5ng_evosep/1109/
# %%setup
#python -m pip install pandas seaborn pathlib supervenn
import sys
from pathlib import Path
# %% read
if len(sys.argv) != 2: sys.exit("\n\nREQUIRED: pandas, seaborn, supervenn, pathlib\nUSAGE: python peptideGroupsCombine.py <path to folder containing peptides.txt file(s)>")
pathFiles = Path(sys.argv[1])
#pathFiles=Path("L:/promec/TIMSTOF/LARS/2024/240924_hela5ng_evosep/1106/mqparTTPdda.xml.1727445966.results")
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
            proteinHitsI['Name']=str(f.parts[-4])[15:29]
            proteinHitsC['Name']=str(f.parts[-4])[15:29]
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

