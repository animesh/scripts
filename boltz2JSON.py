from pathlib import Path
import sys
import json
import gzip
import csv
import glob
import re
import os

def _open_text(path: Path):
    if path.suffix == ".gz":
        return gzip.open(path, "rt", encoding="utf-8")
    return path.open("r", encoding="utf-8")

in_arg = sys.argv[1] if len(sys.argv) > 1 else ""
out_path = Path(sys.argv[2]) if len(sys.argv) > 2 else Path("boltz2.combined.csv")

def load_file(p: Path):
    with _open_text(p) as fh:
        return json.load(fh)

def _get(src, i):
    if src is None:
        return ""
    if not isinstance(src, list):
        return src
    if i < len(src):
        return src[i]
    return ""

def _is_number_list(x):
    return isinstance(x, list) and all(not isinstance(e, list) for e in x)

# determine run count: prefer confidence or complex scores, or iptm if it's per-run (list of lists)
def _process(data, source_name=""):
    confidence = data.get("confidence_scores") or data.get("confidence") or []
    chains_ptm = data.get("chains_ptm_scores") or data.get("chains_ptm") or data.get("ptm_scores") or []
    iptm_src = data.get("pair_chains_iptm_scores") or data.get("iptm_scores") or data.get("protein_iptm_scores") or []
    complex_plddt = data.get("complex_plddt_scores") or []
    complex_iplddt = data.get("complex_iplddt_scores") or []
    complex_pde = data.get("complex_pde_scores") or []
    complex_ipde = data.get("complex_ipde_scores") or []

    run_count = 1
    if isinstance(confidence, list) and len(confidence) > 1:
        run_count = len(confidence)
    elif isinstance(complex_plddt, list) and len(complex_plddt) > 1:
        run_count = len(complex_plddt)
    elif isinstance(iptm_src, list) and len(iptm_src) > 0 and isinstance(iptm_src[0], list):
        run_count = len(iptm_src)

    rows_local = []
    for i in range(run_count):
        if isinstance(confidence, list):
            conf_v = confidence[i] if i < len(confidence) else confidence[0]
        else:
            conf_v = confidence

        # pTM
        if isinstance(chains_ptm, list) and len(chains_ptm) > 0 and isinstance(chains_ptm[0], list):
            ch = chains_ptm[i] if i < len(chains_ptm) else chains_ptm[0]
            pTM_Ch0 = ch[0] if len(ch) > 0 else ""
            pTM_Ch1 = ch[1] if len(ch) > 1 else ""
        elif _is_number_list(chains_ptm) and len(chains_ptm) >= 2:
            pTM_Ch0, pTM_Ch1 = chains_ptm[0], chains_ptm[1]
        else:
            pTM_Ch0 = pTM_Ch1 = ""

        # ipTM: reuse existing logic but refer to local variables
        if isinstance(iptm_src, list) and len(iptm_src) > 0 and isinstance(iptm_src[0], list):
            ip = iptm_src[i] if i < len(iptm_src) else iptm_src[0]
            ipTM_Ch0 = ip[0] if len(ip) > 0 else ""
            ipTM_Ch1 = ip[1] if len(ip) > 1 else ""
            try:
                pairwise = sum(float(x) for x in ip if x not in (None, "")) / max(1, len([x for x in ip if x not in (None, "")] ))
            except Exception:
                pairwise = ""
        elif isinstance(iptm_src, list) and len(iptm_src) > 0 and isinstance(iptm_src[0], dict):
            d = iptm_src[i] if i < len(iptm_src) else iptm_src[0]
            pairwise = d.get("0", {}).get("1") if isinstance(d.get("0"), dict) else None
            if pairwise is None:
                pairwise = d.get("1", {}).get("0") if isinstance(d.get("1"), dict) else None
            ipTM_Ch0 = d.get("1", {}).get("0") if isinstance(d.get("1"), dict) else None
            ipTM_Ch1 = d.get("1", {}).get("1") if isinstance(d.get("1"), dict) else None
            if ipTM_Ch0 is None:
                ipTM_Ch0 = (data.get("protein_iptm_scores") or data.get("iptm_scores") or [None])[0]
            if ipTM_Ch1 is None:
                ipTM_Ch1 = (chains_ptm[1] if isinstance(chains_ptm, list) and len(chains_ptm) > 1 else None)
            if pairwise is None:
                pairwise = ""
        elif _is_number_list(iptm_src) and len(iptm_src) >= 2 and run_count == 1:
            ipTM_Ch0, ipTM_Ch1 = iptm_src[0], iptm_src[1]
            try:
                pairwise = sum(float(x) for x in iptm_src if x not in (None, "")) / max(1, len([x for x in iptm_src if x not in (None, "")] ))
            except Exception:
                pairwise = ""
        else:
            ipTM_Ch0 = ipTM_Ch1 = pairwise = ""

        cp = complex_plddt[i] if isinstance(complex_plddt, list) and i < len(complex_plddt) else (complex_plddt[0] if isinstance(complex_plddt, list) and complex_plddt else complex_plddt)
        cip = complex_iplddt[i] if isinstance(complex_iplddt, list) and i < len(complex_iplddt) else (complex_iplddt[0] if isinstance(complex_iplddt, list) and complex_iplddt else complex_iplddt)
        cpd = complex_pde[i] if isinstance(complex_pde, list) and i < len(complex_pde) else (complex_pde[0] if isinstance(complex_pde, list) and complex_pde else complex_pde)
        cipd = complex_ipde[i] if isinstance(complex_ipde, list) and i < len(complex_ipde) else (complex_ipde[0] if isinstance(complex_ipde, list) and complex_ipde else complex_ipde)

        def f(x):
            if x == "" or x is None:
                return ""
            try:
                return f"{float(x):.3f}"
            except Exception:
                return str(x)

        rows_local.append({
            "File": source_name,
            "Run": i + 1,
            "Confidence": f(conf_v),
            "pTM_Ch0": f(pTM_Ch0),
            "pTM_Ch1": f(pTM_Ch1),
            "ipTM_Ch0": f(ipTM_Ch0),
            "ipTM_Ch1": f(ipTM_Ch1),
            "complex_pLDDT": f(cp),
            "complex_iPLDDT": f(cip),
            "complex_pDE": f(cpd),
            "complex_iPDE": f(cipd),
            "Pairwise_ipTM": f(pairwise),
        })

    return rows_local

