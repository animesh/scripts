# /// script
# requires-python = ">=3.13"
# dependencies = [
#     "marimo>=0.23.3",
#     "numpy>=2.5.1",
#     "pandas>=3.0.3",
#     "plotly>=6.9.0",
#     "scipy>=1.18.0",
# ]
# ///
#local view: uv run marimo run maxLFQmo.py
#server edit: animeshs@ubuntu:~/scripts$ uv run marimo edit maxLFQmo.py --host 0.0.0.0 --port 2718
#http://10.20.93.118:2718?access_token=-qW8IZTi3PwgFHbAErqa3Q

import marimo

__generated_with = "0.23.9"
app = marimo.App(width="full", app_title="Inside MaxLFQ")


@app.cell
def _():
    import marimo as mo
    import pandas as pd
    import numpy as np
    import plotly.express as px
    import io
    from itertools import combinations
    from scipy.optimize import least_squares

    return combinations, io, least_squares, mo, np, pd, px


@app.cell
def _(mo):
    mo.md(r"""
    # Inside MaxLFQ
    Reverse-engineering MaxQuant LFQ (Cox et al., MCP 2014).

    **Workflow:** peptides.txt → species matrix → delayed normalization → pairwise ratios → profile reconstruction → LFQ intensities
    """)
    return


@app.cell
def _(mo):
    peptide_file = mo.ui.file(label="peptides.txt / modificationSpecificPeptides.txt")
    proteingroup_file = mo.ui.file(label="proteinGroups.txt  (optional)")
    return peptide_file, proteingroup_file


@app.cell
def _(mo, peptide_file, proteingroup_file):
    _out = mo.hstack([peptide_file, proteingroup_file], gap=4)
    _out
    return


@app.cell
def _():
    def first_col(df, candidates):
        for c in candidates:
            if c in df.columns:
                return c
        return None

    def first_token(v):
        return str(v).split(";")[0].strip()

    return first_col, first_token


@app.cell
def _(io, pd):
    def read_uploaded(f):
        name = f.name.lower()
        buf = io.BytesIO(f.contents)
        if name.endswith((".txt", ".tsv")):
            return pd.read_csv(buf, sep="\t", low_memory=False)
        if name.endswith(".csv"):
            return pd.read_csv(buf, low_memory=False)
        if name.endswith(".xlsx"):
            return pd.read_excel(buf, engine="openpyxl")
        return pd.read_csv(buf, sep=None, engine="python")

    return (read_uploaded,)


@app.cell
def _(peptide_file, proteingroup_file, read_uploaded):
    peptide_df = protein_groups_df = pep_err = pg_err = None
    if peptide_file.value:
        try:
            peptide_df = read_uploaded(peptide_file.value[0])
        except Exception as e:
            pep_err = str(e)
    if proteingroup_file.value:
        try:
            protein_groups_df = read_uploaded(proteingroup_file.value[0])
        except Exception as e:
            pg_err = str(e)
    return pep_err, peptide_df, pg_err, protein_groups_df


@app.cell
def _(mo, pep_err, peptide_df, pg_err, protein_groups_df):
    _out = mo.md("")
    if pep_err:
        _out = mo.callout(mo.md(f"**Error:** {pep_err}"), kind="danger")
    elif peptide_df is None:
        _out = mo.callout(mo.md("Upload **peptides.txt** (or **modificationSpecificPeptides.txt**) to begin. **proteinGroups.txt** enables comparison plots."), kind="info")
    else:
        _stats = [
            mo.stat(label="Rows",    value=f"{len(peptide_df):,}"),
            mo.stat(label="Columns", value=f"{len(peptide_df.columns):,}"),
        ]
        if protein_groups_df is not None:
            _stats.append(mo.stat(label="ProteinGroup rows", value=f"{len(protein_groups_df):,}"))
        if pg_err:
            _stats.append(mo.callout(mo.md(f"proteinGroups error: {pg_err}"), kind="warn"))
        _out = mo.hstack(_stats)
    _out
    return


