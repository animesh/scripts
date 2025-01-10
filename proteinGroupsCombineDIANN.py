#runDIANN.bat
#python proteinGroupsCombineDIANN.py L:\promec\TIMSTOF\LARS\2025\250107_Hela_Coli\DIA "*d.UP000005640_9606_UP000000625_83333_unique_gene_MC1_L35_C57_vMod3_MZ117.diann.pr_matrix.tsv"
# %% setup
import sys
from pathlib import Path
import pandas as pd
# %% data
pathFiles = Path(sys.argv[1])
#pathFiles=Path("L:\\promec\\TIMSTOF\\LARS\\2025\\250107_Hela_Coli\\DIA")
fileName=sys.argv[2]
#fileName='*UP000005640_9606_UP000000625_83333_unique_gene_MC1_L35_C57_vMod3_MZ117.diann.pr_matrix.tsv'
print(fileName)
fileNameOut=fileName.replace("*","")
print(fileNameOut)
trainList=list(pathFiles.rglob(fileName))
print(trainList)
print(len(trainList),"files found in",pathFiles)
# %% combine
df=pd.DataFrame()
#f=trainList[0]
for f in trainList:
    if Path(f).stat().st_size > 0:
        proteinHits=pd.read_csv(f,sep='\t',low_memory=False)
        fName=f.name.split('.')[0]
        proteinHits.rename({'Protein.Ids':'ID'},inplace=True,axis='columns')
        proteinHits.rename({proteinHits.columns[-1]:'intensity'},inplace=True,axis='columns')
        proteinHits=proteinHits[~proteinHits['ID'].str.contains('cRAP')]
        print(fName,f,proteinHits.columns)
        proteinHits=proteinHits.ID.str.split(';', expand=True).set_index(proteinHits.intensity).stack().reset_index(level=0, name='ID')
        proteinHits=proteinHits.groupby('ID').sum()
        proteinHits['Name']=fName
        df=pd.concat([df,proteinHits],sort=False)
print(df.head())
print(df.columns)
# %% pivot
df=df.pivot(columns='Name', values='intensity')
df['sum']=df.sum(axis=1)
df=df.sort_values("sum", ascending=False)  
# %% plot
print(df.head())
print(df.columns)
#writeDPpng=pathFiles/(fileName+"Score.png")
#df.plot(kind='hist').figure.savefig(writeDPpng.absolute(),dpi=100,bbox_inches = "tight")
#print("Histogram of Score in",writeDPpng)
# %% write
writeScores=pathFiles/("intensity"+fileNameOut+".sum.csv")
df.to_csv(writeScores)#.with_suffix('.combo.csv'))
dfU=df.drop_duplicates()
writeScores=pathFiles/("intensity"+fileNameOut+".sum.unique.txt")
dfU.to_csv(writeScores,sep='\t')
dfU.drop(columns='sum',inplace=True)
import numpy as np
dfU=np.log2(dfU)
plotcsv=pathFiles/("intensity.log2."+fileNameOut+".histogram.svg")
dfU.plot(kind='hist',alpha=0.5,bins=100).figure.savefig(plotcsv,dpi=100,bbox_inches = "tight")
#%%scatter
import seaborn as sns
ppS=sns.PairGrid(dfU)
coefV=dfU.corr()
ppS.fig.suptitle(coefV)
ppS.map_diag(sns.histplot)
ppS.map_lower(sns.kdeplot)
ppS.map_upper(sns.regplot)
plotcsv=pathFiles/("intensity.log2."+fileNameOut+".scatter.svg")
ppS.savefig(plotcsv, dpi=100, bbox_inches="tight")
#dfU=dfU.reindex(sorted(dfU.columns), axis=1)
plotcsv=pathFiles/("intensity.log2."+fileNameOut+".line.svg")
dfU.T.plot(kind='line',alpha=0.6,legend=False,rot=90,fontsize=10).figure.savefig(plotcsv,dpi=100,bbox_inches = "tight")
print("Combined intensities in\n",writeScores,"\n",plotcsv)
#dfID=df.assign(ID=df.ID.str.split(';')).explode('ID')
