from pathlib import Path
pathFiles = Path('L:/promec/Elite/KWS/Raw/140801 RBP B3/')
fileName='allPeptides.txt'
pepCnt=2
proteinOfInterest='P42704'

trainList=list(pathFiles.rglob(fileName))

import pandas as pd
df=pd.read_table(trainList[0])
df_indi = (pd.read_table(f, low_memory=False) for f in trainList)
concatenated_df   = pd.concat(df_indi, ignore_index=True)

concatenated_df.columns.values
dPc=concatenated_df.loc[:, concatenated_df.columns.str.startswith('DP')]
dPc=dPc[dPc['DP Proteins'].notna()].rename(columns = lambda x : str(x)[3:])

dPc=concatenated_df['DP Modification'].value_counts()
dPc[dPc>=pepCnt].plot(kind='barh').figure.savefig(fileName+str(pepCnt)+'DP.png',dpi=300,bbox_inches = "tight")
dPc.to_csv(fileName+str(pepCnt)+'DP.csv')

proteinOfInterestDP=concatenated_df[concatenated_df['DP Proteins'].str.contains(proteinOfInterest)==True]

#proteinOfInterestDP['DP Mass Difference'].hist(bins=dPc.shape[0]).figure.savefig(proteinOfInterest+'massdiff.png',dpi=300,bbox_inches = "tight")

proteinOfInterestDP['DP Modification']
proteinOfInterestDP['DP Modification'].value_counts().plot(kind='barh').figure.savefig(proteinOfInterest+'DP.png',dpi=300,bbox_inches = "tight")

proteinOfInterestDP=proteinOfInterestDP.loc[:, proteinOfInterestDP.columns.str.startswith('DP')]
proteinOfInterestDP.rename(columns = lambda x : str(x)[3:])
proteinOfInterestDP.to_csv(proteinOfInterest+'DP.csv')