@app.cell
def _(first_col, peptide_df):
    if peptide_df is None:
        protein_col = sequence_col = mod_col = charge_col = intensity_cols = samples = None
    else:
        protein_col    = first_col(peptide_df, ["Leading razor protein", "Razor protein", "Proteins", "Protein IDs"])
        sequence_col   = first_col(peptide_df, ["Sequence", "Peptide sequence", "Peptide"])
        mod_col        = next((c for c in peptide_df.columns if c.lower().startswith("mod")), None)
        charge_col     = first_col(peptide_df, ["Charge", "Charges", "z"])
        intensity_cols = [c for c in peptide_df.columns if str(c).startswith("Intensity ")]
        samples        = [c.replace("Intensity ", "", 1) for c in intensity_cols]
    return (
        charge_col,
        intensity_cols,
        mod_col,
        protein_col,
        samples,
        sequence_col,
    )


@app.cell
def _(charge_col, intensity_cols, mo, mod_col, protein_col, sequence_col):
    _out = mo.md("")
    if protein_col is not None:
        _out = mo.md(f"**Columns:** protein=`{protein_col}` | sequence=`{sequence_col}` | mod=`{mod_col}` | charge=`{charge_col}` | **{len(intensity_cols or [])} samples**")
    _out
    return


@app.cell
def _(peptide_df):
    if peptide_df is None:
        n_decoy = n_contaminant = 0
    else:
        def _count_plus(df, cols):
            for c in cols:
                if c in df.columns:
                    return int((df[c].astype(str).str.strip() == "+").sum())
            return 0
        n_decoy       = _count_plus(peptide_df, ["Reverse", "Decoy"])
        n_contaminant = _count_plus(peptide_df, ["Potential contaminant", "Contaminant"])
    return n_contaminant, n_decoy


@app.cell
def _(first_token, peptide_df, protein_col):
    if peptide_df is None or protein_col is None:
        raw_protein_list = []
    else:
        raw_protein_list = sorted(set(
            peptide_df[protein_col].astype(str).map(first_token).tolist()
        ))
    return (raw_protein_list,)


@app.cell
def _(
    charge_col,
    filter_contaminant,
    filter_decoy,
    first_token,
    intensity_cols,
    mod_col,
    np,
    pd,
    peptide_df,
    protein_col,
    proteins_to_exclude,
    samples,
    sequence_col,
):
    if peptide_df is None or protein_col is None:
        species_matrix = None
    else:
        df = peptide_df.copy()
        if filter_decoy.value:
            for flag in ["Reverse", "Decoy"]:
                if flag in df.columns:
                    df = df[df[flag].astype(str).str.strip() != "+"]
        if filter_contaminant.value:
            for flag in ["Potential contaminant", "Contaminant"]:
                if flag in df.columns:
                    df = df[df[flag].astype(str).str.strip() != "+"]
        df[intensity_cols] = df[intensity_cols].apply(pd.to_numeric, errors="coerce").replace(0, np.nan)
        df = df[df[intensity_cols].notna().any(axis=1)].copy()
        df["_protein"] = df[protein_col].astype(str).map(first_token)
        if proteins_to_exclude:
            df = df[~df["_protein"].isin(proteins_to_exclude)]
        seq    = df[sequence_col].astype(str).str.upper() if sequence_col else pd.Series("NA", index=df.index)
        mods   = df[mod_col].astype(str).str.strip()     if mod_col    else pd.Series("Unmodified", index=df.index)
        charge = df[charge_col].astype(str).str.strip()  if charge_col else pd.Series("NA", index=df.index)
        df["_species"] = seq + "_" + mods + "_z" + charge
        rename = dict(zip(intensity_cols, samples))
        w = df[["_protein", "_species"] + intensity_cols].rename(columns=rename)
        species_matrix = w.groupby(["_protein", "_species"], sort=True)[samples].first().replace(0, np.nan)
    return (species_matrix,)


@app.cell
def _(mo, species_matrix):
    _out = mo.md("")
    if species_matrix is not None:
        fill = species_matrix.notna().values.sum()
        _out = mo.hstack([
            mo.stat(label="Proteins", value=f"{species_matrix.index.get_level_values(0).nunique():,}"),
            mo.stat(label="Species",  value=f"{len(species_matrix):,}"),
            mo.stat(label="Fill",     value=f"{100*fill/species_matrix.size:.1f}%"),
        ])
    _out
    return


@app.cell
def _(mo):
    mo.md(r"""
    ## Step 1 — Delayed Normalization

    **Eq. 2** Find scaling factors $N_s$ minimising the sum of squared log-ratios across all peptide species $p$ and sample pairs $(i,j)$:
    $$H(N) = \sum_{p,i,j} \left[\log\frac{N_i\,X_{p,i}}{N_j\,X_{p,j}}\right]^2 \to \min$$
    """)
    return


