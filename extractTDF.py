# python extractTDF.py "F:\promec\TIMSTOF\LARS\Whale_Mitra27samples_LC-MSMSAugust2024-Feb2025\240819_Mitra_FOC4050_1_Slot2-10_1_8042.d" F:\240819_Mitra_FOC4050_1_Slot2-10_1_8042.mgf --mgf --workers 32 
"""Lossless mzML export of a Bruker timsTOF .d folder, without timsdata.dll.

analysis.tdf is read with sqlite3 and analysis.tdf_bin is decoded directly (zstd frames,
byte-plane shuffled 32-bit integers). Needs numpy and zstandard (pip install zstandard).

One spectrum is written per (frame, scan), named "frame=N scan=M" (M is the 1-based scan
number) like the ProteoWizard conversion, so the two files can be compared one to one.
Every spectrum keeps everything stored in the raw file:
  - m/z array (64-bit float), computed from the TOF index with the MzCalibration table
    (including the T1/T2 temperature terms)
  - intensity array (raw 32-bit integer counts, nothing is rescaled)
  - "raw TOF index" array (32-bit integer), the value the m/z was calculated from
  - 1/K0 (MS:1002815) of the scan, computed from the TimsCalibration table
  - retention time in seconds, polarity, MS level
  - for PASEF MS2 scans inside an isolation range: precursor id, isolation window,
    selected ion m/z, charge, intensity and collision energy
Scans without peaks carry no information beyond their 1/K0 and are skipped unless
--keep-empty is given (then the spectrum count equals frames x scans, as in ProteoWizard).

With --mgf an MGF file is written instead: one entry per PASEF MS2 (frame, scan) that lies in an
isolation window (TITLE, PEPMASS, CHARGE, RTINSECONDS, ION_MOBILITY, isolation and collision
energy, SCANS=frame.scan). MS1 and the TOF index are not part of MGF.

Calibration formulas (derived from the tables, checked against Bruker's library):
  sqrt(m/z) = sqrt(C1') * 1e-6 * (DigitizerDelay + tof * DigitizerTimebase - C0)
  C1' = C1 * (1 - dC1 * 1e-6 * (T1 - T1cal) - dC2 * 1e-6 * (T2 - T2cal))
  voltage   = C2 + (C3 - C2) * (scan - C0 - C4) / C1        (TimsCalibration, scan is 0-based)
  1/K0      = voltage / (C7 + C6 * voltage)
"""

import argparse
import base64
import sqlite3
import struct
import sys
import zlib
from collections import deque
from concurrent.futures import ProcessPoolExecutor
from pathlib import Path
from typing import Dict, List, Optional, Sequence, Tuple

import numpy as np

try:
    import zstandard
except ImportError:
    sys.exit("zstandard is required: pip install zstandard")

DEFAULT_WORKERS = 32

_state: Dict[str, object] = {}


class Calibration:
    """m/z and 1/K0 conversion built from the MzCalibration and TimsCalibration tables."""

    def __init__(self, mz_rows: Dict[int, tuple], tims_rows: Dict[int, tuple]):
        self.mz_rows = mz_rows
        self.tims_rows = tims_rows
        self._mobility: Dict[Tuple[int, int], np.ndarray] = {}

    def mz(self, cal_id: int, t1: float, t2: float, tof: np.ndarray) -> np.ndarray:
        _, _, timebase, delay, t1_cal, t2_cal, dc1, dc2, c0, c1, *_ = self.mz_rows[cal_id]
        c1 = c1 * (1.0 - dc1 * 1e-6 * (t1 - t1_cal) - dc2 * 1e-6 * (t2 - t2_cal))
        root = np.sqrt(c1) * 1e-6 * (delay + tof * timebase - c0)
        return root * root

    def mobility(self, cal_id: int, num_scans: int) -> np.ndarray:
        key = (cal_id, num_scans)
        if key not in self._mobility:
            _, _, c0, c1, c2, c3, c4, _, c6, c7, *_ = self.tims_rows[cal_id]
            scans = np.arange(num_scans, dtype=np.float64)
            voltage = c2 + (c3 - c2) * (scans - c0 - c4) / c1
            self._mobility[key] = voltage / (c7 + c6 * voltage)
        return self._mobility[key]


