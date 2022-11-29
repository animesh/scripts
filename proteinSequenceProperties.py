#..\python-3.11.0\python.exe proteinSequenceProperties.py
#setup####
#..\python-3.11.0\python.exe -m pip install biopython
#Extinction Coefficients
#Instability index
#Secondary structure of proteins
#Cysteine disulfide bonding state and connectivity prediction
#Protein-protein interaction
#data####
#F:\promec\FastaDB\barleyAlphaendornavirusIsoAug22.fasta</fastaFilePath>
#F:\promec\FastaDB\barleyDomesticatedIsoAug22.fasta</fastaFilePath>
#F:\promec\FastaDB\barleyIsoAug22.fasta</fastaFilePath>
#from Bio import SeqIO
#record_dict = SeqIO.to_dict(SeqIO.parse("L:/promec/FastaDB/barleyAlphaendornavirusIsoAug22.fasta", "fasta"))
#print(record_dict)  # use any record ID
#print(record_dict["gi:12345678"])  # use any record ID
from Bio.SeqUtils.ProtParam import ProteinAnalysis
import pandas as pd
inpF="L:/promec/TIMSTOF/LARS/2022/august/220819 Toktam/combined/txt/proteinGroups.txtLFQ.intensity.16S1S30.050.50.05SampleRemGroups.txttTestBH.csv"
data=pd.read_csv(inpF,low_memory=False)
print(data.info())
#print(data["Uniprot"][0])
#data = data[data["Master"]=="IsMasterProtein"]
import requests
#https://rest.uniprot.org/uniprotkb/A0A060IFB9.fasta
#https://www.uniprot.org/help/api_queries
#url = 'https://rest.uniprot.org/uniprotkb/stream?format=fasta&query=%28accession%3'
url='https://rest.uniprot.org/uniprotkb/'
uniprot=data["Uniprot"]
protein=data["RowGeneUniProtScorePeps"]
protEC=[]
protII=[]
protSSh=[]
protSSt=[]
protSSs=[]
protAA=[]
protLen=[]
protSeq=[]
protMWkDa=[]
protPI=[]
cnt=0
import re
for i in uniprot:
    #i=uniprot[1613]
    cnt=cnt+1
    print(cnt,uniprot[cnt-1])
    fasta=url+i+'.fasta'
    all_fastas = requests.get(fasta).text
    if "Error" in all_fastas:
        protSeq.append("")
        protLen.append("")
        protMWkDa.append("")
        protPI.append("")
        protEC.append("")
        protII.append("")
        protSSh.append("")
        protSSt.append("")
        protSSs.append("")
        protAA.append("")
    else:
        fasta_list = re.split(r'\n', all_fastas)
        fasta_list.pop(0)
        fastaSeq=''.join(fasta_list)
        protSeq.append(fastaSeq)
        protLen.append(len(fastaSeq))
        X = ProteinAnalysis(fastaSeq.replace("X", "" ).replace("Z", ""))
        protMWkDa.append(X.molecular_weight())
        protPI.append(X.isoelectric_point())
        protEC.append(X.molar_extinction_coefficient()[0])
        protII.append(X.instability_index())
        protSSh.append(X.secondary_structure_fraction()[0])
        protSSt.append(X.secondary_structure_fraction()[1])
        protSSs.append(X.secondary_structure_fraction()[2])
        protAA.append(X.count_amino_acids())
        
dataAnno = pd.DataFrame(list(zip(uniprot,protein,protLen,protMWkDa,protPI,protEC,protII,protSSh,protSSt,protSSs,protAA,protSeq)), columns = ['Uniprot', 'Protein','Length','MW in kDa','pI','Extinction Coefficient','Instability index','Helix','Turn','Sheet','Amino Acids','Sequence'])
dataAnno.to_csv(inpF+"protparam.csv")
