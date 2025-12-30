#python compareDIffExprDIANNvalues.py DDAreport.parquet_Ms1_Area_pivot_all_protein_data.csv reportDDA.parquet_Ms1_Area_pivot_all_protein_data.csv 
import sys
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from pathlib import Path
from scipy import stats

if len(sys.argv) != 3: sys.exit("USAGE: python compareDIffExprDIANNvalues.py <DDA_protein_data.csv> <DIA_protein_data.csv>")

dda_file = Path(sys.argv[1])
dia_file = Path(sys.argv[2])
output_prefix = "protein_data_comparison"

sns.set_style("whitegrid")
plt.rcParams['figure.dpi'] = 300

print(f"Loading DDA protein data from {dda_file}...")
dda = pd.read_csv(dda_file)

print(f"Loading DIA protein data from {dia_file}...")
dia = pd.read_csv(dia_file)

protein_col = 'Protein.Names'
mean_cols_dda = [c for c in dda.columns if c.startswith('Mean_Hela_coli')]
mean_cols_dia = [c for c in dia.columns if c.startswith('Mean_Hela_coli')]
fc_cols_dda = [c for c in dda.columns if c.startswith('FC_Hela_coli')]
fc_cols_dia = [c for c in dia.columns if c.startswith('FC_Hela_coli')]

print(f"DDA: {len(dda)} proteins")
print(f"DIA: {len(dia)} proteins")

merged = dda[[protein_col, 'Species'] + mean_cols_dda + fc_cols_dda].merge(
    dia[[protein_col, 'Species'] + mean_cols_dia + fc_cols_dia],
    on=[protein_col, 'Species'],
    suffixes=('_DDA', '_DIA'),
    how='inner'
)

print(f"Common proteins: {len(merged)}")
print(f"DDA only: {len(dda) - len(merged)}")
print(f"DIA only: {len(dia) - len(merged)}")

species_colors = {'Human': '#8B4513', 'E.coli': '#2E8B57', 'cRAP': '#DC143C', 'Unknown': '#DAA520'}

fig, axes = plt.subplots(2, 3, figsize=(18, 12))
fig.suptitle('DDA vs DIA: Protein-level Quantification Comparison', fontsize=16, fontweight='bold')

conditions = ['Hela_coli_1_1', 'Hela_coli_2_1', 'Hela_coli_4_1', 'Hela_coli_5_1', 'Hela_coli_10_1']

for idx, condition in enumerate(conditions[:3]):
    ax = axes[0, idx]
    
    dda_col = f'Mean_{condition}_DDA'
    dia_col = f'Mean_{condition}_DIA'
    
    if dda_col not in merged.columns or dia_col not in merged.columns:
        continue
    
    plot_data = merged[[dda_col, dia_col, 'Species']].dropna()
    
    for species, color in species_colors.items():
        sp_data = plot_data[plot_data['Species'] == species]
        if len(sp_data) > 0:
            ax.scatter(sp_data[dda_col], sp_data[dia_col], 
                      c=color, alpha=0.5, s=20, label=f"{species} (n={len(sp_data)})", edgecolors='none')
    
    min_val = min(plot_data[dda_col].min(), plot_data[dia_col].min())
    max_val = max(plot_data[dda_col].max(), plot_data[dia_col].max())
    ax.plot([min_val, max_val], [min_val, max_val], 'k--', alpha=0.5, linewidth=2)
    
    corr = plot_data[dda_col].corr(plot_data[dia_col])
    ax.text(0.05, 0.95, f'R={corr:.3f}', transform=ax.transAxes, 
            fontsize=10, verticalalignment='top', bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))
    
    ax.set_xlabel('DDA (Log2 Intensity)', fontsize=10, fontweight='bold')
    ax.set_ylabel('DIA (Log2 Intensity)', fontsize=10, fontweight='bold')
    ax.set_title(f'{condition.replace("Hela_coli_", "")}', fontsize=11, fontweight='bold')
    ax.legend(fontsize=8, frameon=True, fancybox=True)
    ax.grid(True, alpha=0.3)

