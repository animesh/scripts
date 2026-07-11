import marimo as mo

app = mo.App(width="full", app_title="Inside MaxLFQ")


@app.cell
def _():
    import marimo as mo
    import pandas as pd
    import numpy as np
    import plotly.express as px
    import io
    from pathlib import Path
    from itertools import combinations
    from scipy.optimize import least_squares
    return io, combinations, least_squares, mo, np, Path, pd, px


@app.cell
def _(mo):
    mo.md(r"""
    # Inside MaxLFQ
    Interactive reverse-engineering of MaxQuant LFQ (Cox et al., MCP 2014).

    **Workflow:** peptides.txt → Delayed normalization (Eq. 2) → Pairwise ratios (Eq. 3) → Protein reconstruction → LFQ scaling → Compare vs. proteinGroups
    """)


@app.cell
def _(mo):
    mo.accordion({
        "Equations": mo.md(r"""
        **Eq. 1** Normalized: $I_{p,s}(N) = N_s\, X_{p,s}$

        **Eq. 2** Normalization: $H(N) = \sum_{p,i,j} \left[\log\frac{I_{p,i}(N)}{I_{p,j}(N)}\right]^2 \to \min$

        **Eq. 3** Profile constraint: $\log I_i - \log I_j = \log r_{ij}$, solved via least-squares
        """)
    })


@app.cell
def _(mo):
    peptide_file = mo.ui.file(label="peptides.txt")
    proteingroup_file = mo.ui.file(label="proteinGroups.txt")
    return peptide_file, proteingroup_file


@app.cell
def _(mo, peptide_file, proteingroup_file):
    mo.hstack([peptide_file, proteingroup_file], gap=4)


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
def _(pd, io):
    def read_uploaded_table(uploaded_file):
        name = uploaded_file.name.lower()
        content_stream = io.BytesIO(uploaded_file.contents)
        
        if name.endswith((".txt", ".tsv")):
            return pd.read_csv(content_stream, sep="\t", low_memory=False)
        if name.endswith(".csv"):
            return pd.read_csv(content_stream, low_memory=False)
        if name.endswith(".xlsx"):
            return pd.read_excel(content_stream, engine="openpyxl")
        return pd.read_csv(content_stream, sep=None, engine="python")
    return (read_uploaded_table,)


@app.cell
def _(peptide_file, proteingroup_file, read_uploaded_table):
    peptide_df = None
    protein_groups_df = None
    _pep_err = None
    _pg_err = None
    
    if peptide_file.value:
        try:
            peptide_df = read_uploaded_table(peptide_file.value[0])
        except Exception as e:
            _pep_err = str(e)
            
    if proteingroup_file.value:
        try:
            protein_groups_df = read_uploaded_table(proteingroup_file.value[0])
        except Exception as e:
            _pg_err = str(e)
            
    load_errors = {"peptide": _pep_err, "pg": _pg_err}
    return load_errors, peptide_df, protein_groups_df


@app.cell
def _(peptide_df, first_col):
    if peptide_df is None:
        protein_col = modified_sequence_col = sequence_col = modifications_col = charge_col = intensity_cols = samples = None
    else:
        protein_col = first_col(peptide_df, ["Leading razor protein", "Razor protein", "Proteins", "Protein IDs"])
        modified_sequence_col = first_col(peptide_df, ["Modified sequence", "Modified Sequence"])
        sequence_col = first_col(peptide_df, ["Sequence", "Peptide sequence", "Peptide"])
        modifications_col = first_col(peptide_df, ["Modifications", "Modification"])
        charge_col = first_col(peptide_df, ["Charge", "Charges", "z"])
        intensity_cols = [c for c in peptide_df.columns if str(c).startswith("Intensity ")]
        samples = [c.replace("Intensity ", "", 1) for c in intensity_cols]
    return charge_col, intensity_cols, modifications_col, modified_sequence_col, protein_col, samples, sequence_col


