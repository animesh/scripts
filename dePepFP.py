#!pip3 install pandas --user
#!pip3 install pathlib --user
import sys
from pathlib import Path
if len(sys.argv)!=2:    sys.exit("REQUIRED: pandas, pathlib\nTested with Python 3.9\n","USAGE: \npython dePepFP.py <path to folder containing psm.tsv file(s) like \"Z:/20220319_IP-UCHL1_MN/\" > <Hyperscore threshold for filetering> <Protein ID to filter>\n")
pathFiles = Path(sys.argv[1])
hyperScoreThr = Path(sys.argv[2])
uniprotID = Path(sys.argv[3])
#fileName = Path(sys.argv[4])
#tar cvzf fp.tgz /home/ash022/PD/TIMSTOF/LARS/2021/Desember/211207_Nilu/MGF8F/FP/*/psm.tsv
#pathFiles = Path("L:/promec/TIMSTOF/LARS/2021/Desember/211207_Nilu/FP/")
fileName='psm.tsv'
uniprotID='HUMAN'
hyperScoreThr=0
trainList=list(pathFiles.rglob(fileName))
import pandas as pd
df=pd.DataFrame()
#f=trainList[0]
for f in trainList:
    print(f)
    peptideHits=pd.read_csv(f,low_memory=False,sep='\t')
    peptideHits=peptideHits[peptideHits['Hyperscore']>hyperScoreThr]
    peptideHits=peptideHits[peptideHits['Protein'].str.contains(uniprotID) == False]
    peptideHits['Name']=f
    #peptideHits['Observed Modifications']
    df=pd.concat([df,peptideHits],sort=False)
print(df.head())
print(df.columns)
df.to_csv(pathFiles/(fileName+uniprotID+str(hyperScoreThr)+".combine.csv"))
dfDP=df[df['Observed Modifications'].notnull()]
dfDP.to_csv(pathFiles/(fileName+uniprotID+str(hyperScoreThr)+".DP.combine.csv"))
dfModCnt=df['Observed Modifications'].value_counts()
#print(df.columns.get_loc("DP Proteins"))
dfModCnt.to_csv(pathFiles/(fileName+uniprotID+str(hyperScoreThr)+".DP.count.combine.csv"))
dfModCnt[dfModCnt>10].plot(kind='bar',stacked=True).figure.savefig(pathFiles/(fileName+uniprotID+str(hyperScoreThr)+".DP.count.combine.png"),dpi=100,bbox_inches = "tight")
dfDP=df.loc[:, df.columns.str.startswith('Observed Modification')|df.columns.str.endswith('unmodified)')]
dfDP=dfDP[dfDP['Potential Modification 1'].notnull()]
#dfDP=dfDP.rename(columns = lambda x : str(x)[3:])
writeDPcsv=pathFiles/(fileName+"FP.csv")
print("writing output to ... ")
dfDP.to_csv(writeDPcsv)
print(writeDPcsv)
dfDPcnt1=dfDP['Potential Modification 1'].value_counts()
print(dfDPcnt1)
dfDPcnt2=dfDP['Potential Modification 2'].value_counts()
print(dfDPcnt2)
writeDPpng1=pathFiles/(fileName+"DP1.png")
if(dfDPcnt1.empty==False): dfDPcnt1[dfDPcnt1>0].plot(kind='pie').figure.savefig(writeDPpng1.absolute(),dpi=100,bbox_inches = "tight")
print(writeDPpng1)
writeDPpng2=pathFiles/(fileName+"DP2.png")
if(dfDPcnt2.empty==False): dfDPcnt2[dfDPcnt2>0].plot(kind='pie').figure.savefig(writeDPpng2.absolute(),dpi=100,bbox_inches = "tight")
print(writeDPpng2)
#specific mod(s)
modName="Formylation"
dfDPmod=dfDP[dfDP['Potential Modification 1']==modName]
print(modName,dfDPmod.groupby('Potential Modification 2').sum())#['Potential Modification 2'].sum())
#dfDPmod.groupby('Base Raw File').count().sum()
#dfDPmod=dfDP[dfDP['Modification'].str.contains('ly')==True]
writeDPcsv=pathFiles/(fileName+modName+"DP.csv")
dfDPmod.to_csv(writeDPcsv)
print(writeDPcsv)
modsummary=pathFiles/'global.modsummary.tsv'
if(modsummary.exists()):
    modHits=pd.read_csv(modsummary,low_memory=False,sep='\t')
modsummaryO=pathFiles/"global.modsummary.tsvDP.png"
modHits.plot(kind='bar', stacked=True).figure.savefig(modsummaryO.absolute(),dpi=600)#,bbox_inches = "tight")
#modHits.plot(kind='bar', stacked=True).figure.savefig(modsummaryO.absolute(),dpi=600)
print(modsummaryO)
