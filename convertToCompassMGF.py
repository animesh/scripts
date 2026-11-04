"""Convert our per-scan PASEF MGF into a Compass (DataAnalysis) style MGF.
python convertToCompassMGF.py  L:\promec\TIMSTOF\LARS\Whale_Mitra27samples_LC-MSMSAugust2024-Feb2025\240819_Mitra_FOC4050_1_Slot2-10_1_8042.d
Wrote 6167680 MGF entries from 49592 frames to 240819_Mitra_FOC4050_1_Slot2-10_1_8042.mgf
Wrote 113236 precursor spectra to 240819_Mitra_FOC4050_1_Slot2-10_1_8042.compassstyle.mgf
Compass writes one entry per PASEF precursor: the scans of all its frames are summed,
neighbouring profile bins are merged into one centroided peak (summed intensity, half-area m/z; see
centroid_sdk), and the list is then limited as in the DataAnalysis export settings found in the header of
ProteinAnalysisResults.mgf: intensity >= 10, fragments below the precursor [M+H]+ mass + 5.6 Da,
isotope peaks removed, and about the 170 most intense peaks kept (Compass keeps 157-185; the
limit is fitted, not a published rule).
Input must be ordered by frame (as written by extractTDF.py --mgf).
"""
import argparse
import os
import re
import subprocess
import sys

import numpy as np

TITLE_RE = re.compile(r"frame=(\d+)\.scan=(\d+)\.precursor=(\d+)")
H_PLUS = 1.00728
ISOTOPE_SPACING = 1.00335


def bin_spacing(mz):
    """m/z width of one TOF bin; the digitizer samples uniformly in sqrt(m/z)."""
    return 157.2e-6 * np.sqrt(mz)


def centroid(mz, inten, gap_ppm):
    """mz sorted ascending. Merge bins closer than gap_ppm into one peak (summed intensity,
    intensity-weighted m/z). The default of 25 ppm is the PeakWidthEstimateValue (0.000025, relative)
    that Bruker stores in GlobalMetadata of analysis.tdf."""
    if len(mz) == 0:
        return mz, inten
    new = np.diff(mz) > gap_ppm * 1e-6 * mz[1:]
    starts = np.concatenate([[0], np.nonzero(new)[0] + 1])
    total = np.add.reduceat(inten, starts)
    return np.add.reduceat(mz * inten, starts) / total, total


def centroid_sdk(mz, inten, gap_ppm=25.0, radius_ppm=0.0):
    """Reproduce the peak picking of Bruker's PASEF MS/MS reader (tims_read_pasef_msms) on summed bins.

    Found by comparing its output with the raw bins: consecutive bins closer than ~38 ppm belong to the
    same peak, bins further than ~40 ppm from the apex are dropped, the intensity is the plain sum and
    the m/z is the half-area point of the profile (each bin is one TOF index wide), not the weighted mean.
    mz sorted ascending, one entry per bin."""
    if len(mz) == 0:
        return mz, inten
    gaps = np.diff(mz) / mz[:-1] * 1e6
    bounds = np.concatenate([[0], np.nonzero(gaps >= gap_ppm)[0] + 1, [len(mz)]])
    out_mz, out_it = [], []
    for a, b in zip(bounds[:-1], bounds[1:]):
        if b - a == 1:
            out_mz.append(mz[a])
            out_it.append(inten[a])
            continue
        m, v = mz[a:b], inten[a:b]
        k = int(np.argmax(v))
        ok = np.abs(m - m[k]) / m[k] * 1e6 <= (radius_ppm if radius_ppm > 0 else np.inf)
        lo = k
        while lo > 0 and ok[lo - 1]:
            lo -= 1
        hi = k
        while hi < len(m) - 1 and ok[hi + 1]:
            hi += 1
        m, v = m[lo:hi + 1], v[lo:hi + 1]
        cum = np.cumsum(v)
        half = cum[-1] / 2.0
        j = int(np.searchsorted(cum, half))
        before = cum[j - 1] if j else 0.0
        out_mz.append(m[j] + ((half - before) / v[j] - 0.5) * bin_spacing(m[j]))
        out_it.append(cum[-1])
    return np.array(out_mz), np.array(out_it)


def remove_isotopes(mz, inten, max_charge, ratio, tol_ppm=8.0):
    """Drop peaks that sit one 13C spacing above a peak (charge 1..max_charge) and are not
    more than `ratio` times its intensity (Compass: isotope deconvolution)."""
    keep = np.ones(len(mz), bool)
    for z in range(1, max_charge + 1):
        target = mz - ISOTOPE_SPACING / z
        k = np.clip(np.searchsorted(mz, target), 1, len(mz) - 1)
        for cand in (k - 1, k):
            near = np.abs(mz[cand] - target) / target * 1e6 < tol_ppm
            keep &= ~(near & (inten < ratio * inten[cand]))
    return mz[keep], inten[keep]


