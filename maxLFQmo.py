## [tool.marimo.runtime]
## auto_instantiate = false
## uv add pandas plotly scipy
## #animeshs@ubuntu:~/scripts$ uv run marimo edit maxLFQmo.py --host 0.0.0.0 --port 2718
## http://10.20.93.118:2718?access_token=J8CZerX-fwfcr_CRZUK_Rw

import marimo

__generated_with = "0.23.13"
app = marimo.App(width="full")


@app.cell
def _():
    import marimo as mo

    import pandas as pd
    import numpy as np

    import plotly.express as px
    import plotly.graph_objects as go

    from pathlib import Path
    from itertools import combinations

    from scipy.optimize import least_squares



    return Path, combinations, least_squares, mo, np, pd, px


@app.cell
def _(mo):
    mo.md(r"""
    # Inside MaxLFQ

    ## Interactive Reverse Engineering of MaxQuant LFQ

    This notebook is an interactive implementation of the
    MaxLFQ workflow described by Cox et al.

    ---

    ## Workflow

    Peptide Intensities

    ↓

    Species Construction

    ↓

    Equation 2 Delayed Normalization

    ↓

    Equation 1 Normalized Intensities

    ↓

    Pairwise Peptide Ratios

    ↓

    Equation 3 Protein Profile Reconstruction

    ↓

    LFQ Scaling

    ↓

    Comparison Against proteinGroups.txt

    ---

    This notebook allows users to:

    - Upload MaxQuant outputs
    - Reconstruct LFQ step-by-step
    - Explore normalization factors
    - Inspect pairwise ratio graphs
    - Compare reconstructed LFQ to proteinGroups LFQ
    - Investigate reconstruction residuals
    """)
    return


@app.cell
def _(mo):
    mo.md(r"""
    # Equation 1

    Normalized peptide intensity

    $$
    I_{p,s}(N)
    =
    N_s X_{p,s}
    $$

    where

    - $X_{p,s}$ = observed peptide intensity
    - $N_s$ = normalization factor
    - $I_{p,s}(N)$ = normalized peptide intensity
    """)
    return


@app.cell
def _(mo):
    mo.md(r"""
    # Equation 2

    Delayed normalization objective

    $$
    H(N)
    =
    \sum
    \left[
    \log
    \left(
    \frac{I_{p,i}(N)}
     {I_{p,j}(N)}
    \right)
    \right]^2
    $$

    over all shared peptide species and sample pairs.
    """)
    return


@app.cell
def _(mo):
    mo.md(r"""
    # Equation 3

    Protein profile reconstruction

    $$
    \log I_i
    -
    \log I_j
    =
    \log(r_{ij})
    $$

    where

    $$
    r_{ij}
    $$

    is the representative peptide ratio
    between samples.
    """)
    return


@app.cell
def _(mo):

    peptide_path_widget = mo.ui.text(
        value="peptides.txt",
        label="Peptides file",
    )

    protein_groups_path_widget = mo.ui.text(
        value="proteinGroups.txt",
        label="ProteinGroups file",
    )

    _path_selector_view = mo.vstack(
        [
            peptide_path_widget,
            protein_groups_path_widget,
        ]
    )

    _path_selector_view

    return (
        peptide_path_widget,
        protein_groups_path_widget,
    )


@app.cell
def _(mo, peptide_df, protein_groups_df):
    mo.md(f"""
    # Debug

    Peptide loaded:
    {peptide_df is not None}

    ProteinGroups loaded:
    {protein_groups_df is not None}

    Peptide rows:
    {0 if peptide_df is None else len(peptide_df)}

    ProteinGroups rows:
    {0 if protein_groups_df is None else len(protein_groups_df)}
    """)
    return


@app.cell
def _(mo):

    species_mode = mo.ui.dropdown(
        options=[
            "ModifiedSequence+Charge",
            "ModifiedSequence",
            "Sequence+Charge",
            "Sequence",
        ],
        value="ModifiedSequence+Charge",
        label="Species Definition",
    )

    aggregation_mode = mo.ui.dropdown(
        options=[
            "max",
            "sum",
        ],
        value="max",
        label="Species Aggregation",
    )

    ratio_method = mo.ui.dropdown(
        options=[
            "median",
            "mean",
        ],
        value="median",
        label="Ratio Method",
    )

    rescale_method = mo.ui.dropdown(
        options=[
            "max",
            "sum",
        ],
        value="max",
        label="Protein Rescaling",
    )

    min_ratio_count = mo.ui.number(
        start=1,
        stop=50,
        value=1,
        label="Minimum Shared Species",
    )

    mo.vstack(
        [
            species_mode,
            aggregation_mode,
            ratio_method,
            rescale_method,
            min_ratio_count,
        ]
    )
    return aggregation_mode, rescale_method, species_mode

