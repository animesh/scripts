#python proteinGroupsCombineTTP.py L:\promec\TIMSTOF\LARS\2024\240221_Tom_Kelt\4caaf540a6cc92c6dd28e5f87aa2406f\processing-run
#!pip3 install pandas matplotlib pathlib --user
import sys
from pathlib import Path
if len(sys.argv)!=2: sys.exit("\n\nREQUIRED: pandas, pathlib, tcl==8.6.9; tested with Python 3.7.9 \n\nUSAGE: python proteinGroupsCombineTTP.py <path to folder containing protein.tsv file(s) like \"L:\promec\Animesh\Samah\mqpar.xml.1623227664.results\" >\n\nExample\n\npython proteinGroupsCombineTTP.py L:\\promec\\TIMSTOF\\LARS\\2024\\240202_beads")
pathFiles = Path(sys.argv[1])
#pathFiles=Path("L:/promec/TIMSTOF/LARS/2024/240221_Tom_Kelt/4caaf540a6cc92c6dd28e5f87aa2406f/processing-run")
fileName='dtaselect.protein.tsv'
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
        proteinHits=pd.read_csv(f,low_memory=False,sep='\t')
        fName=pd.read_csv(f.parents[0]/summaryFile,sep='\t')
        print(fName['sample_name'])
        proteinHits.rename({'protein_group_name':'ID'},inplace=True,axis='columns')
        proteinHits.rename({'number_psms':'PSMs'},inplace=True,axis='columns')
        proteinHits=proteinHits.ID.str.split(';', expand=True).set_index(proteinHits.PSMs).stack().reset_index(level=0, name='ID')
        proteinHits=proteinHits.groupby('ID').sum()
        proteinHits['Name']=fName['sample_name'][0]
        df=pd.concat([df,proteinHits],sort=False)
print(df.columns)
print(df.head())
df=df.pivot(columns='Name', values='PSMs')
df['PSMs']=df.sum(axis=1)
df=df.sort_values("PSMs", ascending=False)  
plotcsv=pathFiles/("PSMs.histogram.svg")
df.plot(kind='hist',alpha=0.5,bins=100).figure.savefig(plotcsv,dpi=100,bbox_inches = "tight")
print(df.head())
print(df.columns)
#writeDPpng=pathFiles/(fileName+"Score.png")
#df.plot(kind='hist').figure.savefig(writeDPpng.absolute(),dpi=100,bbox_inches = "tight")
#print("Histogram of Score in",writeDPpng)
writeScores=pathFiles/("PSMs.sum.csv")
df.to_csv(writeScores)#.with_suffix('.combo.csv'))
print("PSMs in\n",writeScores,"\n",plotcsv)
#dfID=df.assign(ID=df.ID.str.split(';')).explode('ID')
