# python compareMGF.py --reference F:\240819_Mitra_FOC4050_1_Slot2-10_1_8042.mgf --comparison F:\promec\TIMSTOF\LARS\Whale_Mitra27samples_LC-MSMSAugust2024-Feb2025\240819_Mitra_FOC4050_1_Slot2-10_1_8042.pwiz.mgf --output F:\mgf_differences.csv
"""Compare two timsTOF MGF files entry by entry, paired by (frame, scan).

Both files must name entries by frame and scan: "TITLE=frame=4 scan=814" (ProteoWizard) or
"TITLE=sample.frame=4.scan=814.precursor=1" (extractTDF.py --mgf). Entries are in frame order
in both files, so the files are cut into frame ranges that 32 workers compare independently.

Per entry it checks the peaks (m/z in ppm, intensity), PEPMASS m/z and intensity, CHARGE,
RTINSECONDS and, when both files carry it, ION_MOBILITY. Entries without peaks (ProteoWizard
writes them, extractTDF.py does not) are counted separately from entries with peaks that are
missing in one file. Standard library plus numpy.
"""

import argparse
import csv
import math
import mmap
import re
from collections import defaultdict
from concurrent.futures import ProcessPoolExecutor
from pathlib import Path
from typing import Dict, List, Optional, Tuple

import numpy as np

from compareMZ import match_peaks, open_data

DEFAULT_WORKERS = 32
BEGIN = b"BEGIN IONS"
TITLE = re.compile(rb"TITLE=[^\r\n]*?frame=(\d+)[ .]scan=(\d+)")
CSV_FIELDS = [
    "frame", "scan", "status", "reference_peaks", "comparison_peaks", "matched", "unmatched_reference",
    "unmatched_comparison", "max_abs_ppm", "max_abs_intensity_difference", "pepmass_ppm", "rt_difference",
    "charge_reference", "charge_comparison", "ion_mobility_difference",
]
MAX_KEYS = ("max_abs_ppm", "max_int_diff", "max_pepmass_ppm", "max_rt", "max_im")
ZERO = [
    "entries", "both", "only_reference", "only_comparison", "empty_in_one", "identical", "ref_peaks",
    "cmp_peaks", "matched", "unm_ref", "unm_cmp", "ppm_sum", "abs_ppm_sum", "int_equal", "int_different",
    "int_diff_sum", "charge_pairs", "charge_different", "im_pairs", "im_missing", "pepmass_pairs",
    "pepmass_int_different",
]


def new_stats() -> Dict[str, float]:
    stats = {key: 0 for key in ZERO + list(MAX_KEYS)}
    stats["min_diff_int"] = float("inf")
    return stats


def entry_at(data: mmap.mmap, position: int) -> Tuple[Optional[int], int]:
    """Offset and frame of the first entry starting at or after `position`."""
    offset = data.find(BEGIN, position)
    if offset == -1:
        return None, 2**62
    match = TITLE.search(data[offset : offset + 400])
    if match is None:
        raise ValueError(f"Entry at byte {offset} has no 'frame=N scan=M' title")
    return offset, int(match.group(1))


def frame_offset(data: mmap.mmap, frame: int) -> int:
    """Byte offset of the first entry of `frame` or any later frame (end of data if none)."""
    low, high = 0, len(data)
    while low < high:
        middle = (low + high) // 2
        offset, found = entry_at(data, middle)
        if offset is None or found >= frame:
            high = middle
        else:
            low = middle + 1
    offset, _ = entry_at(data, low)
    return len(data) if offset is None else offset


def parse_entry(text: bytes):
    """(frame, scan, header dict, m/z array, intensity array) of one entry body."""
    lines = text.splitlines()
    header: Dict[bytes, bytes] = {}
    peak_lines = []
    for line in lines:
        if not line or line.startswith(b"END IONS"):
            continue
        if b"=" in line:
            key, _, value = line.partition(b"=")
            header[key] = value
        else:
            peak_lines.append(line)
    match = TITLE.search(b"TITLE=" + header[b"TITLE"])
    frame, scan = int(match.group(1)), int(match.group(2))
    if peak_lines:
        values = np.fromstring(b"\n".join(peak_lines), sep=" ")
        mz, intensity = values[0::2], values[1::2]
        if mz.size > 1 and np.any(np.diff(mz) < 0):
            order = np.argsort(mz, kind="stable")
            mz, intensity = mz[order], intensity[order]
    else:
        mz = intensity = np.zeros(0)
    return frame, scan, header, mz, intensity


