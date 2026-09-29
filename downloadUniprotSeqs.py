#python download_uniprot_wt_sequences.py P55265 Q16666 Q9Y2D5 Q96NB3 Q5SY16 Q8ND56 Q7L513 Q12931
#python download_uniprot_wt_sequences.py ADAR IFI16 PALM2AKAP2 ZNF830 NOL9 LSM14A FCRLA TRAP1 --organism-id 9606
#python download_uniprot_wt_sequences.py --ids-file identifiers.txt --output wt_sequences.fasta

import argparse
import csv
import re
import sys
import time
from pathlib import Path

import requests


UNIPROT_BASE = "https://rest.uniprot.org"
DEFAULT_TIMEOUT_SECONDS = 60
DEFAULT_USER_AGENT = "wt-sequence-downloader/1.0"
ACCESSION_PATTERN = re.compile(
    r"^(?:[OPQ][0-9][A-Z0-9]{3}[0-9]|[A-NR-Z](?:[0-9][A-Z][A-Z0-9]{2}){1,2}[0-9])$"
)


def normalize_identifiers(values):
    """Split comma-separated values, trim whitespace, and preserve input order."""
    normalized = []
    seen = set()
    for value in values:
        for identifier in str(value).split(","):
            identifier = identifier.strip()
            if identifier and identifier not in seen:
                seen.add(identifier)
                normalized.append(identifier)
    return normalized


def read_identifiers_file(path):
    """Read one or more identifiers per line; commas and whitespace are accepted."""
    identifiers = []
    for raw_line in Path(path).read_text(encoding="utf-8-sig").splitlines():
        line = raw_line.split("#", 1)[0].strip()
        if line:
            identifiers.extend(re.split(r"[\s,]+", line))
    return normalize_identifiers(identifiers)


def request_json(session, url, params=None, timeout=DEFAULT_TIMEOUT_SECONDS, retries=3):
    """GET JSON from UniProt with bounded retries for transient failures."""
    last_error = None
    for attempt in range(1, retries + 1):
        try:
            response = session.get(url, params=params, timeout=timeout)
            if response.status_code == 404:
                return None
            response.raise_for_status()
            return response.json()
        except (requests.RequestException, ValueError) as error:
            last_error = error
            if attempt < retries:
                time.sleep(2 ** (attempt - 1))
    raise RuntimeError(f"UniProt request failed after {retries} attempts: {url}: {last_error}")


def primary_gene_name(entry):
    genes = entry.get("genes") or []
    if not genes:
        return ""
    return ((genes[0].get("geneName") or {}).get("value") or "").strip()


def entry_to_record(entry, requested_identifier):
    """Convert a UniProtKB JSON entry into a compact sequence record."""
    sequence_block = entry.get("sequence") or {}
    sequence = (sequence_block.get("value") or "").replace(" ", "").replace("\n", "").upper()
    accession = (entry.get("primaryAccession") or "").strip()
    if not accession or not sequence:
        raise RuntimeError(f"UniProt entry for {requested_identifier!r} lacks accession or sequence data.")

    organism = entry.get("organism") or {}
    description = entry.get("proteinDescription") or {}
    recommended = description.get("recommendedName") or {}
    full_name = ((recommended.get("fullName") or {}).get("value") or "").strip()
    if not full_name:
        submission_names = description.get("submissionNames") or []
        if submission_names:
            full_name = (((submission_names[0].get("fullName") or {}).get("value")) or "").strip()

    return {
        "requested_identifier": requested_identifier,
        "accession": accession,
        "entry_name": (entry.get("uniProtkbId") or "").strip(),
        "gene": primary_gene_name(entry),
        "protein_name": full_name,
        "organism": (organism.get("scientificName") or "").strip(),
        "organism_id": organism.get("taxonId"),
        "reviewed": entry.get("entryType") == "UniProtKB reviewed (Swiss-Prot)",
        "length": int(sequence_block.get("length") or len(sequence)),
        "sequence": sequence,
    }


