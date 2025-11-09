#python pepCleave.py L:/promec/FastaDB/UP000005640_9606_unique_gene.fasta 10 30
#sed 's/|/_/g' promec/promec/FastaDB/UP000005640_9606_unique_gene.fasta.len10to30.fasta | awk '/^>/ {print ">sp|S" ++i "|" substr($0, 2)} !/^>/ {print}' > promec/promec/FastaDB/UP000005640_9606_unique_gene.len10to30.hdrfix.fasta
#grep -E "^[^>].*Z.*" promec/promec/FastaDB/UP000005640_9606_unique_gene.len10to30.hdrfix.fasta
#Z:\DIA-NN\2.3.0>diann.exe --f "L:\promec\TIMSTOF\LARS\2025\251031_MAREN\251030_MAREN_DIALYSE_DIA_Slot1-37_1_11509.d" --lib "" --threads 24 --verbose 1 --out "Z:\DIA-NN\2.3.0\report.parquet" --qvalue 0.01 --matrices  --out-lib "Z:\DIA-NN\2.3.0\report-lib.parquet" --gen-spec-lib --fasta "L:\promec\FastaDB\UP000005640_9606_unique_gene.len10to30.hdrfix.fasta" --pre-search --pre-filter --met-excision --min-pep-len 10 --max-pep-len 30 --min-pr-mz 300 --max-pr-mz 1800 --min-pr-charge 1 --max-pr-charge 4 --min-fr-mz 200 --max-fr-mz 1800 --cut Z* --missed-cleavages 0 --unimod4 --reanalyse --rt-profiling
#C:\Program Files\DIA-NN\2.2.0>diann.exe --lib "" --threads 32 --verbose 5 --out "F:\promec\FastaDB\humanL10to30peptides.parquet" --qvalue 0.01 --matrices  --out-lib "F:\promec\FastaDB\humanL10to30peptideslib.parquet" --gen-spec-lib --predictor --fasta "F:\promec\FastaDB\UP000005640_9606_unique_gene.len10to30.hdrfix.fasta" --fasta-search --min-fr-mz 200 --max-fr-mz 1800 --met-excision --min-pep-len 10 --max-pep-len 30 --min-pr-mz 300 --max-pr-mz 1800 --min-pr-charge 1 --max-pr-charge 4 --cut Z* --missed-cleavages 0 --unimod4 --mass-acc 15.0 --mass-acc-ms1 15.0 --reanalyse --rt-profiling
from pyteomics import fasta, parser
import sys
import pandas as pd
import pickle
if len(sys.argv) > 1:
    fastaF = sys.argv[1]
else:
    fastaF = r"L:/promec/FastaDB/UP000005640_9606_unique_gene.fasta"
if len(sys.argv) > 2:
    minLen = int(sys.argv[2])
else:
    minLen = 10
if len(sys.argv) > 3:
    maxLen = int(sys.argv[3])
else:
    maxLen = 30

# output file
fastaFO = fastaF + ".len{0}to{1}.fasta".format(minLen, maxLen)
print('Generating subsequences from', fastaF)
print('minLen', minLen, 'maxLen', maxLen, '-> writing to', fastaFO)

f = open(fastaFO, 'w+')
unique_peptides = set()
count_written = 0
for description, sequence in fasta.FASTA(fastaF):
    seq = sequence
    seqlen = len(seq)
    # iterate start positions
    for i in range(0, seqlen - minLen + 1):
        # iterate lengths
        for L in range(minLen, maxLen + 1):
            if i + L > seqlen:
                break
            peptide = seq[i:i+L]
            if peptide in unique_peptides:
                continue
            unique_peptides.add(peptide)
            header = ">{sid}|{start}-{end} len={llen} O={seqlen} {desc}".format(
                sid=description.split()[0],
                start=i+1,
                end=i+L,
                llen=L,
                seqlen=seqlen,
                desc=description
            )
            f.write(header + "\n")
            f.write(peptide + "\n")
            count_written += 1

f.close()
print('Done, wrote {0} unique subsequences'.format(count_written))

# compute amino acid composition over concatenated unique peptides
peptideCombined = ''.join(unique_peptides)
if peptideCombined:
    aaCnt = parser.amino_acid_composition(peptideCombined)
    compDF = pd.DataFrame([dict(aaCnt)])
    compDF = compDF.transpose()
    compDF = compDF.sort_values(0)
    compDF = compDF.sort_index()
    print(compDF)
    try:
        compDF.plot.bar().get_figure().savefig(fastaFO + '.comp.png', dpi=100, bbox_inches='tight')
    except Exception:
        pass

# save set
with open(fastaFO + '.pkl', 'wb') as pf:
    pickle.dump(unique_peptides, pf)

print('Saved pickle to', fastaFO + '.pkl')
