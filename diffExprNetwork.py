import sys
from pathlib import Path
if len(sys.argv)!=2:    sys.exit("REQUIRED: pandas, pathlib; tested with Python 3.8.5\n","USAGE: python diffExprNetwork.py <path to folder containing Formaldehyde_XL_Analyzer outouts like \"F:\20210118_8samples\QE\" >")
pathFiles = Path(sys.argv[1])
pathFiles = Path("F:\\20210118_8samples\\QE")
fileName='*.mq.txt'
trainList=list(pathFiles.rglob(fileName))
import pandas as pd
df=pd.read_csv(trainList[0],low_memory=False,header=None)
df = df[-df[0].str.startswith('Log:')]
df=df[0].str.split('\t', expand=True)
#df['Name']=sorted(df[0]+df[1])
df['Name']=df[0]+df[1]
df=df.set_index('Name')
#df=df.rename(columns={0:f})
#df=df.replace('^ ','',regex=True)
#df=df.fillna(value=' ')
testCSV=pathFiles/ 'xLink.csv'
df.to_csv(testCSV)
print(df.head())
print(df.columns)
for f in trainList:
    print(f)
    temp=pd.read_csv(trainList[0],low_memory=False,header=None)
    temp = temp[-temp[0].str.startswith('Log:')]
    temp=temp[0].str.split('\t', expand=True)
    temp['Name']=temp[0]+temp[1]
    temp=temp.set_index('Name')
    #temp.rename(columns={'0':f}, inplace=True)
    df=df.merge(temp,left_index=True, right_index=True,how='outer')
#df.fillna(0,inplace=True)
print(df.head())
print(df.columns)
testCSV=pathFiles/ 'xLinkComb.csv'
df.to_csv(testCSV)
#df=df.dropna()
#df=df.drop(columns=['Position'])
df=df.groupby(['From','To']).size().reset_index(name='Count')
df['Count']=df['Count']/df['Count'].sum()
#df['Count'].hist()
import networkx as nx
#g=nx.from_pandas_edgelist(df,'From','To',edge_attr=True)
g=nx.from_pandas_edgelist(df,'From','To',edge_attr='Count',create_using=nx.DiGraph())
g.edges()
values = [g.nodes()]
from matplotlib import pyplot as plt
#nx.draw(g, cmap=plt.get_cmap('viridis'), with_labels=True, font_color='white')
#nx.draw(g,with_labels=True,node_size=1000,alpha=0.4,arrows=True,node_color="skyblue",node_shape="o",linewidths=4,font_size=12,font_color="#333333",font_weight="bold",width=4,edge_color="grey",style="solid",pos=nx.spring_layout(g))
nx.draw(g,with_labels=True,node_size=1000,alpha=0.5,arrows=True,node_color="skyblue",node_shape="o",font_size=16,font_color="#333333",font_weight="bold",edge_color="grey",style="solid",pos=nx.circular_layout(g))
plt.savefig(path+"GraphX.png", format="PNG")
plt.show()
#nx.draw_networkx(nx.minimum_spanning_tree(g))
