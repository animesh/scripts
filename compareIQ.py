import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt
from scipy.stats import pearsonr, spearmanr

# 1. Load Data
df_iq = pd.read_csv('peptides.txtiQ_log2_LFQ.csv').rename(columns={'Leading razor protein': 'Protein'})
df_mq = pd.read_csv('proteinGroups.txt', sep='\t', low_memory=False)
df_mq['Protein'] = df_mq['Majority protein IDs'].str.split(';').str[0]
df_mo = pd.read_csv('maxLFQmo_ratio-median_scale-sum_min-1_anchor-AllSamplesMaximum_decoy-54_cont-223_excl-0_ug-no_up-no_zi-yes (1).tsv', sep='\t').rename(columns={'_protein': 'Protein'})

samples_ups1 = ['UPS1_01', 'UPS1_02', 'UPS1_03', 'UPS1_04']
samples_ups2 = ['UPS2_01', 'UPS2_02', 'UPS2_03', 'UPS2_04']

# 2. Process Data
all_comparisons = []
for i in range(4):
    s1, s2 = samples_ups1[i], samples_ups2[i]
    
    # Merge and log2 transform
    df = df_iq[['Protein', s1, s2]].rename(columns={s1: 'iq_s1', s2: 'iq_s2'})
    
    for method, ref_df in [('mq', df_mq), ('mo', df_mo)]:
        ref_s1 = ref_df[['Protein', f'LFQ intensity {s1}']].rename(columns={f'LFQ intensity {s1}': f'{method}_s1'})
        ref_s2 = ref_df[['Protein', f'LFQ intensity {s2}']].rename(columns={f'LFQ intensity {s2}': f'{method}_s2'})
        df = df.merge(ref_s1, on='Protein').merge(ref_s2, on='Protein')
    
    for method in ['mq', 'mo']:
        df[f'{method}_s1'] = np.log2(df[f'{method}_s1'].replace(0, np.nan))
        df[f'{method}_s2'] = np.log2(df[f'{method}_s2'].replace(0, np.nan))
        
    df['Sample_Pair'] = f'{s1}_{s2}'
    df['is_ups'] = df['Protein'].str.contains('ups', case=False, na=False)
    all_comparisons.append(df)

final_df = pd.concat(all_comparisons).reset_index(drop=True)

# 3. Define Clusters
ups_df = final_df[final_df['is_ups'] == True].copy()
# Tiering UPS proteins by intensity to create the Figure 6 clusters
ups_df['Cluster'] = pd.qcut(ups_df['mq_s1'], q=4, labels=['Tier 1', 'Tier 2', 'Tier 3', 'Tier 4'])
final_df = final_df.merge(ups_df[['Protein', 'Sample_Pair', 'Cluster']], on=['Protein', 'Sample_Pair'], how='left')
final_df['Cluster'] = final_df['Cluster'].astype(str).replace('nan', 'E. coli')

# 4. Metrics (UPS Subset Only)
print("--- Metrics: MAE, Pearson, Spearman (vs MaxQuant) for UPS Proteins ---")
ups_data = final_df[final_df['is_ups'] == True].dropna()

for method in ['iq', 'mo']:
    for i in range(4):
        subset = ups_data[ups_data['Sample_Pair'] == f'{samples_ups1[i]}_{samples_ups2[i]}']
        mae = np.mean(np.abs(subset[f'{method}_s1'] - subset['mq_s1']))
        corr, _ = pearsonr(subset[f'{method}_s1'], subset['mq_s1'])
        print(f"{method.upper()} vs MQ ({samples_ups1[i]}): MAE={mae:.4f} | Pearson={corr:.4f}")

# 5. Visualizations
fig, axes = plt.subplots(1, 3, figsize=(18, 6), sharey=True)
methods = [('iq', 'iQ'), ('mq', 'MaxQuant'), ('mo', 'maxLFQmo')]

for idx, (col_prefix, title) in enumerate(methods):
    ax = axes[idx]
    plot_data = final_df.copy()
    plot_data['log_ratio'] = plot_data[f'{col_prefix}_s2'] - plot_data[f'{col_prefix}_s1']
    plot_data['log_intensity'] = plot_data[f'{col_prefix}_s1']
    
    sns.scatterplot(data=plot_data, x='log_intensity', y='log_ratio', hue='Cluster', 
                    palette={'E. coli': 'lightgray', 'Tier 1': 'red', 'Tier 2': 'green', 'Tier 3': 'blue', 'Tier 4': 'orange'},
                    ax=ax, alpha=0.5, s=20)
    
    ax.set_title(f'{title}: Log Ratio vs Intensity')
    ax.axhline(0, color='black', linestyle='--')
    ax.set_xlabel('Log2 Intensity (Sample 1)')
    if idx == 0: ax.set_ylabel('Log2 Ratio (S2 / S1)')

plt.tight_layout()
plt.show()

# 6. Violin Plot (Ratio Distributions)
plt.figure(figsize=(10, 6))
ups_only = final_df[final_df['is_ups'] == True].copy()
ups_only['log_ratio'] = ups_only['mq_s2'] - ups_only['mq_s1']

sns.violinplot(data=ups_only, x='Cluster', y='log_ratio', palette='viridis', hue='Cluster', legend=False)
plt.axhline(0, color='black', linestyle='--')
plt.title('Distribution of Log2 Ratios (MaxQuant) by UPS Intensity Tier')
plt.ylabel('Log2 Ratio (S2 / S1)')
plt.show()
