#python mqrunDash_verify_peptides.py 
from pathlib import Path
import re
import mqrunDash as mq

import argparse

parser = argparse.ArgumentParser(description="Verify mqrunDash peptide label claims against a FASTA and DuckDB file.")
parser.add_argument('--db', default=r'Z:\Download\mqrun.duckdb', help='Path to the DuckDB file')
parser.add_argument('--fasta', default=r'Z:\Download\UP000005640_9606_1protein1gene.fasta', help='Path to the FASTA file')
args = parser.parse_args()

# Use the intended database path
mq.DB = args.db

fasta_path = Path(args.fasta)
if not fasta_path.exists():
    raise FileNotFoundError(f'FASTA not found: {fasta_path}')

# parse FASTA
entries = {}
by_gene = {}
by_uniprot = {}
header = None
seq_lines = []
with fasta_path.open('r', encoding='utf-8', errors='replace') as f:
    for line in f:
        line = line.rstrip('\n')
        if line.startswith('>'):
            if header is not None:
                accession = header['accession']
                seq = ''.join(seq_lines)
                entries[accession] = {'header': header, 'seq': seq}
                by_uniprot[accession] = seq
                if header['gene']:
                    by_gene.setdefault(header['gene'], []).append(accession)
            desc = line[1:]
            acc_match = re.search(r'^\w+\|([^|]+)\|', desc)
            accession = acc_match.group(1) if acc_match else None
            gene = None
            m = re.search(r' GN=([^ ]+)', desc)
            if m:
                gene = m.group(1)
            header = {'line': line, 'accession': accession, 'gene': gene, 'desc': desc}
            seq_lines = []
        else:
            seq_lines.append(line.strip())
    if header is not None:
        accession = header['accession']
        seq = ''.join(seq_lines)
        entries[accession] = {'header': header, 'seq': seq}
        by_uniprot[accession] = seq
        if header['gene']:
            by_gene.setdefault(header['gene'], []).append(accession)

print(f'Parsed FASTA entries: {len(entries)} proteins, {len(by_gene)} genes')

mq._build_profile_store()

# peptides to verify: top peptides plus HLSGEFGK
peptides = [r['peptide'] for r in mq._TOP_PEPTIDES[:20]]
if 'HLSGEFGK' not in peptides:
    peptides.append('HLSGEFGK')

print('Verifying peptides:', peptides)
print()

for pep in peptides:
    profile, mat, label, _ = mq.load_peptide_profile(pep)
    # parse label text
    uid = None
    gene = None
    uid_match = re.search(r'\[([^\]]+)\]', label)
    if uid_match:
        uid = uid_match.group(1)
    parts = label.split()
    if len(parts) >= 2:
        gene = parts[-2] if uid else parts[-1]
    print(f'PEP={pep}  LABEL={label}')
    if uid:
        print(f'  claimed UID={uid}')
        if uid in by_uniprot:
            seq = by_uniprot[uid]
            found = pep in seq
            print(f'  found in UID sequence: {found} (seq len {len(seq)})')
            if not found:
                # maybe peptide spans cleavage or case issue
                print('    peptide not found in claimed UID sequence')
        else:
            print('  UID not present in FASTA')
    else:
        print('  no UID parsed from label')
    if gene:
        print(f'  claimed gene={gene}')
        if gene in by_gene:
            hits = [acc for acc in by_gene[gene] if pep in by_uniprot[acc]]
            print(f'  found in gene accessions: {hits}')
            if not hits:
                print('    peptide not found in any FASTA sequence for claimed gene')
        else:
            print('  gene not present in FASTA gene mapping')
    present = int(profile['present'].sum())
    print(f'  dashboard present in {present}/{len(profile)} runs')
    print()
