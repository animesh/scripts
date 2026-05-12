#python genPRM.py --msms "L:/promec/TIMSTOF/LARS/2026/260507_sonali/combined/txt/msms.txt"  --scans  "L:/promec/TIMSTOF/LARS/2026/260507_sonali/combined/txt/accumulatedMsmsScans.txt"  --out prm_transitions.tsv --pep 0.01 --top_n 5 --min_score 40
import argparse, re
from itertools import zip_longest
import numpy as np
import pandas as pd

PROTON = 1.007276

AA_MONO = {
    'A': 71.03711, 'R': 156.10111, 'N': 114.04293, 'D': 115.02694,
    'C': 103.00919, 'E': 129.04259, 'Q': 128.05858, 'G':  57.02146,
    'H': 137.05891, 'I': 113.08406, 'L': 113.08406, 'K': 128.09496,
    'M': 131.04049, 'F': 147.06841, 'P':  97.05276, 'S':  87.03203,
    'T': 101.04768, 'W': 186.07931, 'Y': 163.06333, 'V':  99.06841,
}

MOD_MASS = {
    'Oxidation (M)': 15.99491, 'Carbamidomethyl (C)': 57.02146,
    'Phospho (ST)': 79.96633,  'Phospho (STY)': 79.96633,
    'Acetyl (Protein N-term)': 42.01057,
}

SILAC_HEAVY = {'R': 10.008269, 'K': 8.014199}  # Arg10 (13C6,15N4), Lys8 (13C6,15N2)


def parse_modified_sequence(modseq, is_heavy=False):
    seq, residues, pending, i = modseq.strip('_'), [], 0.0, 0
    while i < len(seq):
        if seq[i] == '(':
            j = seq.index(')', i)
            mod_str = seq[i+1:j]
            extra = next((v for k, v in MOD_MASS.items() if mod_str.lower() in k.lower()), 0.0)
            if residues:
                aa, m = residues[-1]; residues[-1] = (aa, m + extra)
            else:
                pending += extra
            i = j + 1
        else:
            aa = seq[i]
            silac = SILAC_HEAVY.get(aa, 0.0) if is_heavy else 0.0
            residues.append((aa, AA_MONO.get(aa, 0.0) + pending + silac))
            pending = 0.0
            i += 1
    return residues


def fragment_mz(residues, ion_type, position, charge=1, nl=0.0):
    mass = (sum(m for _, m in residues[:position]) if ion_type == 'b'
            else sum(m for _, m in residues[-position:]) + 18.01056)
    return (mass + nl + charge * PROTON) / charge


NL_MASS = {'-H2O': -18.010565, '-NH3': -17.026549, '+H2O': 18.010565}

ION_RE = re.compile(r'^([by])(\d+)(?:\((\d+)\+\))?$')

def parse_ion_label(label):
    label = label.strip()
    nl = 0.0
    for tag, delta in NL_MASS.items():
        if label.endswith(tag):
            nl = delta; label = label[:-len(tag)]; break
    m = ION_RE.match(label)
    if not m: return None, None, None, 0.0
    return m.group(1), int(m.group(2)), int(m.group(3)) if m.group(3) else 1, nl