@app.cell
def _(
    mo,
    species_mode,
    aggregation_mode,
    ratio_method,
    rescale_method,
):

    _settings_view = mo.md(
        f"""
# Current Settings

Species Mode

`{species_mode.value}`

Aggregation Mode

`{aggregation_mode.value}`

Ratio Method

`{ratio_method.value}`

Rescale Method

`{rescale_method.value}`
"""
    )

    _settings_view

    return

@app.cell
def _():
    def first_existing_column(
        df,
        candidates,
    ):
        for col in candidates:
            if col in df.columns:
                return col
        return None


    def first_token(value):
        return str(value).split(";")[0].strip()

    return first_existing_column, first_token


@app.cell
def _(Path, pd):

    def read_table(path):

        path = Path(path)

        suffix = path.suffix.lower()

        if suffix in [".txt", ".tsv"]:
            return pd.read_csv(
                path,
                sep="\t",
                low_memory=False,
            )

        if suffix == ".csv":
            return pd.read_csv(
                path,
                low_memory=False,
            )

        if suffix == ".xlsx":
            return pd.read_excel(
                path,
                engine="openpyxl",
            )

        if suffix == ".xls":
            return pd.read_excel(
                path,
                engine="xlrd",
            )

        return pd.read_csv(
            path,
            sep=None,
            engine="python",
        )

    return (read_table,)


@app.cell
def _(
    peptide_path_widget,
    protein_groups_path_widget,
    read_table,
):

    peptide_df = None
    protein_groups_df = None

    try:

        peptide_df = read_table(
            peptide_path_widget.value
        )

    except Exception as e:

        print(
            "PEPTIDE LOAD ERROR:",
            e,
        )

    try:

        protein_groups_df = read_table(
            protein_groups_path_widget.value
        )

    except Exception as e:

        print(
            "PROTEINGROUPS LOAD ERROR:",
            e,
        )

    return (
        peptide_df,
        protein_groups_df,
    )

@app.cell
def _(mo, peptide_df):
    if peptide_df is None:

        mo.md(
            """
    ## Input Data

    Upload a peptide table.
    """
        )

    else:

        mo.vstack(
            [
                mo.md(
                    f"""
    ## Peptide Table

    Rows

    **{len(peptide_df):,}**

    Columns

    **{len(peptide_df.columns):,}**
    """
                ),
                mo.ui.table(
                    peptide_df.head(20)
                ),
            ]
        )
    return


@app.cell
def _(first_existing_column, peptide_df):

    if peptide_df is None:

        protein_col = None
        modified_sequence_col = None
        sequence_col = None
        modifications_col = None
        charge_col = None
        intensity_cols = []
        samples = []

    else:

        protein_col = (
            first_existing_column(
                peptide_df,
                [
                    "Leading razor protein",
                    "Razor",
                    "Razor protein",
                    "Proteins",
                    "Protein",
                    "Protein IDs",
                ],
            )
        )

        modified_sequence_col = (
            first_existing_column(
                peptide_df,
                [
                    "Modified sequence",
                    "Modified Sequence",
                    "Modified peptide sequence",
                ],
            )
        )

        sequence_col = (
            first_existing_column(
                peptide_df,
                [
                    "Sequence",
                    "Peptide sequence",
                    "Peptide",
                ],
            )
        )

        modifications_col = (
            first_existing_column(
                peptide_df,
                [
                    "Modifications",
                    "Modification",
                ],
            )
        )

        charge_col = (
            first_existing_column(
                peptide_df,
                [
                    "Charge",
                    "Charges",
                    "z",
                ],
            )
        )

        intensity_cols = [
            c
            for c in peptide_df.columns
            if str(c).startswith(
                "Intensity "
            )
        ]

        samples = [
            c.replace(
                "Intensity ",
                "",
                1,
            )
            for c in intensity_cols
        ]
    return (
        charge_col,
        intensity_cols,
        modifications_col,
        modified_sequence_col,
        protein_col,
        samples,
        sequence_col,
    )


@app.cell
def _(
    charge_col,
    intensity_cols,
    mo,
    modifications_col,
    modified_sequence_col,
    protein_col,
    sequence_col,
):
    mo.md(f"""
    # Auto Detection

    Protein column

    `{protein_col}`

    Modified sequence column

    `{modified_sequence_col}`

    Sequence column

    `{sequence_col}`

    Modifications column

    `{modifications_col}`

    Charge column

    `{charge_col}`

    Intensity columns

    `{len(intensity_cols)}`
    """)
    return


