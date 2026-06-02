#python genomeTranslate.py
"""
1. Download nucleotide FASTA from NCBI by accession (via eutils REST, no Biopython)
2. Six-frame translation using a specified NCBI genetic code table (parsed live from NCBI)
3. Download reference proteome from UniProt
4. For each translated segment between stop codons: check if it is a substring
   of any proteome entry.
   - If yes  -> KNOWN
   - If no   -> NOVEL (not in reference proteome)

No biopython, no parasail, no numpy. stdlib + requests only.

Defaults: NC_014373.1 (Ebola virus Bundibugyo ) vs UP000143891 (Ebola Bundibugyo proteome)

Ebola codon notes:n 
  - Uses standard genetic code (table 1): TAA, TAG, TGA are all stops.
  - The GP gene has a transcriptional RNA-editing site (poly-A slippage,
    +1 A insertion) that produces sGP vs full-length GP. This is a
    co-transcriptional event NOT captured by static 6-frame translation.
    Translated GP from genomic DNA produces 
    "...TSQKPFQVKSCLSYLYQEPRIQAATRRRRSLPPASPTTKPPRTTKTWFQRIPLQWFKCETSRGKTQCRPHPQTQSPQL..."
    as "NC_014373.1 strand=+ frame=3 start=6020 len=373aa" skipping ACTTCA... at pos 6976 to
    CTTCAC...  which differs from the mature secreted glycoprotein isoform "...LHKNPFK". 
    Flag this in output.

Usage:
    python genomeTranslate.py [options]
    python genomeTranslate.py --accession NC_014373.1 --proteome-url <url>
    python genomeTranslate.py --genome-fasta ebola.fasta --proteome-fasta proteome.fasta
"""

import argparse
import csv
import html
import re
import sys
import urllib.error
import urllib.request
from pathlib import Path

# ---------------------------------------------------------------------------
# Defaults (Ebola Bundibugyo , NCBI refseq + UniProt reference proteome)
# ---------------------------------------------------------------------------

DEFAULT_ACCESSION = "NC_014373.1"   # Ebola virus Bundibugyo  
DEFAULT_PROTEOME_URL = (
    "https://rest.uniprot.org/uniprotkb/stream"
    "?download=true&format=fasta"
    "&query=%28%28proteome%3AUP000143891%29%29"
)
DEFAULT_CODON_TABLE = 1        # Standard (correct for Ebola)
NCBI_EMAIL = "researcher@institute.edu"  # overridden by --email arg at runtime

# NCBI eutils base
EUTILS = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils"

# ---------------------------------------------------------------------------
# Hard-coded standard genetic code (table 1) as fallback
# Keys: RNA codons (U not T); value: single-letter AA or '*' for stop
# ---------------------------------------------------------------------------

STANDARD_CODE_RNA = {
    'UUU':'F','UUC':'F','UUA':'L','UUG':'L',
    'UCU':'S','UCC':'S','UCA':'S','UCG':'S',
    'UAU':'Y','UAC':'Y','UAA':'*','UAG':'*',
    'UGU':'C','UGC':'C','UGA':'*','UGG':'W',
    'CUU':'L','CUC':'L','CUA':'L','CUG':'L',
    'CCU':'P','CCC':'P','CCA':'P','CCG':'P',
    'CAU':'H','CAC':'H','CAA':'Q','CAG':'Q',
    'CGU':'R','CGC':'R','CGA':'R','CGG':'R',
    'AUU':'I','AUC':'I','AUA':'I','AUG':'M',
    'ACU':'T','ACC':'T','ACA':'T','ACG':'T',
    'AAU':'N','AAC':'N','AAA':'K','AAG':'K',
    'AGU':'S','AGC':'S','AGA':'R','AGG':'R',
    'GUU':'V','GUC':'V','GUA':'V','GUG':'V',
    'GCU':'A','GCC':'A','GCA':'A','GCG':'A',
    'GAU':'D','GAC':'D','GAA':'E','GAG':'E',
    'GGU':'G','GGC':'G','GGA':'G','GGG':'G',
}

