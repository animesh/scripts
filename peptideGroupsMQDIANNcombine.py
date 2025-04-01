#python peptideGroupsMQDIANNcombine.py L:\promec\TIMSTOF\LARS\2025\250319_Alessandro\combined\txt\peptides.txt L:\promec\TIMSTOF\LARS\2025\250319_Alessandro\DIANNv2\report.pr_matrix.tsv
#!pip3 install pandas matplotlib --user
import sys
if len(sys.argv)!=3: sys.exit("\n\nREQUIRED: pandas; tested with Python 3.12 \n\nUSAGE: python peptideGroupsMQDIANNcombine.py <path to peptides.txt>  <path to pr_matrix.tsv>\n\n")
fileMQ=sys.argv[1]
fileDIANN=sys.argv[2]
#fileMQ='L:\\promec\\TIMSTOF\\LARS\\2025\\250319_Alessandro\\combined\\txt\\peptides.txt'
#fileDIANN='L:\\promec\\TIMSTOF\\LARS\\2025\\250319_Alessandro\\DIANNv2\\report.pr_matrix.tsv'
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
pepHits['Genes'] = pepHits['Genes'].replace({np.nan: ""})
pepHits['Gene names'] = pepHits['Gene names'].replace({np.nan: ""})
pepHits['GeneList']=pepHits['Genes'].str.upper()+';'+pepHits['Gene names'].str.upper()#.str.split(';',expand=True)
print(pepHits['GeneList'])
#pepHits['Uniprots'].str.split(';',expand=True)[0]
pepHits['GeneList'] = pepHits['GeneList'].str.split(';')
pepHits=pepHits.explode('GeneList')
pepHits = pepHits.drop_duplicates()
pepHits = pepHits.reset_index(drop=True)#.str.split(';',expand=True)
pepHits = pepHits[pepHits["GeneList"] != ""]
pepHitsNum = pepHits.select_dtypes(include='number')
print(pepHitsNum.describe())
pepHitsNum = pepHitsNum.replace({np.nan:0})
pepHitsNum['GeneList'] = pepHits['GeneList']
pepHitsNum=pepHitsNum.groupby('GeneList').agg(lambda x: x.sum())
#pepHistSum=pepHitsNum.sum()
pepHitsNum=pepHitsNum.drop_duplicates()
print(pepHitsNum.head())
print(pepHitsNum.describe())
pepHitsNum.to_csv("geneHitsUniq.csv")
