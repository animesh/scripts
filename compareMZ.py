# python compareMZ.py --reference F:\240819_Mitra_FOC4050_1_Slot2-10_1_8042.mzML  --comparison F:\promec\TIMSTOF\LARS\Whale_Mitra27samples_LC-MSMSAugust2024-Feb2025\240819_Mitra_FOC4050_1_Slot2-10_1_8042.mzML --rt-tolerance 0.01 --ms2-before 0.01 --ms2-after 0.01 --output F:\extracted_vs_converted.csv
"""Compare spectra of two mzML files at every MS level.
MS1 spectra are paired by retention time. MS2+ spectra are paired by precursor
m/z (ppm) within a retention-time window; the reference candidate with the best
cosine similarity is reported. Peaks are matched in ppm and the signed m/z
error shows calibration differences. Files are streamed. Both files are indexed
and cut into retention-time slices; every worker process parses, pairs and
compares its own slice, so all CPUs are used. A per-MS-level summary is printed.

With --by-id (automatic when both files name spectra "frame=N scan=M", as
ProteoWizard and extractTDF.py do) spectra are paired by native id, one scan to
one scan, and compared peak by peak: m/z in ppm, intensity, 1/K0, retention
time. Frames are cut into slices that the workers process independently.
"""

import argparse
import base64
import csv
import io
import math
import mmap
import re
import shutil
import sys
import xml.etree.ElementTree as ET
import zlib
from array import array
from collections import defaultdict, deque
from concurrent.futures import ProcessPoolExecutor
from dataclasses import dataclass, replace
from pathlib import Path
from typing import Deque, Dict, Iterator, List, Optional, Sequence, Tuple


DEFAULT_WORKERS = 32

DEFAULT_REFERENCE = (
    r"F:\promec\TIMSTOF\LARS\Whale_Mitra27samples_LC-MSMSAugust2024-Feb2025"
    r"\240819_Mitra_FOC4050_1_Slot2-10_1_8042.paser.mzML"
)
DEFAULT_COMPARISON = (
    r"F:\promec\TIMSTOF\LARS\Whale_Mitra27samples_LC-MSMSAugust2024-Feb2025"
    r"\240819_Mitra_FOC4050_1_Slot2-10_1_8042_uncalibrated.mzML"
)

FIELDNAMES = [
    "status",
    "ms_level",
    "reference_scan_index",
    "reference_native_id",
    "reference_rt_seconds",
    "reference_precursor_mz",
    "reference_ion_mobility",
    "reference_peak_count",
    "comparison_scan_index",
    "comparison_native_id",
    "comparison_rt_seconds",
    "comparison_precursor_mz",
    "comparison_ion_mobility",
    "comparison_peak_count",
    "candidate_count",
    "rt_difference_seconds",
    "precursor_error_ppm",
    "ion_mobility_difference",
    "matched_peak_count",
    "unmatched_reference_peak_count",
    "unmatched_comparison_peak_count",
    "cosine_similarity",
    "mean_peak_error_ppm",
    "mean_abs_peak_error_ppm",
    "max_abs_peak_error_ppm",
]


@dataclass(frozen=True)
class Spectrum:
    index: int
    native_id: str
    rt: float
    ms_level: int
    precursor_mz: Optional[float]
    mz: Sequence[float]
    intensities: Sequence[float]
    # Inverse reduced ion mobility 1/K0 in V*s/cm^2 (timsTOF); None if absent
    ion_mobility: Optional[float] = None


def iter_spectra(path: Path, source=None) -> Iterator[Spectrum]:
    """Stream spectra from an mzML file, or from a file-like `source` holding a part of it."""
    referenceable_groups = {}
    spectrum_count = 0
    stack = []
    for event, element in ET.iterparse(
        source if source is not None else str(path), events=("start", "end")
    ):
        if event == "start":
            stack.append(element)
            continue

        element_type = element.tag.rsplit("}", 1)[-1]
        if element_type == "referenceableParamGroup":
            referenceable_groups[element.attrib["id"]] = _cv_params(
                element, referenceable_groups
            )
            stack[-2].clear()
            element.clear()
            stack.pop()
            continue
        if element_type != "spectrum":
            stack.pop()
            continue

        params = _cv_params(element, referenceable_groups)
        ms_level = _cv_value(params, "MS:1000511")
        if ms_level is None:
            spectrum_type = next(
                (
                    param.get("accession")
                    for param in params
                    if param.get("accession") in ("MS:1000579", "MS:1000580")
                ),
                None,
            )
            ms_level = {"MS:1000579": "1", "MS:1000580": "2"}.get(spectrum_type)
        if ms_level is None:
            raise ValueError(f"Spectrum in {path} is missing its MS level")
        retention_time = _cv_value(params, "MS:1000016")
        if retention_time is None:
            raise ValueError(f"Spectrum in {path} is missing its scan start time")
        rt = float(retention_time)
        rt_unit = next(
            (
                param.get("unitAccession")
                for param in params
                if param.get("accession") == "MS:1000016"
            ),
            None,
        )
        if rt_unit == "UO:0000031":
            rt *= 60.0
        elif rt_unit not in (None, "UO:0000010"):
            raise ValueError(f"Unsupported retention-time unit {rt_unit!r} in {path}")

        # A precursor m/z of 0 means "unknown" in some exporters
        precursor_text = _cv_value(params, "MS:1000744")
        precursor_mz = float(precursor_text) if precursor_text is not None else None
        if precursor_mz is not None and precursor_mz <= 0:
            precursor_mz = None

        mobility_text = _cv_value(params, "MS:1002815")
        ion_mobility = float(mobility_text) if mobility_text else None
        if ion_mobility is not None and ion_mobility <= 0:
            ion_mobility = None

        arrays = {}
        for binary_array in element.iter():
            if binary_array.tag.rsplit("}", 1)[-1] != "binaryDataArray":
                continue
            array_params = _cv_params(binary_array, referenceable_groups)
            array_type = (
                "mz"
                if any(p.get("accession") == "MS:1000514" for p in array_params)
                else "intensity"
                if any(p.get("accession") == "MS:1000515" for p in array_params)
                else None
            )
            if array_type is None:
                continue
            binary = next(
                (
                    child
                    for child in binary_array
                    if child.tag.rsplit("}", 1)[-1] == "binary"
                ),
                None,
            )
            arrays[array_type] = _decode_binary_array(
                binary.text if binary is not None else "", array_params, path
            )

        if "mz" not in arrays or "intensity" not in arrays:
            raise ValueError(f"Spectrum in {path} is missing m/z or intensity data")
        if len(arrays["mz"]) != len(arrays["intensity"]):
            raise ValueError(f"Spectrum in {path} has mismatched peak-array lengths")

        spectrum = Spectrum(
            index=int(element.attrib.get("index", spectrum_count)),
            native_id=element.attrib.get("id", ""),
            rt=rt,
            ms_level=int(float(ms_level)),
            precursor_mz=precursor_mz,
            mz=arrays["mz"],
            intensities=arrays["intensity"],
            ion_mobility=ion_mobility,
        )
        stack[-2].clear()
        element.clear()
        stack.pop()
        spectrum_count += 1
        yield spectrum


