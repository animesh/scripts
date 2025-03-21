#python peptideGroupsMQDIANNcombine.py L:\promec\TIMSTOF\LARS\2025\250319_Alessandro\combined\txt\peptides.txt L:\promec\TIMSTOF\LARS\2025\250319_Alessandro\DIANNv2\report.pr_matrix.tsv
#!pip3 install pandas matplotlib --user
import sys
if len(sys.argv)!=3: sys.exit("\n\nREQUIRED: pandas; tested with Python 3.12 \n\nUSAGE: python peptideGroupsMQDIANNcombine.py <path to peptides.txt>  <path to pr_matrix.tsv>\n\n")
#pathFiles=Path("L:/promec/TIMSTOF/LARS/2024/240221_Tom_Kelt/4caaf540a6cc92c6dd28e5f87aa2406f/processing-run")
fileMQ='L:\\promec\\TIMSTOF\\LARS\\2025\\250319_Alessandro\\combined\\txt\\peptides.txt'
fileDIANN='L:\\promec\\TIMSTOF\\LARS\\2025\\250319_Alessandro\\DIANNv2\\report.pr_matrix.tsv'
print(fileMQ)
print(fileDIANN)
import pandas as pd
dfMQ = pd.read_csv(fileMQ,sep='\t')
dfDIANN = pd.read_csv(fileDIANN,sep='\t')
dfMQ.rename({'Sequence':'ID'},inplace=True,axis='columns')
dfDIANN.rename({'Stripped.Sequence':'ID'},inplace=True,axis='columns')
pepHits=pd.merge(dfMQ,dfDIANN,on='ID',how='outer')
print(pepHits.columns)
print(pepHits.head())
import numpy as np
pepHits['Protein.Ids'] = pepHits['Protein.Ids'].replace({np.nan: ""})
pepHits['Proteins'] = pepHits['Proteins'].replace({np.nan: ""})
pepHits['Uniprots']=pepHits['Protein.Ids'].str.upper()+';'+pepHits['Proteins'].str.upper()#.str.split(';',expand=True)
#pepHits['Uniprots'].str.split(';',expand=True)[0]
pepHits['Uniprots'] = pepHits['Uniprots'].str.split(';')
pepHits=pepHits.explode('Uniprots')
pepHits = pepHits.drop_duplicates()
pepHits = pepHits.reset_index(drop=True)#.str.split(';',expand=True)
pepHits = pepHits[pepHits["Uniprots"] != ""]
pepHits = pepHits.replace({np.nan:0})
pepHits=pepHits.astype("string")
pepHits.replace('\.','0', regex=True,inplace=True)
pepHits = pepHits.replace({'.':""})
proteinHits=pepHits.groupby('Uniprots',as_index=False).agg(lambda x: ''.join(x))
proteinHits.replace('0','', regex=True,inplace=True)
proteinHits.replace('^\d','1', regex=True,inplace=True)
proteinHits=proteinHits.drop_duplicates()
proteinHits.to_csv("proteinHits_combined.csv")