def decode_frame(blob: bytes, num_scans: int) -> Tuple[np.ndarray, np.ndarray, np.ndarray]:
    """Return per-scan peak counts, absolute TOF indices and intensities of one frame."""
    length, header_scans = struct.unpack_from("<II", blob, 0)
    if header_scans != num_scans:
        raise ValueError(f"frame has {header_scans} scans, expected {num_scans}")
    if length <= 8:
        empty = np.zeros(0, dtype=np.int64)
        return np.zeros(num_scans, dtype=np.int64), empty, empty
    raw = _state["zstd"].decompress(blob[8:length])
    planes = np.frombuffer(raw, dtype=np.uint8)
    ints = planes.reshape(4, planes.size // 4).T.copy().view("<u4").ravel().astype(np.int64)
    peaks = ints[num_scans:]
    counts = np.empty(num_scans, dtype=np.int64)
    # u[0] holds the scan count; u[1:num_scans] are the value counts (2 per peak) of scans 0..n-2
    counts[: num_scans - 1] = ints[1:num_scans]
    counts[num_scans - 1] = peaks.size - counts[: num_scans - 1].sum()
    counts //= 2
    deltas = peaks[0::2]
    intensities = peaks[1::2]
    tof = np.empty_like(deltas)
    start = 0
    for scan, n in enumerate(counts):
        if n:
            tof[start : start + n] = np.cumsum(deltas[start : start + n]) - 1
            start += n
    return counts, tof, intensities


def _array(name_accession: str, name: str, dtype: str, values: np.ndarray, extra: str = "") -> str:
    kind = {
        "f8": ("MS:1000523", "64-bit float"),
        "f4": ("MS:1000521", "32-bit float"),
        "i4": ("MS:1000519", "32-bit integer"),
    }[dtype]
    data = base64.b64encode(zlib.compress(np.ascontiguousarray(values, dtype="<" + dtype).tobytes(), 3)).decode()
    return (
        "<binaryDataArray>"
        f'<cvParam cvRef="MS" accession="{name_accession}" name="{name}" value=""/>'
        f'{extra}<cvParam cvRef="MS" accession="{kind[0]}" name="{kind[1]}" value=""/>'
        '<cvParam cvRef="MS" accession="MS:1000574" name="zlib compression" value=""/>'
        f"<binary>{data}</binary></binaryDataArray>"
    )


def _spectrum(
    frame: int, scan: int, ms_level: int, polarity: str, time_seconds: float, mobility: float,
    mz: np.ndarray, intensity: np.ndarray, tof: np.ndarray, precursor: Optional[tuple],
) -> str:
    n = mz.size
    parts = [
        f' id="frame={frame} scan={scan + 1}" defaultArrayLength="{n}">',
        f'<cvParam cvRef="MS" accession="MS:1000511" name="ms level" value="{ms_level}"/>',
        '<cvParam cvRef="MS" accession="MS:1000127" name="centroid spectrum" value=""/>',
    ]
    if polarity == "-":
        parts.append('<cvParam cvRef="MS" accession="MS:1000129" name="negative scan" value=""/>')
    else:
        parts.append('<cvParam cvRef="MS" accession="MS:1000130" name="positive scan" value=""/>')
    if n:
        base = int(np.argmax(intensity))
        parts.append(f'<cvParam cvRef="MS" accession="MS:1000528" name="lowest observed m/z" value="{mz.min()!r}" unitCvRef="MS" unitAccession="MS:1000040" unitName="m/z"/>')
        parts.append(f'<cvParam cvRef="MS" accession="MS:1000527" name="highest observed m/z" value="{mz.max()!r}" unitCvRef="MS" unitAccession="MS:1000040" unitName="m/z"/>')
        parts.append(f'<cvParam cvRef="MS" accession="MS:1000504" name="base peak m/z" value="{mz[base]!r}" unitCvRef="MS" unitAccession="MS:1000040" unitName="m/z"/>')
        parts.append(f'<cvParam cvRef="MS" accession="MS:1000505" name="base peak intensity" value="{int(intensity[base])}" unitCvRef="MS" unitAccession="MS:1000131" unitName="number of detector counts"/>')
        parts.append(f'<cvParam cvRef="MS" accession="MS:1000285" name="total ion current" value="{int(intensity.sum())}"/>')
    parts.append(
        '<scanList count="1"><cvParam cvRef="MS" accession="MS:1000795" name="no combination" value=""/><scan>'
        f'<cvParam cvRef="MS" accession="MS:1000016" name="scan start time" value="{time_seconds!r}" unitCvRef="UO" unitAccession="UO:0000010" unitName="second"/>'
        f'<cvParam cvRef="MS" accession="MS:1002815" name="inverse reduced ion mobility" value="{mobility!r}" unitCvRef="MS" unitAccession="MS:1002814" unitName="volt-second per square centimeter"/>'
        "</scan></scanList>"
    )
    if precursor is not None:
        precursor_id, iso_mz, iso_width, energy, selected_mz, charge, precursor_intensity = precursor
        half = iso_width / 2.0
        parts.append(
            '<precursorList count="1"><precursor>'
            "<isolationWindow>"
            f'<cvParam cvRef="MS" accession="MS:1000827" name="isolation window target m/z" value="{iso_mz!r}" unitCvRef="MS" unitAccession="MS:1000040" unitName="m/z"/>'
            f'<cvParam cvRef="MS" accession="MS:1000828" name="isolation window lower offset" value="{half!r}" unitCvRef="MS" unitAccession="MS:1000040" unitName="m/z"/>'
            f'<cvParam cvRef="MS" accession="MS:1000829" name="isolation window upper offset" value="{half!r}" unitCvRef="MS" unitAccession="MS:1000040" unitName="m/z"/>'
            "</isolationWindow>"
            '<selectedIonList count="1"><selectedIon>'
            f'<cvParam cvRef="MS" accession="MS:1000744" name="selected ion m/z" value="{selected_mz!r}" unitCvRef="MS" unitAccession="MS:1000040" unitName="m/z"/>'
        )
        if charge:
            parts.append(f'<cvParam cvRef="MS" accession="MS:1000041" name="charge state" value="{int(charge)}"/>')
        if precursor_intensity is not None:
            parts.append(f'<cvParam cvRef="MS" accession="MS:1000042" name="peak intensity" value="{precursor_intensity!r}"/>')
        parts.append(f'<userParam name="Precursors.Id" value="{precursor_id}"/>')
        parts.append(
            "</selectedIon></selectedIonList>"
            "<activation>"
            '<cvParam cvRef="MS" accession="MS:1000422" name="beam-type collision-induced dissociation" value=""/>'
            f'<cvParam cvRef="MS" accession="MS:1000045" name="collision energy" value="{energy!r}" unitCvRef="UO" unitAccession="UO:0000266" unitName="electronvolt"/>'
            "</activation></precursor></precursorList>"
        )
    intensity_type = "i4" if (n == 0 or intensity.max() < 2**31) else "f8"
    parts.append(
        '<binaryDataArrayList count="3">'
        + _array("MS:1000514", "m/z array", "f8", mz, "")
        + _array("MS:1000515", "intensity array", "i4" if intensity_type == "i4" else "f8", intensity)
        + _array("MS:1000786", "non-standard data array", "i4", tof, '<userParam name="raw TOF index" value=""/>')
        + "</binaryDataArrayList></spectrum>\n"
    )
    return "".join(parts)


def _mgf_entry(
    frame: int, scan: int, polarity: str, time_seconds: float, mobility: float,
    mz: np.ndarray, intensity: np.ndarray, precursor: tuple, name: str,
) -> str:
    precursor_id, iso_mz, iso_width, energy, selected_mz, charge, precursor_intensity = precursor
    lines = [
        "BEGIN IONS",
        f"TITLE={name}.frame={frame}.scan={scan + 1}.precursor={precursor_id}",
        f"PEPMASS={selected_mz!r}" + (f" {precursor_intensity!r}" if precursor_intensity is not None else ""),
    ]
    if charge:
        lines.append(f"CHARGE={int(charge)}{'-' if polarity == '-' else '+'}")
    lines += [
        f"RTINSECONDS={time_seconds!r}",
        f"ION_MOBILITY={mobility!r}",
        f"ISOLATION_MZ={iso_mz!r}",
        f"ISOLATION_WIDTH={iso_width!r}",
        f"COLLISION_ENERGY={energy!r}",
        f"SCANS={frame}.{scan + 1}",
    ]
    lines += [f"{m!r} {int(i)}" for m, i in zip(mz.tolist(), intensity.tolist())]
    lines.append("END IONS\n")
    return "\n".join(lines)


def _init_worker(raw_directory: str):
    directory = Path(raw_directory)
    connection = sqlite3.connect(f"file:{(directory / 'analysis.tdf').as_posix()}?mode=ro", uri=True)
    mz_rows = {r[0]: r for r in connection.execute("SELECT * FROM MzCalibration")}
    tims_rows = {r[0]: r for r in connection.execute("SELECT * FROM TimsCalibration")}
    connection.close()
    _state["calibration"] = Calibration(mz_rows, tims_rows)
    _state["zstd"] = zstandard.ZstdDecompressor()
    _state["bin"] = open(directory / "analysis.tdf_bin", "rb")


def _extract_chunk(jobs: Sequence[tuple], keep_empty: bool, mgf_name: Optional[str] = None) -> Tuple[List[str], int]:
    """Return the spectrum texts (mzML without the index attribute, or MGF entries) of a run of frames."""
    calibration: Calibration = _state["calibration"]
    stream = _state["bin"]
    pieces: List[str] = []
    for frame, time_seconds, polarity, ms_level, num_scans, tims_id, t1, t2, mz_cal, tims_cal, windows in jobs:
        if mgf_name is not None and not windows:
            continue
        stream.seek(tims_id)
        header = stream.read(8)
        length = struct.unpack_from("<I", header, 0)[0]
        counts, tof, intensity = decode_frame(header + stream.read(length - 8), num_scans)
        mz = calibration.mz(mz_cal, t1, t2, tof.astype(np.float64))
        mobility = calibration.mobility(tims_cal, num_scans)
        ends = np.cumsum(counts)
        for scan in range(num_scans):
            n = int(counts[scan])
            if n == 0 and not keep_empty:
                continue
            lo, hi = int(ends[scan] - n), int(ends[scan])
            precursor = None
            for begin, end, row in windows:
                if begin <= scan <= end:
                    precursor = row
                    break
            if mgf_name is not None:
                if precursor is not None and n:
                    pieces.append(
                        _mgf_entry(
                            frame, scan, polarity, time_seconds, float(mobility[scan]),
                            mz[lo:hi], intensity[lo:hi], precursor, mgf_name,
                        )
                    )
                continue
            pieces.append(
                _spectrum(
                    frame, scan, ms_level, polarity, time_seconds, float(mobility[scan]),
                    mz[lo:hi], intensity[lo:hi], tof[lo:hi], precursor,
                )
            )
    return pieces, len(jobs)


def _read_jobs(raw_directory: Path, first: int, last: int) -> List[tuple]:
    connection = sqlite3.connect(f"file:{(raw_directory / 'analysis.tdf').as_posix()}?mode=ro", uri=True)
    try:
        windows: Dict[int, List[tuple]] = {}
        query = (
            "SELECT p.Frame, p.ScanNumBegin, p.ScanNumEnd, p.IsolationMz, p.IsolationWidth, p.CollisionEnergy, "
            "p.Precursor, COALESCE(r.MonoisotopicMz, r.LargestPeakMz), r.Charge, r.Intensity "
            "FROM PasefFrameMsMsInfo p LEFT JOIN Precursors r ON r.Id = p.Precursor ORDER BY p.Frame, p.ScanNumBegin"
        )
        for frame, begin, end, iso_mz, width, energy, precursor_id, selected, charge, level in connection.execute(query):
            row = (precursor_id, iso_mz, width, energy, iso_mz if selected is None else selected, charge, level)
            windows.setdefault(frame, []).append((begin, end, row))
        frames = connection.execute(
            "SELECT Id, Time, Polarity, MsMsType, NumScans, TimsId, T1, T2, MzCalibration, TimsCalibration "
            "FROM Frames WHERE Id BETWEEN ? AND ? ORDER BY Id",
            (first, last),
        ).fetchall()
    finally:
        connection.close()
    jobs = []
    for frame, time_seconds, polarity, msms_type, num_scans, tims_id, t1, t2, mz_cal, tims_cal in frames:
        ms_level = 1 if msms_type == 0 else 2
        jobs.append((frame, time_seconds, polarity, ms_level, num_scans, tims_id, t1, t2, mz_cal, tims_cal, windows.get(frame, [])))
    return jobs


def _header(name: str, count_text: str) -> str:
    return (
        '<?xml version="1.0" encoding="utf-8"?>\n'
        '<mzML xmlns="http://psi.hupo.org/ms/mzml" version="1.1.0">\n'
        '<cvList count="2"><cv id="MS" fullName="Proteomics Standards Initiative Mass Spectrometry Ontology" version="4.1.0" URI=""/>'
        '<cv id="UO" fullName="Unit Ontology" version="1" URI=""/></cvList>\n'
        '<fileDescription><fileContent><cvParam cvRef="MS" accession="MS:1000579" name="MS1 spectrum" value=""/>'
        '<cvParam cvRef="MS" accession="MS:1000580" name="MSn spectrum" value=""/></fileContent></fileDescription>\n'
        '<softwareList count="1"><software id="extractTDF" version="2.0"><userParam name="extractTDF.py (direct analysis.tdf reader)" value=""/></software></softwareList>\n'
        '<instrumentConfigurationList count="1"><instrumentConfiguration id="IC1"><cvParam cvRef="MS" accession="MS:1000031" name="instrument model" value=""/></instrumentConfiguration></instrumentConfigurationList>\n'
        '<dataProcessingList count="1"><dataProcessing id="extract"><processingMethod order="0" softwareRef="extractTDF"><userParam name="lossless TDF to mzML" value=""/></processingMethod></dataProcessing></dataProcessingList>\n'
        f'<run id="{name}" defaultInstrumentConfigurationRef="IC1"><spectrumList count="{count_text}" defaultDataProcessingRef="extract">\n'
    )


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("raw_directory", type=Path, help="Bruker .d folder")
    parser.add_argument("output", type=Path, help="mzML (or, with --mgf, MGF) file to write")
    parser.add_argument("--mgf", action="store_true", help="write MGF instead of mzML: one entry per PASEF MS2 (frame, scan) inside an isolation window; MS1 is not written")
    parser.add_argument("--workers", type=int, default=DEFAULT_WORKERS, help="worker processes (default: 32)")
    parser.add_argument("--chunk", type=int, default=8, help="frames per task (default: 8)")
    parser.add_argument("--first-frame", type=int, default=1, help="first frame id (default: 1)")
    parser.add_argument("--last-frame", type=int, default=2**31 - 1, help="last frame id (default: all)")
    parser.add_argument("--keep-empty", action="store_true", help="also write scans without peaks")
    args = parser.parse_args()

    if not (args.raw_directory / "analysis.tdf").is_file() or not (args.raw_directory / "analysis.tdf_bin").is_file():
        parser.error(f"analysis.tdf and analysis.tdf_bin are needed in {args.raw_directory}")
    if args.workers < 1 or args.chunk < 1:
        parser.error("--workers and --chunk must be at least 1")

    connection = sqlite3.connect(f"file:{(args.raw_directory / 'analysis.tdf').as_posix()}?mode=ro", uri=True)
    compression = connection.execute("SELECT Value FROM GlobalMetadata WHERE Key = 'TimsCompressionType'").fetchone()
    connection.close()
    if compression is None or compression[0] != "2":
        parser.error(f"only TimsCompressionType 2 (zstd) is supported, found {compression}")

    jobs = _read_jobs(args.raw_directory, args.first_frame, args.last_frame)
    chunks = [jobs[i : i + args.chunk] for i in range(0, len(jobs), args.chunk)]
    args.output.parent.mkdir(parents=True, exist_ok=True)
    spectra = 0
    frames_done = 0
    placeholder = "0" * 12
    if args.mgf:
        name = args.raw_directory.stem
        entries = 0
        with args.output.open("w", encoding="utf-8", newline="\n") as report, ProcessPoolExecutor(
            max_workers=args.workers, initializer=_init_worker, initargs=(str(args.raw_directory),)
        ) as executor:
            pending = deque()

            def drain() -> None:
                nonlocal entries, frames_done
                texts, count = pending.popleft().result()
                report.writelines(texts)
                entries += len(texts)
                frames_done += count

            for chunk in chunks:
                pending.append(executor.submit(_extract_chunk, chunk, args.keep_empty, name))
                if len(pending) >= args.workers * 2:
                    drain()
            while pending:
                drain()
        print(f"Wrote {entries} MGF entries from {frames_done} frames to {args.output}")
        return
    with args.output.open("w", encoding="utf-8", newline="\n") as report:
        report.write(_header(args.raw_directory.name.removesuffix(".d") if hasattr(str, "removesuffix") else args.raw_directory.stem, placeholder))
        count_position = report.tell() - len(placeholder) - len('" defaultDataProcessingRef="extract">\n')

        def write(result: Tuple[List[str], int]) -> None:
            nonlocal spectra, frames_done
            for text in result[0]:
                report.write(f'<spectrum index="{spectra}"{text}')
                spectra += 1
            frames_done += result[1]

        with ProcessPoolExecutor(
            max_workers=args.workers, initializer=_init_worker, initargs=(str(args.raw_directory),)
        ) as executor:
            pending = deque()
            for chunk in chunks:
                pending.append(executor.submit(_extract_chunk, chunk, args.keep_empty))
                if len(pending) >= args.workers * 2:
                    write(pending.popleft().result())
            while pending:
                write(pending.popleft().result())
        report.write("</spectrumList></run></mzML>\n")
    with args.output.open("r+b") as patch:
        patch.seek(count_position)
        patch.write(f"{spectra:012d}".encode())
    print(f"Wrote {spectra} spectra from {frames_done} frames to {args.output}")


if __name__ == "__main__":
    main()
