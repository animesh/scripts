import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

intensity_col = 'intensity_lfq'

# DDA
dda = pd.read_csv(r"Z:\Download\nDDA\nDDA_quantified_protein_fdr.tsv", sep='\t')  # For testing with local CSV export
dda = dda[(~dda['is_decoy']) & (dda[intensity_col].notna()) & (dda[intensity_col] > 0)].copy()
dda['log2_int'] = np.log2(dda[intensity_col])
dda_pivot = dda.pivot_table(index='protein_group_id', columns='file_name', values='log2_int', aggfunc='mean')


# DIA
dia = pd.read_csv(r"Z:\Download\nDDA\nDIA_quantified_protein_fdr.tsv", sep='\t')
dia = dia[(~dia['is_decoy']) & (dia[intensity_col].notna()) & (dia[intensity_col] > 0)].copy()
dia['log2_int'] = np.log2(dia[intensity_col])
dia_pivot = dia.pivot_table(index='protein_group_id', columns='file_name', values='log2_int', aggfunc='mean')


# -----------------------------
# Shared proteins and sample names
# -----------------------------
shared_proteins = dda_pivot.index.intersection(dia_pivot.index)
dda_pivot = dda_pivot.loc[shared_proteins]
dia_pivot = dia_pivot.loc[shared_proteins]

dda_samples = sorted(dda_pivot.columns.tolist())
dia_samples = sorted(dia_pivot.columns.tolist())

# -----------------------------
# Violin plots for DDA and DIA sample distributions
# -----------------------------
dda_violin_data = [dda_pivot[col].dropna().values for col in dda_samples]
dia_violin_data = [dia_pivot[col].dropna().values for col in dia_samples]

fig2, (ax1, ax2) = plt.subplots(1, 2, figsize=(max(8, 0.4 * max(len(dda_samples), len(dia_samples)) + 2), 4), dpi=80)

if len(dda_samples) > 0:
    ax1.violinplot(dda_violin_data, showmeans=False, showmedians=True, showextrema=False)
    ax1.set_title('DDA log2 intensity distributions', fontsize=8)
    ax1.set_xticks(range(1, len(dda_samples) + 1))
    ax1.set_xticklabels(dda_samples, rotation=45, ha='right', fontsize=6)
    ax1.set_ylabel('log2 intensity', fontsize=7)
else:
    ax1.text(0.5, 0.5, 'No DDA samples', ha='center', va='center', fontsize=7)

if len(dia_samples) > 0:
    ax2.violinplot(dia_violin_data, showmeans=False, showmedians=True, showextrema=False)
    ax2.set_title('DIA log2 intensity distributions', fontsize=8)
    ax2.set_xticks(range(1, len(dia_samples) + 1))
    ax2.set_xticklabels(dia_samples, rotation=45, ha='right', fontsize=6)
else:
    ax2.text(0.5, 0.5, 'No DIA samples', ha='center', va='center', fontsize=7)

ax1.tick_params(axis='both', labelsize=6, length=2)
ax2.tick_params(axis='both', labelsize=6, length=2)
fig2.tight_layout()
fig2.savefig('DDA_DIA_violin_plots.png', dpi=300)

# -----------------------------
# Build combined panel figure
# Rows = DDA samples (Y axis)
# Cols = DIA samples (X axis)
# -----------------------------
n_rows = len(dda_samples)
n_cols = len(dia_samples)

fig, axes = plt.subplots(n_rows, n_cols, figsize=(1.45 * n_cols, 1.55 * n_rows), dpi=80)
if n_rows == 1 and n_cols == 1:
    axes = np.array([[axes]])
elif n_rows == 1:
    axes = np.array([axes])
elif n_cols == 1:
    axes = np.array([[ax] for ax in axes])

all_n = []
all_r2 = []

for i, dda_file in enumerate(dda_samples):
    for j, dia_file in enumerate(dia_samples):
        ax = axes[i, j]

        pair = pd.concat([dia_pivot[dia_file], dda_pivot[dda_file]], axis=1).dropna()
        pair.columns = ['dia_x', 'dda_y']
        n_valid = pair.shape[0]

        if n_valid > 0:
            r = pair['dia_x'].corr(pair['dda_y'])
            r2 = (r * r) if pd.notna(r) else np.nan

            # X = DIA, Y = DDA
            ax.scatter(
                pair['dia_x'].values,
                pair['dda_y'].values,
                s=0.35,
                alpha=0.16,
                color='#1f77b4',
                linewidths=0
            )

            ann = 'n=' + str(int(n_valid)) + ' | R^2=' + ('{:.3f}'.format(r2))
            ax.text(
                0.02, 0.98, ann,
                transform=ax.transAxes,
                ha='left', va='top',
                fontsize=4.6,
                bbox=dict(facecolor='white', alpha=0.55, edgecolor='none', pad=0.2)
            )

            all_n.append(n_valid)
            if pd.notna(r2):
                all_r2.append(r2)
        else:
            ax.text(0.5, 0.5, 'n=0', transform=ax.transAxes, ha='center', va='center', fontsize=5)

        if i == n_rows - 1:
            ax.set_xlabel('DIA: ' + dia_file, fontsize=4.7)
        else:
            ax.set_xticklabels([])

        if j == 0:
            ax.set_ylabel('DDA: ' + dda_file, fontsize=4.7)
        else:
            ax.set_yticklabels([])

        ax.tick_params(axis='both', labelsize=4.2, length=1)

fig.suptitle('DDAâDIA scatter matrix (log2 intensity, pairwise valid proteins, all points)', fontsize=7)
fig.tight_layout(rect=[0, 0, 1, 0.96])
fig.savefig('DDA_to_DIA_scatter_matrix.png', dpi=300)

print('Panels:', n_rows * n_cols)
print('Shared proteins:', len(shared_proteins))
print('n_valid median:', int(np.median(all_n)) if len(all_n) > 0 else 0)
print('R^2 range:', round(float(np.min(all_r2)), 3) if len(all_r2) > 0 else np.nan, 'to', round(float(np.max(all_r2)), 3) if len(all_r2) > 0 else np.nan)