# DNA version (T instead of U) -- used internally
CODON_TABLE_DNA = {k.replace('U','T'): v for k, v in STANDARD_CODE_RNA.items()}


# ---------------------------------------------------------------------------
# Fetch NCBI genetic code table (optional enhancement -- fetch alternate tables)
# ---------------------------------------------------------------------------

def fetch_ncbi_codon_table(table_num: int) -> dict:
    """Fetch or return a DNA codon table for the requested NCBI table."""
    if table_num == 1:
        print(f"[codon] Using hard-coded standard genetic code (table 1).")
        _print_stop_codons(CODON_TABLE_DNA)
        return CODON_TABLE_DNA

    print(f"[codon] Downloading NCBI genetic code table {table_num} ...")
    gc_url = "https://www.ncbi.nlm.nih.gov/IEB/ToolBox/C_DOC/lxr/source/data/gc.prt"
    try:
        gc_text = http_get(gc_url, f"NCBI genetic code table {table_num}")
        gc_text = _extract_raw_gc_text(gc_text)
        table = _parse_gc_prt(gc_text, table_num)
        if table:
            print(f"[codon] Loaded NCBI genetic code table {table_num} ({len(table)} codons).")
            _print_stop_codons(table)
            return table
        print(f"[codon] Genetic code table {table_num} not found in NCBI data; using table 1 fallback.")
    except Exception as e:
        print(f"[codon] Could not download table {table_num}: {e}. Using table 1 fallback.")

    _print_stop_codons(CODON_TABLE_DNA)
    return CODON_TABLE_DNA


def _extract_raw_gc_text(text: str) -> str:
    if '<pre class="filecontent-src">' not in text:
        return text
    match = re.search(r'<pre class="filecontent-src">(.*?)</pre>', text, re.S)
    if not match:
        return text
    raw = match.group(1)
    raw = html.unescape(raw)
    raw = re.sub(r'<[^>]+>', '', raw)
    return raw


def _parse_gc_prt(text: str, table_num: int) -> dict:
    lines = text.splitlines()
    block = []
    active = False
    id_pattern = re.compile(r"^\s*id\s+%d\b" % table_num)
    next_id = re.compile(r"^\s*id\s+\d+\b")
    for line in lines:
        if not active and id_pattern.search(line):
            active = True
            block.append(line)
            continue
        if active:
            if next_id.search(line) and not id_pattern.search(line):
                break
            block.append(line)
    if not block:
        return {}

    block_text = "\n".join(block)
    aa_line = _extract_value(block_text, "ncbieaa")
    base1 = _extract_value(block_text, "-- Base1")
    base2 = _extract_value(block_text, "-- Base2")
    base3 = _extract_value(block_text, "-- Base3")
    if not (aa_line and base1 and base2 and base3):
        return {}
    if len(aa_line) != 64 or len(base1) != 64 or len(base2) != 64 or len(base3) != 64:
        return {}

    table = {}
    for i, aa in enumerate(aa_line):
        codon = base1[i] + base2[i] + base3[i]
        table[codon] = aa
    return {k.replace('U', 'T'): v for k, v in table.items()}


def _extract_value(text: str, key: str) -> str:
    idx = text.find(key)
    if idx == -1:
        return ""
    sub = text[idx + len(key):]
    line = sub.splitlines()[0].strip()
    if '"' in line:
        q1 = line.find('"')
        q2 = line.find('"', q1 + 1)
        if q1 != -1 and q2 != -1:
            return line[q1 + 1:q2]
    return line.rstrip(',')


def _print_stop_codons(table: dict):
    stops = [c for c, aa in table.items() if aa == '*']
    print(f"[codon] Stop codons in this table: {', '.join(sorted(stops))}")
    if set(stops) == {'TAA', 'TAG', 'TGA'}:
        print("[codon] All three standard stops active (correct for Ebola/most viruses).")
    else:
        reassigned = {'TAA','TAG','TGA'} - set(stops)
        if reassigned:
            print(f"[codon] WARNING: {reassigned} are NOT stops in this table -- codon reassignment detected.")


