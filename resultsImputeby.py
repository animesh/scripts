import sys
if len(sys.argv)!=3: sys.exit("\n\nREQUIRED: pandas! Tested with Python 3.7.9 \n\nUSAGE: python resultsImputeby.py <path to file of interest like \"L:\promec\mqpar.xml.1623227664.results\combined\txt\proteinGroupsCombine.py> <column of interest like \"Score\"\n\n")
#python resultsGroupby.py "L:\promec\USERS\Synnøve\20210709_Synnove_6samples\HF\combined\txt\msmsScans.txt" "Raw file"
inpF = sys.argv[1]
columnID = sys.argv[2]
#inpF = "L:\\promec\\USERS\\Synnøve\\20210709_Synnove_6samples\\HF\\combined\\txt\\msmsScans.txt"
#columnID = "Raw file"
import pandas as pd
df = pd.read_table(inpF)
#!/usr/bin/env python
#!pip3 install pathlib --user
import pandas as pd
df=pd.read_csv("L:\promec\Animesh\Aida\Supplementary Table 2 for working purpose.xlsxgene.csv")
df.corr('spearman').style.background_gradient(cmap="Blues")
print(df["Group"])
print(df.groupby(["Group"])['NDUFB7.6'].transform(lambda x: x.fillna(x.mean())))
dfNAR=df.groupby(["Group"]).transform(lambda x: x.fillna(x.mean()))
print(min(dfNAR.min())
dfNARM=dfNAR.fillna(int(min(dfNAR.min())-1))
print(min(dfNARM.min()))
dfNARM["Group"]=df["Group"]
dfNARM.to_csv("L:\promec\Animesh\Aida\Supplementary Table 2 for working purpose.xlsxgene.NARM.csv",index=False)
dfNARM.describe()
print(dfNARM.columns)
print(dfNARM.head())
