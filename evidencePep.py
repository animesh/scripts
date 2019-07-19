import sys
from pathlib import Path
#if len(sys.argv)!=2:    sys.exit("USAGE: python dePep.py <path to folder containing allPeptidex.txt file(s) like \"L:/combined/txt\" >")
#pathFiles = Path(sys.argv[1])
pathFiles = Path("L:/promec/Elite/LARS/2018/november/Rolf final/txt")
fileName='evidence.txt'
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
colStrName="Raw file"
print(df.columns.get_loc(colStrName))
dfDP=df.loc[:, df.columns.str.startswith(colStrName)]
dfDP=dfDP[dfDP[colStrName].notnull()]
#dfDP=dfDP.rename(columns = lambda x : str(x)[3:])
writeEviPlot=pathFiles/(fileName+colStrName+".png")
dfDPcnt=dfDP[colStrName].value_counts()
print(dfDPcnt)

print("writing output to ... ")
dfDPcnt[dfDPcnt>10].plot(kind='barh').figure.savefig(writeEviPlot,dpi=100,bbox_inches = "tight")
print(writeEviPlot)

writeEviData=pathFiles/(fileName+colStrName+".csv")
dfDPcnt.to_csv(writeEviData)
print(writeEviData)