def _cv_value(params: Sequence[Dict[str, str]], accession: str) -> Optional[str]:
    return next(
        (param.get("value") for param in params if param.get("accession") == accession),
        None,
    )


def _cv_params(element, referenceable_groups) -> List[Dict[str, str]]:
    params = []
    for child in element.iter():
        child_type = child.tag.rsplit("}", 1)[-1]
        if child_type == "cvParam":
            params.append(child.attrib)
        elif child_type == "referenceableParamGroupRef":
            group_id = child.attrib["ref"]
            try:
                params.extend(referenceable_groups[group_id])
            except KeyError as error:
                raise ValueError(
                    f"Unknown referenceable parameter group: {group_id}"
                ) from error
    return params


def _decode_binary_array(
    text: str, params: Sequence[Dict[str, str]], path: Path
) -> array:
    if any(
        param.get("accession") in ("MS:1002312", "MS:1002313", "MS:1002314")
        for param in params
    ):
        raise ValueError(f"Numpress-compressed binary arrays are not supported: {path}")
    if any(param.get("accession") == "MS:1000521" for param in params):
        type_code = "f"
    elif any(param.get("accession") == "MS:1000523" for param in params):
        type_code = "d"
    else:
        raise ValueError(f"Binary array in {path} has no supported float precision")

    values = array(type_code)
    encoded = base64.b64decode(text or "")
    if not encoded:
        return values
    if any(param.get("accession") == "MS:1000574" for param in params):
        encoded = zlib.decompress(encoded)
    if len(encoded) % values.itemsize:
        raise ValueError(f"Binary array in {path} has an invalid byte length")
    values.frombytes(encoded)
    if sys.byteorder == "big":
        values.byteswap()
    return values


def compare_peaks(
    reference: Spectrum, comparison: Spectrum, ppm_tolerance: float
) -> Tuple[int, float, Optional[float], Optional[float]]:
    """Return matched peaks, cosine, mean signed ppm and mean absolute ppm.

    Signed error is (comparison - reference) / reference. The cosine uses the
    intensities of matched peaks over the norms of the complete spectra.
    """
    reference_mz, comparison_mz = reference.mz, comparison.mz
    reference_int, comparison_int = reference.intensities, comparison.intensities
    left = right = matched_count = 0
    dot_product = 0.0
    signed_sum = abs_sum = max_abs = 0.0

    while left < len(reference_mz) and right < len(comparison_mz):
        expected = reference_mz[left]
        difference = comparison_mz[right] - expected
        if abs(difference) <= expected * ppm_tolerance * 1e-6:
            matched_count += 1
            dot_product += reference_int[left] * comparison_int[right]
            if expected:
                ppm = difference / expected * 1e6
                signed_sum += ppm
                abs_sum += abs(ppm)
                max_abs = max(max_abs, abs(ppm))
            left += 1
            right += 1
        elif difference < 0:
            right += 1
        else:
            left += 1

    denominator = math.sqrt(
        sum(v * v for v in reference_int) * sum(v * v for v in comparison_int)
    )
    cosine = dot_product / denominator if denominator else float("nan")
    if not matched_count:
        return 0, cosine, None, None, None
    return (
        matched_count,
        cosine,
        signed_sum / matched_count,
        abs_sum / matched_count,
        max_abs,
    )


def merge_spectra(spectra: Sequence[Spectrum], ppm_tolerance: float) -> Spectrum:
    """Sum peaks of several spectra, clustering peaks closer than the ppm tolerance."""
    peaks = sorted(
        (mz, intensity)
        for spectrum in spectra
        for mz, intensity in zip(spectrum.mz, spectrum.intensities)
    )
    mz_values: List[float] = []
    intensities: List[float] = []
    start = weighted_mz = total = None
    for mz, intensity in peaks:
        if start is not None and mz <= start * (1 + ppm_tolerance * 1e-6):
            weighted_mz += mz * intensity
            total += intensity
            continue
        if start is not None:
            mz_values.append(weighted_mz / total if total else start)
            intensities.append(total)
        start, weighted_mz, total = mz, mz * intensity, intensity
    if start is not None:
        mz_values.append(weighted_mz / total if total else start)
        intensities.append(total)
    first = spectra[0]
    return Spectrum(
        first.index,
        first.native_id,
        sum(s.rt for s in spectra) / len(spectra),
        first.ms_level,
        first.precursor_mz,
        mz_values,
        intensities,
    )


def collapse_mobility(
    spectra: Iterator[Spectrum],
    rt_gap: float,
    precursor_ppm: float,
    peak_ppm: float,
    counts: Dict[str, int],
) -> Iterator[Spectrum]:
    """Merge MS2+ spectra of one precursor that differ only by ion mobility.

    A spectrum joins an open group of the same level and precursor (within
    precursor_ppm) whose latest retention time is at most rt_gap seconds
    earlier. Groups are emitted in order of their first spectrum, so the
    retention-time order of the stream is kept. The merged spectrum carries no
    mobility because it spans several 1/K0 values.
    """
    queue: Deque[List] = deque()  # [spectra, closed]
    open_groups: List[List] = []

    def drain(flush: bool) -> Iterator[Spectrum]:
        while queue and (flush or queue[0][1]):
            group = queue.popleft()[0]
            counts["groups"] += 1
            if len(group) == 1:
                yield group[0]
                continue
            counts["collapsed"] += len(group)
            merged = merge_spectra(group, peak_ppm)
            yield replace(merged, rt=group[0].rt, ion_mobility=None)

    for spectrum in spectra:
        counts["input"] += 1
        for group in open_groups:
            if spectrum.rt - group[0][-1].rt > rt_gap:
                group[1] = True
        open_groups = [g for g in open_groups if not g[1]]
        entry = None
        if spectrum.ms_level >= 2 and spectrum.precursor_mz is not None:
            for group in open_groups:
                first = group[0][0]
                if (
                    first.ms_level == spectrum.ms_level
                    and abs(first.precursor_mz - spectrum.precursor_mz)
                    <= first.precursor_mz * precursor_ppm * 1e-6
                ):
                    entry = group
                    break
        if entry is not None:
            entry[0].append(spectrum)
        else:
            entry = [[spectrum], spectrum.ms_level < 2 or spectrum.precursor_mz is None]
            queue.append(entry)
            if not entry[1]:
                open_groups.append(entry)
        yield from drain(False)
    yield from drain(True)


def compare_candidates(
    comparison: Spectrum, candidates: Sequence[Spectrum], ppm_tolerance: float
) -> Tuple[int, Tuple[int, float, Optional[float], Optional[float], Optional[float]]]:
    """Merge the reference candidates and compare them with one spectrum.

    Returns the peak count of the merged reference and the peak comparison.
    """
    reference = (
        candidates[0]
        if len(candidates) == 1
        else merge_spectra(candidates, ppm_tolerance)
    )
    return len(reference.mz), compare_peaks(reference, comparison, ppm_tolerance)


