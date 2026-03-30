import numpy as np
import pandas as pd
from scipy.optimize import least_squares


# -----------------------------
# LOAD EVIDENCE
# -----------------------------
def load_evidence(path):
    df = pd.read_csv(path, sep="\t")

    df = df[[
        "Sequence",
        "Charge",
        "Raw file",
        "Intensity",
        "Leading razor protein"
    ]].copy()

    df = df[df["Intensity"] > 0]

    # species definition (critical)
    df["species"] = df["Sequence"] + "_z" + df["Charge"].astype(str)

    return df


# -----------------------------
# GLOBAL NORMALIZATION (Fig 2C)
# -----------------------------
def estimate_global_normalization(df):

    runs = df["Raw file"].unique()
    idx = {r: i for i, r in enumerate(runs)}

    rows = []

    for sp, sub in df.groupby("species"):

        sub = sub.sort_values("Raw file")

        for i in range(len(sub)):
            for j in range(i + 1, len(sub)):

                ri = sub.iloc[i]["Raw file"]
                rj = sub.iloc[j]["Raw file"]

                Ii = sub.iloc[i]["Intensity"]
                Ij = sub.iloc[j]["Intensity"]

                r_ij = np.log(Ii) - np.log(Ij)

                rows.append((ri, rj, r_ij))

    def residuals(x):
        res = []
        for ri, rj, r_ij in rows:
            res.append(x[idx[ri]] - x[idx[rj]] - r_ij)
        return np.array(res)

    def residuals_reduced(x):
        full = np.concatenate([[0], x])  # anchor first run
        return residuals(full)

    x0 = np.zeros(len(runs) - 1)

    sol = least_squares(residuals_reduced, x0, method="trf")

    x = np.concatenate([[0], sol.x])

    N = {runs[i]: np.exp(x[i]) for i in range(len(runs))}

    return N

def rescale_maxquant(df, lfq, N):

    scaled = {}

    for prot, sub in df.groupby("Leading razor protein"):

        if prot not in lfq.index:
            continue

        runs = lfq.columns
        x = lfq.loc[prot].copy()

        # Step 1: compute ALL normalized peptide intensities
        all_vals = []

        for _, row in sub.iterrows():
            run = row["Raw file"]
            if run not in N:
                continue
            val = row["Intensity"] * N[run]
            if np.isfinite(val):
                all_vals.append(val)

        if len(all_vals) == 0:
            continue

        # Step 2: single global max (critical MQ rule)
        scale = np.max(all_vals)

        # Step 3: scale LFQ
        scaled_vals = np.exp(np.log(x) - np.nanmax(np.log(x))) * scale

        scaled[prot] = dict(zip(runs, scaled_vals))

    return pd.DataFrame(scaled).T

# -----------------------------
# SOLVE LFQ (Fig 2F exact)
# -----------------------------
def solve_lfq(df, N):

    results = {}

    for prot, sub in df.groupby("Leading razor protein"):

        runs = sorted(sub["Raw file"].unique())
        idx = {r: i for i, r in enumerate(runs)}

        if len(runs) <= 1:
            continue

        rows = []

        for sp, sp_sub in sub.groupby("species"):

            sp_sub = sp_sub.sort_values("Raw file")

            for i in range(len(sp_sub)):
                for j in range(i + 1, len(sp_sub)):

                    ri = sp_sub.iloc[i]["Raw file"]
                    rj = sp_sub.iloc[j]["Raw file"]

                    Ii = sp_sub.iloc[i]["Intensity"]
                    Ij = sp_sub.iloc[j]["Intensity"]

                    r_ij = np.log(N[ri] * Ii) - np.log(N[rj] * Ij)

                    rows.append((ri, rj, r_ij))

        if len(rows) == 0:
            continue

        def residuals(x):
            res = []
            for ri, rj, r_ij in rows:
                res.append(x[idx[ri]] - x[idx[rj]] - r_ij)
            return np.array(res)

        def residuals_reduced(x):
            full = np.concatenate([[0], x])
            return residuals(full)

        x0 = np.zeros(len(runs) - 1)

        sol = least_squares(residuals_reduced, x0, method="trf")

        x = np.concatenate([[0], sol.x])
        vals = np.exp(x)

        # -----------------------------
        # MQ scaling constraint (MAX)
        # -----------------------------
        S = []

        for r in runs:
            sub_run = sub[sub["Raw file"] == r]

            if len(sub_run) > 0:
                S.append(np.max(sub_run["Intensity"] * N[r]))
            else:
                S.append(np.nan)

        S = np.array(S)
        mask = ~np.isnan(S)

        if np.any(mask):
            c = np.nanmax(S[mask]) / np.nanmax(vals[mask] * S[mask])
        else:
            c = 1.0

        vals = vals * c

        results[prot] = dict(zip(runs, vals))

    return pd.DataFrame(results).T


# -----------------------------
# DIAGNOSTICS (Q2KIF2)
# -----------------------------
def report_q2kif2(lfq, N, df):

    prot = "Q2KIF2"

    if prot not in lfq.index:
        print("\nQ2KIF2 not found")
        return

    print("\n==============================")
    print("Q2KIF2 DIAGNOSTICS")
    print("==============================")

    print("\nLFQ values:")
    print(lfq.loc[prot])

    # MQ reference (given)
    MQ_REF = {
        "Flush01_20251203085025": 172860,
        "Flush01_20260308233519": 164540,
        "Flush01_20260309024925": 181600,
    }

    print("\nlog2 differences vs MQ:")
    for run in lfq.columns:
        if run in MQ_REF and not np.isnan(lfq.loc[prot, run]):
            calc = lfq.loc[prot, run]
            ref = MQ_REF[run]
            log2diff = np.log2(calc / ref)
            print(f"{run}: {calc:.1f} vs {ref} → Δlog2 = {log2diff:+.3f}")

    # inspect dominant peptide
    print("\nTop contributing peptide (per run):")

    sub = df[df["Leading razor protein"] == prot]

    for run in lfq.columns:
        sub_run = sub[sub["Raw file"] == run]
        if len(sub_run) == 0:
            continue

        sub_run = sub_run.copy()
        sub_run["norm_int"] = sub_run["Intensity"] * N[run]

        top = sub_run.sort_values("norm_int", ascending=False).iloc[0]

        print(f"{run}: {top['Sequence']} (z{top['Charge']}) → {top['norm_int']:.1f}")


# -----------------------------
# MAIN
# -----------------------------
def run(path):

    df = load_evidence(path)

    print("Loaded:", df.shape)
    print("Runs:", df["Raw file"].unique())

    print("\nEstimating normalization...")
    N = estimate_global_normalization(df)
    print("\nN_j:", N)

    print("\nSolving LFQ (Fig 2F exact)...")
    lfq = solve_lfq(df, N)

    print("\nLFQ (scaled):")
    print(lfq)

    scaled_lfq = rescale_maxquant(df, lfq, N)
    print("\nLFQ (scaled to MQ max):")
    print(scaled_lfq)

    report_q2kif2(lfq, N, df)


# -----------------------------
if __name__ == "__main__":
    run(r"F:\maxlLFQ\combined\txt\evidence.txt")