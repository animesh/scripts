#python checkTTD.py  F:\promec\TIMSTOF\Raw\LARS\250829_rabina #250829_rabina2_dia_Slot1-10_1_10961.d  100.000000  1700.000000     400.0    1201.0
#python checkTTD.py F:\promec\TIMSTOF\Raw\LARS\260827_ChunMei
#                                                 run   fr_mz_low   fr_mz_high  prec_min  prec_max
#   260827_200ngHelaQC_DIA_newQCa_Slot1-54_1_14321.d  100.000549  1700.000000     400.0    1000.0
import sqlite3, glob, pandas as pd
import sys
rows = []
for d in glob.glob(f"{sys.argv[1]}/*.d",recursive=False):
    db = f"{d}/analysis.tdf"
    con = sqlite3.connect(db)
    meta = dict(con.execute("SELECT Key,Value FROM GlobalMetadata").fetchall())
    win  = con.execute(
        "SELECT MIN(IsolationMz-IsolationWidth/2.0), MAX(IsolationMz+IsolationWidth/2.0) "
        "FROM DiaFrameMsMsWindows"
    ).fetchone()
    con.close()
    rows.append({
        "run": d.split("\\")[-1],
        "fr_mz_low":  meta.get("MzAcqRangeLower"),
        "fr_mz_high": meta.get("MzAcqRangeUpper"),
        "prec_min":   round(win[0], 1) if win[0] else None,
        "prec_max":   round(win[1], 1) if win[1] else None,
    })

print(pd.DataFrame(rows).to_string())