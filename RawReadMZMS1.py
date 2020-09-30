#!pip3 install pandas --user
#!pip3 install pathlib --user
import sys
from pathlib import Path
if len(sys.argv)!=2:    sys.exit("REQUIRED: pandas, pathlib; tested with Python 3.8.5\n","USAGE: python RawReadMZMS1.py <path to folder containing profile.intensity0.charge0.MS.txt file(s) like \"Z:/RawRead/\" >")
pathFiles = Path(sys.argv[1])
#pathFiles = Path("C:/Users/animeshs/RawRead")
fileName='*profile.intensity0.charge0.MS.txt'
trainList=list(pathFiles.rglob(fileName))
import pandas as pd
df=pd.DataFrame()
for f in trainList:
    peptideHits=pd.read_csv(f,low_memory=False,sep='\t')
    print(f)
    peptideHits['Name']=f
    df=pd.concat([df,peptideHits],sort=False)
print(df.tail())
print(df.columns)
df['intensity'].sum()
