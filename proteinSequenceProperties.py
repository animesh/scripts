#..\python-3.11.0\python.exe proteinSequenceProperties.py
#setup####
#..\python-3.11.0\python.exe -m pip install biopython
from Bio.SeqUtils.ProtParam import ProteinAnalysis
#Extinction Coefficients
#Instability index
#Secondary structure of proteins
#Cysteine disulfide bonding state and connectivity prediction
#Protein-protein interaction
#data####
#inpF="L:/promec/Qexactive/LARS/2022/juli/toktam/PDv2p5/Beer/220706_toktam1_Proteins.txt.Abundance.Normalized..log2.csvSample14S1S20.0510.05ClassRemGroupsR1.txttTestBH.csv"
import pandas as pd
inpF="L:/promec/Qexactive/LARS/2022/juli/toktam/PDv2p5/Beer/220706_toktam1_Proteins.txt"
data=pd.read_csv(inpF,low_memory=False,sep='\t')
print(data.info())
data = data[data["Master"]=="IsMasterProtein"]
uniprot=data["Accession"]
protein=data["Description"]
print(data.info())
print(data["Sequence"][1])
protLen=(data["Sequence"]).str.len()
protMWkDa=data["MW in kDa"]
protPI=data["calc pI"]
protSeq=data["Sequence"]
seqIdx=protSeq.index
    #X.flexibility()
    #X.charge_at_pH(7.4)
protEC=[]
protII=[]
protSSh=[]
protSSt=[]
protSSs=[]
protAA=[]
cnt=0
for i in protSeq:
    print(cnt,seqIdx[cnt])
    cnt=cnt+1
    X = ProteinAnalysis(i.replace("X", "" ).replace("Z", ""))
    protEC.append(X.molar_extinction_coefficient()[0])
    protII.append(X.instability_index())
    protSSh.append(X.secondary_structure_fraction()[0])
    protSSt.append(X.secondary_structure_fraction()[1])
    protSSs.append(X.secondary_structure_fraction()[2])
    protAA.append(X.count_amino_acids())
dataAnno = pd.DataFrame(list(zip(uniprot,protein,protLen,protMWkDa,protPI,protEC,protII,protSSh,protSSt,protSSs,protAA)), columns = ['Uniprot', 'Protein','Length','MW in kDa','pI','Extinction Coefficient','Instability index','Helix','Turn','Sheet','Amino Acids'])
dataAnno.to_csv(inpF+"protparam.csv")
