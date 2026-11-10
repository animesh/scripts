#python checkTTD.py  F:\promec\TIMSTOF\Raw\LARS\250829_rabina #250829_rabina2_dia_Slot1-10_1_10961.d  100.000000  1700.000000     400.0    1201.0
#python checkTTD.py F:\promec\TIMSTOF\Raw\LARS\260827_ChunMei
#                                                 run   fr_mz_low   fr_mz_high  prec_min  prec_max
#   260827_200ngHelaQC_DIA_newQCa_Slot1-54_1_14321.d  100.000549  1700.000000     400.0    1000.0
# python checkTTD.py <folder_with_.d_files>
# Probes Bruker TDF databases in all .d subfolders.
# Detects diaPASEF and ddaPASEF, extracts acquisition parameters,
# ion counts per 100 m/z bin (0-2000, always), and saves a TSV.
import sqlite3, glob, pandas as pd, sys, statistics, os
from collections import defaultdict

ALL_BINS = list(range(0, 2000, 100))  # 0,100,200,...,1900 -> 20 bins covering 0-2000

def get_tables(con):
    return {r[0] for r in con.execute(
        "SELECT name FROM sqlite_master WHERE type='table'"
    ).fetchall()}

def detect_mode(con, tables):
    dia_wins = con.execute("SELECT COUNT(*) FROM DiaFrameMsMsWindows").fetchone()[0]
    if dia_wins > 0:
        return 'diaPASEF'
    if 'PasefFrameMsMsInfo' in tables:
        dda_rows = con.execute("SELECT COUNT(*) FROM PasefFrameMsMsInfo").fetchone()[0]
        if dda_rows > 0:
            return 'ddaPASEF'
    return 'UNKNOWN'

