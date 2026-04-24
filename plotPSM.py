#python plotPSM.py "L:\promec\HF\Lars\2026\260330_Essa\combined\txt\msms_alsS_LTGKPGVVLVTSGPGASNLATGLLTANTEGDPVVALAGNVIR.txt" --out "alsS_LTGKPGVVLVTSGPGASNLATGLLTANTEGDPVVALAGNVIR.png" #L:\promec\HF\Lars\2026\260330_Essa\combined\txt\msms_alsS_AHPLEIVK.txt --out alsS_AHPLEIVK_test.png
#  Needs Proteins, Sequence, Modified sequence, Raw file, Charge, Fragmentation, Mass analyzer, Masses2/Intensities2 (full spectrum), Masses/Intensities/Matches (annotated ions), Raw precursor m/z = m/z + isotope_index * (1.003355 / charge)  [verified <1.5 mDa error]
import argparse
from pathlib import Path
import sys
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker
import re

PROTON = 1.007276466812
H2O = 18.010564684

AA_MONO = {
    'A': 71.03711, 'R': 156.10111, 'N': 114.04293, 'D': 115.02694,
    'C': 103.00919, 'E': 129.04259, 'Q': 128.05858, 'G': 57.02146,
    'H': 137.05891, 'I': 113.08406, 'L': 113.08406, 'K': 128.09496,
    'M': 131.04049, 'F': 147.06841, 'P': 97.05276, 'S': 87.03203,
    'T': 101.04768, 'W': 186.07931, 'Y': 163.06333, 'V': 99.06841,
}


def find_column(df, patterns):
    for c in df.columns:
        low = c.lower()
        if any(p in low for p in patterns):
            return c
    return None


def sanitize_sequence(seq: str):
    return ''.join(re.findall(r'[A-Z]', str(seq).upper()))


def parse_semicolon_list(s):
    if pd.isna(s):
        return np.array([])
    items = [x for x in str(s).split(';') if x.strip() != '' and x.strip().lower() != 'nan']
    try:
        return np.array([float(x) for x in items])
    except Exception:
        return np.array([])


def read_peak_file(path: Path):
    for sep in ['\t', ',']:
        try:
            df = pd.read_csv(path, sep=sep, low_memory=False)
        except Exception:
            continue

        # Pick best-scored row
        if 'Score' in df.columns:
            selected_row = df.loc[df['Score'].astype(float).idxmax()]
        else:
            selected_row = df.iloc[0]

        full_mz = np.array([])
        full_intensity = np.array([])
        if 'Masses2' in df.columns and 'Intensities2' in df.columns:
            full_mz = parse_semicolon_list(selected_row['Masses2'])
            full_intensity = parse_semicolon_list(selected_row['Intensities2'])
        elif 'Masses' in df.columns and 'Intensities' in df.columns:
            full_mz = parse_semicolon_list(selected_row['Masses'])
            full_intensity = parse_semicolon_list(selected_row['Intensities'])

        ann_mz = np.array([])
        ann_intensity = np.array([])
        ann_labels = []
        if 'Masses' in df.columns and 'Intensities' in df.columns:
            ann_mz = parse_semicolon_list(selected_row['Masses'])
            ann_intensity = parse_semicolon_list(selected_row['Intensities'])
            ann_labels = [x for x in str(selected_row.get('Matches', '')).split(';')
                          if x.strip() != '' and x.strip().lower() != 'nan']
            if len(ann_labels) != len(ann_mz):
                ann_labels = [''] * len(ann_mz)

        if full_mz.size and full_intensity.size:
            return full_mz, full_intensity, ann_mz, ann_intensity, ann_labels, selected_row

        mz_col = find_column(df, ['mz', 'm/z'])
        int_col = find_column(df, ['intensity', 'int'])
        if mz_col and int_col:
            mz = df[mz_col].astype(float).to_numpy()
            intensity = df[int_col].astype(float).to_numpy()
            return mz, intensity, np.array([]), np.array([]), [], selected_row

    try:
        arr = np.loadtxt(path)
        if arr.ndim == 1 and arr.size >= 2:
            arr = arr.reshape(1, -1)
        if arr.shape[1] >= 2:
            return arr[:, 0], arr[:, 1], np.array([]), np.array([]), [], None
    except Exception:
        pass
    raise ValueError(f"Could not parse peak file: {path}")


