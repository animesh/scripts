#python diaNNparquet.py -f "F:\promec\TIMSTOF\LARS\2025\250107_Hela_Coli\DDAreport.parquet" -c  "Ms1.Area"
#python diaNNparquet.py -f "F:\promec\TIMSTOF\LARS\2025\250107_Hela_Coli\reportDDA.parquet" -c  "Ms1.Area"
import pandas as pd
import pyarrow.parquet as pq
import os
import numpy as np
import re
import argparse

# allow overriding via CLI: `python diaNNparquet.py -f <path>`
parser = argparse.ArgumentParser(description='Generate DIA-NN histograms and ridge plots from a parquet file')
parser.add_argument('-f', '--fileP', help='path to parquet file', default=r'F:\promec\TIMSTOF\LARS\2025\250107_Hela_Coli\DDAreport.parquet')
parser.add_argument('-c', '--value-col', help="name of numeric column to use (default 'Precursor.Normalised'), e.g. 'Precursor.Quantity'", default='Precursor.Normalised')
args = parser.parse_args()
value_col = args.value_col
#value_col = "Ms1.Area"
fileP = args.fileP
# safe token to put into output filenames
safe_col = re.sub(r'[^A-Za-z0-9_-]+', '_', value_col)
mz_parquet = pq.read_table(fileP)
mz_parquet = mz_parquet.to_pandas()
print(mz_parquet.describe())
#mz_parquet.to_csv(fileP+'.csv')
#mz_parquet2 = pd.read_csv(fileP+'.csv',index_col=0)
#print(mz_parquet.describe()-mz_parquet2.describe())
#mzDiff=mz_parquet2['Precursor.Normalised']-mz_parquet['Precursor.Normalised']
#print(mzDiff.describe())
pivoted_peptides_by_run = mz_parquet.pivot_table(index=['Precursor.Id', 'Protein.Names'], columns='Run', values=value_col)
pivoted_peptides_by_run=pivoted_peptides_by_run.reset_index()
print(pivoted_peptides_by_run)
print(pivoted_peptides_by_run.count())
pivoted_peptides_by_run.to_csv(fileP + f'_{safe_col}_pivot_all.csv', index=False)
print('Saved full pivot to', fileP + f'_{safe_col}_pivot_all.csv')

peptides_prots_proteotypic = mz_parquet[mz_parquet['Proteotypic'] == 1]
print(peptides_prots_proteotypic)

peptides_prots_proteotypic_log2int = peptides_prots_proteotypic.copy()
log2_col = f"{value_col}.log2"
# avoid -inf from log2(0) by converting non-positive values to NaN before log
vals = peptides_prots_proteotypic_log2int[value_col]
safe_log2 = np.where(vals > 0, np.log2(vals), np.nan)
peptides_prots_proteotypic_log2int[log2_col] = safe_log2
print(peptides_prots_proteotypic_log2int)

pivoted_peptides_by_run = peptides_prots_proteotypic_log2int.pivot_table(index=['Precursor.Id', 'Protein.Names'], columns='Run', values=log2_col)
pivoted_peptides_by_run=pivoted_peptides_by_run.reset_index()
print(pivoted_peptides_by_run)

print(pivoted_peptides_by_run.count())

pivoted_peptides_by_run_coli = pivoted_peptides_by_run[pivoted_peptides_by_run['Protein.Names'].str.contains('COLI')]
print(pivoted_peptides_by_run_coli)
coli_fname = os.path.splitext(os.path.basename(fileP))[0] + f'_{safe_col}_pivot_coli.csv'
coli_path = os.path.join(os.path.dirname(fileP), coli_fname)
pivoted_peptides_by_run_coli.to_csv(coli_path, index=False)
pivoted_peptides_by_run_coli = pivoted_peptides_by_run_coli.drop(columns=['Precursor.Id', 'Protein.Names'])

pivoted_peptides_by_run_human = pivoted_peptides_by_run[pivoted_peptides_by_run['Protein.Names'].str.contains('HUMAN')]
print(pivoted_peptides_by_run_human)
human_fname = os.path.splitext(os.path.basename(fileP))[0] + f'_{safe_col}_pivot_human.csv'
human_path = os.path.join(os.path.dirname(fileP), human_fname)
pivoted_peptides_by_run_human.to_csv(human_path, index=False)
pivoted_peptides_by_run_human = pivoted_peptides_by_run_human.drop(columns=['Precursor.Id', 'Protein.Names'])

import matplotlib.pyplot as plt
from matplotlib.patches import Patch

