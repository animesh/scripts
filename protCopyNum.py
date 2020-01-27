#https://www.mcponline.org/content/13/12/3497.long#sec-1
from pathlib import Path
pathFiles = Path("L:/promec/Qexactive/LARS/2019/oktober/Kristine Sonja/txt")
fileName='proteinGroups.txt'
trainList=list(pathFiles.rglob(fileName))

import pandas as pd
df=pd.read_csv(trainList[0],low_memory=False,sep='\t')
print(df.head())
print(df.columns)
sample='L'

dfHist=df[df['Fasta headers'].str.contains("Histone H",regex=False)|df['Fasta headers'].str.contains("Core histone",regex=False)==True]
dfHistIntensity=dfHist.loc[:,dfHist.columns.str.startswith('Intensity')&dfHist.columns.str.contains(sample)]

dfIntensity=df.loc[:,df.columns.str.startswith('Intensity')&df.columns.str.contains(sample)]
#dfIntensity=dfIntensity.rename(columns = lambda x : str(x)[21:])

dfHistProp=dfHistIntensity.sum()/dfIntensity.sum()
#df_filtered_log2=(dfIntensity.filter(regex=('|'.join('A')))+1).apply(np.log2)
dfHistProp.hist()

#https://cshperspectives.cshlp.org/content/7/7/a019091.full
dfProtAmt=6.5/dfHistProp
dfProtAmt.hist()
print(dfProtAmt)
