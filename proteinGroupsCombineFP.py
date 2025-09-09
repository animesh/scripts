#python proteinGroupsCombineFP.py VibekeV/ "*.FP.result"
#output from bash slurmFP.sh /nird/projects/NS9036K/NORSTORE_OSL_DISK/NS9036K/promec/promec/Elite/LARS/2018/mai/Vibeke\ V
#!pip3 install pandas --user
# %% setup
import sys
from pathlib import Path
import pandas as pd
# %% data
pathFiles = Path(sys.argv[1])
#pathFiles=Path("VibekeV/")
dirName=sys.argv[2]
#dirName="*.FP.result"
fileName='protein.tsv'
fileNameOut=dirName.replace("*","")+"_comb"
print(fileNameOut)
trainList=list(pathFiles.rglob(fileName))
trainList=[f for f in trainList if dirName.replace("*","") in str(f)]
print(trainList)
print(len(trainList),"files found in",pathFiles)
# %% combine
df=pd.DataFrame()
#f=trainList[-1]
for f in trainList:
    if Path(f).stat().st_size > 0:
        fName=f.parts[-2].split('_')[2].split('.')[0]
        print(fName,f)
        proteinHits=pd.read_csv(f,sep='\t',low_memory=False)
        proteinHits.rename({'Protein':'ID'},inplace=True,axis='columns')
        proteinHits.rename({'Unique Spectral Count':'intensity'},inplace=True,axis='columns')
        proteinHits['intensity'].fillna(0,inplace=True)
        #proteinHitsS=proteinHits.ID.str.split(';').explode('ID').reset_index(drop=True)
        proteinHitsS=proteinHits.ID.str.split(';', expand=True).set_index(proteinHits.intensity).stack().reset_index().rename(columns={0:'ID'})
        proteinHitsS.index=proteinHitsS.ID
        proteinHitsS=proteinHitsS.drop(columns='ID')
        proteinHitsS['Name']=fName
        df=pd.concat([df,proteinHitsS],sort=False)
print(df.head())
print(df.columns)
# %% pivot
df=df.pivot(columns='Name', values='intensity')
print(df.head())
df['sum']=df.sum(axis=1)
df=df.sort_values("sum", ascending=False)  
# %% plot
print(df.head())
print(df.isnull().sum())
#writeDPpng=pathFiles/(fileName+"Score.png")
#df.plot(kind='hist').figure.savefig(writeDPpng.absolute(),dpi=100,bbox_inches = "tight")
#print("Histogram of Score in",writeDPpng)
# %% write
dfU=df.drop_duplicates()
dfU=dfU[dfU['sum']>0]
print(dfU.notna().sum())
writeScores=pathFiles/("PSM"+fileNameOut+".sum.unique.csv")
dfU.to_csv(writeScores)#.with_suffix('.combo.csv'))

# %%
