"""Compare our per-scan PASEF MGF with a Bruker Compass (DataAnalysis) ProteinAnalysisResults.mgf.

Compass writes one summed, centroided spectrum per PASEF precursor ("Cmpd"), listing the
frames it merged in a '###MSMS:' comment. Our MGF has one entry per (frame, scan, precursor),
so scans are summed per precursor here before peaks are compared.
Only compounds whose frames are all <= --max-frame are used.
"""
import argparse
import csv
import re
from collections import defaultdict

import numpy as np

TITLE_RE = re.compile(r"frame=(\d+)\.scan=(\d+)\.precursor=(\d+)")


def parse_frames(text):
    frames = set()
    for part in text.split(","):
        part = part.strip()
        if "-" in part:
            a, b = part.split("-")
            frames.update(range(int(a), int(b) + 1))
        elif part:
            frames.add(int(part))
    return frames


def read_compass(path, max_frame):
    out = []
    frames = None
    cur = None
    mz, it = [], []
    with open(path, "r", errors="replace") as fh:
        for line in fh:
            if line.startswith("###MSMS:"):
                frames = parse_frames(line.split(":", 1)[1])
            elif line.startswith("BEGIN IONS"):
                cur = {"frames": frames or set()}
                mz, it = [], []
            elif cur is None:
                continue
            elif line.startswith("END IONS"):
                cur["mz"] = np.array(mz)
                cur["int"] = np.array(it)
                if cur["frames"] and max(cur["frames"]) <= max_frame:
                    out.append(cur)
                elif cur["frames"] and min(cur["frames"]) > max_frame:
                    break
                cur = None
            elif line[0].isdigit():
                a = line.split()
                mz.append(float(a[0]))
                it.append(float(a[1]))
            elif line.startswith("TITLE="):
                cur["title"] = line[6:].strip()
            elif line.startswith("RTINSECONDS="):
                cur["rt"] = float(line.split("=")[1])
            elif line.startswith("PEPMASS="):
                cur["pepmass"] = float(line.split("=")[1].split()[0])
            elif line.startswith("CHARGE="):
                cur["charge"] = line.split("=")[1].strip()
            elif line.startswith("ION_MOBILITY="):
                cur["im"] = float(line.split()[-1])
    return out


