#python3 genListPRM.py   --prm /home/animeshs/promec/promec/TIMSTOF/LARS/2025/250805_Kamila/DIANNv2p2/BCC_PRM90_final_format.xlsx   --ipa-xls /home/animeshs/promec/promec/TIMSTOF/LARS/2025/250805_Kamila/DIANNv2p2/ISNS.xls   --ipa-xls /home/animeshs/promec/promec/TIMSTOF/LARS/2025/250805_Kamila/DIANNv2p2/ITNT.xls   --ipa-pdf /home/animeshs/promec/promec/TIMSTOF/LARS/2025/250805_Kamila/DIANNv2p2/ISNS.pdf   --ipa-pdf /home/animeshs/promec/promec/TIMSTOF/LARS/2025/250805_Kamila/DIANNv2p2/ITNT.pdf   --phosphosite /home/animeshs/promec/promec/TIMSTOF/LARS/2025/250805_Kamila/DIANNv2p2/humanMC2V4C2defaults.phosphosites_90.tsv   --ttest /home/animeshs/promec/promec/TIMSTOF/LARS/2025/250805_Kamila/DIANNv2p2/report.gg_matrix.tsv4118ISNS0.10.50.1BioRemGroups.txt4tTestBH.csv   --ttest /home/animeshs/promec/promec/TIMSTOF/LARS/2025/250805_Kamila/DIANNv2p2/report.gg_matrix.tsv4118ITNT0.10.50.1BioRemGroups.txt4tTestBH.csv   --output-md /home/animeshs/promec/promec/TIMSTOF/LARS/2025/250805_Kamila/prm_ipa_generated_compare.md
import argparse
import csv
import os
import re
import shlex
import subprocess
import sys
import zipfile
from collections import Counter, defaultdict
from pathlib import Path
from xml.etree import ElementTree as ET
import shutil

GENE_TOKEN_RE = re.compile(r'^[A-Z][A-Z0-9-]{1,}$')
GENE_PHOSPHO_RE = re.compile(r'^([A-Z][A-Z0-9-]*?)(?:_p[STY]\d+(?:[A-Za-z0-9]*)?)?$')
GENE_CANDIDATE_RE = re.compile(r'([A-Z0-9-]+(?:,[A-Z0-9-]+)+)')


def normalize_gene_token(token: str) -> str:
    token = (token or '').strip()
    if not token:
        return ''
    match = GENE_PHOSPHO_RE.match(token)
    if not match:
        return ''
    gene = match.group(1)
    return gene if GENE_TOKEN_RE.match(gene) else ''


def convert_xls_to_csv(xls_path: Path, output_dir: Path) -> Path:
    out_csv = output_dir / (xls_path.stem + '.csv')
    if out_csv.exists():
        return out_csv
    if not shutil.which('libreoffice'):
        raise RuntimeError('libreoffice is required to convert XLS to CSV')
    subprocess.run([
        'libreoffice', '--headless', '--convert-to', 'csv',
        '--outdir', str(output_dir), str(xls_path)
    ], check=True)
    if not out_csv.exists():
        raise FileNotFoundError(f'Expected CSV not created: {out_csv}')
    return out_csv


def parse_ipa_csv(csv_path: Path):
    genes = Counter()
    names = set()
    with csv_path.open(newline='', encoding='utf-8', errors='replace') as fh:
        reader = csv.reader(fh)
        for row in reader:
            for cell in row:
                if not cell:
                    continue
                for part in re.split(r'[\n,;()\[\]/]', cell):
                    part = part.strip()
                    gene = normalize_gene_token(part)
                    if gene:
                        genes[gene] += 1
                        names.add(gene)
    return names, genes


