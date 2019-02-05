import sys
if len(sys.argv)!=2:
    sys.exit("USAGE: python dePep.py <path to folder containing allPeptidex.txt file(s)>")

from pathlib import Path
pathFiles = Path(sys.argv[1])
#pathFiles = Path("L:/promec/HF/Lars/2019/Camilla MIB/combined/txt")
fileName='allPeptides.txt'
trainList=list(pathFiles.rglob(fileName))

import pandas as pd
df=pd.read_table(trainList[0], low_memory=False)
print(df.columns)
#df['Mass deficit'].hist()
#df['Mass precision [ppm]'].hist()

print(df.columns.get_loc("DP Proteins"))
#awk -F '\t' '{print $47}' promec/promec/USERS/MarianneNymark/181009/Charlotte/HF/combined/txt/allPeptides.txt | sort | uniq -c
dfDP=df.loc[:, df.columns.str.startswith('DP')]
dfDP=dfDP[dfDP['DP Proteins'].notnull()]
dfDP=dfDP.rename(columns = lambda x : str(x)[3:])
#dfDP['Mass Difference'].hist()
#dfDP['Base Raw File'].hist()
print(dfDP['Base Raw File'].value_counts())
writeDPpng=pathFiles/(fileName+"DP.png")
#dfDP['Modification'].value_counts().plot(kind='bar')
dfDPcnt=dfDP['Modification'].value_counts()
print(dfDPcnt)

print("writing output to ... ")
dfDPcnt[dfDPcnt>10].plot(kind='pie').figure.savefig(writeDPpng,dpi=100,bbox_inches = "tight")
print(writeDPpng)

writeDPcsv=pathFiles/(fileName+"DP.csv")
dfDP.to_csv(writeDPcsv)
print(writeDPcsv)
