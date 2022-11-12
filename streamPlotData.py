#streamlit run streamPlotData.py --server.headless true
import streamlit as st
#st.set_page_config(page_title="IDH1 MUT WT 24H TMZ*DMSO*data")#,page_icon=img)
#hide_menu_style = """<style>MainMenu {visibility: hidden; }footer {visibility: hidden;}</style>"""
#st.markdown(hide_menu_style, unsafe_allow_html=True)
import pandas as pd 
#@st.cache
df1=pd.read_csv("dataMM.csv", index_col=0)
#df1=df1.filter(like='Log2MedianChange').apply(pd.to_numeric)
#st.dataframe(df1, 700, 10)
#@st.cache
#st.dataframe(df2, 700, 10)
#import numpy as np
#from st_aggrid import GridOptionsBuilder, AgGrid, GridUpdateMode, DataReturnMode
#AgGrid(df1)
#def color_df(val):
#  if val > 14:    color = 'red'
#  else :   color = 'green'return f'background-color: {color}'
#from annotated_text import annotated_text
#annotated_text(("LFQ","#faa"))
st.write('<style>div.row-widget.stRadio > div{flex-direction:row;}</style>', unsafe_allow_html=True)
term=st.text_input("Uniprot IDs/GENE symbols?Like LAMP1 for e.g. one can also combine multiple using | symbol", "LAMP1|TFRC|Q9BXV9")
term=term.rsplit(' ', 1)[0]
term=term.strip()
#term="IDH1|ASS1"
#qMesh="https://id.nlm.nih.gov/mesh/lookup/descriptor?label="+term+"&match=exact&limit=1"
#import requests
#rMesh = requests.get(qMesh,headers={'user-agent':'Python'}).json()
#import matplotlib.pyplot as plt
if(len(term)>0):
  #qCTD="http://ctdbase.org/detail.go?type=disease&acc=MESH%3A"+rMesh[0].get('resource').rsplit('/', 1)[-1]
  #rCTD = requests.get(qCTD,headers={'user-agent':'Python'}).text
  #name=rCTD[rCTD.find("gridrow0"):rCTD.find("td")]
  sel1=df1[df1.index.str.contains(str.upper(term))==True]
  #st.write(sel1)
  sel1v=sel1.T
  #sel1v.hist()
  sample1=sel1v.index.T
  #sel1v.index=range(1,18)
  st.write(sel1v)
  sel1v=sel1v.fillna(0)
  #st.line_chart(sel1v)
  #plt.plot(sel2.logFCmedianGrp1)

import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
from matplotlib.cm import jet
fig = plt.figure()#figsize=(16, 12))
#ax = Axes3D(fig)
ax = plt.axes(projection='3d')
#print(type(ax))
sel1v['Group']=['MGUS','MGUS','MGUS','MGUS','MGUS','MGUS','MGUS','MGUS','MGUS','Ml','Ml','Ml','Ml','Ml','Ml','MM','MM','MM','MM','MM','MM','MM','MM','MM','MM','MM','MM','MM','MM','MM','MM','MM','MM','MM','MM','MM','MM','MM','MM','MM','MM','MM','MM','MM','MM','MM']
mapping = {'MGUS':'red','MM':'black','Ml':'green'}
sel1v=sel1v.replace({'Group': mapping})
x = sel1v.iloc[:,0]
y = sel1v.iloc[:,1]
z = sel1v.iloc[:,2]
c = sel1v['Group']
ax.scatter(x,y,z, c=c)#, cmap='coolwarm')
plt.title('Proteins log2SILAC 3D scatterplot')
ax.set_xlabel(sel1v.columns[0])
ax.set_ylabel(sel1v.columns[1])
ax.set_zlabel(sel1v.columns[2])
#create your figure and get the figure object returned
st.pyplot(fig)