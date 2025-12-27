#python diaNNparquetSILACratio.py 
import pandas as pd
import pyarrow as pa
import pyarrow.parquet as pq
import numpy as np

mz_parquet = pq.read_table('/content/report.parquet')
mz_parquet = mz_parquet.to_pandas()
mz_parquet.to_csv('reports.csv')
print(mz_parquet.describe())

peptides_prots_proteotypic_log2int = mz_unimod_21.copy()
peptides_prots_proteotypic_log2int['Genes.MaxLFQ.log2'] = np.log2(peptides_prots_proteotypic_log2int['Genes.MaxLFQ'])
print(peptides_prots_proteotypic_log2int)

pivoted_peptides = peptides_prots_proteotypic_log2int.pivot_table(index=['Precursor.Id', 'Genes','Run'], columns='Channel', values='Genes.MaxLFQ.log2')
print(pivoted_peptides)

peptides_in_both_channels = pivoted_peptides.dropna(subset=['H', 'L'])
print(peptides_in_both_channels)

pivoted_peptides.describe()

pivoted_peptides_na = pivoted_peptides.replace([np.inf, -np.inf], np.nan)
pivoted_peptides_na.describe()

pivoted_peptides_na['Difference'] = pivoted_peptides_na['H'].fillna(0) - pivoted_peptides_na['L'].fillna(0)
pivoted_peptides_na = pivoted_peptides_na.reset_index()
pivoted_peptides_na['Difference'].describe()

pivoted_peptides_na['Difference'] = pivoted_peptides_na['H'] - pivoted_peptides_na['L']
pivoted_peptides_na = pivoted_peptides_na.reset_index()
pivoted_peptides_na['Difference'].describe()

pivoted_peptides_by_run = pivoted_peptides_na.pivot_table(index=['Precursor.Id', 'Genes','H','L'], columns='Run', values=['Difference'])
pivoted_peptides_by_run=pivoted_peptides_by_run.reset_index()
print(pivoted_peptides_by_run)

pivoted_peptides_by_run.Difference.describe()

pivoted_peptides_by_run.Difference.isna().describe()

aggregation_functions = {}

# Aggregate 'Difference' columns by taking the median
for run_col in pivoted_peptides_by_run.columns.get_level_values('Run').unique():
    if run_col != '': # Exclude the empty string level for index columns
        aggregation_functions[('Difference', run_col)] = 'median'

# Concatenate string columns
for level0_col in ['Precursor.Id', 'H', 'L']:
    if (level0_col, '') in pivoted_peptides_by_run.columns:
        aggregation_functions[(level0_col, '')] = lambda x: ';'.join(map(str, x.dropna()))


combined_peptides = pivoted_peptides_by_run.groupby(('Genes', '')).agg(aggregation_functions).reset_index()
print(combined_peptides)

import matplotlib.pyplot as plt

combined_peptides.to_csv('reports_silac.csv')

# Plot histograms for each 'Difference' column
ax_list = combined_peptides['Difference'].hist()

# Add titles to each histogram and display the plots
for i, ax in enumerate(ax_list.flatten()):
    ax.set_title(f'Difference for Run {i+1}')

plt.tight_layout()
plt.show()
