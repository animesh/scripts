#python geneGroupsCombineDIANN.py  F:\promec\TIMSTOF\LARS\2025\250902_Alessandro *gg_matrix.tsv
#runDIANN.bat F:\promec\TIMSTOF\LARS\2025\250902_Alessandro 10 --direct-quant
#!pip3 install pandas --user
# %% setup
import sys
from pathlib import Path
import pandas as pd
# %% data
pathFiles = Path(sys.argv[1])
#pathFiles=Path("L:/promec/TIMSTOF/LARS/2025/250428_Kamilla/")
fileName=sys.argv[2]
#fileName='*report.met.acet.report._genes_matrix.tsv'
fileNameOut=fileName.replace("*","")+"_comb"
print(fileNameOut)
trainList=list(pathFiles.rglob(fileName))
trainList=[f for f in trainList if fileName.replace("*","") in str(f)]
print(trainList)
print(len(trainList),"files found in",pathFiles)
# %% combine
df=pd.DataFrame()
#f=trainList[-1]
for f in trainList:
    if Path(f).stat().st_size > 0:
        print(f.parts)
        fName=f.parts[-2]
        print(fName)
        geneHits=pd.read_csv(f,sep='\t',low_memory=False)
        geneHits.rename({'Genes':'ID'},inplace=True,axis='columns')
        geneHits.rename({geneHits.columns[-1]:'intensity'},inplace=True,axis='columns')
        #geneHitsS=geneHits.ID.str.split(';').explode('ID').reset_index(drop=True)
        geneHitsS=geneHits.ID.str.split(';', expand=True).set_index(geneHits.intensity).stack().reset_index().rename(columns={0:'ID'})
        geneHitsS.index=geneHitsS.ID
        geneHitsS=geneHitsS.drop(columns='ID')
        geneHitsS['Name']=fName
        df=pd.concat([df,geneHitsS],sort=False)
print(df.head())
print(df.columns)
# %% pivot
df=df.pivot(columns='Name', values='intensity')
print(df.head())
df['sum']=df.sum(axis=1)
dfU=df.sort_values("sum", ascending=False)  
# %% plot
#writeDPpng=pathFiles/(fileName+"Score.png")
#df.plot(kind='hist').figure.savefig(writeDPpng.absolute(),dpi=100,bbox_inches = "tight")
#print("Histogram of Score in",writeDPpng)
# %% write
print(dfU.head())
print("Total",dfU.notnull().sum())
print("Common",dfU.dropna().notnull().sum())
print("Missing values",dfU.isnull().sum())
writeScores=pathFiles/("intensity"+fileNameOut+".sum.csv")
dfU.to_csv(writeScores)#.with_suffix('.combo.csv'))
print("Writing combined intensities to",writeScores)