def main(msms_path, scans_path, out_path, pep_thresh, top_n, min_score):
    msms = pd.read_csv(msms_path, sep='\t', low_memory=False)
    msms['msms_line'] = np.arange(2, len(msms) + 2)
    scans = pd.read_csv(scans_path, sep='\t', low_memory=False)
    scans['scan_line'] = np.arange(2, len(scans) + 2)
    print(f"msms: {len(msms):,} rows  |  scans: {len(scans):,} rows")

    rt_msms_col  = next((c for c in ['Retention time', 'Retention time [min]', 'Retention time (min)'] if c in msms.columns), None)
    rt_scans_col = next((c for c in ['Precursor retention time', 'Retention time', 'Retention time [min]'] if c in scans.columns), None)
    print(f"RT columns → msms: {rt_msms_col}  |  scans: {rt_scans_col}")

    msms = msms[msms['Reverse'].isna()     | (msms['Reverse']     != '+')]
    msms = msms[msms['Contaminant'].isna() | (msms['Contaminant'] != '+')]
    msms = msms[(msms['PEP'] <= pep_thresh) & (msms['Score'] >= min_score)]
    msms = msms[msms['Sequence'].notna() & (msms['Sequence'] != '')]
    print(f"After filtering: {len(msms):,} PSMs")

    scan_cols = ['Raw file', 'Scan number', 'Precursor ion mobility', 'Precursor ion mobility width', 'scan_line']
    if rt_scans_col: scan_cols.insert(-1, rt_scans_col)
    scans_im = scans[scan_cols].copy()
    scans_im.columns = ['Raw file', 'Scan number', 'Ion mobility (1/K0)', 'IM width'] + \
                       (['RT from scans'] if rt_scans_col else []) + ['scan_line']
    if 'RT from scans' not in scans_im.columns:
        scans_im['RT from scans'] = np.nan

    msms = msms.merge(scans_im, on=['Raw file', 'Scan number'], how='left')
    print(f"Ion mobility matched: {msms['Ion mobility (1/K0)'].notna().sum():,} / {len(msms):,}")

    msms['_key'] = msms['Modified sequence'].astype(str) + '|' + msms['Charge'].astype(str) + '|' + msms['Labeling state'].astype(str)
    best = msms.sort_values('Score', ascending=False).drop_duplicates('_key')
    print(f"Unique precursors: {len(best):,}")

    rows = []
    for _, psm in best.iterrows():
        seq, modseq = str(psm['Sequence']), str(psm['Modified sequence'])
        charge = int(psm['Charge'])
        mz     = float(psm['m/z'])
        label  = int(psm['Labeling state']) if not pd.isna(psm['Labeling state']) else 0
        score, pep_val = float(psm['Score']), float(psm['PEP'])
        im       = float(psm.get('Ion mobility (1/K0)', np.nan))
        im_width = float(psm.get('IM width', np.nan))
        scan_num = int(psm['Scan number']) if not pd.isna(psm.get('Scan number', np.nan)) else ''

        rt_val = psm.get(rt_msms_col, np.nan) if rt_msms_col else np.nan
        if pd.isna(rt_val): rt_val = psm.get('RT from scans', np.nan)
        try:    rt = float(rt_val)
        except: rt = np.nan

        matches_raw = str(psm.get('Matches', ''))
        intens_raw  = str(psm.get('Intensities', ''))
        notes = []

        labels_list = [x.strip() for x in matches_raw.split(';') if x.strip()] if matches_raw not in ('', 'nan') else []
        if not labels_list: notes.append('Missing Matches')

        intens_list = []
        if intens_raw in ('', 'nan'):
            if labels_list: notes.append('Missing Intensities')
        else:
            for t in intens_raw.split(';'):
                try:    intens_list.append(float(t.strip()))
                except: pass
        if labels_list and not intens_list:
            notes.append('No valid intensities'); intens_list = [np.nan] * len(labels_list)
        if len(labels_list) != len(intens_list):
            notes.append('Matches/Intensities length mismatch')

        ion_pairs = sorted(
            zip_longest(intens_list, labels_list, fillvalue=np.nan),
            key=lambda x: (np.nan_to_num(x[0], nan=-1), x[1] if isinstance(x[1], str) else ''),
            reverse=True
        )
        top_ions = [(lbl, inten) for inten, lbl in ion_pairs
                    if isinstance(lbl, str) and lbl and lbl[0] in ('y', 'b')][:top_n]
        if len(labels_list) > len(top_ions):
            notes.append(f'{len(top_ions)} y/b kept from {len(labels_list)} labels')

        sel = (f"score {score:.1f} PEP {pep_val:.2e} charge {charge} "
               f"label {'heavy' if label else 'light'} modseq {modseq} "
               f"msms_line {int(psm['msms_line'])} scan {scan_num}")

        residues = parse_modified_sequence(modseq, is_heavy=(label == 1))

        for ion_label, ion_intensity in top_ions:
            itype, pos, fcharge, nl = parse_ion_label(ion_label)
            calc_mz = round(fragment_mz(residues, itype, pos, fcharge, nl), 5) if itype else ''
            rows.append({
                'Protein':           str(psm['Proteins']),
                'Peptide':           seq,
                'Modified sequence': modseq,
                'Label':             'heavy' if label else 'light',
                'Precursor charge':  charge,
                'Precursor m/z':     round(mz, 5),
                'RT (min)':          round(rt, 3) if not np.isnan(rt) else '',
                'Ion mobility (1/K0)': round(im, 4) if not np.isnan(im) else '',
                'IM width':          round(im_width, 4) if not np.isnan(im_width) else '',
                'Fragment ion':      ion_label,
                'Fragment m/z':      calc_mz,
                'Fragment intensity': round(ion_intensity, 1) if not np.isnan(ion_intensity) else '',
                'Score':             score,
                'PEP':               f'{pep_val:.2e}',
                'msms_line':         int(psm['msms_line']),
                'scan_line':         int(psm['scan_line']) if not pd.isna(psm.get('scan_line', np.nan)) else '',
                'Selection note':    sel,
                'Transition note':   '; '.join(notes),
            })

    if not rows:
        print("WARNING: No transitions generated — check thresholds."); return

    out = pd.DataFrame(rows)
    out['_lo'] = out['Label'].map({'light': 0, 'heavy': 1})
    out = out.sort_values(['Protein', 'Peptide', '_lo', 'Precursor charge', 'Fragment ion']).drop(columns='_lo')
    out.to_csv(out_path, sep='\t', index=False)

    print(f"\nWritten: {out_path}")
    print(f"  Transitions:       {len(out):,}")
    print(f"  Unique precursors: {out[['Peptide','Precursor charge','Label']].drop_duplicates().shape[0]}")
    print(f"  Unique peptides:   {out['Peptide'].nunique()}")
    print(f"  With IM:           {(out['Ion mobility (1/K0)'] != '').sum():,}")
    missing_rt = (out['RT (min)'] == '').sum()
    if missing_rt: print(f"  Missing RT:        {missing_rt:,}")
    noted = (out['Transition note'] != '').sum()
    if noted: print(f"  Transition notes:  {noted:,}")


if __name__ == '__main__':
    ap = argparse.ArgumentParser()
    ap.add_argument('--msms',      required=True)
    ap.add_argument('--scans',     required=True)
    ap.add_argument('--out',       default='prm_transitions.tsv')
    ap.add_argument('--pep',       type=float, default=0.01)
    ap.add_argument('--top_n',     type=int,   default=5)
    ap.add_argument('--min_score', type=float, default=40.0)
    args = ap.parse_args()
    main(args.msms, args.scans, args.out, args.pep, args.top_n, args.min_score)