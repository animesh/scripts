import pandas as pd
import numpy as np

# Download and load data (keeping your original download code)
url = "https://server-server-drive.promec.sigma2.no/Data/report.parquet?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=promecshare%2F20250821%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20250821T110621Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=a074a77823d970dbf635193a6adfb692e23b8edb89f22a4b38b01d4114ce9cb2"
output_filename = "reports.parquet"
response = requests.get(url, stream=True)
response.raise_for_status()
with open(output_filename, 'wb') as f:
    for chunk in response.iter_content(chunk_size=8192):
        f.write(chunk)
print(f"Downloaded {output_filename}")

# Load and filter data
mz_parquet = pd.read_csv("F:/promec/TIMSTOF/LARS/2021/SEPTEMBER/SUDHL5 silac/210920 SILAC DIA/DIANNv2p2/reports.csv")
peptides_prots_proteotypic = mz_parquet[mz_parquet['Proteotypic'] == 1].copy()

# Calculate log2 intensities
peptides_prots_proteotypic['Genes.MaxLFQ.log2'] = np.log2(peptides_prots_proteotypic['Precursor.Normalised'])

print(f"Total proteotypic peptides: {len(peptides_prots_proteotypic)}")

# Step 1: Pivot to get H and L channels side by side
pivoted_peptides = peptides_prots_proteotypic.pivot_table(
    index=['Precursor.Id', 'Genes', 'Run'], 
    columns='Channel', 
    values='Genes.MaxLFQ.log2'
)

# Reset index to make manipulation easier
pivoted_peptides = pivoted_peptides.reset_index()

print(f"After pivoting: {len(pivoted_peptides)} rows")

# Step 2: Calculate H - L difference (log2(H) - log2(L))
# Replace infinite values with NaN first
pivoted_peptides['H'] = pivoted_peptides['H'].replace([np.inf, -np.inf], np.nan)
pivoted_peptides['L'] = pivoted_peptides['L'].replace([np.inf, -np.inf], np.nan)

# Calculate difference (H - L means log2(H/L) ratio)
pivoted_peptides['Difference'] = pivoted_peptides['H'] - pivoted_peptides['L']
pivoted_peptides['Difference'].hist()
import matplotlib.pyplot as plt
plt.show()

print(f"Peptides with both H and L values: {pivoted_peptides['Difference'].notna().sum()}")

# Step 3: Pivot by Run to get different runs as columns
pivoted_by_run = pivoted_peptides.pivot_table(
    index=['Precursor.Id', 'Genes'], 
    columns='Run', 
    values=['H', 'L', 'Difference'],
    aggfunc='first'  # In case of duplicates, take first value
)

# Flatten column names
pivoted_by_run.columns = ['_'.join(map(str, col)).strip() for col in pivoted_by_run.columns.values]
pivoted_by_run = pivoted_by_run.reset_index()

print(f"After pivoting by run: {len(pivoted_by_run)} rows")

# Step 4: Group by Gene and aggregate
def concatenate_strings(series):
    """Concatenate non-null string values with semicolon"""
    non_null_values = series.dropna().astype(str)
    if len(non_null_values) > 0:
        return ';'.join(non_null_values.unique())  # Remove duplicates
    return np.nan

def median_ignoring_nan(series):
    """Calculate median ignoring NaN values"""
    return series.median()

# Prepare aggregation functions
agg_functions = {}

# For Precursor.Id (string column) - concatenate
agg_functions['Precursor.Id'] = concatenate_strings

# For all other columns (should be numeric) - use median
for col in pivoted_by_run.columns:
    if col not in ['Genes', 'Precursor.Id']:  # Skip grouping column and already handled column
        agg_functions[col] = median_ignoring_nan

# Group by Genes and apply aggregation
final_results = pivoted_by_run.groupby('Genes').agg(agg_functions).reset_index()

print(f"Final results grouped by genes: {len(final_results)} genes")

# Display summary statistics for difference columns
difference_cols = [col for col in final_results.columns if 'Difference_' in col]
print(f"\nDifference columns found: {difference_cols}")

for col in difference_cols:
    print(f"\n{col} statistics:")
    print(final_results[col].describe())

# Save results
final_results.to_csv('reports_silac_corrected.csv', index=False)
print("\nResults saved to 'reports_silac_corrected.csv'")

# Optional: Create a summary with median difference across all runs for each gene
if difference_cols:
    final_results['Median_Difference_Across_Runs'] = final_results[difference_cols].median(axis=1)
    print(f"\nGenes with median H/L ratios (log2 scale):")
    summary = final_results[['Genes', 'Median_Difference_Across_Runs']].dropna()
    print(summary.sort_values('Median_Difference_Across_Runs', ascending=False).head(10))
