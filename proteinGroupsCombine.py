#python proteinGroupsCombine.py "L:\OneDrive - NTNU\Aida\sORF\mqpar.K8R10.xml.1664621075.results"
import sys
from pathlib import Path
if len(sys.argv)!=2: sys.exit("\n\nREQUIRED: pandas, pathlib; tested with Python 3.9 \n\nUSAGE: python proteinGroupsCombine.py <path to folder containing proteinGroups.txt file(s) like \"L:\OneDrive - NTNU\Aida\sORF\mqpar.K8R10.xml.1664621075.results\" >\n\nExample\n\npython proteinGroupsCombine.py L:\promec\TIMSTOF\LARS\2022\januar\220119_ELise_rerun")
pathFiles = Path(sys.argv[1])
#pathFiles=Path("L:/OneDrive - NTNU/Aida/sORF/mqpar.K8R10.xml.1664621075.results/")
fileName='proteinGroups.txt'
trainList=list(pathFiles.rglob(fileName))
#trainList=[fN for fN in trainList if "MGUS" in str(fN)]
#trainList=list([Path('L:/promec/TIMSTOF/LARS/2022/mars/Elise3/combined/txt/proteinGroups.txt'),Path('L:/promec/TIMSTOF/LARS/2022/januar/220119_ELise_rerun/Oslo/txt/proteinGroups.txt')])
#!pip3 install pandas --user
import pandas as pd
#df = pd.concat(map(pd.read_table, trainList))
#df.to_csv(pathFiles.with_suffix('.combinedT.txt'),sep="\t")#,rownames=FALSE)
dfI=pd.DataFrame()
dfC=pd.DataFrame()
dfB=pd.DataFrame()
dfR=pd.DataFrame()
i=0
for f in trainList:
    #f=trainList[i]
    i=i+1
    if Path(f).stat().st_size > 0:
        print(i,f.parts[-4],f.parts[-1])
        proteinHits=pd.read_csv(f,low_memory=False,sep='\t')
        cN=proteinHits.columns
        proteinHits=proteinHits[proteinHits['Reverse']!="+"]
        proteinHits=proteinHits[proteinHits['Potential contaminant']!="+"]
        proteinHits=proteinHits[proteinHits['Only identified by site']!="+"]
        proteinHits.rename({'Protein IDs':'ID'},inplace=True,axis='columns')
        proteinHits=proteinHits[~proteinHits['ID'].str.contains("_HUMAN",na=False)]
        proteinHits.rename({'Ratio H/L normalized':'RatioH2L'},inplace=True,axis='columns')
        proteinHits.rename({'iBAQ L':'iBAQL'},inplace=True,axis='columns')
        proteinHits.rename({'Intensity L':'IntensityL'},inplace=True,axis='columns')
        proteinHitsC=proteinHits.ID.str.split(';', expand=True).set_index(proteinHits.Score).stack().reset_index(level=0, name='ID')
        proteinHitsI=proteinHits.ID.str.split(';', expand=True).set_index(proteinHits.IntensityL).stack().reset_index(level=0, name='ID')
        proteinHitsB=proteinHits.ID.str.split(';', expand=True).set_index(proteinHits.iBAQL).stack().reset_index(level=0, name='ID')
        proteinHitsR=proteinHits.ID.str.split(';', expand=True).set_index(proteinHits.RatioH2L).stack().reset_index(level=0, name='ID')
        proteinHitsI['Name']=f.parts[-4]+f.parts[-1]+str(i)
        proteinHitsC['Name']=f.parts[-4]+f.parts[-1]+str(i)
        proteinHitsB['Name']=f.parts[-4]+f.parts[-1]+str(i)
        proteinHitsR['Name']=f.parts[-4]+f.parts[-1]+str(i)
        dfI=pd.concat([dfI,proteinHitsI],sort=False)
        dfC=pd.concat([dfC,proteinHitsC],sort=False)
        dfB=pd.concat([dfB,proteinHitsB],sort=False)
        dfR=pd.concat([dfR,proteinHitsR],sort=False)
