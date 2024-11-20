#python checkIncorporationRate.py L:\promec\TIMSTOF\LARS\2024\241116_SILAC\combined\txt peptides.txt
print("peptide.txt output file to calculate the incorporation rate. Distinguish between lysine- and argininecontaining peptides. For each of these subsets determine the incorporation rate as 1–1/average ratio, using the non-normalized ratios. The density plot of the density distribution should be narrow, and for both lysine and arginine it should be above 0.95, Reference: Use of stable isotope labeling by amino acids in cell culture as a spike-in standard in quantitative proteomics https://www.nature.com/articles/nprot.2010.192")
import sys
from pathlib import Path

if len(sys.argv) != 3:
    dirName = Path("L:/promec/TIMSTOF/LARS/2024/241116_SILAC/combined/txt/")
    #fileName='proteinGroups.txt'
    fileName='peptides.txt'
    print("\n\nUSAGE: python checkIncorporationRate.py <path to folder containing",fileName,"file(s)>\n\nUsing DEFAULT directory\"", dirName, "\"looking for\"", fileName, "\"file(s)\n\n")
else:
    dirName = Path(sys.argv[1])
    fileName = sys.argv[2]
    print("Input:\"", dirName, "\"as directory, looking for\"", fileName, "\"\n\n")

trainList=list(dirName.rglob(fileName))
print("Using file(s)\n",trainList)

columnName='^(Ratio H/L) [0-9](.*)'#'*([0-9])$'
columnNameH='^(Intensity H)(.*)|(.*)(Light)$'#'*([0-9])$'
columnNameL='^(Intensity L)(.*)|(.*)(Heavy)$'#'*([0-9])$'
#f=trainList[0]
import pandas as pd
for i, f in enumerate(trainList):
    print("\n\nFile",i+1,f)
    df=pd.read_csv(f,low_memory=False,sep='\t')
    print(df.head())
    print(df.columns)
    df=df[df["Reverse"]!='+']
    df=df[df["Potential contaminant" ]!='+']
    #df=df[df[]!='+'|df["Contaminant"]!='TRUE']
    dfPG=df.filter(regex=columnName,axis=1)
    print(dfPG.columns)
    #dfPG=dfPG.rename(columns = lambda x : str(x)[10:])
    writePGCountcsv=f.with_suffix(".count.csv")
    dfPGcnt=dfPG.count()
    print(dfPGcnt)
    print("writing output to ... ")
    dfPGcnt.to_csv(writePGCountcsv,header=False)
    #dfPGcnt[dfPGcnt<max(dfPGcnt)].plot(kind='bar').figure.savefig(writePGCountcsv,bbox_inches = "tight")
    print(writePGCountcsv)
    dfPG=1-(1/dfPG.mean(axis = 0, skipna = True))
    writePGcsv=f.with_suffix(".IR.csv")
    dfPG.to_csv(writePGcsv,header=False)
    print(writePGcsv)
    #dfPG.hist()

    dfPGH=df.filter(regex=columnNameH,axis=1)
    dfPGH=dfPGH.rename(columns = lambda x : str(x)[12:])
    dfPGL=df.filter(regex=columnNameL,axis=1)
    dfPGL=dfPGL.rename(columns = lambda x : str(x)[12:])
    #dfPGH2Ldiff=dfPGH-dfPGL
    dfPGH2Lratio=(dfPGH+1)/(1+dfPGL)
    writePGtxt=f.with_suffix(".IRH2L.txt")
    dfPGH2Lratio.to_csv(writePGtxt,header=True,sep='\t')
    print(writePGtxt)


    dfPGH2LratioIR=1-(1/dfPGH2Lratio.mean(axis = 0, skipna = True))
    print(dfPGH2LratioIR)
    writePGcsv=f.with_suffix(".IRH2L.csv")
    dfPGH2LratioIR.to_csv(writePGcsv,header=False)
    print(writePGcsv)
    print("Overall\n",dfPG)
    import numpy as np
    if "Last amino acid" in df: dfK=df[df["Last amino acid"]=='K']
    if "Annotated Sequence" in df: dfK=df[df["Annotated Sequence"].str.contains('K')]
    writeKpng=f.with_suffix(".log2K.png")
    if "Ratio H/L" in dfK: np.log2(dfK["Ratio H/L"]).hist().figure.savefig(writeKpng,bbox_inches = "tight")
    dfPG=dfK.filter(regex=columnName,axis=1)
    dfPG=1-(1/dfPG.mean(axis = 0, skipna = True))
    writePGcsv=f.with_suffix(".K.IR.csv")
    dfPG.to_csv(writePGcsv,header=False)
    print("Lysine\n",dfPG)
    if "Last amino acid" in df: dfR=df[df["Last amino acid"]=='R']
    if "Annotated Sequence" in df: dfR=df[df["Annotated Sequence"].str.contains('R')]
    writeRpng=f.with_suffix(".log2KR.png")
    if "Ratio H/L" in dfR: np.log2(dfR["Ratio H/L"]).hist().figure.savefig(writeRpng,bbox_inches = "tight")
    print("writing Log2 H/L histogram to ... ")
    print(writeKpng,writeRpng)
    dfPG=dfR.filter(regex=columnName,axis=1)
    dfPG=1-(1/dfPG.mean(axis = 0, skipna = True))
    writePGcsv=f.with_suffix(".R.IR.csv")
    dfPG.to_csv(writePGcsv,header=False)
    print("Arginine\n",dfPG)
