"""
python genPRM.py --msms "L:/promec/TIMSTOF/LARS/2026/260507_sonali/combined/txt/msms.txt" --scans "L:/promec/TIMSTOF/LARS/2026/260507_sonali/combined/txt/accumulatedMsmsScans.txt" --out prm_transitions.tsv --pep 0.01 --top_n 5 --min_score 40

Generate a TIMS-PASEF PRM transition list from MaxQuant 2.x TimsTOF results. Joins msms.txt (peptide IDs + fragment ions) with accumulatedMsmsScans.txt (ion mobility) and outputs a tab-separated transition list ready for: -- Skyline transition list import (once the mqpar bug is fixed) -- Bruker otofControl / timsTOF PRM method directly

Usage:
    python genPRM.py \
        --msms combined/txt/msms.txt \
        --scans combined/txt/accumulatedMsmsScans.txt \
        --out prm_transitions.tsv \
        [--pep 0.01]    # PEP threshold (default 0.01)
        [--top_n 5]      # top N fragment ions per precursor (default 5)
        [--min_score 40] # minimum Andromeda score (default 40)
"""

import argparse
import re
from itertools import zip_longest
import pandas as pd
import numpy as np


# --------------------------------------------------------------------------
# Fragment ion m/z calculator (y and b ions, handles charge suffix like y6(2+))
# --------------------------------------------------------------------------
PROTON = 1.007276

AA_MONO = {
    'A': 71.03711, 'R': 156.10111, 'N': 114.04293, 'D': 115.02694,
    'C': 103.00919, 'E': 129.04259, 'Q': 128.05858, 'G': 57.02146,
    'H': 137.05891, 'I': 113.08406, 'L': 113.08406, 'K': 128.09496,
    'M': 131.04049, 'F': 147.06841, 'P': 97.05276,  'S': 87.03203,
    'T': 101.04768, 'W': 186.07931, 'Y': 163.06333, 'V': 99.06841,
}

MOD_MASS = {
    'Oxidation (M)':          15.99491,
    'Carbamidomethyl (C)':    57.02146,
    'Phospho (ST)':           79.96633,
    'Phospho (STY)':          79.96633,
    'Acetyl (Protein N-term)': 42.01057,
}

SILAC_HEAVY = {
    'Arg10': 10.00827,   # R -> heavy R
    'Lys8':   8.01420,   # K -> heavy K
}


def parse_modified_sequence(modseq: str):
    """
    Parse MaxQuant modified sequence string like _(ac)PEPTM(ox)K_.
    Returns list of (aa, extra_mass) tuples.
    """
    seq = modseq.strip('_')
    residues = []
    pending_extra = 0.0
    i = 0
    while i < len(seq):
        if seq[i] == '(':
            j = seq.index(')', i)
            mod_str = seq[i+1:j]
            extra = 0.0
            for k, v in MOD_MASS.items():
                if mod_str.lower() in k.lower():
                    extra = v
                    break
            if residues:
                aa, mass = residues[-1]
                residues[-1] = (aa, mass + extra)
            else:
                pending_extra += extra
            i = j + 1
        else:
            aa = seq[i]
            residues.append((aa, AA_MONO.get(aa, 0.0) + pending_extra))
            pending_extra = 0.0
            i += 1
    return residues


def fragment_mz(residues, ion_type, position, charge=1):
    """
    Calculate m/z of a y or b ion.
    position: number of residues counted from N-term (b) or C-term (y).
    """
    if ion_type == 'b':
        mass = sum(m for _, m in residues[:position]) + PROTON
    else:  # y
        mass = sum(m for _, m in residues[-position:]) + 18.01056 + PROTON
    return (mass + (charge - 1) * PROTON) / charge


ION_LABEL_RE = re.compile(r'^([by])(\d+)(?:\((\d+)\+\))?$')

def parse_ion_label(label: str):
    """
    Parse 'y6(2+)', 'b3', 'y5-H2O', 'y4-NH3' etc.
    Returns (type, position, charge) ignoring neutral losses.
    """
    label = label.strip()
    for nl in ['-H2O', '-NH3', '(ox)', '+H2O']:
        if label.endswith(nl):
            label = label[: -len(nl)]
            break
    match = ION_LABEL_RE.match(label)
    if not match:
        return None, None, None
    ion_type = match.group(1)
    position = int(match.group(2))
    charge = int(match.group(3)) if match.group(3) else 1
    return ion_type, position, charge


