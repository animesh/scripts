#https://towardsdatascience.com/data-scientists-the-five-graph-algorithms-that-you-should-know-30f454fa5513https://notebooks.ai/maticaputti/an-intro-to-network-diagrams-graphs-using-networkx-086ef6f2
#https://colab.research.google.com/github/google/nucleus/blob/master/nucleus/examples/dna_sequencing_error_correction.ipynb#scrollTo=Vqk2BEXxemv9
#https://www.slideshare.net/GenomeInABottle/giab-for-jax-long-read-190917?next_slideshow=1
edgelist = [["Pro","Ala",6],["Ser","Ala",242],["Glu","Ala",468],["Ser","Ala",242],["Ser","Ala",2],["Ser","Ala",242],["Glu","Ala",468],["Val","Ala",263],["Val","Ala",130],["Glu","Ala",468],["Glu","Ala",468],["Val","Ala",576],["Glu","Ala",1247],["Ser","Ala",242],["Ser","Ala",242],["Val","Ala",576],["Thr","Ala",94],["Glu","Ala",468],["Glu","Ala",468],["Glu","Ala",468],["Glu","Ala",468],["Glu","Ala",468],["Glu","Ala",468],["Glu","Ala",468],["Ser","Ala",242],["Ser","Ala",242],["Val","Ala",314],["Glu","Ala",468],["Ser","Ala",242],["Glu","Ala",468],["Asp","Ala",5],["Ser","Ala",242],["Glu","Ala",468],["Val","Ala",10],["Val","Ala",10],["Glu","Ala",468],["Glu","Ala",468],["Thr","Ala",1482],["Glu","Ala",468],["Ser","Ala",256],["Ser","Ala",242],["Glu","Ala",468],["Ser","Ala",242],["Glu","Ala",468],["Glu","Ala",468],["Ser","Ala",242],["Glu","Ala",468],["His","Arg",1322],["Lys","Arg",372],["His","Arg",1322],["His","Arg",1322],["Ser","Arg",231],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["Ser","Arg",231],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["Lys","Arg",372],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["Ser","Arg",231],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["Leu","Arg",108],["His","Arg",1322],["Ser","Arg",231],["Lys","Arg",587],["His","Arg",1322],["Gly","Arg",229],["His","Arg",1322],["His","Arg",276],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["Ser","Arg",231],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["Ser","Arg",231],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["Lys","Arg",372],["Ser","Arg",231],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["Ser","Arg",231],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["Gly","Arg",156],["His","Arg",1322],["Gln","Arg",701],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["Ser","Arg",231],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["Lys","Arg",372],["Thr","Arg",13],["His","Arg",1322],["Gly","Arg",8],["His","Arg",1322],["Lys","Arg",372],["His","Arg",1322],["Lys","Arg",372],["His","Arg",1322],["Gln","Arg",807],["Ser","Arg",231],["Gly","Arg",584],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["Gln","Arg",13],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["Ser","Arg",231],["Gln","Arg",949],["His","Arg",1322],["His","Arg",1322],["Leu","Arg",33],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["Ser","Arg",231],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["Lys","Arg",372],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["His","Arg",1322],["Cys","Arg",40],["Lys","Arg",372],["Lys","Asn",393],["Ser","Asn",492],["Asp","Asn",292],["Ser","Asn",492],["Ser","Asn",492],["Ser","Asn",235],["Ser","Asn",492],["Lys","Asn",31],["Ser","Asn",492],["Lys","Asn",202],["Ser","Asn",492],["Lys","Asn",478],["Asp","Asn",256],["Lys","Asn",1121],["Ser","Asn",492],["Ser","Asn",492],["Glu","Asp",764],["Asn","Asp",54],["Glu","Asp",86],["Glu","Asp",764],["Tyr","Asp",1501],["Glu","Asp",211],["Gly","Asp",256],["Glu","Asp",764],["Ser","Cys",761],["Arg","Cys",1705],["Ser","Cys",186],["Pro","Gln",130],["Glu","Gln",3],["Leu","Gln",1409],["Leu","Gln",1882],["Arg","Gln",48],["Leu","Gln",16],["Glu","Gln",50],["Arg","Gln",208],["Arg","Gln",1101],["Arg","Gln",275],["Lys","Gln",109],["Asp","Glu",490],["Lys","Glu",3217],["Lys","Glu",3217],["Lys","Glu",3217],["Lys","Glu",3217],["Lys","Glu",3217],["Lys","Glu",3217],["Lys","Glu",3217],["Val","Glu",154],["Val","Glu",210],["Lys","Glu",3217],["Asp","Glu",490],["Lys","Glu",3217],["Lys","Glu",3217],["Lys","Glu",3217],["Lys","Glu",3217],["Lys","Glu",3217],["Lys","Glu",3217],["Gly","Glu",607],["Lys","Glu",3217],["Lys","Glu",3217],["Lys","Glu",3217],["Lys","Glu",3217],["Lys","Glu",3217],["Lys","Glu",3217],["Lys","Glu",3217],["Lys","Glu",3217],["Lys","Glu",3217],["Lys","Glu",427],["Lys","Glu",3217],["Lys","Glu",3217],["Lys","Glu",3217],["Lys","Glu",3217],["Lys","Glu",3217],["Lys","Glu",3217],["Lys","Glu",3217],["Lys","Glu",3217],["Lys","Glu",3217],["Lys","Glu",3217],["Lys","Glu",3217],["Lys","Glu",3217],["Lys","Glu",3217],["Lys","Glu",3217],["Lys","Glu",3217],["Lys","Glu",3217],["Lys","Glu",3217],["Lys","Glu",3217],["Asp","Glu",513],["Glu","Gly",1771],["Glu","Gly",540],["Glu","Gly",707],["Val","Gly",146],["Ser","Gly",136],["Val","Gly",146],["Asp","Gly",128],["Val","Gly",146],["Arg","Gly",11],["Val","Gly",146],["Val","Gly",146],["Val","Gly",297],["Ser","Gly",82],["Val","Gly",146],["Asp","Gly",953],["Val","Gly",146],["Asp","Gly",809],["Arg","Gly",67],["Glu","Gly",50],["Val","Gly",146],["Val","Gly",146],["Asp","Gly",73],["Val","Gly",146],["Gln","His",333],["Leu","His",718],["Val","Ile",102],["Thr","Ile",1603],["Thr","Ile",614],["Met","Ile",631],["Asn","Ile",104],["Thr","Ile",1603],["Thr","Ile",1603],["Val","Ile",120],["Thr","Ile",1603],["Val","Ile",645],["Val","Ile",645],["Val","Ile",131],["Thr","Ile",1603],["Thr","Ile",1603],["Asn","Ile",667],["Thr","Ile",1603],["Val","Ile",1646],["Thr","Ile",453],["Val","Ile",2338],["Phe","Ile",167],["Thr","Ile",1603],["Lys","Ile",252],["Thr","Ile",1603],["Thr","Ile",1603],["Thr","Ile",1603],["Gln","Leu",582],["Ser","Leu",293],["Ser","Leu",293],["Val","Leu",3887],["Arg","Leu",215],["Ser","Leu",293],["Ile","Leu",420],["Ser","Leu",293],["Arg","Leu",42],["Val","Leu",713],["Gln","Leu",541],["Val","Leu",148],["Val","Leu",126],["Pro","Leu",358],["Ser","Leu",293],["Ser","Leu",293],["Phe","Leu",230],["Val","Leu",563],["Ile","Leu",442],["Ser","Leu",293],["Val","Leu",24],["Phe","Leu",311],["Arg","Lys",297],["Glu","Lys",352],["Arg","Lys",49],["Glu","Lys",531],["Thr","Lys",222],["Glu","Lys",42],["Glu","Lys",62],["Arg","Lys",297],["Glu","Lys",128],["Arg","Lys",297],["Asn","Lys",98],["Ile","Lys",59],["Arg","Lys",297],["Asn","Lys",232],["Glu","Lys",271],["Glu","Lys",554],["Arg","Lys",297],["Gln","Lys",536],["Glu","Lys",476],["Gln","Lys",3003],["Ile","Met",113],["Arg","Met",688],["Leu","Met",303],["Lys","Met",663],["Leu","Met",303],["Leu","Met",303],["Arg","Met",9],["Thr","Met",5],["Leu","Met",303],["Val","Met",355],["Val","Met",172],["Leu","Met",303],["Val","Met",1502],["Thr","Met",2866],["Thr","Met",1070],["Val","Phe",312],["Val","Phe",480],["Leu","Phe",796],["Ile","Phe",60],["Leu","Phe",1866],["Ser","Phe",204],["Cys","Phe",1214],["Ser","Phe",789],["Ala","Pro",135],["Ala","Pro",5],["Ala","Pro",5],["Gln","Pro",337],["Ala","Pro",5],["Thr","Pro",4],["Gln","Pro",337],["Leu","Pro",621],["Gln","Pro",337],["Ala","Pro",777],["Gln","Pro",337],["Gln","Pro",337],["Ala","Pro",5],["Pro","Ser",415],["Asn","Ser",464],["Asn","Ser",71],["Pro","Ser",415],["Pro","Ser",415],["Pro","Ser",415],["Gly","Ser",51],["Pro","Ser",415],["Pro","Ser",415],["Gly","Ser",51],["Phe","Ser",430],["Gly","Ser",51],["Gly","Ser",51],["Asn","Ser",71],["Gly","Ser",51],["Pro","Ser",415],["Pro","Ser",415],["Pro","Ser",415],["Pro","Ser",415],["Pro","Ser",123],["Pro","Ser",415],["Pro","Ser",415],["Pro","Ser",415],["Gly","Ser",51],["Gly","Ser",51],["Gly","Ser",51],["Gly","Ser",43],["Cys","Ser",382],["Pro","Ser",415],["Pro","Ser",415],["Pro","Ser",415],["Pro","Ser",415],["Gly","Ser",51],["Gly","Ser",51],["Gly","Ser",51],["Gly","Ser",51],["Asn","Ser",1694],["Pro","Ser",415],["Pro","Ser",415],["Gly","Ser",51],["Leu","Ser",62],["Pro","Ser",415],["Pro","Ser",415],["Pro","Ser",415],["Pro","Ser",415],["Arg","Ser",148],["Ala","Ser",40],["Pro","Ser",415],["Gly","Ser",51],["Gly","Ser",51],["Pro","Ser",415],["Gly","Ser",51],["Pro","Ser",415],["Pro","Ser",415],["Ile","Thr",166],["Ile","Thr",166],["Ile","Thr",166],["Lys","Thr",12],["Ala","Thr",9],["Ala","Thr",336],["Ser","Thr",199],["Pro","Thr",85],["Ile","Thr",166],["Met","Thr",21],["Ser","Thr",345],["Ser","Thr",739],["Ser","Thr",336],["Ile","Thr",166],["Arg","Trp",1139],["Leu","Trp",247],["Ser","Trp",149],["Cys","Tyr",561],["Asn","Tyr",549],["Cys","Tyr",28],["His","Tyr",371],["Met","Val",596],["Ile","Val",436],["Ala","Val",610],["Ile","Val",10],["Asp","Val",279],["Ala","Val",513],["Phe","Val",248],["Ile","Val",436],["Ala","Val",55],["Ile","Val",334],["Gly","Val",634],["Ile","Val",1037],["Ala","Val",1122],["Met","Val",323],["Glu","Val",327],["Phe","Val",242],["Asp","Val",197],["Ile","Val",105],["Ile","Val",105]]
#import pathlib as path
#print(path.Path.cwd())
import pandas as pd
#df = pd.read_csv(path.Path.cwd()/'9606.protein.links.v11.0.txt.gz',delimiter="\s+")
df = pd.read_csv('F:/HeLa/edgelist.csv')
print(df.head())
df['Position'].hist()
import networkx as nx
#g = nx.Graph()
#g=nx.random_graphs.barabasi_albert_graph(int(len(edgelist)), len(edgelist[0]))
#g=nx.from_pandas_edgelist(df=df, source=df['protein1'], target=df['protein2'], edge_attr=df['combined_score'])
import matplotlib.pyplot as plt
g=nx.from_pandas_edgelist(df=df, source=df['From'], target=df['To'], edge_attr=df['Position'],create_using=nx.DiGraph())
g.edges()
values = [g.nodes()]
nx.draw(g, cmap=plt.get_cmap('viridis'), with_labels=True, font_color='white')
from matplotlib import pyplot as plt
plt.figure()
nx.draw(g,with_labels=True,node_size=1000,alpha=0.5,arrows=True,node_color="skyblue",node_shape="o",linewidths=4,font_size=16,font_color="#333333",font_weight="bold",width=4,edge_color="grey",style="solid")#,pos=nx.circular_layout(g))
nx.draw(nx.spring_layout(g), with_labels=True, node_size=500, alpha=0.3, arrows=True)
plt.savefig("GraphX.png", format="PNG")
#nx.draw_networkx(nx.minimum_spanning_tree(g))
nx.draw_networkx(nx.draw_networkx_edges(g))
for edge in edgelist:
    g.add_edge(edge[0],edge[1], weight = edge[2])
