# python peptideGroupsCombine.py L:/promec/Animesh/Maria/peptides/peptides
#wget https://www.python.org/ftp/python/3.11.0/python-3.11.0-amd64.exe
#..\python-3.11.0\python.exe -m pip install pandas seaborn
#..\python-3.11.0\python.exe peptideGroupsCombine.py ..\..\Aida\sORF\mqpar.K8R10.xml.1664621075.results"
# where peptides folder contains all experiments generated like like following:
# tar cvzf pep.tgz mqpar.xml.1642586*/*/combined/txt/peptides.txt
# mkdir peptides
# cd peptides
# tar xvzf ../pep.tgz
#!pip3 install pandas pathlib --user
import pandas as pd
import sys
from pathlib import Path
if len(sys.argv) != 2:
    sys.exit("\n\nREQUIRED: pandas, pathlib; tested with Python 3.9.9 \n\nUSAGE: python peptideGroupsCombine.py <path to folder containing peptides.txt file(s) like \"L:\promec\Animesh\Maria\mqpar.xml.1623227664.results\" >\n\nExample\n\npython proteinGroupsCombineTTP.py L:\promec\Animesh\Maria\mqpar.xml.1623227664.results")
pathFiles = Path(sys.argv[1])
#pathFiles=Path("L:/OneDrive - NTNU/Aida/sORF/mqpar.K8R10.xml.1664621075.results/")
fileName = 'peptides.txt'
trainList = list(pathFiles.rglob(fileName))
#trainList=[fN for fN in trainList if "MGUS" in str(fN)]
#df = pd.concat(map(pd.read_table, trainList))
# df.to_csv(pathFiles.with_suffix('.combinedT.txt'),sep="\t")#,rownames=FALSE)
# f=trainList[0]
df = pd.DataFrame()
for f in trainList:
    if Path(f).stat().st_size > 0:
        peptideHits = pd.read_csv(f, low_memory=False, sep='\t')
        print(f.parts)
        peptideHits.rename({'Ratio H/L normalized':'normH2L'},inplace=True,axis='columns')
        peptideHits.rename({'Proteins':'ID'},inplace=True,axis='columns')
        peptideHits=peptideHits[~peptideHits['ID'].str.contains("_HUMAN",na=False)]
        # +(peptideHits['Charges']).astype(str)
        #peptideHits.rename({'Score': 'Andromeda'},inplace=True, axis='columns')
        peptideHitsR=peptideHits.ID.str.split(';', expand=True).set_index(peptideHits.normH2L).stack().reset_index(level=0, name='ID')
        peptideHitsL=peptideHits.ID.str.split(';', expand=True).set_index(peptideHits.Sequence).stack().reset_index(level=0, name='ID')
        peptideHitsC=pd.merge(peptideHitsL, peptideHitsR, on='ID', how='outer')
        peptideHitsC['pepID'] = peptideHitsC['Sequence']+';'+peptideHitsC['ID']
        peptideHitsCP=peptideHitsC.groupby(peptideHitsC.pepID)[['normH2L']].median()
        #peptideHitsCP=peptideHitsC.pivot_table(index='pepID', columns='Name',values='Andromeda')
        peptideHitsCP['Name'] = f.parts[-4]
        df = pd.concat([df, peptideHitsCP], sort=False)
print(df.columns)
print(df.head())
df = df.pivot_table(index='pepID', columns='Name',values='normH2L')  # , aggfunc='median')
# dfO=df
# df.to_csv(pathFiles.with_suffix('.combined.txt'),sep="\")#,rownames=FALSE)
plotcsv = pathFiles/(fileName+".normH2L.histogram.svg")
df.plot(kind='hist', alpha=0.5, bins=100).figure.savefig(plotcsv, dpi=100, bbox_inches="tight")
df['Count'] = df.count(axis=1)
print(df.Count)
df = df.sort_values('Count', ascending=False)
writeScores = pathFiles/(fileName+".Count.normH2L.csv")
df.to_csv(writeScores)  # .with_suffix('.combo.csv'))
print("Count Score in\n", writeScores, "\n", plotcsv)
#df.iloc[:, 0:1].plot(kind='hist')
# writeDPpng=pathFiles/(fileName+"Score.png")
#df.plot(kind='hist').figure.savefig(writeDPpng.absolute(),dpi=100,bbox_inches = "tight")
#print("Histogram of Score in",writeDPpng)
# selecting for phosphorylated-peptides
#df=df.filter(regex='79', axis="index")
import numpy as np
log2df=-np.log2(df)
print(log2df.head())
print(log2df.columns)
plotcsv = pathFiles/(fileName+".log2normL2H.histogram.svg")
log2df.plot(kind='hist', alpha=0.5, bins=100).figure.savefig(plotcsv, dpi=100, bbox_inches="tight")
writeScores = pathFiles/(fileName+".log2Count.normL2H.csv")
log2df.to_csv(writeScores)  # .with_suffix('.combo.csv'))
print("Count Score in\n", writeScores, "\n", plotcsv)