def read_ours(path, max_frame):
    precs = {}
    cur = None
    mz, it = [], []
    with open(path, "r") as fh:
        for line in fh:
            if line.startswith("BEGIN IONS"):
                cur = {}
                mz, it = [], []
            elif cur is None:
                continue
            elif line.startswith("END IONS"):
                if cur["frame"] > max_frame:
                    break
                p = precs.setdefault(cur["prec"], {"frames": set(), "mz": [], "int": [],
                                                   "pepmass": cur["pepmass"], "im": [],
                                                   "rt": [], "charge": cur.get("charge")})
                p["frames"].add(cur["frame"])
                p["mz"].append(np.array(mz))
                p["int"].append(np.array(it))
                p["im"].append(cur["im"])
                p["rt"].append(cur["rt"])
                cur = None
            elif line[0].isdigit():
                a = line.split()
                mz.append(float(a[0]))
                it.append(float(a[1]))
            elif line.startswith("TITLE="):
                m = TITLE_RE.search(line)
                cur["frame"], cur["scan"], cur["prec"] = (int(x) for x in m.groups())
            elif line.startswith("PEPMASS="):
                cur["pepmass"] = float(line.split("=")[1].split()[0])
            elif line.startswith("CHARGE="):
                cur["charge"] = line.split("=")[1].strip()
            elif line.startswith("ION_MOBILITY="):
                cur["im"] = float(line.split("=")[1])
            elif line.startswith("RTINSECONDS="):
                cur["rt"] = float(line.split("=")[1])
    for p in precs.values():
        mz_all = np.concatenate(p["mz"])
        in_all = np.concatenate(p["int"])
        u, inv = np.unique(mz_all, return_inverse=True)
        p["mz"] = u
        p["int"] = np.bincount(inv, weights=in_all)
        p["im"] = float(np.mean(p["im"]))
        p["rt"] = float(np.mean(p["rt"]))
    return precs


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--reference", required=True, help="our MGF (per scan)")
    ap.add_argument("--comparison", required=True, help="Compass ProteinAnalysisResults.mgf")
    ap.add_argument("--max-frame", type=int, default=2000)
    ap.add_argument("--pepmass-ppm", type=float, default=50.0)
    ap.add_argument("--im-tol", type=float, default=0.01)
    ap.add_argument("--reference-compass", action="store_true",
                    help="reference is already Compass-style (from convertToCompassMGF.py)")
    ap.add_argument("--output", default=None)
    args = ap.parse_args()

    if args.reference_compass:
        ours = {}
        for i, e in enumerate(read_compass(args.reference, args.max_frame)):
            ours[i] = {"frames": e["frames"], "pepmass": e["pepmass"], "im": e.get("im", 0.0),
                       "rt": e["rt"], "charge": e.get("charge"), "mz": e["mz"], "int": e["int"]}
    else:
        ours = read_ours(args.reference, args.max_frame)
    comp = read_compass(args.comparison, args.max_frame)
    print(f"Ours: {len(ours)} precursors (frames <= {args.max_frame}); Compass: {len(comp)} compounds")

    by_frame = defaultdict(list)
    for pid, p in ours.items():
        for f in p["frames"]:
            by_frame[f].append(pid)

    rows = []
    used = set()
    n_match = 0
    tot_c = hit1 = hit10 = hit100 = 0
    ratios = []
    ppms = []
    ours_big = ours_big_found = 0
    dpep, dim, drt = [], [], []
    charge_diff = charge_n = 0
    frames_equal = 0
    for c in comp:
        cand = set()
        for f in c["frames"]:
            cand.update(by_frame.get(f, ()))
        best = None
        for pid in cand:
            p = ours[pid]
            ppm = abs(c["pepmass"] - p["pepmass"]) / p["pepmass"] * 1e6
            if ppm > args.pepmass_ppm or abs(c.get("im", p["im"]) - p["im"]) > args.im_tol:
                continue
            if best is None or ppm < best[0]:
                best = (ppm, pid)
        if best is None:
            rows.append([c.get("title"), "", "no match", "", "", "", ""])
            continue
        pid = best[1]
        p = ours[pid]
        used.add(pid)
        n_match += 1
        dpep.append(best[0])
        dim.append(abs(c.get("im", p["im"]) - p["im"]))
        drt.append(abs(c["rt"] - p["rt"]))
        frames_equal += c["frames"] == p["frames"]
        if p["charge"] and "charge" in c:
            charge_n += 1
            charge_diff += p["charge"] != c["charge"]
        o_mz, o_in = p["mz"], p["int"]
        cm = c["mz"]
        idx = np.clip(np.searchsorted(o_mz, cm), 1, len(o_mz) - 1) if len(o_mz) > 1 else np.zeros(len(cm), int)
        if len(o_mz):
            left = np.abs(cm - o_mz[idx - 1]) < np.abs(cm - o_mz[idx])
            j = np.where(left, idx - 1, idx)
            err = (cm - o_mz[j]) / o_mz[j] * 1e6
        else:
            j = np.zeros(len(cm), int)
            err = np.full(len(cm), np.inf)
        a = np.abs(err)
        tot_c += len(cm)
        hit1 += int((a <= 1).sum())
        hit10 += int((a <= 10).sum())
        hit100 += int((a <= 100).sum())
        ok = a <= 10
        if ok.any():
            ratios.append(c["int"][ok] / o_in[j[ok]])
            ppms.append(err[ok])
        # our summed peaks Compass kept (intensity >= 10)
        big = o_in >= 10
        if big.any() and len(cm):
            k = np.searchsorted(cm, o_mz[big])
            near = np.minimum(np.abs(o_mz[big] - cm[np.clip(k - 1, 0, len(cm) - 1)]),
                              np.abs(o_mz[big] - cm[np.clip(k, 0, len(cm) - 1)]))
            ours_big += int(big.sum())
            ours_big_found += int((near / o_mz[big] * 1e6 <= 10).sum())
        rows.append([c.get("title"), pid, "matched", len(cm), len(o_mz),
                     int((a <= 1).sum()), f"{best[0]:.2f}"])

    print(f"\nCompass compounds matched to one of our precursors: {n_match}/{len(comp)} "
          f"(same frame set: {frames_equal})")
    if n_match:
        print(f"PEPMASS diff ppm: mean {np.mean(dpep):.2f}, max {np.max(dpep):.2f}")
        print(f"1/K0 diff: mean {np.mean(dim):.5f}, max {np.max(dim):.5f}")
        print(f"RT diff s: mean {np.mean(drt):.3f}, max {np.max(drt):.3f}")
        print(f"CHARGE compared {charge_n}, different {charge_diff}")
        print(f"\nCompass fragment peaks: {tot_c}")
        print(f"  with one of our summed peaks within 1 ppm : {hit1} ({100*hit1/tot_c:.1f}%)")
        print(f"  within 10 ppm : {hit10} ({100*hit10/tot_c:.1f}%)")
        print(f"  within 100 ppm: {hit100} ({100*hit100/tot_c:.1f}%)")
        if ppms:
            pp = np.concatenate(ppms)
            rr = np.concatenate(ratios)
            print(f"  ppm error (<=10 ppm pairs): mean {pp.mean():.3f}, mean|.| {np.abs(pp).mean():.3f}")
            print(f"  intensity Compass/ours: median {np.median(rr):.3f}, "
                  f"fraction within 1% {np.mean(np.abs(rr - 1) < 0.01):.3f}")
        if ours_big:
            print(f"Our summed peaks >= 10 counts: {ours_big}; found in Compass within 10 ppm: "
                  f"{ours_big_found} ({100*ours_big_found/ours_big:.1f}%)")
    if args.output:
        with open(args.output, "w", newline="") as fh:
            w = csv.writer(fh)
            w.writerow(["compass_title", "our_precursor", "status", "compass_peaks",
                        "our_summed_peaks", "peaks_within_1ppm", "pepmass_ppm"])
            w.writerows(rows)
        print(f"Report: {args.output}")


if __name__ == "__main__":
    main()
