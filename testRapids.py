import cudf
import cupy as cp
import sys
NUM_ELEMENTS = cp.int(sys.argv[1])
print(NUM_ELEMENTS)
#NUM_ELEMENTS = 10
df = cudf.DataFrame()
for i in range(NUM_ELEMENTS):
    df[i] = cp.random.sample(NUM_ELEMENTS)
for column in df.columns:
    print(df[column].mean())
