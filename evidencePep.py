import pandas as pd
import sys
from pathlib import Path
fileName = 'evidence.txt'
# counting the peptideHits for each file, can change to other columns like "Sequence","Proteins"...
colStrName = "Proteins"
if len(sys.argv) != 2:
    dirName = 'F:/promec/Elite/LARS/2018/november/Rolf final/'
    print("\n\nUSAGE: python evidencePep.py <path to folder containing", fileName,
          "file(s)>\n\ntaking default directory\"", dirName, "\"looking for\"", fileName, "\"file(s)\n\n")
else:
    dirName = sys.argv[1]
    print("Input: ", dirName, "directory, \nlooking for", fileName, "\n\n")

pathFiles = Path(dirName)
trainList = list(pathFiles.rglob(fileName))
print("Found", trainList)

df = pd.DataFrame()
for f in trainList:
    peptideHits = pd.read_csv(f, low_memory=False, sep='\t')
    print("Processing", f)
    peptideHits['Name'] = f
    df = pd.concat([df, peptideHits], sort=False)
print(df.head())
print(df.columns)

print(df.columns.get_loc(colStrName))
dfDP = df.loc[:, df.columns.str.startswith(colStrName)]
dfDP = dfDP[dfDP[colStrName].notnull()]
#dfDP=dfDP.rename(columns = lambda x : str(x)[3:])
writeEviPlot = pathFiles / (fileName + colStrName + ".png")
dfDPcnt = dfDP[colStrName].value_counts()
print(dfDPcnt)

print("writing output to ... ")
dfDPcnt[dfDPcnt > 10].plot(kind='barh').figure.savefig(
    writeEviPlot, dpi=100, bbox_inches="tight")
print(writeEviPlot)

writeEviData = pathFiles / (fileName + colStrName + ".csv")
dfDPcnt.to_csv(writeEviData, header=False)
print(writeEviData)