for idx, condition in enumerate(conditions[3:]):
    ax = axes[1, idx]
    
    dda_col = f'Mean_{condition}_DDA'
    dia_col = f'Mean_{condition}_DIA'
    
    if dda_col not in merged.columns or dia_col not in merged.columns:
        continue
    
    plot_data = merged[[dda_col, dia_col, 'Species']].dropna()
    
    for species, color in species_colors.items():
        sp_data = plot_data[plot_data['Species'] == species]
        if len(sp_data) > 0:
            ax.scatter(sp_data[dda_col], sp_data[dia_col], 
                      c=color, alpha=0.5, s=20, label=f"{species} (n={len(sp_data)})", edgecolors='none')
    
    min_val = min(plot_data[dda_col].min(), plot_data[dia_col].min())
    max_val = max(plot_data[dda_col].max(), plot_data[dia_col].max())
    ax.plot([min_val, max_val], [min_val, max_val], 'k--', alpha=0.5, linewidth=2)
    
    corr = plot_data[dda_col].corr(plot_data[dia_col])
    ax.text(0.05, 0.95, f'R={corr:.3f}', transform=ax.transAxes, 
            fontsize=10, verticalalignment='top', bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))
    
    ax.set_xlabel('DDA (Log2 Intensity)', fontsize=10, fontweight='bold')
    ax.set_ylabel('DIA (Log2 Intensity)', fontsize=10, fontweight='bold')
    ax.set_title(f'{condition.replace("Hela_coli_", "")}', fontsize=11, fontweight='bold')
    ax.legend(fontsize=8, frameon=True, fancybox=True)
    ax.grid(True, alpha=0.3)

axes[1, 2].axis('off')

plt.tight_layout()
plt.savefig(f'{output_prefix}_scatter_all_conditions.png', dpi=300, bbox_inches='tight')
plt.close()
print(f"Saved: {output_prefix}_scatter_all_conditions.png")

fig, axes = plt.subplots(2, 3, figsize=(18, 12))
fig.suptitle('DDA vs DIA: Fold Change Comparison (vs 1_1 reference)', fontsize=16, fontweight='bold')

fc_conditions = [c.replace('FC_', '') for c in fc_cols_dda if 'FC_' in c]

for idx, condition in enumerate(fc_conditions[:3]):
    ax = axes[0, idx]
    
    dda_col = f'FC_{condition}_DDA'
    dia_col = f'FC_{condition}_DIA'
    
    if dda_col not in merged.columns or dia_col not in merged.columns:
        continue
    
    plot_data = merged[[dda_col, dia_col, 'Species']].dropna()
    
    for species, color in species_colors.items():
        sp_data = plot_data[plot_data['Species'] == species]
        if len(sp_data) > 0:
            ax.scatter(sp_data[dda_col], sp_data[dia_col], 
                      c=color, alpha=0.5, s=20, label=f"{species} (n={len(sp_data)})", edgecolors='none')
    
    min_val = min(plot_data[dda_col].min(), plot_data[dia_col].min())
    max_val = max(plot_data[dda_col].max(), plot_data[dia_col].max())
    ax.plot([min_val, max_val], [min_val, max_val], 'k--', alpha=0.5, linewidth=2)
    
    corr = plot_data[dda_col].corr(plot_data[dia_col])
    ax.text(0.05, 0.95, f'R={corr:.3f}', transform=ax.transAxes, 
            fontsize=10, verticalalignment='top', bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))
    
    ax.set_xlabel('DDA Fold Change (Log2)', fontsize=10, fontweight='bold')
    ax.set_ylabel('DIA Fold Change (Log2)', fontsize=10, fontweight='bold')
    ax.set_title(f'{condition.replace("Hela_coli_", "")}', fontsize=11, fontweight='bold')
    ax.legend(fontsize=8, frameon=True, fancybox=True)
    ax.grid(True, alpha=0.3)
    ax.axhline(y=0, color='gray', linestyle='--', alpha=0.3)
    ax.axvline(x=0, color='gray', linestyle='--', alpha=0.3)