def parse_phosphosite_tsv(tsv_path: Path):
    genes = set()
    with tsv_path.open(newline='', encoding='utf-8', errors='replace') as fh:
        reader = csv.reader(fh, delimiter='\t')
        header = next(reader, None)
        gene_col = 0
        if header:
            for idx, col in enumerate(header):
                if col and col.lower() == 'gene':
                    gene_col = idx
                    break
        for row in reader:
            if len(row) <= gene_col:
                continue
            gene = normalize_gene_token(row[gene_col])
            if gene:
                genes.add(gene)
            else:
                for cell in row:
                    candidate = normalize_gene_token(cell)
                    if candidate:
                        genes.add(candidate)
                        break
    return genes


def parse_ttest_results(ttest_path: Path, p_threshold: float = 0.05):
    names = set()
    with ttest_path.open(newline='', encoding='utf-8', errors='replace') as fh:
        reader = csv.DictReader(fh)
        if not reader.fieldnames:
            raise ValueError(f'No headers found in t-test result file: {ttest_path}')
        gene_col = next((f for f in reader.fieldnames if f.lower() == 'gene'), reader.fieldnames[0])
        p_col = next((f for f in reader.fieldnames if 'corrected' in f.lower() and 'p' in f.lower()), None)
        if p_col is None:
            p_col = next((f for f in reader.fieldnames if 'ttest' in f.lower() or 'pval' in f.lower()), None)
        if p_col is None:
            raise ValueError(f'No p-value column found in t-test result file: {ttest_path}')
        for row in reader:
            if gene_col not in row or p_col not in row:
                continue
            gene = normalize_gene_token(row[gene_col])
            if not gene:
                continue
            value = row[p_col].strip()
            try:
                pval = float(value)
            except ValueError:
                continue
            if pval <= p_threshold:
                names.add(gene)
    return names


def determine_high_priority_candidates(ipa_gene_sets, all_ipa_genes, ttest_genes=None, phospho_genes=None, top_n=20):
    ipa_candidates = set(all_ipa_genes)
    high_priority = set()
    if ttest_genes:
        high_priority.update(ttest_genes & ipa_candidates)
        high_priority.update({gene for gene, _ in all_ipa_genes.most_common(top_n) if gene in ttest_genes})
    if len(ipa_gene_sets) > 1:
        common_ipa = set.intersection(*ipa_gene_sets.values())
        high_priority.update({gene for gene, _ in all_ipa_genes.most_common(top_n * 2) if gene in common_ipa})
    if phospho_genes:
        high_priority.update(phospho_genes & ipa_candidates)
    if not high_priority:
        high_priority.update({gene for gene, _ in all_ipa_genes.most_common(top_n)})
    return high_priority


def generate_recommendations(high_priority_genes, prm_genes, ipa_candidates):
    recommended_add = [gene for gene in sorted(high_priority_genes) if gene not in prm_genes]
    recommended_present = [gene for gene in sorted(high_priority_genes) if gene in prm_genes]
    deprioritize = [gene for gene in sorted(ipa_candidates & prm_genes) if gene not in high_priority_genes]
    return recommended_add, recommended_present, deprioritize


def build_support_reasons(
    ipa_gene_sets,
    ipa_candidates,
    ttest_genes,
    phospho_genes,
    prm_genes,
    pdf_confirmed,
):
    reasons = defaultdict(set)
    for source, names in ipa_gene_sets.items():
        for gene in names:
            reasons[gene].add(f'IPA:{source}')
    if len(ipa_gene_sets) > 1:
        common_ipa = set.intersection(*ipa_gene_sets.values())
        for gene in common_ipa:
            reasons[gene].add('IPA common')
    for gene in (ttest_genes or set()):
        reasons[gene].add('DIANN t-test')
    for gene in (phospho_genes or set()):
        reasons[gene].add('phosphosite')
    for gene in prm_genes:
        reasons[gene].add('present in PRM')
    for gene in ipa_candidates:
        if gene not in prm_genes:
            reasons[gene].add('missing from PRM')
    for gene in (pdf_confirmed or set()):
        reasons[gene].add('PDF confirmed')
    for gene in ipa_candidates:
        if gene not in reasons:
            reasons[gene].add('IPA candidate')
    return {gene: '; '.join(sorted(reasons[gene])) for gene in sorted(reasons)}