@app.cell
def _(intensity_cols, mo, peptide_df, samples):
    mo.md(f"""
    # Data Check

    Rows

    {0 if peptide_df is None else len(peptide_df)}

    Intensity columns

    {len(intensity_cols)}

    Samples

    {samples}
    """)
    return


@app.cell
def _(first_token, intensity_cols, np, pd, peptide_df, protein_col):

    if peptide_df is None:

        clean = None

    else:

        clean = peptide_df.copy()

        for flag_col in [
            "Reverse",
            "Potential contaminant",
            "Contaminant",
        ]:

            if flag_col in clean.columns:

                clean = clean[
                    clean[flag_col]
                    .astype(str)
                    .str.strip()
                    != "+"
                ]

        if len(intensity_cols) > 0:

            clean[intensity_cols] = (
                clean[intensity_cols]
                .apply(
                    pd.to_numeric,
                    errors="coerce",
                )
                .replace(
                    0,
                    np.nan,
                )
            )

            clean = clean[
                clean[intensity_cols]
                .notna()
                .any(axis=1)
            ].copy()

        clean["_protein"] = (
            clean[protein_col]
            .astype(str)
            .map(first_token)
        )
    return (clean,)


@app.cell
def _(clean, mo):

    if clean is None:

        mo.md(
            """
    ## Clean Table

    Waiting for peptide data.
    """
        )

    else:

        mo.vstack(
            [
                mo.md(
                    f"""
    ## Clean Table

    Rows remaining after filtering

    **{len(clean):,}**
    """
                ),
                mo.ui.table(
                    clean.head(20)
                ),
            ]
        )
    return


@app.cell
def _(
    charge_col,
    clean,
    modifications_col,
    modified_sequence_col,
    pd,
    sequence_col,
    species_mode,
):

    if clean is None:

        species_df = None

    else:

        species_df = clean.copy()

        if modified_sequence_col is not None:

            modseq = (
                species_df[
                    modified_sequence_col
                ]
                .astype(str)
            )

        elif (
            sequence_col is not None
            and modifications_col is not None
        ):

            modseq = (
                species_df[
                    sequence_col
                ].astype(str)
                + "|mods="
                + species_df[
                    modifications_col
                ].astype(str)
            )

        elif sequence_col is not None:

            modseq = (
                species_df[
                    sequence_col
                ].astype(str)
            )

        else:

            modseq = pd.Series(
                "UNKNOWN",
                index=species_df.index,
            )

        if charge_col is not None:

            charge = (
                species_df[
                    charge_col
                ]
                .astype(str)
                .str.strip()
            )

        else:

            charge = pd.Series(
                "NA",
                index=species_df.index,
            )

        mode = (
            species_mode.value
        )

        if mode == "Sequence":

            species_df["_species"] = (
                modseq
            )

        elif mode == "ModifiedSequence":

            species_df["_species"] = (
                modseq
            )

        elif mode == "Sequence+Charge":

            species_df["_species"] = (
                modseq
                + "|z="
                + charge
            )

        else:

            species_df["_species"] = (
                modseq
                + "|z="
                + charge
            )
    return (species_df,)


@app.cell
def _(mo, species_df):
    mo.md(f"""
    # Species Debug

    species_df exists:

    {species_df is not None}

    species rows:

    {0 if species_df is None else len(species_df)}

    unique proteins:

    {0 if species_df is None else species_df['_protein'].nunique()}

    unique species:

    {0 if species_df is None else species_df['_species'].nunique()}
    """)
    return


@app.cell
def _(mo, species_matrix):
    mo.md(f"""
    # Species Matrix Debug

    Exists:

    {species_matrix is not None}

    Rows:

    {0 if species_matrix is None else len(species_matrix)}

    Columns:

    {0 if species_matrix is None else len(species_matrix.columns)}
    """)
    return


@app.cell
def _(aggregation_mode, intensity_cols, np, samples, species_df):

    if species_df is None:

        working = None
        species_matrix = None

    else:

        rename_map = {
            old: sample
            for old, sample
            in zip(
                intensity_cols,
                samples,
            )
        }

        working = (
            species_df[
                ["_protein", "_species"]
                + intensity_cols
            ]
            .rename(
                columns=rename_map
            )
            .copy()
        )

        if (
            aggregation_mode.value
            == "max"
        ):

            species_matrix = (
                working
                .groupby(
                    [
                        "_protein",
                        "_species",
                    ],
                    sort=True,
                )[samples]
                .max()
            )

        else:

            species_matrix = (
                working
                .groupby(
                    [
                        "_protein",
                        "_species",
                    ],
                    sort=True,
                )[samples]
                .sum(
                    min_count=1
                )
            )

        species_matrix = (
            species_matrix
            .replace(
                0,
                np.nan,
            )
        )
    return (species_matrix,)


