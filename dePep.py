import sys
#!pip3 install pandas --user
#!pip3 install pathlib --user
from pathlib import Path
if len(sys.argv)!=2:    sys.exit("REQUIRED: pandas, pathlib; tested with Python 3.8.5\n","USAGE: python dePep.py <path to folder containing allPeptidex.txt file(s) like \"L:/combined/txt\" >")
pathFiles = Path(sys.argv[1])
#pathFiles = Path("L:/promec/USERS/MarianneNymark/20200108_15-samples/QE/combined/txt/")
fileName='allPeptides.txt'
trainList=list(pathFiles.rglob(fileName))

import pandas as pd
import matplotlib.pyplot as plt
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

#import pandas_profiling
#print(dfDP.profile_report())

print(writeDPcsv)
dfDPcnt=dfDP['Modification'].value_counts()
#https://www.shanelynn.ie/bar-plots-in-python-using-pandas-dataframes/
#dfDP['Base Raw File'].value_counts().plot(kind='bar',stacked=True)
print(dfDPcnt)
writeDPpng=pathFiles/(fileName+"DP.png")
if(dfDPcnt.empty==False): dfDPcnt[dfDPcnt>0].plot(kind='pie').figure.savefig(writeDPpng.absolute(),dpi=100,bbox_inches = "tight")
if(dfDPcnt.empty==False): dfDPcnt[dfDPcnt>0].plot(kind='bar',stacked=True).figure.savefig(writeDPpng.absolute(),dpi=100,bbox_inches = "tight")
plt.close()
print(writeDPpng)
unmodCnt=dfDP[dfDP['Modification']=='Unmodified']#unmodified count(s)
unmodCnt=unmodCnt['Base Raw File'].value_counts()
unmodCnt.index=unmodCnt.keys().str.split("_").str[-1]
dfDPcnt=dfDP['Modification'].value_counts().keys()
for i in range(10):
    modName=dfDPcnt[i]
    print(modName)
    writeDPpng=pathFiles/(fileName+"DP.png")
    dfDPmod=dfDP[dfDP['Modification']==modName]
    dfDPmod=dfDPmod['Base Raw File'].value_counts()
    dfDPmod.index=dfDPmod.keys().str.split("_").str[-1]
    print(modName,dfDPmod,(dfDPmod/unmodCnt))
    writeDPcsv=pathFiles/(fileName+modName+"DP.csv")
    dfDPmod.to_csv(writeDPcsv)
    print(writeDPcsv)
    writeDPpng=pathFiles/(fileName+modName+"DP.png")
    dfDPmod.plot(kind='pie').figure.savefig(writeDPpng.absolute(),dpi=100,bbox_inches = "tight")
    plt.close()
    print(writeDPpng)
