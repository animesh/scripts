#python checkTTD.py  F:\promec\TIMSTOF\Raw\LARS\250829_rabina #250829_rabina2_dia_Slot1-10_1_10961.d  100.000000  1700.000000     400.0    1201.0
#python checkTTD.py F:\promec\TIMSTOF\Raw\LARS\260827_ChunMei
#                                                 run   fr_mz_low   fr_mz_high  prec_min  prec_max
#   260827_200ngHelaQC_DIA_newQCa_Slot1-54_1_14321.d  100.000549  1700.000000     400.0    1000.0
import sqlite3, glob, pandas as pd, sys

rows = []
for d in glob.glob(f"{sys.argv[1]}/*.d", recursive=False):
    db = f"{d}/analysis.tdf"
    con = sqlite3.connect(db)

    meta = dict(con.execute("SELECT Key,Value FROM GlobalMetadata").fetchall())

    win = con.execute(
        "SELECT MIN(IsolationMz-IsolationWidth/2.0), MAX(IsolationMz+IsolationWidth/2.0) "
        "FROM DiaFrameMsMsWindows"
    ).fetchone()

    # m/z isolation window width and count
    widths = [r[0] for r in con.execute(
        "SELECT DISTINCT IsolationWidth FROM DiaFrameMsMsWindows ORDER BY IsolationWidth"
    ).fetchall()]
    n_windows = con.execute(
        "SELECT COUNT(DISTINCT WindowGroup) FROM DiaFrameMsMsWindows"
    ).fetchone()[0]

    # Cycle time: time between consecutive DIA cycle starts
    # One cycle = one full set of DIA windows (n_windows MS2 frames + 1 MS1 frame)
    # Use frame timestamps (in seconds) from Frames table
    frame_times = con.execute(
        "SELECT Time FROM Frames WHERE MsMsType=9 ORDER BY Time"  # MsMsType 9 = dia-PASEF
    ).fetchall()
    if len(frame_times) > n_windows:
        # Estimate cycle time from median gap between frames n_windows apart
        import statistics
        gaps = [frame_times[i+n_windows][0] - frame_times[i][0]
                for i in range(len(frame_times) - n_windows)]
        cycle_time_s = statistics.median(gaps)
    else:
        cycle_time_s = None

    total_time_s = None
    if frame_times:
        total_time_s = round(frame_times[-1][0] - frame_times[0][0], 1)

    con.close()

    # Suggested --window: assume ~20s average peak width (adjust if known)
    # scan_window = round(peak_width_s / cycle_time_s)
    peak_width_s = 20  # typical for timsTOF diaPASEF; adjust per gradient
    scan_window_est = round(peak_width_s / cycle_time_s) if cycle_time_s else None

    rows.append({
        "run":            d.split("\\")[-1],
        "instrument":     meta.get("InstrumentName", meta.get("Description", "?")),
        "fr_mz_low":      meta.get("MzAcqRangeLower"),
        "fr_mz_high":     meta.get("MzAcqRangeUpper"),
        "prec_min":       round(win[0], 1) if win[0] else None,
        "prec_max":       round(win[1], 1) if win[1] else None,
        "win_width_mz":   widths[0] if len(set(widths))==1 else str(widths),
        "n_windows":      n_windows,
        "cycle_time_s":   round(cycle_time_s, 2) if cycle_time_s else None,
        "total_time_min": round(total_time_s/60, 1) if total_time_s else None,
        "--window_est":   scan_window_est,  # assumes 20s peak width
    })

print(pd.DataFrame(rows).to_string())