@app.cell
def _(mo, species_matrix):

    if species_matrix is None:

        view = mo.md(
            """
## Species Matrix

Waiting for data.
"""
        )

    else:

        proteins = (
            species_matrix
            .index
            .get_level_values(0)
            .nunique()
        )

        species_count = (
            len(
                species_matrix
            )
        )

        view = mo.vstack(
            [
                mo.md(
                    f"""
# Species Matrix

Proteins

**{proteins:,}**

Protein-Species Rows

**{species_count:,}**
"""
                ),
                mo.ui.table(
                    species_matrix
                    .head(25)
                ),
            ]
        )

    view

    return

@app.cell
def _(species_matrix):

    if species_matrix is None:

        species_summary = None

    else:

        species_summary = (
            species_matrix
            .reset_index()
            .groupby(
                "_protein"
            )
            .agg(
                species_count=(
                    "_species",
                    "nunique",
                )
            )
            .sort_values(
                "species_count",
                ascending=False,
            )
            .reset_index()
        )
    return (species_summary,)


@app.cell
def _(mo, species_summary):

    if species_summary is not None:

        mo.vstack(
            [
                mo.md(
                    """
    ## Species Per Protein
    """
                ),
                mo.ui.table(
                    species_summary
                    .head(50)
                ),
            ]
        )
    return


@app.cell
def _(np, species_matrix):

    if species_matrix is None:

        matrix_values = None
        matrix_stats = None

    else:

        matrix_values = (
            species_matrix
            .values
            .astype(float)
        )

        finite_mask = (
            np.isfinite(
                matrix_values
            )
        )

        matrix_stats = {
            "rows":
                species_matrix.shape[0],
            "cols":
                species_matrix.shape[1],
            "finite":
                int(
                    finite_mask.sum()
                ),
            "missing":
                int(
                    (~finite_mask).sum()
                ),
        }
    return (matrix_stats,)


@app.cell
def _(matrix_stats, mo):

    if matrix_stats is not None:

        mo.md(
            f"""
    ## Matrix Diagnostics

    Rows

    **{matrix_stats['rows']:,}**

    Columns

    **{matrix_stats['cols']:,}**

    Finite Values

    **{matrix_stats['finite']:,}**

    Missing Values

    **{matrix_stats['missing']:,}**
    """
        )
    return


@app.cell
def _(combinations, np, samples, species_matrix):

    if species_matrix is None:

        logX = None
        n_samples = None
        sample_pairs = None

    else:

        logX = np.log(
            species_matrix
            .values
            .astype(float)
        )

        n_samples = (
            len(samples)
        )

        sample_pairs = list(
            combinations(
                range(
                    n_samples
                ),
                2,
            )
        )
    return logX, n_samples, sample_pairs


@app.cell
def _(logX, np, sample_pairs):

    if logX is None:

        normalization_residuals = None

    else:

        def normalization_residuals(
            logN,
        ):

            blocks = []

            for a, b in sample_pairs:

                ok = (
                    np.isfinite(
                        logX[:, a]
                    )
                    &
                    np.isfinite(
                        logX[:, b]
                    )
                )

                if ok.any():

                    blocks.append(
                        logX[
                            ok,
                            a,
                        ]
                        + logN[a]
                        - logX[
                            ok,
                            b,
                        ]
                        - logN[b]
                    )

            if not blocks:

                return np.array(
                    [0.0]
                )

            return np.concatenate(
                blocks
            )
    return (normalization_residuals,)


@app.cell
def _(least_squares, n_samples, normalization_residuals, np):

    if (
        normalization_residuals
        is None
    ):

        H_before = None
        fit = None
        N_scale_free = None

    else:

        res_before = (
            normalization_residuals(
                np.zeros(
                    n_samples
                )
            )
        )

        H_before = float(
            np.sum(
                res_before ** 2
            )
        )

        solver = (
            "lm"
            if len(
                res_before
            )
            >= n_samples
            else "trf"
        )

        fit = (
            least_squares(
                normalization_residuals,
                np.zeros(
                    n_samples
                ),
                method=solver,
                max_nfev=2000,
            )
        )

        N_scale_free = (
            np.exp(
                fit.x
            )
        )
    return H_before, N_scale_free


@app.cell
def _(N_scale_free, normalization_residuals, np, pd, samples):

    if N_scale_free is None:

        H_after = None
        normalization_table = None

    else:

        anchor_idx = 0

        N = (
            N_scale_free
            /
            N_scale_free[
                anchor_idx
            ]
        )

        res_after = (
            normalization_residuals(
                np.log(N)
            )
        )

        H_after = float(
            np.sum(
                res_after ** 2
            )
        )

        normalization_table = (
            pd.DataFrame(
                {
                    "Sample":
                        samples,
                    "N":
                        N,
                    "log2_N":
                        np.log2(N),
                }
            )
        )
    return H_after, normalization_table


