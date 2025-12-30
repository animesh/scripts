#python compareDIffExprDIANNmetrics.py DDAreport.parquet_Ms1_Area_pivot_all_metrics.csv reportDDA.parquet_Ms1_Area_pivot_all_metrics.csv 
import sys
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from pathlib import Path

if len(sys.argv) != 3: sys.exit("USAGE: python compareDIffExprDIANNmetrics.py <DDA_metrics.csv> <DIA_metrics.csv>")

dda_file = Path(sys.argv[1])
dia_file = Path(sys.argv[2])
output_prefix = "DDA_vs_DIA_comparison"

sns.set_style("whitegrid")
plt.rcParams['figure.dpi'] = 300

print(f"Loading DDA metrics from {dda_file}...")
dda = pd.read_csv(dda_file)
dda['Mode'] = 'DDA'

print(f"Loading DIA metrics from {dia_file}...")
dia = pd.read_csv(dia_file)
dia['Mode'] = 'DIA'

combined = pd.concat([dda, dia], ignore_index=True)

species_colors = {'Human': '#8B4513', 'E.coli': '#2E8B57', 'cRAP': '#DC143C'}
mode_markers = {'DDA': 'o', 'DIA': 's'}

print("\n" + "="*80)
print("BIAS COMPARISON (lower is better)")
print("="*80)
bias_summary = combined.pivot_table(index=['Level', 'Condition', 'Species'], 
                                     columns='Mode', values='Bias', aggfunc='first')
print(bias_summary)

print("\n" + "="*80)
print("PRECISION COMPARISON (lower is better)")
print("="*80)
precision_summary = combined.pivot_table(index=['Level', 'Condition', 'Species'], 
                                          columns='Mode', values='Precision_SD', aggfunc='first')
print(precision_summary)

for level in ['Protein', 'Precursor']:
    level_data = combined[combined['Level'] == level]
    if len(level_data) == 0: continue
    
    fig, axes = plt.subplots(2, 2, figsize=(16, 12))
    fig.suptitle(f'{level}-Level: DDA vs DIA Comparison', fontsize=16, fontweight='bold', y=0.995)
    
    for species in ['Human', 'E.coli']:
        sp_data = level_data[level_data['Species'] == species]
        if len(sp_data) == 0: continue
        
        conditions = sorted(sp_data['Condition'].unique())
        
        for mode in ['DDA', 'DIA']:
            mode_data = sp_data[sp_data['Mode'] == mode].sort_values('Condition')
            if len(mode_data) == 0: continue
            
            x_pos = range(len(mode_data))
            
            if species == 'Human':
                axes[0, 0].plot(x_pos, mode_data['Bias'].abs(), 
                               marker=mode_markers[mode], linestyle='-', linewidth=2, 
                               markersize=8, label=f'{mode}', alpha=0.7)
                axes[0, 1].plot(x_pos, mode_data['Precision_SD'], 
                               marker=mode_markers[mode], linestyle='-', linewidth=2, 
                               markersize=8, label=f'{mode}', alpha=0.7)
            else:
                axes[1, 0].plot(x_pos, mode_data['Bias'].abs(), 
                               marker=mode_markers[mode], linestyle='-', linewidth=2, 
                               markersize=8, label=f'{mode}', alpha=0.7)
                axes[1, 1].plot(x_pos, mode_data['Precision_SD'], 
                               marker=mode_markers[mode], linestyle='-', linewidth=2, 
                               markersize=8, label=f'{mode}', alpha=0.7)
        
        row = 0 if species == 'Human' else 1
        axes[row, 0].set_title(f'{species} - Absolute Bias', fontsize=12, fontweight='bold')
        axes[row, 0].set_ylabel('|Bias| (Log2 FC)', fontsize=11, fontweight='bold')
        axes[row, 0].set_xlabel('Condition', fontsize=11, fontweight='bold')
        axes[row, 0].legend(frameon=True, fancybox=True)
        axes[row, 0].grid(True, alpha=0.3)
        axes[row, 0].set_xticks(range(len(conditions)))
        axes[row, 0].set_xticklabels([c.replace('Hela_coli_', '') for c in conditions], rotation=45)
        
        axes[row, 1].set_title(f'{species} - Precision', fontsize=12, fontweight='bold')
        axes[row, 1].set_ylabel('Precision SD (Log2 FC)', fontsize=11, fontweight='bold')
        axes[row, 1].set_xlabel('Condition', fontsize=11, fontweight='bold')
        axes[row, 1].legend(frameon=True, fancybox=True)
        axes[row, 1].grid(True, alpha=0.3)
        axes[row, 1].set_xticks(range(len(conditions)))
        axes[row, 1].set_xticklabels([c.replace('Hela_coli_', '') for c in conditions], rotation=45)
    
    plt.tight_layout()
    plt.savefig(f'{output_prefix}_{level.lower()}_metrics.png', dpi=300, bbox_inches='tight')
    plt.close()
    print(f"Saved: {output_prefix}_{level.lower()}_metrics.png")

