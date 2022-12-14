import requests
fasta=requests.get('https://rest.uniprot.org/uniprotkb/A0A060IFB9.fasta').text
f = open('test.fasta', 'a')
f.write(fasta)
f.close()
#https://bionumpy.github.io/bionumpy/
import numpy as np
import bionumpy as bnp
reads = bnp.open('test.fasta').read()
print(reads)
gc_content = np.mean((reads.sequence == "C") | (reads.sequence == "G"))
print(gc_content)