@app.cell
def _(combinations, np, samples, species_matrix):
    if species_matrix is None:
        logX = n_samples = normalization_residuals = None
    else:
        logX = np.log(species_matrix.values.astype(float))
        n_samples = len(samples)
        pairs = list(combinations(range(n_samples), 2))

        def normalization_residuals(logN):
            blocks = []
            for a, b in pairs:
                ok = np.isfinite(logX[:, a]) & np.isfinite(logX[:, b])
                if ok.any():
                    blocks.append(logX[ok, a] + logN[a] - logX[ok, b] - logN[b])
            return np.concatenate(blocks) if blocks else np.array([0.0])
    return n_samples, normalization_residuals


@app.cell
def _(least_squares, n_samples, normalization_residuals, np):
    if normalization_residuals is None:
        N_scale_free = H_before = None
    else:
        res0 = normalization_residuals(np.zeros(n_samples))
        H_before = float(np.sum(res0 ** 2))
        method = "lm" if len(res0) >= n_samples else "trf"
        fit = least_squares(normalization_residuals, np.zeros(n_samples), method=method, max_nfev=2000)
        N_scale_free = np.exp(fit.x)
    return H_before, N_scale_free


@app.cell
def _(N_scale_free, anchor_sample, normalization_residuals, np, pd, samples):
    if N_scale_free is None:
        N = H_after = normalization_table = None
    else:
        anch = anchor_sample.value
        if anch == "All Samples Average":
            N = N_scale_free / np.mean(N_scale_free)
        elif anch == "All Samples Median":
            N = N_scale_free / np.median(N_scale_free)
        elif anch == "All Samples Maximum":
            N = N_scale_free / np.max(N_scale_free)
        elif anch in samples:
            N = N_scale_free / N_scale_free[samples.index(anch)]
        else:
            N = N_scale_free / N_scale_free[0]
        H_after = float(np.sum(normalization_residuals(np.log(N)) ** 2))
        normalization_table = pd.DataFrame({"Sample": samples, "N": N, "log2_N": np.log2(N)})
    return H_after, normalization_table


@app.cell
def _(H_after, H_before, mo, normalization_table, px):
    _out = mo.md("")
    if normalization_table is not None:
        reduction = f"{100*(1-H_after/H_before):.1f}%" if H_before and H_before > 0 else "n/a"
        _out = mo.vstack([
            mo.hstack([
                mo.stat(label="H before", value=f"{H_before:,.0f}"),
                mo.stat(label="H after",  value=f"{H_after:,.0f}"),
                mo.stat(label="H reduction", value=reduction),
            ]),
            px.bar(normalization_table, x="Sample", y="log2_N", title="log2 Normalization Factors (Eq. 2)"),
        ])
    _out
    return


@app.cell
def _(normalization_table, species_matrix):
    if species_matrix is None or normalization_table is None:
        normalized_species_matrix = None
    else:
        normalized_species_matrix = species_matrix.copy()
        nlookup = dict(zip(normalization_table["Sample"], normalization_table["N"]))
        for s in normalized_species_matrix.columns:
            normalized_species_matrix[s] = normalized_species_matrix[s] * nlookup.get(s, 1.0)
    return (normalized_species_matrix,)


@app.cell
def _(mo):
    mo.md(r"""
    ## Step 2 — Normalized Intensities (Eq. 1)

    Apply the solved $N_s$ to each peptide species intensity:
    $$I_{p,s}(N) = N_s \cdot X_{p,s}$$
    """)
    return


@app.cell
def _(mo, normalization_table, normalized_species_matrix, pd, px, samples):
    _out = mo.md("")
    if normalized_species_matrix is not None and normalization_table is not None:
        nlookup2 = dict(zip(normalization_table["Sample"], normalization_table["N"]))
        rows_eq1 = [{"Sample": s,
                     "Raw":        normalized_species_matrix[s].sum(skipna=True) / nlookup2.get(s, 1.0),
                     "Normalized": normalized_species_matrix[s].sum(skipna=True)}
                    for s in samples if s in normalized_species_matrix.columns]
        _out = px.bar(pd.DataFrame(rows_eq1), x="Sample", y=["Raw", "Normalized"], barmode="group",
               title="Total intensity per sample: Raw vs Normalized")
    _out
    return


