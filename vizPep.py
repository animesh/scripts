#C:\Python314\python.exe -m pip install requests matplotlib pandas alphatims pyopenms pyopenms_viz
#C:\Python314\python.exe vizPep.py YNDTFWK
#check example from https://pyopenms-viz.readthedocs.io/en/latest/Getting%20Started.html#Case-Example:-Inspecting-a-Peptide-in-DIA details in https://pubs.acs.org/jprobs/article/24/4/2152/3774490/pyOpenMS-viz-Streamlining-Mass-Spectrometry-Data
import os
import sys
import gc
import atexit
import tempfile
import warnings

# Suppress internal warnings
warnings.filterwarnings('ignore')
os.environ['PYTHONWARNINGS'] = 'ignore'

import requests
import zipfile
import pandas as pd
import matplotlib.pyplot as plt
import pyopenms as oms
import alphatims.bruker
import alphatims.tempmmap
import pyopenms_viz

# Unregister alphatims atexit hook to avoid Windows memory map locks
if hasattr(alphatims.tempmmap, 'atexit_clear'):
    atexit.unregister(alphatims.tempmmap.atexit_clear)

# Detach weakref finalizers on temporary directories created by alphatims
for attr_name in dir(alphatims.tempmmap):
    attr_val = getattr(alphatims.tempmmap, attr_name)
    if isinstance(attr_val, tempfile.TemporaryDirectory) and hasattr(attr_val, '_finalizer'):
        attr_val._finalizer.detach()

# Parse sequence and optional charge filter from command line arguments
sequence = sys.argv[1].upper() if len(sys.argv) > 1 else "YNDTFWK"
user_charge = int(sys.argv[2]) if len(sys.argv) > 2 else None

# Check specified charge or scan candidate charge states 2 and 3 by default
charges_to_scan = [user_charge] if user_charge else [2, 3]

# 1. Download sample data if missing
url = 'https://github.com/MannLabs/alphatims/releases/download/0.1.210317/20201207_tims03_Evo03_PS_SA_HeLa_200ng_EvoSep_prot_high_speed_21min_8cm_S1-C8_1_22474.d.zip'
file_name = '20201207_tims03_Evo03_PS_SA_HeLa_200ng_EvoSep_prot_high_speed_21min_8cm_S1-C8_1_22474.d.zip'
extracted_folder = './20201207_tims03_Evo03_PS_SA_HeLa_200ng_EvoSep_prot_high_speed_21min_8cm_S1-C8_1_22474.d'

if not os.path.exists(extracted_folder):
    print("Downloading sample dataset...")
    response = requests.get(url)
    with open(file_name, 'wb') as file:
        file.write(response.content)
    print("Extracting dataset...")
    with zipfile.ZipFile(file_name, 'r') as zip_ref:
        zip_ref.extractall('./')
    os.remove(file_name)

# 2. Load dataset
dia_data = alphatims.bruker.TimsTOF(extracted_folder)
seq = oms.AASequence.fromString(sequence)
ppm = 50.0

def find_2d_apexes(df_peak, min_intensity_ratio=0.10, min_rt_diff=30.0, min_im_diff=0.04, max_peaks=3):
    """Detect distinct feature apexes in RT and Ion Mobility space."""
    if df_peak.empty:
        return []
    
    max_intensity = df_peak['intensity_values'].max()
    threshold = max_intensity * min_intensity_ratio
    candidates = df_peak[df_peak['intensity_values'] >= threshold].sort_values(by='intensity_values', ascending=False)
    
    apexes = []
    for _, row in candidates.iterrows():
        rt = float(row['rt_values'])
        im = float(row['mobility_values'])
        intensity = float(row['intensity_values'])
        
        is_duplicate = False
        for prev_rt, prev_im, _ in apexes:
            if abs(rt - prev_rt) < min_rt_diff and abs(im - prev_im) < min_im_diff:
                is_duplicate = True
                break
        
        if not is_duplicate:
            apexes.append((rt, im, intensity))
            if len(apexes) >= max_peaks:
                break
                
    return apexes

# 3. Process each charge state and detected apex
pd.options.plotting.backend = 'ms_matplotlib'
total_detected_features = 0