for idx, condition in enumerate(fc_conditions[3:]):
    if idx >= 3: break
    ax = axes[1, idx]
    
    dda_col = f'FC_{condition}_DDA'
    dia_col = f'FC_{condition}_DIA'
    
    if dda_col not in merged.columns or dia_col not in merged.columns:
        continue
    
    plot_data = merged[[dda_col, dia_col, 'Species']].dropna()
    
    for species, color in species_colors.items():
        sp_data = plot_data[plot_data['Species'] == species]
        if len(sp_data) > 0:
            ax.scatter(sp_data[dda_col], sp_data[dia_col], 
                      c=color, alpha=0.5, s=20, label=f"{species} (n={len(sp_data)})", edgecolors='none')
    
    min_val = min(plot_data[dda_col].min(), plot_data[dia_col].min())
    max_val = max(plot_data[dda_col].max(), plot_data[dia_col].max())
    ax.plot([min_val, max_val], [min_val, max_val], 'k--', alpha=0.5, linewidth=2)
    
    corr = plot_data[dda_col].corr(plot_data[dia_col])
    ax.text(0.05, 0.95, f'R={corr:.3f}', transform=ax.transAxes, 
            fontsize=10, verticalalignment='top', bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))
    
    ax.set_xlabel('DDA Fold Change (Log2)', fontsize=10, fontweight='bold')
    ax.set_ylabel('DIA Fold Change (Log2)', fontsize=10, fontweight='bold')
    ax.set_title(f'{condition.replace("Hela_coli_", "")}', fontsize=11, fontweight='bold')
    ax.legend(fontsize=8, frameon=True, fancybox=True)
    ax.grid(True, alpha=0.3)
    ax.axhline(y=0, color='gray', linestyle='--', alpha=0.3)
    ax.axvline(x=0, color='gray', linestyle='--', alpha=0.3)

if len(fc_conditions) <= 3:
    axes[1, 2].axis('off')

plt.tight_layout()
plt.savefig(f'{output_prefix}_foldchange_comparison.png', dpi=300, bbox_inches='tight')
plt.close()
print(f"Saved: {output_prefix}_foldchange_comparison.png")

fig, axes = plt.subplots(1, 2, figsize=(16, 6))
fig.suptitle('DDA vs DIA: Quantification Agreement by Species', fontsize=16, fontweight='bold')

ref_condition = 'Hela_coli_1_1'
dda_col = f'Mean_{ref_condition}_DDA'
dia_col = f'Mean_{ref_condition}_DIA'

plot_data = merged[[dda_col, dia_col, 'Species']].dropna()

for species, color in species_colors.items():
    sp_data = plot_data[plot_data['Species'] == species]
    if len(sp_data) > 0:
        axes[0].scatter(sp_data[dda_col], sp_data[dia_col], 
                       c=color, alpha=0.4, s=30, label=f"{species} (n={len(sp_data)})", edgecolors='none')

min_val = plot_data[dda_col].min()
max_val = plot_data[dda_col].max()
axes[0].plot([min_val, max_val], [min_val, max_val], 'k--', alpha=0.5, linewidth=2, label='Perfect agreement')

corr = plot_data[dda_col].corr(plot_data[dia_col])
axes[0].text(0.05, 0.95, f'Overall R={corr:.3f}', transform=axes[0].transAxes, 
            fontsize=12, verticalalignment='top', bbox=dict(boxstyle='round', facecolor='white', alpha=0.9))

axes[0].set_xlabel('DDA Log2 Intensity', fontsize=12, fontweight='bold')
axes[0].set_ylabel('DIA Log2 Intensity', fontsize=12, fontweight='bold')
axes[0].set_title(f'Reference Condition ({ref_condition})', fontsize=13, fontweight='bold')
axes[0].legend(fontsize=10, frameon=True, fancybox=True)
axes[0].grid(True, alpha=0.3)

plot_data['Difference'] = plot_data[dia_col] - plot_data[dda_col]
plot_data['Mean'] = (plot_data[dia_col] + plot_data[dda_col]) / 2

for species, color in species_colors.items():
    sp_data = plot_data[plot_data['Species'] == species]
    if len(sp_data) > 0:
        axes[1].scatter(sp_data['Mean'], sp_data['Difference'], 
                       c=color, alpha=0.4, s=30, label=f"{species} (n={len(sp_data)})", edgecolors='none')

mean_diff = plot_data['Difference'].mean()
std_diff = plot_data['Difference'].std()
axes[1].axhline(y=mean_diff, color='blue', linestyle='-', linewidth=2, label=f'Mean diff={mean_diff:.3f}')
axes[1].axhline(y=mean_diff + 1.96*std_diff, color='red', linestyle='--', linewidth=2, alpha=0.7, label='±1.96 SD')
axes[1].axhline(y=mean_diff - 1.96*std_diff, color='red', linestyle='--', linewidth=2, alpha=0.7)
axes[1].axhline(y=0, color='black', linestyle=':', alpha=0.5)

