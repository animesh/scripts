#https://medium.com/coding-nexus/why-i-stopped-using-pandas-describe-method-two-libraries-that-do-it-better-e2890c2c24d1
from skimpy import skim
import polars as pl
import polars.selectors as cs
import sys
fileName=sys.argv[1]
with open(fileName, 'r') as file: row_count = sum(1 for line in file)
print(f"Number of rows: {row_count}")
df = pl.read_csv(fileName,infer_schema_length=row_count,separator='\t')
df = df.select(cs.numeric())
df = df.with_columns([pl.col(col).replace(0, None).alias(col) for col in df.columns])
skim(df)
