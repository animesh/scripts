from pathlib import Path
pathFiles = Path('L:/promec/Animesh/HUNT/txt106dpMBR/')
fileName=pathFiles/'msms.txt'
import pandas as pd
df=pd.read_table(fileName, low_memory=False)
colName="Raw file"
df.columns.get_loc(colName)
#df['Raw file'].value_counts().plot(kind='barh').figure.savefig('fooMeAd.png',dpi=300,bbox_inches = "tight")
dfDP=df.loc[:, df.columns.str.startswith(colName)]
dfDP=dfDP[dfDP[colName].notnull()]
dfDP[colName].replace('170704_OLUF_','',inplace=True,regex=True)
dfDPcnt=dfDP[colName].value_counts()
dfDPcnt[(dfDPcnt>0)].plot(kind='pie')

fileName=pathFiles/'all_the_labels_HUNT3_aliquot_batch.csv'
dfPTM=pd.read_csv(fileName, low_memory=False)
dfPTM.columns.values
colName="POSITION"
dfPTM[colName].value_counts().plot(kind='bar').figure.savefig(pathFiles/(colName+'.png'),dpi=100,bbox_inches = "tight")

chkFiles="A1,A3,A6,A10,A11,C10,D1,D2,D3,E1,E2,F10,C11,E6,E9,E12,F1,F2,F4,G2,G3,H2,H5,H7"
dfPTM[colName].replace('0','',inplace=True,regex=True)
dfPTM['index']=dfPTM[colName].str[1:]+dfPTM[colName].str[:1]
dfDPcnt=dfDPcnt.to_frame().reset_index()
dfDPcnt[colName]=dfDPcnt['index'].str[-1:]+dfDPcnt['index'].str[0:-1]
dfMerged=dfDPcnt.merge(dfPTM,left_on=colName, right_on=colName,how='inner')
dfMergedOnIndex=dfDPcnt.merge(dfPTM,left_on='index', right_on='index',how='inner')
dfMergedOnIndexM=dfMergedOnIndex[dfMergedOnIndex['Code'].str.contains('M')&dfMergedOnIndex['PrimaryLast']==1]
dfMergedOnIndexM=dfMergedOnIndexM.set_index("index")
dfMergedOnIndexM['Raw file'].plot(kind='bar').figure.savefig(pathFiles/(colName+'Me.png'),dpi=100,bbox_inches = "tight")
dfMergedOnIndexAD=dfMergedOnIndex[dfMergedOnIndex['Code'].str.contains('AD')&dfMergedOnIndex['PrimaryLast']==1]
dfMergedOnIndexAD=dfMergedOnIndexAD.set_index("index")
dfMergedOnIndexAD['Raw file'].plot(kind='bar').figure.savefig(pathFiles/(colName+'Ad.png'),dpi=100,bbox_inches = "tight")

dfMergedOnIndex.to_csv(pathFiles/(colName+'merged.csv'))