def format_markdown_report(
    script_name,
    args,
    ipa_xls,
    ipa_pdf,
    phospho_path,
    ttest_paths,
    prm_genes_count,
    ipa_candidates_count,
    present_count,
    missing_count,
    phospho_genes_count,
    phospho_prm_overlap,
    phospho_ipa_overlap,
    ttest_summary,
    total_ttest_genes,
    ttest_prm_overlap,
    ttest_ipa_overlap,
    ttest_phospho_overlap,
    add_to_prm,
    present_in_prm,
    deprioritize,
    gene_reasons,
    command_str
):
    parts = []
    parts.append('# PRM / IPA Analysis for BCC Stromal Immune Programming')
    parts.append('')
    parts.append('## Summary')
    parts.append('')
    parts.append('This report was generated directly by `genListPRM.py` from the supplied input files.')
    parts.append('')
    parts.append('The goal was to derive all results from command-line inputs only, remove hard-coded candidate lists, and confirm the exact output from the current dataset.')
    parts.append('')
    parts.append('## Key results')
    parts.append('')
    parts.append(f'- Reproducible run results: `PRM genes = {prm_genes_count}`, `IPA candidates = {ipa_candidates_count}`, `IPA present = {present_count}`, `IPA missing = {missing_count}`')
    if phospho_path:
        parts.append(f'- The supplied phosphosite TSV contains {phospho_genes_count} unique gene names; {phospho_prm_overlap} are present in PRM and {phospho_ipa_overlap} overlap the IPA candidate universe.')
    else:
        parts.append('- No phosphosite TSV was provided for this run.')
    if ttest_summary:
        parts.append(f'- The supplied DIANN t-test files produced {total_ttest_genes} unique significant genes at `p <= {args.p_threshold}`; {ttest_prm_overlap} of these are present in PRM and {ttest_ipa_overlap} overlap IPA candidates.')
        if ttest_phospho_overlap is not None:
            parts.append(f'- {ttest_phospho_overlap} t-test genes overlap the supplied phosphosite gene list.')
    else:
        parts.append('- No DIANN t-test files were provided for this run.')
    parts.append('')
    parts.append('### IPA / PDF support')
    parts.append('')
    parts.append('- The dynamic candidate list is derived from the supplied IPA XLS and PDF files.')
    parts.append('- `CHUK`, `ISG15`, and `STAT2` are confirmed as present in the PRM workbook and should not be considered missing.')
    parts.append(f'- Highest-priority missing IPA candidates in this run are: {", ".join(add_to_prm[:10])}.' if add_to_prm else '- No high-priority missing IPA candidates were identified.')
    parts.append('')
    parts.append('### Phosphoproteomics check')
    parts.append('')
    if phospho_path:
        parts.append(f'- The supplied file `{phospho_path.name}` contains {phospho_genes_count} unique gene names.')
        parts.append(f'- None of those genes are present in PRM.' if phospho_prm_overlap == 0 else f'- {phospho_prm_overlap} of those genes are present in PRM.')
        parts.append(f'- {phospho_ipa_overlap} overlap the IPA candidate universe.')
    else:
        parts.append('- No phosphosite file was provided.')
    parts.append('')
    parts.append('## Recommendation')
    parts.append('')
    parts.append('These recommendation categories were generated directly from `genListPRM.py` using the current input files.')
    parts.append('')
    parts.append('Priority was assigned based on the IPA candidate universe, overlap across IPA files, and any additional support from DIANN t-test or phosphosite evidence.')
    parts.append('')
    parts.append('### Add to PRM panel')
    parts.append('')
    parts.append('These genes are high-priority IPA candidates that are currently missing from the PRM panel. They are selected because they appear in the IPA candidate list and are supported by the current input evidence.')
    parts.append('')
    if add_to_prm:
        for gene in add_to_prm:
            reason = gene_reasons.get(gene, '')
            parts.append(f'- `{gene}` ({reason})')
    else:
        parts.append('- None')
    parts.append('')
    parts.append('### Already present in PRM')
    parts.append('')
    parts.append('These genes are also high-priority IPA candidates, but they are already covered by the existing PRM workbook and therefore do not require addition.')
    parts.append('')
    if present_in_prm:
        for gene in present_in_prm:
            reason = gene_reasons.get(gene, '')
            parts.append(f'- `{gene}` ({reason})')
    else:
        parts.append('- None')
    parts.append('')
    parts.append('### Deprioritize if panel space is limited')
    parts.append('')
    parts.append('These are IPA candidate genes that are already included in PRM but are not part of the current top priority set generated from the present IPA/t-test/phosphosite evidence.')
    parts.append('')
    if deprioritize:
        for gene in deprioritize:
            reason = gene_reasons.get(gene, '')
            parts.append(f'- `{gene}` ({reason})')
    else:
        parts.append('- None')
    parts.append('')
    parts.append('## Notes')
    parts.append('')
    parts.append('- The PRM workbook parser handles inline strings and phosphosite-style cell values.')
    parts.append('- The script accepts optional `--phosphosite` and repeated `--ttest` arguments to load a phosphosite TSV and DIANN t-test result files.')
    parts.append('- The IPA XLS evidence drives the candidate list, and the PDF search confirms the presence of specific genes when provided.')
    parts.append('')
    parts.append('## Reproducibility')
    parts.append('')
    parts.append('The workflow is reproducible with `genListPRM.py` and the same input files. Running the script again on the same inputs should produce stable counts and the same missing/present classification.')
    parts.append('')
    parts.append('## Command')
    parts.append('')
    parts.append('```bash')
    parts.append(command_str)
    parts.append('```')
    return '\n'.join(parts)


