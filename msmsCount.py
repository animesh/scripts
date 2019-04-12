import sys
from pathlib import Path
fileName='msms.txt'
colName="Raw file"
if len(sys.argv)!=2:    sys.exit("USAGE: python dePep.py <path to folder containing \""+fileName+"\" file(s) like \"L:/combined/txt\" with column \""+colName+"\">")
pathFiles = Path(sys.argv[1])
#pathFiles = Path('L:/promec/Animesh/HUNT/combined/txt/')
trainList=list(pathFiles.rglob(fileName))

import pandas as pd
df=pd.DataFrame()
for f in trainList:
    peptideHits=pd.read_csv(f,low_memory=False,sep='\t')
    print(f)
    peptideHits['Name']=f
    df=pd.concat([df,peptideHits],sort=False)
print(df.head())

df.columns.get_loc(colName)
dfMSMS=df.loc[:, df.columns.str.startswith(colName)]
dfMSMS=dfMSMS[dfMSMS[colName].notnull()]
dfMSMScnt=dfMSMS[colName].value_counts()

print("writing output to ... ")
writeMSMSpng=pathFiles/(fileName+".count.png")
dfMSMScnt[dfMSMScnt>10].plot(kind='pie').figure.savefig(writeMSMSpng,dpi=100,bbox_inches = "tight")
print(writeMSMSpng)
writeMSMScsv=pathFiles/(fileName+".count.csv")
dfMSMScnt.to_csv(writeMSMScsv)
print(writeMSMScsv)