@app.cell
def _(mo, samples):
    # Dynamic settings widgets generated reactively once files are processed
    species_mode = mo.ui.dropdown(
        options=["ModifiedSequence+Charge", "ModifiedSequence", "Sequence+Charge", "Sequence"],
        value="ModifiedSequence+Charge", label="Peptide species",
    )
    aggregation_mode = mo.ui.dropdown(options=["max", "sum"], value="max", label="Aggregation Method")
    ratio_method = mo.ui.dropdown(options=["median", "mean"], value="median", label="Ratio method")
    rescale_method = mo.ui.dropdown(options=["max", "sum"], value="max", label="Rescaling Profile")
    
    # Dynamic Anchor Selection Dropdown
    anchor_sample = mo.ui.dropdown(
        options=["All Samples Average"] + (samples if samples else []),
        value="All Samples Average",
        label="Scaling Anchor Target"
    )
    
    minimum_ratio_count = mo.ui.number(start=1, stop=50, value=1, label="Min shared peptides")
    return aggregation_mode, minimum_ratio_count, ratio_method, rescale_method, species_mode, anchor_sample


@app.cell
def _(mo, species_mode, aggregation_mode, ratio_method, rescale_method, anchor_sample, minimum_ratio_count, samples):
    if samples is None:
        _out = mo.md("")
    else:
        _out = mo.vstack([
            mo.md("### Parameter Adjustments"),
            mo.hstack([species_mode, aggregation_mode, ratio_method, rescale_method, anchor_sample, minimum_ratio_count], gap=2)
        ])
    _out


@app.cell
def _(mo, peptide_df, protein_groups_df, load_errors):
    if load_errors.get("peptide"):
        _out = mo.callout(mo.md(f"**Error loading peptides.txt:** {load_errors['peptide']}"), kind="danger")
    elif peptide_df is None:
        _out = mo.callout(mo.md("Upload **peptides.txt** above to begin. **proteinGroups.txt** is optional (enables comparison plots)."), kind="info")
    else:
        _stats = [
            mo.stat(label="Peptide rows", value=f"{len(peptide_df):,} lines"),
            mo.stat(label="Peptide columns", value=f"{len(peptide_df.columns):,}"),
        ]
        if protein_groups_df is not None:
            _stats.append(mo.stat(label="ProteinGroup rows", value=f"{len(protein_groups_df):,}"))
        if load_errors.get("pg"):
            _stats.append(mo.callout(mo.md(f"proteinGroups error: {load_errors['pg']}"), kind="warn"))
        _out = mo.hstack(_stats)
    _out


@app.cell
def _(mo, protein_col, modified_sequence_col, sequence_col, charge_col, intensity_cols):
    _txt = "" if protein_col is None else f"**Detected columns:** protein=`{protein_col}` | mod-seq=`{modified_sequence_col}` | seq=`{sequence_col}` | charge=`{charge_col}` | **{len(intensity_cols or [])} raw intensity tracks parsed**"
    mo.md(_txt)


@app.cell
def _(peptide_df, protein_col, intensity_cols, first_token, pd, np):
    if peptide_df is None or protein_col is None:
        clean = None
    else:
        clean = peptide_df.copy()
        for _flag in ["Reverse", "Potential contaminant", "Contaminant"]:
            if _flag in clean.columns:
                clean = clean[clean[_flag].astype(str).str.strip() != "+"]
        clean[intensity_cols] = clean[intensity_cols].apply(pd.to_numeric, errors="coerce").replace(0, np.nan)
        clean = clean[clean[intensity_cols].notna().any(axis=1)].copy()
        clean["_protein"] = clean[protein_col].astype(str).map(first_token)
    return (clean,)


@app.cell
def _(clean, species_mode, modified_sequence_col, sequence_col, modifications_col, charge_col, pd):
    if clean is None:
        species_df = None
    else:
        species_df = clean.copy()
        if modified_sequence_col:
            modseq = species_df[modified_sequence_col].astype(str)
        elif sequence_col and modifications_col:
            modseq = species_df[sequence_col].astype(str) + "|" + species_df[modifications_col].astype(str)
        elif sequence_col:
            modseq = species_df[sequence_col].astype(str)
        else:
            modseq = pd.Series("UNKNOWN", index=species_df.index)
        charge = species_df[charge_col].astype(str).str.strip() if charge_col else pd.Series("NA", index=species_df.index)
        if species_mode.value in ("ModifiedSequence+Charge", "Sequence+Charge"):
            species_df["_species"] = modseq + "|z=" + charge
        else:
            species_df["_species"] = modseq
    return (species_df,)


