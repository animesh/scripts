#!/usr/bin/env python
#!pip3 install pathlib --user
import sys
from pathlib import Path
if len(sys.argv)!=2: sys.exit("\n\nREQUIRED: pandas, pathlib, tcl==8.6.9; tested with Python 3.7.9 \n\nUSAGE: python proteinGroupsCombine.py <path to folder containing proteinGroups.txt file(s) like \"L:\promec\Animesh\Samah\mqpar.xml.1623227664.results\" >\n\nExample\n\npython proteinGroupsCombine.py L:\promec\Animesh\Samah\mqpar.xml.1623227664.results")
pathFiles = Path(sys.argv[1])
#pathFiles=Path("L:\promec\Animesh\Samah\mqpar.xml.1623227664.results")
fileName='proteinGroups.txt'
trainList=list(pathFiles.rglob(fileName))
#!pip3 install pandas --user
import pandas as pd
#df = pd.concat(map(pd.read_table, trainList))
#df.to_csv(pathFiles.with_suffix('.combinedT.txt'),sep="\t")#,rownames=FALSE)
df=pd.DataFrame()
for f in trainList:
    if Path(f).stat().st_size > 0:
        proteinHits=pd.read_csv(f,low_memory=False,sep='\t')
        print(f.parts[-4])
        proteinHits.rename({'Protein IDs':'ID'},inplace=True,axis='columns')
        proteinHits=proteinHits.ID.str.split(';', expand=True).set_index(proteinHits.Score).stack().reset_index(level=0, name='ID')
        proteinHits['Name']=f.parts[-4]
        df=pd.concat([df,proteinHits],sort=False)
print(df.columns)
print(df.head())
df=df.pivot(index='ID', columns='Name', values='Score')
#df.to_csv(pathFiles.with_suffix('.combined.txt'),sep="\")#,rownames=FALSE)
print(df.head())
print(df.columns)
#writeDPpng=pathFiles/(fileName+"Score.png")
#df.plot(kind='hist').figure.savefig(writeDPpng.absolute(),dpi=100,bbox_inches = "tight")
#print("Histogram of Score in",writeDPpng)
df['Sum']=df.sum(axis=1)
df=df.sort_values('Sum',ascending=False)
writeScores=pathFiles/(fileName+"Combo.csv")
df.to_csv(writeScores)#.with_suffix('.combo.csv'))
print("Score in",writeScores)
#dfID=df.assign(ID=df.ID.str.split(';')).explode('ID')
