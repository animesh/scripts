#python proteinGroupsMQtesorAIcombine.py /mnt/z/Download/MQ/ /mnt/z/Download/tesorAI/ "Protein IDs" protein_group_id iBAQ intensity_IBAQ
#python proteinGroupsMQtesorAIcombine.py /mnt/z/Download/MQ/ /mnt/z/Download/tesorAI/ "Protein IDs" protein_group_id Top3 intensity_top3
"""
Arguments:
	dir_with_proteinGroups   Directory containing MaxQuant output subfolders with 'proteinGroups.txt' files
													 (default: /mnt/z/Download/MQ/)
	dir_with_quantified_tsv  Directory containing quantified TSVs named '*_quantified_protein_fdr.tsv'
													 (default: /mnt/z/Download/tesorAI/)
	prot_id_col              ProteinGroups ID column name (default: 'Protein IDs')
	quant_id_col             Quant TSV ID column name (default: 'protein_group_id')
	prot_intensity_col       ProteinGroups intensity column name (default: 'Intensity')
	quant_intensity_col      Quant TSV intensity column name (default: 'intensity_IBAQ')
"""

import sys
import os
import pandas as pd
import numpy as np
import re

default_dir_prot = "/mnt/z/Download/MQ/"
default_dir_quant = "/mnt/z/Download/tesorAI/"

if len(sys.argv) >= 2 and len(sys.argv) < 7: sys.exit("\nUSAGE: python proteinGroupsMQtesorAIcombine.py [dir_with_proteinGroups] [dir_with_quantified_tsv] [prot_id_col] [quant_id_col] [prot_intensity_col] [quant_intensity_col]\n\nIf not provided, defaults are:\n  dir_with_proteinGroups = /mnt/z/Download/MQ/\n  dir_with_quantified_tsv = /mnt/z/Download/tesorAI/\n  prot_id_col = Protein IDs\n  quant_id_col = protein_group_id\n  prot_intensity_col = Intensity\n  quant_intensity_col = intensity_IBAQ\n")

# Accept CLI overrides but fall back to hard-coded defaults
dir_prot = sys.argv[1] if len(sys.argv) >= 2 else default_dir_prot
dir_quant = sys.argv[2] if len(sys.argv) >= 3 else default_dir_quant
# optional positional: prot id column name and quant id column name
prot_id_col_cli = sys.argv[3] if len(sys.argv) >= 4 else 'Protein IDs'
quant_id_col_cli = sys.argv[4] if len(sys.argv) >= 5 else 'protein_group_id'
# optional positional: intensity column names (defaults)
prot_int_col_cli = sys.argv[5] if len(sys.argv) >= 6 else 'Intensity'
quant_int_col_cli = sys.argv[6] if len(sys.argv) >= 7 else 'intensity_IBAQ'

print('proteinGroups TXT dir:', dir_prot)
print('tesorAI TSV dir:', dir_quant)

# helper: sanitize strings for filenames
def safe_arg(s):
	s = str(s)
	s = s.strip()
	# remove characters that are not alphanumeric, dot or hyphen (no underscores)
	return re.sub(r'[^A-Za-z0-9.-]+', '', s)

def find_files(root, suffix):
	out = []
	for dp, dn, filenames in os.walk(root):
		for f in filenames:
			if f.endswith(suffix):
				out.append(os.path.join(dp, f))
	return out

prot_files = find_files(dir_prot, 'proteinGroups.txt')
quant_files = find_files(dir_quant, '_quantified_protein_fdr.tsv')

print(f'Found {len(prot_files)} proteinGroups files and {len(quant_files)} quantified TSV files')

# Read each discovered file once and cache DataFrames (avoid repeated reads)
prot_dfs = {}
quant_dfs = {}
for p in prot_files:
	try:
		prot_dfs[p] = pd.read_csv(p, sep='\t', low_memory=False)
	except Exception as e:
		print(' - failed reading', p, e)
for q in quant_files:
	try:
		quant_dfs[q] = pd.read_csv(q, sep='\t', low_memory=False)
	except Exception as e:
		print(' - failed reading', q, e)

