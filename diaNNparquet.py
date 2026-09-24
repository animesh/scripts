#python diaNNparquet.py -f "F:\promec\TIMSTOF\LARS\2026\260825_Barbara\phosDIA\lib.report.parquet" -c Precursor.Normalised -s "UniMod:21"
import pandas as pd
import pyarrow.parquet as pq
import os
import numpy as np
import re
import argparse

# allow overriding via CLI: `python diaNNparquet.py -f <path>`
parser = argparse.ArgumentParser(description='Generate DIA-NN histograms and ridge plots from a parquet file')
parser.add_argument('-f', '--fileP', help='path to parquet file', default=r'F:\promec\TIMSTOF\LARS\2026\260825_Barbara\phosDIA\lib.report.parquet')
parser.add_argument('-c', '--value-col', help="name of numeric column to use (default 'Precursor.Normalised'), e.g. 'Precursor.Quantity'", default='Precursor.Normalised')
parser.add_argument('-s', '--select-col', help="name of column to use for selection(default 'UniMod:21'), e.g. 'UniMod:21' for phosphorylation", default='UniMod:21')

args = parser.parse_args()
value_col = args.value_col
#value_col = "Ms1.Area"
select_col = args.select_col
#value_col = "Ms1.Area"
fileP = args.fileP
# safe token to put into output filenames
safe_col = re.sub(r'[^A-Za-z0-9_-]+', '_', value_col)
safe_col_select = re.sub(r'[^A-Za-z0-9_-]+', '_', select_col)
mz_parquet = pq.read_table(fileP)
mz_parquet = mz_parquet.to_pandas()
#print(mz_parquet.describe())
#mz_parquet.to_csv(fileP+'.infinisearch.csv')
#mz_parquet2 = pd.read_csv(fileP+'.csv',index_col=0)
#print(mz_parquet.describe()-mz_parquet2.describe())
#mzDiff=mz_parquet2['Precursor.Normalised']-mz_parquet['Precursor.Normalised']
#print(mzDiff.describe())
pivoted_peptides_by_run = mz_parquet.pivot_table(index=['Precursor.Id', 'Protein.Names'], columns='Run', values=value_col)
pivoted_peptides_by_run=pivoted_peptides_by_run.reset_index()
print(pivoted_peptides_by_run)
print(pivoted_peptides_by_run.count())
#pivoted_peptides_by_run.to_csv(fileP + f'_{safe_col}_pivot_all.csv', index=False)
#print('Saved full pivot to', fileP + f'_{safe_col}_pivot_all.csv')

#peptides_prots_proteotypic = mz_parquet[mz_parquet['Proteotypic'] == 1]
#print(peptides_prots_proteotypic)

#peptides_prots_proteotypic_log2int = peptides_prots_proteotypic.copy()
#log2_col = f"{value_col}.log2"
# avoid -inf from log2(0) by converting non-positive values to NaN before log
#vals = peptides_prots_proteotypic_log2int[value_col]
#safe_log2 = np.where(vals > 0, np.log2(vals), np.nan)
#peptides_prots_proteotypic_log2int[log2_col] = safe_log2
#print(peptides_prots_proteotypic_log2int)

#pivoted_peptides_by_run = peptides_prots_proteotypic_log2int.pivot_table(index=['Precursor.Id', 'Protein.Names'], columns='Run', values=log2_col)
#pivoted_peptides_by_run=pivoted_peptides_by_run.reset_index()
#print(pivoted_peptides_by_run)

#print(pivoted_peptides_by_run.count())

pivoted_peptides_by_run_select = pivoted_peptides_by_run[pivoted_peptides_by_run['Precursor.Id'].str.contains(select_col)]
print(pivoted_peptides_by_run_select)
pivoted_peptides_by_run_select.to_csv(fileP + f'_{safe_col_select}_pivot_all.csv', index=False)

