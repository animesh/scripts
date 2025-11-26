#!/usr/bin/env python3
# compareFastq.py
#
# Procedural script (user style) to compare two FASTQ files.
# Build an in-memory set of MD5 hashes for sequences from the first FASTQ (reads),
# then stream the second FASTQ (collectReads) and write sequences not present in
# the first to an output FASTA. Deduplicates output by sequence hash.
#
# Usage:
#   python compareFastq.py reads.fastq(.gz) collect.fastq(.gz) [out_missing.fasta]

import sys
import gzip
import time
import os
 


# args and defaults
reads = sys.argv[1] if len(sys.argv) > 1 else r'F:/tk/TK9_1_22FFLLLT3_AGAGAACCTA-GGTTATGCTA_L005__1.fq.gz'
collectReads = sys.argv[2] if len(sys.argv) > 2 else r'Z:/Download/rnafusion/data/fastq/SRR31089076_1.fastq.gz'
out_fasta = sys.argv[3] if len(sys.argv) > 3 else 'missing_from_reads.fasta'

print('reads =', reads)
print('collectReads =', collectReads)
print('out_fasta =', out_fasta)

# By default do not load files into memory; use simple grep-like scan per-sequence.
# Set SIMPLE_GREP=0 in environment to allow memory-based faster mode.
SIMPLE_GREP = os.environ.get('SIMPLE_GREP', '1') == '1'


def open_fh(path):
    if str(path).endswith('.gz'):
        return gzip.open(path, 'rt', encoding='utf-8', errors='ignore')
    return open(path, 'r', encoding='utf-8', errors='ignore')


def iter_fastq(fh):
    # yield header, seq
    while True:
        h = fh.readline()
        if not h:
            break
        s = fh.readline().rstrip('\n')
        fh.readline()
        fh.readline()
        yield h.rstrip('\n'), s


# build in-memory hash set of sequences from reads
def count_fastq_reads(path):
    # count records (fast pass). returns number of reads
    print('Counting reads in', path)
    n = 0
    with open_fh(path) as fh:
        for _ in iter_fastq(fh):
            n += 1
            if n % 1000000 == 0:
                print('  counted', n, 'reads...')
    print('Counted', n, 'reads in', path)
    return n


def human(n):
    for u in ['B','KB','MB','GB','TB']:
        if n < 1024.0:
            return f"{n:3.1f}{u}"
        n /= 1024.0
    return f"{n:.1f}PB"

# simple mode defaults to per-sequence grep
t0 = time.time()
missing = 0
scanned = 0
if not SIMPLE_GREP:
    print('Deciding comparison strategy (load smaller file into memory, then scan larger)...')
    # count both files and pick the smaller to load into memory
    count_reads_a = count_fastq_reads(reads)
    count_reads_b = count_fastq_reads(collectReads)
    print(f'reads: {count_reads_a:,}  collectReads: {count_reads_b:,}')
    if count_reads_a <= count_reads_b:
        small_path, large_path = reads, collectReads
        small_name, large_name = 'reads', 'collectReads'
    else:
        small_path, large_path = collectReads, reads
        small_name, large_name = 'collectReads', 'reads'

    print(f'Loading smaller file into memory ({small_name} -> {small_path})')
    inmem = set()
    loaded = 0
    with open_fh(small_path) as fh:
        for hdr, seq in iter_fastq(fh):
            inmem.add(seq)
            loaded += 1
            if loaded % 1000000 == 0:
                print('  loaded', loaded, 'sequences into memory...')
    print('Loaded', loaded, 'unique sequences in memory')

    print(f'Scanning larger file ({large_name} -> {large_path}) and writing sequences not present in {small_name} to', out_fasta)
else:
    print('SIMPLE_GREP mode (default): for each sequence in reads, scan the other file once; no large-memory structures used.')
# Simple grep-like mode: for each sequence in `reads`, scan `collectReads` once
# Use environment variable SIMPLE_GREP=1 to enable. This is slow but simple.
SIMPLE_GREP = os.environ.get('SIMPLE_GREP', '0') == '1'

if SIMPLE_GREP:
    print('Running SIMPLE_GREP mode: for each seq in reads, scan collectReads for a match (slow).')
    with open(out_fasta, 'w', encoding='utf-8') as outfh:
        with open_fh(reads) as rfh:
            for ri, (_, rseq) in enumerate(iter_fastq(rfh), start=1):
                found = False
                with open_fh(collectReads) as cfh:
                    for _, cseq in iter_fastq(cfh):
                        if cseq == rseq:
                            found = True
                            break
                if not found:
                    # write this read to output FASTA (use index as id)
                    outfh.write(f'>{ri}\n')
                    outfh.write(rseq + '\n')
                    missing += 1
                if ri % 10000 == 0:
                    print('  checked', ri, 'reads from reads; missing so far:', missing)
        scanned = None
    print('SIMPLE_GREP finished. wrote', missing, 'sequences not found in collectReads')
else:
    # Scan the larger file and write sequences not present in the smaller in-memory set
    with open(out_fasta, 'w', encoding='utf-8') as outfh:
        with open_fh(large_path) as fh:
            for header, seq in iter_fastq(fh):
                scanned += 1
                if seq not in inmem:
                    rid = header.split()[0].lstrip('@')
                    outfh.write('>' + rid + '\n')
                    outfh.write(seq + '\n')
                    missing += 1
                if scanned % 1000000 == 0:
                    print('  scanned', scanned, f'{large_name}...')

t2 = time.time()
print('Done. Scanned', scanned, 'collectReads; wrote', missing, 'unique sequences not present in reads; total time(s):', round(t2 - t0, 1))