for charge in charges_to_scan:
    precursor_mz = seq.getMZ(charge)
    prec_mz_slice = slice(precursor_mz / (1 + ppm / 10**6), precursor_mz * (1 + ppm / 10**6))
    
    # Calculate fragment m/z
    n = len(sequence)
    fragment_mzs = {}
    for i in range(1, n + 1):
        y_sub = seq.getSubsequence(n - i, i)
        fragment_mzs[f"y{i}"] = y_sub.getMZ(1)
        
        b_sub = seq.getSubsequence(0, i)
        fragment_mzs[f"b{i}"] = b_sub.getMonoWeight() - 18.010565 + 1.007276

    # Extract precursor profile across entire LC-IM space
    try:
        indices = dia_data[:, :, 0, prec_mz_slice, "raw"]
        df_peak = dia_data.as_dataframe(indices)
    except Exception:
        df_peak = pd.DataFrame()

    apexes = find_2d_apexes(df_peak)
    if not apexes:
        print(f"No signal detected for sequence {sequence} with charge {charge}+")
        continue

    print(f"\nFound {len(apexes)} feature(s) for charge {charge}+ (precursor m/z {precursor_mz:.4f}):")

    for idx, (target_rt, target_mobility, intensity) in enumerate(apexes, start=1):
        total_detected_features += 1
        print(f"  Feature #{idx}: RT = {target_rt:.2f} s ({target_rt/60:.2f} min), Mobility = {target_mobility:.4f}, Intensity = {intensity:.0f}")
        
        rt_tolerance = 70.0
        mobility_tolerance = 0.1

        rt_slice = slice(target_rt - rt_tolerance, target_rt + rt_tolerance)
        im_slice = slice(target_mobility - mobility_tolerance, target_mobility + mobility_tolerance)

        precursor_indices = dia_data[rt_slice, im_slice, 0, prec_mz_slice, "raw"]
        prec_df = dia_data.as_dataframe(precursor_indices)
        prec_df['Annotation'] = 'prec'

        all_dfs = [prec_df]
        for fragment_name, mz in fragment_mzs.items():
            fragment_mz_slice = slice(mz / (1 + ppm / 10**6), mz * (1 + ppm / 10**6))
            fragment_indices = dia_data[rt_slice, im_slice, prec_mz_slice, fragment_mz_slice, "raw"]
            frag_df = dia_data.as_dataframe(fragment_indices)
            frag_df['Annotation'] = fragment_name
            all_dfs.append(frag_df)

        dia_df = pd.concat(all_dfs, axis=0).copy()
        dia_df['ms_level'] = dia_df['Annotation'].apply(lambda x: 1 if x == 'prec' else 2)

        file_prefix = f"{sequence}_z{charge}_peak{idx}"

        # Chromatogram
        ax_xic = dia_df.plot(
            x='rt_values', y='intensity_values', kind='chromatogram',
            by='Annotation', aggregate_duplicates=True,
            title=f"Chromatogram: {sequence} ({charge}+, Peak {idx})", show_plot=False
        )
        ax_xic.figure.savefig(f"{file_prefix}_chromatogram.png", dpi=300, bbox_inches='tight')
        plt.close(ax_xic.figure)

        # Mobilogram
        ax_mob = dia_df.plot(
            x='mobility_values', y='intensity_values', kind='mobilogram',
            by='Annotation', title=f"Mobilogram: {sequence} ({charge}+, Peak {idx})",
            aggregate_duplicates=True, grid=False, show_plot=False
        )
        ax_mob.figure.savefig(f"{file_prefix}_mobilogram.png", dpi=300, bbox_inches='tight')
        plt.close(ax_mob.figure)

        # Spectrum
        ax_spec = dia_df.plot(
            x="mz_values", y="intensity_values", kind="spectrum",
            by="Annotation", title=f"Spectrum: {sequence} ({charge}+, Peak {idx})",
            aggregate_duplicates=True, annotate_top_n_peaks=0, grid=False,
            legend_config=dict(title='Trace', bbox_to_anchor=(1.2, 0.5)), show_plot=False
        )
        ax_spec.figure.savefig(f"{file_prefix}_spectrum.png", dpi=300, bbox_inches='tight')
        plt.close(ax_spec.figure)

        # 2D Peak Map
        dia_df_prec = dia_df[dia_df['Annotation'] == 'prec'].copy()
        ax_map = dia_df_prec.plot(
            x="rt_values", y="mobility_values", z="intensity_values", kind="peakmap",
            xlabel="Retention Time [sec]", ylabel="Ion Mobility", add_marginals=True,
            aggregate_duplicates=True, x_kind='chromatogram', y_kind='chromatogram', grid=False, show_plot=False
        )
        ax_map.figure.savefig(f"{file_prefix}_peakmap.png", dpi=300, bbox_inches='tight')
        plt.close(ax_map.figure)

        del dia_df_prec, dia_df, prec_df, all_dfs

print(f"\nProcessing complete. Generated plots for {total_detected_features} detected feature(s).")

# Cleanup references
del dia_data
gc.collect()

for attr_name in dir(alphatims.tempmmap):
    attr_val = getattr(alphatims.tempmmap, attr_name)
    if isinstance(attr_val, tempfile.TemporaryDirectory) and hasattr(attr_val, '_finalizer'):
        attr_val._finalizer.detach()
