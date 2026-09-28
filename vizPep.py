#C:\Python314\python.exe -m pip install requests matplotlib pandas alphatims pyopenms_viz
#C:\Python314\python.exe vizPep.py
#check example from https://pyopenms-viz.readthedocs.io/en/latest/Getting%20Started.html#Case-Example:-Inspecting-a-Peptide-in-DIA details in https://pubs.acs.org/jprobs/article/24/4/2152/3774490/pyOpenMS-viz-Streamlining-Mass-Spectrometry-Data
import os
import sys
import gc
import warnings

# Mute downstream pandas Copy-on-Write and UserWarnings
warnings.filterwarnings('ignore')
os.environ['PYTHONWARNINGS'] = 'ignore'

import requests
import zipfile
import pandas as pd
import matplotlib.pyplot as plt
import alphatims.bruker
import pyopenms_viz

# 1. Download and extract sample timsTOF dataset
url = 'https://github.com/MannLabs/alphatims/releases/download/0.1.210317/20201207_tims03_Evo03_PS_SA_HeLa_200ng_EvoSep_prot_high_speed_21min_8cm_S1-C8_1_22474.d.zip'
file_name = '20201207_tims03_Evo03_PS_SA_HeLa_200ng_EvoSep_prot_high_speed_21min_8cm_S1-C8_1_22474.d.zip'
extract_dir = './'
extracted_folder = './20201207_tims03_Evo03_PS_SA_HeLa_200ng_EvoSep_prot_high_speed_21min_8cm_S1-C8_1_22474.d'

if not os.path.exists(extracted_folder):
    print("Downloading sample dataset...")
    response = requests.get(url)
    with open(file_name, 'wb') as file:
        file.write(response.content)
    print("Extracting dataset...")
    with zipfile.ZipFile(file_name, 'r') as zip_ref:
        zip_ref.extractall(extract_dir)
    os.remove(file_name)

# 2. Load the DIA data via alphatims
dia_data = alphatims.bruker.TimsTOF(extracted_folder)

# 3. Function to extract target precursor and fragment coordinates
def inspect_peptide(dia_data, peptide, ppm=50, rt_tolerance=30, mobility_tolerance=0.05):
    precursor_mz = peptide["mz"]
    precursor_mobility = peptide["mobility"]
    precursor_rt = peptide["rt"]
    fragment_mzs = peptide["fragment_mzs"]
    
    rt_slice = slice(precursor_rt - rt_tolerance, precursor_rt + rt_tolerance)
    im_slice = slice(precursor_mobility - mobility_tolerance, precursor_mobility + mobility_tolerance)
    precursor_mz_slice = slice(precursor_mz / (1 + ppm / 10**6), precursor_mz * (1 + ppm / 10**6))
    
    precursor_indices = dia_data[rt_slice, im_slice, 0, precursor_mz_slice, "raw"]
    prec_df = dia_data.as_dataframe(precursor_indices)
    prec_df['Annotation'] = 'prec'
    
    all_dfs = [prec_df]
    for fragment_name, mz in fragment_mzs.items():
        fragment_mz_slice = slice(mz / (1 + ppm / 10**6), mz * (1 + ppm / 10**6))
        fragment_indices = dia_data[rt_slice, im_slice, precursor_mz_slice, fragment_mz_slice, "raw"]
        frag_df = dia_data.as_dataframe(fragment_indices)
        frag_df['Annotation'] = fragment_name
        all_dfs.append(frag_df)
        
    all_df = pd.concat(all_dfs, axis=0)
    all_df['ms_level'] = all_df['Annotation'].apply(lambda x: 1 if x == 'prec' else 2)
    return all_df

# 4. Target peptide definition and extraction
peptide = {
    "sequence": "YNDTFWK",
    "mz": 487.22439,
    "mobility": 0.81,
    "rt": 9.011 * 60,
    "charge": 2,
    "fragment_mzs": {
        "y7": 973.44145, "y6": 810.37812, "y5": 696.33520, "y4": 581.30825,
        "y3": 480.26057, "y2": 333.19216, "y1": 147.11285, "b1": 164.07065,
        "b2": 278.11358, "b3": 393.14052, "b4": 494.18820, "b5": 641.25661,
        "b6": 827.33592, "b7": 955.43089
    }
}

dia_df = inspect_peptide(dia_data, peptide, ppm=50, rt_tolerance=70, mobility_tolerance=0.1)

# 5. Visualization via pyopenms_viz and saving to disk
pd.options.plotting.backend = 'ms_matplotlib'

# Chromatogram
ax_xic = dia_df.plot(
    x='rt_values', 
    y='intensity_values', 
    kind='chromatogram',
    by='Annotation', 
    aggregate_duplicates=True, 
    title="Extracted Chromatogram for YNDTFWK_2",
    show_plot=False
)
ax_xic.figure.savefig("chromatogram.png", dpi=300, bbox_inches='tight')
plt.close(ax_xic.figure)

# Mobilogram
ax_mob = dia_df.plot(
    x='mobility_values', 
    y='intensity_values', 
    kind='mobilogram',
    by='Annotation', 
    title="Extracted Mobilogram for YNDTFWK_2",
    aggregate_duplicates=True, 
    grid=False,
    show_plot=False
)
ax_mob.figure.savefig("mobilogram.png", dpi=300, bbox_inches='tight')
plt.close(ax_mob.figure)

# Spectrum 
ax_spec = dia_df.plot(
    x="mz_values", 
    y="intensity_values", 
    kind="spectrum",
    by="Annotation", 
    title="Extracted Spectrum for YNDTFWK_2",
    aggregate_duplicates=True, 
    annotate_top_n_peaks=0, 
    grid=False, 
    legend_config=dict(title='Trace', bbox_to_anchor=(1.2, 0.5)),
    show_plot=False
)
ax_spec.figure.savefig("spectrum.png", dpi=300, bbox_inches='tight')
plt.close(ax_spec.figure)

# 2D Peak Map
dia_df_prec = dia_df[dia_df['Annotation'] == 'prec']
ax_map = dia_df_prec.plot(
    x="rt_values", 
    y="mobility_values", 
    z="intensity_values", 
    kind="peakmap",
    xlabel="Retention Time [sec]", 
    ylabel="Ion Mobility", 
    add_marginals=True,
    aggregate_duplicates=True,
    x_kind='chromatogram', 
    y_kind='chromatogram', 
    grid=False,
    show_plot=False
)
ax_map.figure.savefig("peakmap.png", dpi=300, bbox_inches='tight')
plt.close(ax_map.figure)

print("Successfully saved plots to current working directory:")
print("  - chromatogram.png")
print("  - mobilogram.png")
print("  - spectrum.png")
print("  - peakmap.png")

# Release memory-mapped handles for Windows file safety
del dia_data
del dia_df
del dia_df_prec
gc.collect()
