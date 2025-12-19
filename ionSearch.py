# single-file script: load pandas and lightweight XML/num libs
import pandas as pd
import xml.etree.ElementTree as ET
import numpy as np
import os
#Load and filter data
chargeThreshold = 2
intensityThreshold = 1e6
mzData = pd.read_csv("L:/promec/HF/Lars/2025/251204_Maren_Gemma/combined/txt/matchedFeatures.txt", sep='\t')
mzSelect = mzData[(mzData['Charge'] < chargeThreshold) & (mzData['Intensity 1kda_A3_ms1']  > intensityThreshold) & (mzData['Intensity 1kda_A7_ms1']  > intensityThreshold) & (mzData['Intensity 3kda_A3_ms1']  > intensityThreshold) & (mzData['Intensity 3kda_A9_ms1']  > intensityThreshold)].copy()
mzSelect['MassCalc'] = mzSelect['m/z'] * mzSelect['Charge'] - mzSelect['Charge'] * 1.007276
#mzSelect.describe()
#(mzSelect['MassCalc']-mzSelect['Mass']).hist()
# metabolites DB (example path):
# https://www.hmdb.ca/system/downloads/current/hmdb_metabolites.zip
# example local XML: r"Z:\Download\hmdb_metabolites\hmdb_metabolites.xml"
# --- inline HMDB search: stream the XML and match MassCalc values within tolerance
# Example usage: set path and run search (adjust as required for your system)
hmdb_xml = r"Z:\Download\serum_metabolites\serum_metabolites.xml"
out_matches = "hmdb_matches.tsv"
# tolerance: use tol_ppm=None to use absolute Da tolerance
tol_da = 0.005
tol_ppm = None
q = pd.to_numeric(mzSelect['MassCalc'], errors='coerce').to_numpy(dtype=float)
valid_idx = ~np.isnan(q)
q_valid = q[valid_idx]
orig_rows = np.nonzero(valid_idx)[0]
mass_tags = ['monisotopic_molecular_weight', 'average_molecular_weight', 'exact_mass', 'molecular_weight']
matches = []
it = ET.iterparse(hmdb_xml, events=('end',))

def _local_name(tag):
    return tag.rsplit('}', 1)[-1] if '}' in tag else tag

for event, elem in it:
    if _local_name(elem.tag) == 'metabolite':
        accession = ''
        name = ''
        formula = ''
        db_masses = []

        # scan this metabolite and all descendants for relevant tags (robust to namespaces)
        for e in elem.iter():
            ln = _local_name(e.tag)
            txt = e.text.strip() if (e.text and isinstance(e.text, str)) else None
            if ln == 'accession' and accession == '':
                accession = txt or ''
            elif ln == 'name' and name == '':
                name = txt or ''
            elif ln in ('chemical_formula', 'formula') and formula == '':
                formula = txt or ''
            elif ln in mass_tags and txt:
                try:
                    db_masses.append(float(txt))
                except Exception:
                    pass

        if db_masses:
            for db_mass in db_masses:
                if tol_ppm is None:
                    diffs = np.abs(q_valid - db_mass)
                    hits = np.where(diffs <= tol_da)[0]
                else:
                    diffs_ppm = np.abs(q_valid - db_mass) / db_mass * 1e6
                    hits = np.where(diffs_ppm <= tol_ppm)[0]
                for hit in hits:
                    orig_row = int(orig_rows[int(hit)])
                    input_mass = float(q_valid[int(hit)])
                    diff = input_mass - db_mass
                    diff_abs = abs(diff)
                    diff_ppm = (abs(diff) / db_mass * 1e6) if db_mass != 0 else None
                    matches.append({
                        'input_row': orig_row + 1,
                        'input_mass': input_mass,
                        'db_accession': accession,
                        'db_name': name,
                        'db_formula': formula,
                        'db_mass': float(db_mass),
                        'diff': diff,
                        'diff_abs': diff_abs,
                        'diff_ppm': diff_ppm
                    })
        elem.clear()
if matches:
    out_df = pd.DataFrame(matches)
    out_df.to_csv(out_matches, sep='\t', index=False)
    print(f"Wrote {len(out_df)} HMDB matches to {out_matches}")
else:
    print("No HMDB matches found within tolerance")
