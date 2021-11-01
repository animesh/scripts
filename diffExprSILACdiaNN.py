#C:\\Users\\animeshs\\AppData\\Local\\Programs\\Spyder\\Python\\python.exe -m pip install datatable
import datatable as dt  # pip install datatble
fileName="C:/Users/animeshs/Downloads/SILACDIA2/report.tsv"
df = dt.fread(fileName).to_pandas()
import matplotlib.pyplot as plt
import numpy as np
plt.scatter(np.log2(df['PG.MaxLFQ']),np.log2(df['PG.Normalised']))
plt.hist(np.log2(df['PG.MaxLFQ']+1))
#https://gist.githubusercontent.com/BexTuychiev/4e34c55454c50c6fb1d0043d2848de6a/raw/f8af2217bdf3cb19881f068a9ba42ce67b1d6d8c/10206.py
def reduce_memory_usage(df, verbose=True):
    numerics = ["int8", "int16", "int32", "int64", "float16", "float32", "float64"]
    start_mem = df.memory_usage().sum() / 1024 ** 2
    for col in df.columns:
        col_type = df[col].dtypes
        if col_type in numerics:
            c_min = df[col].min()
            c_max = df[col].max()
            if str(col_type)[:3] == "int":
                if c_min > np.iinfo(np.int8).min and c_max < np.iinfo(np.int8).max:
                    df[col] = df[col].astype(np.int8)
                elif c_min > np.iinfo(np.int16).min and c_max < np.iinfo(np.int16).max:
                    df[col] = df[col].astype(np.int16)
                elif c_min > np.iinfo(np.int32).min and c_max < np.iinfo(np.int32).max:
                    df[col] = df[col].astype(np.int32)
                elif c_min > np.iinfo(np.int64).min and c_max < np.iinfo(np.int64).max:
                    df[col] = df[col].astype(np.int64)
            else:
                if (
                    c_min > np.finfo(np.float16).min
                    and c_max < np.finfo(np.float16).max
                ):
                    df[col] = df[col].astype(np.float16)
                elif (
                    c_min > np.finfo(np.float32).min
                    and c_max < np.finfo(np.float32).max
                ):
                    df[col] = df[col].astype(np.float32)
                else:
                    df[col] = df[col].astype(np.float64)
    end_mem = df.memory_usage().sum() / 1024 ** 2
    if verbose:
        print(
            "Mem. usage decreased to {:.2f} Mb ({:.1f}% reduction)".format(
                end_mem, 100 * (start_mem - end_mem) / start_mem
            )
        )
    return df
df=reduce_memory_usage(df)
#heatmap sample
df.sample(20, axis=1).describe().T.style.bar(subset=["mean"], color="#205ff2").background_gradient(subset=["std"],cmap="Reds").background_gradient(subset=["50%"], cmap="coolwarm")
#https://pandas.pydata.org/docs/user_guide/io.html
df.to_parquet(fileName+".parquet")
