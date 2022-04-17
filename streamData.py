#streamlit run streamData.py --server.headless true
import streamlit as st
st.set_page_config(page_title="IDH1 MUT WT control data")#,page_icon=img)
hide_menu_style = """
        <style>
        MainMenu {visibility: hidden; }
        footer {visibility: hidden;}
        </style>
        """
st.markdown(hide_menu_style, unsafe_allow_html=True)
import pandas as pd 
#@st.cache
df1=pd.read_csv("proteinGroups.txtLFQ.intensity.16MUTctrlWTctrl0.050.50.05grouptTestBH.csv")
#st.dataframe(df1, 700, 10)
#@st.cache
df2=pd.read_csv("proteinGroups.txtLFQ.intensity.16MUT CtrlWT Ctrl0.050.50.05BiotTestBH.csv")
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
term=st.text_input("GENE symbol?Like IDH1 for e.g. one can also combine multiple using | symbol", "IDH1|ASS1")
term=term.rsplit(' ', 1)[0]
term=term.strip()
#term="diarrhea"
#qMesh="https://id.nlm.nih.gov/mesh/lookup/descriptor?label="+term+"&match=exact&limit=1"
#import requests
#rMesh = requests.get(qMesh,headers={'user-agent':'Python'}).json()
#import matplotlib.pyplot as plt
if(len(term)>0):
  #qCTD="http://ctdbase.org/detail.go?type=disease&acc=MESH%3A"+rMesh[0].get('resource').rsplit('/', 1)[-1]
  #rCTD = requests.get(qCTD,headers={'user-agent':'Python'}).text
  #name=rCTD[rCTD.find("gridrow0"):rCTD.find("td")]
  sel1=df1[df1['Gene'].str.contains(str.upper(term))==True]
  st.write(sel1)
  sel1v=sel1.iloc[:,9:15].T
  sample1=sel1v.index.T
  sel1v.index=range(1,7)
  #st.write(sel1v)
  sel1v=sel1v.fillna(0)
  st.line_chart(sel1v)
  sel2=df2[df2['Gene'].str.contains(str.upper(term))==True]
  st.write(sel2)
  sel2v=sel2.iloc[:,9:15].T
  sample2=sel2v.index.T
  sel2v.index=range(1,7)
  sel2v=sel2v.fillna(0)
  st.line_chart(sel2v)
  st.write("Batch1 contains:",sample1)
  st.write("Batch2 contains:",sample2)
  #plt.plot(sel2.logFCmedianGrp1)