def spectrum_fields(prefix: str, spectrum: Optional[Spectrum]) -> Dict[str, object]:
    if spectrum is None:
        return {
            f"{prefix}_scan_index": "",
            f"{prefix}_native_id": "",
            f"{prefix}_rt_seconds": "",
            f"{prefix}_precursor_mz": "",
            f"{prefix}_ion_mobility": "",
            f"{prefix}_peak_count": "",
        }
    return {
        f"{prefix}_scan_index": spectrum.index,
        f"{prefix}_native_id": spectrum.native_id,
        f"{prefix}_rt_seconds": spectrum.rt,
        f"{prefix}_precursor_mz": (
            spectrum.precursor_mz if spectrum.precursor_mz is not None else ""
        ),
        f"{prefix}_ion_mobility": (
            spectrum.ion_mobility if spectrum.ion_mobility is not None else ""
        ),
        f"{prefix}_peak_count": len(spectrum.mz),
    }


def blank_row(
    status: str, reference: Optional[Spectrum], comparison: Optional[Spectrum]
) -> Dict[str, object]:
    row = {name: "" for name in FIELDNAMES}
    row["status"] = status
    row["ms_level"] = (reference or comparison).ms_level
    row.update(spectrum_fields("reference", reference))
    row.update(spectrum_fields("comparison", comparison))
    return row


def matched_row(
    candidates: Sequence[Spectrum],
    comparison: Spectrum,
    reference_peak_count: int,
    result: Tuple[int, float, Optional[float], Optional[float], Optional[float]],
) -> Dict[str, object]:
    matched_peaks, cosine, signed_ppm, abs_ppm, max_abs_ppm = result
    reference = candidates[0]
    mean_rt = sum(c.rt for c in candidates) / len(candidates)
    row = blank_row("matched", reference, comparison)
    row.update(
        {
            "reference_peak_count": reference_peak_count,
            "candidate_count": len(candidates),
            "rt_difference_seconds": comparison.rt - mean_rt,
            "matched_peak_count": matched_peaks,
            "unmatched_reference_peak_count": reference_peak_count - matched_peaks,
            "unmatched_comparison_peak_count": len(comparison.mz) - matched_peaks,
            "cosine_similarity": cosine if not math.isnan(cosine) else "",
            "mean_peak_error_ppm": signed_ppm if signed_ppm is not None else "",
            "mean_abs_peak_error_ppm": abs_ppm if abs_ppm is not None else "",
            "max_abs_peak_error_ppm": max_abs_ppm if max_abs_ppm is not None else "",
        }
    )
    if reference.precursor_mz and comparison.precursor_mz:
        row["precursor_error_ppm"] = (
            (comparison.precursor_mz - reference.precursor_mz)
            / reference.precursor_mz
            * 1e6
        )
    mobilities = [c.ion_mobility for c in candidates if c.ion_mobility is not None]
    if mobilities and comparison.ion_mobility is not None:
        row["reference_ion_mobility"] = sum(mobilities) / len(mobilities)
        row["ion_mobility_difference"] = comparison.ion_mobility - row[
            "reference_ion_mobility"
        ]
    return row


def new_level_stats() -> Dict[str, float]:
    return {
        "reference": 0,
        "comparison": 0,
        "matched": 0,
        "unmatched_reference": 0,
        "unmatched_comparison": 0,
        "cosine_sum": 0.0,
        "cosine_count": 0,
        "ppm_sum": 0.0,
        "abs_ppm_sum": 0.0,
        "ppm_count": 0,
        "max_abs_ppm": 0.0,
        "recall_sum": 0.0,
        "im_pairs": 0,
        "im_abs_sum": 0.0,
        "im_max": 0.0,
        "reference_im": 0,
        "comparison_im": 0,
    }


def select_candidates(
    comparison: Spectrum,
    window: Sequence[Spectrum],
    consumed: set,
    rt_tolerance: float,
    ms2_before: float,
    ms2_after: float,
    precursor_ppm: float,
    im_tolerance: float,
) -> List[Spectrum]:
    # Mobility only filters when both spectra carry it
    same_level = [
        s
        for s in window
        if s.ms_level == comparison.ms_level
        and (
            s.ion_mobility is None
            or comparison.ion_mobility is None
            or abs(s.ion_mobility - comparison.ion_mobility) <= im_tolerance
        )
    ]
    if comparison.ms_level == 1:
        free = [
            s
            for s in same_level
            if abs(s.rt - comparison.rt) <= rt_tolerance and s.index not in consumed
        ]
        if not free:
            return []
        return [min(free, key=lambda s: (abs(s.rt - comparison.rt), s.index))]

    # MS2+ reference scans of one precursor follow the retention time that the
    # comparison file stamps on the merged spectrum, so the window is asymmetric
    if comparison.precursor_mz is None:
        return []
    return [
        spectrum
        for spectrum in same_level
        if -ms2_before <= spectrum.rt - comparison.rt <= ms2_after
        and spectrum.precursor_mz is not None
        and abs(spectrum.precursor_mz - comparison.precursor_mz)
        <= spectrum.precursor_mz * precursor_ppm * 1e-6
    ]


MAX_STAT_KEYS = ("max_abs_ppm", "im_max")
SPECTRUM_START = b"<spectrum "
SPECTRUM_END = b"</spectrum>"
RT_TAG = re.compile(rb'<cvParam\b[^>]*accession="MS:1000016"[^>]*>')
VALUE_ATTRIBUTE = re.compile(rb'\bvalue="([^"]*)"')
UNIT_ATTRIBUTE = re.compile(rb'\bunitAccession="([^"]*)"')


@dataclass
class MzmlIndex:
    """Byte offsets of every spectrum, so that parts of a file can be parsed alone."""

    path: Path
    header: bytes
    footer: bytes
    # Start of each spectrum, plus the end of the last one
    offsets: List[int]


def open_data(path: Path) -> mmap.mmap:
    with path.open("rb") as handle:
        return mmap.mmap(handle.fileno(), 0, access=mmap.ACCESS_READ)


def build_index(path: Path) -> MzmlIndex:
    data = open_data(path)
    try:
        offsets = []
        position = data.find(SPECTRUM_START)
        while position != -1:
            offsets.append(position)
            position = data.find(SPECTRUM_START, position + len(SPECTRUM_START))
        if not offsets:
            raise ValueError(f"No spectra found in {path}")
        offsets.append(data.rfind(SPECTRUM_END) + len(SPECTRUM_END))
        header = data[: offsets[0]]
    finally:
        data.close()
    footer = b"</spectrumList></run></mzML>"
    if b"<indexedmzML" in header:
        footer += b"</indexedmzML>"
    return MzmlIndex(path, header, footer, offsets)


def spectrum_rt(data: mmap.mmap, index: MzmlIndex, position: int) -> float:
    start = index.offsets[position]
    chunk = data[start : min(start + 16384, index.offsets[-1])]
    tag = RT_TAG.search(chunk)
    value = VALUE_ATTRIBUTE.search(tag.group(0)) if tag else None
    if value is None:
        raise ValueError(f"Spectrum {position} in {index.path} has no scan start time")
    rt = float(value.group(1))
    unit = UNIT_ATTRIBUTE.search(tag.group(0))
    if unit and unit.group(1) == b"UO:0000031":
        rt *= 60.0
    return rt


def count_up_to(
    data: mmap.mmap, index: MzmlIndex, rt: float, inclusive: bool
) -> int:
    """Number of leading spectra with a retention time below (or equal to) rt."""
    low, high = 0, len(index.offsets) - 1
    while low < high:
        middle = (low + high) // 2
        middle_rt = spectrum_rt(data, index, middle)
        if middle_rt < rt or (inclusive and middle_rt == rt):
            low = middle + 1
        else:
            high = middle
    return low


