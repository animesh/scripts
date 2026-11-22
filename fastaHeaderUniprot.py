#curl -sS https://ftp.ncbi.nlm.nih.gov/pub/taxonomy/new_taxdump/new_taxdump.tar.gz | tar -xz rankedlineage.dmp
#for %F in ("L:\promec\Animesh\Miriam\Proteomes\Proteome prom NCBI\*.faa") do python fastaHeaderUniprot.py "%F" rankedlineage.dmp
#for %F in ("L:\promec\Animesh\Miriam\Proteomes\Proteome from Madhushri\*.faa") do python fastaHeaderUniprot.py "%F" rankedlineage.dmp
import sys
import re
import os

if len(sys.argv) < 3:
    print("Usage: python fastaHeaderUniprot.py <input_fasta_file> <rankedlineage.dmp>")
    sys.exit(1)

input_file = sys.argv[1]
taxonomy_file = sys.argv[2]

if not os.path.exists(input_file):
    print(f"Error: File not found: {input_file}")
    sys.exit(1)

if not os.path.exists(taxonomy_file):
    print(f"Error: Taxonomy file not found: {taxonomy_file}")
    sys.exit(1)

# Parse rankedlineage.dmp to build species -> taxid mapping
# Format: taxid | species name | rank | ...
species_to_taxid = {}

print(f"Loading taxonomy from {os.path.basename(taxonomy_file)}...")
with open(taxonomy_file, 'r', encoding='utf-8', errors='ignore') as f:
    for line in f:
        parts = [p.strip() for p in line.split('|')]
        if len(parts) >= 2:
            taxid = parts[0]
            # The species name is typically in the full lineage, extract just the species
            lineage = parts[1] if len(parts) > 1 else ""
            # Get the last element (species name) from the lineage
            if lineage:
                species = lineage.split(';')[-1].strip()
                if species and species != "":
                    species_to_taxid[species.lower()] = taxid

print(f"Loaded {len(species_to_taxid)} unique species from taxonomy")

# Generate output filename by inserting ".uniprot" before the extension
base, ext = os.path.splitext(input_file)
output_file = base + ".uniprot.fasta"

# Count sequences in original file
orig_sequence_count = 0
with open(input_file, 'r', encoding='utf-8', errors='ignore') as f:
    for line in f:
        if line.startswith(">"):
            orig_sequence_count += 1

print(f"Original file sequences: {orig_sequence_count}")

def extract_os_from_filename(filename):
    """Extract organism from last two words of filename separated by underscore"""
    if not filename:
        return None
    # Get basename without extension
    basename = os.path.splitext(os.path.basename(filename))[0]
    # Split by underscore and get last two words
    parts = basename.split("_")
    if len(parts) >= 2:
        # Convert underscores to spaces - return as "Genus species"
        organism = f"{parts[-2]} {parts[-1]}"
        return organism
    return None

def extract_organism_from_header(header):
    """Extract organism from [OS=...] or the LAST [...] pair in header"""
    # Look for [OS=...] pattern first
    os_match = re.search(r'\[OS=([^\]]+)\]', header)
    if os_match:
        return os_match.group(1).strip()
    # Look for the LAST [...] pattern which is typically the organism
    last_bracket_match = None
    for match in re.finditer(r'\[([^\[\]]+)\]', header):
        last_bracket_match = match
    if last_bracket_match:
        return last_bracket_match.group(1).strip()
    return None

# Process file
already_matched = set()
species_counts = {}
sequences_with_ox = 0
with open(input_file, 'r', encoding='utf-8', errors='ignore') as infile, open(output_file, 'w', encoding='utf-8') as outfile:
    for line in infile:
        if line.startswith(">"):
            header = line.strip()[1:]
            
            # Try to extract accession (first word/token before space or pipe)
            accession_match = re.match(r'(\S+)', header)
            accession = accession_match.group(1) if accession_match else "UNKNOWN"
            accession = accession.replace(".", "-").upper()
            
            # Extract gene name: first word after ">"
            gn_match = re.match(r'(\S+)', header)
            gn = gn_match.group(1) if gn_match else "UNKNOWN"
            
            # Extract organism: first try from header, then fallback to filename
            organism = extract_organism_from_header(header)
            if not organism:
                organism = extract_os_from_filename(input_file)
            
            if not organism:
                organism = "UNKNOWN"
            
            # Count sequences per species
            if organism not in species_counts:
                species_counts[organism] = 0
            species_counts[organism] += 1
            
            # Look up taxid from taxonomy mapping (exact case-insensitive match)
            ox_value = species_to_taxid.get(organism.lower(), "")
            ox_tag = f" OX={ox_value}" if ox_value else ""
            if ox_value:
                sequences_with_ox += 1
                if organism.lower() not in already_matched:
                    print(f"  Matched: {organism} -> OX={ox_value}")
                    already_matched.add(organism.lower())
            
            # Extract description: everything except the last [...] which typically contains organism
            # Keep all brackets except the last one which is usually [Organism]
            match = re.match(r'^(.+?)\s*\[[^\[\]]*\]\s*$', header)
            if match:
                description = match.group(1).strip()
            else:
                description = re.sub(r'^\S+\s*', '', header).strip()
            
            if not description:
                description = accession
            
            # Build UniProt-style header - format organism as "Genus Species"
            organism_display = " ".join([part.capitalize() for part in organism.split()])
            outfile.write(f">tr|{accession}|{accession}_{organism_display.replace(' ', '_').upper()} {description} OS={organism_display}{ox_tag} GN={gn}\n")
        else:
            # Sequence line → keep only alphabetic characters and uppercase
            cleaned = re.sub(r"[^A-Za-z]", "", line)
            cleaned = cleaned.upper()
            if cleaned:
                outfile.write(cleaned + "\n")

print(f"Matched species: {len(already_matched)}")
for species in already_matched:
    # Find the display version of species name
    for orig_species, count in species_counts.items():
        if orig_species.lower() == species:
            ox_value = species_to_taxid.get(species, "")
            print(f"  {orig_species}: {count} sequences, OX={ox_value}")
            break
print(f"Sequences with OX tag: {sequences_with_ox}")
print(f"Output written to: {output_file}")