axes[1].set_xlabel('Mean Log2 Intensity (DDA + DIA)/2', fontsize=12, fontweight='bold')
axes[1].set_ylabel('Difference (DIA - DDA)', fontsize=12, fontweight='bold')
axes[1].set_title('Bland-Altman Plot', fontsize=13, fontweight='bold')
axes[1].legend(fontsize=10, frameon=True, fancybox=True)
axes[1].grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig(f'{output_prefix}_agreement_analysis.png', dpi=300, bbox_inches='tight')
plt.close()
print(f"Saved: {output_prefix}_agreement_analysis.png")

print("\n" + "="*80)
print("CORRELATION ANALYSIS BY CONDITION")
print("="*80)

corr_summary = []
for condition in conditions:
    dda_col = f'Mean_{condition}_DDA'
    dia_col = f'Mean_{condition}_DIA'
    
    if dda_col not in merged.columns or dia_col not in merged.columns:
        continue
    
    plot_data = merged[[dda_col, dia_col, 'Species']].dropna()
    
    overall_corr = plot_data[dda_col].corr(plot_data[dia_col])
    overall_r2 = overall_corr**2
    
    print(f"\n{condition}:")
    print(f"  Overall: R={overall_corr:.4f}, R²={overall_r2:.4f}, N={len(plot_data)}")
    
    for species in ['Human', 'E.coli']:
        sp_data = plot_data[plot_data['Species'] == species]
        if len(sp_data) > 5:
            sp_corr = sp_data[dda_col].corr(sp_data[dia_col])
            sp_r2 = sp_corr**2
            print(f"  {species}: R={sp_corr:.4f}, R²={sp_r2:.4f}, N={len(sp_data)}")
            
            corr_summary.append({
                'Condition': condition,
                'Species': species,
                'Correlation': sp_corr,
                'R_squared': sp_r2,
                'N': len(sp_data)
            })

corr_df = pd.DataFrame(corr_summary)
corr_df.to_csv(f'{output_prefix}_correlations.csv', index=False)

print("\n" + "="*80)
print("DETECTION OVERLAP ANALYSIS")
print("="*80)

dda_proteins = set(dda[protein_col])
dia_proteins = set(dia[protein_col])
common_proteins = dda_proteins & dia_proteins

print(f"\nTotal DDA proteins: {len(dda_proteins)}")
print(f"Total DIA proteins: {len(dia_proteins)}")
print(f"Common proteins: {len(common_proteins)}")
print(f"DDA-only proteins: {len(dda_proteins - dia_proteins)}")
print(f"DIA-only proteins: {len(dia_proteins - dda_proteins)}")
print(f"Overlap: {len(common_proteins)/len(dda_proteins | dia_proteins)*100:.1f}%")

for species in ['Human', 'E.coli', 'cRAP']:
    dda_sp = set(dda[dda['Species'] == species][protein_col])
    dia_sp = set(dia[dia['Species'] == species][protein_col])
    common_sp = dda_sp & dia_sp
    
    print(f"\n{species}:")
    print(f"  DDA: {len(dda_sp)}, DIA: {len(dia_sp)}, Common: {len(common_sp)}")
    print(f"  DDA-only: {len(dda_sp - dia_sp)}, DIA-only: {len(dia_sp - dda_sp)}")
    print(f"  Overlap: {len(common_sp)/len(dda_sp | dia_sp)*100:.1f}%")

overlap_summary = {
    'Total_DDA': len(dda_proteins),
    'Total_DIA': len(dia_proteins),
    'Common': len(common_proteins),
    'DDA_only': len(dda_proteins - dia_proteins),
    'DIA_only': len(dia_proteins - dda_proteins),
    'Overlap_percent': len(common_proteins)/len(dda_proteins | dia_proteins)*100
}

overlap_df = pd.DataFrame([overlap_summary])
overlap_df.to_csv(f'{output_prefix}_overlap_summary.csv', index=False)

merged.to_csv(f'{output_prefix}_merged_data.csv', index=False)
print(f"\nSaved: {output_prefix}_merged_data.csv")
print(f"Saved: {output_prefix}_correlations.csv")
print(f"Saved: {output_prefix}_overlap_summary.csv")
print("\nDone!")
