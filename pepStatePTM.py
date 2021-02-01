from pathlib import Path
pathFiles = Path('L:/promec/Animesh/Kathleen')
fileName='allPeptides.txt'
trainList=list(pathFiles.rglob(fileName))

import pandas as pd
df=pd.read_table(trainList[0], low_memory=False)
df.columns.get_loc("DP Proteins")
dfDP=df.loc[:, df.columns.str.startswith('DP')]
dfDP=dfDP[dfDP['DP Proteins'].notnull()]
dfDP=dfDP.rename(columns = lambda x : str(x)[3:])
dfDP['Mass Difference'].hist()
dfDPcnt=dfDP['Modification'].value_counts()
dfDPcnt[(dfDPcnt>200)&(dfDPcnt<8000000)].plot(kind='pie')

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

from numpy import exp, array, random, dot
training_set_inputs = array([[0, 0, 1], [1, 1, 1], [1, 0, 1], [0, 1, 1]])
training_set_outputs = array([[0, 1, 1, 0]]).T
random.seed(1)
synaptic_weights = 2 * random.random((3, 1)) - 1
for iteration in range(10000):
    output = 1 / (1 + exp(-(dot(training_set_inputs, synaptic_weights))))
    synaptic_weights += dot(training_set_inputs.T, (training_set_outputs - output) * output * (1 - output))
print(1 / (1 + exp(-(dot(array([1, 0, 0]), synaptic_weights)))))
#https://gist.githubusercontent.com/miloharper/62fe5dcc581131c96276/raw/68145c6ac966617a8d1ef46f2d19df8909808620/short_version.py
