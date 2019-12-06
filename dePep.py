import sys
#pip3 install pandas --user
#pip3 install pathlib --user
from pathlib import Path
if len(sys.argv)!=2:    sys.exit("REQUIRED: pandas, pathlib; tested with Python 3.7.0\n","USAGE: python dePep.py <path to folder containing allPeptidex.txt file(s) like \"L:/combined/txt\" >")
pathFiles = Path(sys.argv[1])
#pathFiles = Path("C:/Users/animeshs/Desktop/KS/combined/txt/")
fileName='allPeptides.txt'
trainList=list(pathFiles.rglob(fileName))

import pandas as pd
df=pd.DataFrame()
for f in trainList:
    peptideHits=pd.read_csv(f,low_memory=False,sep='\t')
    print(f)
    peptideHits['Name']=f
    df=pd.concat([df,peptideHits],sort=False)
print(df.head())
print(df.columns)
#print(df.columns.get_loc("DP Proteins"))

dfDP=df.loc[:, df.columns.str.startswith('DP')|df.columns.str.startswith('Raw')]
dfDP=dfDP[dfDP['DP Proteins'].notnull()]
dfDP=dfDP.rename(columns = lambda x : str(x)[3:])
writeDPcsv=pathFiles/(fileName+"DP.csv")
print("writing output to ... ")
dfDP.to_csv(writeDPcsv)
print(writeDPcsv)
dfDPcnt=dfDP['Modification'].value_counts()
print(dfDPcnt)
writeDPpng=pathFiles/(fileName+"DP.png")
if(dfDPcnt.empty==False): dfDPcnt[dfDPcnt>0].plot(kind='pie').figure.savefig(writeDPpng,dpi=100,bbox_inches = "tight")
print(writeDPpng)
#specific mod(s)
modName="GlyGly"
dfDPmod=dfDP[dfDP['Modification']==modName]
#dfDPmod=dfDP[dfDP['Modification'].str.contains('ly')==True]
writeDPcsv=pathFiles/(fileName+modName+"DP.csv")
dfDPmod.to_csv(writeDPcsv)
print(writeDPcsv)
#specific mod(s)
modName="Phosphorylation"
dfDPmod=dfDP[dfDP['Modification']==modName]
#dfDP=dfDP[dfDP['Modification'].str.contains('ly')==True]
writeDPcsv=pathFiles/(fileName+modName+"DP.csv")
dfDPmod.to_csv(writeDPcsv)
print(writeDPcsv)
