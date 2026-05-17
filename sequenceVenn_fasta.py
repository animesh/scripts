#wget "https://rest.uniprot.org/uniprotkb/stream?download=true&format=fasta&includeIsoform=true&query=%28%28proteome%3AUP000005640%29%29"
#python sequenceVenn_fasta.py CCDS_nucleotide.20221027.fna.CCDS.20221027.txt.aa.fasta uniprotkb_proteome_UP000005640_2026_05_17.fasta --write-fasta
import argparse
from pathlib import Path

def parse_fasta(path):
    seqs = []
    header = None
    seq = []
    with open(path, encoding='utf-8', errors='replace') as fh:
        for line in fh:
            line = line.rstrip('\r\n')
            if not line:
                continue
            if line.startswith('>'):
                if header is not None:
                    seqs.append((header, ''.join(seq)))
                header = line[1:].strip()
                seq = []
            else:
                seq.append(line.strip())
        if header is not None:
            seqs.append((header, ''.join(seq)))
    return seqs


def write_fasta(path, seq_to_headers):
    with open(path, 'w', encoding='utf-8') as out:
        for seq, headers in seq_to_headers.items():
            header = ' | '.join(headers)
            out.write(f'>{header}\n')
            out.write(f'{seq}\n')


def main():
    parser = argparse.ArgumentParser(description='Compare exact amino-acid sequences between two FASTA files.')
    parser.add_argument('left_fasta', help='First FASTA file (e.g. CCDS amino-acid output)')
    parser.add_argument('right_fasta', help='Second FASTA file (e.g. UniProt proteome)')
    parser.add_argument('--write-lists', action='store_true', help='Write overlap and exclusive lists to text files')
    parser.add_argument('--write-fasta', action='store_true', help='Write overlap and exclusive FASTA files')
    args = parser.parse_args()

    left = parse_fasta(args.left_fasta)
    right = parse_fasta(args.right_fasta)
    left_map = {}
    right_map = {}
    for header, seq in left:
        left_map.setdefault(seq, []).append(header)
    for header, seq in right:
        right_map.setdefault(seq, []).append(header)

    left_seqs = set(left_map)
    right_seqs = set(right_map)
    overlap = left_seqs & right_seqs
    left_only = left_seqs - right_seqs
    right_only = right_seqs - left_seqs

    print(f'Left entries: {len(left)}')
    print(f'Right entries: {len(right)}')
    print(f'Left unique sequences: {len(left_seqs)}')
    print(f'Right unique sequences: {len(right_seqs)}')
    print(f'Exact overlap sequences: {len(overlap)}')
    print(f'Left-only sequences: {len(left_only)}')
    print(f'Right-only sequences: {len(right_only)}')

    prefix = Path(args.left_fasta).stem + '__' + Path(args.right_fasta).stem
    if args.write_lists:
        Path(f'{prefix}_overlap.txt').write_text('\n'.join(overlap) + ('\n' if overlap else ''), encoding='utf-8')
        Path(f'{prefix}_left_only.txt').write_text('\n'.join(left_only) + ('\n' if left_only else ''), encoding='utf-8')
        Path(f'{prefix}_right_only.txt').write_text('\n'.join(right_only) + ('\n' if right_only else ''), encoding='utf-8')
        print(f'Wrote lists: {prefix}_overlap.txt, {prefix}_left_only.txt, {prefix}_right_only.txt')

    if args.write_fasta:
        overlap_path = f'{prefix}_overlap.fasta'
        left_only_path = f'{prefix}_left_only.fasta'
        right_only_path = f'{prefix}_right_only.fasta'
        write_fasta(overlap_path, {seq: left_map[seq] + right_map[seq] for seq in overlap})
        write_fasta(left_only_path, {seq: left_map[seq] for seq in left_only})
        write_fasta(right_only_path, {seq: right_map[seq] for seq in right_only})
        print(f'Wrote FASTA files: {overlap_path}, {left_only_path}, {right_only_path}')


if __name__ == '__main__':
    main()
