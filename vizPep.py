#C:\Python314\python.exe -m pip install requests matplotlib pandas alphatims pyopenms pyopenms_viz
#C:\Python314\python.exe vizPep.py YNDTFWK -d 20201207_tims03_Evo03_PS_SA_HeLa_200ng_EvoSep_prot_high_speed_21min_8cm_S1-C8_1_22474.d -c 2 --rt 540 --im 0.8 --rt-tol 80.0 --im-tol 0.1
#check example from https://pyopenms-viz.readthedocs.io/en/latest/Getting%20Started.html#Case-Example:-Inspecting-a-Peptide-in-DIA details in https://pubs.acs.org/jprobs/article/24/4/2152/3774490/pyOpenMS-viz-Streamlining-Mass-Spectrometry-Data
import os
import sys
import gc
import atexit
import tempfile
import argparse
import zipfile
import warnings

# Suppress internal warnings
#warnings.filterwarnings('ignore')
#os.environ['PYTHONWARNINGS'] = 'ignore'

import pandas as pd
import matplotlib.pyplot as plt
import pyopenms as oms
import alphatims.bruker
import alphatims.tempmmap
import pyopenms_viz

def detach_alphatims_finalizers():
    """Unregister exit hooks and detach weakref finalizers on alphatims temporary directories."""
    if hasattr(alphatims.tempmmap, 'atexit_clear'):
        atexit.unregister(alphatims.tempmmap.atexit_clear)
    for attr_name in dir(alphatims.tempmmap):
        attr_val = getattr(alphatims.tempmmap, attr_name)
        if isinstance(attr_val, tempfile.TemporaryDirectory) and hasattr(attr_val, '_finalizer'):
            attr_val._finalizer.detach()

# Initial detachment call
detach_alphatims_finalizers()

# Parse command line arguments
parser = argparse.ArgumentParser(description="Visualize LC-TIMS-TOF precursor and fragment traces for a peptide.")
parser.add_argument("sequence", type=str, help="Peptide sequence (e.g., YNDTFWK)")
parser.add_argument("-d", "--data", type=str, required=True, help="Path to raw Bruker .d folder or .zip archive.")
parser.add_argument("-c", "--charge", type=int, default=None, help="Precursor charge state (e.g., 2). Scans z=2 and z=3 if omitted.")
parser.add_argument("--rt", type=float, default=None, help="Explicit Retention Time in seconds (e.g., 696.07).")
parser.add_argument("--im", type=float, default=None, help="Explicit Ion Mobility 1/K0 (e.g., 0.7647).")
parser.add_argument("--rt-tol", type=float, default=70.0, help="RT tolerance window +/- in seconds (default: 70.0).")
parser.add_argument("--im-tol", type=float, default=0.1, help="Mobility tolerance window +/- (default: 0.1).")
parser.add_argument("--ppm", type=float, default=50.0, help="Mass tolerance in ppm (default: 50.0).")

args = parser.parse_args()

sequence = args.sequence.upper()
charges_to_scan = [args.charge] if args.charge is not None else [2, 3]
ppm = args.ppm
rt_tolerance = args.rt_tol
mobility_tolerance = args.im_tol

# 1. Handle raw data input (.d directory or .zip archive)
raw_input = args.data

if not os.path.exists(raw_input):
    sys.exit(f"Error: Specified raw data path '{raw_input}' does not exist.")

if raw_input.lower().endswith('.zip'):
    extracted_folder = os.path.splitext(raw_input)[0]
    if not os.path.exists(extracted_folder):
        print(f"Extracting {raw_input}...")
        with zipfile.ZipFile(raw_input, 'r') as zip_ref:
            zip_ref.extractall(os.path.dirname(raw_input) or '.')
    extracted_folder_path = extracted_folder
else:
    extracted_folder_path = raw_input

dia_data = None

try:
    # 2. Load dataset
    dia_data = alphatims.bruker.TimsTOF(extracted_folder_path)
    detach_alphatims_finalizers()
    
    seq = oms.AASequence.fromString(sequence)

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

    # 3. Process charge states and target RT/IM coordinates
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

        # Determine apex coordinates: manual override or auto-detection
        if args.rt is not None and args.im is not None:
            apexes = [(args.rt, args.im, 0.0)]
            print(f"\nUsing user-supplied parameters for {sequence} ({charge}+): RT = {args.rt:.2f} s, IM = {args.im:.4f}")
        else:
            try:
                indices = dia_data[:, :, 0, prec_mz_slice, "raw"]
                df_peak = dia_data.as_dataframe(indices)
            except Exception:
                df_peak = pd.DataFrame()

            apexes = find_2d_apexes(df_peak)
            if not apexes:
                print(f"No signal detected for sequence {sequence} with charge {charge}+")
                continue
            print(f"\nFound {len(apexes)} auto-detected feature(s) for charge {charge}+ (precursor m/z {precursor_mz:.4f}):")

        for idx, (target_rt, target_mobility, intensity) in enumerate(apexes, start=1):
            total_detected_features += 1
            if intensity > 0:
                print(f"  Feature #{idx}: RT = {target_rt:.2f} s ({target_rt/60:.2f} min), Mobility = {target_mobility:.4f}, Intensity = {intensity:.0f}")
            
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

    print(f"\nProcessing complete. Generated plots for {total_detected_features} feature(s).")

finally:
    # Always execute cleanup regardless of success or failure
    if dia_data is not None:
        del dia_data
    gc.collect()
    detach_alphatims_finalizers()