@app.cell
def _(normalized_species_matrix, species_matrix):
    _src = normalized_species_matrix if normalized_species_matrix is not None else species_matrix
    if _src is None:
        protein_list = None
    else:
        protein_list = (
            _src.reset_index()["_protein"]
            .drop_duplicates().sort_values().tolist()
        )
    return (protein_list,)


@app.cell
def _(mo, protein_list):
    protein_selector = mo.ui.dropdown(
        options=protein_list or [],
        value=(protein_list[0] if protein_list else None),
        label="Select protein",
    )
    return (protein_selector,)


@app.cell
def _(mo, protein_list, protein_selector):
    _out = mo.md("")
    if protein_list:
        _out = mo.vstack([mo.md("## Protein Explorer"), protein_selector])
    _out
    return


@app.cell
def _(mo, normalized_species_matrix, protein_list, protein_selector, px, species_matrix):
    _out = mo.md("")
    _src = normalized_species_matrix if normalized_species_matrix is not None else species_matrix
    _label = "normalized species intensities" if normalized_species_matrix is not None else "raw species intensities (normalization pending)"
    if protein_list and _src is not None and protein_selector.value:
        prot = protein_selector.value
        psm = _src.loc[prot].copy()
        long_df = (psm.reset_index()
                   .melt(id_vars="_species", var_name="Sample", value_name="Intensity")
                   .dropna(subset=["Intensity"]))
        _out = mo.vstack([
            px.bar(long_df, x="Sample", y="Intensity", color="_species", log_y=True,
                   title=f"{prot} — {_label}"),
            mo.md(f"**{prot}** · {len(psm)} species"),
            psm,
        ])
    _out
    return


@app.cell
def _(mo):
    mo.md(r"""
    ## Step 3 — Pairwise Log-Ratios

    For each protein and each pair of samples $(i,j)$, compute the median (or mean) log-ratio across all shared peptide species $p$:
    $$r_{ij} = \operatorname{median}_p \left(\log_2 \frac{I_{p,i}}{I_{p,j}}\right)$$
    """)
    return


@app.cell
def _(
    combinations,
    minimum_ratio_count,
    n_samples,
    normalized_species_matrix,
    np,
    pd,
    ratio_method,
    samples,
):
    if normalized_species_matrix is None:
        pairwise_ratio_trace = None
    else:
        pr_rows = []
        for protein, pdf in normalized_species_matrix.groupby(level=0, sort=True):
            logm = np.log2(pdf.values.astype(float))
            for j, k in combinations(range(n_samples), 2):
                ok = np.isfinite(logm[:, j]) & np.isfinite(logm[:, k])
                nsh = int(ok.sum())
                if nsh < minimum_ratio_count.value:
                    continue
                r = float(np.median(logm[ok, j] - logm[ok, k]) if ratio_method.value == "median"
                          else np.mean(logm[ok, j] - logm[ok, k]))
                pr_rows.append({"Protein": protein, "Sample_A": samples[j], "Sample_B": samples[k],
                                "Shared_Species": nsh, "log2_ratio": r})
        pairwise_ratio_trace = pd.DataFrame(pr_rows)
    return (pairwise_ratio_trace,)


@app.cell
def _(mo, pairwise_ratio_trace, px):
    _out = mo.md("")
    if pairwise_ratio_trace is not None and len(pairwise_ratio_trace) > 0:
        _out = mo.vstack([
            mo.stat(label="Protein-pair ratios computed", value=f"{len(pairwise_ratio_trace):,}"),
            px.histogram(pairwise_ratio_trace, x="Shared_Species",
                         title="Shared species per sample pair"),
        ])
    _out
    return


@app.cell
def _(mo):
    mo.md(r"""
    ## Step 4 — Profile Reconstruction (Eq. 3)

    Solve for a relative intensity profile $\{I_s\}$ satisfying all pairwise constraints:
    $$\log_2 I_i - \log_2 I_j = r_{ij} \quad \forall\,(i,j)$$
    via least-squares, then scale to the observed anchor intensities.
    """)
    return


