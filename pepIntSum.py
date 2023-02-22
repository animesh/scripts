#dependencies: pandas and pathlib
#install: pip install pandas pathlib
#data: https://ftp.pride.ebi.ac.uk/pride/data/archive/2014/09/PXD000279/dynamicrangebenchmark.zip
#USAGE: python pepIntSum.py <path to folder containing peptides.txt AND proteinGroups.txt files for the experiment>
#e.g. tested on windows-11: python.exe pepIntSum.py  C:\Users\sharm\Downloads\dynamicrangebenchmark\
import sys
from pathlib import Path
pathFiles = Path(sys.argv[1])
#pathFiles = Path("L:\\promec\\USERS\\Alessandro\\230119_66samples-redo\\combined\\txt\\")
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
dfS=dfS.groupby(dfS['ID']).aggregate('sum')
dfS.to_csv(pathFiles/'peptides.combinedIntensity.csv')#,sep="\")#,rownames=FALSE)
#dfP=dfS.pivot_table(index='ID', columns='Sequence', values='Intensity', aggfunc='sum')
#dfP.to_csv(pathFiles.with_suffix('.combinedIntensity.csv'))#,sep="\")#,rownames=FALSE)
dfProtG=pd.read_csv(pathFiles/"proteinGroups.txt",low_memory=False,sep='\t')
dfM=dfProtG.merge(dfS,left_on='Protein IDs', right_on='ID',how='outer',indicator=True)
dfM.to_csv(pathFiles/'proteins.mergedIntensity.csv')#,sep="\")#,rownames=FALSprint(dfM.columns)
print(dfM[dfM['_merge']=="right_only"])
print(dfM[dfM['_merge']=="left_only"])
#dfC=dfM[dfM['_merge']=="left_only"]
dfC=dfM[dfM['_merge']=="both"].filter(regex='Intensity',axis=1)
print(dfC.columns)
diffInt=dfC['Intensity_y']-dfC['Intensity_x']
print("\nDff Intensity Summary\n",diffInt.describe())
#plt.plot(diffInt,"o")
#plt.savefig(pathFiles.with_suffix('.combinedIntensity.png'),dpi=100,bbox_inches = "tight")
#plt.show()
