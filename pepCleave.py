#python pepCleave.py L:/promec/FastaDB/UP000005640_9606_unique_gene.fasta 10 30
import sys
import pickle
from collections import Counter

def read_fasta(file_path):
    """
    Simple FASTA parser generator.
    Yields (description, sequence).
    """
    with open(file_path, 'r') as f:
        description = None
        sequence_parts = []
        for line in f:
            line = line.strip()
            if not line:
                continue
            if line.startswith('>'):
                if description:
                    yield description, ''.join(sequence_parts)
                description = line[1:] # Remove '>'
                sequence_parts = []
            else:
                sequence_parts.append(line)
        if description:
            yield description, ''.join(sequence_parts)

# Monoisotopic masses of amino acid residues
MONOISOTOPIC_MASS = {
    'A': 71.03711, 'R': 156.10111, 'N': 114.04293, 'D': 115.02694, 'C': 103.00919,
    'E': 129.04259, 'Q': 128.05858, 'G': 57.02146, 'H': 137.05891, 'I': 113.08406,
    'L': 113.08406, 'K': 128.09496, 'M': 131.04049, 'F': 147.06841, 'P': 97.05276,
    'S': 87.03203, 'T': 101.04768, 'W': 186.07931, 'Y': 163.06333, 'V': 99.06841,
    'U': 150.95363, 'O': 237.14773
}

def calculate_monoisotopic_mass(peptide):
    mass = 18.01056  # H2O for termini
    for aa in peptide:
        if aa in MONOISOTOPIC_MASS:
            mass += MONOISOTOPIC_MASS[aa]
    return mass

def test_mass_equality():
    p1 = "LSLAQEDLISNR"
    p2 = "GSLLLGGLDAEASR"
    m1 = calculate_monoisotopic_mass(p1)
    m2 = calculate_monoisotopic_mass(p2)
    print(f"Test: Comparing '{p1}' and '{p2}'")
    print(f"Length {p1}: {len(p1)}")
    print(f"Length {p2}: {len(p2)}")
    print(f"Mass {p1}: {m1:.4f}")
    print(f"Mass {p2}: {m2:.4f}")
    diff = abs(m1 - m2)
    print(f"Difference: {diff:.4f}")
    if diff < 0.0001:
        print("Result: Masses are EQUAL")
    else:
        print("Result: Masses are DIFFERENT")

if __name__ == "__main__":
    # Run the requested test
    test_mass_equality()
    
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

    try:
        for description, sequence in read_fasta(fastaF):
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
                    
                    mass = calculate_monoisotopic_mass(peptide)
                    
                    header = ">{sid}|{start}-{end} len={llen} mass={mass:.4f} O={seqlen} {desc}".format(
                        sid=description.split()[0],
                        start=i+1,
                        end=i+L,
                        llen=L,
                        mass=mass,
                        seqlen=seqlen,
                        desc=description
                    )
                    f.write(header + "\n")
                    f.write(peptide + "\n")
                    count_written += 1
    except FileNotFoundError:
        print(f"Error: File not found: {fastaF}")
        sys.exit(1)
    except Exception as e:
        print(f"An error occurred: {e}")
        sys.exit(1)

    f.close()
    print('Done, wrote {0} unique subsequences'.format(count_written))

    # compute amino acid composition over concatenated unique peptides
    peptideCombined = ''.join(unique_peptides)
    if peptideCombined:
        aaCnt = Counter(peptideCombined)
        print("\nAmino Acid Composition:")
        # Print sorted by amino acid
        for aa in sorted(aaCnt.keys()):
            print(f"{aa}: {aaCnt[aa]}")

    # save set
    with open(fastaFO + '.pkl', 'wb') as pf:
        pickle.dump(unique_peptides, pf)

    print('Saved pickle to', fastaFO + '.pkl')
