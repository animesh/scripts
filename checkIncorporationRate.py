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

#import re
#columnName=re.compile("^Ratio H/L*[0-9]$")
columnName='^(Ratio H/L)(.*)*([0-9])$'
trainList=list(dirName.rglob(fileName))

import pandas as pd
df=pd.DataFrame()
for f in trainList:
    proteinGroups=pd.read_csv(f,low_memory=False,sep='\t')
    print(f)
    proteinGroups['Name']=f
    df=pd.concat([df,proteinGroups],sort=False)
print(df.head())
print(df.columns)
#df.loc[:,df.columns.str.match('^Ratio H/L*')].head()#+'*'+'[0-9]$')
#dfPG=df.filter(regex=columnName,axis=1).filter(regex='norm').dropna(axis=1, how="all")
dfPG=df.filter(regex=columnName,axis=1)
#dfPG.head()
dfPG=dfPG.rename(columns = lambda x : str(x)[10:])
writePGpng=dirName/(fileName+"PG.png")
dfPGcnt=dfPG.count()
print(dfPGcnt)
print("writing output to ... ")
dfPGcnt[dfPGcnt<max(dfPGcnt)].plot(kind='bar').figure.savefig(writePGpng,bbox_inches = "tight")
print(writePGpng)
#dfPG=dfPG.rename(columns = lambda x : str(x)[21:])
#dfPG.agg(lambda x: x.value_counts(dropna=True).index[0],axis='rows')
#dfPG.agg(max,axis='rows')
#dfPG.apply(lambda x: x, axis=1)
dfPG=1-(1/dfPG.mean(axis = 0, skipna = True))
writePGcsv=dirName/(fileName+".IR.csv")
dfPG.to_csv(writePGcsv)
print(writePGcsv)
#dfPG.hist()
