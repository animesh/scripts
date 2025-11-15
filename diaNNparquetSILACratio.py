#python diaNNparquetSILACratio.py 
import requests
url = "https://server-server-drive.promec.sigma2.no/Data/251024_MAIKE_.report.parquet.tar?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=promecshare%2F20251112%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20251112T085631Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=a1e6add4d54ac864df8e1874f50b6bf32b85a95c9d5f0ffc6d4499a99ab05fe3"
output_filename = "reports.parquet.tar"
response = requests.get(url, stream=True)
response.raise_for_status()  # Raise an exception for bad status codes
with open(output_filename, 'wb') as f:
    for chunk in response.iter_content(chunk_size=8192):
        f.write(chunk)
print(f"Downloaded {output_filename}")

import tarfile
import os
output_filename = "reports.parquet.tar"
extract_path = "."
with tarfile.open(output_filename, 'r') as tar:
    tar.extractall(path=extract_path)
print(f"Extracted {output_filename} to {extract_path}")

import glob
parquet_files = glob.glob("**/*parquet",recursive=True)
print(parquet_files)
print(len(parquet_files))

import pandas as pd
import pyarrow as pa
import pyarrow.parquet as pq
import numpy as np

combined_df = None
#file=parquet_files[0]
for file in parquet_files:
    print(f"Processing {file}")
    df = pq.read_table(file).to_pandas()

    peptides_prots_proteotypic = df[df['Proteotypic'] == 1].copy()

    peptides_prots_proteotypic['Precursor.Normalised.log2'] = np.log2(peptides_prots_proteotypic['Precursor.Normalised'].replace(0, np.nan))
    peptides_prots_proteotypic['Precursor.Normalised.log2'] = peptides_prots_proteotypic['Precursor.Normalised.log2'].replace(-np.inf, np.nan)

    #pivoted_peptides = peptides_prots_proteotypic.pivot_table(index=['Precursor.Id', 'Genes'], columns='Channel', values='Precursor.Normalised.log2')
    pivoted_peptides = peptides_prots_proteotypic.pivot_table(index=['Precursor.Id', 'Genes'], columns='Channel', values='RT')

    pivoted_peptides = pivoted_peptides.reset_index()

    h_values = pivoted_peptides['H'].fillna(0) if 'H' in pivoted_peptides.columns else 0
    l_values = pivoted_peptides['L'].fillna(0) if 'L' in pivoted_peptides.columns else 0
    pivoted_peptides['Difference'] = h_values.astype(str) + 'H;L' + l_values.astype(str) #h_values - l_values
    pivoted_peptides['ID'] = pivoted_peptides['Genes'] + ';' + pivoted_peptides['Precursor.Id']

    #pivoted_peptides['Precursor.Id'] = pivoted_peptides['Precursor.Id'].str.replace(r'\(.*\)\d*', '', regex=True)
    result = pivoted_peptides[['ID','Difference']].copy()

    filename = file.split('/')[-1].split('\\')[-1].rsplit('.', 1)[0]
    result = result.rename(columns={'Difference': filename})

    if combined_df is None:
        combined_df = result
    else:
        combined_df = combined_df.merge(result, on='ID', how='outer')

print(combined_df.info())
#combined_df
combined_df.to_csv('diaNNparquetSILACratio.csv', index=False)
print("Saved diaNNparquetSILACratio.csv")
