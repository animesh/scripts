#!pip3 install pandas --user
#!pip3 install pathlib --user
import sys
from pathlib import Path
if len(sys.argv)!=2:    sys.exit("REQUIRED: pandas, pathlib; tested with Python 3.8.5\n","USAGE: python dePepFP.py <path to folder containing global.profile.tsv file(s) like \"Z:/FP/\" >")
pathFiles = Path(sys.argv[1])
#pathFiles = Path("Z:/FP/")
fileName='global.profile.tsv'
trainList=list(pathFiles.rglob(fileName))

import pandas as pd
df=pd.DataFrame()
for f in trainList:
    peptideHits=pd.read_csv(f,low_memory=False,sep='\t')
    print(f)
    peptideHits['Name']=f
    df=pd.concat([df,peptideHits],sort=False)
print(df.head())
print(df.columns)

#print(df.columns.get_loc("DP Proteins"))
dfDP=df.loc[:, df.columns.str.startswith('Potential Modification')|df.columns.str.endswith('unmodified)')]
dfDP=dfDP[dfDP['Potential Modification 1'].notnull()]
#dfDP=dfDP.rename(columns = lambda x : str(x)[3:])
writeDPcsv=pathFiles/(fileName+"FP.csv")
print("writing output to ... ")
dfDP.to_csv(writeDPcsv)
print(writeDPcsv)
dfDPcnt1=dfDP['Potential Modification 1'].value_counts()
print(dfDPcnt1)
dfDPcnt2=dfDP['Potential Modification 2'].value_counts()
print(dfDPcnt2)
writeDPpng1=pathFiles/(fileName+"DP1.png")
if(dfDPcnt1.empty==False): dfDPcnt1[dfDPcnt1>0].plot(kind='pie').figure.savefig(writeDPpng1.absolute(),dpi=100,bbox_inches = "tight")
print(writeDPpng1)
writeDPpng2=pathFiles/(fileName+"DP2.png")
if(dfDPcnt2.empty==False): dfDPcnt2[dfDPcnt2>0].plot(kind='pie').figure.savefig(writeDPpng2.absolute(),dpi=100,bbox_inches = "tight")
print(writeDPpng2)
#specific mod(s)
modName="Formylation"
dfDPmod=dfDP[dfDP['Potential Modification 1']==modName]
print(modName,dfDPmod.groupby('Potential Modification 2').sum())#['Potential Modification 2'].sum())
#dfDPmod.groupby('Base Raw File').count().sum()
#dfDPmod=dfDP[dfDP['Modification'].str.contains('ly')==True]
writeDPcsv=pathFiles/(fileName+modName+"DP.csv")
dfDPmod.to_csv(writeDPcsv)
print(writeDPcsv)
modsummary=pathFiles/'global.modsummary.tsv'
if(modsummary.exists()):
    modHits=pd.read_csv(modsummary,low_memory=False,sep='\t')
modsummaryO=pathFiles/"global.modsummary.tsvDP.png"
modHits.plot(kind='bar', stacked=True).figure.savefig(modsummaryO.absolute(),dpi=600)#,bbox_inches = "tight")
#modHits.plot(kind='bar', stacked=True).figure.savefig(modsummaryO.absolute(),dpi=600)
print(modsummaryO)
