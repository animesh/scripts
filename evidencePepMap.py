#C:\\Users\\animeshs\\AppData\\Local\\Programs\\Spyder\\Python\\python.exe f:\GD\OneDrive\Dokumenter\GitHub\scripts\evidenceIntensityPepMap.py z:\SIGRID\combined\txt\evidence.txt
import sys
from pathlib import Path
pathFiles = Path(sys.argv[1])
#pathFiles = Path("L:\\promec\\USERS\\Alessandro\\230119_66samples-redo\\combined\\txt\\evidence.txt")
import pandas as pd
df=pd.read_csv(pathFiles,low_memory=False,sep='\t')
print(df.columns)
print(df.head())
import matplotlib.pyplot as plt
#plt.plot(df['PEP'])
#plt.hist(df['PEP'])
dfS=df.copy()
dfS=df[df['PEP']<1]
print(dfS['Modifications'].value_counts())
#peptidePTM=['Unmodified','Acetyl (Protein N-term)','Oxidation (M)','Deamidation (NQ)']
#peptidePTM="Deamidation \(NQ\)"
#dfS=dfS[~dfS['Modifications'].str.contains(peptidePTM)]
dfS.rename({'Sequence':'ID'},inplace=True,axis='columns')
dfP=dfS.pivot_table(index='ID', columns='Raw file', values='Intensity', aggfunc='sum')
dfP=dfP.fillna(0)
dfP["sumInt"]=dfP.sum(axis=1)
print(dfP.sumInt.describe())
#check
#dfPep=pd.read_csv(pathFiles.parent/"peptides.txt",low_memory=False,sep='\t')
#dfM=dfPep.merge(dfP,left_on='Sequence', right_on='ID',how='outer',indicator=True)
#print(dfM['_merge'])
#print(dfM[dfM['_merge']=="right_only"])
#print(dfM[dfM['_merge']=="left_only"])
#print(dfM[dfM['_merge']=="left_only"].Intensity.describe())
#dfM["diffInt"]=(dfM.Intensity-dfM.sumInt)/dfM.sumInt
#dfM.to_csv(pathFiles.with_suffix('.mergedIntensity.csv'))#,sep="\")#,rownames=FALSprint(dfM.columns)
#dfC=dfM[dfM['_merge']=="both"]
#dfC.diffInt.hist()
#print(dfC.diffInt.describe())
dfP.to_csv(pathFiles.with_suffix('.combinedIntensity.csv'))#,sep="\")#,rownames=FALSE)
dfSM=dfS.pivot_table(index='ID', columns='Raw file', values='Score', aggfunc='max')
dfSM=dfSM.fillna(0)
dfSM["maxScore"]=dfSM.max(axis=1)
print(dfSM.maxScore.describe())
dfSM.to_csv(pathFiles.with_suffix('.ScoreMax.csv'))#,sep="\")#,rownames=FALSE)
#dfMS=dfPep.merge(dfSM,left_on='Sequence', right_on='ID',how='outer',indicator=True)
#print(dfMS[dfMS['_merge']=="right_only"])
#print(dfMS[dfMS['_merge']=="left_only"])
#print(dfMS[dfMS['_merge']=="left_only"].Score.describe())
#dfMS["diffScore"]=(dfMS.Score-dfMS.maxScore)#/dfM.sumInt
#dfMS.to_csv(pathFiles.with_suffix('.merge.scoreMax.csv'))#,sep="\")#,rownames=FALSE)
#dfCS=dfMS[dfMS['_merge']=="both"]
#dfCS.diffScore.hist()
#print(dfCS.diffScore.describe())
#df1A_Slot2=dfM[dfM['_merge']=="both"].filter(regex='3_Slot2-21_1_648',axis=1)
#diffInt=df1A_Slot2.iloc[:,-1]-df1A_Slot2.iloc[:,-3]
#print("\nDff Intensity Summary\n",diffInt.describe())
#dfC[dfC['Sequence']=="AVFADLDLR"]
#!grep "AVFADLDLR" /mnt/z/SIGRID/combined/txt/*
#/mnt/z/SIGRID/combined/txt/accumulatedMsmsScans.txt:211105_hela_Slot1-54_1_365  20592   1879.9  30.843049327354255      +               AVFADLDLR       9       531.2830031301097       1060.5514533270193   2       209063  89.8104248046875        0.2916503906249943      0.8855212679223398      0.023857869449965263    29807.587139867555      Acetyl (Protein N-term) _(Acetyl (Protein N-term))AVFADLDLR_ P78346  51.066213193756575      0.04979819692857459                     20592
#/mnt/z/SIGRID/combined/txt/peptides.txt:AVFADLDLR       ______________________________  ______________________________  M       A       V       L       R       A       2       1       0   1018.5447        P78346  P78346  2       10      RPP30   Ribonuclease P protein subunit p30      no      no              1       NaN     0                       2752    1878                0
#plt.plot(dfC['PEP'])
#plt.plot(df1A_Slot2.iloc[:,-1],df1A_Slot2.iloc[:,-3],"o")
#fig, ax = plt.subplots()
#ax.scatter(dfM.iloc[:,-2],dfM['Intensity'],c=dfM['PEP'])
#ax.set_xlabel('Evidence')
#ax.set_ylabel('Intensity')
#for idx, row in df.iterrows(): ax.annotate(row['Sequence'], (dfM.iloc[:,-2],dfM['Intensity']))
# force matplotlib to draw the graph
plt.savefig(pathFiles.with_suffix('.combinedIntensity.png'),dpi=100,bbox_inches = "tight")
#plt.show()