@app.cell
def _(species_df, samples, intensity_cols, aggregation_mode, np):
    if species_df is None:
        species_matrix = None
    else:
        _rename = dict(zip(intensity_cols, samples))
        _w = species_df[["_protein", "_species"] + intensity_cols].rename(columns=_rename)
        _grp = _w.groupby(["_protein", "_species"], sort=True)[samples]
        species_matrix = (_grp.max() if aggregation_mode.value == "max" else _grp.sum(min_count=1)).replace(0, np.nan)
    return (species_matrix,)


@app.cell
def _(mo, species_matrix):
    if species_matrix is None:
        _out = mo.md("")
    else:
        _fill = species_matrix.notna().values.sum()
        _out = mo.hstack([
            mo.stat(label="Proteins", value=f"{species_matrix.index.get_level_values(0).nunique():,}"),
            mo.stat(label="Species Matrix Rows", value=f"{len(species_matrix):,}"),
            mo.stat(label="Matrix Sparsity Fill", value=f"{100*_fill/species_matrix.size:.1f}%"),
        ])
    _out


@app.cell
def _(np, species_matrix, samples, combinations, least_squares):
    if species_matrix is None:
        logX = n_samples = normalization_residuals = None
    else:
        logX = np.log(species_matrix.values.astype(float))
        n_samples = len(samples)
        _pairs = list(combinations(range(n_samples), 2))

        def normalization_residuals(logN):
            blocks = []
            for _a, _b in _pairs:
                _ok = np.isfinite(logX[:, _a]) & np.isfinite(logX[:, _b])
                if _ok.any():
                    blocks.append(logX[_ok, _a] + logN[_a] - logX[_ok, _b] - logN[_b])
            return np.concatenate(blocks) if blocks else np.array([0.0])

    return logX, n_samples, normalization_residuals


@app.cell
def _(np, n_samples, normalization_residuals, least_squares):
    if normalization_residuals is None:
        N_scale_free = H_before = None
    else:
        _res0 = normalization_residuals(np.zeros(n_samples))
        H_before = float(np.sum(_res0 ** 2))
        _method = "lm" if len(_res0) >= n_samples else "trf"
        _fit = least_squares(normalization_residuals, np.zeros(n_samples), method=_method, max_nfev=2000)
        N_scale_free = np.exp(_fit.x)
    return H_before, N_scale_free


@app.cell
def _(np, pd, samples, N_scale_free, normalization_residuals):
    if N_scale_free is None:
        N = H_after = normalization_table = None
    else:
        N = N_scale_free / N_scale_free[0]
        H_after = float(np.sum(normalization_residuals(np.log(N)) ** 2))
        normalization_table = pd.DataFrame({"Sample": samples, "N": N, "log2_N": np.log2(N)})
    return H_after, N, normalization_table


@app.cell
def _(mo, H_before, H_after, normalization_table, px):
    if normalization_table is None:
        _out = mo.md("")
    else:
        _reduction = f"{100*(1-H_after/H_before):.1f}%" if H_before and H_before > 0 else "n/a"
        _out = mo.vstack([
            mo.md("## Normalization (Eq. 2)"),
            mo.hstack([
                mo.stat(label="H before", value=f"{H_before:,.0f}"),
                mo.stat(label="H after", value=f"{H_after:,.0f}"),
                mo.stat(label="Objective Residual Reduction", value=_reduction),
            ]),
            px.bar(normalization_table, x="Sample", y="log2_N", title="log2 Normalization Factors"),
        ])
    _out


@app.cell
def _(species_matrix, normalization_table, np):
    if species_matrix is None or normalization_table is None:
        normalized_species_matrix = None
    else:
        normalized_species_matrix = species_matrix.copy()
        _nlookup = dict(zip(normalization_table["Sample"], normalization_table["N"]))
        for _s in normalized_species_matrix.columns:
            normalized_species_matrix[_s] = normalized_species_matrix[_s] * _nlookup.get(_s, 1.0)
    return (normalized_species_matrix,)


