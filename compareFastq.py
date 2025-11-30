#python "c:\Users\animeshs\OneDrive\Desktop\Scripts\compareFastq.py" "F:/reads/TK9_1_22FFLLLT3_AGAGAACCTA-GGTTATGCTA_L005__1.fq.gz" "F:/fastq/SRR31089076_1.fastq.gz"
#for %R in ("F:\reads\TK9*_1.fq.gz") do for %F in ("F:\fastq\SRR31089076_1.fastq.gz") do  python compareFastq.py "%R" "%F"
import sys, os, gzip, time, platform

def peak_bytes():
    # Dependency-free peak memory detection.
    if platform.system() == 'Windows':
        try:
            import ctypes
            from ctypes import wintypes, byref
            class PROCESS_MEMORY_COUNTERS(ctypes.Structure):
                _fields_ = [
                    ('cb', wintypes.DWORD),
                    ('PageFaultCount', wintypes.DWORD),
                    ('PeakWorkingSetSize', ctypes.c_size_t),
                    ('WorkingSetSize', ctypes.c_size_t),
                    ('QuotaPeakPagedPoolUsage', ctypes.c_size_t),
                    ('QuotaPagedPoolUsage', ctypes.c_size_t),
                    ('QuotaPeakNonPagedPoolUsage', ctypes.c_size_t),
                    ('QuotaNonPagedPoolUsage', ctypes.c_size_t),
                    ('PagefileUsage', ctypes.c_size_t),
                    ('PeakPagefileUsage', ctypes.c_size_t),
                ]
            psapi = ctypes.WinDLL('Psapi')
            kernel32 = ctypes.WinDLL('kernel32')
            GetCurrentProcess = kernel32.GetCurrentProcess
            GetProcessMemoryInfo = psapi.GetProcessMemoryInfo
            # set argtypes/restype for safety
            GetProcessMemoryInfo.argtypes = [wintypes.HANDLE, ctypes.POINTER(PROCESS_MEMORY_COUNTERS), wintypes.DWORD]
            GetProcessMemoryInfo.restype = wintypes.BOOL
            pmc = PROCESS_MEMORY_COUNTERS()
            pmc.cb = ctypes.sizeof(pmc)
            h = GetCurrentProcess()
            ok = GetProcessMemoryInfo(h, byref(pmc), pmc.cb)
            if ok:
                return int(pmc.PeakWorkingSetSize)
            # fall through to tasklist fallback
        except Exception:
            pass
        # Fallback: use built-in tasklist command and parse its output (no external deps)
        try:
            import subprocess, csv, io
            pid = os.getpid()
            cmd = ['tasklist', '/FI', f'PID eq {pid}', '/FO', 'CSV', '/NH']
            out = subprocess.check_output(cmd, universal_newlines=True, stderr=subprocess.DEVNULL)
            # parse CSV robustly (handles commas inside quoted fields)
            reader = csv.reader(io.StringIO(out))
            rows = list(reader)
            if rows and len(rows[0]) >= 5:
                mem_field = rows[0][-1]
                # mem_field like '10,240 K' or '1,234,560 K'
                num = ''.join(ch for ch in mem_field if ch.isdigit())
                if num:
                    kb = int(num)
                    # tasklist reports memory in KB
                    return int(kb * 1024)
        except Exception:
            return None
    else:
        try:
            import resource
            peak = resource.getrusage(resource.RUSAGE_SELF).ru_maxrss
            # ru_maxrss is often kilobytes on Unix; convert to bytes
            return int(peak * 1024) if peak > 1024 else int(peak)
        except Exception:
            return None

def read_seqs(p):
    opener = gzip.open if p.lower().endswith('.gz') else open
    s = set(); n = 0
    with opener(p, 'rt') as fh:
        for i, L in enumerate(fh):
            if i % 4 == 1:
                n += 1; s.add(L.rstrip('\n'))
    return s, n

if len(sys.argv) != 3:
    sys.stderr.write('Usage: compareFastq.py <reads-file> <reference-file>\n')
    sys.exit(2)

reads, ref = sys.argv[1], sys.argv[2]
if not os.path.isfile(reads) or not os.path.isfile(ref):
    sys.stderr.write('file not found\n'); sys.exit(2)

st_cpu = time.process_time(); st_wall = time.time()
s_reads, n_reads = read_seqs(reads)
s_ref, n_ref = read_seqs(ref)
missing = sum(1 for x in s_ref if x not in s_reads)
cpu = time.process_time() - st_cpu; wall = time.time() - st_wall
peak = peak_bytes(); peak_gb = (peak / 1024.0**3) if peak else None
missing_reads_in_ref = sum(1 for x in s_reads if x not in s_ref)
common_unique = len(s_reads & s_ref)

pairs = [
    ("reads_total", str(n_reads)),
    ("reads_unique", str(len(s_reads))),
    ("reference_total", str(n_ref)),
    ("reference_unique", str(len(s_ref))),
    ("missing_reference_in_reads", str(missing)),
    ("missing_reads_in_reference", str(missing_reads_in_ref)),
    ("common_unique", str(common_unique)),
    ("cpu_time_min", f"{(cpu/60):.3f}"),
    ("wall_time_min", f"{(wall/60):.3f}"),
    ("peak_mem_gb", f"{peak_gb:.3f}" if peak_gb is not None else 'NA'),
]

print('\t'.join(f"{k}:{v}" for k, v in pairs))
