import sys
from pathlib import Path
if len(sys.argv)!=2:    sys.exit("USAGE: python dePep.py <path to folder containing mascot exported csv file(s)>, for example,\npython dePepMascot.py L:/promec/HF/Lars/2019/november/ung\n")
pathFiles = Path(sys.argv[1])
#pathFiles = Path("L:/promec/HF/Lars/2019/november/ung")
fileName='*.csv'
trainList=list(pathFiles.rglob(fileName))

import pandas as pd
df=pd.DataFrame()
for f in trainList:
    peptideHits=pd.read_csv(f,low_memory=False,skiprows=66,doublequote=True)#,sep='\t')
    print(f)
    peptideHits['Name']=f
    peptideHits.fillna(method='ffill',inplace=True)
    df=pd.concat([df,peptideHits],sort=False)
print(df.head())
print(df.columns)
fileName=fileName.replace("*.","")
writecsv=pathFiles/(fileName+"combined.csv")
df.to_csv(writecsv)
print(df.columns.get_loc("prot_acc"))

dfDP=df.loc[:, df.columns.str.startswith('prot')|df.columns.str.startswith('pep')]
#dfDP=dfDP[dfDP['DP Proteins'].notnull()]
#dfDP=dfDP.rename(columns = lambda x : str(x)[3:])
#dfDP[dfDP['Modification']=="Phosphorylation"]
#dfDP=dfDP[dfDP['Modification'].str.contains('hosphor')==True]
writeDPcsv=pathFiles/(fileName+"DP.csv")
dfDP.to_csv(writeDPcsv)
print("writing output to ... ")
print(writeDPcsv)

dfDPcnt=dfDP['prot_acc'].value_counts()
print(dfDPcnt)

writeDPpng=pathFiles/(fileName+"DP.png")
dfDPcnt[dfDPcnt>0].plot(kind='pie').figure.savefig(writeDPpng,dpi=100,bbox_inches = "tight")
print(writeDPpng)