@app.cell
def _(mo, normalized_species_matrix, normalization_table, samples, px, pd):
    if normalized_species_matrix is None or normalization_table is None:
        _out = mo.md("")
    else:
        _nlookup = dict(zip(normalization_table["Sample"], normalization_table["N"]))
        _rows = [{"Sample": _s,
                  "Raw": normalized_species_matrix[_s].sum(skipna=True) / _nlookup.get(_s, 1.0),
                  "Normalized": normalized_species_matrix[_s].sum(skipna=True)}
                 for _s in samples if _s in normalized_species_matrix.columns]
        _out = mo.vstack([
            mo.md("## Raw vs Normalized Totals (Eq. 1)"),
            px.bar(pd.DataFrame(_rows), x="Sample", y=["Raw", "Normalized"], barmode="group"),
        ])
    _out


@app.cell
def _(normalized_species_matrix):
    if normalized_species_matrix is None:
        protein_list = None
    else:
        protein_list = (normalized_species_matrix.reset_index()["_protein"]
                        .drop_duplicates().sort_values().tolist())
    return (protein_list,)


@app.cell
def _(mo, protein_list):
    protein_selector = mo.ui.dropdown(
        options=protein_list or [],
        value=(protein_list[0] if protein_list else None),
        label="Select protein to trace",
    )
    return (protein_selector,)


@app.cell
def _(mo, protein_selector, protein_list):
    _out = mo.md("") if not protein_list else mo.vstack([mo.md("## Individual Protein Profile Tracker"), protein_selector])
    _out


@app.cell
def _(mo, protein_selector, normalized_species_matrix, protein_list, px):
    if not protein_list or normalized_species_matrix is None or protein_selector.value is None:
        _out = mo.md("")
    else:
        _prot = protein_selector.value
        _psm = normalized_species_matrix.loc[_prot].copy()
        _long = (_psm.reset_index()
                  .melt(id_vars="_species", var_name="Sample", value_name="Intensity")
                  .dropna(subset=["Intensity"]))
        _out = mo.vstack([
            px.bar(_long, x="Sample", y="Intensity", color="_species", log_y=True,
                   title=f"{_prot} - Normalized Species Intensities"),
            mo.md(f"**{_prot}** - {len(_psm)} species detected"),
            _psm,
        ])
    _out


@app.cell
def _(np, pd, samples, normalized_species_matrix, combinations, ratio_method, minimum_ratio_count):
    if normalized_species_matrix is None:
        pairwise_ratio_trace = None
    else:
        _rows = []
        _ns = len(samples)
        for _protein, _pdf in normalized_species_matrix.groupby(level=0, sort=True):
            _logm = np.log2(_pdf.values.astype(float))
            for _j, _k in combinations(range(_ns), 2):
                _ok = np.isfinite(_logm[:, _j]) & np.isfinite(_logm[:, _k])
                _nsh = int(_ok.sum())
                if _nsh < minimum_ratio_count.value:
                    continue
                _r = float(np.median(_logm[_ok, _j] - _logm[_ok, _k]) if ratio_method.value == "median"
                           else np.mean(_logm[_ok, _j] - _logm[_ok, _k]))
                _rows.append({"Protein": _protein, "Sample_A": samples[_j], "Sample_B": samples[_k],
                              "Shared_Species": _nsh, "log2_ratio_A_over_B": _r})
        pairwise_ratio_trace = pd.DataFrame(_rows)
    return (pairwise_ratio_trace,)


@app.cell
def _(mo, pairwise_ratio_trace, px):
    if pairwise_ratio_trace is None or len(pairwise_ratio_trace) == 0:
        _out = mo.md("")
    else:
        _out = mo.vstack([
            mo.md("## Pairwise Ratios (Eq. 3 inputs)"),
            mo.stat(label="Reconstructed Protein-pair ratios", value=f"{len(pairwise_ratio_trace):,}"),
            px.histogram(pairwise_ratio_trace, x="Shared_Species", title="Shared Peptides Distribution per Sample Pair"),
        ])
    _out


