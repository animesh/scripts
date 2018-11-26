from pathlib import Path
pathFiles = Path('L:/promec/Animesh/Tobias/HeLaIpAndrea')
fileName='allPeptides.txt'
trainList=list(pathFiles.rglob(fileName))

import pandas as pd
df=pd.read_table(trainList[3])
df_indi = (pd.read_table(f, low_memory=False) for f in trainList)
concatenated_df   = pd.concat(df_indi, ignore_index=True)

concatenated_df.columns.values
P13051=concatenated_df[concatenated_df['DP Proteins'].str.contains("P13051")==True]

P13051['DP Mass Difference'].hist()
P13051['DP Modification'].plot.pie()
P13051['DP Modification'].value_counts().plot(kind='bar').figure.savefig('foo.png',dpi=100,bbox_inches = "tight")

P13051DP=P13051.loc[:, P13051.columns.str.startswith('DP')]
P13051DP.rename(columns = lambda x : str(x)[3:])
P13051DP.to_csv('P13051DP.csv')
