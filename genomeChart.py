import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from scipy import stats
import re
import os
import subprocess
import sys

def download_file(url, filename):
    if os.path.exists(filename):
        print(f"{filename} already exists. Skipping download.")
        return
    
    print(f"Downloading {filename} from {url}...")
    try:
        subprocess.run(['wget', '-O', filename, url], check=True)
        print(f"Successfully downloaded {filename}")
    except subprocess.CalledProcessError as e:
        print(f"Error downloading {filename}: {e}")
        sys.exit(1)

def download_data():
    # NCBI Files
    download_file('https://ftp.ncbi.nlm.nih.gov/genomes/GENOME_REPORTS/eukaryotes.txt', 'eukaryotes.txt')
    download_file('https://ftp.ncbi.nlm.nih.gov/genomes/GENOME_REPORTS/prokaryotes.txt', 'prokaryotes.txt')
    
    # UniProt Stats
    download_file('https://ftp.ebi.ac.uk/pub/databases/reference_proteomes/QfO/STATS', 'QfO_STATS')

# 1. Parse UniProt Stats
def parse_qfo_stats(filepath):
    data = []
    try:
        with open(filepath, 'r') as f:
            lines = f.readlines()
    except FileNotFoundError:
        print(f"Error: {filepath} not found.")
        return pd.DataFrame()
    
    start_index = 0
    for i, line in enumerate(lines):
        if line.startswith('Proteome_ID'):
            start_index = i + 1
            break
    
    for line in lines[start_index:]:
        if not line.strip():
            continue
        parts = line.split('\t')
        if len(parts) < 8:
            continue
        
        try:
            tax_id = int(parts[1])
            canonical_count_str = parts[2]
            match = re.match(r'(\d+)', canonical_count_str)
            if match:
                canonical_count = int(match.group(1))
            else:
                continue
            
            species_name = parts[-1].strip()
            
            data.append({
                'TaxID': tax_id,
                'Unique_Proteins': canonical_count,
                'UniProt_Name': species_name
            })
        except ValueError:
            continue
            
    return pd.DataFrame(data)

# 2. Load NCBI Data for Genome Size
def load_ncbi_size(filepath):
    try:
        df = pd.read_csv(filepath, sep='\t', on_bad_lines='skip')
        if 'Size (Mb)' not in df.columns or 'TaxID' not in df.columns:
            return None
        
        df = df[['TaxID', 'Size (Mb)', '#Organism/Name']].copy()
        df.rename(columns={'#Organism/Name': 'NCBI_Name'}, inplace=True)
        df['Size (Mb)'] = pd.to_numeric(df['Size (Mb)'], errors='coerce')
        df['TaxID'] = pd.to_numeric(df['TaxID'], errors='coerce')
        df.dropna(subset=['Size (Mb)', 'TaxID'], inplace=True)
        df['TaxID'] = df['TaxID'].astype(int)
        
        # Take median size per TaxID
        df_grouped = df.groupby('TaxID').agg({'Size (Mb)': 'median', 'NCBI_Name': 'first'}).reset_index()
        
        return df_grouped
    except Exception as e:
        print(f"Error processing {filepath}: {e}")
        return None

def main():
    # Step 1: Download Data
    download_data()

    # Step 2: Parse UniProt Data
    uniprot_df = parse_qfo_stats('QfO_STATS')
    print(f"Loaded {len(uniprot_df)} records from UniProt STATS")

    # Step 3: Load NCBI Data
    euk_size = load_ncbi_size('eukaryotes.txt')
    prok_size = load_ncbi_size('prokaryotes.txt')
    
    if euk_size is None or prok_size is None:
        print("Failed to load NCBI data.")
        return

    ncbi_df = pd.concat([euk_size, prok_size], ignore_index=True)

    # Step 4: Merge Datasets
    merged_df = pd.merge(uniprot_df, ncbi_df, on='TaxID', how='inner')
    print(f"Merged data has {len(merged_df)} records.")

    # Step 5: Plotting
    plt.figure(figsize=(12, 8))

    euk_taxids = set(euk_size['TaxID'])
    prok_taxids = set(prok_size['TaxID'])

    def get_color(taxid):
        if taxid in euk_taxids: return 'tab:orange', 'Eukaryotes'
        if taxid in prok_taxids: return 'tab:blue', 'Prokaryotes'
        return 'gray', 'Other'

    colors = [get_color(tid)[0] for tid in merged_df['TaxID']]
    labels = [get_color(tid)[1] for tid in merged_df['TaxID']]
    merged_df['Color'] = colors
    merged_df['Label'] = labels

    # Scatter plot
    for label, color in [('Prokaryotes', 'tab:blue'), ('Eukaryotes', 'tab:orange')]:
        subset = merged_df[merged_df['Label'] == label]
        plt.scatter(subset['Size (Mb)'], subset['Unique_Proteins'], 
                    alpha=0.6, s=30, label=label, color=color, edgecolor='k', linewidth=0.5)

    # Highlight Human and Zebrafish
    specific_organisms = {
        9606: 'Homo sapiens', 
        7955: 'Danio rerio'
    }

    for tax_id, name in specific_organisms.items():
        row = merged_df[merged_df['TaxID'] == tax_id]
        if not row.empty:
            r = row.iloc[0]
            plt.scatter(r['Size (Mb)'], r['Unique_Proteins'], color='green', s=150, marker='*', zorder=10)
            plt.annotate(f"{name}\n({int(r['Unique_Proteins'])})", 
                         (r['Size (Mb)'], r['Unique_Proteins']), 
                         xytext=(10, -10), textcoords='offset points', 
                         arrowprops=dict(arrowstyle="->", connectionstyle="arc3,rad=.2"), 
                         color='green', fontweight='bold')

    # Regression
    log_size = np.log10(merged_df['Size (Mb)'])
    log_genes = np.log10(merged_df['Unique_Proteins'])
    slope, intercept, r_value, p_value, std_err = stats.linregress(log_size, log_genes)

    x_range = np.linspace(merged_df['Size (Mb)'].min(), merged_df['Size (Mb)'].max(), 100)
    y_fit = 10**(intercept + slope * np.log10(x_range))
    plt.plot(x_range, y_fit, 'r--', label=f'Fit: $R^2$ = {r_value**2:.3f}')

    # Outliers
    residuals = log_genes - (intercept + slope * log_size)
    merged_df['residual'] = residuals
    outliers = pd.concat([merged_df.nlargest(3, 'residual'), merged_df.nsmallest(3, 'residual')])

    for idx, row in outliers.iterrows():
        if row['TaxID'] not in specific_organisms: # Don't double label
            plt.text(row['Size (Mb)'], row['Unique_Proteins'], row['UniProt_Name'].split('(')[0].strip(), fontsize=8)

    plt.xscale('log')
    plt.yscale('log')
    plt.xlabel('Genome Size (Mb)')
    plt.ylabel('Unique Protein-Coding Genes (Canonical)')
    plt.title('Genome Size vs Unique Protein Count (Quick & Dirty Analysis)')
    plt.figtext(0.5, 0.01, "Note: Unique Proteins (UniProt QfO) vs Genome Size (NCBI median). Mismatched TaxIDs dropped.", ha="center", fontsize=9, bbox={"facecolor":"lightblue", "alpha":0.2, "pad":5})
    plt.legend()
    plt.grid(True, which="both", ls="-", alpha=0.2)

    output_file = 'uniprot_unique_protein_chart.png'
    plt.savefig(output_file, dpi=300)
    print(f"Chart saved to {output_file}")

if __name__ == "__main__":
    main()