# ---------------------------------------------------------------------------
# Sequence download
# ---------------------------------------------------------------------------

def http_get(url: str, label: str = "") -> str:
    req = urllib.request.Request(
        url,
        headers={"User-Agent": f"genome/1.0 ({NCBI_EMAIL})"}
    )
    try:
        with urllib.request.urlopen(req, timeout=120) as resp:
            return resp.read().decode("utf-8", errors="replace")
    except urllib.error.HTTPError as e:
        sys.exit(f"[error] HTTP {e.code} fetching {label or url}: {e.reason}")
    except Exception as e:
        sys.exit(f"[error] Could not fetch {label or url}: {e}")


def fetch_genome_fasta(accession: str) -> str:
    print(f"[fetch] Downloading genome {accession} from NCBI eutils ...")
    url = (f"{EUTILS}/efetch.fcgi"
           f"?db=nuccore&id={accession}&rettype=fasta&retmode=text&email={NCBI_EMAIL}")
    text = http_get(url, accession)
    if not text.startswith(">"):
        sys.exit(f"[error] NCBI returned unexpected content for {accession}:\n{text[:200]}")
    return text


def fetch_proteome_fasta(url: str) -> str:
    print(f"[fetch] Downloading proteome from UniProt ...")
    return http_get(url, "UniProt proteome")


# ---------------------------------------------------------------------------
# FASTA parser (no biopython)
# ---------------------------------------------------------------------------

def parse_fasta(text: str) -> list:
    """Returns list of (header, sequence) tuples."""
    records = []
    header = None
    seq_parts = []
    for line in text.splitlines():
        line = line.strip()
        if not line:
            continue
        if line.startswith(">"):
            if header is not None:
                records.append((header, "".join(seq_parts).upper()))
            header = line[1:]
            seq_parts = []
        else:
            seq_parts.append(line)
    if header is not None:
        records.append((header, "".join(seq_parts).upper()))
    return records


# ---------------------------------------------------------------------------
# Reverse complement
# ---------------------------------------------------------------------------

COMPLEMENT = str.maketrans("ACGTN", "TGCAN")

def revcomp(seq: str) -> str:
    return seq.translate(COMPLEMENT)[::-1]


# ---------------------------------------------------------------------------
# Six-frame translation
# ---------------------------------------------------------------------------

def translate_frame(seq: str, codon_table: dict) -> list:
    """
    Translate a single reading frame.
    Returns list of (start_nt, segment_aa) for each inter-stop segment.
    start_nt is 0-based position in the supplied seq.
    Includes even single-aa segments (no length filter).
    """
    segments = []
    n = len(seq)
    i = 0
    seg_start = 0
    aa_buf = []
    while i + 3 <= n:
        codon = seq[i:i+3]
        aa = codon_table.get(codon, 'X')   # X for unknown/ambiguous
        if aa == '*':
            # emit segment (may be empty if two stops are adjacent)
            if aa_buf:
                segments.append((seg_start, "".join(aa_buf)))
            seg_start = i + 3
            aa_buf = []
        else:
            aa_buf.append(aa)
        i += 3
    # emit trailing segment (no stop codon at end -- common for incomplete seqs)
    if aa_buf:
        segments.append((seg_start, "".join(aa_buf)))
    return segments


def six_frame_translate(header: str, seq: str, codon_table: dict) -> list:
    """
    Translate all 6 frames.
    Returns list of dicts with keys:
        seq_id, strand, frame, start_nt, length_aa, sequence_aa
    """
    results = []
    acc = header.split()[0]
    seq_len = len(seq)

    strands = [(seq, '+'), (revcomp(seq), '-')]
    for strand_seq, strand_label in strands:
        for frame in range(3):
            segments = translate_frame(strand_seq[frame:], codon_table)
            for (seg_start_in_frame, aa_seq) in segments:
                raw_start = frame + seg_start_in_frame
                if strand_label == '+':
                    nt_start = raw_start
                else:
                    # convert back to forward-strand coordinates
                    nt_start = seq_len - raw_start - len(aa_seq) * 3
                results.append({
                    "seq_id": acc,
                    "strand": strand_label,
                    "frame": frame + 1,
                    "start_nt": nt_start,
                    "length_aa": len(aa_seq),
                    "sequence_aa": aa_seq,
                })
    return results