@app.cell
def _(H_after, H_before, mo, normalization_table):

    if (
        normalization_table
        is not None
    ):

        mo.vstack(
            [
                mo.md(
                    f"""
    # Equation 2

    H Before

    **{H_before:,.6f}**

    H After

    **{H_after:,.6f}**
    """
                ),
                mo.ui.table(
                    normalization_table
                ),
            ]
        )
    return


@app.cell
def _(normalization_table, px):

    if (
        normalization_table
        is None
    ):

        fig_N = None

    else:

        fig_N = px.bar(
            normalization_table,
            x="Sample",
            y="log2_N",
            title=
            "Normalization Factors",
        )
    return (fig_N,)


@app.cell
def _(fig_N):

    if fig_N is not None:
        fig_N
    return


@app.cell
def _(normalization_table, species_matrix):

    if (
        species_matrix is None
        or normalization_table is None
    ):

        normalized_species_matrix = None

    else:

        normalized_species_matrix = (
            species_matrix.copy()
        )

        for _, _norm_row in (
            normalization_table.iterrows()
        ):

            _norm_sample = _norm_row["Sample"]

            normalized_species_matrix[
                _norm_sample
            ] = (
                normalized_species_matrix[
                    _norm_sample
                ]
                * _norm_row["N"]
            )
    return (normalized_species_matrix,)


@app.cell
def _(normalization_table, normalized_species_matrix, pd, species_matrix):

    if (
        species_matrix is None
        or normalized_species_matrix is None
    ):

        raw_to_norm_trace = None

    else:

        lookup = dict(
            zip(
                normalization_table["Sample"],
                normalization_table["N"],
            )
        )

        rows = []

        preview = species_matrix.head(
            100
        )

        for (
            protein,
            species,
        ), _trace_row in preview.iterrows():

            for _trace_sample in (
                species_matrix.columns
            ):
                rows.append(
                    {
                        "Protein": protein,
                        "Species": species,
                        "Sample": _trace_sample,
                        "Raw_Intensity":
                            _trace_row[_trace_sample],
                        "N":
                            lookup[_trace_sample],
                        "Normalized_Intensity":
                            normalized_species_matrix.loc[
                                (
                                    protein,
                                    species,
                                ),
                                _trace_sample,
                            ],
                    }
                )

        raw_to_norm_trace = (
            pd.DataFrame(rows)
        )
    return (raw_to_norm_trace,)


@app.cell
def _(mo, raw_to_norm_trace):

    if raw_to_norm_trace is not None:

        mo.vstack(
            [
                mo.md(
                    """
    # Equation 1 Results

    Raw intensities
    multiplied by
    normalization factors.
    """
                ),
                mo.ui.table(
                    raw_to_norm_trace
                    .head(50)
                ),
            ]
        )
    return


@app.cell
def _(normalized_species_matrix):

    if (
        normalized_species_matrix
        is None
    ):

        protein_list = []

    else:

        protein_list = (
            normalized_species_matrix
            .reset_index()["_protein"]
            .drop_duplicates()
            .sort_values()
            .tolist()
        )
    return (protein_list,)


@app.cell
def _(mo, protein_list):

    if len(protein_list) == 0:

        protein_selector = None

    else:

        protein_selector = (
            mo.ui.dropdown(
                options=protein_list,
                value=protein_list[0],
                label="Protein",
            )
        )

        protein_selector
    return (protein_selector,)


@app.cell
def _(normalized_species_matrix, protein_selector):

    if (
        protein_selector is None
        or normalized_species_matrix is None
    ):

        selected_protein = None
        protein_matrix = None

    else:

        selected_protein = (
            protein_selector.value
        )

        protein_matrix = (
            normalized_species_matrix
            .loc[selected_protein]
            .copy()
        )
    return protein_matrix, selected_protein


@app.cell
def _(mo, protein_matrix, selected_protein):

    if (
        selected_protein is not None
        and protein_matrix is not None
    ):

        mo.vstack(
            [
                mo.md(
                    f"""
    # Protein Explorer

    Selected Protein

    `{selected_protein}`
    """
                ),
                mo.ui.table(
                    protein_matrix
                ),
            ]
        )
    return


