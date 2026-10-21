# python extractTDF.py "F:\promec\TIMSTOF\LARS\Whale_Mitra27samples_LC-MSMSAugust2024-Feb2025\240819_Mitra_FOC4050_1_Slot2-10_1_8042.d" F:\8042_extracted.mzML
"""Extract centroided MS1 and per-precursor PASEF MS2 spectra from a Bruker timsTOF .d folder.

The spectra are written as a simple mzML file that carries ion mobility (1/K0) for every
spectrum, so that compareMZ.py can compare it with an already converted mzML.

It reads the data with Bruker's own timsdata.dll (shipped with MaxQuant and DIA-NN), loaded
through ctypes, and analysis.tdf through sqlite3. Nothing needs to be installed; numpy is
used for the mobility-weighted mean of MS1 frames.

MS1: one spectrum per frame, centroided over all scans; 1/K0 is the intensity-weighted mean
     over the frame's scans.
MS2: one spectrum per Precursors row (all PASEF scans of that precursor merged and centroided
     by the DLL); the precursor m/z is MonoisotopicMz, or LargestPeakMz if that is missing,
     and 1/K0 is that of Precursors.ScanNumber. Its retention time is that of the parent MS1 frame.
"""

import argparse
import base64
import ctypes
import os
import sqlite3
import struct
import sys
import zlib
from array import array
from collections import deque
from concurrent.futures import ProcessPoolExecutor
from ctypes import CFUNCTYPE, POINTER, c_char_p, c_double, c_float, c_int64, c_uint32, c_uint64, c_void_p
from pathlib import Path
from typing import Dict, List, Sequence, Tuple

DEFAULT_WORKERS = 32
DEFAULT_DLLS = (
    r"C:\Program Files\MaxQuant_v2.8.1.0\bin\timsdata.dll",
    r"C:\Program Files\MaxQuant_v2.7.0.0\bin\timsdata.dll",
    r"C:\Program Files\MaxQuant_v2.6.7.0\bin\timsdata.dll",
)
SPECTRUM_FUNCTOR = CFUNCTYPE(None, c_int64, c_uint32, POINTER(c_double), POINTER(c_float))

# (precursor_id, monoisotopic or else largest-peak m/z, charge or None, scan_number)
PrecursorRow = Tuple[int, float, object, float]
# (frame_id, time_seconds, num_scans, first_spectrum_index, precursors)
FrameJob = Tuple[int, float, int, int, List[PrecursorRow]]

_state: Dict[str, object] = {}


def _load_dll(dll_path: str):
    os.add_dll_directory(os.path.dirname(dll_path))
    dll = ctypes.cdll.LoadLibrary(dll_path)
    conversion = [c_uint64, c_int64, POINTER(c_double), POINTER(c_double), c_uint32]
    dll.tims_open.argtypes = [c_char_p, c_uint32]
    dll.tims_open.restype = c_uint64
    dll.tims_close.argtypes = [c_uint64]
    dll.tims_close.restype = None
    dll.tims_set_num_threads.argtypes = [c_uint32]
    dll.tims_set_num_threads.restype = None
    dll.tims_get_last_error_string.argtypes = [c_char_p, c_uint32]
    dll.tims_get_last_error_string.restype = c_uint32
    dll.tims_extract_centroided_spectrum_for_frame_v2.argtypes = [
        c_uint64, c_int64, c_uint32, c_uint32, SPECTRUM_FUNCTOR, c_void_p,
    ]
    dll.tims_extract_centroided_spectrum_for_frame_v2.restype = c_uint32
    dll.tims_read_pasef_msms.argtypes = [c_uint64, POINTER(c_int64), c_uint32, SPECTRUM_FUNCTOR]
    dll.tims_read_pasef_msms.restype = c_uint32
    dll.tims_read_scans_v2.argtypes = [c_uint64, c_int64, c_uint32, c_uint32, c_void_p, c_uint32]
    dll.tims_read_scans_v2.restype = c_uint32
    dll.tims_scannum_to_oneoverk0.argtypes = conversion
    dll.tims_scannum_to_oneoverk0.restype = c_uint32
    return dll


