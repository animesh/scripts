#python pepMap.py "F:\OneDrive - NTNU\Desktop\uniprot_sprot.fasta" "NKPHVNVGTIGHVDHGK"
#python pepMap.py "F:\OneDrive - NTNU\Desktop\uniprot_sprot.fasta" "PHVNVGTIGHVDHGK"
#https://pyteomics.readthedocs.io/en/latest/examples/example_fasta.html
#python -m pip install -U pyteomics pandas
#wget https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/complete/uniprot_sprot.fasta.gz
#gunzip uniprot_sprot.fasta.gz
#wget https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/complete/uniprot_trembl.fasta.gz
#gunzip uniprot_trembl.fasta.gz
#wget https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/complete/uniprot_sprot_varsplic.fasta.gz
#gunzip uniprot_sprot_varsplic.fasta.gz
from pyteomics import fasta, parser
import sys
fastaF = sys.argv[1]
#fastaF = "F:/OneDrive - NTNU/Desktop/uniprot_sprot.fasta"
#fastaF = "F:/OneDrive - NTNU/Desktop/uniprot_test.fasta"
peptide = sys.argv[2]
#peptide = "NKPHVNVGTIGHVDHGK"
#peptide = "PHVNVGTIGHVDHGK"
peptide = peptide.upper()
peptide = peptide.replace("L", "I") 
import time
chkPoint=time.strftime("%H.%M.%S.%d.%m.%Y")
fastaFO=fastaF+peptide+chkPoint+".hits.csv"
print('Searching ', fastaF ,'for peptide',peptide,'and writing to... \n',fastaFO,'...\n')
f= open(fastaFO,"w+")
#https://stackoverflow.com/questions/3437059/does-python-have-a-string-contains-substring-method
for description, sequence in fasta.FASTA(fastaF):
  sequence = sequence.upper()
  sequence = sequence.replace("L", "I")
  #print(description, sequence, peptide)
  if peptide in sequence: 
    f.write(description)
    words = description.split('=') 
    words = ','.join(words)
    print(words)
    f.write(str(words))
    f.write('\n')
f.close()
