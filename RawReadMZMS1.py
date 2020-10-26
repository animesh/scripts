#!pip3 install pandas --user
#!pip3 install pathlib --user
import sys
from pathlib import Path
if len(sys.argv)!=2:    sys.exit("REQUIRED: pandas, pathlib; tested with Python 3.8.5\n","USAGE: python RawReadMZMS1.py <path to folder containing profile.intensity0.charge0.MS.txt file(s) like \"Z:/RawRead/\" >")
pathFiles = Path(sys.argv[1])
pathFiles = Path("L:/promec/Animesh/RawRead")
fileName='20150512_BSA_The-PEG-envelope.raw.intensityThreshold1000.PPM10.errTolDecimalPlace3.Time20201022145302.MZ1R.csv'
trainList=list(pathFiles.rglob(fileName))
import pandas as pd
df=pd.DataFrame()
for f in trainList:
    peptideHits=pd.read_csv(f,low_memory=False)
    print(f)
    peptideHits['Name']=f
    df=pd.concat([df,peptideHits],sort=False)
print(df.tail())
print(df.columns)
df['sumIntensity'].sum()
#df['MZ1'].hist(bins=1000)
#df['log2sumIntensity'].hist(bins=10000)
import numpy as np
import scipy.spatial.distance
df=df[df['log2sumIntensity']>20]
mz1=np.array(df['MZ1']).reshape(-1, 1)
dataD = np.int32(scipy.spatial.distance.pdist(mz1, 'euclidean'))
np.min(dataD)
np.max(dataD)
#plt.hist(dataD)
binD=np.zeros(np.max(dataD)+1)
binD[np.max(dataD)]
for i in range(dataD.size):
        binD[dataD[i]]+=1
import matplotlib.pyplot as plt
plt.hist(binD,bins=1000)
binDfft=np.fft.fft(binD)
binDfft.shape
plt.plot(binDfft[100:1000])
binDfftPos=np.where(binDfft>20000000)
np.size(binDfftPos)
plt.hist(binDfftPos[10:1000])
binDfft[np.where(binDfft>9000000)]
import matplotlib.pyplot as plt
df=pd.read_('F:/promec/Animesh/hmdb_metabolites/hmdb_metabolites.xml')
import xml.etree.ElementTree as et
#https://medium.com/@robertopreste/from-xml-to-pandas-dataframes-9292980b1c1c
xtree = et.parse("F:/promec/Animesh/hmdb_metabolites/hmdb_metabolites.xml")
xroot.getElementsByTagName('metabolite')
cnt=0
for elem in xroot:
    if(cnt<10):
        cnt=cnt+1
        for subelem in elem:
            print(subelem.attrib.get("hmdb_metabolites"))
xroot = xtree.getroot()
xtree.findtext
cnt=0
for node in xroot:
    if(cnt<10):
        cnt=cnt+1
        s_name = node.attrib.get("monisotopic_molecular_weight")
        s_name = node.find("monisotopic_molecular_weight").text#node.attrib.get("metabolites")
        print(s_name)
#    s_mail = node.find("email").text
#    s_grade = node.find("grade").text
#    s_age = node.find("age").text
df=pd.read_csv('L:/promec/Qexactive/LARS/2020/september/PSO_201005_fraksjonFTcation_URT1.raw.profile.intensity0.charge0.MS.txt_dataagg7lMaxF.csv',low_memory=False,index_col="MZ")
for f in trainList:
    print(f)
    temp=pd.read_csv(f,low_memory=False,index_col="MZ")
    temp.rename(columns={'dataAnionAgg7lMax':f}, inplace=True)
    df=df.merge(temp,left_index=True, right_index=True,how='outer')
df.fillna(0,inplace=True)
print(df.head())
print(df.columns)
testCSV=pathFiles/ 'mz1coll.csv'
df.to_csv(testCSV)