# --------------------------------------------------------------------------
# Main
# --------------------------------------------------------------------------
def main(msms_path, scans_path, out_path, pep_thresh, top_n, min_score):

    print(f"Reading {msms_path} ...")
    msms = pd.read_csv(msms_path, sep='\t', low_memory=False)
    msms['msms_line'] = np.arange(2, len(msms) + 2)

    print(f"Reading {scans_path} ...")
    scans = pd.read_csv(scans_path, sep='\t', low_memory=False)
    scans['scan_line'] = np.arange(2, len(scans) + 2)

    print(f"msms rows: {len(msms):,}  |  scans rows: {len(scans):,}")

    rt_msms_cols = ['Retention time', 'Retention time [min]', 'Retention time (min)']
    rt_scans_cols = ['Precursor retention time', 'Retention time', 'Retention time [min]', 'Retention time (min)']
    rt_msms_col = next((c for c in rt_msms_cols if c in msms.columns), None)
    rt_scans_col = next((c for c in rt_scans_cols if c in scans.columns), None)

    if rt_msms_col:
        print(f"Using msms retention time column: {rt_msms_col}")
    else:
        print("No retention time column found in msms.txt; will fall back to scans metadata if available.")
    if rt_scans_col:
        print(f"Using scans retention time column: {rt_scans_col}")
    else:
        print("No retention time column found in scans file; RT output may remain empty.")

    # --- Filter msms -------------------------------------------------------
    msms = msms[msms['Reverse'].isna() | (msms['Reverse'] != '+')]
    msms = msms[msms['Contaminant'].isna() | (msms['Contaminant'] != '+')]
    msms = msms[msms['PEP'] <= pep_thresh]
    msms = msms[msms['Score'] >= min_score]
    msms = msms[msms['Sequence'].notna() & (msms['Sequence'] != '')]
    print(f"After filtering (PEP≤{pep_thresh}, score≥{min_score}): {len(msms):,} PSMs")

    # --- Join with scans for ion mobility ----------------------------------
    scan_cols = ['Raw file', 'Scan number',
                 'Precursor ion mobility',
                 'Precursor ion mobility width',
                 'scan_line']
    if rt_scans_col:
        scan_cols.insert(-1, rt_scans_col)
    scans_im = scans[scan_cols].copy()
    col_names = ['Raw file', 'Scan number',
                 'Ion mobility (1/K0)',
                 'IM width']
    if rt_scans_col:
        col_names.append('RT from scans')
    col_names.append('scan_line')
    scans_im.columns = col_names
    if 'RT from scans' not in scans_im.columns:
        scans_im['RT from scans'] = np.nan

    msms = msms.merge(scans_im, on=['Raw file', 'Scan number'], how='left')
    im_matched = msms['Ion mobility (1/K0)'].notna().sum()
    print(f"Ion mobility matched: {im_matched:,} / {len(msms):,} PSMs")

    # --- Pick best PSM per (Modified sequence, Charge, Labeling state) ----
    msms['_key'] = (msms['Modified sequence'].astype(str) + '|' +
                    msms['Charge'].astype(str) + '|' +
                    msms['Labeling state'].astype(str))
    best = msms.sort_values('Score', ascending=False).drop_duplicates('_key')
    print(f"Unique precursors (seq+charge+label): {len(best):,}")

    # --- Build transition list rows ----------------------------------------
    rows = []
    for _, psm in best.iterrows():
        seq      = str(psm['Sequence'])
        modseq   = str(psm['Modified sequence'])
        protein  = str(psm['Proteins'])
        charge   = int(psm['Charge'])
        mz       = float(psm['m/z'])
        rt_val = np.nan
        if rt_msms_col is not None:
            rt_val = psm.get(rt_msms_col, np.nan)
        if pd.isna(rt_val):
            rt_val = psm.get('RT from scans', np.nan)
        try:
            rt = float(rt_val)
        except (TypeError, ValueError):
            rt = np.nan
        im       = float(psm.get('Ion mobility (1/K0)', np.nan))
        im_width = float(psm.get('IM width', np.nan))
        pep      = float(psm['PEP'])
        score    = float(psm['Score'])
        label    = int(psm['Labeling state']) if not pd.isna(psm['Labeling state']) else 0
        label_str = 'heavy' if label == 1 else 'light'

        # Parse fragment ions from Matches + Intensities columns
        matches_raw = str(psm.get('Matches', ''))
        intens_raw  = str(psm.get('Intensities', ''))
        fragment_notes = []

        if not matches_raw or matches_raw == 'nan':
            fragment_notes.append('Missing Matches column')
            match_labels = []
        else:
            match_labels = [x.strip() for x in matches_raw.split(';') if x.strip()]

        intensities = []
        if not intens_raw or intens_raw == 'nan':
            if match_labels:
                fragment_notes.append('Missing Intensities column')
        else:
            for token in intens_raw.split(';'):
                token = token.strip()
                if not token:
                    continue
                try:
                    intensities.append(float(token))
                except ValueError:
                    continue

        if match_labels and not intensities:
            fragment_notes.append('No valid intensity values; keeping fragment labels only')
            intensities = [np.nan] * len(match_labels)
        if len(match_labels) != len(intensities):
            fragment_notes.append('Matches/Intensities length mismatch')

        ion_pairs = sorted(
            ((inten, lbl) for inten, lbl in zip_longest(intensities, match_labels, fillvalue=np.nan)),
            key=lambda x: (np.nan_to_num(x[0], nan=-1), x[1] if isinstance(x[1], str) else ''),
            reverse=True
        )
        top_ions = [(lbl, inten) for inten, lbl in ion_pairs
                    if isinstance(lbl, str) and lbl and lbl[0] in ('y', 'b')][:top_n]
        if len(match_labels) > len(top_ions):
            fragment_notes.append(f'{len(top_ions)} y/b fragments kept from {len(match_labels)} parsed labels')
        if len(top_ions) == 0 and match_labels:
            fragment_notes.append('No y/b fragment labels present in Matches')

        scan_line = int(psm['scan_line']) if not pd.isna(psm.get('scan_line', np.nan)) else ''
        scan_number = int(psm['Scan number']) if 'Scan number' in psm.index and not pd.isna(psm['Scan number']) else ''
        selection_note = (
            f"best PSM selected by score {score:.1f}, PEP {pep:.2e}, "
            f"charge {charge}, label {label_str}, "
            f"Modified sequence {modseq}, "
            f"msms_line {int(psm['msms_line'])}, "
            f"scan {scan_number}"
        )
        for ion_label, ion_intensity in top_ions:
            rows.append({
                'Protein':              protein,
                'Peptide':              seq,
                'Modified sequence':    modseq,
                'Label':                label_str,
                'Precursor charge':     charge,
                'Precursor m/z':        mz,
                'RT (min)':             rt if not np.isnan(rt) else '',
                'Ion mobility (1/K0)':  im if not np.isnan(im) else '',
                'IM width':             im_width if not np.isnan(im_width) else '',
                'Fragment ion':         ion_label,
                'Fragment intensity':   ion_intensity,
                'Score':                score,
                'PEP':                  f'{pep:.2e}',
                'msms_line':            int(psm['msms_line']),
                'scan_line':            scan_line,
                'Selection note':       selection_note,
                'Transition note':      '; '.join(fragment_notes) if fragment_notes else '',
            })

    if not rows:
        print("WARNING: No transitions generated — check filters.")
        return

    out = pd.DataFrame(rows)

    # Sort: protein > peptide > label (light before heavy) > charge > fragment
    out['_label_order'] = out['Label'].map({'light': 0, 'heavy': 1})
    out = out.sort_values(['Protein', 'Peptide', '_label_order',
                           'Precursor charge', 'Fragment ion'])
    out = out.drop(columns='_label_order')

    out.to_csv(out_path, sep='\t', index=False)
    print(f"\nWritten: {out_path}")
    print(f"  Transitions: {len(out):,}")
    print(f"  Unique precursors: {out[['Peptide','Precursor charge','Label']].drop_duplicates().shape[0]}")
    print(f"  Unique peptides:   {out['Peptide'].nunique()}")
    print(f"\nColumn summary:")
    im_ok = (out['Ion mobility (1/K0)'] != '').sum()
    print(f"  Ion mobility populated: {im_ok}/{len(out)} transitions")
    missing_rt = (out['RT (min)'] == '').sum()
    if missing_rt:
        print(f"  RT missing: {missing_rt}/{len(out):,} transitions. This happens when neither msms.txt has a retention time column nor the scans file supplies Precursor retention time, or the scan merge did not match.")
    note_count = (out['Transition note'] != '').sum()
    if note_count:
        print(f"  Transition notes present: {note_count}/{len(out):,} transitions (missing/mismatched Matches/Intensities or only y/b fragments kept).")


if __name__ == '__main__':
    ap = argparse.ArgumentParser(description='MaxQuant TimsTOF → PRM transition list')
    ap.add_argument('--msms',      required=True,  help='Path to msms.txt')
    ap.add_argument('--scans',     required=True,  help='Path to accumulatedMsmsScans.txt')
    ap.add_argument('--out',       default='prm_transitions.tsv')
    ap.add_argument('--pep',       type=float, default=0.01,  help='PEP threshold')
    ap.add_argument('--top_n',     type=int,   default=5,     help='Top N fragment ions')
    ap.add_argument('--min_score', type=float, default=40.0,  help='Min Andromeda score')
    args = ap.parse_args()

    main(
        msms_path  = args.msms,
        scans_path = args.scans,
        out_path   = args.out,
        pep_thresh = args.pep,
        top_n      = args.top_n,
        min_score  = args.min_score,
    )