def iter_range(
    index: MzmlIndex, data: mmap.mmap, first: int, last: int
) -> Iterator[Spectrum]:
    """Spectra first..last-1 of an indexed file."""
    part = data[index.offsets[first] : index.offsets[last]]
    return iter_spectra(index.path, io.BytesIO(index.header + part + index.footer))


def plan_slices(
    reference: MzmlIndex, comparison: MzmlIndex, args: argparse.Namespace
) -> List[Tuple[int, int, int, int, int, float, float]]:
    """Cut the run into retention-time slices.

    Each slice holds a range of comparison spectra and every reference spectrum
    that can pair with them. Reference spectra are owned by the slice whose
    retention-time span contains them, which decides who reports them unmatched.
    """
    look_ahead = max(args.rt_tolerance, args.ms2_after)
    look_behind = max(args.rt_tolerance, args.ms2_before)
    reference_data = open_data(reference.path)
    comparison_data = open_data(comparison.path)
    try:
        comparison_count = len(comparison.offsets) - 1
        reference_count = len(reference.offsets) - 1
        if args.max_rt is not None:
            comparison_count = count_up_to(comparison_data, comparison, args.max_rt, True)
            reference_count = count_up_to(reference_data, reference, args.max_rt, True)
        slice_count = max(1, min(args.workers * 8, comparison_count // 50))
        bounds = sorted({k * comparison_count // slice_count for k in range(slice_count + 1)})
        slices = []
        for k in range(len(bounds) - 1):
            first, last = bounds[k], bounds[k + 1]
            first_rt = spectrum_rt(comparison_data, comparison, first)
            last_rt = spectrum_rt(comparison_data, comparison, last - 1)
            is_first, is_last = k == 0, k == len(bounds) - 2
            owner_low = float("-inf") if is_first else first_rt
            owner_high = (
                float("inf")
                if is_last
                else spectrum_rt(comparison_data, comparison, last)
            )
            reference_first = (
                0
                if is_first
                else count_up_to(reference_data, reference, first_rt - look_behind, False)
            )
            reference_last = (
                reference_count
                if is_last
                else min(
                    reference_count,
                    count_up_to(
                        reference_data,
                        reference,
                        max(last_rt + look_ahead, owner_high),
                        True,
                    ),
                )
            )
            slices.append(
                (k, first, last, reference_first, reference_last, owner_low, owner_high)
            )
        return slices
    finally:
        reference_data.close()
        comparison_data.close()


_SLICE: Dict[str, object] = {}


def init_slice_worker(
    reference: MzmlIndex, comparison: MzmlIndex, args: argparse.Namespace
) -> None:
    _SLICE.update(
        args=args,
        reference=reference,
        comparison=comparison,
        reference_data=open_data(reference.path),
        comparison_data=open_data(comparison.path),
    )


def record_match(
    stats: Dict[int, Dict[str, float]],
    comparison: Spectrum,
    row: Dict[str, object],
    result: Tuple[int, float, Optional[float], Optional[float], Optional[float]],
) -> None:
    level = stats[comparison.ms_level]
    level["matched"] += 1
    if row["ion_mobility_difference"] != "":
        difference = abs(row["ion_mobility_difference"])
        level["im_pairs"] += 1
        level["im_abs_sum"] += difference
        level["im_max"] = max(level["im_max"], difference)
    if comparison.mz:
        level["recall_sum"] += result[0] / len(comparison.mz)
    if not math.isnan(result[1]):
        level["cosine_sum"] += result[1]
        level["cosine_count"] += 1
    if result[2] is not None:
        level["ppm_sum"] += result[2]
        level["abs_ppm_sum"] += result[3]
        level["max_abs_ppm"] = max(level["max_abs_ppm"], result[4])
        level["ppm_count"] += 1


def process_slice(task: Tuple[int, int, int, int, int, float, float]):
    """Parse, pair and compare one slice; runs in a worker process.

    Returns the slice number, its statistics, the collapse counts, the rows of
    owned reference spectra that nothing in this slice paired with, the indices
    of reference spectra owned by other slices that this slice did pair with,
    and the path of the CSV part holding every other row.
    """
    k, first, last, reference_first, reference_last, owner_low, owner_high = task
    args = _SLICE["args"]
    reference, comparison = _SLICE["reference"], _SLICE["comparison"]
    stats: Dict[int, Dict[str, float]] = defaultdict(new_level_stats)
    collapse_counts: Dict[str, int] = defaultdict(int)
    unpaired_reference_rows: List[Dict[str, object]] = []
    foreign_touched = set()
    touched = set()
    window: Deque[Spectrum] = deque()
    look_ahead = max(args.rt_tolerance, args.ms2_after)
    look_behind = max(args.rt_tolerance, args.ms2_before)
    last_reference_rt = last_comparison_rt = float("-inf")

    def owned(spectrum: Spectrum) -> bool:
        return owner_low <= spectrum.rt < owner_high

    reference_spectra = iter_range(
        reference, _SLICE["reference_data"], reference_first, reference_last
    )
    next_reference = next(reference_spectra, None)
    part_path = args.output.with_name(f"{args.output.name}.part{k}")

    with part_path.open("w", newline="", encoding="utf-8") as report:
        writer = csv.DictWriter(report, fieldnames=FIELDNAMES)

        def take_reference() -> Spectrum:
            nonlocal next_reference, last_reference_rt
            spectrum = next_reference
            if spectrum.rt < last_reference_rt:
                raise ValueError(
                    f"Reference spectra are not in retention-time order: {args.reference}"
                )
            last_reference_rt = spectrum.rt
            if owned(spectrum):
                stats[spectrum.ms_level]["reference"] += 1
                if spectrum.ion_mobility is not None:
                    stats[spectrum.ms_level]["reference_im"] += 1
            next_reference = next(reference_spectra, None)
            return spectrum

        def retire_reference(spectrum: Spectrum) -> None:
            if spectrum.index in touched:
                touched.discard(spectrum.index)
            elif owned(spectrum):
                unpaired_reference_rows.append(
                    blank_row("unmatched_reference", spectrum, None)
                )

        comparison_stream = iter_range(
            comparison, _SLICE["comparison_data"], first, last
        )
        if args.collapse_rt > 0:
            comparison_stream = collapse_mobility(
                comparison_stream,
                args.collapse_rt,
                args.precursor_ppm,
                args.peak_ppm,
                collapse_counts,
            )
        for spectrum in comparison_stream:
            if spectrum.rt < last_comparison_rt:
                raise ValueError(
                    f"Comparison spectra are not in retention-time order: {args.comparison}"
                )
            last_comparison_rt = spectrum.rt
            stats[spectrum.ms_level]["comparison"] += 1
            if spectrum.ion_mobility is not None:
                stats[spectrum.ms_level]["comparison_im"] += 1

            while (
                next_reference is not None
                and next_reference.rt <= spectrum.rt + look_ahead
            ):
                window.append(take_reference())
            while window and window[0].rt < spectrum.rt - look_behind:
                retire_reference(window.popleft())

            candidates = select_candidates(
                spectrum,
                window,
                touched,
                args.rt_tolerance,
                args.ms2_before,
                args.ms2_after,
                args.precursor_ppm,
                args.im_tolerance,
            )
            if not candidates:
                writer.writerow(blank_row("unmatched_comparison", None, spectrum))
                stats[spectrum.ms_level]["unmatched_comparison"] += 1
                continue

            for candidate in candidates:
                touched.add(candidate.index)
                if not owned(candidate):
                    foreign_touched.add(candidate.index)
            reference_peak_count, result = compare_candidates(
                spectrum, candidates, args.peak_ppm
            )
            row = matched_row(candidates, spectrum, reference_peak_count, result)
            writer.writerow(row)
            record_match(stats, spectrum, row, result)

        while next_reference is not None:
            window.append(take_reference())
        while window:
            retire_reference(window.popleft())

    return (
        k,
        dict(stats),
        dict(collapse_counts),
        unpaired_reference_rows,
        foreign_touched,
        str(part_path),
    )


SCAN_ID = re.compile(rb'<spectrum\b[^>]*?\bid="frame=(\d+) scan=(\d+)"')
LEVEL_VALUE = re.compile(rb'accession="MS:1000511"[^>]*?\bvalue="(\d+)"')
MOBILITY_VALUE = re.compile(rb'accession="MS:1002815"[^>]*?\bvalue="([^"]*)"')
RT_VALUE = re.compile(rb'accession="MS:1000016"[^>]*?\bvalue="([^"]*)"([^>]*)>')
ARRAY_BLOCK = re.compile(rb"<binaryDataArray\b.*?</binaryDataArray>", re.S)
BINARY_TEXT = re.compile(rb"<binary>(.*?)</binary>", re.S)
ARRAY_TYPES = ((b"MS:1000523", "d"), (b"MS:1000521", "f"), (b"MS:1000519", "i"), (b"MS:1000522", "q"))
SCAN_MAX_KEYS = ("max_abs_ppm", "max_int_diff", "im_max", "rt_max", "max_near_ppm")
SCAN_MIN_KEYS = ("min_diff_int",)
INTENSITY_BINS = 8
SCAN_CSV_FIELDS = [
    "frame", "scan", "ms_level", "reference_peaks", "comparison_peaks", "matched", "near_matched",
    "unmatched_reference", "unmatched_comparison", "max_abs_ppm", "max_abs_intensity_difference",
    "ion_mobility_difference",
]


def locate_spectrum(data: mmap.mmap, position: int) -> Tuple[Optional[int], int]:
    """Offset and frame number of the first spectrum starting at or after `position`."""
    offset = data.find(SPECTRUM_START, position)
    if offset == -1:
        return None, 2**62
    match = SCAN_ID.match(data, offset)
    if match is None:
        raise ValueError(f"Spectrum at byte {offset} has no 'frame=N scan=M' native id")
    return offset, int(match.group(1))


def frame_offset(data: mmap.mmap, frame: int) -> int:
    """Byte offset of the first spectrum of `frame` or any later frame (end of data if none)."""
    low, high = 0, len(data)
    while low < high:
        middle = (low + high) // 2
        offset, found = locate_spectrum(data, middle)
        if offset is None or found >= frame:
            high = middle
        else:
            low = middle + 1
    offset, _ = locate_spectrum(data, low)
    return len(data) if offset is None else offset


def uses_scan_ids(path: Path) -> bool:
    with path.open("rb") as handle:
        head = handle.read(1 << 20)
    offset = head.find(SPECTRUM_START)
    return offset != -1 and SCAN_ID.match(head, offset) is not None


def last_frame(data: mmap.mmap) -> int:
    offset = data.rfind(SPECTRUM_START)
    return int(SCAN_ID.match(data, offset).group(1))


def decode_scan_array(block: bytes) -> array:
    type_code = next(code for accession, code in ARRAY_TYPES if accession in block)
    values = array(type_code)
    text = BINARY_TEXT.search(block).group(1)
    raw = base64.b64decode(text) if text else b""
    if raw and b"MS:1000574" in block:
        raw = zlib.decompress(raw)
    values.frombytes(raw)
    if sys.byteorder == "big":
        values.byteswap()
    return values


def parse_scan_spectrum(piece: bytes):
    """(frame, scan, ms level, rt seconds, 1/K0, m/z, intensity) of one spectrum text."""
    match = SCAN_ID.match(b"<spectrum " + piece[:200])
    frame, scan = int(match.group(1)), int(match.group(2))
    level = LEVEL_VALUE.search(piece)
    mobility = MOBILITY_VALUE.search(piece)
    rt = RT_VALUE.search(piece)
    rt_seconds = None
    if rt is not None:
        rt_seconds = float(rt.group(1)) * (60.0 if b"UO:0000031" in rt.group(2) else 1.0)
    mz: Sequence[float] = ()
    intensity: Sequence[float] = ()
    if b'defaultArrayLength="0"' not in piece[:200]:
        for block in ARRAY_BLOCK.findall(piece):
            if b"MS:1000514" in block:
                mz = decode_scan_array(block)
            elif b"MS:1000515" in block:
                intensity = decode_scan_array(block)
        if list(mz) != sorted(mz):
            order = sorted(range(len(mz)), key=mz.__getitem__)
            mz = [mz[i] for i in order]
            intensity = [intensity[i] for i in order]
    return (
        frame, scan, int(level.group(1)) if level else 0, rt_seconds,
        float(mobility.group(1)) if mobility else None, mz, intensity,
    )


def iter_scan_spectra(data: mmap.mmap, start: int, end: int):
    """Spectra of a byte range in file order."""
    for piece in data[start:end].split(SPECTRUM_START)[1:]:
        yield parse_scan_spectrum(piece)


def match_peaks(reference_mz, comparison_mz, ppm_tolerance: float):
    """Greedy ordered matching in ppm; returns matched index pairs and the leftover indices."""
    pairs: List[Tuple[int, int]] = []
    left_over_reference: List[int] = []
    left_over_comparison: List[int] = []
    left = right = 0
    while left < len(reference_mz) and right < len(comparison_mz):
        expected = reference_mz[left]
        difference = comparison_mz[right] - expected
        if abs(difference) <= expected * ppm_tolerance * 1e-6:
            pairs.append((left, right))
            left += 1
            right += 1
        elif difference < 0:
            left_over_comparison.append(right)
            right += 1
        else:
            left_over_reference.append(left)
            left += 1
    left_over_reference.extend(range(left, len(reference_mz)))
    left_over_comparison.extend(range(right, len(comparison_mz)))
    return pairs, left_over_reference, left_over_comparison


def intensity_bin(value: float) -> int:
    return min(INTENSITY_BINS - 1, max(0, int(math.log10(value)) if value >= 1 else 0))


def new_scan_stats() -> Dict[str, float]:
    keys = [
        "spectra", "reference_nonempty", "comparison_nonempty", "both_nonempty", "identical",
        "only_reference", "only_comparison", "reference_peaks", "comparison_peaks", "matched",
        "near_matched", "unmatched_reference", "unmatched_comparison", "ppm_sum", "abs_ppm_sum",
        "int_equal", "int_different", "int_diff_sum", "int_rel_sum", "im_pairs", "im_abs_sum",
        "im_missing", "rt_pairs",
    ]
    stats = {key: 0 for key in keys + list(SCAN_MAX_KEYS)}
    stats["min_diff_int"] = float("inf")
    for side in ("ref", "cmp"):
        for bin_number in range(INTENSITY_BINS):
            stats[f"unmatched_{side}_bin{bin_number}"] = 0
    return stats


def compare_scan_pair(reference, comparison, args, stats, examples) -> Optional[Dict[str, object]]:
    """Update stats with one (frame, scan); return a CSV row if the scans differ."""
    frame, scan, level = (reference or comparison)[:3]
    ref_mz = reference[5] if reference else ()
    ref_int = reference[6] if reference else ()
    cmp_mz = comparison[5] if comparison else ()
    cmp_int = comparison[6] if comparison else ()
    stats["spectra"] += 1
    stats["reference_nonempty"] += bool(ref_mz)
    stats["comparison_nonempty"] += bool(cmp_mz)
    stats["reference_peaks"] += len(ref_mz)
    stats["comparison_peaks"] += len(cmp_mz)
    if ref_mz and cmp_mz:
        stats["both_nonempty"] += 1
    elif ref_mz:
        stats["only_reference"] += 1
    elif cmp_mz:
        stats["only_comparison"] += 1

    pairs, extra_ref, extra_cmp = match_peaks(ref_mz, cmp_mz, args.peak_ppm)
    near_pairs, left_ref, left_cmp = match_peaks(
        [ref_mz[i] for i in extra_ref], [cmp_mz[i] for i in extra_cmp], args.near_ppm
    )
    stats["matched"] += len(pairs)
    stats["near_matched"] += len(near_pairs)
    stats["unmatched_reference"] += len(left_ref)
    stats["unmatched_comparison"] += len(left_cmp)
    for index in near_pairs:
        a, b = ref_mz[extra_ref[index[0]]], cmp_mz[extra_cmp[index[1]]]
        stats["max_near_ppm"] = max(stats["max_near_ppm"], abs(b - a) / a * 1e6)
    max_ppm = max_int_difference = 0.0
    for left, right in pairs:
        ppm = (cmp_mz[right] - ref_mz[left]) / ref_mz[left] * 1e6
        stats["ppm_sum"] += ppm
        stats["abs_ppm_sum"] += abs(ppm)
        max_ppm = max(max_ppm, abs(ppm))
        difference = abs(round(ref_int[left]) - round(cmp_int[right]))
        if difference:
            stats["int_different"] += 1
            stats["int_diff_sum"] += difference
            stats["int_rel_sum"] += difference / max(ref_int[left], 1.0)
            stats["min_diff_int"] = min(stats["min_diff_int"], ref_int[left])
            max_int_difference = max(max_int_difference, difference)
            if len(examples["intensity"]) < 5:
                examples["intensity"].append((frame, scan, level, ref_mz[left], ref_int[left], cmp_int[right]))
        else:
            stats["int_equal"] += 1
    stats["max_abs_ppm"] = max(stats["max_abs_ppm"], max_ppm)
    stats["max_int_diff"] = max(stats["max_int_diff"], max_int_difference)
    for index in left_ref:
        stats[f"unmatched_ref_bin{intensity_bin(ref_int[extra_ref[index]])}"] += 1
        if len(examples["reference_only"]) < 5:
            examples["reference_only"].append((frame, scan, level, ref_mz[extra_ref[index]], ref_int[extra_ref[index]]))
    for index in left_cmp:
        stats[f"unmatched_cmp_bin{intensity_bin(cmp_int[extra_cmp[index]])}"] += 1
        if len(examples["comparison_only"]) < 5:
            examples["comparison_only"].append((frame, scan, level, cmp_mz[extra_cmp[index]], cmp_int[extra_cmp[index]]))

    mobility_difference = ""
    if reference and comparison:
        if reference[4] is None or comparison[4] is None:
            stats["im_missing"] += 1
        else:
            mobility_difference = abs(reference[4] - comparison[4])
            stats["im_pairs"] += 1
            stats["im_abs_sum"] += mobility_difference
            stats["im_max"] = max(stats["im_max"], mobility_difference)
        if reference[3] is not None and comparison[3] is not None:
            stats["rt_pairs"] += 1
            stats["rt_max"] = max(stats["rt_max"], abs(reference[3] - comparison[3]))
    identical = (
        len(ref_mz) == len(cmp_mz) == len(pairs) and not max_int_difference
    )
    stats["identical"] += identical
    if identical:
        return None
    return {
        "frame": frame, "scan": scan, "ms_level": level, "reference_peaks": len(ref_mz),
        "comparison_peaks": len(cmp_mz), "matched": len(pairs), "near_matched": len(near_pairs),
        "unmatched_reference": len(left_ref), "unmatched_comparison": len(left_cmp),
        "max_abs_ppm": max_ppm, "max_abs_intensity_difference": max_int_difference,
        "ion_mobility_difference": mobility_difference,
    }


def process_frame_slice(task):
    """Compare all scans of frames first..last-1 of the two files, paired by native id."""
    first, last, args = task
    data = [open_data(args.reference), open_data(args.comparison)]
    try:
        streams = []
        for handle in data:
            start = frame_offset(handle, first)
            end = frame_offset(handle, last)
            streams.append(iter_scan_spectra(handle, start, end))
        stats: Dict[int, Dict[str, float]] = defaultdict(new_scan_stats)
        examples: Dict[int, Dict[str, list]] = defaultdict(
            lambda: {"intensity": [], "reference_only": [], "comparison_only": []}
        )
        rows: List[Dict[str, object]] = []
        reference, comparison = next(streams[0], None), next(streams[1], None)
        while reference is not None or comparison is not None:
            reference_key = reference[:2] if reference else None
            comparison_key = comparison[:2] if comparison else None
            use_reference = comparison is None or (reference is not None and reference_key <= comparison_key)
            use_comparison = reference is None or (comparison is not None and comparison_key <= reference_key)
            pair = (reference if use_reference else None, comparison if use_comparison else None)
            level = (pair[0] or pair[1])[2]
            row = compare_scan_pair(pair[0], pair[1], args, stats[level], examples[level])
            if row is not None and len(rows) < args.slice_rows:
                rows.append(row)
            if use_reference:
                reference = next(streams[0], None)
            if use_comparison:
                comparison = next(streams[1], None)
    finally:
        for handle in data:
            handle.close()
    return dict(stats), dict(examples), rows


def run_by_id(args) -> None:
    """Pair spectra by their native id (frame=N scan=M) and compare them peak by peak."""
    reference_data, comparison_data = open_data(args.reference), open_data(args.comparison)
    total_frames = max(last_frame(reference_data), last_frame(comparison_data))
    reference_data.close()
    comparison_data.close()
    last_wanted = min(total_frames, args.max_frame) if args.max_frame else total_frames
    ranges = [
        (first, min(first + args.slice_frames, last_wanted + 1), args)
        for first in range(args.min_frame, last_wanted + 1, args.slice_frames)
    ]
    print(f"Pairing by native id: frames {args.min_frame}-{last_wanted} in {len(ranges)} slices on {args.workers} workers", flush=True)

    totals: Dict[int, Dict[str, float]] = defaultdict(new_scan_stats)
    examples_total: Dict[int, Dict[str, list]] = defaultdict(
        lambda: {"intensity": [], "reference_only": [], "comparison_only": []}
    )
    written = 0
    args.output.parent.mkdir(parents=True, exist_ok=True)
    with args.output.open("w", newline="", encoding="utf-8") as report:
        writer = csv.DictWriter(report, fieldnames=SCAN_CSV_FIELDS)
        writer.writeheader()
        with ProcessPoolExecutor(max_workers=args.workers) as executor:
            for index, (part_stats, part_examples, rows) in enumerate(executor.map(process_frame_slice, ranges), 1):
                for level, values in part_stats.items():
                    for key, value in values.items():
                        if key in SCAN_MAX_KEYS:
                            totals[level][key] = max(totals[level][key], value)
                        elif key in SCAN_MIN_KEYS:
                            totals[level][key] = min(totals[level][key], value)
                        else:
                            totals[level][key] += value
                for level, values in part_examples.items():
                    for kind, items in values.items():
                        if len(examples_total[level][kind]) < 5:
                            examples_total[level][kind].extend(items[: 5 - len(examples_total[level][kind])])
                for row in rows:
                    if written < args.max_rows:
                        writer.writerow(row)
                        written += 1
                if index % 25 == 0 or index == len(ranges):
                    print(f"  {index}/{len(ranges)} slices", flush=True)

    print(f"\nReference:  {args.reference.name}\nComparison: {args.comparison.name}")
    print(f"Peaks match within {args.peak_ppm} ppm; leftover peaks are re-matched within {args.near_ppm} ppm ('near')\n")
    print(
        f"{'MS':>3} {'scans':>10} {'ref non-empty':>14} {'cmp non-empty':>14} {'only ref':>9} {'only cmp':>9} "
        f"{'identical':>10}"
    )
    for level in sorted(totals):
        s = totals[level]
        print(
            f"{level:>3} {int(s['spectra']):>10} {int(s['reference_nonempty']):>14} {int(s['comparison_nonempty']):>14} "
            f"{int(s['only_reference']):>9} {int(s['only_comparison']):>9} {int(s['identical']):>10}"
        )
    print(f"\n{'MS':>3} {'ref peaks':>12} {'cmp peaks':>12} {'matched':>12} {'near':>8} {'unm.ref':>9} {'unm.cmp':>9} {'mean ppm':>10} {'|ppm|':>8} {'max|ppm|':>9} {'max near':>9}")
    for level in sorted(totals):
        s = totals[level]
        mean = s["ppm_sum"] / s["matched"] if s["matched"] else float("nan")
        absolute = s["abs_ppm_sum"] / s["matched"] if s["matched"] else float("nan")
        print(
            f"{level:>3} {int(s['reference_peaks']):>12} {int(s['comparison_peaks']):>12} {int(s['matched']):>12} "
            f"{int(s['near_matched']):>8} {int(s['unmatched_reference']):>9} {int(s['unmatched_comparison']):>9} "
            f"{mean:>10.5f} {absolute:>8.5f} {s['max_abs_ppm']:>9.5f} {s['max_near_ppm']:>9.3f}"
        )
    print(f"\n{'MS':>3} {'int equal':>12} {'int differ':>11} {'max |dI|':>9} {'mean |dI|':>10} {'min I that differs':>19}")
    for level in sorted(totals):
        s = totals[level]
        mean_difference = s["int_diff_sum"] / s["int_different"] if s["int_different"] else 0.0
        smallest = s["min_diff_int"] if s["int_different"] else float("nan")
        print(
            f"{level:>3} {int(s['int_equal']):>12} {int(s['int_different']):>11} {int(s['max_int_diff']):>9} "
            f"{mean_difference:>10.3f} {smallest:>19.1f}"
        )
    print(f"\nIon mobility (1/K0) and retention time of paired scans")
    print(f"{'MS':>3} {'IM pairs':>10} {'missing':>8} {'mean|dIM|':>11} {'max|dIM|':>10} {'max|dRT| s':>11}")
    for level in sorted(totals):
        s = totals[level]
        mean_difference = s["im_abs_sum"] / s["im_pairs"] if s["im_pairs"] else float("nan")
        print(
            f"{level:>3} {int(s['im_pairs']):>10} {int(s['im_missing']):>8} {mean_difference:>11.3e} "
            f"{s['im_max']:>10.3e} {s['rt_max']:>11.3e}"
        )
    print("\nUnmatched peaks by intensity decade (counts: 1e0-1e1, 1e1-1e2, ...)")
    for level in sorted(totals):
        s = totals[level]
        for side, label in (("ref", "only in reference"), ("cmp", "only in comparison")):
            counts = [int(s[f"unmatched_{side}_bin{b}"]) for b in range(INTENSITY_BINS)]
            print(f"MS{level} {label:>18}: {counts}")
    for level in sorted(examples_total):
        for kind, items in examples_total[level].items():
            for item in items[:3]:
                print(f"example MS{level} {kind}: frame={item[0]} scan={item[1]} {item[3:]}")
    print(f"\nScan report ({written} differing scans written, limit {args.max_rows}): {args.output}")


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Compare two mzML files at every MS level: MS1 by retention "
        "time, MS2+ by precursor m/z, then peak by peak. With --by-id (or when both "
        "files use 'frame=N scan=M' ids) spectra are paired by native id instead."
    )
    parser.add_argument(
        "--by-id",
        action="store_true",
        help="Pair spectra by native id 'frame=N scan=M' (per-scan timsTOF files); "
        "detected automatically when both files use such ids",
    )
    parser.add_argument("--near-ppm", type=float, default=20.0, help="--by-id: tolerance for classifying leftover peaks as shifted (default: 20)")
    parser.add_argument("--slice-frames", type=int, default=50, help="--by-id: frames per worker task (default: 50)")
    parser.add_argument("--min-frame", type=int, default=1, help="--by-id: first frame to compare")
    parser.add_argument("--max-frame", type=int, default=0, help="--by-id: last frame to compare (default: all)")
    parser.add_argument("--max-rows", type=int, default=1000000, help="--by-id: most differing scans to write (default: 1000000)")
    parser.add_argument("--slice-rows", type=int, default=2000, help=argparse.SUPPRESS)
    parser.add_argument("--reference", type=Path, default=Path(DEFAULT_REFERENCE))
    parser.add_argument("--comparison", type=Path, default=Path(DEFAULT_COMPARISON))
    parser.add_argument(
        "--output",
        type=Path,
        default=Path("mzml_spectrum_comparison.csv"),
        help="CSV report path (default: mzml_spectrum_comparison.csv)",
    )
    parser.add_argument(
        "--rt-tolerance",
        type=float,
        default=0.5,
        help="MS1 retention-time window in seconds, either direction (default: 0.5)",
    )
    parser.add_argument(
        "--ms2-before",
        type=float,
        default=0.5,
        help="MS2+: reference scans up to this many seconds before the comparison "
        "spectrum are merged (default: 0.5)",
    )
    parser.add_argument(
        "--ms2-after",
        type=float,
        default=2.0,
        help="MS2+: reference scans up to this many seconds after the comparison "
        "spectrum are merged (default: 2.0)",
    )
    parser.add_argument(
        "--precursor-ppm",
        type=float,
        default=1.0,
        help="Precursor m/z tolerance for MS2+ pairing in ppm (default: 1)",
    )
    parser.add_argument(
        "--peak-ppm",
        type=float,
        default=1.0,
        help="Fragment/peak m/z tolerance in ppm (default: 1)",
    )
    parser.add_argument(
        "--im-tolerance",
        type=float,
        default=0.02,
        help="Inverse reduced ion mobility (1/K0, V*s/cm2) tolerance for pairing; "
        "only applied when both spectra carry mobility (default: 0.02)",
    )
    parser.add_argument(
        "--collapse-rt",
        type=float,
        default=0.0,
        help="If above 0, collapse comparison MS2+ spectra of one precursor that "
        "differ only by ion mobility when at most this many seconds apart "
        "(default: 0, off)",
    )
    parser.add_argument(
        "--max-rt",
        type=float,
        default=None,
        help="Only compare spectra up to this retention time in seconds",
    )
    parser.add_argument(
        "--workers",
        type=int,
        default=DEFAULT_WORKERS,
        help="Number of worker processes; each handles whole retention-time slices (default: 32)",
    )
    args = parser.parse_args()
    if (
        min(
            args.rt_tolerance,
            args.ms2_before,
            args.ms2_after,
            args.precursor_ppm,
            args.im_tolerance,
            args.collapse_rt,
            args.peak_ppm,
        )
        < 0
    ):
        parser.error("tolerances must be non-negative")
    if args.workers < 1:
        parser.error("--workers must be at least 1")
    for input_path in (args.reference, args.comparison):
        if not input_path.is_file():
            parser.error(f"input file does not exist: {input_path}")
    if args.by_id or all(uses_scan_ids(path) for path in (args.reference, args.comparison)):
        run_by_id(args)
        return

    stats: Dict[int, Dict[str, float]] = defaultdict(new_level_stats)
    collapse_counts: Dict[str, int] = defaultdict(int)
    args.output.parent.mkdir(parents=True, exist_ok=True)

    reference_index = build_index(args.reference)
    comparison_index = build_index(args.comparison)
    slices = plan_slices(reference_index, comparison_index, args)
    print(
        f"Indexed {len(reference_index.offsets) - 1} reference and "
        f"{len(comparison_index.offsets) - 1} comparison spectra; "
        f"{len(slices)} slices on {args.workers} workers",
        flush=True,
    )

    header = io.StringIO()
    csv.DictWriter(header, fieldnames=FIELDNAMES).writeheader()
    unpaired_reference_rows: List[Dict[str, object]] = []
    foreign_touched = set()
    with args.output.open("wb") as report:
        report.write(header.getvalue().encode("utf-8"))
        with ProcessPoolExecutor(
            max_workers=args.workers,
            initializer=init_slice_worker,
            initargs=(reference_index, comparison_index, args),
        ) as executor:
            for _, part_stats, part_counts, rows, foreign, part_path in executor.map(
                process_slice, slices
            ):
                for level, values in part_stats.items():
                    for key, value in values.items():
                        total = stats[level]
                        total[key] = (
                            max(total[key], value)
                            if key in MAX_STAT_KEYS
                            else total[key] + value
                        )
                for key, value in part_counts.items():
                    collapse_counts[key] += value
                unpaired_reference_rows.extend(rows)
                foreign_touched.update(foreign)
                with open(part_path, "rb") as part:
                    shutil.copyfileobj(part, report)
                Path(part_path).unlink()

        # A reference spectrum is unmatched only if no slice paired with it
        report_text = io.StringIO()
        writer = csv.DictWriter(report_text, fieldnames=FIELDNAMES)
        for row in unpaired_reference_rows:
            if row["reference_scan_index"] in foreign_touched:
                continue
            writer.writerow(row)
            stats[row["ms_level"]]["unmatched_reference"] += 1
        report.write(report_text.getvalue().encode("utf-8"))

    print(f"Reference: {args.reference.name}")
    print(f"Comparison: {args.comparison.name}")
    if args.collapse_rt > 0:
        print(
            f"Collapsed mobility: {collapse_counts['input']} comparison spectra -> "
            f"{collapse_counts['groups']} ({collapse_counts['collapsed']} merged "
            f"into groups, gap {args.collapse_rt} s)"
        )
    print(
        f"Pairing: MS1 RT +/-{args.rt_tolerance} s, MS2+ RT -{args.ms2_before}/"
        f"+{args.ms2_after} s, precursor {args.precursor_ppm} ppm, "
        f"1/K0 {args.im_tolerance}, peaks {args.peak_ppm} ppm, workers {args.workers}"
    )
    print()
    header = (
        f"{'MS':>3} {'ref':>8} {'cmp':>8} {'matched':>8} {'unm.ref':>8} {'unm.cmp':>8} "
        f"{'mean cos':>9} {'peak rec':>9} {'mean ppm':>9} {'|ppm|':>7} {'max|ppm|':>9}"
    )
    print(header)
    for level in sorted(stats):
        level_stats = stats[level]
        cosine = (
            level_stats["cosine_sum"] / level_stats["cosine_count"]
            if level_stats["cosine_count"]
            else float("nan")
        )
        recall = (
            level_stats["recall_sum"] / level_stats["matched"]
            if level_stats["matched"]
            else float("nan")
        )
        count = level_stats["ppm_count"]
        signed = level_stats["ppm_sum"] / count if count else float("nan")
        absolute = level_stats["abs_ppm_sum"] / count if count else float("nan")
        print(
            f"{level:>3} {level_stats['reference']:>8} {level_stats['comparison']:>8} "
            f"{level_stats['matched']:>8} {level_stats['unmatched_reference']:>8} "
            f"{level_stats['unmatched_comparison']:>8} {cosine:>9.4f} {recall:>9.4f} "
            f"{signed:>9.4f} {absolute:>7.4f} {level_stats['max_abs_ppm']:>9.4f}"
        )
    print()
    print("peak rec = mean fraction of comparison peaks found in the paired reference")
    print()
    print("Ion mobility (1/K0, V*s/cm2)")
    print(
        f"{'MS':>3} {'ref w/IM':>9} {'cmp w/IM':>9} {'IM pairs':>9} "
        f"{'mean|dIM|':>10} {'max|dIM|':>9}"
    )
    for level in sorted(stats):
        level_stats = stats[level]
        pairs = level_stats["im_pairs"]
        mean_difference = level_stats["im_abs_sum"] / pairs if pairs else float("nan")
        print(
            f"{level:>3} {level_stats['reference_im']:>9} "
            f"{level_stats['comparison_im']:>9} {pairs:>9} "
            f"{mean_difference:>10.5f} {level_stats['im_max']:>9.5f}"
        )
    if not any(level["reference_im"] for level in stats.values()):
        print("Reference has no ion mobility; mobility could not be checked.")
    elif not any(level["comparison_im"] for level in stats.values()):
        print("Comparison has no ion mobility; mobility could not be checked.")
    print(f"Report written to: {args.output}")


if __name__ == "__main__":
    main()