def plot_spectrum(full_mz, full_intensity, ann_mz, ann_intensity, ann_labels,
                 row: pd.Series, peptide: str, outpath: Path, title=None):
    order_full = np.argsort(full_mz)
    full_mz = full_mz[order_full]
    full_intensity = full_intensity[order_full]

    order_ann = np.argsort(ann_mz)
    ann_mz = ann_mz[order_ann]
    ann_intensity = ann_intensity[order_ann]
    ann_labels = [ann_labels[i] for i in order_ann]

    if full_intensity.size and np.max(full_intensity) > 0:
        intensity_norm = full_intensity / np.max(full_intensity) * 100.0
    else:
        intensity_norm = full_intensity.copy()
    if ann_intensity.size and np.max(full_intensity) > 0:
        ann_norm = ann_intensity / np.max(full_intensity) * 100.0
    else:
        ann_norm = ann_intensity.copy()

    fig, ax = plt.subplots(figsize=(14, 6))
    ax.set_facecolor('white')
    annotated_mask = np.array([np.any(np.isclose(x, ann_mz, atol=1e-4)) for x in full_mz])
    ax.vlines(full_mz[~annotated_mask], 0, intensity_norm[~annotated_mask], color='grey', linewidth=0.8, alpha=0.7)
    ax.scatter(full_mz[~annotated_mask], intensity_norm[~annotated_mask], color='grey', s=8, zorder=2)

    b_ion_color = '#D18F3F'
    y_ion_color = '#3D6B8A'
    annotated_colors = []
    for mz in full_mz[annotated_mask]:
        if ann_mz.size:
            idx = int(np.argmin(np.abs(ann_mz - mz)))
            label = str(ann_labels[idx]).lower()
            if label.startswith('y'):
                annotated_colors.append(y_ion_color)
            elif label.startswith('b'):
                annotated_colors.append(b_ion_color)
            else:
                annotated_colors.append('black')
        else:
            annotated_colors.append('black')

    ax.vlines(full_mz[annotated_mask], 0, intensity_norm[annotated_mask], color=annotated_colors, linewidth=0.8, alpha=0.9)
    ax.scatter(full_mz[annotated_mask], intensity_norm[annotated_mask], color=annotated_colors, s=10, zorder=3)

    ax.set_xlabel('m/z')
    ax.set_ylabel('Relative intensity (%)')
    ax.set_xlim(full_mz.min() - 20, full_mz.max() + 20)
    ax.set_ylim(0, 100)

    max_raw = np.max(full_intensity) if full_intensity.size else 0.0
    ax_right = ax.twinx()
    ax_right.set_ylabel('Raw intensity')
    ax_right.set_ylim(ax.get_ylim())
    ax_right.set_yticks(ax.get_yticks())
    def raw_intensity_formatter(value, pos):
        return f"{(value / 100.0 * max_raw):.0f}"
    ax_right.yaxis.set_major_formatter(ticker.FuncFormatter(raw_intensity_formatter))
    ax_right.tick_params(axis='y', which='major', right=True, labelright=True, left=False, length=6, width=1)
    ax_right.yaxis.set_ticks_position('right')
    ax_right.spines['right'].set_visible(True)
    ax_right.spines['right'].set_linewidth(1.0)
    ax_right.spines['right'].set_color('#333333')
    ax_right.set_zorder(ax.get_zorder() + 1)
    ax_right.patch.set_visible(False)

    ax.grid(axis='y', linestyle=':', color='#cccccc', alpha=0.6)
    ax.tick_params(axis='x', which='both', bottom=True, top=False)
    ax.tick_params(axis='y', which='both', left=True, right=False)

    # Build header — compute raw precursor m/z from msms m/z + isotope index + charge
    header_items = []
    if row is not None:
        if 'Raw file' in row:
            header_items.append(str(row['Raw file']))
        if 'Scan number' in row:
            header_items.append(f"Scan {int(row['Scan number'])}")
        if 'Mass analyzer' in row:
            header_items.append(str(row['Mass analyzer']))
        if 'Fragmentation' in row:
            header_items.append(str(row['Fragmentation']))
        if 'Charge' in row and pd.notna(row['Charge']):
            try:
                charge_val = int(float(row['Charge']))
            except Exception:
                charge_val = row['Charge']
            header_items.append(f"z {charge_val}+")
        header_items.append(f"Score {row.get('Score', '')}")
        # Compute raw precursor m/z: monoisotopic m/z + isotope_offset
        try:
            mz_mono = float(row['m/z'])
            iso_idx = int(row.get('Isotope index', 0))
            z       = int(float(row.get('Charge', 1)))
            raw_mz  = mz_mono + iso_idx * (1.003355 / z)
            header_items.append(f"MS/MS m/z {raw_mz:.6f}")
        except Exception:
            header_items.append(f"m/z {row.get('m/z', '')}")
    header_text = '   '.join(header_items)
    ax.text(0, 1.07, header_text, transform=ax.transAxes, fontsize=10, ha='left', va='bottom')
    if title:
        ax.text(0, 1.13, title, transform=ax.transAxes, fontsize=12, fontweight='bold', ha='left', va='bottom')
    seq_annotation = peptide if peptide else ''
    if row is not None and 'Modified sequence' in row and pd.notna(row['Modified sequence']):
        seq_annotation = str(row['Modified sequence'])
    ax.text(0, 1.01, f"Peptide: {seq_annotation}", transform=ax.transAxes, fontsize=10, ha='left', va='bottom', color='#333333')

    placed_bboxes = []
    x_min, x_max = ax.get_xlim()
    x_margin = (x_max - x_min) * 0.02
    fig.canvas.draw()
    axis_bbox = ax.get_window_extent(renderer=fig.canvas.get_renderer())
    for x, y, label in zip(ann_mz, ann_norm, ann_labels):
        if not label:
            continue
        b_ion_color = '#D18F3F'
        y_ion_color = '#3D6B8A'
        color = y_ion_color if label.lower().startswith('y') else b_ion_color if label.lower().startswith('b') else 'purple'
        if not re.search(r'\(\d\+\)', label):
            label = f"{label}(1+)"
        match = re.match(r'^([by])(\d+)', label.lower())
        segment = ''
        if match and peptide:
            ion = match.group(1)
            idx_num = int(match.group(2))
            if ion == 'b':
                segment = peptide[:idx_num]
            elif ion == 'y':
                segment = peptide[-idx_num:]
        if segment:
            peak_text = f"{label} {segment} {x:.1f}"
        else:
            peak_text = f"{label} {x:.1f}"

        x_data = x
        if x < x_min + x_margin:
            x_data = x_min + x_margin
        elif x > x_max - x_margin:
            x_data = x_max - x_margin

        y_offsets = [4, 8, 12, 16, 20, 24, 28, 32, -6, -14, -22]
        tries = 0
        while True:
            y_offset = y_offsets[min(tries, len(y_offsets)-1)]
            va = 'bottom' if y_offset >= 0 else 'top'
            text = ax.text(
                x_data,
                y + y_offset,
                peak_text,
                ha='center',
                va=va,
                fontsize=7,
                color=color,
                clip_on=True,
                bbox=dict(facecolor='white', alpha=0.75, edgecolor='none', pad=0.5)
            )
            fig.canvas.draw()
            bbox = text.get_window_extent(renderer=fig.canvas.get_renderer())
            inside_axis = (
                bbox.x0 >= axis_bbox.x0 and bbox.x1 <= axis_bbox.x1 and
                bbox.y0 >= axis_bbox.y0 and bbox.y1 <= axis_bbox.y1
            )
            if inside_axis and not any(bbox.overlaps(prev) for prev in placed_bboxes):
                placed_bboxes.append(bbox)
                break
            if tries == 0 and x_data == x and x > x_max - x_margin:
                x_data = x_max - x_margin
            elif tries == 0 and x_data == x and x < x_min + x_margin:
                x_data = x_min + x_margin
            elif tries == 1 and x_data == x:
                x_data = x
            elif tries >= len(y_offsets) - 1:
                placed_bboxes.append(bbox)
                break
            text.remove()
            tries += 1

    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
    ax.spines['bottom'].set_linewidth(1.0)
    ax.spines['left'].set_linewidth(1.0)

    fig.subplots_adjust(right=0.85, top=0.93, left=0.08)
    plt.savefig(outpath, dpi=200, bbox_inches='tight')
    plt.close()


