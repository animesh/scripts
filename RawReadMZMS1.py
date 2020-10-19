#!pip3 install pandas --user
#!pip3 install pathlib --user
import sys
from pathlib import Path
if len(sys.argv)!=2:    sys.exit("REQUIRED: pandas, pathlib; tested with Python 3.8.5\n","USAGE: python RawReadMZMS1.py <path to folder containing profile.intensity0.charge0.MS.txt file(s) like \"Z:/RawRead/\" >")
pathFiles = Path(sys.argv[1])
#pathFiles = Path("C:/Users/animeshs/Desktop/RawRead")
fileName='20150512_BSA_The-PEG-envelope.raw.intensityThreshold1000.errTolDecimalPlace3.MZ1R.txt'
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
df['sumIntensity'].sum()
df['MZ'].hist(bins=10000)

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