def extract_dia(con):
    pr_min, pr_max, n_groups, n_win_total = con.execute("""
        SELECT MIN(IsolationMz - IsolationWidth/2.0),
               MAX(IsolationMz + IsolationWidth/2.0),
               COUNT(DISTINCT WindowGroup),
               COUNT(*)
        FROM DiaFrameMsMsWindows
    """).fetchone()

    windows = con.execute("""
        SELECT WindowGroup, IsolationMz, ScanNumBegin, ScanNumEnd, IsolationWidth
        FROM DiaFrameMsMsWindows ORDER BY WindowGroup, ScanNumBegin
    """).fetchall()

    unique_widths = sorted({w[4] for w in windows})
    win_width = unique_widths[0] if len(unique_widths) == 1 else f"variable:{unique_widths}"

    group_total_scans = defaultdict(int)
    for wg, mz, sb, se, _ in windows:
        group_total_scans[wg] += se - sb
    group_fracs = defaultdict(list)
    for wg, mz, sb, se, _ in windows:
        frac = (se - sb) / group_total_scans[wg] if group_total_scans[wg] else 0
        group_fracs[wg].append((mz, frac))

    ms2_times = [r[0] for r in con.execute(
        "SELECT Time FROM Frames WHERE MsMsType=9 ORDER BY Time"
    ).fetchall()]
    cycle_time_s = None
    if len(ms2_times) > n_groups:
        gaps = [ms2_times[i+n_groups] - ms2_times[i]
                for i in range(len(ms2_times) - n_groups)]
        cycle_time_s = statistics.median(gaps)

    pr_bin_peaks = defaultdict(float)
    for wg, num_peaks in con.execute("""
        SELECT m.WindowGroup, f.NumPeaks
        FROM DiaFrameMsMsInfo m
        JOIN Frames f ON f.Id = m.Frame
        WHERE f.MsMsType = 9
    """).fetchall():
        for mz, frac in group_fracs[wg]:
            pr_bin_peaks[int(mz // 100) * 100] += num_peaks * frac

    return {
        'pr_min':        round(pr_min, 1) if pr_min else None,
        'pr_max':        round(pr_max, 1) if pr_max else None,
        'win_width_mz':  win_width,
        'n_win_groups':  n_groups,
        'win_per_group': n_win_total // n_groups if n_groups else None,
        'cycle_time_s':  cycle_time_s,
        'n_precursors':  None,
        'avg_prec_cycle':None,
        'charges':       None,
        'pr_bin_peaks':  pr_bin_peaks,
    }

def extract_dda(con):
    pr_min, pr_max = con.execute("""
        SELECT MIN(IsolationMz - IsolationWidth/2.0),
               MAX(IsolationMz + IsolationWidth/2.0)
        FROM PasefFrameMsMsInfo
    """).fetchone()

    w_min, w_max, w_med = con.execute("""
        SELECT MIN(IsolationWidth), MAX(IsolationWidth), AVG(IsolationWidth)
        FROM PasefFrameMsMsInfo
    """).fetchone()
    win_width = f"{w_min:.1f}-{w_max:.1f}(med:{w_med:.1f})"

    ms1_times = [r[0] for r in con.execute(
        "SELECT Time FROM Frames WHERE MsMsType=0 ORDER BY Time"
    ).fetchall()]
    cycle_time_s = None
    if len(ms1_times) > 1:
        gaps = [ms1_times[i+1] - ms1_times[i] for i in range(len(ms1_times)-1)]
        cycle_time_s = statistics.median(gaps)

    n_precursors = con.execute("SELECT COUNT(*) FROM Precursors").fetchone()[0]
    avg_prec_cycle = round(n_precursors / len(ms1_times), 1) if ms1_times else None

    charges = dict(con.execute("""
        SELECT Charge, COUNT(*) FROM Precursors
        WHERE Charge IS NOT NULL GROUP BY Charge ORDER BY Charge
    """).fetchall())

    pr_bin_peaks = defaultdict(float)
    for mz, sb, se, num_peaks, num_scans in con.execute("""
        SELECT p.IsolationMz, p.ScanNumBegin, p.ScanNumEnd,
               f.NumPeaks, f.NumScans
        FROM PasefFrameMsMsInfo p
        JOIN Frames f ON f.Id = p.Frame
        WHERE f.MsMsType = 8 AND f.NumScans > 0
    """).fetchall():
        frac = (se - sb) / num_scans
        pr_bin_peaks[int(mz // 100) * 100] += num_peaks * frac

    return {
        'pr_min':        round(pr_min, 1) if pr_min else None,
        'pr_max':        round(pr_max, 1) if pr_max else None,
        'win_width_mz':  win_width,
        'n_win_groups':  None,
        'win_per_group': None,
        'cycle_time_s':  cycle_time_s,
        'n_precursors':  n_precursors,
        'avg_prec_cycle':avg_prec_cycle,
        'charges':       '+'.join(f"z{k}:{v}" for k, v in charges.items()),
        'pr_bin_peaks':  pr_bin_peaks,
    }

def extract_tdf(db_path):
    con = sqlite3.connect(db_path)
    tables = get_tables(con)
    mode = detect_mode(con, tables)

    meta = dict(con.execute("SELECT Key, Value FROM GlobalMetadata").fetchall())

    frames = {}
    for mstype, n, peaks, intensity, t_start, t_end in con.execute("""
        SELECT MsMsType, COUNT(*), SUM(NumPeaks), SUM(SummedIntensities),
               MIN(Time), MAX(Time)
        FROM Frames GROUP BY MsMsType
    """).fetchall():
        frames[mstype] = {
            'n': n, 'peaks': peaks, 'intensity': intensity,
            't_start': t_start, 't_end': t_end
        }

    cal_info = dict(con.execute(
        "SELECT KeyName, Value FROM CalibrationInfo WHERE KeyPolarity='+'"
    ).fetchall())

    if mode == 'diaPASEF':
        mode_info = extract_dia(con)
        ms2_mstype = 9
    elif mode == 'ddaPASEF':
        mode_info = extract_dda(con)
        ms2_mstype = 8
    else:
        mode_info = {k: None for k in [
            'pr_min','pr_max','win_width_mz','n_win_groups','win_per_group',
            'cycle_time_s','n_precursors','avg_prec_cycle','charges','pr_bin_peaks'
        ]}
        mode_info['pr_bin_peaks'] = {}
        ms2_mstype = None

    con.close()

    ms1 = frames.get(0, {})
    ms2 = frames.get(ms2_mstype, {}) if ms2_mstype else {}
    tt  = ms2.get('t_end', 0) - ms2.get('t_start', 0) if ms2 else None

    return {
        'mode':         mode,
        'meta':         meta,
        'ms1':          ms1,
        'ms2':          ms2,
        'total_time_s': tt,
        'cal_info':     cal_info,
        **mode_info,
    }

# --- main ---
folder = sys.argv[1]
rows = []

for d in sorted(glob.glob(f"{folder}/*.d", recursive=False)):
    try:
        info = extract_tdf(f"{d}/analysis.tdf")
    except Exception as e:
        print(f"SKIP {d}: {e}")
        continue

    meta = info['meta']
    ms1  = info['ms1']
    ms2  = info['ms2']
    ct   = info['cycle_time_s']
    tt   = info['total_time_s']

    row = {
        'run':           os.path.basename(d),
        'mode':          info['mode'],
        'instrument':    meta.get('InstrumentName', '?'),
        'acquired':      meta.get('AcquisitionDateTime', '?')[:10],
        'sample':        meta.get('SampleName', '?'),
        'method':        meta.get('MethodName', '?'),
        'denoised':      meta.get('DenoisingEnabled', '?'),
        'fr_mz':         f"{float(meta.get('MzAcqRangeLower',0)):.0f}-{float(meta.get('MzAcqRangeUpper',0)):.0f}",
        'pr_mz':         f"{info['pr_min']:.0f}-{info['pr_max']:.0f}" if info['pr_min'] else None,
        'IM_1/K0':       f"{meta.get('OneOverK0AcqRangeLower','?')}-{meta.get('OneOverK0AcqRangeUpper','?')}",
        'win_w_mz':      info['win_width_mz'],
        'n_win_groups':  info['n_win_groups'],
        'win_per_grp':   info['win_per_group'],
        'n_precursors':  info['n_precursors'],
        'avg_prec/cyc':  info['avg_prec_cycle'],
        'charges':       info['charges'],
        'cycle_s':       round(ct, 2) if ct else None,
        'total_min':     round(tt / 60, 1) if tt else None,
        'window_est':    round(20 / ct) if ct and info['mode'] == 'diaPASEF' else None,
        'ms1_frames':    ms1.get('n'),
        'ms2_frames':    ms2.get('n'),
        'ms1_Mions':     round(ms1.get('peaks', 0) / 1e6, 1),
        'ms2_Mions':     round(ms2.get('peaks', 0) / 1e6, 1),
        'cal_date':      info['cal_info'].get('CalibrationDateTime', '?')[:10],
    }

    # Fixed 0-2000 bins in steps of 100, zero-filled where no data
    pr_bin_peaks = info.get('pr_bin_peaks', {})
    for b in ALL_BINS:
        row[f'pr{b}-{b+100}M'] = round(pr_bin_peaks.get(b, 0) / 1e6, 2)

    rows.append(row)

pd.set_option('display.max_columns', None)
pd.set_option('display.width', 600)
pd.set_option('display.max_colwidth', 30)

df = pd.DataFrame(rows)
print(df.to_string())

# Save to root of input folder
out_path = os.path.join(folder, "checkTTD_summary.tsv")
df.to_csv(out_path, sep='\t', index=False)
print(f"\nSaved: {out_path}")

print("""
NOTES
  pr{x}-{y}M   : scan-fraction-weighted MS2 NumPeaks per 100 m/z precursor bin (millions)
                 bins span 0-2000 m/z always; zero where no isolation events occurred
  window_est   : diaPASEF only; assumes 20s average peak width -- check DIA-NN log
  n_win_groups : diaPASEF only
  win_per_grp  : diaPASEF only (number of quadrupole sub-windows per TIMS ramp)
  n_precursors : ddaPASEF only (unique precursor IDs from Precursors table)
  avg_prec/cyc : ddaPASEF only (precursors per MS1 cycle)
  win_w_mz     : ddaPASEF shows min-max(median) of dynamic isolation widths
  fr bin ions  : require reading analysis.tdf_bin (alphatims or Bruker SDK)
""")