def _last_error(dll) -> str:
    buffer = ctypes.create_string_buffer(1024)
    dll.tims_get_last_error_string(buffer, 1024)
    return buffer.value.decode(errors="replace")


def _init_worker(dll_path: str, raw_directory: str, recalibrated: bool) -> None:
    import numpy

    dll = _load_dll(dll_path)
    dll.tims_set_num_threads(1)
    handle = dll.tims_open(raw_directory.encode(), 1 if recalibrated else 0)
    if not handle:
        raise RuntimeError(f"Cannot open {raw_directory}: {_last_error(dll)}")
    _state.update(dll=dll, handle=handle, numpy=numpy)


def _one_over_k0(frame_id: int, scans: Sequence[float]) -> List[float]:
    dll, handle = _state["dll"], _state["handle"]
    count = len(scans)
    scan_values = (c_double * count)(*scans)
    result = (c_double * count)()
    if not dll.tims_scannum_to_oneoverk0(handle, frame_id, scan_values, result, count):
        raise RuntimeError(f"1/K0 conversion failed: {_last_error(dll)}")
    return list(result)


def _frame_mobility(frame_id: int, num_scans: int) -> float:
    """Intensity-weighted mean 1/K0 over all scans of one frame; 0.0 if the frame is empty."""
    dll, handle, numpy = _state["dll"], _state["handle"], _state["numpy"]
    buffer = _state.get("scan_buffer")
    if buffer is None:
        buffer = numpy.empty(1 << 21, dtype=numpy.uint32)
    while True:
        needed = dll.tims_read_scans_v2(handle, frame_id, 0, num_scans, buffer.ctypes.data, buffer.nbytes)
        if needed == 0:
            raise RuntimeError(f"Cannot read frame {frame_id}: {_last_error(dll)}")
        if needed <= buffer.nbytes:
            break
        buffer = numpy.empty(needed // 4 + 1, dtype=numpy.uint32)
    _state["scan_buffer"] = buffer
    counts = buffer[:num_scans].astype(numpy.int64)
    # Per scan the buffer holds n TOF indices followed by n intensities
    ends = num_scans + 2 * numpy.cumsum(counts)
    scan_intensity = numpy.zeros(num_scans)
    for scan in numpy.nonzero(counts)[0]:
        end = ends[scan]
        scan_intensity[scan] = buffer[end - counts[scan] : end].sum(dtype=numpy.float64)
    total = scan_intensity.sum()
    if total <= 0:
        return 0.0
    mobility = numpy.array(_one_over_k0(frame_id, [float(s) for s in range(num_scans)]))
    return float((scan_intensity * mobility).sum() / total)


def _encode(values: Sequence[float], typecode: str) -> str:
    data = array(typecode, values)
    if sys.byteorder == "big":
        data.byteswap()
    return base64.b64encode(zlib.compress(data.tobytes(), 1)).decode("ascii")


def _spectrum_xml(
    index: int,
    native_id: str,
    ms_level: int,
    time_seconds: float,
    mobility: float,
    precursor_mz,
    charge,
    scan_number,
    mz: Sequence[float],
    intensity: Sequence[float],
) -> str:
    mz_text = _encode(mz, "d")
    intensity_text = _encode(intensity, "f")
    lines = [
        f'<spectrum index="{index}" id="{native_id}" defaultArrayLength="{len(mz)}">',
        f'<cvParam cvRef="MS" accession="MS:1000511" name="ms level" value="{ms_level}"/>',
        '<cvParam cvRef="MS" accession="MS:1000127" name="centroid spectrum" value=""/>',
        '<scanList count="1"><scan>',
        f'<cvParam cvRef="MS" accession="MS:1000016" name="scan start time" value="{time_seconds:.6f}" unitAccession="UO:0000010" unitName="second"/>',
        f'<cvParam cvRef="MS" accession="MS:1002815" name="inverse reduced ion mobility" value="{mobility:.6f}" unitAccession="MS:1002814" unitName="volt-second per square centimeter"/>',
        "</scan></scanList>",
    ]
    if precursor_mz is not None:
        lines.append("<precursorList count=\"1\"><precursor><selectedIonList count=\"1\"><selectedIon>")
        lines.append(f'<cvParam cvRef="MS" accession="MS:1000744" name="selected ion m/z" value="{precursor_mz!r}" unitAccession="MS:1000040" unitName="m/z"/>')
        if charge is not None:
            lines.append(f'<cvParam cvRef="MS" accession="MS:1000041" name="charge state" value="{int(charge)}"/>')
        lines.append("</selectedIon></selectedIonList></precursor></precursorList>")
    lines += [
        '<binaryDataArrayList count="2">',
        "<binaryDataArray>"
        '<cvParam cvRef="MS" accession="MS:1000514" name="m/z array" value=""/>'
        '<cvParam cvRef="MS" accession="MS:1000523" name="64-bit float" value=""/>'
        '<cvParam cvRef="MS" accession="MS:1000574" name="zlib compression" value=""/>'
        f"<binary>{mz_text}</binary></binaryDataArray>",
        "<binaryDataArray>"
        '<cvParam cvRef="MS" accession="MS:1000515" name="intensity array" value=""/>'
        '<cvParam cvRef="MS" accession="MS:1000521" name="32-bit float" value=""/>'
        '<cvParam cvRef="MS" accession="MS:1000574" name="zlib compression" value=""/>'
        f"<binary>{intensity_text}</binary></binaryDataArray>",
        "</binaryDataArrayList>",
        "</spectrum>",
    ]
    return "\n".join(lines)


def _extract_chunk(jobs: Sequence[FrameJob]) -> Tuple[str, int, int]:
    """Return the mzML text of a run of frames, the MS1 count and the empty-MS2 count."""
    dll, handle = _state["dll"], _state["handle"]
    collected: Dict[int, Tuple[List[float], List[float]]] = {}

    def on_spectrum(identifier, count, mz_pointer, area_pointer):
        collected[identifier] = (list(mz_pointer[:count]), list(area_pointer[:count]))

    callback = SPECTRUM_FUNCTOR(on_spectrum)
    pieces: List[str] = []
    empty = 0
    for frame_id, time_seconds, num_scans, first_index, precursors in jobs:
        collected.clear()
        if not dll.tims_extract_centroided_spectrum_for_frame_v2(
            handle, frame_id, 0, num_scans, callback, None
        ):
            raise RuntimeError(f"Cannot centroid frame {frame_id}: {_last_error(dll)}")
        mz, intensity = collected.get(frame_id, ([], []))
        pieces.append(
            _spectrum_xml(
                first_index, f"frame={frame_id}", 1, time_seconds,
                _frame_mobility(frame_id, num_scans), None, None, None, mz, intensity,
            )
        )
        if not precursors:
            continue
        collected.clear()
        identifiers = (c_int64 * len(precursors))(*[row[0] for row in precursors])
        if not dll.tims_read_pasef_msms(handle, identifiers, len(precursors), callback):
            raise RuntimeError(f"Cannot read PASEF MS/MS of frame {frame_id}: {_last_error(dll)}")
        mobilities = _one_over_k0(frame_id, [row[3] for row in precursors])
        for offset, (precursor_id, largest_mz, charge, scan_number) in enumerate(precursors, 1):
            mz, intensity = collected.get(precursor_id, ([], []))
            empty += not mz
            pieces.append(
                _spectrum_xml(
                    first_index + offset, f"precursor={precursor_id}", 2, time_seconds,
                    mobilities[offset - 1], largest_mz, charge, scan_number, mz, intensity,
                )
            )
    return "\n".join(pieces) + "\n", len(jobs), empty


def _read_jobs(raw_directory: Path, start: float, end: float) -> Tuple[List[FrameJob], int]:
    connection = sqlite3.connect(f"file:{(raw_directory / 'analysis.tdf').as_posix()}?mode=ro", uri=True)
    try:
        frames = connection.execute(
            "SELECT Id, Time, NumScans FROM Frames WHERE MsMsType = 0 AND Time BETWEEN ? AND ? ORDER BY Id",
            (start, end),
        ).fetchall()
        by_parent: Dict[int, List[PrecursorRow]] = {}
        for precursor_id, largest, charge, scan, parent in connection.execute(
            "SELECT Id, COALESCE(MonoisotopicMz, LargestPeakMz), Charge, ScanNumber, Parent FROM Precursors ORDER BY Parent, Id"
        ):
            by_parent.setdefault(parent, []).append((precursor_id, largest, charge, scan))
    finally:
        connection.close()
    jobs: List[FrameJob] = []
    index = 0
    for frame_id, time_seconds, num_scans in frames:
        precursors = by_parent.get(frame_id, [])
        jobs.append((frame_id, time_seconds, num_scans, index, precursors))
        index += 1 + len(precursors)
    return jobs, index


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("raw_directory", type=Path, help="Bruker .d folder")
    parser.add_argument("output", type=Path, help="mzML file to write")
    parser.add_argument("--dll", type=Path, help="timsdata.dll (default: the MaxQuant copy)")
    parser.add_argument("--workers", type=int, default=DEFAULT_WORKERS, help="worker processes (default: 32)")
    parser.add_argument("--chunk", type=int, default=20, help="MS1 frames per task (default: 20)")
    parser.add_argument("--start", type=float, default=0.0, help="first MS1 retention time in seconds")
    parser.add_argument("--end", type=float, default=float("inf"), help="last MS1 retention time in seconds")
    parser.add_argument("--no-recalibration", action="store_true", help="open the data without Bruker's recalibrated state")
    args = parser.parse_args()

    dll_path = args.dll or next((Path(p) for p in DEFAULT_DLLS if Path(p).is_file()), None)
    if dll_path is None or not Path(dll_path).is_file():
        parser.error("timsdata.dll not found; pass --dll")
    if not (args.raw_directory / "analysis.tdf").is_file():
        parser.error(f"no analysis.tdf in {args.raw_directory}")
    if args.workers < 1 or args.chunk < 1:
        parser.error("--workers and --chunk must be at least 1")

    jobs, spectrum_count = _read_jobs(args.raw_directory, args.start, args.end)
    chunks = [jobs[i : i + args.chunk] for i in range(0, len(jobs), args.chunk)]
    args.output.parent.mkdir(parents=True, exist_ok=True)
    ms1 = empty = 0
    with args.output.open("w", encoding="utf-8", newline="\n") as report:
        report.write('<?xml version="1.0" encoding="utf-8"?>\n')
        report.write('<mzML xmlns="http://psi.hupo.org/ms/mzml" version="1.1.0">\n')
        report.write('<cvList count="2"><cv id="MS" fullName="PSI-MS" version="4" URI=""/><cv id="UO" fullName="UO" version="1" URI=""/></cvList>\n')
        report.write(f'<run id="{args.raw_directory.name}"><spectrumList count="{spectrum_count}">\n')
        with ProcessPoolExecutor(
            max_workers=args.workers,
            initializer=_init_worker,
            initargs=(str(dll_path), str(args.raw_directory), not args.no_recalibration),
        ) as executor:
            pending = deque()
            for chunk in chunks:
                pending.append(executor.submit(_extract_chunk, chunk))
                if len(pending) >= args.workers * 2:
                    text, frames, missing = pending.popleft().result()
                    report.write(text)
                    ms1 += frames
                    empty += missing
            while pending:
                text, frames, missing = pending.popleft().result()
                report.write(text)
                ms1 += frames
                empty += missing
        report.write("</spectrumList></run></mzML>\n")
    print(f"Extracted {ms1} MS1 frames and {spectrum_count - ms1} MS2 precursors ({empty} without peaks)")
    print(f"Written to: {args.output}")


if __name__ == "__main__":
    main()