# helper for diagnostics: find best matching column name
def find_best_col_local(df, candidates):
	cols_lower = {c.lower(): c for c in df.columns}
	for cand in candidates:
		key = cand.lower()
		if key in cols_lower:
			return cols_lower[key]
	return None

# helper: extract between pipes
def extract_between_pipes(x):
	s = str(x)
	m = re.search(r"\|([^|]+)\|", s)
	return m.group(1) if m else s

# Process proteinGroups files once each: print header, diagnostics, build master_prot
print('\nProcessing proteinGroups files:')
master_prot = None
for p in prot_files:
	dfp = prot_dfs.get(p)
	if dfp is None:
		print(' -', p, ' (failed to read)')
		continue

	# diagnostic row counts
	col = find_best_col_local(dfp, [prot_id_col_cli])
	if col is None:
		print(f" - {p}: ID column '{prot_id_col_cli}' not found")
		continue
	before = len(dfp)
	ids = dfp[col].astype(str)
	after = ids.str.split(';').explode().str.strip().shape[0] if ids.str.contains(';').any() else before
	print(f" - {p}: {before} -> {after}")

	# expand IDs and extract
	dfp_proc = dfp.copy()
	dfp_proc['ID'] = dfp_proc[col].astype(str).str.split(';')
	dfp_proc = dfp_proc.explode('ID')
	dfp_proc['ID'] = dfp_proc['ID'].astype(str).str.strip().apply(extract_between_pipes)

	# find intensity column
	prot_int_candidates = [prot_int_col_cli, prot_int_col_cli.lower(), prot_int_col_cli.replace(' ', '_'), prot_int_col_cli.replace('_', ' ')]
	intcol = find_best_col_local(dfp_proc, prot_int_candidates)
	rel = os.path.relpath(p, dir_prot)
	colname = f'Intensity_{rel}'
	if intcol is None:
		print(f" - {p}: Intensity column not found; filling NA")
		df_small = dfp_proc[['ID']].drop_duplicates().copy()
		df_small[colname] = np.nan
	else:
		df_small = dfp_proc[['ID', intcol]].copy()
		df_small = df_small.rename(columns={intcol: colname})

	df_small = df_small.groupby('ID').agg({colname: 'sum'})
	master_prot = df_small if master_prot is None else master_prot.merge(df_small, left_index=True, right_index=True, how='outer')

if master_prot is None:
	print('No proteinGroups data assembled')
else:
	master_prot = master_prot.reset_index()
	print('Final master proteinGroups dataframe rows:', len(master_prot))
	# write MQ master with CLI args embedded in filename (no underscores)
	prot_tag = f"dir-{safe_arg(dir_prot)}-idcol-{safe_arg(prot_id_col_cli)}-intcol-{safe_arg(prot_int_col_cli)}"
	prot_fname = f"mqmaster-{prot_tag}.csv"
	master_prot.to_csv(prot_fname, index=False)
	print('Wrote', prot_fname)

# Process quantified TSV files once each: print header, diagnostics, build master
print('\nProcessing tesorAI TSV files:')
master = None
for q in quant_files:
	dfq = quant_dfs.get(q)
	if dfq is None:
		print(' -', q, ' (failed to read)')
		continue

	idcol = find_best_col_local(dfq, [quant_id_col_cli])
	if idcol is None:
		print(f" - {q}: ID column '{quant_id_col_cli}' not found; skipping")
		continue
	before = len(dfq)
	ids = dfq[idcol].astype(str)
	after = ids.str.split(';').explode().str.strip().shape[0] if ids.str.contains(';').any() else before
	print(f" - {q}: {before} -> {after}")

	dfq_proc = dfq.copy()
	dfq_proc['ID'] = dfq_proc[idcol].astype(str).str.split(';')
	dfq_proc = dfq_proc.explode('ID')
	dfq_proc['ID'] = dfq_proc['ID'].astype(str).str.strip().apply(extract_between_pipes)

	int_candidates = [quant_int_col_cli, quant_int_col_cli.lower(), quant_int_col_cli.replace(' ', '_'), quant_int_col_cli.replace('_', ' ')]
	intcol = find_best_col_local(dfq_proc, int_candidates)
	rel = os.path.relpath(q, dir_quant)
	colname = f'{quant_int_col_cli}_{rel}'
	if intcol is None:
		print(f" - {q}: {quant_int_col_cli} column not found; filling NA")
		df_small = dfq_proc[['ID']].drop_duplicates().copy()
		df_small[colname] = np.nan
	else:
		df_small = dfq_proc[['ID', intcol]].copy()
		df_small = df_small.rename(columns={intcol: colname})

	df_small = df_small.groupby('ID').agg({colname: 'sum'})
	master = df_small if master is None else master.merge(df_small, left_index=True, right_index=True, how='outer')

