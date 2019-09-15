import sys
from pathlib import Path
if len(sys.argv) != 2:
    dirName = Path("L:/promec/Elite/LARS/2019/august/190820 Camilla wolo/combined/txt")
    fileName='proteinGroups.txt'
    print("\n\nUSAGE: python evidencePep.py <path to folder containing", fileName,
          "file(s)>\n\ntaking default directory\"", dirName, "\"looking for\"", fileName, "\"file(s)\n\n")
else:
    dirName = sys.argv[1]
    print("Input: ", dirName, "directory, \nlooking for", fileName, "\n\n")
trainList=list(dirName.rglob(fileName))

columnName='^(Ratio H/L)(.*)*([0-9])$'
columnNameH='^(Intensity H)(.*)*([0-9])$'
columnNameL='^(Intensity L)(.*)*([0-9])$'

import pandas as pd
df=pd.DataFrame()
for f in trainList:
    proteinGroups=pd.read_csv(f,low_memory=False,sep='\t')
    print(f)
    proteinGroups['Name']=f
    df=pd.concat([df,proteinGroups],sort=False)
    dfP
print(df.head())
print(df.columns)
dfPG=df.filter(regex=columnName,axis=1)
dfPG=dfPG.rename(columns = lambda x : str(x)[10:])
writePGpng=dirName/(fileName+"PG.png")
dfPGcnt=dfPG.count()
print(dfPGcnt)
print("writing output to ... ")
dfPGcnt[dfPGcnt<max(dfPGcnt)].plot(kind='bar').figure.savefig(writePGpng,bbox_inches = "tight")
print(writePGpng)
dfPG=1-(1/dfPG.mean(axis = 0, skipna = True))
writePGcsv=dirName/(fileName+".IR.csv")
dfPG.to_csv(writePGcsv,header=False)
print(writePGcsv)
#dfPG.hist()

dfPGH=df.filter(regex=columnNameH,axis=1)
dfPGH=dfPGH.rename(columns = lambda x : str(x)[12:])
dfPGL=df.filter(regex=columnNameL,axis=1)
dfPGL=dfPGL.rename(columns = lambda x : str(x)[12:])
dfPGH2L=dfPGH-dfPGL
writePGtxt=dirName/(fileName+".IRH2L.txt")
dfPGH2L.to_csv(writePGcsv,header=True,sep='\t')
print(writePGtxt)


dfPGH2L=1-(1/dfPGH2L.mean(axis = 0, skipna = True))
writePGcsv=dirName/(fileName+".IRH2L.csv")
dfPGH2L.to_csv(writePGcsv,header=False)
print(writePGcsv)
