#!/usr/bin/env python3
"""
vepExtract.py
Read all VEP output files from a folder, build a gene x sample
non-synonymous mutation count table, write to CSV.

Usage:
    python vepExtract.py <vep_folder> [--out counts.csv] [--mode nonsyn|genic|exonic]
    python vepExtract.py /path/to/vep_files/
    python vepExtract.py /path/to/vep_files/ --out my_counts.csv --mode exonic
"""

import os
import re
import csv
import sys
import argparse
from collections import defaultdict

# VEP consequences considered non-synonymous (protein-altering)
NONSYN = {
    'missense_variant',
    'stop_gained',
    'stop_lost',
    'start_lost',
    'frameshift_variant',
    'splice_acceptor_variant',
    'splice_donor_variant',
    'splice_region_variant',
    'protein_altering_variant',
    'incomplete_terminal_codon_variant',
    'coding_sequence_variant',
    'start_retained_variant',
    'stop_retained_variant',
}

# Genomic region classification (priority order)
REGION_RANK = ['Exonic', 'Intronic', 'Upstream', 'Downstream', 'Intergenic', 'Other']

def classify_region(consequences):
    if 'intergenic' in consequences:
        return 'Intergenic'
    if 'non_coding_transcript_exon' in consequences or (
        'exon' in consequences and 'non_coding' in consequences):
        return 'Exonic'
    if 'intron' in consequences:
        return 'Intronic'
    if 'upstream' in consequences:
        return 'Upstream'
    if 'downstream' in consequences:
        return 'Downstream'
    return 'Other'

def is_nonsyn(consequences):
    return bool(set(c.strip() for c in consequences.split(',')) & NONSYN)

def parse_vep_file(path, sample_name):
    """Parse one VEP output file, return list of variant dicts."""
    records = []
    seen = set()  # deduplicate (var_id) within sample
    with open(path, encoding='utf-8', errors='replace') as fh:
        for line in fh:
            line = line.rstrip('\n')
            if line.startswith('#') or not line.strip():
                continue
            cols = line.split('\t')
            if len(cols) < 14:
                continue

            var_id       = cols[0]
            location     = cols[1]
            allele       = cols[2]
            gene         = cols[3].strip()
            feature      = cols[4]
            feature_type = cols[5]
            consequences = cols[6]
            cdna_pos     = cols[7]
            cds_pos      = cols[8]
            prot_pos     = cols[9]
            amino_acids  = cols[10]
            codons       = cols[11]
            existing_var = cols[12]
            extra        = cols[13]

            # skip if no gene
            if gene == '-' or not gene:
                gene = None

            # parse chromosome and position
            loc_parts = location.split(':')
            chrom = loc_parts[0]
            try:
                pos = int(loc_parts[1].split('-')[0])
            except (IndexError, ValueError):
                pos = 0

            # variant type from uploaded_variation field
            vp = var_id.split('_')
            alleles = vp[-1].split('/') if vp else []
            ref = alleles[0] if alleles else ''
            alt = alleles[1] if len(alleles) > 1 else ''
            if len(ref) == 1 and len(alt) == 1 and ref != '-' and alt != '-':
                var_type = 'SNP'
            elif ref == '-' or len(ref) < len(alt):
                var_type = 'INS'
            elif alt == '-' or len(ref) > len(alt):
                var_type = 'DEL'
            else:
                var_type = 'MNP'

            # IMPACT
            imp_match = re.search(r'IMPACT=(\w+)', extra)
            impact = imp_match.group(1) if imp_match else 'UNKNOWN'

            region = classify_region(consequences)
            nonsyn = is_nonsyn(consequences)

            # deduplicate multi-transcript rows: keep first occurrence per var_id
            if var_id not in seen:
                seen.add(var_id)
                records.append({
                    'sample':        sample_name,
                    'var_id':        var_id,
                    'chrom':         chrom,
                    'pos':           pos,
                    'ref':           ref,
                    'alt':           alt,
                    'var_type':      var_type,
                    'gene':          gene,
                    'feature_type':  feature_type,
                    'consequences':  consequences,
                    'region':        region,
                    'impact':        impact,
                    'amino_acids':   amino_acids if amino_acids != '-' else '',
                    'nonsyn':        nonsyn,
                    'known':         'Known' if existing_var and existing_var != '-' else 'Novel',
                })
    return records

def collect_files(folder):
    """Return list of (sample_name, filepath) for all files in folder."""
    pairs = []
    for fname in sorted(os.listdir(folder)):
        fpath = os.path.join(folder, fname)
        if not os.path.isfile(fpath):
            continue
        if os.path.getsize(fpath) == 0:
            print(f'  SKIP (empty): {fname}')
            continue
        # derive sample name: strip known VEP suffixes
        sample = re.sub(r'\.(vep|txt|tsv|vcf|gz)$', '', fname, flags=re.IGNORECASE)
        # also strip chromosome suffixes like .Y .X .1 etc
        sample = re.sub(r'\.[XY\d]+$', '', sample)
        pairs.append((sample, fpath))
    return pairs

