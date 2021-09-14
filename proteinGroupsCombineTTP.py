#!/usr/bin/env python
#!pip3 install pathlib --user
import sys
from pathlib import Path
if len(sys.argv)!=2: sys.exit("\n\nREQUIRED: pandas, pathlib, tcl==8.6.9; tested with Python 3.7.9 \n\nUSAGE: python proteinGroupsCombineTTP.py <path to folder containing protein_label_quant.tsv file(s) like \"L:\promec\Animesh\Samah\mqpar.xml.1623227664.results\" >\n\nExample\n\npython proteinGroupsCombineTTP.py L:\promec\Animesh\Samah\mqpar.xml.1623227664.results")
#python proteinGroupsCombineTTP.py C:/Users/animeshs/Desktop/FP2
pathFiles = Path(sys.argv[1])
#pathFiles=Path("C:/Users/animeshs/Desktop/FP2")
fileName='protein_label_quant.tsv'
trainList=list(pathFiles.rglob(fileName))
#!pip3 install pandas --user
import pandas as pd
#df = pd.concat(map(pd.read_table, trainList))
#df.to_csv(pathFiles.with_suffix('.combinedT.txt'),sep="\t")#,rownames=FALSE)
#f=Path("C:/Users/animeshs/Desktop/FP2/210902_sudhl5_tot_3_Slot1-30_1_181/protein_label_quant.tsv")
df=pd.DataFrame()
for f in trainList:
    if Path(f).stat().st_size > 0:
        proteinHits=pd.read_csv(f,low_memory=False,sep='\t')
        print(f.parts[-2])
        proteinHits.rename({'Protein':'ID'},inplace=True,axis='columns')
        proteinHits.rename({'Median Log2 Ratios HL':'MedianLog2SILAC'},inplace=True,axis='columns')
        proteinHits=proteinHits.ID.str.split(';', expand=True).set_index(proteinHits.MedianLog2SILAC).stack().reset_index(level=0, name='ID')
        proteinHits['Name']=f.parts[-2]
        df=pd.concat([df,proteinHits],sort=False)
print(df.columns)
print(df.head())
df=df.pivot(index='ID', columns='Name', values='MedianLog2SILAC')
#df.to_csv(pathFiles.with_suffix('.combined.txt'),sep="\")#,rownames=FALSE)
plotcsv=pathFiles/(fileName+".MedianLog2SILAC.histogram.svg")
df.plot(kind='hist',alpha=0.5,bins=100).figure.savefig(plotcsv,dpi=100,bbox_inches = "tight")
print(df.head())
print(df.columns)
#writeDPpng=pathFiles/(fileName+"Score.png")
#df.plot(kind='hist').figure.savefig(writeDPpng.absolute(),dpi=100,bbox_inches = "tight")
#print("Histogram of Score in",writeDPpng)
df['Median']=df.median(axis=1)
df=df.sort_values('Median',ascending=False)
writeScores=pathFiles/(fileName+".MedianLog2SILAC.ratio.csv")
df.to_csv(writeScores)#.with_suffix('.combo.csv'))
print("MedianLog2SILAC in\n",writeScores,"\n",plotcsv)
#dfID=df.assign(ID=df.ID.str.split(';')).explode('ID')
