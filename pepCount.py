import sys
from pathlib import Path
if len(sys.argv)!=2:    sys.exit("USAGE: python pepCount.py <path to peptides containing proteome-discoverer exported file>, \n e.g.,\npython pepCount.py \"L:/promec/HF/Lars/2021/march/Ingrid/KO/210317_Ingrid2-(1)_PeptideGroups.txt\"\n")
pathFiles = Path(sys.argv[1])
#pathFiles = Path("L:/promec/HF/Lars/2021/march/Ingrid/KO/210317_Ingrid2-(1)_PeptideGroups.txt")
import pandas as pd
df=pd.read_csv(pathFiles,low_memory=False,doublequote=True,sep='\t')
print(df.columns)
print(df.dtypes)
df = df.convert_dtypes(convert_boolean=False)
print(df.dtypes)
print("\nData in",pathFiles,df.info())
df=df[df["PSM Ambiguity"]=="Unambiguous"]
print("\nKeeping Unambiguous PSMs",df.info())
df['Modifications'] = df['Modifications'].fillna("UnMod")
dfDNQ=df[df.Modifications.str.contains("Deamidat")&~df.Modifications.str.contains("UnMod")].Sequence.to_frame()
print("\nDeamidated NQ counts",dfDNQ.info())
dfUnMod=df[df.Modifications.str.contains("UnMod")].Sequence.to_frame()
print("\nUnMod count",dfUnMod.info())
df_diff = pd.concat([dfUnMod,dfDNQ]).drop_duplicates(keep=False)
print("\nDifference",df_diff.info())
dfUnModInDNQ=[]
for seq in dfUnMod.Sequence:
    dfUnModInDNQ.append(dfDNQ.Sequence.str.contains(seq).sum())
print("\nUnMod NOT In DNQ",dfUnModInDNQ.count(0))
dfDNQinUnMod=[]
for seq in dfDNQ.Sequence:
    dfDNQinUnMod.append(dfUnMod.Sequence.str.contains(seq).sum())
print("\nDNQ NOT in UnMod",dfDNQinUnMod.count(0))
print("\nDNQ NOT in UnMod %",100*dfDNQinUnMod.count(0)/len(df))
