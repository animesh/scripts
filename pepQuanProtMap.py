#python pepQuanProtMap.py "L:/promec/TIMSTOF/LARS/2026/260908_Moreforsk/combined/txtLen/peptides.txt" "A0A8C5CNW5"
#python pepQuanProtMap.py "L:/promec/TIMSTOF/LARS/2026/260908_Moreforsk/trypsin/combined/txtLen/peptides.txt" "A0A8C5CNW5"
import sys
if len(sys.argv)!=3:sys.exit("USAGE: python pepQuanProtMap.py <tab-sep-peptide-file> <Uniprot-ID>")
pathFile = sys.argv[1]
#pathFile = "L:/promec/TIMSTOF/LARS/2026/260908_Moreforsk/trypsin/combined/txt/peptides.txt"
protName=sys.argv[2]
#protName='A0A8C4ZK06'
import pandas as pd
proteinHits=pd.read_csv(pathFile,low_memory=False,sep='\t')
#proteinHits.rename({'Unique Spectral Count':'uniqPSMs'},inplace=True,axis='columns')
#proteinHits=proteinHits.ID.str.split(';', expand=True).set_index(proteinHits.uniqPSMs).stack().reset_index(level=0, name='ID')
df=proteinHits[proteinHits['Leading razor protein'].str.startswith(protName)]
df.rename({'Sequence':'ID'},inplace=True,axis='columns')
print(df.head)
#df=df.pivot_table(index='ID', columns='Name', values='MedianLog2SILAC', aggfunc='median')
df.ID.to_csv(pathFile+protName+"peptides.txt",sep="\t",index=False,header=False)
import matplotlib.pyplot as plt
#plt.scatter(df["Start position"],df["Intensity"],c=df['Length'])
#plt.annotate(df['ID'],df["Start position"],df["Intensity"])
#plt.show()
#plotcsv=pathFiles/(fileName+".eColiPositionLFQ.svg")
fig, ax = plt.subplots()
ax.scatter(df["Start position"],df["Intensity"],c=df['Length'])
ax.set_xlabel('Start position')
ax.set_ylabel('Intensity')
ax.set_title(protName)
for idx, row in df.iterrows(): ax.annotate(row['ID'],(row["Start position"],row["Intensity"]), size=4)
# force matplotlib to draw the graph
plt.savefig(pathFile+protName+".svg",dpi=100,bbox_inches = "tight")
#plt.show()
import numpy as np
df['log2']=np.log2(df["Intensity"]+1)
df=df.sort_values('Start position')
print(df[['ID','log2','Start position','End position','Length']])
fig, ax = plt.subplots()
ax.scatter(df["Start position"],df["log2"],c=df['Length'])
ax.set_xlabel('Start position')
ax.set_ylabel('log2')
ax.set_title(protName)
for idx, row in df.iterrows(): ax.annotate(row['ID'], (row["Start position"],row["log2"]), rotation=0, size=4)
# force matplotlib to draw the graph
plt.savefig(pathFile+protName+"log2.svg",dpi=100,bbox_inches = "tight")
#plt.show()

