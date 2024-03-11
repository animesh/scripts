#python peptideGroupsCombineTTP.py L:\promec\TIMSTOF\LARS\2024\240221_Tom_Kelt\4caaf540a6cc92c6dd28e5f87aa2406f\processing-run
#!pip3 install pandas matplotlib pathlib --user
import sys
from pathlib import Path
if len(sys.argv)!=2: sys.exit("\n\nREQUIRED: pandas, pathlib, tcl==8.6.9; tested with Python 3.7.9 \n\nUSAGE: python proteinGroupsCombineTTP.py <path to folder containing protein.tsv file(s) like \"L:\promec\Animesh\Samah\mqpar.xml.1623227664.results\" >\n\nExample\n\npython proteinGroupsCombineTTP.py L:\\promec\\TIMSTOF\\LARS\\2024\\240202_beads")
pathFiles = Path(sys.argv[1])
#pathFiles=Path("L:/promec/TIMSTOF/LARS/2024/240221_Tom_Kelt/4caaf540a6cc92c6dd28e5f87aa2406f/processing-run")
fileName='dtaselect.peptide.tsv'
proteinGroups='dtaselect.protein.tsv'
summaryFile='summary-results.results.tsv'
trainList=list(pathFiles.rglob(fileName))
print(trainList)
print(len(trainList),"files found in",pathFiles)
#!pip3 install pandas
import pandas as pd
#df = pd.concat(map(pd.read_table, trainList))
#df.to_csv(pathFiles.with_suffix('.combinedT.txt'),sep="\t")#,rownames=FALSE)
#f=trainList[0]
df=pd.DataFrame()
for f in trainList:
    if Path(f).stat().st_size > 0:
        fName=pd.read_csv(f.parents[0]/summaryFile,sep='\t')
        print(fName['sample_name'])
        proteinHits=pd.read_csv(f.parents[0]/proteinGroups,sep='\t')
        proteinHits.rename({'protein_group_name':'ID'},inplace=True,axis='columns')
        proteinHits.rename({'protein_group_id':'protein_group_parent_id'},inplace=True,axis='columns')
        proteinHits=proteinHits.ID.str.split(';', expand=True).set_index(proteinHits.protein_group_parent_id).stack().reset_index(level=0, name='protein_group_name')
        proteinHits=proteinHits.groupby('protein_group_parent_id').sum()
        pepHits=pd.read_csv(f,low_memory=False,sep='\t')
        pepHits=pd.merge(pepHits,proteinHits,on='protein_group_parent_id')
        pepHits['ID']=pepHits['protein_group_name']+':'+pepHits['stripped_peptide']
        pepHits = pepHits[['ID', 'x_corr_score']]
        pepHits=pepHits.groupby('ID').sum()
        pepHits['Name']=fName['sample_name'][0]
        df=pd.concat([df,pepHits],sort=False)
print(df.columns)
print(df.head())
df=df.pivot(columns='Name', values='x_corr_score')
df['x_corr_score']=df.sum(axis=1)
df=df.sort_values("x_corr_score", ascending=False)  
plotcsv=pathFiles/("x_corr_score.histogram.svg")
df.plot(kind='hist',alpha=0.5,bins=100).figure.savefig(plotcsv,dpi=100,bbox_inches = "tight")
print(df.head())
print(df.columns)
#writeDPpng=pathFiles/(fileName+"Score.png")
#df.plot(kind='hist').figure.savefig(writeDPpng.absolute(),dpi=100,bbox_inches = "tight")
#print("Histogram of Score in",writeDPpng)
writeScores=pathFiles/("x_corr_score.sum.csv")
df.to_csv(writeScores)#.with_suffix('.combo.csv'))
print("x_corr_score in\n",writeScores,"\n",plotcsv)
#dfID=df.assign(ID=df.ID.str.split(';')).explode('ID')