for i, x in enumerate(nx.connected_components(g)):
    print("cc"+str(i)+":",x)
for x in nx.all_pairs_dijkstra_path(g,weight='weight'):
    print(x)
nx.draw_networkx(nx.minimum_spanning_tree(g))
fb = nx.read_edgelist(df['protein1'], create_using = nx.Graph(), nodetype = int)
pos = nx.spring_layout(fb)
import warnings
warnings.filterwarnings('ignore')
plt.style.use('fivethirtyeight')
plt.rcParams['figure.figsize'] = (20, 15)
plt.axis('off')
nx.draw_networkx(fb, pos, with_labels = False, node_size = 35)
plt.show()

pageranks = nx.pagerank(fb)
print(pageranks)

import operator
sorted_pagerank = sorted(pagerank.items(), key=operator.itemgetter(1),reverse = True)
print(sorted_pagerank)

first_degree_connected_nodes = list(fb.neighbors(3437))
second_degree_connected_nodes = []
for x in first_degree_connected_nodes:
    second_degree_connected_nodes+=list(fb.neighbors(x))
second_degree_connected_nodes.remove(3437)
second_degree_connected_nodes = list(set(second_degree_connected_nodes))
subgraph_3437 = nx.subgraph(fb,first_degree_connected_nodes+second_degree_connected_nodes)
pos = nx.spring_layout(subgraph_3437)
node_color = ['yellow' if v == 3437 else 'red' for v in subgraph_3437]
node_size =  [1000 if v == 3437 else 35 for v in subgraph_3437]
plt.style.use('fivethirtyeight')
plt.rcParams['figure.figsize'] = (20, 15)
plt.axis('off')
nx.draw_networkx(subgraph_3437, pos, with_labels = False, node_color=node_color,node_size=node_size )
plt.show()

pos = nx.spring_layout(subgraph_3437)
betweennessCentrality = nx.betweenness_centrality(subgraph_3437,normalized=True, endpoints=True)
node_size =  [v * 10000 for v in betweennessCentrality.values()]
plt.figure(figsize=(20,20))
nx.draw_networkx(subgraph_3437, pos=pos, with_labels=False,
                 node_size=node_size )
plt.axis('off')

"""
#wget https://stringdb-static.org/download/protein.links.v11.0/9606.protein.links.v11.0.txt.gz
