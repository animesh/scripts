#!/usr/bin/env python3
"""
Plot an annotated MS/MS spectrum from MaxQuant msms.txt + evidence.txt.

Usage:
    python plot_msms.py <msms.txt> <evidence.txt> [--out output.png]

Data flow (verified against MaxQuant output in session):
  - evidence.txt : pick best row by max Score; use 'Best MS/MS' id to locate scan
  - msms.txt     : find row where id == Best MS/MS
  - Masses2 / Intensities2 : full observed spectrum (all peaks)
  - Masses / Intensities / Matches : observed m/z, intensity, label for matched ions
    (Masses stores observed m/z values, identical to entries in Masses2)
  - MS/MS m/z in evidence : raw selected precursor m/z (includes isotope offset)
"""

import argparse
import re
import sys
from pathlib import Path

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker


# ── Ion colour map ────────────────────────────────────────────────────────────
# Keyed on the first token of the label (before digits / modifiers)
ION_COLORS = {
    'y':  '#2166ac',   # blue
    'b':  '#d6604d',   # red-orange
    'a':  '#f4a582',   # pale orange
    'c':  '#4dac26',   # green  (ETD)
    'z':  '#b8e186',   # light green (ETD)
    'IM': '#7b3294',   # purple  (immonium)
    '_':  '#888888',   # internal fragments (PL, LE, IV …)
}
GREY = '#aaaaaa'


def ion_color(label: str) -> str:
    """Return colour for an ion label string."""
    for prefix, color in ION_COLORS.items():
        if label.startswith(prefix):
            return color
    return ION_COLORS['_']


def format_label(raw_label: str, sequence: str, mz: float) -> str:
    """
    Format ion label as shown in MaxQuant Viewer:
        b2(1+) AH 209.1
        y11(2+) PVVALAGNVIR 1108.7
        y1-NH3(1+) K 130.1
        a2(1+) AH 181.1

    Rules:
    - If charge not already in label (e.g. b2, y1-NH3) append (1+)
    - For b/a ions: sequence fragment = first N residues
    - For y ions:   sequence fragment = last N residues
    - Append observed m/z rounded to 1 decimal
    - Non-b/y/a ions (immonium, internal): just add charge + mz, no fragment
    """
    n = len(sequence)
    has_charge = bool(re.search(r'\(\d+\+\)', raw_label))
    charge_suffix = '' if has_charge else '(1+)'

    # Strip existing charge notation to parse core ion
    base = re.sub(r'\(\d+\+\)', '', raw_label)
    core = re.split(r'[-]', base)[0]          # strip -NH3, -H2O etc
    m = re.match(r'^([aby])(\d+)$', core)
    if not m:
        return f"{raw_label}{charge_suffix} {mz:.1f}"

    ion_type = m.group(1)
    ion_num  = min(int(m.group(2)), n)
    fragment = sequence[:ion_num] if ion_type in ('b', 'a') else sequence[n - ion_num:]
    return f"{raw_label}{charge_suffix} {fragment} {mz:.1f}"


# ── I/O helpers ───────────────────────────────────────────────────────────────

def _parse_semi(s) -> np.ndarray:
    """Parse a semicolon-separated numeric string into a float array."""
    if pd.isna(s) or str(s).strip() == '':
        return np.array([], dtype=float)
    return np.array([float(x) for x in str(s).split(';') if x.strip() != ''], dtype=float)


def load_tsv(path: Path) -> pd.DataFrame:
    return pd.read_csv(path, sep='\t', low_memory=False)


def best_evidence_row(ev_df: pd.DataFrame) -> pd.Series:
    """
    Return the evidence row with the highest Score.
    For multi-charge-state / multi-scan features (e.g. LTGK... with 4 rows)
    the highest Score row is also the Best MS/MS designation — verified in session.
    If Score is absent fall back to lowest PEP.
    """
    if 'Score' in ev_df.columns:
        return ev_df.loc[ev_df['Score'].astype(float).idxmax()]
    if 'PEP' in ev_df.columns:
        return ev_df.loc[ev_df['PEP'].astype(float).idxmin()]
    return ev_df.iloc[0]