@app.cell
def _(
    combinations,
    normalized_species_matrix,
    np,
    pd,
    ratio_method,
    samples,
):
    if normalized_species_matrix is None:

        pairwise_ratio_trace = None

    else:

        _pairwise_rows = []

        _sample_count = len(samples)

        for (
            _protein_name,
            _protein_frame,
        ) in normalized_species_matrix.groupby(
            level=0,
            sort=True,
        ):

            _matrix_values = (
                _protein_frame
                .values
                .astype(float)
            )

            _log_matrix_values = np.log2(
                _matrix_values
            )

            _species_names = [
                _idx[1]
                for _idx
                in _protein_frame.index
            ]

            for _j_idx, _k_idx in combinations(
                range(_sample_count),
                2,
            ):

                _valid_mask = (
                    np.isfinite(
                        _log_matrix_values[:, _j_idx]
                    )
                    &
                    np.isfinite(
                        _log_matrix_values[:, _k_idx]
                    )
                )

                _shared_count = int(
                    _valid_mask.sum()
                )

                if _shared_count < 1:
                    continue

                _ratio_values = (
                    _log_matrix_values[
                        _valid_mask,
                        _j_idx,
                    ]
                    -
                    _log_matrix_values[
                        _valid_mask,
                        _k_idx,
                    ]
                )
                if ratio_method.value == "median":

                    _log2_ratio = float(
                        np.median(
                            _ratio_values
                        )
                    )

                else:

                    _log2_ratio = float(
                        np.mean(
                            _ratio_values
                        )
                    )

                _pairwise_rows.append(
                    {
                        "Protein":
                            _protein_name,
                        "Sample_A":
                            samples[_j_idx],
                        "Sample_B":
                            samples[_k_idx],
                        "Shared_Species_Count":
                            _shared_count,
                        "Shared_Species":
                            ";".join(
                                np.array(
                                    _species_names
                                )[
                                    _valid_mask
                                ]
                            ),
                        "log2_ratio_A_over_B":
                            _log2_ratio,
                        "ratio_A_over_B":
                            2 ** _log2_ratio,
                    }
                )

        pairwise_ratio_trace = (
            pd.DataFrame(
                _pairwise_rows
            )
        )
    return (pairwise_ratio_trace,)


@app.cell
def _(mo, pairwise_ratio_trace):

    if pairwise_ratio_trace is not None:

        mo.vstack(
            [
                mo.md(
                    """
    # Pairwise Ratios
    """
                ),
                mo.ui.table(
                    pairwise_ratio_trace
                    .head(50)
                ),
            ]
        )
    return


