#python pepProtMap.py peplist.txt A0A8C4ZK06.fasta
#python pepQuanProtMap.py "L:/promec/TIMSTOF/LARS/2026/260908_Moreforsk/combined/txt/peptides.txt" "A0A8C4ZK06"
#python pepQuanProtMap.py "L:/promec/TIMSTOF/LARS/2026/260908_Moreforsk/trypsin/combined/txt/peptides.txt" "A0A8C4ZK06"
#cat L:/promec/TIMSTOF/LARS/2026/260908_Moreforsk/combined/txt/peptides.txtA0A8C4ZK06peptides.txt L:/promec/TIMSTOF/LARS/2026/260908_Moreforsk/trypsin/combined/txt/peptides.txtA0A8C4ZK06peptides.txt > peplist.txt
#wget "https://rest.uniprot.org/uniprotkb/A0A8C4ZK06.fasta" 
import sys
from pathlib import Path
import matplotlib.pyplot as plt
if len(sys.argv) not in (3, 4): sys.exit("USAGE: python pepQuanProtMap.py <peptide-file> <protein-fasta> [Uniprot-ID]")
peptide_file = Path(sys.argv[1])
fasta_file = Path(sys.argv[2])
wanted_id = sys.argv[3] if len(sys.argv) == 4 else None

peptides = []
with open(peptide_file, encoding="utf-8") as f:
    for line in f:
        peptide = line.strip().upper()
        if peptide and not peptide.startswith("#"):
            peptides.append(peptide)

records = []
header = None
sequence = []

with open(fasta_file, encoding="utf-8") as f:
    for line in f:
        line = line.strip()
        if not line:
            continue
        if line.startswith(">"):
            if header is not None:
                records.append((header, "".join(sequence)))
            header = line[1:]
            sequence = []
        else:
            sequence.append(line.upper())

if header is not None:
    records.append((header, "".join(sequence)))

if not records:
    sys.exit(f"No FASTA records found in {fasta_file}")

if wanted_id is None:
    header, protein = records[0]
else:
    matches = [(h, s) for h, s in records if wanted_id in h]
    if not matches:
        sys.exit(f"Protein ID '{wanted_id}' was not found in FASTA file {fasta_file}")
    header, protein = matches[0]

hits = []

for peptide in peptides:
    start = 0
    found = False

    while True:
        pos = protein.find(peptide, start)
        if pos == -1:
            break

        found = True
        hits.append({
            "peptide": peptide,
            "start": pos + 1,
            "end": pos + len(peptide),
            "length": len(peptide)
        })

        start = pos + 1

    if not found:
        print(f"WARNING: peptide not found: {peptide}", file=sys.stderr)

if hits:
    intervals = sorted((h["start"], h["end"]) for h in hits)

    contigs = []
    current_start, current_end = intervals[0]

    for start, end in intervals[1:]:
        if start <= current_end + 1:
            current_end = max(current_end, end)
        else:
            contigs.append((current_start, current_end))
            current_start, current_end = start, end

    contigs.append((current_start, current_end))
else:
    contigs = []

print(f"\nProtein: {header}")
print(f"Length:  {len(protein)} aa")
print(f"Peptides supplied: {len(peptides)}")
print(f"Peptide mappings:  {len(hits)}")
print()

if not hits:
    print("No peptides mapped.")
    sys.exit()

print("PEPTIDE MAPPINGS")
print("Peptide\tStart\tEnd\tLength")

for hit in sorted(hits, key=lambda x: (x["start"], x["end"], x["peptide"])):
    print(f'{hit["peptide"]}\t{hit["start"]}\t{hit["end"]}\t{hit["length"]}')

print()
print("CONTIGS")
print("Contig\tStart\tEnd\tLength")

for i, (start, end) in enumerate(contigs, 1):
    print(f"{i}\t{start}\t{end}\t{end - start + 1}")

covered = sum(end - start + 1 for start, end in contigs)

print()
print(f"Number of contigs: {len(contigs)}")
print(f"Covered residues:  {covered}")
print(f"Protein coverage:  {100 * covered / len(protein):.2f}%")

fig_width = max(12, len(protein) / 80)
fig, ax = plt.subplots(figsize=(fig_width, 5))

ax.plot([1, len(protein)], [0, 0], linewidth=3)

for start, end in contigs:
    ax.plot([start, end], [0, 0], linewidth=12, solid_capstyle="butt")

rows = []

for hit in sorted(hits, key=lambda x: (x["start"], x["end"])):
    placed = False

    for row, row_end in enumerate(rows):
        if hit["start"] > row_end:
            rows[row] = hit["end"]
            hit["row"] = row + 1
            placed = True
            break

    if not placed:
        rows.append(hit["end"])
        hit["row"] = len(rows)

for hit in hits:
    y = hit["row"]
    ax.plot([hit["start"], hit["end"]], [y, y], linewidth=4)
    ax.text(
        (hit["start"] + hit["end"]) / 2,
        y + 0.12,
        hit["peptide"],
        ha="center",
        va="bottom",
        fontsize=6,
        rotation=45
    )

ax.set_xlim(1, len(protein))
ax.set_ylim(-1.5, max(3, len(rows) + 1.5))
ax.set_xlabel("Protein position")
ax.set_yticks([0])
ax.set_yticklabels(["contig"])
ax.set_title(f"Peptide map: {len(protein)} aa protein")
ax.grid(axis="x", alpha=0.2)

plt.tight_layout()

output = peptide_file.with_name(
    f"{peptide_file.stem}_{fasta_file.stem}_map.svg"
)

fig.savefig(output, dpi=150, bbox_inches="tight")
plt.close(fig)

print(f"\nFigure: {output}")
