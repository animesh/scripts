from pathlib import Path
pathFiles = Path('L:/promec/Animesh/Kathleen')
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
dfDPcnt=dfDP['Modification'].value_counts()
dfDPcnt[(dfDPcnt>20)&(dfDPcnt<800)].plot(kind='pie')

fileName='Phospho (STY)Sites.txt'
trainList=list(pathFiles.rglob(fileName))
dfPTM=pd.read_table(trainList[0], low_memory=False)
dfPTM.columns.values


dfPTM['Occupancy HT'].hist()

dfPTM['Occupancy HT'].value_counts().plot(kind='bar').figure.savefig('foo.png',dpi=100,bbox_inches = "tight")

dfPTMocc=dfPTM.loc[:, dfPTM.columns.str.startswith('Occupancy')]
dfPTMocc.rename(columns = lambda x : str(x)[3:])
dfPTMocc.to_csv('dfPTMocc.csv')

#https://photos.app.goo.gl/Ja8mn8c4pwnajA7k8
a=(z-y)/(x-z)
p=a/(1+a)

or=(1-(y/z))/((x/z)-1)
st=or/(1+or)

dE=dR*((1/((1-v)**2)+(1/((1-w)**2))**(1/2)
v=rUModPep/rProtein
v=rModPep/rProtein
