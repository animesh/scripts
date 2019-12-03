#pip install git+https://github.com/cox-labs/perseuspy.git
from perseuspy import pd#, nx, write_network
import sys
#_, n, m, outfolder = sys.argv
#G = nx.random_graphs.barabasi_albert_graph(int(n), int(m))
#networks_table, networks = nx.to_perseus([G])
#write_networks(outfolder, networks_table, networks)
from perseuspy.parameters import *
_, infile, outfile = sys.argv # read arguments from the command line
df = pd.read_perseus(infile) # read the input matrix into a pandas.DataFrame
#df2 = df.dropna()
df2 = df.head(10) # keep only the first 10 rows of the table
df2.to_perseus(outfile) # write pandas.DataFrame in Perseus txt format
