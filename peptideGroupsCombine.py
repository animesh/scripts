# python peptideGroupsCombine.py L:/promec/TIMSTOF/LARS/2024/241002_zrimac/mqparTTPdda.xml.1727950782.results
# wget https://www.python.org/ftp/python/3.12.0/python-3.12.0-amd64.exe
# %% data
# rsync -Pirm --include='Phospho (STY)Sites.txt' --include='*/' --exclude='*' ash022@login.saga.sigma2.no:scripts/mqparTTPdda.xml.1727950782.results /mnt/l/promec/TIMSTOF/LARS/2024/241002_zrimac/
# %% setup
#python -m pip install pandas seaborn pathlib supervenn
import pandas as pd
import sys
from pathlib import Path
# %% read
#if len(sys.argv) != 2: sys.exit("\n\nREQUIRED: pandas, seaborn, supervenn, pathlib\nUSAGE: python peptideGroupsCombine.py <path to folder containing peptides.txt file(s)>")
#pathFiles = Path(sys.argv[1])
pathFiles=Path("L:/promec/TIMSTOF/LARS/2024/241002_zrimac/mqparTTPdda.xml.1727950782.results")
fileName = 'Phospho (STY)Sites.txt'
trainList = list(pathFiles.rglob(fileName))
print("Reading data from"+str(pathFiles.absolute)+"values in column"+"files to consider"+str(fileName)+str(trainList)+str(len(trainList)))
#trainList=[fN for fN in trainList if "Maike" in str(fN)]
#df = pd.concat(map(pd.read_table, trainList))
# df.to_csv(pathFiles.with_suffix('.combinedT.txt'),sep="\t")#,rownames=FALSE)
# f=trainList[0]
# %% combine
df = pd.DataFrame()
for f in trainList:
    if Path(f).stat().st_size > 0:
        peptideHits = pd.read_csv(f, low_memory=False, sep='\t')
        print(f.parts)
        peptideHits=peptideHits[peptideHits['Potential contaminant']!="+"]
        peptideHits=peptideHits[peptideHits['Reverse']!="+"]
        peptideHits=peptideHits.assign(IDs=peptideHits['Protein'].str.split(';')).explode('IDs')
        peptideHits['phosty']=peptideHits['Phospho (STY) Probabilities'].str.replace('[^A-Z]+', '', regex=True)
        peptideHits['pepID'] = peptideHits['phosty']+';'+peptideHits['IDs']
        peptideHits['Name']=str(f.parts[-4])[6:13]
        df = pd.concat([df, peptideHits], sort=False)
print(df.columns)
print(df.head())
# %% pivot
dfPGI = df.pivot_table(index='IDs', columns='Name',values='Intensity',aggfunc='sum')
dfPGI.dropna(axis=1, how='all', inplace=True)
dfPGI=dfPGI.drop_duplicates()    
print(dfPGI.notna().all(axis=1).sum())
print(dfPGI.count(axis=0))
dfPGS = df.pivot_table(index='IDs', columns='Name',values='Score',aggfunc='sum')
dfPepGS = df.pivot_table(index='pepID', columns='Name',values='Score',aggfunc='sum')
dfPepGI = df.pivot_table(index='pepID', columns='Name',values='Intensity',aggfunc='sum')
# %% tranform
import numpy as np
dfPGI=np.log2(dfPGI+1)
dfPepGI=np.log2(dfPepGI+1)
# dfO=df
# df.to_csv(pathFiles.with_suffix('.combined.txt'),sep="\")#,rownames=FALSE)
# %% venn
from supervenn import supervenn, make_sets_from_chunk_sizes
import matplotlib.pyplot as plt
plt.figure(figsize=(10, 10))
dfPGIvenn = dfPGI.notna()
dfPGIvenn['size'] = 1#dfPGIvenn.sum(axis=1)
sets, labels = make_sets_from_chunk_sizes(dfPGIvenn)
supervenn(sets, labels)
#plt.show()
plt.savefig(pathFiles/(fileName+"dfPGI.venn.svg"), dpi=100, bbox_inches="tight")
plt.close()
plt.figure(figsize=(10, 10))
dfPepGSvenn = dfPepGS.notna()
dfPepGSvenn['size'] = 1#dfPGIvenn.sum(axis=1)
sets, labels = make_sets_from_chunk_sizes(dfPepGSvenn)
supervenn(sets, labels)
#plt.show()
plt.savefig(pathFiles/(fileName+"dfPepGS.venn.svg"), dpi=100, bbox_inches="tight")
plt.close()
# %% plot
import seaborn as sbn
sbn.pairplot(dfPGI).figure.savefig(pathFiles/(fileName+"dfPGI.scatter.svg"), dpi=100, bbox_inches="tight")
sbn.pairplot(dfPepGI).figure.savefig(pathFiles/(fileName+"dfPepGI.scatter.svg"), dpi=100, bbox_inches="tight")
sbn.pairplot(dfPGS).figure.savefig(pathFiles/(fileName+"dfPGS.scatter.svg"), dpi=100, bbox_inches="tight")
sbn.pairplot(dfPepGS).figure.savefig(pathFiles/(fileName+"dfPepGS.scatter.svg"), dpi=100, bbox_inches="tight")
# %% sum
dfPGI['sum'] = dfPGI.sum(axis=1)
dfPGS['sum'] = dfPGS.sum(axis=1)
dfPepGI['sum'] = dfPepGI.sum(axis=1)
dfPepGS['sum'] = dfPepGS.sum(axis=1)
# %% sort
dfPGI = dfPGI.sort_values('sum', ascending=False)
dfPGS = dfPGS.sort_values('sum', ascending=False)
dfPepGI = dfPepGI.sort_values('sum', ascending=False)
dfPepGS = dfPepGS.sort_values('sum', ascending=False)
# %% write
dfPGI.to_csv(pathFiles/(fileName+"dfPGI.sum.csv"))
dfPGS.to_csv(pathFiles/(fileName+"dfPGS.sum.csv"))
dfPepGI.to_csv(pathFiles/(fileName+"dfPepGI.sum.csv"))
dfPepGS.to_csv(pathFiles/(fileName+"dfPepGS.sum.csv"))
print("Sum of Intensity Score in\n", pathFiles, "\n", fileName)
#df.iloc[:, 0:1].plot(kind='hist')
# writeDPpng=pathFiles/(fileName+"Score.png")
#df.plot(kind='hist').figure.savefig(writeDPpng.absolute(),dpi=100,bbox_inches = "tight")
#print("Histogram of Score in",writeDPpng)
# selecting for phosphorylated-peptides
#df=df.filter(regex='79', axis="index")