def select_gene_result(results, identifier, organism_id, reviewed_only=True):
    """Select a unique exact gene-symbol match from UniProt search results."""
    identifier_upper = identifier.upper()
    exact = []
    for entry in results:
        gene = primary_gene_name(entry).upper()
        taxon_id = (entry.get("organism") or {}).get("taxonId")
        is_reviewed = entry.get("entryType") == "UniProtKB reviewed (Swiss-Prot)"
        if gene == identifier_upper and taxon_id == organism_id and (is_reviewed or not reviewed_only):
            exact.append(entry)

    if not exact:
        return None
    if len(exact) > 1:
        accessions = [entry.get("primaryAccession", "?") for entry in exact]
        raise RuntimeError(
            f"Identifier {identifier!r} matched multiple exact UniProt entries for taxon {organism_id}: "
            + ", ".join(accessions)
        )
    return exact[0]


def fetch_identifier(session, identifier, organism_id=9606, reviewed_only=True, timeout=DEFAULT_TIMEOUT_SECONDS):
    """Resolve accessions/entry names directly; resolve gene symbols through search."""
    identifier = identifier.strip()
    looks_like_accession = bool(ACCESSION_PATTERN.fullmatch(identifier.upper()))
    looks_like_entry_name = "_" in identifier

    # UniProt's single-entry endpoint accepts accessions/entry names, not bare gene symbols.
    # Calling /uniprotkb/ADAR.json returns HTTP 400, so gene symbols skip direct lookup.
    if looks_like_accession or looks_like_entry_name:
        direct_url = f"{UNIPROT_BASE}/uniprotkb/{identifier}.json"
        direct_entry = request_json(session, direct_url, timeout=timeout)
        if direct_entry is None:
            raise RuntimeError(f"No UniProtKB entry found for {identifier!r}.")
        record = entry_to_record(direct_entry, identifier)
        if organism_id is not None and record["organism_id"] != organism_id:
            raise RuntimeError(
                f"{identifier!r} resolves to taxon {record['organism_id']} ({record['organism']}), "
                f"not requested taxon {organism_id}."
            )
        if reviewed_only and not record["reviewed"]:
            raise RuntimeError(f"{identifier!r} resolves to an unreviewed UniProtKB entry.")
        return record

    if organism_id is None:
        raise RuntimeError("--organism-id is required when resolving gene symbols.")

    reviewed_clause = " AND (reviewed:true)" if reviewed_only else ""
    query = f"(gene_exact:{identifier}) AND (organism_id:{organism_id}){reviewed_clause}"
    search_data = request_json(
        session,
        f"{UNIPROT_BASE}/uniprotkb/search",
        params={"query": query, "format": "json", "size": 10},
        timeout=timeout,
    )
    results = (search_data or {}).get("results") or []
    selected = select_gene_result(results, identifier, organism_id, reviewed_only=reviewed_only)
    if selected is None:
        qualifier = "reviewed " if reviewed_only else ""
        raise RuntimeError(
            f"No exact {qualifier}UniProtKB match found for gene {identifier!r} in taxon {organism_id}."
        )
    return entry_to_record(selected, identifier)


def download_identifiers(identifiers, organism_id=9606, reviewed_only=True, timeout=DEFAULT_TIMEOUT_SECONDS):
    """Download canonical WT records in input order and reject duplicate accessions."""
    identifiers = normalize_identifiers(identifiers)
    if not identifiers:
        raise ValueError("No identifiers were supplied.")

    records = []
    accession_to_input = {}
    with requests.Session() as session:
        session.headers.update({"User-Agent": DEFAULT_USER_AGENT, "Accept": "application/json"})
        for identifier in identifiers:
            print(f"[DOWNLOAD] {identifier}", flush=True)
            record = fetch_identifier(
                session,
                identifier,
                organism_id=organism_id,
                reviewed_only=reviewed_only,
                timeout=timeout,
            )
            if record["accession"] in accession_to_input:
                first = accession_to_input[record["accession"]]
                raise RuntimeError(
                    f"Inputs {first!r} and {identifier!r} both resolve to {record['accession']}; "
                    "remove the duplicate identifier."
                )
            accession_to_input[record["accession"]] = identifier
            records.append(record)
            print(
                f"[OK] {identifier} -> {record['accession']} | {record['gene']} | "
                f"{record['length']} aa | {record['organism']}",
                flush=True,
            )
    return records


