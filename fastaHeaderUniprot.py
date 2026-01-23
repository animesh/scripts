#python fastaHeaderUniprot.py < F:\promec\TIMSTOF\LARS\2026\260107_Tore\Thalassiosira_pseudonana_PASA-proteins.txt > F:\promec\TIMSTOF\LARS\2026\260107_Tore\Thalassiosira_pseudonana_PASA-proteins_uniprot.fasta

import sys
import re

for line in sys.stdin:
    if line.startswith(">"):
        # Header line → rewrite
        header = line.strip()[1:]
        parts = header.split()

        transcript = parts[0]          # g244.t1
        gene = parts[1]                # g244
        rest = " ".join(parts[2:])     # contig + organism info

        accession = transcript.replace(".", "").upper()   # G244T1
        entry = f"{accession}_THAPS"

        new_header = (
            f">tr|{accession}|{entry} "
            f"{rest} protein "
            f"OS=Thalassiosira pseudonana "
            f"OX=35128 "
            f"GN={gene}_t1 "
            f"PE=1 SV=1"
        )

        print(new_header)
    else:
        # Sequence line → keep only alphabetic characters and uppercase
        cleaned = re.sub(r"[^A-Za-z]", "", line)
        cleaned = cleaned.upper()
        print(cleaned)

