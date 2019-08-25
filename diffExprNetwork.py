#https://towardsdatascience.com/data-scientists-the-five-graph-algorithms-that-you-should-know-30f454fa5513
#edgelist = [['Mannheim', 'Frankfurt', 85], ['Mannheim', 'Karlsruhe', 80], ['Erfurt', 'Wurzburg', 186], ['Munchen', 'Numberg', 167], ['Munchen', 'Augsburg', 84], ['Munchen', 'Kassel', 502], ['Numberg', 'Stuttgart', 183], ['Numberg', 'Wurzburg', 103], ['Numberg', 'Munchen', 167], ['Stuttgart', 'Numberg', 183], ['Augsburg', 'Munchen', 84], ['Augsburg', 'Karlsruhe', 250], ['Kassel', 'Munchen', 502], ['Kassel', 'Frankfurt', 173], ['Frankfurt', 'Mannheim', 85], ['Frankfurt', 'Wurzburg', 217], ['Frankfurt', 'Kassel', 173], ['Wurzburg', 'Numberg', 103], ['Wurzburg', 'Erfurt', 186], ['Wurzburg', 'Frankfurt', 217], ['Karlsruhe', 'Mannheim', 80], ['Karlsruhe', 'Augsburg', 250],["Mumbai", "Delhi",400],["Delhi", "Kolkata",500],["Kolkata", "Bangalore",600],["TX", "NY",1200],["ALB", "NY",800]]
#wget https://stringdb-static.org/download/protein.links.v11.0/9606.protein.links.v11.0.txt.gz
import pathlib as path
print(path.Path.cwd())

import pandas as pd
df = pd.read_csv(path.Path.cwd()/'9606.protein.links.v11.0.txt.gz',delimiter="\s+")
print(df.head())
df['combined_score'].hist()

import networkx as nx
#g = nx.Graph()
g = nx.random_graphs.barabasi_albert_graph(int(len(edgelist)), len(edgelist[0]))
g=nx.from_pandas_edgelist(df=df, source=df['protein1'], target=df['protein2'], edge_attr=df['combined_score'])
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
12|ensembl_havana|CDS|109098327|109098638|.|+|0|gene_id 0       12      109098327       60     376S312M *       0       0       NANNCNNNTNNNNNNNNTNNNNNNNNNNNNNNTNANNCNNNTNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNGNNNNNANNNNNNGNNNGNNNNNNNNCNNNNNNNNNNNNANANANNNGNNNNNNNTNNNNNNNNTNNNNCNNNNGNNNTNANNCNNNTNNANNNNNNG[main] Version: 0.7.12-r1039
[main] CMD: bwa mem -M -t 8 Homo_sapiens.GRCh38.dna.primary_assembly UNG.t1.fa
[main] Real time: 118.668 sec; CPU: 41.895 sec
animeshs@dmed6942:~/scripts$
animeshs@dmed6942:~/scripts$ less UNG.t1.fa
>12|ensembl_havana|CDS|109098327|109098638|.|+|0|gene_id "ENSG00000076248"; gene_version "10"; t
ranscript_id "ENST00000336865"; transcript_version "6"; exon_number "1"; gene_name "UNG"; gene_s
ource "ensembl_havana"; gene_biotype "protein_coding"; transcript_name "UNG-202"; transcript_sou
rce "ensembl_havana"; transcript_biotype "protein_coding"; tag "CCDS"; ccds_id "CCDS9125"; prote
in_id "ENSP00000337398"; protein_version "2"; tag "basic"; transcript_support_level "1";
ATGGGCGTCTTCTGCCTTGGGCCGTGGGGGTTGGGCCGGAAGCTGCGGACGCCTGGGAAGGGGCCGCTGCAGCTCTTGAGCCGCCTCTGCGGGGAC
CACTTGCAGGCCATCCCAGCCAAGAAGGCCCCGGCTGGGCAGGAGGAGCCTGGGACGCCGCCCTCCTCGCCGCTGAGTGCCGAGCAGTTGGACCGG
ATCCAGAGGAACAAGGCCGCGGCCCTGCTCAGACTCGCGGCCCGCAACGTGCCCGTGGGCTTTGGAGAGAGCTGGAAGAAGCACCTCAGCGGGGAG
TTCGGGAAACCGTATTTTATCAAG
"""