def ranges(frames):
    frames = sorted(frames)
    parts, start, prev = [], frames[0], frames[0]
    for f in frames[1:]:
        if f != prev + 1:
            parts.append((start, prev))
            start = f
        prev = f
    parts.append((start, prev))
    return parts


IM_SCALE = 1.01361  # constant Compass/our-calibration ratio of 1/K0 (fitted, origin unknown)


def one_over_k0(cal, scan):
    c = cal
    v = c[2] + (c[3] - c[2]) * (scan - c[0] - c[4]) / c[1]
    return v / (c[7] + c[6] * v)


def read_tdf(folder):
    """Precursors (ScanNumber, Parent) and TimsCalibration C0..C9 from analysis.tdf."""
    import sqlite3
    con = sqlite3.connect("file:" + os.path.join(folder, "analysis.tdf").replace("\\", "/") + "?mode=ro", uri=True)
    info = {r[0]: (r[1], r[2]) for r in con.execute("SELECT Id, ScanNumber, Parent FROM Precursors")}
    cal = con.execute("SELECT C0,C1,C2,C3,C4,C5,C6,C7,C8,C9 FROM TimsCalibration").fetchone()
    con.close()
    return info, cal


def fmt_ranges(frames, sep=", "):
    return sep.join(str(a) if a == b else f"{a}-{b}" for a, b in ranges(frames))


