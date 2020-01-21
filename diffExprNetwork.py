import pandas as pd
path='F:/HeLa/edgelist.csv'
df = pd.read_csv(path)
print(df.head())
df=df.dropna()
df=df.drop(columns=['Position'])
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