files = []
if in_arg:
    files = sorted([Path(p) for p in glob.glob(in_arg)])
else:
    files = sorted(Path.cwd().glob("boltz2*.json*"))

def _common_token_prefix(names):
    lists = [re.findall(r"[A-Za-z0-9]+", n) for n in names if n]
    if not lists:
        return None
    min_len = min(len(lst) for lst in lists)
    common = []
    for i in range(min_len):
        tok = lists[0][i]
        if all(lst[i] == tok for lst in lists):
            common.append(tok)
        else:
            break
    if common:
        return "_".join(common)
    # fallback to os.path.commonprefix on raw names (without extension)
    cp = os.path.commonprefix(names)
    cp = re.sub(r"[^A-Za-z0-9]+$", "", cp)
    if cp:
        return cp
    return None

# if user didn't pass an explicit output, derive base from input/files
if len(sys.argv) <= 2:
    base = None
    if in_arg and "boltz2" in in_arg:
        base = "boltz2"
    elif files:
        names = [p.stem for p in files]
        base = _common_token_prefix(names)
    if not base:
        base = "boltz2"
    out_path = Path(f"{base}.combined.csv")

all_rows = []
for p in files:
    try:
        d = load_file(p)
    except Exception:
        continue
    all_rows.extend(_process(d, source_name=p.name))

fieldnames = ["File", "Run", "Confidence", "pTM_Ch0", "pTM_Ch1", "ipTM_Ch0", "ipTM_Ch1", "complex_pLDDT", "complex_iPLDDT", "complex_pDE", "complex_iPDE", "Pairwise_ipTM"]
out_path.parent.mkdir(parents=True, exist_ok=True)
with out_path.open("w", newline="", encoding="utf-8") as fh:
    w = csv.DictWriter(fh, fieldnames=fieldnames)
    w.writeheader()
    for r in all_rows:
        w.writerow(r)

# print the row with highest numeric ipTM_Ch0 to console
best = None
best_val = float("-inf")
for r in all_rows:
    v = r.get("ipTM_Ch0", "")
    try:
        fv = float(v) if v not in (None, "") else None
    except Exception:
        fv = None
    if fv is not None and fv > best_val:
        best_val = fv
        best = r

if best is not None:
    hdr = [c for c in fieldnames if c != "File"]
    vals = [str(best.get(c, "")) for c in hdr]
    print("Best ipTM_Ch0:", f"{best_val:.3f}")
    print("\t".join(hdr))
    print("\t".join(vals))