@app.cell
def _(
    combinations,
    normalized_species_matrix,
    np,
    pd,
    ratio_method,
    rescale_method,
    samples,
):
    if normalized_species_matrix is None:

        protein_profile_trace = None
        calculated_lfq = None

    else:

        _profile_rows = []
        _lfq_rows = []

        _sample_count_lfq = (
            len(samples)
        )

        for (
            _protein_name_lfq,
            _protein_frame_lfq,
        ) in normalized_species_matrix.groupby(
            level=0,
            sort=True,
        ):

            _protein_matrix = (
                _protein_frame_lfq
                .values
                .astype(float)
            )

            _protein_log_matrix = (
                np.log2(
                    _protein_matrix
                )
            )

            _ratio_matrix_lfq = np.full(
                (
                    _sample_count_lfq,
                    _sample_count_lfq,
                ),
                np.nan,
            )

            for (
                _sample_a,
                _sample_b,
            ) in combinations(
                range(
                    _sample_count_lfq
                ),
                2,
            ):

                _shared_mask = (
                    np.isfinite(
                        _protein_log_matrix[
                            :,
                            _sample_a,
                        ]
                    )
                    &
                    np.isfinite(
                        _protein_log_matrix[
                            :,
                            _sample_b,
                        ]
                    )
                )

                if (
                    _shared_mask.sum()
                    < 1
                ):
                    continue

                _ratio_input = (
                    _protein_log_matrix[
                        _shared_mask,
                        _sample_a,
                    ]
                    -
                    _protein_log_matrix[
                        _shared_mask,
                        _sample_b,
                    ]
                )

                if ratio_method.value == "median":

                    _ratio_matrix_lfq[
                        _sample_a,
                        _sample_b,
                    ] = float(
                        np.median(
                            _ratio_input
                        )
                    )

                else:

                    _ratio_matrix_lfq[
                        _sample_a,
                        _sample_b,
                    ] = float(
                        np.mean(
                            _ratio_input
                        )
                    )


                _ratio_matrix_lfq[
                    _sample_b,
                    _sample_a,
                ] = (
                    -_ratio_matrix_lfq[
                        _sample_a,
                        _sample_b,
                    ]
                )

            _output_profile = np.full(
                _sample_count_lfq,
                np.nan,
            )

            _valid_sample_idx = (
                np.where(
                    np.isfinite(
                        _ratio_matrix_lfq
                    ).any(axis=0)
                )[0]
            )

            if len(
                _valid_sample_idx
            ) > 1:

                _equations = []
                _equation_values = []

                for (
                    _eq_a,
                    _eq_b,
                ) in combinations(
                    range(
                        len(
                            _valid_sample_idx
                        )
                    ),
                    2,
                ):

                    _ratio_value = (
                        _ratio_matrix_lfq[
                            _valid_sample_idx[
                                _eq_a
                            ],
                            _valid_sample_idx[
                                _eq_b
                            ],
                        ]
                    )

                    if np.isfinite(
                        _ratio_value
                    ):

                        _eq_row = np.zeros(
                            len(
                                _valid_sample_idx
                            )
                        )

                        _eq_row[
                            _eq_a
                        ] = 1.0

                        _eq_row[
                            _eq_b
                        ] = -1.0

                        _equations.append(
                            _eq_row
                        )

                        _equation_values.append(
                            _ratio_value
                        )

                if len(
                    _equations
                ) > 0:

                    _solution, *_unused = (
                        np.linalg.lstsq(
                            np.asarray(
                                _equations
                            ),
                            np.asarray(
                                _equation_values
                            ),
                            rcond=None,
                        )
                    )

                    _relative_profile = (
                        2.0 ** _solution
                    )

                    _component_matrix = (
                        _protein_matrix[
                            :,
                            _valid_sample_idx,
                        ]
                    )

                    if (
                        rescale_method.value
                        == "max"
                    ):

                        _anchor_vector = (
                            np.nanmax(
                                _component_matrix,
                                axis=0,
                            )
                        )

                    else:

                        _anchor_vector = (
                            np.nansum(
                                _component_matrix,
                                axis=0,
                            )
                        )

                    _active_mask = (
                        np.isfinite(
                            _relative_profile
                        )
                        &
                        np.isfinite(
                            _anchor_vector
                        )
                        &
                        (
                            _relative_profile
                            > 0
                        )
                        &
                        (
                            _anchor_vector
                            > 0
                        )
                    )

                    if (
                        _active_mask.any()
                    ):

                        _scale_factor = (
                            np.nansum(
                                _anchor_vector[
                                    _active_mask
                                ]
                            )
                            /
                            np.nansum(
                                _relative_profile[
                                    _active_mask
                                ]
                            )
                        )

                        _final_profile = (
                            _relative_profile
                            * _scale_factor
                        )

                        _output_profile[
                            _valid_sample_idx
                        ] = (
                            _final_profile
                        )

            _lfq_row = {
                "Protein":
                    _protein_name_lfq
            }

            for (
                _sample_name_lfq,
                _sample_value_lfq,
            ) in zip(
                samples,
                _output_profile,
            ):

                _lfq_row[
                    "LFQ intensity "
                    + _sample_name_lfq
                ] = (
                    _sample_value_lfq
                    if (
                        np.isfinite(
                            _sample_value_lfq
                        )
                        and _sample_value_lfq > 0
                    )
                    else np.nan
                )

            _lfq_rows.append(
                _lfq_row
            )

        protein_profile_trace = (
            pd.DataFrame(
                _profile_rows
            )
        )

        calculated_lfq = (
            pd.DataFrame(
                _lfq_rows
            )
            .set_index(
                "Protein"
            )
        )
    return calculated_lfq, protein_profile_trace


@app.cell
def _(mo, protein_profile_trace):

    if protein_profile_trace is not None:

        mo.vstack(
            [
                mo.md(
                    """
    # Equation 3 Reconstruction
    """
                ),
                mo.ui.table(
                    protein_profile_trace
                    .head(50)
                ),
            ]
        )
    return


@app.cell
def _(calculated_lfq, mo):

    if calculated_lfq is not None:

        mo.vstack(
            [
                mo.md(
                    """
    # Calculated LFQ
    """
                ),
                mo.ui.table(
                    calculated_lfq
                    .head(50)
                ),
            ]
        )
    return