def iter_entries(data: mmap.mmap, start: int, end: int):
    for piece in data[start:end].split(BEGIN)[1:]:
        yield parse_entry(piece)


def pepmass(header: Dict[bytes, bytes]):
    value = header.get(b"PEPMASS")
    if not value:
        return None, None
    fields = value.split()
    return float(fields[0]), (float(fields[1]) if len(fields) > 1 else None)


def compare_peaks(ref_mz, ref_int, cmp_mz, cmp_int, ppm: float):
    """Return matched count, signed ppm array, intensity differences, leftover counts and max ppm."""
    if ref_mz.size == cmp_mz.size:
        errors = (cmp_mz - ref_mz) / ref_mz * 1e6 if ref_mz.size else np.zeros(0)
        if not errors.size or np.abs(errors).max() <= ppm:
            return errors, np.abs(np.rint(ref_int) - np.rint(cmp_int)), ref_int, 0, 0
    pairs, extra_ref, extra_cmp = match_peaks(ref_mz, cmp_mz, ppm)
    left = np.array([p[0] for p in pairs], dtype=int)
    right = np.array([p[1] for p in pairs], dtype=int)
    errors = (cmp_mz[right] - ref_mz[left]) / ref_mz[left] * 1e6 if pairs else np.zeros(0)
    return errors, np.abs(np.rint(ref_int[left]) - np.rint(cmp_int[right])), ref_int[left], len(extra_ref), len(extra_cmp)


def compare_pair(reference, comparison, args, stats, examples) -> Optional[dict]:
    frame, scan = (reference or comparison)[:2]
    stats["entries"] += 1
    if reference is None or comparison is None:
        present = reference or comparison
        key = "only_reference" if reference else "only_comparison"
        if present[3].size:
            stats[key] += 1
            status = key
        else:
            stats["empty_in_one"] += 1
            return None
        stats["ref_peaks" if reference else "cmp_peaks"] += present[3].size
        if len(examples[key]) < 3:
            examples[key].append((frame, scan, int(present[3].size)))
        return {"frame": frame, "scan": scan, "status": status,
                "reference_peaks": reference[3].size if reference else 0,
                "comparison_peaks": comparison[3].size if comparison else 0}

    stats["both"] += 1
    _, _, ref_header, ref_mz, ref_int = reference
    _, _, cmp_header, cmp_mz, cmp_int = comparison
    stats["ref_peaks"] += ref_mz.size
    stats["cmp_peaks"] += cmp_mz.size
    errors, int_diff, ref_matched_int, unm_ref, unm_cmp = compare_peaks(ref_mz, ref_int, cmp_mz, cmp_int, args.peak_ppm)
    stats["matched"] += errors.size
    stats["unm_ref"] += unm_ref
    stats["unm_cmp"] += unm_cmp
    max_ppm = float(np.abs(errors).max()) if errors.size else 0.0
    stats["ppm_sum"] += float(errors.sum())
    stats["abs_ppm_sum"] += float(np.abs(errors).sum())
    stats["max_abs_ppm"] = max(stats["max_abs_ppm"], max_ppm)
    different = int_diff > 0
    max_int = float(int_diff.max()) if int_diff.size else 0.0
    stats["int_different"] += int(different.sum())
    stats["int_equal"] += int(int_diff.size - different.sum())
    stats["int_diff_sum"] += float(int_diff.sum())
    stats["max_int_diff"] = max(stats["max_int_diff"], max_int)
    if different.any():
        stats["min_diff_int"] = min(stats["min_diff_int"], float(ref_matched_int[different].min()))
        if len(examples["intensity"]) < 3:
            examples["intensity"].append((frame, scan, float(ref_mz[0]), float(int_diff.max())))

    ref_pep, ref_pep_int = pepmass(ref_header)
    cmp_pep, cmp_pep_int = pepmass(cmp_header)
    pep_ppm = ""
    if ref_pep is not None and cmp_pep is not None:
        pep_ppm = (cmp_pep - ref_pep) / ref_pep * 1e6
        stats["pepmass_pairs"] += 1
        stats["max_pepmass_ppm"] = max(stats["max_pepmass_ppm"], abs(pep_ppm))
        if ref_pep_int is not None and cmp_pep_int is not None and round(ref_pep_int) != round(cmp_pep_int):
            stats["pepmass_int_different"] += 1
    rt_diff = ""
    if b"RTINSECONDS" in ref_header and b"RTINSECONDS" in cmp_header:
        rt_diff = abs(float(ref_header[b"RTINSECONDS"]) - float(cmp_header[b"RTINSECONDS"]))
        stats["max_rt"] = max(stats["max_rt"], rt_diff)
    ref_charge, cmp_charge = ref_header.get(b"CHARGE"), cmp_header.get(b"CHARGE")
    if ref_charge is not None and cmp_charge is not None:
        stats["charge_pairs"] += 1
        stats["charge_different"] += ref_charge != cmp_charge
    im_diff = ""
    if b"ION_MOBILITY" in ref_header and b"ION_MOBILITY" in cmp_header:
        im_diff = abs(float(ref_header[b"ION_MOBILITY"]) - float(cmp_header[b"ION_MOBILITY"]))
        stats["im_pairs"] += 1
        stats["max_im"] = max(stats["max_im"], im_diff)
    else:
        stats["im_missing"] += 1

    identical = (
        not unm_ref and not unm_cmp and not different.any() and max_ppm <= args.peak_ppm
        and ref_mz.size == cmp_mz.size and ref_charge == cmp_charge
        and (pep_ppm == "" or abs(pep_ppm) <= args.peak_ppm)
    )
    stats["identical"] += identical
    if identical:
        return None
    return {
        "frame": frame, "scan": scan, "status": "different", "reference_peaks": ref_mz.size,
        "comparison_peaks": cmp_mz.size, "matched": errors.size, "unmatched_reference": unm_ref,
        "unmatched_comparison": unm_cmp, "max_abs_ppm": max_ppm, "max_abs_intensity_difference": max_int,
        "pepmass_ppm": pep_ppm, "rt_difference": rt_diff, "charge_reference": (ref_charge or b"").decode(),
        "charge_comparison": (cmp_charge or b"").decode(), "ion_mobility_difference": im_diff,
    }