def build_matrix(all_records, mode):
    """
    Build gene x sample count matrix.
    mode: 'nonsyn'  -- non-synonymous variants only
          'exonic'  -- genic exonic variants
          'genic'   -- all genic variants (has a gene ID, not intergenic)
    Returns (genes_sorted, samples_sorted, matrix dict, detail dict)
    """
    # filter by mode
    if mode == 'nonsyn':
        rows = [r for r in all_records if r['gene'] and r['nonsyn']]
    elif mode == 'exonic':
        rows = [r for r in all_records if r['gene'] and r['region'] == 'Exonic']
    else:  # genic
        rows = [r for r in all_records if r['gene'] and r['region'] != 'Intergenic']

    # gene -> sample -> set of var_ids
    matrix  = defaultdict(lambda: defaultdict(set))
    details = defaultdict(lambda: defaultdict(list))  # gene -> sample -> [var_ids]

    for r in rows:
        genes = [g.strip() for g in r['gene'].split(',') if g.strip()]
        for gene in genes:
            matrix[gene][r['sample']].add(r['var_id'])
            if r['var_id'] not in details[gene][r['sample']]:
                details[gene][r['sample']].append(r['var_id'])

    all_genes   = sorted(matrix.keys())
    all_samples = sorted({r['sample'] for r in all_records})

    return all_genes, all_samples, matrix, details

def write_csv(out_path, genes, samples, matrix, details, mode):
    """Write count matrix to CSV. Also writes a detail CSV."""
    with open(out_path, 'w', newline='') as fh:
        w = csv.writer(fh)
        w.writerow(['Gene'] + samples + ['Total'])
        for gene in genes:
            counts = [len(matrix[gene][s]) for s in samples]
            w.writerow([gene] + counts + [sum(counts)])

    # also write long-format detail file
    detail_path = out_path.replace('.csv', '_detail.csv')
    with open(detail_path, 'w', newline='') as fh:
        w = csv.writer(fh)
        w.writerow(['Gene', 'Sample', 'Count', 'VariantIDs'])
        for gene in genes:
            for sample in samples:
                ids = details[gene][sample]
                if ids:
                    w.writerow([gene, sample, len(ids), ';'.join(ids)])

    return detail_path

def main():
    parser = argparse.ArgumentParser(description='Extract gene x sample variant counts from VEP files.')
    parser.add_argument('folder', help='Folder containing VEP output files')
    parser.add_argument('--out', default='', help='Output CSV path (default: <folder>/gene_sample_counts.csv)')
    parser.add_argument('--mode', choices=['nonsyn', 'exonic', 'genic'], default='nonsyn',
                        help='Which variants to count (default: nonsyn)')
    args = parser.parse_args()

    folder = os.path.abspath(args.folder)
    if not os.path.isdir(folder):
        sys.exit(f'ERROR: {folder} is not a directory')

    out_csv = args.out or os.path.join(folder, f'gene_sample_{args.mode}.csv')

    print(f'Folder : {folder}')
    print(f'Mode   : {args.mode}')
    print(f'Output : {out_csv}')
    print()

    file_pairs = collect_files(folder)
    if not file_pairs:
        sys.exit('No files found in folder.')

    print(f'Found {len(file_pairs)} file(s). Parsing...')
    all_records = []
    for sample, fpath in file_pairs:
        recs = parse_vep_file(fpath, sample)
        all_records.extend(recs)
        nonsyn_n = sum(1 for r in recs if r['nonsyn'])
        print(f'  {sample:30s}  {len(recs):4d} variants  {nonsyn_n:4d} non-synonymous')

    print(f'\nTotal records : {len(all_records)}')
    total_nonsyn = sum(1 for r in all_records if r['nonsyn'])
    print(f'Non-synonymous: {total_nonsyn}')
    if total_nonsyn == 0 and args.mode == 'nonsyn':
        print('\nWARNING: Zero non-synonymous variants found.')
        print('This is expected for non-coding chromosomes (Y, mitochondria).')
        print('Consider --mode exonic or --mode genic for non-coding data.')

    genes, samples, matrix, details = build_matrix(all_records, args.mode)
    print(f'\nGenes   : {len(genes)}')
    print(f'Samples : {len(samples)}')

    detail_path = write_csv(out_csv, genes, samples, matrix, details, args.mode)
    print(f'\nWrote : {out_csv}')
    print(f'Wrote : {detail_path}')

if __name__ == '__main__':
    main()