@app.cell
def _(calculated_lfq, first_token, np, pd, protein_groups_df):

    if (
        protein_groups_df is None
        or calculated_lfq is None
    ):

        reference_lfq = None
        comparison_trace = None
        shared_samples = []

    else:

        _pg = (
            protein_groups_df.copy()
        )

        for _flag_col in [
            "Reverse",
            "Potential contaminant",
            "Contaminant",
        ]:

            if _flag_col in _pg.columns:

                _pg = _pg[
                    _pg[_flag_col]
                    .astype(str)
                    .str.strip()
                    != "+"
                ]

        if (
            "Majority protein IDs"
            in _pg.columns
        ):

            _pg["_protein"] = (
                _pg[
                    "Majority protein IDs"
                ]
                .map(first_token)
            )

        elif (
            "Protein IDs"
            in _pg.columns
        ):

            _pg["_protein"] = (
                _pg[
                    "Protein IDs"
                ]
                .map(first_token)
            )

        _lfq_cols = [
            _c
            for _c
            in _pg.columns
            if str(_c).startswith(
                "LFQ intensity "
            )
        ]

        reference_lfq = (
            _pg[
                ["_protein"]
                + _lfq_cols
            ]
            .copy()
            .set_index("_protein")
        )

        reference_lfq = (
            reference_lfq
            .apply(
                pd.to_numeric,
                errors="coerce",
            )
            .replace(0, np.nan)
        )

        reference_lfq.columns = [
            _c.replace(
                "LFQ intensity ",
                "",
                1,
            )
            for _c
            in reference_lfq.columns
        ]

        _calc_samples = [
            _c.replace(
                "LFQ intensity ",
                "",
                1,
            )
            for _c
            in calculated_lfq.columns
        ]

        shared_samples = [
            _s
            for _s
            in _calc_samples
            if _s in reference_lfq.columns
        ]

        _common_proteins = (
            calculated_lfq.index
            .intersection(
                reference_lfq.index
            )
        )

        _comparison_rows = []

        for _protein_name in (
            _common_proteins
        ):

            for _sample_name in (
                shared_samples
            ):

                _calc_col = (
                    "LFQ intensity "
                    + _sample_name
                )

                _calc = (
                    calculated_lfq.loc[
                        _protein_name,
                        _calc_col,
                    ]
                )

                _ref = (
                    reference_lfq.loc[
                        _protein_name,
                        _sample_name,
                    ]
                )

                if (
                    pd.notna(_calc)
                    and pd.notna(_ref)
                    and _calc > 0
                    and _ref > 0
                ):

                    _log2_diff = float(
                        np.log2(
                            _calc / _ref
                        )
                    )

                else:

                    _log2_diff = np.nan

                _comparison_rows.append(
                    {
                        "Protein":
                            _protein_name,
                        "Sample":
                            _sample_name,
                        "Calculated_LFQ":
                            _calc,
                        "ProteinGroups_LFQ":
                            _ref,
                        "Log2_Calc_over_PG":
                            _log2_diff,
                    }
                )

        comparison_trace = (
            pd.DataFrame(
                _comparison_rows
            )
        )
    return (comparison_trace,)


@app.cell
def _(comparison_trace, np, pd):

    if comparison_trace is None:

        summary_table = None

    else:

        _valid = (
            comparison_trace[
                "Log2_Calc_over_PG"
            ]
            .dropna()
            .values
        )

        summary_table = (
            pd.DataFrame(
                [
                    {
                        "Compared_Cells":
                            int(
                                len(_valid)
                            ),
                        "Median_Log2_Diff":
                            float(
                                np.median(
                                    _valid
                                )
                            )
                            if len(_valid)
                            else np.nan,
                        "Mean_Log2_Diff":
                            float(
                                np.mean(
                                    _valid
                                )
                            )
                            if len(_valid)
                            else np.nan,
                        "MAE_Log2":
                            float(
                                np.mean(
                                    np.abs(
                                        _valid
                                    )
                                )
                            )
                            if len(_valid)
                            else np.nan,
                    }
                ]
            )
        )
    return (summary_table,)


@app.cell
def _(comparison_trace, mo):

    if comparison_trace is not None:

        mo.vstack(
            [
                mo.md(
                    """
    # LFQ Comparison
    """
                ),
                mo.ui.table(
                    comparison_trace
                    .head(100)
                ),
            ]
        )
    return


@app.cell
def _(mo, summary_table):

    if summary_table is not None:

        mo.vstack(
            [
                mo.md(
                    """
    # Summary
    """
                ),
                mo.ui.table(
                    summary_table
                ),
            ]
        )
    return


@app.cell
def _(comparison_trace, px):

    if (
        comparison_trace is None
        or len(
            comparison_trace
        ) == 0
    ):

        residual_histogram = None

    else:

        residual_histogram = (
            px.histogram(
                comparison_trace,
                x="Log2_Calc_over_PG",
                nbins=50,
                title=
                "Residual Distribution",
            )
        )
    return (residual_histogram,)


@app.cell
def _(residual_histogram):

    if residual_histogram is not None:
        residual_histogram
    return


@app.cell
def _(mo):
    mo.md(r"""
    # Notebook Complete

    Implemented

    - Peptide loading
    - Species construction
    - Species matrix
    - Equation 2 normalization
    - Equation 1 normalization
    - Pairwise ratios
    - Equation 3 reconstruction
    - LFQ calculation
    - proteinGroups comparison
    - Residual diagnostics
    """)
    return


if __name__ == "__main__":
    app.run()
