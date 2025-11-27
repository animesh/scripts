import gzip
# Load file2 into set
seqs2 = set()
with gzip.open("Z:/Download/rnafusion/data/fastq/SRR31089076_1.fastq.gz", 'rb') as f:
    for i, line in enumerate(f):
        if i % 4 == 1:
            seqs2.add(line.strip())
# Check file1 against file2
missing = 0
total = 0
with gzip.open("F:/tk/TK9_1_22FFLLLT3_AGAGAACCTA-GGTTATGCTA_L005__1.fq.gz", 'rb') as f:
    for i, line in enumerate(f):
        if i % 4 == 1:
            total += 1
            if line.strip() not in seqs2:
                missing += 1
print(f"Total: {total}, Missing: {missing}")
