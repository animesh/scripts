import sys
from pathlib import Path
if len(sys.argv)!=2:    sys.exit("REQUIRED: pandas, pathlib; tested with Python 3.8.5\n","USAGE: python RawReadMZMS1.py <path to folder containing profile.intensity0.charge0.MS.txt file(s) like \"Z:/RawRead/\" >")
pathFiles = Path(sys.argv[1])
pathFiles = Path("L:/promec/Animesh/RawRead")
fileName='20150512_BSA_The-PEG-envelope.raw.intensityThreshold1000.PPM10.errTolDecimalPlace3.Time20201022145302.MZ1R.csv'
trainList=list(pathFiles.rglob(fileName))
import pandas as pd
df=pd.DataFrame()
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

#source https://github.com/jdrudolph/perseuspy
import sys
from perseuspy import pd
from perseuspy.parameters import *
_, paramfile, infile, outfile = sys.argv # read arguments from the command line
parameters = parse_parameters(paramfile) # parse the parameters file
df = pd.read_perseus(infile) # read the input matrix into a pandas.DataFrame
some_value = doubleParam(parameters, 'some value') # extract a parameter value
df2 = some_value / df.drop('Name', 1)
df2.to_perseus(outfile) # write pandas.DataFrame in Perseus txt format

import sys
from perseuspy import nx, pd, read_networks, write_networks
_, paramfile, infolder, outfolder = sys.argv # read arguments from the command line
networks_table, networks = read_networks(infolder) # networks in tabular form
graphs = nx.from_perseus(networks_table, networks) # graphs as networkx objects
_networks_table, _networks = nx.to_perseus(graphs) # convert back into tabular form
write_networks(tmp_dir, networks_table, networks) # write to folder

import pandas as pd
data = pd.read_table("C:/Users/animeshs/OneDrive - NTNU/OneDrive - NTNU/Jimita/txt48/proteinGroups.txt",sep='\t', index_col=0, header=0, lineterminator='\n')
data.head()


%matplotlib inline
import matplotlib.pyplot as plt
import numpy as np
dataLFQlog2=np.log2(dataLFQ+1)
dataLFQlog2.hist()

label = pd.read_table("C:/Users/animeshs/OneDrive - NTNU/OneDrive - NTNU/Jimita/txt48/Groups.txt",sep='\t', index_col=0, header=0, lineterminator='\n')
label

prot=dataLFQlog2.rename(columns=lambda x: x.replace('LFQ intensity ','')).transpose()
#prot=pd.merge(prot,label,left_on=['Protein IDs'],right_on=['Name'],how='outer')
prot=pd.merge(prot,label,left_index=True, right_index=True)
#prot=pd.concat([label,prot])
#prot.index
#label.index
prot.head(2)

prot.loc[(prot['Category'] == 'EVexo') | (prot['Category'] == 'NPNTexo')]

prot[prot>0].loc[prot['Category'] == 'EVexo'].sum()

list(prot)[1]


testID=list(prot)
from ipywidgets import interactive
def f(m):
    ID=list(prot)[1]
    prot[prot>m].groupby(['Category']).median().hist()
interactive_plot = interactive(f, m=(0, 30))
output = interactive_plot.children[-1]
output.layout.height = '350px'
interactive_plot
