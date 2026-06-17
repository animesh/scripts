#python proteinGroupsCombineDIANN.py "L:\promec\TIMSTOF\LARS\2026\260518_Sonali\saga_batch\" "*.dreport.ppm15bm.pg_matrix.tsv"
#!pip3 install pandas --user
# %% setup
import sys
from pathlib import Path
import pandas as pd
# %% data
pathFiles = Path(sys.argv[1])
#pathFiles=Path("L:/promec/TIMSTOF/LARS/2026/260518_Sonali/saga_batch/")
dirName=sys.argv[2]
#dirName="*.dreport.ppm15bm.pg_matrix.tsv"
fileName=dirName
fileNameOut=dirName.replace("*","")+"_comb"
print(fileNameOut)
trainList=list(pathFiles.rglob(fileName))
trainList=[f for f in trainList if dirName.replace("*","") in str(f)]
print(trainList)
print(len(trainList),"files found in",pathFiles)
# %% combine
#f=trainList[-1]
proteinGroups = []
for f in trainList:
    if Path(f).stat().st_size > 0:
        fName = f.parts[-1].split('_')[2]
        print(fName, f)
        proteinHits = pd.read_csv(f, sep='\t', low_memory=False)
        key = (proteinHits['Protein.Group'] + ';;' +
               proteinHits['Protein.Names'] + ';;' +
               proteinHits['Genes'] + ';;' +
               proteinHits['First.Protein.Description'])
        intensity_col = proteinHits.columns[-1]  # verify this assumption below
        proteinHitsS = pd.DataFrame({
            'proteinGroup': key.values,
            'fileName': fName,
            'intensity': proteinHits[intensity_col].fillna(0).values
        })
        proteinGroups.append(proteinHitsS)
proteinGroupsComb = pd.concat(proteinGroups, ignore_index=True)
print(proteinGroupsComb.head())
print(proteinGroupsComb.columns)
# %% pivot
df = proteinGroupsComb.pivot_table(index='proteinGroup', columns='fileName', values='intensity', aggfunc='sum', fill_value=0)
print(df.head())
df['sum']=df.sum(axis=1)
df=df.sort_values("sum", ascending=False)  
# %% plot
print(df.head())
print(df.isnull().sum())
#writeDPpng=pathFiles/(fileName+"Score.png")
#df.plot(kind='hist').figure.savefig(writeDPpng.absolute(),dpi=100,bbox_inches = "tight")
#print("Histogram of Score in",writeDPpng)
# %% write
dfU=df.drop_duplicates()
writeScores=pathFiles/("intensity"+fileNameOut+".sum.unique.csv")
dfU.to_csv(writeScores)#.with_suffix('.combo.csv'))