def translate_frame_orfs(seq: str, codon_table: dict) -> list:
    """Translate every Met codon in a frame to the next stop codon."""
    results = []
    n = len(seq)
    for i in range(0, n - 2, 3):
        codon = seq[i:i+3]
        if codon_table.get(codon, 'X') != 'M':
            continue
        aa_buf = ['M']
        j = i + 3
        while j + 3 <= n:
            codon = seq[j:j+3]
            aa = codon_table.get(codon, 'X')
            if aa == '*':
                results.append((i, ''.join(aa_buf)))
                break
            aa_buf.append(aa)
            j += 3
        else:
            # reached end of sequence without a stop codon
            results.append((i, ''.join(aa_buf)))
    return results


def six_frame_translate_orfs(header: str, seq: str, codon_table: dict) -> list:
    results = []
    acc = header.split()[0]
    seq_len = len(seq)

    strands = [(seq, '+'), (revcomp(seq), '-')]
    for strand_seq, strand_label in strands:
        for frame in range(3):
            segments = translate_frame_orfs(strand_seq[frame:], codon_table)
            for seg_start_in_frame, aa_seq in segments:
                raw_start = frame + seg_start_in_frame
                if strand_label == '+':
                    nt_start = raw_start
                else:
                    nt_start = seq_len - raw_start - len(aa_seq) * 3
                results.append({
                    "seq_id": acc,
                    "strand": strand_label,
                    "frame": frame + 1,
                    "start_nt": nt_start,
                    "length_aa": len(aa_seq),
                    "sequence_aa": aa_seq,
                })
    return results


# ---------------------------------------------------------------------------
# Proteome index for fast substring lookup
# ---------------------------------------------------------------------------

def build_proteome_concat(proteome_records: list) -> tuple:
    """
    Concatenate all proteome sequences with a rare separator.
    Returns (concat_string, list_of_(uniprot_id, start_in_concat, end_in_concat)).
    Substring search in the concatenated string finds matches across the whole proteome
    without matching across protein boundaries (separator prevents cross-boundary hits).
    """
    SEP = "BBBBB"   # B is not a standard AA -- acts as boundary sentinel
    parts = []
    index = []
    pos = 0
    for header, seq in proteome_records:
        uid = header.split("|")[1] if "|" in header else header.split()[0]
        start = pos
        parts.append(seq)
        end = pos + len(seq)
        index.append((uid, start, end))
        pos = end + len(SEP)
        parts.append(SEP)
    concat = "".join(parts)
    return concat, index


def find_hit(aa_seq: str, concat: str, index: list) -> tuple:
    """
    Check if aa_seq is a substring of the concatenated proteome.
    Returns (hit_uid, position_in_protein) or (None, None).
    """
    if not aa_seq:
        return None, None
    pos = concat.find(aa_seq)
    if pos == -1:
        return None, None
    # find which protein this falls in
    for uid, start, end in index:
        if start <= pos < end:
            return uid, pos - start
    return "cross-boundary", pos   # should not happen with SEP


def find_exact_proteome_matches(translated_segs: list, proteome_records: list) -> list:
    """Return a list of proteome entries whose full sequence exactly matches a translated segment."""
    seq_map = {}
    for seg in translated_segs:
        aa = seg.get("sequence_aa")
        if aa:
            seq_map.setdefault(aa, []).append(seg)

    matches = []
    for header, seq in proteome_records:
        if not seq:
            continue
        if seq in seq_map:
            for seg in seq_map[seq]:
                matches.append({
                    "uniprot_header": header,
                    "seq_id": seg["seq_id"],
                    "strand": seg["strand"],
                    "frame": seg["frame"],
                    "start_nt": seg["start_nt"],
                    "length_aa": seg["length_aa"],
                })
    return matches


