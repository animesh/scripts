#python diffExprDIANN.py F:\promec\TIMSTOF\LARS\2025\250107_Hela_Coli\DDAreport.parquet_Ms1_Area_pivot_all.csv
#python diffExprDIANN.py F:\promec\TIMSTOF\LARS\2025\250107_Hela_Coli\reportDDA.parquet_Ms1_Area_pivot_all.csv
import sys
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import re
from pathlib import Path

if len(sys.argv) != 2: sys.exit("USAGE: python diffExprDIANN.py <precursor_matrix.csv>")

filepath = Path(sys.argv[1])
output_prefix = filepath.stem

sns.set_style("whitegrid")
plt.rcParams['figure.dpi'] = 300

def parse_condition(col): 
    match = re.search(r'Hela_coli_(\d+)_1', col)
    return f"Hela_coli_{match.group(1)}_1" if match else None

def annotate_species(protein):
    if pd.isna(protein): return 'Unknown'
    protein = str(protein)
    if 'ECOLI' in protein: return 'E.coli'
    elif 'HUMAN' in protein: return 'Human'
    elif 'cRAP' in protein or 'CONT' in protein: return 'cRAP'
    return 'Unknown'

def extract_ratio(condition):
    match = re.search(r'Hela_coli_(\d+)_1', condition)
    return int(match.group(1)) if match else None

def get_dilution_factor(condition, ref_condition):
    ratio = extract_ratio(condition)
    ref_ratio = extract_ratio(ref_condition)
    if ratio is None or ref_ratio is None:
        return 1.0
    return ref_ratio / ratio

print(f"Loading {filepath}...")
sep = ',' if filepath.suffix == '.csv' else '\t'
df = pd.read_csv(filepath, sep=sep)

print(f"Columns in file: {list(df.columns)[:10]}")

id_col = None
protein_col = None
for col in df.columns:
    if 'precursor' in col.lower() and 'id' in col.lower():
        id_col = col
    if 'protein' in col.lower():
        protein_col = col
        break

if not protein_col:
    protein_col = df.columns[0]
    print(f"Using first column as protein ID: {protein_col}")

sample_cols = [c for c in df.columns if c not in [id_col, protein_col] and parse_condition(c)]
col_to_condition = {c: parse_condition(c) for c in sample_cols}

if not sample_cols:
    print("No sample columns found with pattern 'Hela_coli_X_1'")
    print("Available columns:", list(df.columns))
    sys.exit()

print(f"Found {len(sample_cols)} samples, {len(set(col_to_condition.values()))} conditions")
print(f"Conditions: {sorted(set(col_to_condition.values()))}")

df['Species'] = df[protein_col].apply(annotate_species)

for col in sample_cols:
    df[col] = pd.to_numeric(df[col], errors='coerce').replace(0, np.nan)

print("Analyzing at precursor level...")
precursor_df = df.copy()

print("Calculating precursor condition means...")
for condition in sorted(set(col_to_condition.values())):
    condition_cols = [c for c in sample_cols if col_to_condition.get(c) == condition]
    if condition_cols:
        precursor_df[f'Mean_{condition}'] = np.log2(precursor_df[condition_cols]).mean(axis=1)

ref_candidates = [c for c in sorted(set(col_to_condition.values())) if 'coli_1_1' in c]
if not ref_candidates:
    ref_condition = sorted(set(col_to_condition.values()))[0]
    print(f"No 1:1 reference found, using first condition: {ref_condition}")
else:
    ref_condition = ref_candidates[0]
    print(f"Precursor reference condition: {ref_condition}")

for condition in sorted(set(col_to_condition.values())):
    if condition != ref_condition:
        precursor_df[f'FC_{condition}'] = precursor_df[f'Mean_{condition}'] - precursor_df[f'Mean_{ref_condition}']

species_colors = {'Human': '#8B4513', 'E.coli': '#2E8B57', 'cRAP': '#DC143C', 'Unknown': '#DAA520'}
precursor_metrics = []

