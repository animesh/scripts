#!/usr/bin/env python
#!pip3 install pathlib --user
import sys
from pathlib import Path
if len(sys.argv)!=2: sys.exit("\n\nREQUIRED: pandas, pathlib, tcl==8.6.9; tested with Python 3.7.9 \n\nUSAGE: python proteinGroupsCombineTTP.py <path to folder containing protein.tsv file(s) like \"L:\promec\Animesh\Samah\mqpar.xml.1623227664.results\" >\n\nExample\n\npython proteinGroupsCombineTTP.py L:\promec\Animesh\Samah\mqpar.xml.1623227664.results")
#python proteinGroupsCombineTTP.py C:/Users/animeshs/Desktop/FP2
pathFiles = Path(sys.argv[1])
#pathFiles=Path("L:/promec/TIMSTOF/LARS/2024/240221_Tom_Kelt")
fileName='*.tsv'
trainList=list(pathFiles.rglob(fileName))
print(trainList)
print(len(trainList),"files found in",pathFiles)
#!pip3 install pandas
import pandas as pd
#df = pd.concat(map(pd.read_table, trainList))
#df.to_csv(pathFiles.with_suffix('.combinedT.txt'),sep="\t")#,rownames=FALSE)
#f=trainList[0]
df=pd.DataFrame()
for f in trainList:
    if Path(f).stat().st_size > 0:
        proteinHits=pd.read_csv(f,low_memory=False,sep='\t')
        fName=f.parts[-1]
        print(fName)
        proteinHits.rename({'Protein Group Name':'ID'},inplace=True,axis='columns')
        proteinHits.rename({'Number PSMs':'uniqPSMs'},inplace=True,axis='columns')
        proteinHits=proteinHits.ID.str.split(';', expand=True).set_index(proteinHits.uniqPSMs).stack().reset_index(level=0, name='ID')
        proteinHits['Name']=fName
        df=pd.concat([df,proteinHits],sort=False)
print(df.columns)
print(df.head())
df=df.pivot(index='ID', columns='Name', values='uniqPSMs')
df['PSMs']=df.sum(axis=1)
df=df.sort_values("PSMs", ascending=False)  
#df.filter(like='Reverse', axis=0)
dfS=df[df.index.str.contains('Reverse')==False]
#!pip3 install matplotlib
plotcsv=pathFiles/("uniqPSMs.histogram.svg")
df.plot(kind='hist',alpha=0.5,bins=100).figure.savefig(plotcsv,dpi=100,bbox_inches = "tight")
print(df.head())
print(df.columns)
#writeDPpng=pathFiles/(fileName+"Score.png")
#df.plot(kind='hist').figure.savefig(writeDPpng.absolute(),dpi=100,bbox_inches = "tight")
#print("Histogram of Score in",writeDPpng)
writeScores=pathFiles/("PSMs.sum.csv")
df.to_csv(writeScores)#.with_suffix('.combo.csv'))
print("uniqPSMsin\n",writeScores,"\n",plotcsv)
#dfID=df.assign(ID=df.ID.str.split(';')).explode('ID')