@app.cell
def _(np, pd, samples, normalized_species_matrix, rescale_method, anchor_sample, combinations, minimum_ratio_count):
    if normalized_species_matrix is None:
        calculated_lfq = None
    else:
        _calc_rows = []
        _ns = len(samples)
        for _protein, _pdf in normalized_species_matrix.groupby(level=0, sort=True):
            _mat = _pdf.values.astype(float)
            _logm = np.log2(_mat)
            _ratio_mat = np.full((_ns, _ns), np.nan)
            for _j, _k in combinations(range(_ns), 2):
                _ok = np.isfinite(_logm[:, _j]) & np.isfinite(_logm[:, _k])
                if _ok.sum() < minimum_ratio_count.value:
                    continue
                _r = float(np.median(_logm[_ok, _j] - _logm[_ok, _k]))
                _ratio_mat[_j, _k] = _r
                _ratio_mat[_k, _j] = -_r
            _valid = np.where(np.isfinite(_ratio_mat).any(axis=0))[0]
            _out_v = np.full(_ns, np.nan)
            if len(_valid) > 1:
                _rls, _vls = [], []
                for _a, _b in combinations(range(len(_valid)), 2):
                    _rv = _ratio_mat[_valid[_a], _valid[_b]]
                    if np.isfinite(_rv):
                        _eq = np.zeros(len(_valid))
                        _eq[_a] = 1.0; _eq[_b] = -1.0
                        _rls.append(_eq); _vls.append(_rv)
                if _rls:
                    _sol, *_ = np.linalg.lstsq(np.asarray(_rls), np.asarray(_vls), rcond=None)
                    _rel = 2.0 ** _sol
                    
                    # Target scaling anchor based on the selected dynamic dropdown choice
                    if anchor_sample.value != "All Samples Average" and anchor_sample.value in samples:
                        _idx = samples.index(anchor_sample.value)
                        if _idx in _valid:
                            _v_idx = np.where(_valid == _idx)[0][0]
                            _rel = _rel / _rel[_v_idx]
                    
                    _comp = _mat[:, _valid]
                    _anch = np.nanmax(_comp, axis=0) if rescale_method.value == "max" else np.nansum(_comp, axis=0)
                    _active = np.isfinite(_rel) & np.isfinite(_anch) & (_rel > 0) & (_anch > 0)
                    if _active.any():
                        _scale = np.nansum(_anch[_active]) / np.nansum(_rel[_active])
                        _out_v[_valid] = _rel * _scale
            _crow = {"Protein": _protein}
            for _s, _v in zip(samples, _out_v):
                _crow["LFQ intensity " + _s] = _v if (np.isfinite(_v) and _v > 0) else np.nan
            _calc_rows.append(_crow)
        calculated_lfq = pd.DataFrame(_calc_rows).set_index("Protein")
    return (calculated_lfq,)


@app.cell
def _(mo, calculated_lfq):
    if calculated_lfq is None:
        _out = mo.md("")
    else:
        _filled = calculated_lfq.notna().values.sum()
        _out = mo.vstack([
            mo.md("## Calculated LFQ Data Output"),
            mo.hstack([
                mo.stat(label="Proteins Quantified", value=f"{len(calculated_lfq):,}"),
                mo.stat(label="Valid LFQ Values", value=f"{_filled:,}"),
                mo.stat(label="Fill Rate", value=f"{100*_filled/calculated_lfq.size:.1f}%"),
            ]),
            calculated_lfq.head(20),
        ])
    _out