@app.cell
def _(
    anchor_sample,
    combinations,
    minimum_ratio_count,
    n_samples,
    normalized_species_matrix,
    np,
    pd,
    ratio_method,
    rescale_method,
    samples,
):
    if normalized_species_matrix is None:
        calculated_lfq = None
    else:
        calc_rows = []
        _rescale = rescale_method.value
        _anch_val = anchor_sample.value
        _r_method = ratio_method.value
        _min_cnt = minimum_ratio_count.value

        for protein2, pdf2 in normalized_species_matrix.groupby(level=0, sort=True):
            mat = pdf2.values.astype(float)
            logm2 = np.log2(mat)
            ratio_mat = np.full((n_samples, n_samples), np.nan)
            for j2, k2 in combinations(range(n_samples), 2):
                ok2 = np.isfinite(logm2[:, j2]) & np.isfinite(logm2[:, k2])
                if ok2.sum() < _min_cnt:
                    continue
                r2 = float(np.median(logm2[ok2, j2] - logm2[ok2, k2]) if _r_method == "median"
                           else np.mean(logm2[ok2, j2] - logm2[ok2, k2]))
                ratio_mat[j2, k2] = r2
                ratio_mat[k2, j2] = -r2
            valid = np.where(np.isfinite(ratio_mat).any(axis=0))[0]
            out_v = np.full(n_samples, np.nan)
            if len(valid) > 1:
                rls, vls = [], []
                for a2, b2 in combinations(range(len(valid)), 2):
                    rv = ratio_mat[valid[a2], valid[b2]]
                    if np.isfinite(rv):
                        eq = np.zeros(len(valid))
                        eq[a2] = 1.0; eq[b2] = -1.0
                        rls.append(eq); vls.append(rv)
                if rls:
                    sol, *_ = np.linalg.lstsq(np.asarray(rls), np.asarray(vls), rcond=None)
                    rel = 2.0 ** sol
                    if _anch_val == "All Samples Average":
                        rel = rel / np.mean(rel)
                    elif _anch_val == "All Samples Median":
                        rel = rel / np.median(rel)
                    elif _anch_val == "All Samples Maximum":
                        rel = rel / np.max(rel)
                    elif _anch_val in samples:
                        idx = samples.index(_anch_val)
                        if idx in valid:
                            rel = rel / rel[np.where(valid == idx)[0][0]]

                    comp = mat[:, valid]
                    anch_v = np.nanmax(comp, axis=0) if _rescale == "max" else np.nansum(comp, axis=0)
                    active = np.isfinite(rel) & np.isfinite(anch_v) & (rel > 0) & (anch_v > 0)
                    if active.any():
                        scale = np.nansum(anch_v[active]) / np.nansum(rel[active])
                        out_v[valid] = rel * scale
            crow = {"Protein": protein2}
            for s2, v2 in zip(samples, out_v):
                crow["LFQ intensity " + s2] = v2 if (np.isfinite(v2) and v2 > 0) else np.nan
            calc_rows.append(crow)
        calculated_lfq = pd.DataFrame(calc_rows).set_index("Protein")
    return (calculated_lfq,)


@app.cell
def _(calculated_lfq, mo):
    _out = mo.md("")
    if calculated_lfq is not None:
        filled = calculated_lfq.notna().values.sum()
        _out = mo.vstack([
            mo.hstack([
                mo.stat(label="Proteins quantified", value=f"{len(calculated_lfq):,}"),
                mo.stat(label="LFQ values",          value=f"{filled:,}"),
                mo.stat(label="Fill rate",            value=f"{100*filled/calculated_lfq.size:.1f}%"),
            ]),
            calculated_lfq.head(20),
        ])
    _out
    return


