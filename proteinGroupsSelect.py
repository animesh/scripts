#python proteinGroupsSelect.py L:\promec\TIMSTOF\LARS\2024\240221_Tom_Kelt\combined\txtv252\proteinGroups.txt L:\promec\TIMSTOF\LARS\2024\240221_Tom_Kelt\list.txt
# %%setup
import sys
from pathlib import Path
pathFiles = Path(sys.argv[1])
pathFiles=Path("L:/promec/TIMSTOF/LARS/2024/240221_Tom_Kelt/combined/txtv252/proteinGroups.txt")
listFiles=Path("L:/promec/TIMSTOF/LARS/2024/240221_Tom_Kelt/list.txt")
ID1='Protein IDs'
ID2='Uniprot'
print(pathFiles,listFiles)
#%%data 
import pandas as pd
if pathFiles.stat().st_size > 0:
    print(pathFiles.parts)
    proteinHits=pd.read_csv(pathFiles,low_memory=False,sep='\t')
    if ID1 in proteinHits:
        print(proteinHits.columns)
        proteinHits.rename({ID1:'ID'},inplace=True,axis='columns')
        proteinHits.ID=proteinHits.ID.str.split(';')
        print(proteinHits.shape)
        proteinHits=proteinHits.explode('ID')
        print(proteinHits.shape)
if listFiles.stat().st_size > 0:
    print(listFiles.parts)
    listHits=pd.read_csv(listFiles,low_memory=False,sep='\t')
    if ID2 in listHits:
        print(listHits.columns)
        listHits.rename({ID2:'ID'},inplace=True,axis='columns')
        listHits.ID=listHits.ID.str.split(';')
        print(listHits.shape)
        listHits=listHits.explode('ID')
        print(listHits.shape)
        proteinHits=listHits.merge(proteinHits, on='ID', how='inner')        
print(proteinHits.columns,proteinHits.shape)
outFile=str(listFiles)+pathFiles.name+ID1+ID2+"combo.csv"
proteinHits.to_csv(outFile,index=False)#.with_suffix('.combo.csv'))
#%%results
print("procesed"+str(listFiles)+str(pathFiles))
print("result"+outFile)
