#python diffExprStringify.py "L:\promec\TIMSTOF\LARS\2025\250805_Kamila\DIANNv2p2\report rq.ha..gg_matrix.tsv4118ISNS0.10.50.1BioRemGroups.txt4LFQvsntTestBH.csv" Log2MedianChange PValueMinusLog10 
import pandas as pd
import numpy as np
import sys
fileName=sys.argv[1]
#fileName="L:\\promec\\TIMSTOF\\LARS\\2025\\250805_Kamila\\DIANNv2p2\\report rq.ha..gg_matrix.tsv4118ISNS0.10.50.1BioRemGroups.txt4LFQvsntTestBH.csv"
Log2MedianChange=sys.argv[2]
#Log2MedianChange="Log2MedianChange"
PValueMinusLog10=sys.argv[3]
#PValueMinusLog10="PValueMinusLog10"
data=pd.read_csv(fileName)
data["signLog2FCminuslog10pValue"]=np.sign(data[Log2MedianChange])*data[PValueMinusLog10]
data=data[data["signLog2FCminuslog10pValue"].notna()]
data[["Gene","signLog2FCminuslog10pValue"]].to_csv(fileName+"stringInput.tsv",sep="\t",index=False,header=False)
print("Output: "+fileName+"stringInput.tsv")