print(dfI.columns)
print(dfC.columns)
print(dfB.columns)
print(dfR.columns)
dfI=dfI.pivot(index='ID', columns='Name', values='IntensityL')
dfC=dfC.pivot(index='ID', columns='Name', values='Score')
dfB=dfB.pivot(index='ID', columns='Name', values='iBAQL')
dfR=dfR.pivot(index='ID', columns='Name', values='RatioH2L')
#df.to_csv(pathFiles.with_suffix('.combined.txt'),sep="\")#,rownames=FALSE)
#writeDPpng=pathFiles/(fileName+"Score.png")
#df.plot(kind='hist').figure.savefig(writeDPpng.absolute(),dpi=100,bbox_inches = "tight")
#print("Histogram of Score in",writeDPpng)
dfI['SumI']=dfI.sum(axis=1)
dfB['SumB']=dfB.sum(axis=1)
dfC['SumC']=dfC.sum(axis=1)
dfR['SumR']=dfR.sum(axis=1)
dfI=dfI[dfI['SumI']!=0]
dfB=dfB[dfB['SumB']!=0]
dfC=dfC[dfC['SumC']!=0]
dfR=dfR[dfR['SumR']!=0]
dfI=dfI.sort_values('SumI',ascending=False)
dfB=dfB.sort_values('SumB',ascending=False)
dfC=dfC.sort_values('SumC',ascending=False)
dfR=dfR.sort_values('SumR',ascending=False)
dfI.to_csv(pathFiles/(fileName+"Combo.intensityL.csv"))#.with_suffix('.combo.csv'))
dfB.to_csv(pathFiles/(fileName+"Combo.iBAQL.csv"))#.with_suffix('.combo.csv'))
dfC.to_csv(pathFiles/(fileName+"Combo.score.csv"))#.with_suffix('.combo.csv'))
dfR.to_csv(pathFiles/(fileName+"Combo.RatioH2L.csv"))#.with_suffix('.combo.csv'))
histScores=pathFiles/(fileName+"HistInt.svg")
import numpy as np
log2dfR=dfR.fillna(1)
print(log2dfR.columns)
log2dfR=np.log2(log2dfR)
log2dfR=log2dfR.drop('SumR',axis=1)
log2dfR.plot(kind='hist',alpha=0.5,bins=100).figure.savefig(histScores,dpi=100,bbox_inches = "tight")
print("Scatter of First 2 Intensities in",pathFiles/(fileName+"Scatter.svg"))
import seaborn as sns
sns.jointplot(y=log2dfR.iloc[:,0],x=log2dfR.iloc[:,1], ).figure.savefig(pathFiles/(fileName+"Scatter.svg"),dpi=100,bbox_inches = "tight")#,kind="reg")
#sns.jointplot(data=log2dfI,y='Oslo220119_ELise_rerunjanuar2', x='combined220119_ELise_rerunjanuar1').figure.savefig(pathFiles/(fileName+"Scatter.svg"),dpi=100,bbox_inches = "tight")#,kind="reg")
#sns.jointplot(data=log2dfI[:,1:2])#,kind="reg")
#dfB.plot(kind='hist',alpha=0.5,bins=100).figure.savefig(pathFiles/(fileName+"iBAQhist.svg"),dpi=100,bbox_inches = "tight")
#dfC.plot(kind='hist',alpha=0.5,bins=100).figure.savefig(pathFiles/(fileName+"ScoresHist.svg"),dpi=100,bbox_inches = "tight")
#dfID=df.assign(ID=df.ID.str.split(';')).explode('ID')
df=dfR
i=0
for f in trainList:
    i=i+1
    if Path(f).stat().st_size > 0:
        print(i,f.parts[-4],f.parts[-1])
        proteinHits=pd.read_csv(f,low_memory=False,sep='\t')
        proteinHitsR=proteinHits.assign(ID=proteinHits['Protein IDs'].str.split(';')).explode('ID')
        proteinHitsR.index=proteinHitsR['ID']
        proteinHitsR=proteinHitsR.add_suffix(f.parts[-4]+'F'+str(i))
        df=pd.concat([df,proteinHitsR],axis=1,join='inner')
print(df.columns)
#dfLFQ['211207_NiluDesember2'].hist()
#(dfLFQ['211221_NiluDesember3']-dfLFQ['Score211221_NiluDesemberF3']).hist()
df.to_csv(pathFiles/(fileName+"Combo.csv"))
dfS=df.filter(like='Peptide sequence', axis=1)
#dfS=dfLFQ[:,[dfLFQ.filter(like='Peptide sequence', axis=1)]].apply(lambda x: ''.join(x), axis=1)
dfLFQPeptides=dfS[dfS.columns].apply(lambda x:','.join(x.dropna().astype(str)),axis=1)
#dfLFQPeptides['C9J1R6']#EFPDLGAHCSEPSCQR
#dfLFQPeptides.filter(like='HTSALCNSCR')#EFPDLGAHCSEPSCQR,HPLDHDCSGEGHPTSR;HRHPLDHDCSGEGHPTSR,HPLDHDCSGEGHPTSR;HRHPLDHDCSGEGHPTSR
dfLFQPeptides.to_csv(pathFiles/(fileName+"dfLFQPeptides.csv"))
#dfLFQvals=df.filter(like='Unique peptides', axis=1)
#dfLFQvals=df.filter(like='iBAQ', axis=1)
dfLFQvals=df.filter(like='Ratio', axis=1)
#dfLFQvals=dfLFQ.filter(like='Intensity', axis=1)
dfLFQvals.to_csv(pathFiles/(fileName+"dfLFQvals.csv"))
#dfLFQvals.to_csv(pathFiles/(fileName+"dfiBAQvals.csv"))
#dfLFQvals.to_csv(pathFiles/(fileName+"dfUniPeps.csv"))
dfLFQvalsSeqs=pd.concat([dfLFQvals,dfLFQPeptides],axis=1)
dfLFQvalsSeqs.to_csv(pathFiles/(fileName+"dfLFQvalsSeqs.csv"))
dfLFQvalsSeqsMedian=dfLFQvalsSeqs.groupby(0).median()
dfLFQid=dfLFQPeptides.reset_index()
dfLFQidC=dfLFQid.groupby(0).agg({'ID': ';'.join})
dfLFQvalsSeqsUni=pd.concat([dfLFQidC,dfLFQvalsSeqsMedian],axis=1)
dfLFQvalsSeqsUni.to_csv(pathFiles/(fileName+"dfLFQvalsSeqsUni.csv"))
log2dfLFQvalsSeqsUni=dfLFQvalsSeqsUni.fillna(0)
log2dfLFQvalsSeqsUni.index=log2dfLFQvalsSeqsUni['ID']
log2dfLFQvalsSeqsUni=log2dfLFQvalsSeqsUni.drop(['ID'], axis=1)
log2dfLFQvalsSeqsUni=np.log2(log2dfLFQvalsSeqsUni+1)
log2dfLFQvalsSeqsUni.iloc[:,30]#LFQ intensity 4H_Elise_Slot1-34_1_3303Oslo220119_ELise_rerunjanuarF2
log2dfLFQvalsSeqsUni.iloc[:,16]#LFQ intensity 1B_Elise_Slot1-20_1_3268Oslo220119_ELise_rerunjanuarF2
print(log2dfLFQvalsSeqsUni.columns)