if master is None:
	print('No quantified data assembled')
else:
	master = master.reset_index()
	print('Final master quantified dataframe rows:', len(master))
	# write tesorAI master with CLI args embedded in filename (no underscores)
	quant_tag = f"dir-{safe_arg(dir_quant)}-idcol-{safe_arg(quant_id_col_cli)}-intcol-{safe_arg(quant_int_col_cli)}"
	quant_fname = f"tesoraimaster-{quant_tag}.csv"
	master.to_csv(quant_fname, index=False)
	print('Wrote', quant_fname)

# Merge the two master tables on ID (if both are present) and write merged output
if master_prot is not None and master is not None:
	try:
		merged_master = pd.merge(master_prot, master, on='ID', how='outer', suffixes=('_prot', '_quant'))
		before = len(merged_master)
		# write combined master with a concise tag (no underscores)
		merged_tag = f"{safe_arg(dir_prot)}-{safe_arg(dir_quant)}-{safe_arg(prot_id_col_cli)}-{safe_arg(quant_id_col_cli)}-{safe_arg(prot_int_col_cli)}-{safe_arg(quant_int_col_cli)}"
		merged_fname = f"comb-{merged_tag}.csv"
		# remove duplicate rows that have the same values across all columns except ID
		# concatenate their IDs (unique, sorted) separated by ';'
		try:
			cols = list(merged_master.columns)
			if 'ID' not in cols:
				merged_master.to_csv(merged_fname, index=False)
				print('Wrote', merged_fname, '— rows:', len(merged_master))
			else:
				id_col = 'ID'
				other_cols = [c for c in cols if c != id_col]
				# create a stable key based on stringified other column values (treat NaN consistently)
				def row_key(row):
					vals = []
					for v in row:
						if pd.isna(v):
							vals.append('__NA__')
						else:
							vals.append(str(v))
					return tuple(vals)

				temp = merged_master.copy()
				temp['_merge_key'] = temp[other_cols].apply(lambda r: row_key(r.values), axis=1)

				grouped_ids = temp.groupby('_merge_key')[id_col].agg(lambda ids: ';'.join(sorted(set([str(i) for i in ids if pd.notna(i)]))))

				# build deduplicated rows by taking a representative row for each group (preserving types)
				rows = []
				for key, id_comb in grouped_ids.items():
					rep = temp[temp['_merge_key'] == key].iloc[0]
					row = {c: rep[c] for c in other_cols}
					row[id_col] = id_comb
					rows.append(row)

				deduped = pd.DataFrame(rows)
				# ensure columns order matches original (ID first if originally first)
				try:
					deduped = deduped[cols]
				except Exception:
					# fallback: put ID first then others
					deduped = deduped[[id_col] + other_cols]

				after = len(deduped)
				deduped.to_csv(merged_fname, index=False)
				print(f'Wrote {merged_fname} — rows (deduplicated): {before} -> {after}')
		except Exception as e:
			# fallback: write original merged_master if deduplication fails
			merged_master.to_csv(merged_fname, index=False)
			print('Wrote', merged_fname, '— rows:', len(merged_master), '(deduplication failed:', e, ')')
	except Exception as e:
		print('Failed merging master tables on ID:', e)
else:
	print('Skipping merged_master_by_ID.csv: one or both masters missing')