@app.cell
def _(calculated_lfq, filter_contaminant, filter_decoy, first_token, np, pd, protein_groups_df, samples):
    if protein_groups_df is None or calculated_lfq is None:
        comparison_trace = reference_lfq = None
    else:
        pg = protein_groups_df.copy()
        if filter_decoy.value:
            for flag2 in ["Reverse", "Decoy"]:
                if flag2 in pg.columns:
                    pg = pg[pg[flag2].astype(str).str.strip() != "+"]
        if filter_contaminant.value:
            for flag2 in ["Potential contaminant", "Contaminant"]:
                if flag2 in pg.columns:
                    pg = pg[pg[flag2].astype(str).str.strip() != "+"]
        pid_col = "Majority protein IDs" if "Majority protein IDs" in pg.columns else "Protein IDs"
        pg["_protein"] = pg[pid_col].map(first_token)
        lfq_cols = [c for c in pg.columns if str(c).startswith("LFQ intensity ")]
        reference_lfq = (
            pg[["_protein"] + lfq_cols].set_index("_protein")
            .apply(pd.to_numeric, errors="coerce").replace(0, np.nan)
        )
        reference_lfq.columns = [c.replace("LFQ intensity ", "", 1) for c in reference_lfq.columns]
        common = calculated_lfq.index.intersection(reference_lfq.index)
        shared_samp = [s for s in samples if s in reference_lfq.columns]
        cmp_rows = []
        for prot3 in common:
            for s3 in shared_samp:
                calc_col = "LFQ intensity " + s3
                calc = calculated_lfq.loc[prot3, calc_col] if calc_col in calculated_lfq.columns else np.nan
                ref  = reference_lfq.loc[prot3, s3]
                d    = float(np.log2(calc / ref)) if (pd.notna(calc) and pd.notna(ref) and calc > 0 and ref > 0) else np.nan
                cmp_rows.append({"Protein": prot3, "Sample": s3,
                                  "Calculated_LFQ": calc, "ProteinGroups_LFQ": ref, "Log2_Calc_over_PG": d})
        comparison_trace = pd.DataFrame(cmp_rows)
    return (comparison_trace,)


@app.cell
def _(H_after, H_before, calculated_lfq, comparison_trace, mo, np):
    _out = mo.md("")
    if comparison_trace is not None and calculated_lfq is not None:
        valid_d = comparison_trace["Log2_Calc_over_PG"].dropna().values
        _out = mo.vstack([
            mo.md("## Validation vs. MaxQuant proteinGroups"),
            mo.hstack([
                mo.stat(label="Proteins calculated",  value=f"{len(calculated_lfq):,}"),
                mo.stat(label="Common proteins",      value=f"{comparison_trace['Protein'].nunique():,}"),
                mo.stat(label="Pairs compared",       value=f"{len(valid_d):,}"),
                mo.stat(label="Median log2 residual", value=f"{float(np.median(valid_d)):.3f}" if len(valid_d) else "n/a"),
                mo.stat(label="MAE log2",             value=f"{float(np.mean(np.abs(valid_d))):.3f}" if len(valid_d) else "n/a"),
                mo.stat(label="H reduction",          value=f"{100*(1-H_after/H_before):.1f}%" if (H_before and H_before > 0) else "n/a"),
            ]),
        ])
    _out
    return


@app.cell
def _(comparison_trace, mo, px):
    _out = mo.md("")
    if comparison_trace is not None and len(comparison_trace) > 0:
        valid_cmp = comparison_trace.dropna(subset=["Calculated_LFQ", "ProteinGroups_LFQ"])
        bias_df   = comparison_trace.groupby("Sample").agg(mean_log2_diff=("Log2_Calc_over_PG", "mean")).reset_index()
        _out = mo.ui.tabs({
            "Scatter": px.scatter(valid_cmp, x="Calculated_LFQ", y="ProteinGroups_LFQ",
                                  hover_data=["Protein", "Sample"], opacity=0.5,
                                  title="Calculated vs. MaxQuant LFQ", log_x=True, log_y=True),
            "Residuals": px.histogram(valid_cmp, x="Log2_Calc_over_PG", nbins=60,
                                       title="Residual distribution (log2 Calc / MQ)"),
            "Sample bias": px.bar(bias_df, x="Sample", y="mean_log2_diff",
                                   title="Mean log2 residual per sample"),
            "Top outliers": comparison_trace.sort_values("Log2_Calc_over_PG",
                                                          key=lambda x: x.abs(), ascending=False).head(50),
        })
    _out
    return


@app.cell
def _(mo):
    mo.md("""
    ---
    ## Parameters
    """)
    return


