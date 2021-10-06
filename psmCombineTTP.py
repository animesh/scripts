#!/usr/bin/env python
#!pip3 install pathlib --user
import sys
from pathlib import Path
if len(sys.argv)!=2: sys.exit("\n\nREQUIRED: pandas, pathlib, tcl==8.6.9; tested with Python 3.7.9 \n\nUSAGE: python psmCombineTTP.py <path to folder containing psm.tsv file(s) like \"L:\promec\Animesh\Samah\mqpar.xml.1623227664.results\" >\n\nExample\n\npython proteinGroupsCombineTTP.py L:\promec\Animesh\Samah\mqpar.xml.1623227664.results")
#python psmCombineTTP.py C:/Users/animeshs/Desktop/Documents/OpenFPttp210101Fractions
pathFiles = Path(sys.argv[1])
#pathFiles=Path("C:/Users/animeshs/Desktop/Documents/OpenFPttp210101Fractions")
fileName='psm.tsv'
trainList=list(pathFiles.rglob(fileName))
#!pip3 install pandas --user
import pandas as pd
#df = pd.concat(map(pd.read_table, trainList))
#df.to_csv(pathFiles.with_suffix('.combinedT.txt'),sep="\t")#,rownames=FALSE)
#f=trainList[0]#Path("C:/Users/animeshs/Desktop/FP2/210902_sudhl5_tot_3_Slot1-30_1_181/peptide_label_quant.tsv")
df=pd.DataFrame()
for f in trainList:
    if Path(f).stat().st_size > 0:
        peptideHits=pd.read_csv(f,low_memory=False,sep='\t')
        print(f.parts[-2])
        #peptideHits.rename({'Protein':'ID'},inplace=True,axis='columns')
        #peptideHits.rename({'Median Log2 Ratios HL':'dMASS'},inplace=True,axis='columns')
        peptideHits['ID']=peptideHits['MSFragger Localization']#+(peptideHits['Charges']).astype(str)
        peptideHits.rename({'Delta Mass':'dMASS'},inplace=True,axis='columns')
        peptideHits=peptideHits.ID.str.split(' ', expand=True).set_index(peptideHits.dMASS).stack().reset_index(level=0, name='ID')
        peptideHits['Name']=f.parts[-2]
        df=pd.concat([df,peptideHits],sort=False)
print(df.columns)
print(df.head())
#df=df.pivot(index='ID', columns='Name', values='dMASS')
df=df.pivot_table(index='ID', columns='Name', values='dMASS', aggfunc='median')
#dfO=df
#df.to_csv(pathFiles.with_suffix('.combined.txt'),sep="\")#,rownames=FALSE)
plotcsv=pathFiles/(fileName+".dMASS.histogram.svg")
df.plot(kind='hist',alpha=0.5,bins=100).figure.savefig(plotcsv,dpi=100,bbox_inches = "tight")
print(df.head())
print(df.columns)
df=df.fillna(0)
df.iloc[:,-1].plot(kind='hist')
#writeDPpng=pathFiles/(fileName+"Score.png")
#df.plot(kind='hist').figure.savefig(writeDPpng.absolute(),dpi=100,bbox_inches = "tight")
#print("Histogram of Score in",writeDPpng)
#selecting for phosphorylated-peptides
#df=df.filter(regex='79', axis="index")
df['Median']=df.median(axis=1)
df=df.sort_values('Median',ascending=False)
writeScores=pathFiles/(fileName+".dMASS.median.csv")
df.to_csv(writeScores)#.with_suffix('.combo.csv'))
print("dMASS in\n",writeScores,"\n",plotcsv)
#select for Fe-2H delta-mass
peptide=df[df['Median'].between(57.91,53.93)]
peptides=''.join(peptide.index)
from collections import Counter
c = Counter(peptides)
cf=pd.DataFrame(c.items())
cf=cf[cf.iloc[:,0].str.contains('[a-z]')]
print(cf,"\nmedian delta-mass between",peptide['Median'].min(),peptide['Median'].max())
#dfID=df.assign(ID=df.ID.str.split(';')).explode('ID')
