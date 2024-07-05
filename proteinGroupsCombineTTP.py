#!pip3 install pandas matplotlib pathlib --user
#python proteinGroupsCombineTTP.py L:\promec\TIMSTOF\LARS\2024\240626_Mira\2de755bb378949183b1b6b89a359e507\processing-run
# %% setup
import sys
from pathlib import Path
import pandas as pd
# %% meta
#pathFiles=Path("L:/promec/TIMSTOF/LARS/2024/240626_Mira/b3093c79d999b9393e121db1af7c0438/processing-run")
#pathFiles=Path("L:/promec/TIMSTOF/LARS/2024/240626_Mira/2de755bb378949183b1b6b89a359e507/processing-run")
pathFiles = Path(sys.argv[1])
summaryFile='metadata.csv'
dfMeta=pd.read_csv(pathFiles.parents[0]/summaryFile)
print(dfMeta.head())
# %% data
fileName='dtaselect.protein.parquet'
trainList=list(pathFiles.rglob(fileName))
print(trainList)
print(len(trainList),"files found in",pathFiles)
#f=trainList[0]
#proteinHits=pd.read_parquet(f)
#print(proteinHits.columns)
#proteinHits.query("protein_accession == 'P60174'")
#pd.read_parquet(f, filters=[("protein_accession", "=", "P60174")]).to_dict() #optim? https://medium.com/munchy-bytes/are-you-using-parquet-with-pandas-in-the-right-way-595c9ee7112 
#df = pd.concat(map(pd.read_table, trainList))
#df.to_csv(pathFiles.with_suffix('.combinedT.txt'),sep="\t")#,rownames=FALSE)
# %% combine
df=pd.DataFrame()
for f in trainList:
    if Path(f).stat().st_size > 0:
        proteinHits=pd.read_parquet(f)
        fName=dfMeta.name[dfMeta.processing_run_uuid==f.parents[0].name]
        print(fName,f)
        proteinHits.rename({'protein_group_name':'ID'},inplace=True,axis='columns')
        proteinHits.rename({'number_psms':'PSMs'},inplace=True,axis='columns')
        proteinHits=proteinHits.ID.str.split(';', expand=True).set_index(proteinHits.PSMs).stack().reset_index(level=0, name='ID')
        proteinHits=proteinHits.groupby('ID').sum()
        proteinHits['Name']=fName.values[0]
        df=pd.concat([df,proteinHits],sort=False)
print(df.columns)
print(df.head())
# %% pivot
df=df.pivot(columns='Name', values='PSMs')
df['PSMs']=df.sum(axis=1)
df=df.sort_values("PSMs", ascending=False)  
# %% plot
plotcsv=pathFiles/("PSMs.histogram.svg")
df.plot(kind='hist',alpha=0.5,bins=100).figure.savefig(plotcsv,dpi=100,bbox_inches = "tight")
print(df.head())
print(df.columns)
#writeDPpng=pathFiles/(fileName+"Score.png")
#df.plot(kind='hist').figure.savefig(writeDPpng.absolute(),dpi=100,bbox_inches = "tight")
#print("Histogram of Score in",writeDPpng)
# %% write
writeScores=pathFiles/("PSMs.sum.csv")
df.to_csv(writeScores)#.with_suffix('.combo.csv'))
print("PSMs in\n",writeScores,"\n",plotcsv)
#dfID=df.assign(ID=df.ID.str.split(';')).explode('ID')



# %%
