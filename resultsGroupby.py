#!/usr/bin/env python
#!pip3 install pathlib --user
import sys
if len(sys.argv)!=3: sys.exit("\n\nREQUIRED: pandas! Tested with Python 3.7.9 \n\nUSAGE: python resultsGroupby.py <path to file of interest like \"L:\promec\mqpar.xml.1623227664.results\combined\txt\proteinGroupsCombine.py> <column of interest like \"Score\"\n\n")
#python resultsGroupby.py "L:\promec\USERS\Synnøve\20210709_Synnove_6samples\HF\combined\txt\msmsScans.txt" "Raw file"
inpF = sys.argv[1]
columnID = sys.argv[2]
#inpF = "L:\\promec\\USERS\\Synnøve\\20210709_Synnove_6samples\\HF\\combined\\txt\\msmsScans.txt"
#columnID = "Raw file"
import pandas as pd
df = pd.read_table(inpF)
df.describe()
print(df.columns)
print(df.head())
#print(df.info())
dfC=df.groupby(columnID).count()
print(dfC)
outFc=inpF+columnID+"count.csv"
dfC.to_csv(outFc)#.with_suffix('.combo.csv'))
print(outFc)
outFc=inpF+columnID+"count.png"
dfC.iloc[:,1].plot(kind="barh").figure.savefig(outFc,dpi=100,bbox_inches = "tight")
#plt.close()
print(outFc)
dfS=df.groupby(columnID).sum()
#dfR=df.pivot(index='Sequence', columns=columnID, values='Score')
#df.to_csv(pathFiles.with_suffix('.combined.txt'),sep="\")#,rownames=FALSE)
#writeDPpng=pathFiles/(fileName+"columnID.png")
#df.plot(kind='hist').figure.savefig(writeDPpng.absolute(),dpi=100,bbox_inches = "tight")
#print("Histogram of columnID in",writeDPpng)
#df['Sum']=df.sum(axis=1)
#df=df.sort_values('Sum',ascending=False)
#writecolumnIDs=pathFiles/(fileName+"Combo.csv")
#df.to_csv(writecolumnIDs)#.with_suffix('.combo.csv'))
#print(columnID," in",writecolumnIDs)
#dfID=df.assign(ID=df.ID.str.split(';')).explode('ID')

#import streamlit as st
#@st.cache
#def get_data():
#    return pd.read_table('/home/animeshs/promec/promec/HF/Lars/2021/june/Siri2/combined/txt-old/#proteinGroups.txt')
#df = get_data()
#makes = df['Protein IDs'].drop_duplicates()
#make_choice = st.sidebar.selectbox('Select your vehicle:', makes)
#years = df["year"].loc[df["make"] = make_choice]
#year_choice = st.sidebar.selectbox('', years) 