def process_slice(task):
    first, last, args = task
    data = [open_data(args.reference), open_data(args.comparison)]
    stats = new_stats()
    examples: Dict[str, list] = defaultdict(list)
    rows: List[dict] = []
    try:
        streams = [iter_entries(handle, frame_offset(handle, first), frame_offset(handle, last)) for handle in data]
        reference, comparison = next(streams[0], None), next(streams[1], None)
        while reference is not None or comparison is not None:
            use_ref = comparison is None or (reference is not None and reference[:2] <= comparison[:2])
            use_cmp = reference is None or (comparison is not None and comparison[:2] <= reference[:2])
            row = compare_pair(reference if use_ref else None, comparison if use_cmp else None, args, stats, examples)
            if row is not None and len(rows) < args.slice_rows:
                rows.append(row)
            if use_ref:
                reference = next(streams[0], None)
            if use_cmp:
                comparison = next(streams[1], None)
    finally:
        for handle in data:
            handle.close()
    return stats, dict(examples), rows


def plan_ranges(args) -> List[Tuple[int, int, argparse.Namespace]]:
    """Frame ranges that cut the reference file into about equal byte ranges."""
    data = open_data(args.reference)
    other = open_data(args.comparison)
    try:
        boundaries = {1}
        for i in range(1, args.slices):
            offset, frame = entry_at(data, len(data) * i // args.slices)
            if offset is not None:
                boundaries.add(frame)
        last_frames = []
        for handle in (data, other):
            offset = handle.rfind(BEGIN)
            last_frames.append(entry_at(handle, offset)[1])
    finally:
        data.close()
        other.close()
    ordered = sorted(boundaries) + [max(last_frames) + 1]
    return [(ordered[i], ordered[i + 1], args) for i in range(len(ordered) - 1) if ordered[i] < ordered[i + 1]]


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--reference", type=Path, required=True)
    parser.add_argument("--comparison", type=Path, required=True)
    parser.add_argument("--output", type=Path, default=Path("mgf_comparison.csv"), help="CSV of differing entries")
    parser.add_argument("--peak-ppm", type=float, default=1.0, help="peak m/z tolerance in ppm (default: 1)")
    parser.add_argument("--workers", type=int, default=DEFAULT_WORKERS)
    parser.add_argument("--slices", type=int, default=256, help="frame ranges handed to the workers (default: 256)")
    parser.add_argument("--max-rows", type=int, default=1000000, help="most differing entries written to the CSV")
    parser.add_argument("--slice-rows", type=int, default=5000, help=argparse.SUPPRESS)
    args = parser.parse_args()
    for path in (args.reference, args.comparison):
        if not path.is_file():
            parser.error(f"input file does not exist: {path}")
    if args.workers < 1 or args.slices < 1 or args.peak_ppm < 0:
        parser.error("--workers and --slices must be at least 1 and --peak-ppm non-negative")

    ranges = plan_ranges(args)
    print(f"{len(ranges)} frame ranges on {args.workers} workers", flush=True)
    totals = new_stats()
    examples_total: Dict[str, list] = defaultdict(list)
    written = 0
    args.output.parent.mkdir(parents=True, exist_ok=True)
    with args.output.open("w", newline="", encoding="utf-8") as report, ProcessPoolExecutor(max_workers=args.workers) as executor:
        writer = csv.DictWriter(report, fieldnames=CSV_FIELDS)
        writer.writeheader()
        for done, (stats, examples, rows) in enumerate(executor.map(process_slice, ranges), 1):
            for key, value in stats.items():
                if key in MAX_KEYS:
                    totals[key] = max(totals[key], value)
                elif key == "min_diff_int":
                    totals[key] = min(totals[key], value)
                else:
                    totals[key] += value
            for kind, items in examples.items():
                examples_total[kind].extend(items[: max(0, 3 - len(examples_total[kind]))])
            for row in rows:
                if written < args.max_rows:
                    writer.writerow(row)
                    written += 1
            if done % 50 == 0 or done == len(ranges):
                print(f"  {done}/{len(ranges)}", flush=True)

    t = totals
    print(f"\nReference:  {args.reference.name}\nComparison: {args.comparison.name}\n")
    print(f"Entries paired by (frame, scan):      {int(t['both']):>12}")
    print(f"  identical (peaks, PEPMASS, charge): {int(t['identical']):>12}")
    print(f"Only in reference (with peaks):       {int(t['only_reference']):>12}")
    print(f"Only in comparison (with peaks):      {int(t['only_comparison']):>12}")
    print(f"Peakless entry present in one file:   {int(t['empty_in_one']):>12}")
    matched = t["matched"]
    print(f"\nPeaks: reference {int(t['ref_peaks'])}, comparison {int(t['cmp_peaks'])}, matched within {args.peak_ppm} ppm {int(matched)}")
    print(f"  unmatched in paired entries: reference {int(t['unm_ref'])}, comparison {int(t['unm_cmp'])}")
    if matched:
        print(f"  m/z error ppm: mean {t['ppm_sum'] / matched:.3e}, mean|.| {t['abs_ppm_sum'] / matched:.3e}, max|.| {t['max_abs_ppm']:.3e}")
    different = int(t["int_different"])
    print(f"  intensity: equal {int(t['int_equal'])}, different {different}"
          + (f", max |dI| {int(t['max_int_diff'])}, mean |dI| {t['int_diff_sum'] / different:.3f}, smallest affected {t['min_diff_int']:.0f}" if different else ""))
    print(f"\nPEPMASS: {int(t['pepmass_pairs'])} pairs, max {t['max_pepmass_ppm']:.3e} ppm, intensity differs in {int(t['pepmass_int_different'])}")
    print(f"CHARGE: {int(t['charge_pairs'])} pairs, {int(t['charge_different'])} different")
    print(f"RTINSECONDS: max |difference| {t['max_rt']:.3e} s")
    print(f"ION_MOBILITY: compared for {int(t['im_pairs'])} pairs, max |difference| {t['max_im']:.3e}; missing in one file for {int(t['im_missing'])}")
    for kind, items in examples_total.items():
        for item in items[:3]:
            print(f"example {kind}: {item}")
    print(f"\nReport ({written} differing entries): {args.output}")


if __name__ == "__main__":
    main()
