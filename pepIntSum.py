#python pepIntSum.py  dynamicrangebenchmark/peptides.txt
# %% setup
#install dependencies: pip install matplotlib pandas 
import sys,matplotlib.pyplot as plt,numpy as np,pandas as pd
# %% data
pathFiles = sys.argv[1]
#eg. data: https://ftp.pride.ebi.ac.uk/pride/data/archive/2014/09/PXD000279/dynamicrangebenchmark.zip
#pathFiles = "dynamicrangebenchmark/peptides.txt"
dfS=pd.read_csv(pathFiles,low_memory=False,sep='\t')
print(dfS.columns)
print(dfS.head())
#plt.close('all')
#import matplotlib
#matplotlib.use('Agg')
#plt.plot(df['Intensity'])
#plt.show()
#dfS=df[df['PEP']<0.01]
#print(dfS['Mod. peptide IDs'].value_counts())
#plt.plot(dfS['Intensity'])
#dfS.rename({'Leading razor protein':'ID'},inplace=True,axis='columns')
# %% separate IDs by semicolon
dfS.rename({'Leading razor protein':'ID'},inplace=True,axis='columns')
print(dfS[dfS==0].count())
#dfS.replace(0, np.nan, inplace=True)
#print(dfS[dfS==0].count())
dfS['IDs']=dfS.ID.str.split(';')
dfSE=dfS.explode('IDs')
dfSE.index=dfSE["Sequence"]
# %% groupy IDs using sum of intensities
dfSEG=dfSE.groupby(dfSE['IDs']).aggregate('sum')
dfSEG.to_csv(pathFiles+'.combinedIntensity.csv')#,sep="\")#,rownames=FALSE)
# %% check for a protein
dfA5A614=dfSE[dfSE['IDs'].isin(["A5A614"])]
dfA5A614.index=dfA5A614.Sequence
dfA5A614=dfA5A614.filter(regex='Intensity ',axis=1)
dfA5A614.columns=dfA5A614.columns.str.removeprefix('Intensity ')
#dfA5A614.columns=dfA5A614.columns.str.split('_').str[0]
#dfA5PFJ8=dfSE[dfSE['IDs'].isin(["A5PFJ8"])]
#dfSE[dfSE['IDs'].isin(["A5PFJ8"])]
dfA5A614.T.plot.line().figure.savefig(pathFiles+'peptidesSel.sumIntensity.png',dpi=100,bbox_inches = "tight")
dfA5A614.to_csv(pathFiles+'peptidesSel.sumIntensity.csv')#,sep="\")#,rownames=FALSE)
# %% extract intensity
dfSE.replace(0,np.nan,inplace=True)
dfSEint=dfSE.filter(regex='Intensity ',axis=1)
dfSEint.columns=dfSEint.columns.str.removeprefix('Intensity ')
print(dfSEint.describe())
# %% tranform with log2
dfSEintLog2=np.log2(dfSEint)
print(dfSEintLog2.describe())
# %% pairwise substract log2 sample values per peptide
dfSEintRepS=dfSEintLog2[np.repeat(dfSEintLog2.columns.values,dfSEintLog2.shape[1])]
#dfSEintRepS.reset_index(inplace=True)
dfSEintRepS.columns
dfSEintRepB=pd.concat([dfSEintLog2]*(dfSEintLog2.shape[1]),axis=1)
#dfSEintRepB.reset_index(inplace=True)
dfSEintRepB.columns
dfSEintRepS.columns=dfSEintRepS.columns+';'+dfSEintRepB.columns
dfSEintRepB.columns=dfSEintRepS.columns
dfSEintRepSB=dfSEintRepS-dfSEintRepB
dfSEintRepSB.replace(0,np.nan,inplace=True)
dfSEintRepSB.dropna(axis = 1, how = 'all',inplace=True)
print(dfSEintRepSB.describe())
dfSEintRepSB["Protein"]=dfSE["IDs"]
dfSEintRepSB=dfSEintRepSB.sort_values('Protein')
dfSEintRepSB.to_csv(pathFiles+'sampleBySampleLog2IntensityDiff.csv')
print(dfSEintRepSB.columns)
print("Intensity Difference Summary\n",dfSEintRepSB.describe())
# %% group peptides to protein using median of log2differences 
dfSEintRepSBPG=dfSEintRepSB.groupby(dfSEintRepSB['Protein']).aggregate('median')
#print(dfSEintRepSBPG.describe())
#dfSEintRepSBPG.hist()
#dfSEintRepSBPG.replace(np.nan,0,inplace=True)
dfSEintRepSBPG.to_csv(pathFiles+'proteins.merged.sampleBySampleIntensityMedian.csv')
#print(dfSEintRepSBPG.columns)
print("Median Intensity Difference Summary\n",dfSEintRepSBPG.describe())