def load_evidence(path: Path):
    """
    Returns (ev_row, sequence, precursor_mz, charge, raw_file, scan_number).
    Uses 'Best MS/MS' id to identify which msms scan to render.
    'MS/MS m/z' is the RAW selected precursor m/z (including isotope offset).
    """
    df = load_tsv(path)
    # All rows that have a non-empty Sequence
    seq_col = next((c for c in df.columns if c.lower() == 'sequence'), df.columns[0])
    df = df[df[seq_col].notna() & (df[seq_col].astype(str).str.strip() != '')]

    ev_row   = best_evidence_row(df)
    sequence = str(ev_row[seq_col]).strip().upper()
    charge   = int(float(ev_row['Charge'])) if 'Charge' in ev_row else None
    # MS/MS m/z = raw precursor m/z as selected by the instrument (isotope-aware)
    prec_mz  = float(ev_row['MS/MS m/z']) if 'MS/MS m/z' in ev_row else None
    raw_file = str(ev_row.get('Raw file', ''))
    # Best MS/MS points to msms.txt 'id' column — use this as primary selector
    best_msms_id = int(float(ev_row['Best MS/MS'])) if 'Best MS/MS' in ev_row else None
    return ev_row, sequence, prec_mz, charge, raw_file, best_msms_id


def load_msms(path: Path, best_msms_id: int | None):
    """
    Load the correct msms row.
    Priority: match 'id' == best_msms_id → then 'Scan number' from evidence → else first row.
    Returns the pandas Series for the matched row.
    """
    df = load_tsv(path)

    if best_msms_id is not None and 'id' in df.columns:
        match = df[df['id'].astype(float).fillna(-1).astype(int) == best_msms_id]
        if len(match):
            return match.iloc[0]
        print(f"Warning: id={best_msms_id} not found in msms file; using first row", file=sys.stderr)

    return df.iloc[0]


def extract_spectrum(msms_row: pd.Series):
    """
    Returns:
      full_mz, full_int  — all observed peaks (Masses2/Intensities2)
      ann_mz, ann_int    — matched-ion peaks (Masses/Intensities)
      ann_labels         — ion label strings (Matches)
    """
    full_mz  = _parse_semi(msms_row.get('Masses2'))
    full_int = _parse_semi(msms_row.get('Intensities2'))
    ann_mz   = _parse_semi(msms_row.get('Masses'))
    ann_int  = _parse_semi(msms_row.get('Intensities'))
    ann_labels = [x for x in str(msms_row.get('Matches', '')).split(';')
                  if x.strip() not in ('', 'nan')]

    if len(ann_labels) != len(ann_mz):
        ann_labels = ['?'] * len(ann_mz)

    return full_mz, full_int, ann_mz, ann_int, ann_labels


# ── Plot ──────────────────────────────────────────────────────────────────────

