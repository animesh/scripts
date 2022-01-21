# python peptideGroupsCombine.py L:/promec/Animesh/Maria/peptides/peptides
# where peptides folder contains all experiments generated like like following:
# tar cvzf pep.tgz mqpar.xml.1642586*/*/combined/txt/peptides.txt
# mkdir peptides
# cd peptides
# tar xvzf ../pep.tgz
#!pip3 install pandas pathlib --user
import pandas as pd
import sys
from pathlib import Path
if len(sys.argv) != 2:
    sys.exit("\n\nREQUIRED: pandas, pathlib; tested with Python 3.9.9 \n\nUSAGE: python peptideGroupsCombine.py <path to folder containing peptides.txt file(s) like \"L:\promec\Animesh\Maria\mqpar.xml.1623227664.results\" >\n\nExample\n\npython proteinGroupsCombineTTP.py L:\promec\Animesh\Maria\mqpar.xml.1623227664.results")
pathFiles = Path(sys.argv[1])
# pathFiles=Path("L:/promec/Animesh/Maria/peptides")
fileName = 'peptides.txt'
trainList = list(pathFiles.rglob(fileName))
#df = pd.concat(map(pd.read_table, trainList))
# df.to_csv(pathFiles.with_suffix('.combinedT.txt'),sep="\t")#,rownames=FALSE)
# f=trainList[0]
df = pd.DataFrame()
for f in trainList:
    if Path(f).stat().st_size > 0:
        peptideHits = pd.read_csv(f, low_memory=False, sep='\t')
        print(f.parts[-5])
        # peptideHits.rename({'Protein':'ID'},inplace=True,axis='columns')
        #peptideHits.rename({'Median Log2 Ratios HL':'MedianLog2SILAC'},inplace=True,axis='columns')
        # +(peptideHits['Charges']).astype(str)
        peptideHits['ID'] = peptideHits['Sequence'] + \
            ';'+peptideHits['Leading razor protein']
        peptideHits.rename({'Score': 'Andromeda'},
                           inplace=True, axis='columns')
        #peptideHits=peptideHits.ID.str.split(' ', expand=True).set_index(peptideHits.MedianLog2SILAC).stack().reset_index(level=0, name='ID')
        peptideHits['Name'] = f.parts[-5]
        df = pd.concat([df, peptideHits], sort=False)
print(df.columns)
print(df.head())
df = df.pivot_table(index='ID', columns='Name',values='Andromeda')  # , aggfunc='median')
# dfO=df
# df.to_csv(pathFiles.with_suffix('.combined.txt'),sep="\")#,rownames=FALSE)
plotcsv = pathFiles/(fileName+".Score.histogram.svg")
df.plot(kind='hist', alpha=0.5, bins=100).figure.savefig(plotcsv, dpi=100, bbox_inches="tight")
print(df.head())
print(df.columns)
df.iloc[:, 0:1].plot(kind='hist')
# writeDPpng=pathFiles/(fileName+"Score.png")
#df.plot(kind='hist').figure.savefig(writeDPpng.absolute(),dpi=100,bbox_inches = "tight")
#print("Histogram of Score in",writeDPpng)
# selecting for phosphorylated-peptides
#df=df.filter(regex='79', axis="index")
df['Count'] = df.count(axis=1)
df = df.sort_values('Count', ascending=False)
writeScores = pathFiles/(fileName+".Count.Score.csv")
df.to_csv(writeScores)  # .with_suffix('.combo.csv'))
print("Count Score in\n", writeScores, "\n", plotcsv)
# dfID=df.assign(ID=df.ID.str.split(';')).explode('ID')