for condition in sorted(set(col_to_condition.values())):
    if condition == ref_condition: continue
    
    fc_col = f'FC_{condition}'
    quant_col = f'Mean_{ref_condition}'
    plot_df = precursor_df[[fc_col, quant_col, 'Species', protein_col]].dropna()
    
    ratio = extract_ratio(condition)
    ref_ratio = extract_ratio(ref_condition)
    dilution_factor = get_dilution_factor(condition, ref_condition)
    expected_ecoli = np.log2(dilution_factor)
    expected_human = 0
    
    fig, ax = plt.subplots(figsize=(12, 8))
    
    for species in ['Human', 'E.coli', 'cRAP', 'Unknown']:
        sp_data = plot_df[plot_df['Species'] == species]
        if len(sp_data) > 0:
            ax.scatter(sp_data[quant_col], sp_data[fc_col], c=species_colors[species], 
                      label=f"{species} (n={len(sp_data)})", alpha=0.4, s=15, edgecolors='none')
    
    ax.axhline(y=expected_ecoli, color=species_colors['E.coli'], linestyle='--', 
               linewidth=2, alpha=0.7, label=f"Expected E.coli (log2={expected_ecoli:.2f})")
    ax.axhline(y=expected_human, color=species_colors['Human'], linestyle='--', 
               linewidth=2, alpha=0.7, label=f"Expected Human (log2={expected_human:.2f})")
    
    ax.set_xlabel(f'Log2 Mean Quantity in {ref_condition}', fontsize=12, fontweight='bold')
    ax.set_ylabel(f'Log2 Fold Change ({condition} / {ref_condition})', fontsize=12, fontweight='bold')
    ax.set_title(f'LFQbench PRECURSOR: E.coli {ratio}x dilution (1/{ratio}x abundance)', fontsize=14, fontweight='bold')
    ax.legend(loc='best', frameon=True, fancybox=True, shadow=True)
    ax.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig(f'{output_prefix}_precursor_{condition}.png', dpi=300, bbox_inches='tight')
    plt.close()
    print(f"Saved: {output_prefix}_precursor_{condition}.png")
    
    for species in ['Human', 'E.coli', 'cRAP']:
        sp_data = plot_df[plot_df['Species'] == species][fc_col].dropna()
        if len(sp_data) > 3:
            expected = expected_ecoli if species == 'E.coli' else 0
            precursor_metrics.append({
                'Level': 'Precursor',
                'Condition': condition,
                'Species': species,
                'N': len(sp_data),
                'Median_FC': np.median(sp_data),
                'Mean_FC': np.mean(sp_data),
                'Expected_FC': expected,
                'Bias': np.median(sp_data) - expected,
                'Precision_SD': np.std(sp_data)
            })

precursor_df.to_csv(f'{output_prefix}_precursor_data.csv', index=False)
print(f"Saved: {output_prefix}_precursor_data.csv")

print("\nAggregating to protein level...")
agg_dict = {col: 'median' for col in sample_cols}
agg_dict['Species'] = 'first'
protein_df = df.groupby(protein_col).agg(agg_dict).reset_index()

print("Calculating protein condition means...")
conditions = sorted(set(col_to_condition.values()))
for condition in conditions:
    condition_cols = [c for c in sample_cols if col_to_condition.get(c) == condition]
    if condition_cols:
        protein_df[f'Mean_{condition}'] = np.log2(protein_df[condition_cols]).mean(axis=1)

ref_candidates = [c for c in conditions if 'coli_1_1' in c]
if not ref_candidates:
    ref_condition = conditions[0]
    print(f"No 1:1 reference found, using first condition: {ref_condition}")
else:
    ref_condition = ref_candidates[0]
    print(f"Reference condition: {ref_condition}")

for condition in conditions:
    if condition != ref_condition:
        protein_df[f'FC_{condition}'] = protein_df[f'Mean_{condition}'] - protein_df[f'Mean_{ref_condition}']

species_colors = {'Human': '#8B4513', 'E.coli': '#2E8B57', 'cRAP': '#DC143C', 'Unknown': '#DAA520'}
protein_metrics = []

