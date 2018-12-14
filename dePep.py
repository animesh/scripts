from pathlib import Path
pathFiles = Path('L:/promec/Animesh/Tobias/HeLaIpAndrea/')
fileName='allPeptides.txt'
trainList=list(pathFiles.rglob(fileName))

import pandas as pd
df=pd.read_table(trainList[0], low_memory=False)
df.columns.get_loc("DP Proteins")
#awk -F '\t' '{print $47}' promec/promec/USERS/MarianneNymark/181009/Charlotte/HF/combined/txt/allPeptides.txt | sort | uniq -c
dfDP=df.loc[:, df.columns.str.startswith('DP')]
dfDP=dfDP[dfDP['DP Proteins'].notnull()]
dfDP=dfDP.rename(columns = lambda x : str(x)[3:])
dfDP['Mass Difference'].hist()
writeDPpng=pathFiles/(fileName+"DP.png")
dfDP['Modification'].value_counts().plot(kind='bar')
dfDPcnt=dfDP['Modification'].value_counts()
dfDPcnt[dfDPcnt>1].plot(kind='bar').figure.savefig(writeDPpng,dpi=100,bbox_inches = "tight")

writeDPcsv=pathFiles/(fileName+"DP.csv")
dfDP.to_csv(writeDPcsv)