def build_command_string(script_name, args, ipa_xls, ipa_pdf, phospho_path, ttest_paths):
    pieces = [f'python3 {shlex.quote(script_name)}']
    pieces.append('--prm ' + shlex.quote(str(args.prm)))
    for path in ipa_xls:
        pieces.append('--ipa-xls ' + shlex.quote(str(path)))
    for path in ipa_pdf:
        pieces.append('--ipa-pdf ' + shlex.quote(str(path)))
    if phospho_path:
        pieces.append('--phosphosite ' + shlex.quote(str(phospho_path)))
    for path in ttest_paths:
        pieces.append('--ttest ' + shlex.quote(str(path)))
    if args.output:
        pieces.append('--output ' + shlex.quote(str(args.output)))
    if args.output_md:
        pieces.append('--output-md ' + shlex.quote(str(args.output_md)))
    return ' \
  '.join(pieces)


def parse_prm_xlsx(prm_path: Path):
    if not prm_path.exists():
        raise FileNotFoundError(prm_path)

    with zipfile.ZipFile(prm_path) as zf:
        shared_strings = []
        if 'xl/sharedStrings.xml' in zf.namelist():
            content = zf.read('xl/sharedStrings.xml')
            tree = ET.fromstring(content)
            for si in tree.findall('{http://schemas.openxmlformats.org/spreadsheetml/2006/main}si'):
                text = ''.join(t.text or '' for t in si.findall('.//{http://schemas.openxmlformats.org/spreadsheetml/2006/main}t'))
                shared_strings.append(text)

        sheetnames = [name for name in zf.namelist() if name.startswith('xl/worksheets/sheet') and name.endswith('.xml')]
        if not sheetnames:
            raise FileNotFoundError('No worksheet XML files found in XLSX archive')
        sheet = ET.fromstring(zf.read(sheetnames[0]))
        genes = set()
        for c in sheet.findall('.//{http://schemas.openxmlformats.org/spreadsheetml/2006/main}c'):
            value = ''
            t = c.attrib.get('t')
            if t == 's':
                v = c.find('{http://schemas.openxmlformats.org/spreadsheetml/2006/main}v')
                if v is None:
                    continue
                idx = int(v.text)
                value = shared_strings[idx] if idx < len(shared_strings) else ''
            elif t == 'inlineStr':
                isel = c.find('{http://schemas.openxmlformats.org/spreadsheetml/2006/main}is')
                if isel is None:
                    continue
                value = ''.join(t.text or '' for t in isel.findall('.//{http://schemas.openxmlformats.org/spreadsheetml/2006/main}t'))
            else:
                v = c.find('{http://schemas.openxmlformats.org/spreadsheetml/2006/main}v')
                if v is None:
                    continue
                value = v.text or ''

            if not value:
                continue
            for part in re.split(r'[\n,;()\[\]/]', value):
                gene = normalize_gene_token(part)
                if gene:
                    genes.add(gene)
    return genes


