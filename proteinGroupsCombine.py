#!/usr/bin/env python
#python proteinGroupsCombine.py C:\Users\animeshs\Desktop\mqparTTPdia.xml.1638368050.results\
import sys
from pathlib import Path
if len(sys.argv)!=2: sys.exit("\n\nREQUIRED: pandas, pathlib, tcl==8.6.9; tested with Python 3.7.9 \n\nUSAGE: python proteinGroupsCombine.py <path to folder containing proteinGroups.txt file(s) like \"L:\promec\Animesh\Samah\mqpar.xml.1623227664.results\" >\n\nExample\n\npython proteinGroupsCombine.py L:\promec\Animesh\Samah\mqpar.xml.1623227664.results")
pathFiles = Path(sys.argv[1])
#pathFiles=Path("C:/Users/animeshs/Desktop/mqparTTPdia.xml.1638368050.results")
fileName='proteinGroups.txt'
trainList=list(pathFiles.rglob(fileName))
#!pip3 install pandas --user
import pandas as pd
#df = pd.concat(map(pd.read_table, trainList))
#df.to_csv(pathFiles.with_suffix('.combinedT.txt'),sep="\t")#,rownames=FALSE)
#f=trainList[0]
dfI=pd.DataFrame()
dfC=pd.DataFrame()
dfB=pd.DataFrame()
for f in trainList:
    if Path(f).stat().st_size > 0:
        proteinHits=pd.read_csv(f,low_memory=False,sep='\t')
        print(f.parts[-4])
        proteinHits.rename({'Protein IDs':'ID'},inplace=True,axis='columns')
        proteinHitsC=proteinHits.ID.str.split(';', expand=True).set_index(proteinHits.Score).stack().reset_index(level=0, name='ID')
        proteinHitsI=proteinHits.ID.str.split(';', expand=True).set_index(proteinHits.Intensity).stack().reset_index(level=0, name='ID')
        proteinHitsB=proteinHits.ID.str.split(';', expand=True).set_index(proteinHits.iBAQ).stack().reset_index(level=0, name='ID')
        proteinHitsI['Name']=f.parts[-4]+f.parts[-5]
        proteinHitsC['Name']=f.parts[-4]+f.parts[-5]
        proteinHitsB['Name']=f.parts[-4]+f.parts[-5]
        dfI=pd.concat([dfI,proteinHitsI],sort=False)
        dfC=pd.concat([dfC,proteinHitsC],sort=False)
        dfB=pd.concat([dfB,proteinHitsB],sort=False)
print(dfI.columns)
print(dfC.columns)
print(dfB.columns)
dfI=dfI.pivot(index='ID', columns='Name', values='Intensity')
dfC=dfC.pivot(index='ID', columns='Name', values='Score')
dfB=dfB.pivot(index='ID', columns='Name', values='iBAQ')
#df.to_csv(pathFiles.with_suffix('.combined.txt'),sep="\")#,rownames=FALSE)
#writeDPpng=pathFiles/(fileName+"Score.png")
#df.plot(kind='hist').figure.savefig(writeDPpng.absolute(),dpi=100,bbox_inches = "tight")
#print("Histogram of Score in",writeDPpng)
dfI['SumI']=dfI.sum(axis=1)
dfB['SumB']=dfB.sum(axis=1)
dfC['SumC']=dfC.sum(axis=1)
dfI=dfI.sort_values('SumI',ascending=False)
dfB=dfB.sort_values('SumB',ascending=False)
dfC=dfC.sort_values('SumC',ascending=False)
dfI.to_csv(pathFiles/(fileName+"Combo.intensity.csv"))#.with_suffix('.combo.csv'))
dfB.to_csv(pathFiles/(fileName+"Combo.ibaq.csv"))#.with_suffix('.combo.csv'))
dfC.to_csv(pathFiles/(fileName+"Combo.score.csv"))#.with_suffix('.combo.csv'))
histScores=pathFiles/(fileName+"Hist.svg")
dfC.plot(kind='hist',alpha=0.5,bins=100).figure.savefig(histScores,dpi=100,bbox_inches = "tight")
print("Histogram of Scores in",histScores)
#dfID=df.assign(ID=df.ID.str.split(';')).explode('ID')