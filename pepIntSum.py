#python.exe pepIntSum.py  C:\Users\animeshs\OneDrive\Desktop\dynamicrangebenchmark
#USAGE: python pepIntSum.py <path to folder containing peptides.txt AND proteinGroups.txt files for the experiment>
#dependencies: pandas and pathlib
#install: pip install pandas pathlib
#data: https://ftp.pride.ebi.ac.uk/pride/data/archive/2014/09/PXD000279/dynamicrangebenchmark.zip
import sys
from pathlib import Path
pathFiles = Path(sys.argv[1])
#pathFiles = Path("C:\\Users\\animeshs\\OneDrive\\Desktop\\dynamicrangebenchmark\\")
import pandas as pd
df=pd.read_csv(pathFiles/"peptides.txt",low_memory=False,sep='\t')
print(df.columns)
print(df.head())
#import matplotlib.pyplot as plt
#plt.plot(df['Intensity'])
dfS=df.copy()
#dfS=df[df['PEP']<0.01]
#print(dfS['Mod. peptide IDs'].value_counts())
#plt.plot(dfS['Intensity'])
dfS.rename({'Leading razor protein':'ID'},inplace=True,axis='columns')
#dfS.rename({'Proteins':'ID'},inplace=True,axis='columns')
print(dfS[dfS==0].count())
import numpy as np
dfS.replace(0, np.nan, inplace=True)
print(dfS[dfS==0].count())
dfS['IDs']=dfS.ID.str.split(';')
dfSE=dfS.explode('IDs')
dfSEG=dfSE.groupby(dfSE['IDs']).aggregate('sum')
dfSEG.to_csv(pathFiles/'peptides.combinedIntensity.csv')#,sep="\")#,rownames=FALSE)
#dfP=dfS.pivot_table(index='ID', columns='Sequence', values='Intensity', aggfunc='sum')
#dfP.to_csv(pathFiles.with_suffix('.combinedIntensity.csv'))#,sep="\")#,rownames=FALSE)
dfProtG=pd.read_csv(pathFiles/"proteinGroups.txt",low_memory=False,sep='\t')
dfProtG.rename({'Majority protein IDs':'ID'},inplace=True,axis='columns')
#dfProtG.rename({'Protein IDs':'ID'},inplace=True,axis='columns')
dfProtG['IDs']=dfProtG.ID.str.split(';')
dfProtGE=dfProtG.explode('IDs')
dfM=dfProtGE.merge(dfSEG,left_on='IDs', right_on='IDs',how='outer',indicator=True)
#dfM=dfProtG.merge(dfSEG,left_on='ID', right_on='IDs',how='outer',indicator=True)
dfM.to_csv(pathFiles/'proteins.mergedIntensity.csv')#,sep="\")#,rownames=FALSprint(dfM.columns)
print(dfM[dfM['_merge']=="right_only"])
print(dfM[dfM['_merge']=="left_only"])
print(dfM[dfM['IDs'].str.contains('REV__')])
#dfC=dfM[dfM['_merge']=="left_only"]
dfC=dfM[dfM['_merge']=="both"].filter(regex='Intensity',axis=1)
dfC["ID"]=dfM['IDs']
dfC["IDs"]=dfM['ID']
dfC["diffInt"]=(dfC['Intensity_y']-dfC['Intensity_x'])/dfC['Intensity_x']
print(dfC.columns)
print("\nDff Intensity Summary\n",dfC["diffInt"].describe())
#dfC["diffInt"].hist()
dfC.to_csv(pathFiles/'proteins.merged.selIntensity.csv')#,sep="\")#,rownames=FALSprint(dfM.column#plt.plot(diffInt,"o")
#plt.savefig(pathFiles.with_suffix('.combinedIntensity.png'),dpi=100,bbox_inches = "tight")
#plt.show()
dfSEint=dfSE.copy()
dfSEint.replace(np.nan,0,inplace=True)
dfSEint=dfSEint.filter(regex='Intensity',axis=1)
dfSEintLog2=np.log2(dfSEint+1)
dfSEintRepS=dfSEintLog2[np.repeat(dfSEintLog2.columns.values,dfSEintLog2.shape[1])]
dfSEintRepB=pd.concat([dfSEintLog2]*(dfSEintLog2.shape[1]),axis=1)
dfSEintRepSB=np.subtract(dfSEintRepS,dfSEintRepB)
dfSEintRepSB.columns=dfSEintRepS.columns+';'+dfSEintRepB.columns
dfSEintRepSB["peptide"]=dfSE["Sequence"]
dfSEintRepSB["ID"]=dfSE["IDs"]
dfSEintRepSB.replace(0,np.nan,inplace=True)
dfSEintRepSBPG=dfSEintRepSB.groupby(dfSEintRepSB['ID']).aggregate('median')
#dfSEintRepSBPG.hist()
dfSEintRepSBPG.replace(np.nan,0,inplace=True)
dfSEintRepSBPG.to_csv(pathFiles/'proteins.merged.sampleBySampleIntensityMedian.csv')
print(dfSEintRepSBPG.columns)
print("\Median Intensity Summary\n",dfSEintRepSBPG.describe())