def extract_uniprot_id(header: str) -> str:
    return header.split("|")[1] if "|" in header else header.split()[0]


def find_unmatched_proteins(proteome_records: list, matched_uids: set) -> list:
    return [
        (header, seq)
        for header, seq in proteome_records
        if extract_uniprot_id(header) not in matched_uids
    ]


# ---------------------------------------------------------------------------
# Output
# ---------------------------------------------------------------------------

def write_tsv(rows: list, path: Path, fieldnames: list):
    with path.open("w", newline="") as fh:
        writer = csv.DictWriter(fh, fieldnames=fieldnames, delimiter="\t",
                                extrasaction="ignore")
        writer.writeheader()
        writer.writerows(rows)
    print(f"[out] {path}  ({len(rows)} rows)")


def print_summary(all_segments: list, novel: list, known: list, accession: str):
    print()
    print("=" * 70)
    print("SUMMARY")
    print("=" * 70)
    print(f"  Accession              : {accession}")
    print(f"  Total translated segs  : {len(all_segments)}")
    print(f"  Known (in proteome)    : {len(known)}")
    print(f"  Novel (not in proteome): {len(novel)}")
    if novel:
        lengths = [r['length_aa'] for r in novel]
        print(f"  Novel length range     : {min(lengths)}-{max(lengths)} aa")
        print(f"  Novel length mean      : {sum(lengths)/len(lengths):.1f} aa")
    print()
    print("  NOTE: Ebola GP gene has a transcriptional RNA-editing site")
    print("  (+1 A insertion in poly-A tract) producing sGP vs full-length GP.")
    print("  Static 6-frame translation cannot capture this isoform -- the")
    print("  genomic GP ORF will not match the secreted glycoprotein sequence.")
    print("=" * 70)


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    global NCBI_EMAIL

    parser = argparse.ArgumentParser(
        description="6-frame translation + proteome substring comparison. "
                    "Flags translated segments as KNOWN or NOVEL w.r.t. a reference proteome.",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    parser.add_argument("--accession", default=DEFAULT_ACCESSION,
                        help="NCBI nucleotide accession")
    parser.add_argument("--proteome-url", default=DEFAULT_PROTEOME_URL,
                        help="UniProt proteome stream URL")
    parser.add_argument("--proteome-fasta", default=None,
                        help="Local proteome FASTA (overrides --proteome-url)")
    parser.add_argument("--genome-fasta", default=None,
                        help="Local genome FASTA (overrides --accession download)")
    parser.add_argument("--table", type=int, default=DEFAULT_CODON_TABLE,
                        help="NCBI genetic code table (1=Standard, 11=Bacterial/Phage)")
    parser.add_argument("--email", default=NCBI_EMAIL,
                        help="Email for NCBI Entrez (required by NCBI policy)")
    parser.add_argument("--out-dir", default=".", type=Path,
                        help="Output directory")
    args = parser.parse_args()
    NCBI_EMAIL = args.email

    out_dir = Path(args.out_dir)
    out_dir.mkdir(parents=True, exist_ok=True)

    print(f"\n{'='*70}")
    print(f"  genomeTranslate.py  --  6-frame translation + proteome comparison")
    print(f"  Accession    : {args.accession}")
    print(f"  Codon table  : {args.table}")
    print(f"{'='*70}\n")

    # --- codon table ---
    codon_table = fetch_ncbi_codon_table(args.table)

    # --- genome ---
    if args.genome_fasta:
        print(f"[genome] Reading {args.genome_fasta}")
        genome_text = Path(args.genome_fasta).read_text()
    else:
        genome_text = fetch_genome_fasta(args.accession)
        gpath = out_dir / f"{args.accession}.fasta"
        gpath.write_text(genome_text)
        print(f"[genome] Saved -> {gpath}")

    genome_records = parse_fasta(genome_text)
    print(f"[genome] {len(genome_records)} sequence(s) loaded.")
    for h, s in genome_records:
        print(f"         {h.split()[0]}  len={len(s)} bp")

    # --- 6-frame translation ---
    print(f"\n[translate] 6-frame translation across all sequences ...")
    all_segments = []
    for header, seq in genome_records:
        segs = six_frame_translate(header, seq, codon_table)
        print(f"  {header.split()[0]}: {len(segs)} segments across 6 frames")
        all_segments.extend(segs)
    print(f"  Total segments: {len(all_segments)}")

    # save all translated segments as FASTA
    fasta_lines = []
    for i, seg in enumerate(all_segments):
        seg["segment_num"] = i + 1
        fasta_lines.append(
            f">{seg['seq_id']}_seg{i+1} strand={seg['strand']} "
            f"frame={seg['frame']} start={seg['start_nt']} len={seg['length_aa']}aa"
        )
        aa = seg["sequence_aa"]
        for j in range(0, len(aa), 60):
            fasta_lines.append(aa[j:j+60])
    trans_fasta = out_dir / f"{args.accession}_6frame.fasta"
    trans_fasta.write_text("\n".join(fasta_lines) + "\n")
    print(f"[out] 6-frame FASTA -> {trans_fasta}")

    # --- ORFs from first Methionine to stop codon ---
    print(f"\n[orf] Extracting first Met-to-stop ORFs across 6 frames ...")
    all_orfs = []
    for header, seq in genome_records:
        segs = six_frame_translate_orfs(header, seq, codon_table)
        print(f"  {header.split()[0]}: {len(segs)} ORF(s) across 6 frames")
        all_orfs.extend(segs)
    print(f"  Total ORFs: {len(all_orfs)}")

    orf_lines = []
    for i, seg in enumerate(all_orfs):
        seg["segment_num"] = i + 1
        orf_lines.append(
            f">{seg['seq_id']}_orf{i+1} strand={seg['strand']} "
            f"frame={seg['frame']} start={seg['start_nt']} len={seg['length_aa']}aa"
        )
        aa = seg["sequence_aa"]
        for j in range(0, len(aa), 60):
            orf_lines.append(aa[j:j+60])
    orf_fasta = out_dir / f"{args.accession}_6frame_orfs.fasta"
    orf_fasta.write_text("\n".join(orf_lines) + "\n")
    print(f"[out] ORF FASTA -> {orf_fasta}")

    # --- proteome ---
    if args.proteome_fasta:
        print(f"\n[proteome] Reading {args.proteome_fasta}")
        proteome_text = Path(args.proteome_fasta).read_text()
    else:
        proteome_text = fetch_proteome_fasta(args.proteome_url)
        ppath = out_dir / f"{args.accession}_proteome.fasta"
        ppath.write_text(proteome_text)
        print(f"[proteome] Saved -> {ppath}")

    proteome_records = parse_fasta(proteome_text)
    print(f"[proteome] {len(proteome_records)} protein entries loaded.")

    # --- reverse exact-match checks ---
    reverse_matches = find_exact_proteome_matches(all_segments, proteome_records)
    orf_reverse_matches = find_exact_proteome_matches(all_orfs, proteome_records)
    if reverse_matches:
        print(f"\n[reverse] Exact proteome matches found for translated segments:")
        for match in reverse_matches:
            print(
                f"  {match['uniprot_header']} -> "
                f"{match['seq_id']} strand={match['strand']} frame={match['frame']} "
                f"start={match['start_nt']} len={match['length_aa']}aa"
            )
    else:
        print(f"\n[reverse] No exact proteome matches found for translated segments.")
    if orf_reverse_matches:
        print(f"\n[reverse] Exact proteome matches found for ORF segments:")
        for match in orf_reverse_matches:
            print(
                f"  {match['uniprot_header']} -> "
                f"{match['seq_id']} strand={match['strand']} frame={match['frame']} "
                f"start={match['start_nt']} len={match['length_aa']}aa"
            )
    else:
        print(f"\n[reverse] No exact proteome matches found for ORF segments.")

    # --- build index ---
    print(f"\n[compare] Building proteome substring index ...")
    concat, prot_index = build_proteome_concat(proteome_records)
    print(f"[compare] Concatenated proteome: {len(concat):,} chars. Searching ...")

    # --- compare ---
    known = []
    novel = []
    for seg in all_segments:
        hit_uid, hit_pos = find_hit(seg["sequence_aa"], concat, prot_index)
        row = {
            "segment_num": seg["segment_num"],
            "seq_id": seg["seq_id"],
            "strand": seg["strand"],
            "frame": seg["frame"],
            "start_nt": seg["start_nt"],
            "length_aa": seg["length_aa"],
            "status": "KNOWN" if hit_uid else "NOVEL",
            "hit_uniprot_id": hit_uid or "",
            "hit_position_in_protein": hit_pos if hit_pos is not None else "",
        }
        if hit_uid:
            known.append(row)
        else:
            novel.append(row)

    matched_proteins = set()
    orf_known = []
    orf_novel = []
    for seg in all_orfs:
        hit_uid, hit_pos = find_hit(seg["sequence_aa"], concat, prot_index)
        row = {
            "segment_num": seg["segment_num"],
            "seq_id": seg["seq_id"],
            "strand": seg["strand"],
            "frame": seg["frame"],
            "start_nt": seg["start_nt"],
            "length_aa": seg["length_aa"],
            "status": "KNOWN" if hit_uid else "NOVEL",
            "hit_uniprot_id": hit_uid or "",
            "hit_position_in_protein": hit_pos if hit_pos is not None else "",
        }
        if hit_uid:
            orf_known.append(row)
            matched_proteins.add(hit_uid)
        else:
            orf_novel.append(row)

    # include all segment hits as matched
    matched_proteins.update(r["hit_uniprot_id"] for r in known if r["hit_uniprot_id"])

    # look for unmatched UniProt sequences
    unmatched_proteins = find_unmatched_proteins(proteome_records, matched_proteins)
    if unmatched_proteins:
        print(f"\n[reverse] UniProt sequences with no translated match anywhere: {len(unmatched_proteins)}")
        for header, seq in unmatched_proteins:
            print(f"  {header}")
        unmatched_fasta = out_dir / f"{args.accession}_unmatched_proteins.fasta"
        with unmatched_fasta.open("w") as fh:
            for header, seq in unmatched_proteins:
                fh.write(f">{header}\n{seq}\n")
        print(f"[out] Unmatched UniProt sequences -> {unmatched_fasta}")

    # --- output ---
    fields = ["segment_num","seq_id","strand","frame","start_nt","length_aa",
              "status","hit_uniprot_id","hit_position_in_protein"]
    write_tsv(known + novel, out_dir / f"{args.accession}_comparison.tsv", fields)
    write_tsv(novel, out_dir / f"{args.accession}_novel.tsv", fields)
    write_tsv(known, out_dir / f"{args.accession}_known.tsv", fields)
    write_tsv(orf_known + orf_novel, out_dir / f"{args.accession}_orf_comparison.tsv", fields)
    write_tsv(orf_novel, out_dir / f"{args.accession}_orf_novel.tsv", fields)
    write_tsv(orf_known, out_dir / f"{args.accession}_orf_known.tsv", fields)

    if reverse_matches:
        reverse_fields = ["uniprot_header","seq_id","strand","frame","start_nt","length_aa"]
        write_tsv(reverse_matches, out_dir / f"{args.accession}_reverse_matches.tsv", reverse_fields)
    if orf_reverse_matches:
        reverse_fields = ["uniprot_header","seq_id","strand","frame","start_nt","length_aa"]
        write_tsv(orf_reverse_matches, out_dir / f"{args.accession}_orf_reverse_matches.tsv", reverse_fields)

    print_summary(all_segments, novel, known, args.accession)


if __name__ == "__main__":
    main()
