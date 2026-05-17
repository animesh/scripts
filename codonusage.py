#python codonusage.py CCDS_nucleotide.20221027.fna CCDS.20221027.txt

import sys
import csv

file1 = sys.argv[1]
file2 = sys.argv[2]

ftout = f"{file1}.{file2}.aa.py.fasta"
fcout = f"{file1}.{file2}.aa.py.txt"

seqh = {}
seqc = None
val = {}

cl = 3

c2a = {
    'TTT': 'F', 'TTC': 'F', 'TTA': 'L', 'TTG': 'L',
    'TCT': 'S', 'TCC': 'S', 'TCA': 'S', 'TCG': 'S',
    'TAT': 'Y', 'TAC': 'Y', 'TAA': 'stop', 'TAG': 'stop',
    'TGT': 'C', 'TGC': 'C', 'TGA': 'stop', 'TGG': 'W',

    'CTT': 'L', 'CTC': 'L', 'CTA': 'L', 'CTG': 'L',
    'CCT': 'P', 'CCC': 'P', 'CCA': 'P', 'CCG': 'P',
    'CAT': 'H', 'CAC': 'H', 'CAA': 'Q', 'CAG': 'Q',
    'CGT': 'R', 'CGC': 'R', 'CGA': 'R', 'CGG': 'R',

    'ATT': 'I', 'ATC': 'I', 'ATA': 'I', 'ATG': 'M',
    'ACT': 'T', 'ACC': 'T', 'ACA': 'T', 'ACG': 'T',
    'AAT': 'N', 'AAC': 'N', 'AAA': 'K', 'AAG': 'K',
    'AGT': 'S', 'AGC': 'S', 'AGA': 'R', 'AGG': 'R',

    'GTT': 'V', 'GTC': 'V', 'GTA': 'V', 'GTG': 'V',
    'GCT': 'A', 'GCC': 'A', 'GCA': 'A', 'GCG': 'A',
    'GAT': 'D', 'GAC': 'D', 'GAA': 'E', 'GAG': 'E',
    'GGT': 'G', 'GGC': 'G', 'GGA': 'G', 'GGG': 'G',
}


def translate(se):

    lt = len(se)
    ct = int(lt / cl)
    rr = lt % cl

    sa = ""
    cu = {}
    cp = ""

    for c2 in range(ct):

        sp = c2 * cl
        aa = se[sp:sp + cl]

        sa += c2a.get(aa, "")

        if aa not in cu:
            cu[aa] = 0

        cu[aa] += 1

        if c2a.get(aa) == "stop":
            cp += f"{sp}-"

    return sa, cp, lt, rr, cu


# annotation
with open(file2, encoding="utf-8-sig") as f2:

    reader = csv.reader(f2, delimiter="\t")

    for row in reader:

        if len(row) < 5:
            continue

        kh = (row[4] + "_chr" + row[0]).upper()

        val[kh] = "\t".join(row)

print(f"loaded annotations {file2}: {len(val)}")


# fasta
with open(file1) as f1:

    for l1 in f1:

        l1 = l1.rstrip("\n")
        l1 = l1.replace("\r", "")

        if l1.startswith(">"):

            l1 = l1.replace(">", "")

            snt = l1.split("|")

            seqc = (snt[0] + "_" + snt[2]).upper()

        else:

            l1 = ''.join(
                [x for x in l1 if (not x.isdigit()) and (not x.isspace())]
            )

            if seqc not in seqh:
                seqh[seqc] = ""

            seqh[seqc] += l1.upper()

print(f"loaded sequences {file1}: {len(seqh)}")


print(f"writing translated fasta file {ftout}")

with open(ftout, "w") as ft, open(fcout, "w") as fc:

    fc.write(
        f'{val.get("CCDS_ID_CHR#CHROMOSOME","").lstrip("#")}\t'
        'ID\tLength\tDivBy3Rem\tStopCodons\tStopCodonPos\t'
        'CodonUsage\t'
    )

    for aa in c2a:
        fc.write(f"{aa}-{c2a[aa]}\t")

    fc.write("\n")

    for seqn in seqh:

        seq = seqh[seqn]

        seqt, scp, lgt, rem, cut = translate(seq)

        stpcnt = scp.split("-")

        fc.write(
            f'{val.get(seqn,"")}\t'
            f'{seqn}\t{lgt}\t{rem}\t{len(stpcnt)-1}\t'
            f'{scp}\t{len(seqt)}\t'
        )

        for aaa in c2a:
            fc.write(f'{cut.get(aaa,"")}\t')

        fc.write("\n")

        # preserve original perl bug/behavior exactly
        seqtn = seqt.split("stop")

        for snc in range(len(seqtn)):

            if snc > 0:
                print(f"{seqn}\t{snc}")

            seqtns = seqtn[snc]

            ft.write(
                f">{seqn}.{snc}\t"
                f'{val.get(seqn,"")}\t'
                f'{scp}\t{len(seqt)}\n'
            )

            ft.write(f"{seqtns}\n")

print(f"wrote codon usage in {fcout}")