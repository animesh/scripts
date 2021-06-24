#!/usr/bin/env python
#!pip3 install pathlib --user
import sys
from pathlib import Path
if len(sys.argv)!=3: sys.exit("\n\nREQUIRED: pandas, pathlib, tested with Python 3.7.9 \n\nUSAGE: python proteinGroups.py <path to folder containing proteinGroups.txt file(s) like \"L:\promec\Animesh\Samah\mqpar.xml.1623227664.results\" >\n\nExample\n\npython proteinGroupsCombine.py L:\promec\Animesh\Samah\mqpar.xml.1623227664.results")
pathFiles = Path(sys.argv[1])
columnID = sys.argv[2]
#pathFiles=inpD = Path.home()/'promec'/'promec'/'HF'/'Lars'/'2021'/'june'/'Siri2'/'combined'/'txt-old'
fileName='proteinGroups.txt'
trainList=list(pathFiles.rglob(fileName))
#!pip3 install pandas --user
#!conda activate py37
import pandas as pd
#df = pd.concat(map(pd.read_table, trainList))
#df.to_csv(pathFiles.with_suffix('.combinedT.txt'),sep="\t")#,rownames=FALSE)
inpF="proteinGroups.txt"
df = pd.read_table(inpD/inpF)
df.describe()
print(df.columns)
print(df.head())
#df=df.pivot(index='ID', columns='Name', values=columnID)
#df.to_csv(pathFiles.with_suffix('.combined.txt'),sep="\")#,rownames=FALSE)
print(df.head())
print(df.columns)
#writeDPpng=pathFiles/(fileName+"columnID.png")
#df.plot(kind='hist').figure.savefig(writeDPpng.absolute(),dpi=100,bbox_inches = "tight")
#print("Histogram of columnID in",writeDPpng)
df['Sum']=df.sum(axis=1)
df=df.sort_values('Sum',ascending=False)
writecolumnIDs=pathFiles/(fileName+"Combo.csv")
df.to_csv(writecolumnIDs)#.with_suffix('.combo.csv'))
print(columnID," in",writecolumnIDs)
#dfID=df.assign(ID=df.ID.str.split(';')).explode('ID')

import streamlit as st
@st.cache
def get_data():
    return pd.read_table('/home/animeshs/promec/promec/HF/Lars/2021/june/Siri2/combined/txt-old/proteinGroups.txt')
df = get_data()

makes = df['Protein IDs'].drop_duplicates()
make_choice = st.sidebar.selectbox('Select your vehicle:', makes)
years = df["year"].loc[df["make"] = make_choice]
year_choice = st.sidebar.selectbox('', years) 