for condition in conditions:
    if condition == ref_condition: continue
    
    fc_col = f'FC_{condition}'
    quant_col = f'Mean_{ref_condition}'
    plot_df = protein_df[[fc_col, quant_col, 'Species', protein_col]].dropna()
    
    ratio = extract_ratio(condition)
    ref_ratio = extract_ratio(ref_condition)
    dilution_factor = get_dilution_factor(condition, ref_condition)
    expected_ecoli = np.log2(dilution_factor)
    expected_human = 0
    
    fig, ax = plt.subplots(figsize=(12, 8))
    
    for species in ['Human', 'E.coli', 'cRAP', 'Unknown']:
        sp_data = plot_df[plot_df['Species'] == species]
        if len(sp_data) > 0:
            ax.scatter(sp_data[quant_col], sp_data[fc_col], c=species_colors[species], 
                      label=f"{species} (n={len(sp_data)})", alpha=0.6, s=30, edgecolors='none')
    
    ax.axhline(y=expected_ecoli, color=species_colors['E.coli'], linestyle='--', 
               linewidth=2, alpha=0.7, label=f"Expected E.coli (log2={expected_ecoli:.2f})")
    ax.axhline(y=expected_human, color=species_colors['Human'], linestyle='--', 
               linewidth=2, alpha=0.7, label=f"Expected Human (log2={expected_human:.2f})")
    
    ax.set_xlabel(f'Log2 Mean Quantity in {ref_condition}', fontsize=12, fontweight='bold')
    ax.set_ylabel(f'Log2 Fold Change ({condition} / {ref_condition})', fontsize=12, fontweight='bold')
    ax.set_title(f'LFQbench PROTEIN: E.coli {ratio}x dilution (1/{ratio}x abundance)', fontsize=14, fontweight='bold')
    ax.legend(loc='best', frameon=True, fancybox=True, shadow=True)
    ax.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig(f'{output_prefix}_protein_{condition}.png', dpi=300, bbox_inches='tight')
    plt.close()
    print(f"Saved: {output_prefix}_protein_{condition}.png")
    
    for species in ['Human', 'E.coli', 'cRAP']:
        sp_data = plot_df[plot_df['Species'] == species][fc_col].dropna()
        if len(sp_data) > 3:
            expected = expected_ecoli if species == 'E.coli' else 0
            protein_metrics.append({
                'Level': 'Protein',
                'Condition': condition,
                'Species': species,
                'N': len(sp_data),
                'Median_FC': np.median(sp_data),
                'Mean_FC': np.mean(sp_data),
                'Expected_FC': expected,
                'Bias': np.median(sp_data) - expected,
                'Precision_SD': np.std(sp_data)
            })

all_metrics = precursor_metrics + protein_metrics
if all_metrics:
    metrics_df = pd.DataFrame(all_metrics)
    metrics_df.to_csv(f'{output_prefix}_metrics.csv', index=False)
    print(f"\nProtein-level Metrics:")
    print(metrics_df[metrics_df['Level']=='Protein'].to_string(index=False))
    print(f"\nPrecursor-level Metrics:")
    print(metrics_df[metrics_df['Level']=='Precursor'].to_string(index=False))
    
    for level in ['Protein', 'Precursor']:
        level_metrics = metrics_df[metrics_df['Level']==level]
        if len(level_metrics) == 0: continue
        
        fig, axes = plt.subplots(1, 2, figsize=(14, 6))
        for species, color in species_colors.items():
            if species == 'Unknown': continue
            sp_data = level_metrics[level_metrics['Species'] == species]
            if len(sp_data) > 0:
                axes[0].plot(range(len(sp_data)), sp_data['Bias'], 'o-', color=color, label=species, linewidth=2, markersize=8)
                axes[1].plot(range(len(sp_data)), sp_data['Precision_SD'], 'o-', color=color, label=species, linewidth=2, markersize=8)
        
        axes[0].axhline(y=0, color='black', linestyle='--', alpha=0.5)
        axes[0].set_ylabel('Bias (Log2 FC)', fontsize=12, fontweight='bold')
        axes[0].set_xlabel('Condition', fontsize=12, fontweight='bold')
        axes[0].set_title(f'{level} Quantification Accuracy', fontsize=14, fontweight='bold')
        axes[0].legend(frameon=True, fancybox=True)
        axes[0].grid(True, alpha=0.3)
        
        axes[1].set_ylabel('Precision (SD)', fontsize=12, fontweight='bold')
        axes[1].set_xlabel('Condition', fontsize=12, fontweight='bold')
        axes[1].set_title(f'{level} Quantification Precision', fontsize=14, fontweight='bold')
        axes[1].legend(frameon=True, fancybox=True)
        axes[1].grid(True, alpha=0.3)
        
        plt.tight_layout()
        plt.savefig(f'{output_prefix}_{level.lower()}_summary.png', dpi=300, bbox_inches='tight')
        plt.close()
        print(f"Saved: {output_prefix}_{level.lower()}_summary.png")
else:
    print("Warning: No metrics calculated (need multiple conditions)")

protein_df.to_csv(f'{output_prefix}_protein_data.csv', index=False)
print(f"Saved: {output_prefix}_protein_data.csv")
print(f"\nDone! Processed {len(protein_df)} proteins and {len(precursor_df)} precursors across {len(conditions)} conditions")
