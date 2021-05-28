print("peptide.txt output file to calculate the incorporation rate. Distinguish between lysine- and argininecontaining peptides. For each of these subsets determine the incorporation rate as 1–1/average ratio, using the non-normalized ratios. The density plot of the density distribution should be narrow, and for both lysine and arginine it should be above 0.95, Reference: Use of stable isotope labeling by amino acids in cell culture as a spike-in standard in quantitative proteomics https://www.nature.com/articles/nprot.2010.192")
import sys
from pathlib import Path

print("\n\nExample\n\npython checkIncorporationRate.py \"F:/promec/Elite/LARS/2021/mai/sudhl5 silac/combined/txt/\" peptides.txt\n\n")
if len(sys.argv) != 3:
    #dirName = Path("F:/promec/Elite/LARS/2021/mai/sudhl5 silac/combined/txtStab/")
    dirName = Path("F:/mqpar.xml.1622105612.results/210526_K8R10_sudhl5/combined/txt/")
    #fileName='proteinGroups.txt'
    fileName='peptides.txt'
    print("\n\nUSAGE: python checkIncorporationRate.py <path to folder containing",fileName,"file(s)>\n\nUsing DEFAULT directory\"", dirName, "\"looking for\"", fileName, "\"file(s)\n\n")
else:
    dirName = Path(sys.argv[1])
    fileName = sys.argv[2]
    print("Input:\"", dirName, "\"as directory, looking for\"", fileName, "\"\n\n")

print("Using\n",dirName,fileName)
trainList=list(dirName.rglob(fileName))

columnName='^(Ratio H/L)(.*)'#'*([0-9])$'
columnNameH='^(Intensity H)(.*)'#'*([0-9])$'
columnNameL='^(Intensity L)(.*)'#'*([0-9])$'

import pandas as pd
df=pd.DataFrame()
for f in trainList:
    proteinGroups=pd.read_csv(f,low_memory=False,sep='\t')
    print(f)
    proteinGroups['Name']=f
    df=pd.concat([df,proteinGroups],sort=False)
print(df.head())
print(df.columns)
df=df[df["Reverse"]!='+']
df=df[df["Potential contaminant"]!='+']
dfPG=df.filter(regex=columnName,axis=1)
#dfPG=dfPG.rename(columns = lambda x : str(x)[10:])
writePGpng=dirName/(fileName+"PG.png")
dfPGcnt=dfPG.count()
print(dfPGcnt)
print("writing output to ... ")
#dfPGcnt[dfPGcnt<max(dfPGcnt)].plot(kind='bar').figure.savefig(writePGpng,bbox_inches = "tight")
#print(writePGpng)
dfPG=1-(1/dfPG.mean(axis = 0, skipna = True))
writePGcsv=dirName/(fileName+".IR.csv")
dfPG.to_csv(writePGcsv,header=False)
print(writePGcsv)
#dfPG.hist()

dfPGH=df.filter(regex=columnNameH,axis=1)
dfPGH=dfPGH.rename(columns = lambda x : str(x)[12:])
dfPGL=df.filter(regex=columnNameL,axis=1)
dfPGL=dfPGL.rename(columns = lambda x : str(x)[12:])
#dfPGH2Ldiff=dfPGH-dfPGL
dfPGH2Lratio=(dfPGH+1)/(1+dfPGL)
writePGtxt=dirName/(fileName+".IRH2L.txt")
dfPGH2Lratio.to_csv(writePGtxt,header=True,sep='\t')
print(writePGtxt)


dfPGH2LratioIR=1-(1/dfPGH2Lratio.mean(axis = 0, skipna = True))
print(dfPGH2LratioIR)
writePGcsv=dirName/(fileName+".IRH2L.csv")
dfPGH2LratioIR.to_csv(writePGcsv,header=False)
print(writePGcsv)

print(dfPG)

import numpy as np
dfK=df[df["Last amino acid"]=='K']
writeKpng=dirName/(fileName+"log2K.png")
np.log2(dfK["Ratio H/L"]).hist().figure.savefig(writeKpng,bbox_inches = "tight")
dfR=df[df["Last amino acid"]=='R']
writeRpng=dirName/(fileName+"log2KR.png")
np.log2(dfR["Ratio H/L"]).hist().figure.savefig(writeRpng,bbox_inches = "tight")
print("writing Log2 H/L histogram to ... ")
print(writeKpng,writeRpng)