def fasta_header(record, simple_headers=False):
    if simple_headers:
        return record["requested_identifier"]
    reviewed_text = "reviewed" if record["reviewed"] else "unreviewed"
    return (
        f"{record['requested_identifier']}|{record['accession']}|{record['entry_name']} "
        f"gene={record['gene']} organism={record['organism']} taxon={record['organism_id']} "
        f"status={reviewed_text} length={record['length']}"
    )


def write_fasta(records, output_path, width=60, simple_headers=False):
    output_path = Path(output_path)
    with output_path.open("w", encoding="utf-8", newline="\n") as handle:
        for record in records:
            handle.write(f">{fasta_header(record, simple_headers=simple_headers)}\n")
            sequence = record["sequence"]
            for start in range(0, len(sequence), width):
                handle.write(sequence[start:start + width] + "\n")
    return output_path


def write_manifest(records, output_path):
    output_path = Path(output_path)
    fields = [
        "requested_identifier", "accession", "entry_name", "gene", "protein_name",
        "organism", "organism_id", "reviewed", "length",
    ]
    with output_path.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fields, delimiter="\t")
        writer.writeheader()
        for record in records:
            writer.writerow({field: record[field] for field in fields})
    return output_path


parser = argparse.ArgumentParser(
    description="Download canonical wild-type protein sequences from UniProtKB.",
    formatter_class=argparse.ArgumentDefaultsHelpFormatter,
)
parser.add_argument("identifiers", nargs="*", help="UniProt accessions, entry names, or exact gene symbols.")
parser.add_argument("--ids-file", help="Text file containing identifiers separated by whitespace or commas.")
parser.add_argument("--organism-id", type=int, default=9606, help="NCBI taxonomy identifier used for validation/search.")
parser.add_argument("--allow-unreviewed", action="store_true", help="Allow unreviewed UniProtKB entries.")
parser.add_argument("--output", default="wt_sequences.fasta", help="Combined output FASTA path.")
parser.add_argument("--manifest", default="wt_sequences_manifest.tsv", help="Output metadata TSV path.")
parser.add_argument("--simple-headers", action="store_true", help="Use only the requested identifier as the FASTA header.")
parser.add_argument("--timeout", type=int, default=DEFAULT_TIMEOUT_SECONDS, help="HTTP timeout in seconds.")

# REPL-friendly execution: importing with no extra arguments defines all functions without downloading.
cli_tokens = sys.argv[1:]
if cli_tokens:
    cli = parser.parse_args(cli_tokens)
    cli_identifiers = list(cli.identifiers)
    if cli.ids_file:
        cli_identifiers.extend(read_identifiers_file(cli.ids_file))
    cli_identifiers = normalize_identifiers(cli_identifiers)
    if not cli_identifiers:
        parser.error("Provide identifiers positionally or with --ids-file.")

    downloaded_records = download_identifiers(
        cli_identifiers,
        organism_id=cli.organism_id,
        reviewed_only=not cli.allow_unreviewed,
        timeout=cli.timeout,
    )
    fasta_path = write_fasta(downloaded_records, cli.output, simple_headers=cli.simple_headers)
    manifest_path = write_manifest(downloaded_records, cli.manifest)
    print(f"[DONE] FASTA: {fasta_path.resolve()}")
    print(f"[DONE] Manifest: {manifest_path.resolve()}")