class Writer:
    def __init__(self, path, args):
        self.fh = open(path, "w", newline="\n")
        self.args = args
        self.count = 0

    def limit(self, mz, it):
        """Intensity threshold at the max-peaks-th largest peak; equal intensities are all kept."""
        n = self.args.max_peaks
        if n and len(it) > n:
            keep = it >= np.sort(it)[::-1][n - 1]
            return mz[keep], it[keep]
        return mz, it

    def write(self, pid, p):
        mz = np.concatenate(p["mz"])
        it = np.concatenate(p["int"])
        order = np.argsort(mz, kind="stable")
        mz, it = mz[order], it[order]
        u, inv = np.unique(mz, return_inverse=True)
        it = np.bincount(inv, weights=it)
        mz, it = (centroid_sdk(u, it, self.args.sdk_gap, self.args.sdk_radius) if self.args.method == "sdk"
                  else centroid(u, it, self.args.gap))
        keep = it >= self.args.min_intensity
        mz, it = mz[keep], it[keep]
        z = int(p["charge"][0]) if p["charge"] else 0
        if z and self.args.cap_margin >= 0:
            keep = mz <= p["pepmass"] * z - (z - 1) * H_PLUS + self.args.cap_margin
            mz, it = mz[keep], it[keep]
        if self.args.isotope_charge and len(mz) > 1:
            mz, it = remove_isotopes(mz, it, self.args.isotope_charge, self.args.isotope_ratio)
        mz, it = self.limit(mz, it)
        frames = sorted(p["frames"])
        w = np.array(p["w"])
        im = float(np.average(p["im"], weights=w)) if w.sum() > 0 else float(np.mean(p["im"]))
        raw = frames
        info = self.args.tdf_info.get(pid)
        if info:
            scan, parent = info
            im = one_over_k0(self.args.tdf_cal, scan) * IM_SCALE
            raw = sorted(set(frames) | {parent})
        rt = float(np.mean([p["rt_by_frame"][f] for f in frames]))
        pm = p["pepmass"]
        fh = self.fh
        self.count += 1
        fh.write(f"###MSMS: {fmt_ranges(frames, ',')}\n###Mobility: {im:.4f}\nBEGIN IONS\n")
        fh.write(f"TITLE=Cmpd {pid}, +PASEF({pm:.4f}), {p['ce']:.1f}eV, {rt / 60:.1f}min, "
                 f"#{frames[0]}-{frames[-1]}\n")
        fh.write(f"RTINSECONDS={rt:.5f}\nRAWSCANS={fmt_ranges(raw, ',')}\n")
        fh.write(f"PEPMASS={pm:.5f} {p['pepint']:.0f}\n")
        if p["charge"]:
            fh.write(f"CHARGE={p['charge']}\n")
        fh.write(f"ION_MOBILITY={pm:.5f} {p['pepint']:.0f} {im:.6f}\n")
        fh.write("".join(f"{m:.5f}\t{i:.0f}\t\n" for m, i in zip(mz, it)))
        fh.write("END IONS\n\n")


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("input", help="Bruker .d folder (extracted first with extractTDF.py --mgf) or our per-scan MGF")
    ap.add_argument("output", nargs="?", help="Compass-style MGF to write (default: <name>.compassstyle.mgf in the current folder)")
    ap.add_argument("--workers", type=int, default=32, help="extractTDF.py worker processes when the input is a .d folder")
    ap.add_argument("--max-frame", type=int, default=0, help="stop after this frame (0 = all)")
    ap.add_argument("--min-intensity", type=float, default=10)
    ap.add_argument("--method", choices=("sdk", "mean"), default="sdk",
                    help="sdk: reproduce Bruker's PASEF peak picking (gap + apex radius, half-area m/z); "
                         "mean: merge bins closer than --gap ppm with intensity-weighted m/z")
    ap.add_argument("--sdk-gap", type=float, default=25.0,
                    help="sdk: bins closer than this many ppm form one peak. 25 (PeakWidthEstimateValue) matches "
                         "Compass best; 38 reproduces Bruker's tims_read_pasef_msms output")
    ap.add_argument("--sdk-radius", type=float, default=0.0,
                    help="sdk: drop bins further than this many ppm from the apex (0 = off; 40 together with "
                         "--sdk-gap 38 reproduces tims_read_pasef_msms)")
    ap.add_argument("--gap", type=float, default=25.0,
                    help="mean: merge bins closer than this many ppm into one peak (PeakWidthEstimateValue)")
    ap.add_argument("--cap-margin", type=float, default=5.6,
                    help="drop fragments above precursor [M+H]+ mass + this many Da when the charge is known (-1 = off)")
    ap.add_argument("--isotope-charge", type=int, default=4,
                    help="remove isotope peaks for charges 1..N (0 = off)")
    ap.add_argument("--isotope-ratio", type=float, default=5.0,
                    help="an isotope peak is removed if it is below this multiple of its lower partner")
    ap.add_argument("--max-peaks", type=int, default=170,
                    help="intensity threshold at the Nth largest peak, ties kept (0 = no limit); Compass uses "
                         "about 150 (NoMSMSSignals) but keeps 157-185 peaks in dense spectra")
    ap.add_argument("--flush-gap", type=int, default=6,
                    help="a precursor is complete when no scan was seen for this many frames")
    args = ap.parse_args()

    args.tdf_info, args.tdf_cal = {}, None
    if os.path.isdir(args.input):
        args.tdf_info, args.tdf_cal = read_tdf(args.input)
        name = os.path.basename(os.path.normpath(args.input))
        stem = name[:-2] if name.endswith(".d") else name
        scan_mgf = stem + ".mgf"
        if not os.path.exists(scan_mgf):
            script = os.path.join(os.path.dirname(os.path.abspath(__file__)), "extractTDF.py")
            subprocess.run([sys.executable, script, args.input, scan_mgf, "--mgf", "--workers", str(args.workers)],
                           check=True)
        args.input = scan_mgf
        args.output = args.output or stem + ".compassstyle.mgf"
    elif not args.output:
        ap.error("output is required when the input is an MGF file")
    out = Writer(args.output, args)
    active = {}
    cur = None
    lines = []
    last_flush_frame = 0

    def flush(frame):
        for pid in [k for k, v in active.items() if frame - max(v["frames"]) > args.flush_gap]:
            out.write(pid, active.pop(pid))

    with open(args.input, "r") as fh:
        for line in fh:
            c = line[0]
            if c.isdigit():
                lines.append(line)
            elif line.startswith("BEGIN IONS"):
                cur = {}
                lines = []
            elif line.startswith("END IONS"):
                frame, pid = cur["frame"], cur["prec"]
                if args.max_frame and frame > args.max_frame:
                    break
                if frame != last_flush_frame:
                    flush(frame)
                    last_flush_frame = frame
                arr = np.array("".join(lines).split(), dtype=float)
                mz, it = arr[0::2], arr[1::2]
                p = active.get(pid)
                if p is None:
                    p = active[pid] = {"frames": set(), "mz": [], "int": [], "im": [], "w": [],
                                       "rt_by_frame": {}, "pepmass": cur["pepmass"],
                                       "pepint": cur["pepint"], "charge": cur.get("charge"),
                                       "ce": cur.get("ce", 0.0)}
                p["frames"].add(frame)
                p["mz"].append(mz)
                p["int"].append(it)
                p["im"].append(cur["im"])
                p["w"].append(float(it.sum()))
                p["rt_by_frame"][frame] = cur["rt"]
                cur = None
            elif cur is None:
                continue
            elif line.startswith("TITLE="):
                m = TITLE_RE.search(line)
                cur["frame"], cur["scan"], cur["prec"] = (int(x) for x in m.groups())
            elif line.startswith("PEPMASS="):
                a = line.split("=")[1].split()
                cur["pepmass"], cur["pepint"] = float(a[0]), float(a[1])
            elif line.startswith("CHARGE="):
                cur["charge"] = line.split("=")[1].strip()
            elif line.startswith("ION_MOBILITY="):
                cur["im"] = float(line.split("=")[1])
            elif line.startswith("RTINSECONDS="):
                cur["rt"] = float(line.split("=")[1])
            elif line.startswith("COLLISION_ENERGY="):
                cur["ce"] = float(line.split("=")[1])
    for pid in sorted(active):
        out.write(pid, active[pid])
    out.fh.close()
    print(f"Wrote {out.count} precursor spectra to {args.output}")


if __name__ == "__main__":
    main()
