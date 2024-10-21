#python msmsCount.py L:\promec\TIMSTOF\LARS\2024\241002_zrimac
import sys
from pathlib import Path
fileName='msms.txt'
colName="Sequence"
if len(sys.argv)!=2:    sys.exit("USAGE: python dePep.py <path to folder containing \""+fileName+"\" file(s) like \"L:/combined/txt\" with column \""+colName+"\">")
pathFiles = Path(sys.argv[1])
#pathFiles = Path('L:/promec/TIMSTOF/LARS/2024/241002_zrimac/')
trainList=list(pathFiles.rglob(fileName))
import pandas as pd
df=pd.DataFrame()
#f=trainList[0]
for f in trainList:
    print(f)
    peptideHits=pd.read_csv(f,low_memory=False,sep='\t')
    peptideHitsPhoSTY=peptideHits.pivot_table(index='Sequence', columns='Raw file',values='Phospho (STY)',aggfunc='sum')
    peptideHitsScans=peptideHits.pivot_table(index='Sequence', columns='Raw file',values='Scan event number',aggfunc='sum')
    peptideHitsPhoSTYratio=(-1)*peptideHitsPhoSTY/peptideHitsScans
    peptideHitsPhoSTYratioHist = peptideHitsPhoSTYratio.plot.hist()
    peptideHitsPhoSTYratioHist.figure.savefig(f.with_suffix(".phoSTYratio.png"))
    peptideHitsPhoSTYratio.to_csv(f.with_suffix(".phoSTYratio.csv"))
    peptideHits['Name']=peptideHits['Raw file']+str(f)
    df=pd.concat([df,peptideHits],sort=False)
print(df.head())
print(colName,"found in column",df.columns.get_loc(colName))
dfMSMS=df.loc[:, df.columns.str.startswith(colName)]
dfMSMS=dfMSMS[dfMSMS[colName].notnull()]
dfMSMScnt=dfMSMS[colName].value_counts()
import numpy as np
np.log2(dfMSMScnt).hist()
print("writing output to ... ")
writeMSMSpng=pathFiles/(fileName+".count.png")
dfMSMScnt[dfMSMScnt>10].plot(kind='pie').figure.savefig(writeMSMSpng,dpi=100,bbox_inches = "tight")
print(writeMSMSpng)
writeMSMScsv=pathFiles/(fileName+".count.csv")
dfMSMScnt.to_csv(writeMSMScsv)
print(writeMSMScsv)
