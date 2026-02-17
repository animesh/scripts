#python fastaHeaderUniprot.py < L:\promec\TIMSTOF\LARS\2025\251103_STEVEN\Araport11_pep_20250411.fasta > L:\promec\TIMSTOF\LARS\2025\251103_STEVEN\Araport11_pep_20250411.uniprot.fasta
#python fastaHeaderUniprot.py < L:\promec\TIMSTOF\LARS\2025\251103_STEVEN\Araport11_pep_20250411_representative_gene_model.fasta > L:\promec\TIMSTOF\LARS\2025\251103_STEVEN\Araport11_pep_20250411_representative_gene_model.uniprot.fasta
import sys
import re
for line in sys.stdin:
    if line.startswith(">"):
        # Header line → rewrite >GMAT1G01010.1 | Symbols:NAC001,NTL10,ANAC001 | NAC domain containing protein 1 |  Chr1:3760-5630 FORWARD LENGTH=429
        header = line.strip()[1:]
        parts = header.split(sep="|")
        gene = parts[1].strip().replace('Symbols:', '').replace(',', '_').strip()
        rest = " ".join(parts[2:])     # contig + organism info
        accession = parts[0].strip().replace('.', '-').upper()
        print(f">tr|{accession}|{accession}_ARAPORT {rest} OS=Araport11_pep_20250411 GN={gene} PE=1 SV=1")
        # >tr|GMAT1G01010-1|GMAT1G01010-1_ARAPORT  NAC domain containing protein 1    Chr1:3760-5630 FORWARD LENGTH=429 OS=Araport11_pep_20250411 GN=NAC001_NTL10_ANAC001 PE=1 SV=1
    else:
        # Sequence line → keep only alphabetic characters and uppercase
        cleaned = re.sub(r"[^A-Za-z]", "", line)
        cleaned = cleaned.upper()
        print(cleaned)
        