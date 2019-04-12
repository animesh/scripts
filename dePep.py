import sys
from pathlib import Path
if len(sys.argv)!=2:    sys.exit("USAGE: python dePep.py <path to folder containing allPeptidex.txt file(s) like \"L:/combined/txt\" >")
pathFiles = Path(sys.argv[1])
#pathFiles = Path("L:/promec/HF/Lars/2019/april/MENGTAN/combined")
fileName='allPeptides.txt'
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
print(df.columns.get_loc("DP Proteins"))
dfDP=df.loc[:, df.columns.str.startswith('DP')]
dfDP=dfDP[dfDP['DP Proteins'].notnull()]
dfDP=dfDP.rename(columns = lambda x : str(x)[3:])
writeDPpng=pathFiles/(fileName+"DP.png")
dfDPcnt=dfDP['Modification'].value_counts()
print(dfDPcnt)

print("writing output to ... ")
dfDPcnt[dfDPcnt>10].plot(kind='pie').figure.savefig(writeDPpng,dpi=100,bbox_inches = "tight")
print(writeDPpng)

writeDPcsv=pathFiles/(fileName+"DP.csv")
dfDP.to_csv(writeDPcsv)
print(writeDPcsv)
