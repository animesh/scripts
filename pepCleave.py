#https://pyteomics.readthedocs.io/en/latest/examples/example_fasta.html
#C:\\Users\\animeshs\\AppData\\Local\\Programs\\Spyder\\Python\\python.exe -m pip install -U pyteomics
from pyteomics import fasta, parser, mass, achrom, electrochem, auxiliary
#parser.expasy_rules https://web.expasy.org/peptide_cutter/peptidecutter_enzymes.html
import sys
fastaF = sys.argv[1]
protease1 = sys.argv[2]
protease2 = sys.argv[3]
#fastaF = "C:/Users/animeshs/Desktop/crap.fasta"
#protease1 = '[KR]'
#protease2 = 'E'
#fastaFO=fastaF+protease1+protease2+".test.cleave.fasta"
fastaFO=fastaF+protease1+protease2+".cleave.fasta"
print('Cleaving ', fastaF ,'sequences with protease cleaving site',protease1,protease2,'and writing to... \n',fastaFO,'...\n')
f= open(fastaFO,"w+")
unique_peptides = set()
for description, sequence in fasta.FASTA(fastaF):
    new_peptides = parser.cleave(sequence, protease1, 2,min_length=6)
    new_peptides2 = [peptide for peptide in new_peptides if len(peptide) <= 60]
    new_peptides3 =[parser.cleave(peptide, protease2, 2,min_length=6) for peptide in new_peptides2]
    new_peptides4 = [item for sublist in new_peptides3 for item in sublist]
    new_peptides5 = set(new_peptides4)
    unique_peptides.update(new_peptides5)
    description=description.replace(';', '_')#making sure there are no semicolons in the generated sequence names otherwise MaxQuant will crash!
    [f.write(">T"+str(len(new_peptides5))+"F"+str(sequence.find(peptide))+"L"+str(len(peptide))+"O"+str(len(sequence))+"S"+description+"\n"+peptide+"\n") for peptide in new_peptides5]
    #f.write(description+sequence+new_peptides5)
    #print(new_peptides)
print('Done, {0} unique sequences obtained!\n\n'.format(len(unique_peptides)))
f.close()
#Example for GluC/E followed by TryPsin/[KR] cleavage
#C:\\Users\\animeshs\\AppData\\Local\\Programs\\Spyder\\Python\\python.exe pepCleave.py L:\promec\FastaDB\crap.fasta  E  [KR]
#Cleaving  L:\promec\FastaDB\crap.fasta sequences with protease cleaving site E [KR] and writing to...
#Done, 57183 unique sequences obtained!
#NOTE: 