@app.cell
def _(protein_groups_df, calculated_lfq, first_token, pd, np, samples):
    if protein_groups_df is None or calculated_lfq is None:
        comparison_trace = reference_lfq = None
    else:
        _pg = protein_groups_df.copy()
        for _flag in ["Reverse", "Potential contaminant", "Contaminant"]:
            if _flag in _pg.columns:
                _pg = _pg[_pg[_flag].astype(str).str.strip() != "+"]
        _pid_col = "Majority protein IDs" if "Majority protein IDs" in _pg.columns else "Protein IDs"
        _pg["_protein"] = _pg[_pid_col].map(first_token)
        _lfq_cols = [c for c in _pg.columns if str(c).startswith("LFQ intensity ")]
        reference_lfq = (
            _pg[["_protein"] + _lfq_cols].set_index("_protein")
            .apply(pd.to_numeric, errors="coerce").replace(0, np.nan)
        )
        reference_lfq.columns = [c.replace("LFQ intensity ", "", 1) for c in reference_lfq.columns]
        _common = calculated_lfq.index.intersection(reference_lfq.index)
        _shared_samp = [s for s in samples if s in reference_lfq.columns]
        _rows = []
        for _prot in _common:
            for _s in _shared_samp:
                _calc_col = "LFQ intensity " + _s
                _calc = calculated_lfq.loc[_prot, _calc_col] if _calc_col in calculated_lfq.columns else np.nan
                _ref = reference_lfq.loc[_prot, _s]
                _d = float(np.log2(_calc / _ref)) if (pd.notna(_calc) and pd.notna(_ref) and _calc > 0 and _ref > 0) else np.nan
                _rows.append({"Protein": _prot, "Sample": _s,
                               "Calculated_LFQ": _calc, "ProteinGroups_LFQ": _ref, "Log2_Calc_over_PG": _d})
        comparison_trace = pd.DataFrame(_rows)
    return comparison_trace, reference_lfq


@app.cell
def _(mo, comparison_trace, calculated_lfq, H_before, H_after, np):
    if comparison_trace is None or calculated_lfq is None or "Log2_Calc_over_PG" not in comparison_trace.columns:
        _out = mo.md("")
    else:
        _valid = comparison_trace["Log2_Calc_over_PG"].dropna().values
        _out = mo.vstack([
            mo.md("## Validation vs. MaxQuant proteinGroups Reference"),
            mo.hstack([
                mo.stat(label="Proteins Calculated", value=f"{len(calculated_lfq):,}"),
                mo.stat(label="Intersecting Proteins", value=f"{comparison_trace['Protein'].nunique():,}"),
                mo.stat(label="Compared Elements", value=f"{len(_valid):,}"),
                mo.stat(label="Median Log2 Residual", value=f"{float(np.median(_valid)):.3f}" if len(_valid) else "n/a"),
                mo.stat(label="Mean Absolute Error (MAE)", value=f"{float(np.mean(np.abs(_valid))):.3f}" if len(_valid) else "n/a"),
            ]),
        ])
    _out


@app.cell
def _(mo, comparison_trace, px):
    if comparison_trace is None or len(comparison_trace) == 0 or "Log2_Calc_over_PG" not in comparison_trace.columns:
        _out = mo.md("")
    else:
        _valid = comparison_trace.dropna(subset=["Calculated_LFQ", "ProteinGroups_LFQ"])
        _bias = comparison_trace.groupby("Sample").agg(mean_log2_diff=("Log2_Calc_over_PG", "mean")).reset_index()
        _out = mo.ui.tabs({
            "Scatter Profile": px.scatter(_valid, x="Calculated_LFQ", y="ProteinGroups_LFQ",
                                  hover_data=["Protein", "Sample"], opacity=0.5,
                                  title="Calculated Intensity Correlation Curve", log_x=True, log_y=True),
            "Residual Variance": px.histogram(_valid, x="Log2_Calc_over_PG", nbins=60,
                                       title="Residual Errors Distribution (log2 Calculated / MaxQuant Reference)"),
            "Sample Normalization Bias": px.bar(_bias, x="Sample", y="mean_log2_diff", title="Mean Variance by Sample Group"),
            "Top Discrepancy Outliers": comparison_trace.sort_values("Log2_Calc_over_PG",
                                                          key=lambda x: x.abs(), ascending=False).head(50),
        })
    _out


@app.cell
def _(mo):
    mo.md("""---
    **System Architecture:** Reactive variables binding | dynamic downstream re-scaling matrices | inline parsing engines.
    """)


if __name__ == "__main__":
    app.run()