def main():
    parser = argparse.ArgumentParser(description='Plot annotated MS/MS spectrum from msms.txt')
    parser.add_argument('msms', type=Path)
    parser.add_argument('evidence', type=Path, nargs='?', default=None,
                        help='Optional — not used, kept for backwards compatibility')
    parser.add_argument('--out', type=Path, default=None)
    parser.add_argument('--tol', type=float, default=0.5)
    parser.add_argument('--ppm', action='store_true')
    args = parser.parse_args()

    if args.evidence:
        print(f"Note: evidence file ignored — all fields sourced from msms.txt")

    full_mz, full_intensity, ann_mz, ann_intensity, ann_labels, msms_row = read_peak_file(args.msms)

    seq = ''
    proteins = ''
    if msms_row is not None:
        seq = sanitize_sequence(str(msms_row.get('Sequence', '')))
        proteins = str(msms_row.get('Proteins', '')) if pd.notna(msms_row.get('Proteins', '')) else ''

    out = args.out or args.msms.with_suffix('.png')
    title = proteins or seq

    plot_spectrum(full_mz, full_intensity, ann_mz, ann_intensity, ann_labels,
                 msms_row, seq, out, title=title)
    print(f"Saved annotated spectrum to: {out}")


if __name__ == '__main__':
    main()