# quick per-organism histograms
ax_list = pivoted_peptides_by_run_coli.hist()
for i, ax in enumerate(ax_list.flatten()):
    try:
        colname = pivoted_peptides_by_run_coli.columns[i]
    except Exception:
        colname = f'Run {i+1}'
    ax.set_title(str(colname), fontsize=4)
plt.tight_layout()
plt.savefig(fileP + f'_{safe_col}_coli_hist.svg', format='svg')
plt.close()
ax_list = pivoted_peptides_by_run_human.hist()
for i, ax in enumerate(ax_list.flatten()):
    try:
        colname = pivoted_peptides_by_run_human.columns[i]
    except Exception:
        colname = f'Run {i+1}'
    ax.set_title(str(colname), fontsize=4)
plt.tight_layout()
plt.savefig(fileP + f'_{safe_col}_human_hist.svg', format='svg')
plt.close()


# Ridge / waterfall plot: stacked offset histograms per run
def ridge_plot_runs(coli_df, human_df, runs=None, lane_height=1.0, gap=0.2, bins_method='auto', out_svg=None):
    if runs is None:
        runs = [c for c in coli_df.columns if c in human_df.columns]
    # prepare global bin edges from all data
    all_vals = []
    rows = []
    for r in runs:
        all_vals.append(coli_df[r].dropna().values if r in coli_df.columns else np.array([]))
        all_vals.append(human_df[r].dropna().values if r in human_df.columns else np.array([]))
    all_concat = np.concatenate([a for a in all_vals if a.size > 0]) if len(all_vals) > 0 else np.array([])
    if all_concat.size == 0:
        print('No data for ridge plot')
        return
    bins = np.histogram_bin_edges(all_concat, bins=bins_method)

    # compute raw counts for every run/organism, determine global maximum count, and compute means
    hist_data = {}
    global_max = 0
    means = {}
    for r in runs:
        c_vals = coli_df[r].dropna().values if r in coli_df.columns else np.array([])
        h_vals = human_df[r].dropna().values if r in human_df.columns else np.array([])
        h_c = np.histogram(c_vals, bins=bins, density=False)[0] if c_vals.size > 0 else np.zeros(len(bins) - 1, dtype=int)
        h_h = np.histogram(h_vals, bins=bins, density=False)[0] if h_vals.size > 0 else np.zeros(len(bins) - 1, dtype=int)
        mean_c = float(np.nan) if c_vals.size == 0 else float(np.nanmedian(c_vals))
        mean_h = float(np.nan) if h_vals.size == 0 else float(np.nanmedian(h_vals))
        hist_data[r] = (h_c, h_h)
        means[r] = (mean_c, mean_h)
        if h_c.size > 0:
            global_max = max(global_max, int(h_c.max()))
        if h_h.size > 0:
            global_max = max(global_max, int(h_h.max()))

    # compute per-organism baseline: median of COLI medians and median of HUMAN medians
    coli_meds = [mc for (mc, mh) in means.values() if not np.isnan(mc)]
    human_meds = [mh for (mc, mh) in means.values() if not np.isnan(mh)]
    coli_baseline = float(np.nan) if len(coli_meds) == 0 else float(np.nanmedian(coli_meds))
    human_baseline = float(np.nan) if len(human_meds) == 0 else float(np.nanmedian(human_meds))

    if global_max == 0:
        print('No counts for ridge plot')
        return

    plt.figure(figsize=(8, max(6, len(runs) * (lane_height + gap) * 0.6)))
    yticks = []
    yticklabels = []
    scale = lane_height
    x = 0.5 * (bins[:-1] + bins[1:])

    for i, run in enumerate(runs[::-1]):
        idx = len(runs) - 1 - i
        y_base = idx * (lane_height + gap)
        h_c, h_h = hist_data[run]

        # scale by the global maximum count so heights are comparable across runs
        h_c_scaled = h_c.astype(float) / float(global_max)
        h_h_scaled = h_h.astype(float) / float(global_max)

        if h_c.sum() > 0:
            plt.fill_between(x, y_base, y_base + h_c_scaled * scale, color='C0', alpha=0.6)
            plt.plot(x, y_base + h_c_scaled * scale, color='C0', linewidth=0.7)

        if h_h.sum() > 0:
            plt.fill_between(x, y_base, y_base + h_h_scaled * scale, color='C1', alpha=0.5)
            plt.plot(x, y_base + h_h_scaled * scale, color='C1', linewidth=0.7)

        yticks.append(y_base + lane_height * 0.5)
        yticklabels.append(str(run))

        # annotate medians, deviations from overall median (baseline B), diff and fold on right side
        mean_c, mean_h = means.get(run, (np.nan, np.nan))
        if not np.isnan(mean_c):
            dev_c = mean_c - coli_baseline if not np.isnan(coli_baseline) else np.nan
        else:
            dev_c = np.nan
        if not np.isnan(mean_h):
            dev_h = mean_h - human_baseline if not np.isnan(human_baseline) else np.nan
        else:
            dev_h = np.nan
        # compute 2^dev values (back-transform from log2 deviation)
        pow2_dev_c = (2 ** dev_c) if not np.isnan(dev_c) else np.nan
        pow2_dev_h = (2 ** dev_h) if not np.isnan(dev_h) else np.nan
        anot_x = x.max()
        anot_y = y_base + lane_height * 0.1
        # omit printing the overall median in the lane annotation per request
        anot_text = (
            f'COLI median: {mean_c:.2f}\n'
            f'HUMAN median: {mean_h:.2f}\n'
            f'COLI dev: {dev_c:.2f}\n'
            f'HUMAN dev: {dev_h:.2f}\n'
            f'Fold COLI: {pow2_dev_c:.4f}\n'
            f'Fold HUMAN: {pow2_dev_h:.4f}'
        )
        plt.text(anot_x, anot_y, anot_text, fontsize=6, ha='right', va='bottom')

    plt.yticks(yticks, yticklabels)
    plt.xlabel(f'log2 {value_col}')
    plt.title('Ridge / Waterfall plot per Run (COLI=blue, HUMAN=orange)')
    # print median, deviation and fold (2^dev) values for both organisms per run
    print('Run\tCOLI_median\tHUMAN_median\tCOLI_dev\tHUMAN_dev\tFold_COLI\tFold_HUMAN')
    for r in runs:
        mc, mh = means.get(r, (np.nan, np.nan))
        if not np.isnan(mc):
            devc = mc - coli_baseline if not np.isnan(coli_baseline) else np.nan
        else:
            devc = np.nan
        if not np.isnan(mh):
            devh = mh - human_baseline if not np.isnan(human_baseline) else np.nan
        else:
            devh = np.nan
        pow2c = (2 ** devc) if not np.isnan(devc) else np.nan
        pow2h = (2 ** devh) if not np.isnan(devh) else np.nan
        if not np.isnan(mc) and not np.isnan(mh):
            mc_str = f'{mc:.4f}'
            mh_str = f'{mh:.4f}'
            devc_str = f'{devc:.4f}'
            devh_str = f'{devh:.4f}'
            pow2c_str = f'{pow2c:.4f}'
            pow2h_str = f'{pow2h:.4f}'
        else:
            mc_str = f'{mc:.4f}' if not np.isnan(mc) else 'nan'
            mh_str = f'{mh:.4f}' if not np.isnan(mh) else 'nan'
            devc_str = f'{devc:.4f}' if not np.isnan(devc) else 'nan'
            devh_str = f'{devh:.4f}' if not np.isnan(devh) else 'nan'
            pow2c_str = f'{pow2c:.4f}' if not np.isnan(pow2c) else 'nan'
            pow2h_str = f'{pow2h:.4f}' if not np.isnan(pow2h) else 'nan'
        print(f'{r}\t{mc_str}\t{mh_str}\t{devc_str}\t{devh_str}\t{pow2c_str}\t{pow2h_str}')
        rows.append({
            'Run': r,
            'COLI_median': mc_str,
            'HUMAN_median': mh_str,
            'COLI_dev': devc_str,
            'HUMAN_dev': devh_str,
            'Fold_COLI': pow2c_str,
            'Fold_HUMAN': pow2h_str,
        })
    plt.tight_layout()
    if out_svg:
        # if out_svg is a template name, allow caller to pass full path; otherwise use as given
        plt.savefig(out_svg, format='svg')
        plt.close()
        # save stats table next to the parquet file using parquet basename (avoids permission/dot issues)
        try:
            stats_fname = os.path.splitext(os.path.basename(fileP))[0] + f'_{safe_col}_ridge_stats.csv'
            stats_csv = os.path.join(os.getcwd(), stats_fname)
            stats_df = pd.DataFrame(rows)
            stats_df.to_csv(stats_csv, index=False)
            print('Saved stats CSV to', stats_csv)
        except Exception as e:
            print('Failed to save stats CSV:', e)
    else:
        plt.show()

# call the ridge plot for runs present in either dataframe
all_runs = sorted(list(set(list(pivoted_peptides_by_run_coli.columns) + list(pivoted_peptides_by_run_human.columns))))
ridge_plot_runs(pivoted_peptides_by_run_coli, pivoted_peptides_by_run_human, runs=all_runs, out_svg=fileP + f'_{safe_col}_ridge.svg')




