import pandas as pd
import sys
from pathlib import Path
fileName = 'evidence.txt'
df.columns = df.columns.str.strip('_x')
# counting the peptideHits for each file, can change to other columns like "Sequence","Proteins"...
colStrName = ["Raw file","Proteins"]
if len(sys.argv) != 2:
    dirName = 'F:/promec/Elite/LARS/2018/november/Rolf final/txt/'
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

[print(df.columns.get_loc(colStrName)) for colStrName in colStrName]
#dfDP = df.loc[:, df.columns.str.startswith(colStrName)]
#dfDP = dfDP[dfDP[colStrName].notnull()]
#dfDP=dfDP.rename(columns = lambda x : str(x)[3:])
#dfDPcnt = dfDP[colStrName].value_counts()
#print(dfDPcnt)
dfDPcnt=pd.crosstab(df[colStrName[1]],df[colStrName[0]])
print("writing output to ... ")
writeEviData = pathFiles / (fileName + '.' + ''.join(colStrName) + ".csv").replace(" ", "")
dfDPcnt.to_csv(writeEviData, header=True)
print("writeEviData\n")
dfDPcnt=df.groupby(colStrName).size().reset_index(name="Counts")
dfDPcnt=dfDPcnt['Counts']
writeEviPlot = pathFiles / (fileName + '.' + ''.join(colStrName) + ".png").replace(" ", "")
dfDPcnt[dfDPcnt > 10].plot(kind='barh').figure.savefig(writeEviPlot, dpi=100, bbox_inches="tight")
print(writeEviPlot)