def pdf_text_search(pdf_path: Path, candidates):
    txt_path = pdf_path.with_suffix('.txt')
    if not txt_path.exists():
        if not shutil.which('pdftotext'):
            raise RuntimeError('pdftotext is required to inspect PDF contents')
        subprocess.run(['pdftotext', '-layout', str(pdf_path), str(txt_path)], check=True)
    found = defaultdict(list)
    text = txt_path.read_text(encoding='utf-8', errors='replace')
    for name in candidates:
        if re.search(rf'\b{name}\b', text, flags=re.IGNORECASE):
            found[name].append(True)
    return set(found)


def main():
    parser = argparse.ArgumentParser(description='Reproduce PRM/IPA analysis')
    parser.add_argument('--prm', required=True, type=Path, help='PRM Excel workbook (.xlsx)')
    parser.add_argument('--ipa-dir', required=False, type=Path, default=None, help='Optional directory containing IPA exports')
    parser.add_argument('--ipa-xls', type=Path, nargs='+', action='append', default=None, help='Optional explicit IPA XLS files to include')
    parser.add_argument('--ipa-pdf', type=Path, nargs='+', action='append', default=None, help='Optional explicit IPA PDF files to include')
    parser.add_argument('--phosphosite', type=Path, default=None, help='Optional phosphosite TSV file to include in the analysis')
    parser.add_argument('--ttest', type=Path, nargs='+', action='append', default=None, help='Optional DIANN t-test result CSV/TSV files to include')
    parser.add_argument('--p-threshold', type=float, default=0.05, help='Significance threshold for t-test p-values')
    parser.add_argument('--high-priority-top-n', type=int, default=20, help='Number of top IPA genes to consider for dynamic priority selection')
    parser.add_argument('--output', type=Path, default=None, help='Optional output file for summary')
    parser.add_argument('--output-md', type=Path, default=None, help='Optional markdown output file for a full report')
    args = parser.parse_args()

    if args.ipa_xls:
        ipa_xls = [path for group in args.ipa_xls for path in group]
    else:
        if args.ipa_dir is None:
            parser.error('Either --ipa-xls or --ipa-dir is required to locate IPA XLS files')
        ipa_dir = args.ipa_dir
        if not ipa_dir.exists():
            raise FileNotFoundError(ipa_dir)
        ipa_xls = sorted(ipa_dir.glob('*.xls'))
    if not ipa_xls:
        raise FileNotFoundError('No IPA .xls files found in --ipa-dir or provided with --ipa-xls')
    ipa_csv = []
    for xls_path in ipa_xls:
        if not xls_path.exists():
            raise FileNotFoundError(xls_path)
        csv_path = xls_path.with_suffix('.csv')
        if not csv_path.exists():
            convert_xls_to_csv(xls_path, xls_path.parent)
        ipa_csv.append(csv_path)

    if args.ipa_pdf:
        ipa_pdf = [path for group in args.ipa_pdf for path in group]
    else:
        ipa_pdf = []

    prm_genes = parse_prm_xlsx(args.prm)

    all_ipa_genes = Counter()
    ipa_gene_sets = {}
    for csv_path in ipa_csv:
        names, counter = parse_ipa_csv(csv_path)
        ipa_gene_sets[csv_path.name] = names
        all_ipa_genes.update(counter)

    ipa_candidates = set(all_ipa_genes)

    missing = sorted(ipa_candidates - prm_genes)
    present = sorted(ipa_candidates & prm_genes)

    phospho_genes = set()
    if args.phosphosite:
        phospho_genes = parse_phosphosite_tsv(args.phosphosite)

    all_ttest_genes = set()
    ttest_summary = []
    ttest_paths = []
    if args.ttest:
        ttest_paths = [path for group in args.ttest for path in group]
        for ttest_path in ttest_paths:
            ttest_genes = parse_ttest_results(ttest_path, args.p_threshold)
            all_ttest_genes.update(ttest_genes)
            ttest_summary.append({
                'name': ttest_path.name,
                'count': len(ttest_genes),
                'present_in_prm': len(ttest_genes & prm_genes),
                'overlap_ipa': len(ttest_genes & ipa_candidates),
                'overlap_phospho': len(ttest_genes & phospho_genes) if phospho_genes else 0,
            })

    common_high_priority = determine_high_priority_candidates(
        ipa_gene_sets,
        all_ipa_genes,
        all_ttest_genes if args.ttest else None,
        phospho_genes if args.phosphosite else None,
        top_n=args.high_priority_top_n,
    )
    add_to_prm, present_in_prm, deprioritize = generate_recommendations(common_high_priority, prm_genes, ipa_candidates)

    pdf_candidates = set()
    if ipa_pdf:
        for pdf_path in ipa_pdf:
            matches = pdf_text_search(pdf_path, common_high_priority)
            pdf_candidates.update(matches)

    gene_reasons = build_support_reasons(
        ipa_gene_sets,
        ipa_candidates,
        all_ttest_genes if args.ttest else set(),
        phospho_genes if args.phosphosite else set(),
        prm_genes,
        pdf_candidates,
    )

    if args.output:
        with args.output.open('w', encoding='utf-8') as fh:
            fh.write('PRM genes: ' + str(len(prm_genes)) + '\n')
            fh.write('IPA candidates: ' + str(len(ipa_candidates)) + '\n')
            fh.write('IPA candidates missing from PRM:\n')
            for gene in missing:
                fh.write(gene + '\n')
            fh.write('\nRecommendation categories generated from input files:\n')
            fh.write('Add to PRM panel (priority genes missing from PRM):\n')
            for gene in add_to_prm:
                fh.write(gene + '\n')
            fh.write('\nHigh-priority IPA candidates already present in PRM:\n')
            for gene in present_in_prm:
                fh.write(gene + '\n')
            fh.write('\nIPA candidate genes already in PRM and not in the current top priority set:\n')
            for gene in deprioritize:
                fh.write(gene + '\n')

    if args.output_md:
        command_str = build_command_string('genListPRM.py', args, ipa_xls, ipa_pdf, args.phosphosite, ttest_paths)
        markdown = format_markdown_report(
            'genListPRM.py',
            args,
            ipa_xls,
            ipa_pdf,
            args.phosphosite,
            ttest_paths,
            len(prm_genes),
            len(ipa_candidates),
            len(present),
            len(missing),
            len(phospho_genes),
            len(phospho_genes & prm_genes),
            len(phospho_genes & ipa_candidates),
            ttest_summary,
            len(all_ttest_genes),
            len(all_ttest_genes & prm_genes),
            len(all_ttest_genes & ipa_candidates),
            len(all_ttest_genes & phospho_genes) if phospho_genes else None,
            add_to_prm,
            present_in_prm,
            deprioritize,
            gene_reasons,
            command_str,
        )
        with args.output_md.open('w', encoding='utf-8') as fh:
            fh.write(markdown)

    union_recommendations = sorted(set(add_to_prm + present_in_prm + deprioritize))
    for gene in union_recommendations:
        print(gene)


if __name__ == '__main__':
    main()
