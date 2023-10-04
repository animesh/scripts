#python pepCleave.py ../../../uniprot-human-iso-feb23.fasta [KR] 7 35 0
#https://pyteomics.readthedocs.io/en/latest/examples/example_fasta.html
#python -m pip install -U pyteomics pandas
from pyteomics import fasta, parser
#parser.expasy_rules https://web.expasy.org/peptide_cutter/peptidecutter_enzymes.html
import sys
fastaF = sys.argv[1]
protease = sys.argv[2]
minLen= int(sys.argv[3])
maxLen = int(sys.argv[4])
missCleave = int(sys.argv[5])
#fastaF = "../../../uniprot-human-iso-feb23.fasta"
#protease = '[KR]'
#minLen=7
#maxLen=35
#missCleave=0
fastaFO=fastaF+protease+str(minLen)+str(maxLen)+str(missCleave)+".cleave.fasta"
print('Cleaving ', fastaF ,'sequences with protease cleaving site',protease,'with miss-cleavages',missCleave,'filtering peptides at min / max-length of',minLen,'/',maxLen,'respectively and writing to... \n',fastaFO,'...\n')

f= open(fastaFO,"w+")
unique_peptides = set()
for description, sequence in fasta.FASTA(fastaF):
    new_peptides = parser.cleave(sequence, protease, missCleave,minLen)
    new_peptides2 = [peptide for peptide in new_peptides if len(peptide) <= maxLen]
    new_peptides3 = set(new_peptides2)
    unique_peptides.update(new_peptides3)
    [f.write(">T"+str(len(new_peptides3))+"F"+str(sequence.find(peptide))+"L"+str(len(peptide))+"O"+str(len(sequence))+"S"+description+"\n"+peptide+"\n") for peptide in new_peptides3]
    #f.write(description+sequence+new_peptides5)
    #print(new_peptides)
print('Done, {0} unique peptide sequences obtained\n\n'.format(len(unique_peptides)))
peptideCombined=''.join(unique_peptides)
print("Total amino-acids",len(peptideCombined))
print("Total amino-acids per sequence",len(peptideCombined)/len(unique_peptides))
f.close()

import pandas as pd
aaCnt=parser.amino_acid_composition(peptideCombined)
#aaCnt=parser.amino_acid_composition(max(unique_peptides))#unique_peptides.pop()
compDF=pd.DataFrame([dict(aaCnt)])
compDF=compDF.transpose()
compDF=compDF.sort_values(0)
compDF=compDF.sort_index()
print(compDF)
compDF.plot.bar().get_figure().savefig(fastaFO+'comp.png',dpi=100,bbox_inches = "tight")

import pickle
with open(fastaFO+'.pkl','wb') as f: pickle.dump(unique_peptides, f)#unique_peptides= pickle.load(f)
