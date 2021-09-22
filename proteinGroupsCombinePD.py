if len(sys.argv)!=2: sys.exit("\n\nREQUIRED: pandas, pathlib; tested with Python 3.7.9 \n\nUSAGE: python proteinGroupsCombinePD.py <path to folder containing *Protein.txt file(s) like \"L:\promec\Animesh\Samah\mqpar.xml.1623227664.results\" >\n\nExample\n\npython proteinGroupsCombine.py L:\promec\Animesh\Samah\mqpar.xml.1623227664.results")
import sys
from pathlib import Path
pathFiles = Path(sys.argv[1])
#pathFiles=Path("L:/promec/HF/Lars/2021/SEPTEMBER/SUDHL5/PD")
#pathFiles.exists()
fileName='*_Proteins.txt'
#for p in pathFiles.rglob(fName):    print( p )
trainList=list(pathFiles.rglob(fileName))
print(trainList)
#!pip3 install pandas --user
import pandas as pd
#df = pd.concat(map(pd.read_table, trainList))
#df.to_csv(pathFiles.with_suffix('.combinedT.txt'),sep="\t")#,rownames=FALSE)
#f=trainList[0]
df=pd.DataFrame()
for f in trainList:
    if Path(f).stat().st_size > 0:
        proteinHits=pd.read_csv(f,low_memory=False,sep='\t')
        print(f.parts[-1])
        proteinHits.rename({'FASTA Title Lines':'ID'},inplace=True,axis='columns')
        proteinHits.columns=proteinHits.columns.str.replace(r'\d+', '',regex=True)
        proteinHits.rename({'Abundance Ratio log F Light  F Heavy':'Score'},inplace=True,axis='columns')
        proteinHits=proteinHits.ID.str.split('\n', expand=True).set_index(proteinHits.Score).stack().reset_index(level=0, name='ID')
        proteinHits['Name']=f.parts[-1]+f.parts[-2]
        df=pd.concat([df,proteinHits],sort=False)
print(df.columns)
print(df.head())
df=df.pivot(index='ID', columns='Name', values='Score')
#df.to_csv(pathFiles.with_suffix('.combined.txt'),sep="\")#,rownames=FALSE)
print(df.head())
print(df.columns)
histScores=pathFiles/(fileName.strip('*')+"HistMedian.svg")
df.plot(kind='hist',alpha=0.5,bins=100).figure.savefig(histScores,dpi=100,bbox_inches = "tight")
#df['Median']=df.median(axis=1)
#df=df.sort_values('Median',ascending=False)
df['cat'] = df.astype(str).apply(';'.join, axis=1)
df.reset_index(level=0, inplace=True)
df=df.groupby("cat", as_index=False).agg(lambda x: x.tolist())
writeScores=pathFiles/(fileName.strip('*')+"ComboMedian.csv")
df.to_csv(writeScores)#.with_suffix('.combo.csv'))
print("log2Median in",writeScores,histScores)
#dfID=df.assign(ID=df.ID.str.split(';')).explode('ID')
