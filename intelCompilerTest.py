# https://software.intel.com/en-us/blogs/2016/04/04/unleash-parallel-performance-of-python-programs
import dask, time
import dask.array as da
x = da.random.random((100000, 2000), chunks=(10000, 2000))
t0 = time.time()
q, r = da.linalg.qr(x)
test = da.all(da.isclose(x, q.dot(r)))
assert(test.compute()) # compute(get=dask.threaded.get) by default
print(time.time() - t0)
# python -m TBB intelCompilerTest.py