@app.cell
def _(mo, samples):
    ratio_method    = mo.ui.dropdown(options=["median", "mean"], value="median", label="Pairwise ratio method")
    rescale_method  = mo.ui.dropdown(options=["max", "sum"],     value="sum",    label="Profile rescaling")
    minimum_ratio_count = mo.ui.number(start=1, stop=50, value=1, label="Min shared species")
    anchor_options  = ["All Samples Average", "All Samples Median", "All Samples Maximum"] + (samples if samples else [])
    anchor_sample   = mo.ui.dropdown(options=anchor_options, value="All Samples Maximum", label="Scaling anchor")
    filter_decoy        = mo.ui.checkbox(label="Filter Decoy/Reverse", value=False)
    filter_contaminant  = mo.ui.checkbox(label="Filter Potential Contaminant(s)", value=False)
    return anchor_sample, filter_contaminant, filter_decoy, minimum_ratio_count, ratio_method, rescale_method


@app.cell
def _(mo):
    protein_search = mo.ui.text(placeholder="e.g. CON__, REV__, BSA", label="Search proteins to exclude")
    return (protein_search,)


@app.cell
def _(anchor_sample, filter_contaminant, filter_decoy, minimum_ratio_count, mo, protein_search, ratio_method, rescale_method):
    _out = mo.vstack([
        mo.hstack([ratio_method, rescale_method, minimum_ratio_count, anchor_sample], gap=2),
        mo.hstack([filter_decoy, filter_contaminant], gap=4),
        mo.hstack([protein_search], gap=2),
    ])
    _out
    return


@app.cell
def _(mo, protein_search, raw_protein_list):
    _q = protein_search.value.strip().lower()
    _matched = [p for p in raw_protein_list if _q in p.lower()] if _q else []
    _display = _matched[:200]
    protein_exclusion_select = (
        mo.ui.multiselect(options=_display, value=_display, label="Uncheck to exclude from LFQ")
        if _display else None
    )
    matched_proteins = _matched
    return matched_proteins, protein_exclusion_select


@app.cell
def _(matched_proteins, protein_exclusion_select):
    if protein_exclusion_select is None:
        proteins_to_exclude = set()
    else:
        proteins_to_exclude = set(protein_exclusion_select.options) - set(protein_exclusion_select.value)
    return (proteins_to_exclude,)


@app.cell
def _(matched_proteins, mo, protein_exclusion_select, protein_search, proteins_to_exclude):
    _out = mo.md("")
    if protein_search.value.strip():
        _n = len(matched_proteins)
        if _n == 0:
            _out = mo.callout(mo.md(f"No proteins match `{protein_search.value.strip()}`"), kind="warn")
        else:
            _cap = f" — showing first 200 of {_n}" if _n > 200 else f" — {_n} match"
            _items = [mo.md(f"**{len(proteins_to_exclude)}** of {_n} staged for exclusion{_cap}")]
            if protein_exclusion_select is not None:
                _items.append(protein_exclusion_select)
            if proteins_to_exclude:
                _preview = ", ".join(f"`{p}`" for p in sorted(proteins_to_exclude)[:10])
                if len(proteins_to_exclude) > 10:
                    _preview += f" ... (+{len(proteins_to_exclude) - 10} more)"
                _items.append(mo.md(f"Excluded: {_preview}"))
            _out = mo.vstack(_items)
    _out
    return


@app.cell
def _(
    anchor_sample,
    calculated_lfq,
    filter_contaminant,
    filter_decoy,
    minimum_ratio_count,
    mo,
    n_contaminant,
    n_decoy,
    proteins_to_exclude,
    ratio_method,
    rescale_method,
):
    _out = mo.md("")
    if calculated_lfq is not None:
        _anch = str(anchor_sample.value).replace(" ", "")
        _d = 0 if filter_decoy.value else n_decoy
        _c = 0 if filter_contaminant.value else n_contaminant
        _filt = f"_decoy-{_d}_cont-{_c}_excl-{len(proteins_to_exclude)}"
        _fname = f"maxLFQmo_ratio-{ratio_method.value}_scale-{rescale_method.value}_min-{minimum_ratio_count.value}_anchor-{_anch}{_filt}.tsv"
        _csv = calculated_lfq.to_csv(sep="\t").encode("utf-8")

        _btn = mo.download(
            data=_csv,
            filename=_fname,
            label="📥 Download LFQ Table (.tsv)",
            mimetype="text/tab-separated-values"
        )
        _out = mo.vstack([
            mo.md("---"),
            mo.md("## Export Results"),
            mo.md(f"Filename will automatically reflect current parameters: `{_fname}`"),
            _btn
        ])
    _out
    return


if __name__ == "__main__":
    app.run()