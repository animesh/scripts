# /// script
# [tool.marimo.runtime]
# auto_instantiate = false
# ///

import marimo

__generated_with = "0.23.13"
app = marimo.App(width="medium")


@app.cell
def _():
    #curl -LsSf https://astral.sh/uv/install.sh | sh
    #uv self update
    #uv init
    #sudo apt install nginx -y
    #sudo ufw allow 2718/tcp
    #uv add marimo altair matplotlib duckdb sqlglot pyarrow
    #uv run marimo --version
    #0.23.13
    #uv run marimo new testMarimo.py --host 0.0.0.0 --port 2718
    #http://10.20.93.118:2718?access_token=AQ9XhO60eLEdRRDEjjZHNg
    import marimo as mo
    import pandas as pd
    import numpy as np
    import altair as alt
    import matplotlib.pyplot as plt

    app = mo.App()
    return alt, mo, np, pd, plt


@app.cell
def _(mo):
    title = mo.md("""
    # Minimal marimo starter
    This notebook demonstrates basic interactivity, plotting, and data handling.
    """)

    title
    return


@app.cell
def _(mo):
    # UI elements must be defined in a separate cell from where their .value is used
    n_points_slider = mo.ui.slider(10, 500, value=150, step=10, label="Number of points")
    noise_slider = mo.ui.slider(0.0, 2.0, value=0.5, step=0.1, label="Noise scale")
    dist_radio = mo.ui.radio(["normal", "uniform"], value="normal", label="Distribution")

    mo.hstack([n_points_slider, noise_slider, dist_radio])
    return dist_radio, n_points_slider, noise_slider


@app.cell
def _(dist_radio, n_points_slider, noise_slider, np, pd):
    # Generate a synthetic dataset based on UI choices
    n_points_val = n_points_slider.value
    noise_val = noise_slider.value
    dist_val = dist_radio.value

    rng = np.random.default_rng(0)
    if dist_val == "normal":
        x_data = rng.normal(0, 1, n_points_val)
    else:
        x_data = rng.uniform(-1, 1, n_points_val)

    # Linear relationship with noise
    y_data = 2.0 * x_data + rng.normal(0, noise_val, n_points_val)

    df_points = pd.DataFrame({
        "x": x_data,
        "y": y_data,
        "group": np.where(x_data >= 0, "x>=0", "x<0"),
    })

    df_points
    return (df_points,)


@app.cell
def _(alt, df_points, mo):
    # Altair scatter with interactivity
    scatter = alt.Chart(df_points).mark_point(opacity=0.7).encode(
        x=alt.X("x", title="X"),
        y=alt.Y("y", title="Y"),
        color=alt.Color("group", title="Group"),
        tooltip=["x", "y", "group"],
    ).interactive()

    mo.ui.altair_chart(scatter)
    return (scatter,)


@app.cell
def _(df_points, np, plt):
    # Matplotlib regression line
    coef = np.polyfit(df_points["x"], df_points["y"], 1)
    poly = np.poly1d(coef)

    x_grid = np.linspace(df_points["x"].min(), df_points["x"].max(), 200)

    plt.figure(figsize=(6,4))
    plt.scatter(df_points["x"], df_points["y"], s=12, alpha=0.5, label="points")
    plt.plot(x_grid, poly(x_grid), color="crimson", lw=2, label=f"fit: y={coef[0]:.2f}x+{coef[1]:.2f}")
    plt.title("Linear fit")
    plt.xlabel("x")
    plt.ylabel("y")
    plt.legend()
    plt.gca()
    return


@app.cell
def _(mo):
    # Simple summary stats and a small UI to choose column
    col_dropdown = mo.ui.dropdown(["x", "y"], value="x", label="Column for stats")
    col_dropdown
    return (col_dropdown,)


@app.cell
def _(col_dropdown, df_points, pd):
    col_selected = col_dropdown.value
    series = df_points[col_selected]
    summary = pd.DataFrame({
        "metric": ["count", "mean", "std", "min", "p50", "max"],
        "value": [
            int(series.count()),
            float(series.mean()),
            float(series.std(ddof=1)),
            float(series.min()),
            float(series.median()),
            float(series.max()),
        ],
    })
    summary
    return


@app.cell
def _(mo, pd):
    # DuckDB via marimo SQL cell pattern
    # Prepare an additional DataFrame for demonstration
    cars_url = "https://raw.githubusercontent.com/vega/vega-datasets/master/data/cars.json"
    try:
        cars_df = pd.read_json(cars_url)
    except Exception as e:
        # CORS-safe proxy if needed
        proxy_url = f"https://corsproxy.marimo.app/{cars_url}"
        cars_df = pd.read_json(proxy_url)

    mo.ui.data_explorer(cars_df)
    return (cars_df,)


@app.cell
def _(cars_df, mo):
    _filtered = mo.sql(
        f"""
        SELECT Origin, AVG(Miles_per_Gallon) AS mpg_avg, COUNT(*) AS n
        FROM cars_df
        WHERE Miles_per_Gallon IS NOT NULL
        GROUP BY Origin
        ORDER BY mpg_avg DESC
        """
    )
    return


@app.cell
def _(
    col_dropdown,
    df_points,
    dist_radio,
    mo,
    n_points_slider,
    noise_slider,
    scatter,
):
    # Present results neatly
    mo.ui.tabs({
        "Controls": mo.vstack([n_points_slider, noise_slider, dist_radio, col_dropdown]),
        "Data": mo.ui.dataframe(df_points.head(20)),
        "Altair": mo.ui.altair_chart(scatter),
    })
    return


if __name__ == "__main__":
    app.run()