def plot(full_mz, full_int, ann_mz, ann_int, ann_labels,
         sequence, charge, prec_mz, raw_file, scan_number, score,
         fragmentation, mass_analyzer, out: Path):

    # Normalise to 100 %
    max_int = full_int.max() if full_int.size else 1.0
    full_pct = full_int / max_int * 100.0
    ann_pct  = ann_int  / max_int * 100.0

    # Build a set of annotated m/z for fast lookup (Masses are observed, same values as Masses2)
    ann_set = set(ann_mz.tolist())

    fig, ax = plt.subplots(figsize=(13, 5.5))
    ax.set_facecolor('white')

    # ── Grey unannotated peaks ────────────────────────────────────────────────
    for mz, pct in zip(full_mz, full_pct):
        if mz not in ann_set:
            ax.vlines(mz, 0, pct, color=GREY, lw=0.7, alpha=0.6)

    # ── Coloured annotated peaks ──────────────────────────────────────────────
    for mz, pct, label in zip(ann_mz, ann_pct, ann_labels):
        color = ion_color(label)
        ax.vlines(mz, 0, pct, color=color, lw=1.0)

    # ── Ion labels (with peptide fragment + m/z, matching MaxQuant Viewer style) ──
    placed: list[tuple[float, float, float, float]] = []  # (x0,x1,y0,y1) data coords

    label_fontsize = 6.5
    x_range    = full_mz.max() - full_mz.min() if full_mz.size > 1 else 1.0
    char_width = x_range * 0.010
    line_height = 5.0

    def overlaps(x, y, w, h):
        for (bx0, bx1, by0, by1) in placed:
            if x < bx1 and x + w > bx0 and y < by1 and y + h > by0:
                return True
        return False

    for mz, pct, raw_label in sorted(zip(ann_mz, ann_pct, ann_labels), key=lambda t: -t[1]):
        color      = ion_color(raw_label)
        text_str   = format_label(raw_label, sequence, mz)
        w = len(text_str) * char_width
        y = pct + 2.0
        for _ in range(15):
            if not overlaps(mz - w / 2, y, w, line_height):
                break
            y += line_height
        ax.text(mz, y, text_str, ha='center', va='bottom',
                fontsize=label_fontsize, color=color,
                bbox=dict(facecolor='white', alpha=0.0, edgecolor='none', pad=0))
        placed.append((mz - w / 2, mz + w / 2, y, y + line_height))

    # ── Axes ──────────────────────────────────────────────────────────────────
    ax.set_xlabel('m/z', fontsize=10)
    ax.set_ylabel('Relative intensity (%)', fontsize=10)
    ax.set_xlim(full_mz.min() - 20, full_mz.max() + 30)
    ax.set_ylim(0, min(max(full_pct) * 1.45, 130))

    # Right axis in raw counts
    ax2 = ax.twinx()
    ax2.set_ylim(ax.get_ylim())
    ax2.set_yticks(ax.get_yticks())
    ax2.yaxis.set_major_formatter(
        ticker.FuncFormatter(lambda v, _: f'{v / 100 * max_int:.3g}'))
    ax2.set_ylabel('Intensity', fontsize=9)
    ax2.tick_params(labelsize=8)
    ax2.spines['top'].set_visible(False)

    for sp in ('top', 'right'):
        ax.spines[sp].set_visible(False)

    # ── Header (mirroring MaxQuant Viewer layout) ─────────────────────────────
    method = '; '.join(filter(None, [mass_analyzer, fragmentation]))
    charge_str = f"{charge}+" if charge else ''
    mz_str  = f"{prec_mz:.2f}" if prec_mz else ''
    score_str = f"{float(score):.2f}" if score is not None else ''

    header = (f"{raw_file}    Scan {scan_number}    {method}    "
              f"Score {score_str}    m/z {mz_str}    z={charge_str}")
    ax.text(0, 1.08, header, transform=ax.transAxes,
            fontsize=8.5, ha='left', va='bottom', color='#333333')
    ax.text(0, 1.02, sequence, transform=ax.transAxes,
            fontsize=9, ha='left', va='bottom', color='black',
            fontfamily='monospace')

    # ── Legend ────────────────────────────────────────────────────────────────
    from matplotlib.lines import Line2D
    legend_items = [
        Line2D([0], [0], color=ION_COLORS['y'],  lw=1.5, label='y'),
        Line2D([0], [0], color=ION_COLORS['b'],  lw=1.5, label='b'),
        Line2D([0], [0], color=ION_COLORS['a'],  lw=1.5, label='a'),
        Line2D([0], [0], color=ION_COLORS['c'],  lw=1.5, label='c/z'),
        Line2D([0], [0], color=ION_COLORS['IM'], lw=1.5, label='immonium'),
        Line2D([0], [0], color=ION_COLORS['_'],  lw=1.5, label='internal'),
        Line2D([0], [0], color=GREY,             lw=1.0, label='unmatched', alpha=0.7),
    ]
    ax.legend(handles=legend_items, fontsize=7, loc='upper right',
              framealpha=0.8, ncol=1)

    fig.subplots_adjust(top=0.87, right=0.88, left=0.07, bottom=0.10)
    fig.savefig(out, dpi=200, bbox_inches='tight')
    plt.close()
    print(f"Saved: {out}")


# ── Main ──────────────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(description='Plot MaxQuant MS/MS spectrum')
    parser.add_argument('msms',     type=Path, help='msms.txt')
    parser.add_argument('evidence', type=Path, help='evidence.txt')
    parser.add_argument('--out',    type=Path, default=None)
    args = parser.parse_args()

    # 1. Load evidence — get Best MS/MS id and metadata
    ev_row, sequence, prec_mz, charge, raw_file, best_msms_id = load_evidence(args.evidence)

    # 2. Load the correct msms scan (by id, not by scan number)
    msms_row = load_msms(args.msms, best_msms_id)

    # 3. Extract spectrum arrays from msms row
    full_mz, full_int, ann_mz, ann_int, ann_labels = extract_spectrum(msms_row)

    if full_mz.size == 0:
        sys.exit("Error: no peaks found in Masses2/Intensities2 columns")

    # 4. Collect header fields from msms row (scan-level values)
    scan_number  = msms_row.get('Scan number', '')
    score        = msms_row.get('Score', '')
    fragmentation = msms_row.get('Fragmentation', '')
    mass_analyzer = msms_row.get('Mass analyzer', '')

    out = args.out or args.msms.with_suffix('.png')

    plot(full_mz, full_int, ann_mz, ann_int, ann_labels,
         sequence, charge, prec_mz, raw_file,
         scan_number, score, fragmentation, mass_analyzer, out)


if __name__ == '__main__':
    main()