for level in ['Protein', 'Precursor']:
    level_data = combined[combined['Level'] == level]
    if len(level_data) == 0: continue
    
    ecoli_data = level_data[level_data['Species'] == 'E.coli']
    if len(ecoli_data) == 0: continue
    
    fig, axes = plt.subplots(1, 2, figsize=(16, 6))
    fig.suptitle(f'{level}-Level E.coli: DDA vs DIA Direct Comparison', fontsize=16, fontweight='bold')
    
    for mode in ['DDA', 'DIA']:
        mode_data = ecoli_data[ecoli_data['Mode'] == mode].sort_values('Condition')
        
        axes[0].scatter(mode_data['Expected_FC'], mode_data['Median_FC'], 
                       s=150, marker=mode_markers[mode], label=mode, alpha=0.7, edgecolors='black', linewidths=1.5)
        
        axes[1].scatter(mode_data['N'], mode_data['Bias'].abs(), 
                       s=150, marker=mode_markers[mode], label=mode, alpha=0.7, edgecolors='black', linewidths=1.5)
    
    axes[0].plot([-4, 0], [-4, 0], 'k--', alpha=0.5, linewidth=2, label='Perfect quantification')
    axes[0].set_xlabel('Expected Log2 FC', fontsize=12, fontweight='bold')
    axes[0].set_ylabel('Measured Log2 FC', fontsize=12, fontweight='bold')
    axes[0].set_title('Expected vs Measured', fontsize=13, fontweight='bold')
    axes[0].legend(frameon=True, fancybox=True, fontsize=10)
    axes[0].grid(True, alpha=0.3)
    
    axes[1].set_xlabel(f'Number of {level}s Quantified', fontsize=12, fontweight='bold')
    axes[1].set_ylabel('Absolute Bias (Log2 FC)', fontsize=12, fontweight='bold')
    axes[1].set_title('Coverage vs Accuracy Trade-off', fontsize=13, fontweight='bold')
    axes[1].legend(frameon=True, fancybox=True, fontsize=10)
    axes[1].grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig(f'{output_prefix}_{level.lower()}_ecoli_scatter.png', dpi=300, bbox_inches='tight')
    plt.close()
    print(f"Saved: {output_prefix}_{level.lower()}_ecoli_scatter.png")

for level in ['Protein', 'Precursor']:
    level_data = combined[combined['Level'] == level]
    if len(level_data) == 0: continue
    
    ecoli_data = level_data[level_data['Species'] == 'E.coli'].copy()
    if len(ecoli_data) == 0: continue
    
    ecoli_data['Dilution'] = ecoli_data['Condition'].str.extract(r'(\d+)_1')[0].astype(int)
    
    fig, ax = plt.subplots(figsize=(12, 8))
    
    for mode in ['DDA', 'DIA']:
        mode_data = ecoli_data[ecoli_data['Mode'] == mode].sort_values('Dilution')
        ax.plot(mode_data['Dilution'], mode_data['Bias'].abs(), 
               marker=mode_markers[mode], linestyle='-', linewidth=3, markersize=12,
               label=f'{mode}', alpha=0.7)
    
    ax.set_xlabel('E.coli Dilution Factor (fold)', fontsize=13, fontweight='bold')
    ax.set_ylabel('Absolute Bias (Log2 FC)', fontsize=13, fontweight='bold')
    ax.set_title(f'{level}-Level: Bias vs Dilution Factor', fontsize=15, fontweight='bold')
    ax.legend(frameon=True, fancybox=True, fontsize=11, loc='best')
    ax.grid(True, alpha=0.3)
    ax.set_xscale('log', base=2)
    ax.set_xticks([1, 2, 4, 5, 10])
    ax.set_xticklabels(['1x', '2x', '4x', '5x', '10x'])
    
    plt.tight_layout()
    plt.savefig(f'{output_prefix}_{level.lower()}_dilution_bias.png', dpi=300, bbox_inches='tight')
    plt.close()
    print(f"Saved: {output_prefix}_{level.lower()}_dilution_bias.png")

print("\n" + "="*80)
print("SUMMARY STATISTICS")
print("="*80)

for level in ['Protein', 'Precursor']:
    print(f"\n{level} Level:")
    level_data = combined[combined['Level'] == level]
    
    for species in ['Human', 'E.coli']:
        sp_data = level_data[level_data['Species'] == species]
        if len(sp_data) == 0: continue
        
        print(f"\n  {species}:")
        for mode in ['DDA', 'DIA']:
            mode_data = sp_data[sp_data['Mode'] == mode]
            if len(mode_data) == 0: continue
            
            mean_bias = mode_data['Bias'].abs().mean()
            mean_precision = mode_data['Precision_SD'].mean()
            mean_n = mode_data['N'].mean()
            
            print(f"    {mode}: Avg |Bias|={mean_bias:.3f}, Avg Precision={mean_precision:.3f}, Avg N={mean_n:.0f}")

winner_summary = []
for level in ['Protein', 'Precursor']:
    level_data = combined[combined['Level'] == level]
    for species in ['Human', 'E.coli']:
        sp_data = level_data[level_data['Species'] == species]
        if len(sp_data) == 0: continue
        
        dda_bias = sp_data[sp_data['Mode'] == 'DDA']['Bias'].abs().mean()
        dia_bias = sp_data[sp_data['Mode'] == 'DIA']['Bias'].abs().mean()
        
        dda_prec = sp_data[sp_data['Mode'] == 'DDA']['Precision_SD'].mean()
        dia_prec = sp_data[sp_data['Mode'] == 'DIA']['Precision_SD'].mean()
        
        bias_winner = 'DDA' if dda_bias < dia_bias else 'DIA'
        prec_winner = 'DDA' if dda_prec < dia_prec else 'DIA'
        
        winner_summary.append({
            'Level': level,
            'Species': species,
            'Bias_Winner': bias_winner,
            'Bias_Diff': abs(dda_bias - dia_bias),
            'Precision_Winner': prec_winner,
            'Precision_Diff': abs(dda_prec - dia_prec)
        })

winner_df = pd.DataFrame(winner_summary)
winner_df.to_csv(f'{output_prefix}_winner_summary.csv', index=False)

print("\n" + "="*80)
print("WINNER SUMMARY")
print("="*80)
print(winner_df.to_string(index=False))

print(f"\n\nAll comparison results saved with prefix: {output_prefix}")
print("Done!")
