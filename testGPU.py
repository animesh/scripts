#Original file is located at https://colab.research.google.com/github/rapidsai/cuml/blob/branch-22.06/notebooks/random_forest_mnmg_demo.ipynb
import numpy as np
import sklearn
import pandas as pd
import cudf
import cuml
from sklearn import model_selection
from cuml import datasets
from cuml.metrics import accuracy_score
from cuml.dask.common import utils as dask_utils
from dask.distributed import Client, wait
from dask_cuda import LocalCUDACluster
import dask_cudf
from cuml.dask.ensemble import RandomForestClassifier as cumlDaskRF
from sklearn.ensemble import RandomForestClassifier as sklRF
cluster = LocalCUDACluster(threads_per_worker=1)
c = Client(cluster)
workers = c.has_what().keys()
n_workers = len(workers)
n_streams = 8 # Performance optimization
train_size = 100000
test_size = 1000
n_samples = train_size + test_size
n_features = 20
max_depth = 12
n_bins = 16
n_trees = 1000
X, y = datasets.make_classification(n_samples=n_samples, n_features=n_features,
                                 n_clusters_per_class=1, n_informative=int(n_features / 3),
                                 random_state=123, n_classes=5)
X = X.astype(np.float32)
y = y.astype(np.int32)
X_train, X_test, y_train, y_test = model_selection.train_test_split(X, y, test_size=test_size)
n_partitions = n_workers
def distribute(X, y):
    X_cudf = cudf.DataFrame(X)
    y_cudf = cudf.Series(y)
    X_dask = dask_cudf.from_cudf(X_cudf, npartitions=n_partitions)
    y_dask = dask_cudf.from_cudf(y_cudf, npartitions=n_partitions)
    X_dask, y_dask = dask_utils.persist_across_workers(c, [X_dask, y_dask], workers=workers)
    return X_dask, y_dask
X_train_dask, y_train_dask = distribute(X_train, y_train)
X_test_dask, y_test_dask = distribute(X_test, y_test)
skl_model = sklRF(max_depth=max_depth, n_estimators=n_trees, n_jobs=-1)
skl_model.fit(X_train.get(), y_train.get())
cuml_model = cumlDaskRF(max_depth=max_depth, n_estimators=n_trees, n_bins=n_bins, n_streams=n_streams)
cuml_model.fit(X_train_dask, y_train_dask)
wait(cuml_model.rfs) # Allow asynchronous training tasks to finish
skl_y_pred = skl_model.predict(X_test.get())
cuml_y_pred = cuml_model.predict(X_test_dask).compute().to_numpy()
print("SKLearn accuracy:  ", accuracy_score(y_test, skl_y_pred))
print("CuML accuracy:     ", accuracy_score(y_test, cuml_y_pred))
#https://docs.nvidia.com/deeplearning/cudnn/install-guide/index.html#install-windows
import tensorflow as tf#.compat.v1 as tf
print("TensorFlow ",tf.__version__)
#tf.enable_eager_execution(tf.ConfigProto(log_device_placement=True))
a = tf.constant([1.0, 2.0])
b = tf.constant([3.0, 4.0])
c = tf.add(a,b)
print(c)
#https://stackoverflow.com/questions/48204382/creating-all-possible-combinations-from-vectors-in-tensorflow
def cart_prod(a,b,c):
    tile_a = tf.tile(tf.expand_dims(a, 1), [1, tf.shape(b)[0]])
    tile_a = tf.expand_dims(tile_a, 2)
    tile_b = tf.tile(tf.expand_dims(b, 0), [tf.shape(a)[0], 1])
    tile_b = tf.expand_dims(tile_b, 2)
    cart = tf.concat([tile_a, tile_b], axis=2)
    cart = tf.reshape(cart,[-1,2])
    tile_c = tf.tile(tf.expand_dims(c, 1), [1, tf.shape(cart)[0]])
    tile_c = tf.expand_dims(tile_c, 2)
    tile_c = tf.reshape(tile_c, [-1,1])
    cart = tf.tile(cart,[tf.shape(c)[0],1])
    cart = tf.concat([cart, tile_c], axis=1)
    return cart
print(cart_prod(a,b,c))
#C:\Users\animeshs>C:\\Users\\animeshs\\AppData\\Local\\Programs\\Spyder\\Python\\python.exe f:\gd\OneDrive\Dokumenter\GitHub\scripts\testGPU.py
#2021-11-15 14:26:47.663384: I tensorflow/core/platform/cpu_feature_guard.cc:151] This TensorFlow binary is optimized with oneAPI Deep Neural Network Library (oneDNN) to use the following CPU instructions in performance-critical operations:  AVX AVX2
#To enable them in other operations, rebuild TensorFlow with the appropriate compiler flags.
#2021-11-15 14:26:48.531289: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1525] Created device /job:localhost/replica:0/task:0/device:GPU:0 with 5660 MB memory:  -> device: 0, name: NVIDIA GeForce RTX 2070 SUPER, pci bus id: 0000:81:00.0, compute capability: 7.5
#tf.Tensor([4. 6.], shape=(2,), dtype=float32)
#tf.Tensor(
#[[1. 3. 4.]
# [1. 4. 4.]
# [2. 3. 4.]
# [2. 4. 4.]
# [1. 3. 6.]
# [1. 4. 6.]
# [2. 3. 6.]
# [2. 4. 6.]], shape=(8, 3), dtype=float32)
#Traceback (most recent call last):
#  File "f:\gd\OneDrive\Dokumenter\GitHub\scripts\testGPU.py", line 42, in <module>
#    device_name = sys.argv[1]  # Choose device from cmd line. Options: gpu or cpu
#IndexError: list index out of range
#source https://gist.github.com/aferral/55a9849018c94b7c2818bc11e03059b1
import sys
import numpy as np
import tensorflow as tf
from datetime import datetime
device_name = sys.argv[1]  # Choose device from cmd line. Options: gpu or cpu
shape = (int(sys.argv[2]), int(sys.argv[2]))
if device_name == "gpu":
    device_name = "/gpu:0"
else:
    device_name = "/cpu:0"
tf.compat.v1.disable_eager_execution()
with tf.device(device_name):
    random_matrix = tf.random.uniform(shape=shape, minval=0, maxval=1)
    dot_operation = tf.matmul(random_matrix, tf.transpose(random_matrix))
    sum_operation = tf.reduce_sum(dot_operation)
startTime = datetime.now()
with tf.compat.v1.Session(config=tf.compat.v1.ConfigProto(log_device_placement=True)) as session:
        result = session.run(sum_operation)
        print(result)
# Print the results
print("Shape:", shape, "Device:", device_name)
print("Time taken:", datetime.now() - startTime)
# C:\Users\animeshs>C:\\Users\\animeshs\\AppData\\Local\\Programs\\Spyder\\Python\\python.exe f:\gd\OneDrive\Dokumenter\GitHub\scripts\testGPU.py gpu 10000
# 2021-11-15 14:35:27.222080: I tensorflow/core/platform/cpu_feature_guard.cc:151] This TensorFlow binary is optimized with oneAPI Deep Neural Network Library (oneDNN) to use the following CPU instructions in performance-critical operations:  AVX AVX2
# To enable them in other operations, rebuild TensorFlow with the appropriate compiler flags.
# 2021-11-15 14:35:27.942244: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1525] Created device /job:localhost/replica:0/task:0/device:GPU:0 with 5978 MB memory:  -> device: 0, name: NVIDIA GeForce RTX 2070 SUPER, pci bus id: 0000:81:00.0, compute capability: 7.5
# tf.Tensor([4. 6.], shape=(2,), dtype=float32)
# tf.Tensor(
# [[1. 3. 4.]
#  [1. 4. 4.]
#  [2. 3. 4.]
#  [2. 4. 4.]
#  [1. 3. 6.]
#  [1. 4. 6.]
#  [2. 3. 6.]
#  [2. 4. 6.]], shape=(8, 3), dtype=float32)
# 2021-11-15 14:35:28.200255: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1525] Created device /job:localhost/replica:0/task:0/device:GPU:0 with 5978 MB memory:  -> device: 0, name: NVIDIA GeForce RTX 2070 SUPER, pci bus id: 0000:81:00.0, compute capability: 7.5
# 2021-11-15 14:35:28.204530: I tensorflow/core/common_runtime/direct_session.cc:367] Device mapping:
# /job:localhost/replica:0/task:0/device:GPU:0 -> device: 0, name: NVIDIA GeForce RTX 2070 SUPER, pci bus id: 0000:81:00.0, compute capability: 7.5

# random_uniform/RandomUniform: (RandomUniform): /job:localhost/replica:0/task:0/device:GPU:0
# 2021-11-15 14:35:28.209852: I tensorflow/core/common_runtime/placer.cc:114] random_uniform/RandomUniform: (RandomUniform): /job:localhost/replica:0/task:0/device:GPU:0
# transpose: (Transpose): /job:localhost/replica:0/task:0/device:GPU:0
# 2021-11-15 14:35:28.219577: I tensorflow/core/common_runtime/placer.cc:114] transpose: (Transpose): /job:localhost/replica:0/task:0/device:GPU:0
# MatMul: (MatMul): /job:localhost/replica:0/task:0/device:GPU:0
# 2021-11-15 14:35:28.222751: I tensorflow/core/common_runtime/placer.cc:114] MatMul: (MatMul): /job:localhost/replica:0/task:0/device:GPU:0
# Sum: (Sum): /job:localhost/replica:0/task:0/device:GPU:0
# 2021-11-15 14:35:28.225490: I tensorflow/core/common_runtime/placer.cc:114] Sum: (Sum): /job:localhost/replica:0/task:0/device:GPU:0
# random_uniform/shape: (Const): /job:localhost/replica:0/task:0/device:GPU:0
# 2021-11-15 14:35:28.230566: I tensorflow/core/common_runtime/placer.cc:114] random_uniform/shape: (Const): /job:localhost/replica:0/task:0/device:GPU:0
# transpose/perm: (Const): /job:localhost/replica:0/task:0/device:GPU:0
# 2021-11-15 14:35:28.239250: I tensorflow/core/common_runtime/placer.cc:114] transpose/perm: (Const): /job:localhost/replica:0/task:0/device:GPU:0
# Const: (Const): /job:localhost/replica:0/task:0/device:GPU:0
# 2021-11-15 14:35:28.244678: I tensorflow/core/common_runtime/placer.cc:114] Const: (Const): /job:localhost/replica:0/task:0/device:GPU:0
# 249982780000.0
# Shape: (10000, 10000) Device: /gpu:0
# Time taken: 0:00:01.555302

# C:\Users\animeshs>C:\\Users\\animeshs\\AppData\\Local\\Programs\\Spyder\\Python\\python.exe f:\gd\OneDrive\Dokumenter\GitHub\scripts\testGPU.py cpu 10000
# 2021-11-15 14:35:40.926436: I tensorflow/core/platform/cpu_feature_guard.cc:151] This TensorFlow binary is optimized with oneAPI Deep Neural Network Library (oneDNN) to use the following CPU instructions in performance-critical operations:  AVX AVX2
# To enable them in other operations, rebuild TensorFlow with the appropriate compiler flags.
# 2021-11-15 14:35:41.882971: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1525] Created device /job:localhost/replica:0/task:0/device:GPU:0 with 5978 MB memory:  -> device: 0, name: NVIDIA GeForce RTX 2070 SUPER, pci bus id: 0000:81:00.0, compute capability: 7.5
# tf.Tensor([4. 6.], shape=(2,), dtype=float32)
# tf.Tensor(
# [[1. 3. 4.]
#  [1. 4. 4.]
#  [2. 3. 4.]
#  [2. 4. 4.]
#  [1. 3. 6.]
#  [1. 4. 6.]
#  [2. 3. 6.]
#  [2. 4. 6.]], shape=(8, 3), dtype=float32)
# 2021-11-15 14:35:42.108066: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1525] Created device /job:localhost/replica:0/task:0/device:GPU:0 with 5978 MB memory:  -> device: 0, name: NVIDIA GeForce RTX 2070 SUPER, pci bus id: 0000:81:00.0, compute capability: 7.5
# 2021-11-15 14:35:42.116974: I tensorflow/core/common_runtime/direct_session.cc:367] Device mapping:
# /job:localhost/replica:0/task:0/device:GPU:0 -> device: 0, name: NVIDIA GeForce RTX 2070 SUPER, pci bus id: 0000:81:00.0, compute capability: 7.5

# random_uniform/RandomUniform: (RandomUniform): /job:localhost/replica:0/task:0/device:CPU:0
# 2021-11-15 14:35:42.126371: I tensorflow/core/common_runtime/placer.cc:114] random_uniform/RandomUniform: (RandomUniform): /job:localhost/replica:0/task:0/device:CPU:0
# transpose: (Transpose): /job:localhost/replica:0/task:0/device:CPU:0
# 2021-11-15 14:35:42.133779: I tensorflow/core/common_runtime/placer.cc:114] transpose: (Transpose): /job:localhost/replica:0/task:0/device:CPU:0
# MatMul: (MatMul): /job:localhost/replica:0/task:0/device:CPU:0
# 2021-11-15 14:35:42.138095: I tensorflow/core/common_runtime/placer.cc:114] MatMul: (MatMul): /job:localhost/replica:0/task:0/device:CPU:0
# Sum: (Sum): /job:localhost/replica:0/task:0/device:CPU:0
# 2021-11-15 14:35:42.150091: I tensorflow/core/common_runtime/placer.cc:114] Sum: (Sum): /job:localhost/replica:0/task:0/device:CPU:0
# random_uniform/shape: (Const): /job:localhost/replica:0/task:0/device:CPU:0
# 2021-11-15 14:35:42.153006: I tensorflow/core/common_runtime/placer.cc:114] random_uniform/shape: (Const): /job:localhost/replica:0/task:0/device:CPU:0
# transpose/perm: (Const): /job:localhost/replica:0/task:0/device:CPU:0
# 2021-11-15 14:35:42.163120: I tensorflow/core/common_runtime/placer.cc:114] transpose/perm: (Const): /job:localhost/replica:0/task:0/device:CPU:0
# Const: (Const): /job:localhost/replica:0/task:0/device:CPU:0
# 2021-11-15 14:35:42.169604: I tensorflow/core/common_runtime/placer.cc:114] Const: (Const): /job:localhost/replica:0/task:0/device:CPU:0
# 250004000000.0
# Shape: (10000, 10000) Device: /cpu:0
# Time taken: 0:00:03.411183
#C:\\Users\\animeshs\\AppData\\Local\\Programs\\Spyder\\Python\\python.exe -m pip install torch==1.10.0+cu113 torchvision==0.11.1+cu113 torchaudio===0.10.0+cu113 -f https://download.pytorch.org/whl/cu113/torch_stable.html

import torch
print("PyTorch ",torch.__version__)
#device_name = "/gpu:0"
device = torch.device('cuda' if device_name == "/gpu:0" else 'cpu')
print('Using device:', device)
startTime = datetime.now()
#shape = (int(100000), int(100000))
print(torch.rand(shape)*torch.rand(shape))
#https://stackoverflow.com/a/53374933
print("Time taken:", datetime.now() - startTime)
print("Shape:", shape, "Device:", device_name)
if device.type == 'cuda':
    print(torch.cuda.get_device_name(0))
    print('Allocated:', round(torch.cuda.memory_allocated(0)/1024**3,1), 'GB')
    print('Cached:   ', round(torch.cuda.memory_reserved(0)/1024**3,1), 'GB')
#C:\Users\animeshs>C:\\Users\\animeshs\\AppData\\Local\\Programs\\Spyder\\Python\\python.exe "f:\OneDrive - NTNU\gd\OneDrive\Dokumenter\GitHub\scripts\testGPU.py" gpu 10000
# TensorFlow  2.7.0
# 2021-11-15 15:29:32.511141: I tensorflow/core/platform/cpu_feature_guard.cc:151] This TensorFlow binary is optimized with oneAPI Deep Neural Network Library (oneDNN) to use the following CPU instructions in performance-critical operations:  AVX AVX2
# To enable them in other operations, rebuild TensorFlow with the appropriate compiler flags.
# 2021-11-15 15:29:33.422819: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1525] Created device /job:localhost/replica:0/task:0/device:GPU:0 with 5978 MB memory:  -> device: 0, name: NVIDIA GeForce RTX 2070 SUPER, pci bus id: 0000:81:00.0, compute capability: 7.5
# tf.Tensor([4. 6.], shape=(2,), dtype=float32)
# tf.Tensor(
# [[1. 3. 4.]
#  [1. 4. 4.]
#  [2. 3. 4.]
#  [2. 4. 4.]
#  [1. 3. 6.]
#  [1. 4. 6.]
#  [2. 3. 6.]
#  [2. 4. 6.]], shape=(8, 3), dtype=float32)
# 2021-11-15 15:29:33.669399: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1525] Created device /job:localhost/replica:0/task:0/device:GPU:0 with 5978 MB memory:  -> device: 0, name: NVIDIA GeForce RTX 2070 SUPER, pci bus id: 0000:81:00.0, compute capability: 7.5
# 2021-11-15 15:29:33.674368: I tensorflow/core/common_runtime/direct_session.cc:367] Device mapping:
# /job:localhost/replica:0/task:0/device:GPU:0 -> device: 0, name: NVIDIA GeForce RTX 2070 SUPER, pci bus id: 0000:81:00.0, compute capability: 7.5

# random_uniform/RandomUniform: (RandomUniform): /job:localhost/replica:0/task:0/device:GPU:0
# 2021-11-15 15:29:33.682365: I tensorflow/core/common_runtime/placer.cc:114] random_uniform/RandomUniform: (RandomUniform): /job:localhost/replica:0/task:0/device:GPU:0
# transpose: (Transpose): /job:localhost/replica:0/task:0/device:GPU:0
# 2021-11-15 15:29:33.686696: I tensorflow/core/common_runtime/placer.cc:114] transpose: (Transpose): /job:localhost/replica:0/task:0/device:GPU:0
# MatMul: (MatMul): /job:localhost/replica:0/task:0/device:GPU:0
# 2021-11-15 15:29:33.693419: I tensorflow/core/common_runtime/placer.cc:114] MatMul: (MatMul): /job:localhost/replica:0/task:0/device:GPU:0
# Sum: (Sum): /job:localhost/replica:0/task:0/device:GPU:0
# 2021-11-15 15:29:33.696021: I tensorflow/core/common_runtime/placer.cc:114] Sum: (Sum): /job:localhost/replica:0/task:0/device:GPU:0
# random_uniform/shape: (Const): /job:localhost/replica:0/task:0/device:GPU:0
# 2021-11-15 15:29:33.702960: I tensorflow/core/common_runtime/placer.cc:114] random_uniform/shape: (Const): /job:localhost/replica:0/task:0/device:GPU:0
# transpose/perm: (Const): /job:localhost/replica:0/task:0/device:GPU:0
# 2021-11-15 15:29:33.706793: I tensorflow/core/common_runtime/placer.cc:114] transpose/perm: (Const): /job:localhost/replica:0/task:0/device:GPU:0
# Const: (Const): /job:localhost/replica:0/task:0/device:GPU:0
# 2021-11-15 15:29:33.711164: I tensorflow/core/common_runtime/placer.cc:114] Const: (Const): /job:localhost/replica:0/task:0/device:GPU:0
# 250011880000.0
# Shape: (10000, 10000) Device: /gpu:0
# Time taken: 0:00:01.619880
# PyTorch  1.10.0+cu113
# Using device: cuda
# tensor([[0.4132, 0.0923, 0.5918,  ..., 0.4143, 0.0115, 0.1688],
#         [0.0826, 0.4587, 0.3309,  ..., 0.1728, 0.7921, 0.3385],
#         [0.0023, 0.7075, 0.1996,  ..., 0.0255, 0.0273, 0.0145],
#         ...,
#         [0.5587, 0.3729, 0.0185,  ..., 0.5281, 0.7197, 0.0638],
#         [0.0098, 0.3316, 0.2260,  ..., 0.0236, 0.1472, 0.1582],
#         [0.8157, 0.0411, 0.4933,  ..., 0.2833, 0.4995, 0.0832]])
# Time taken: 0:00:02.336912
# Shape: (10000, 10000) Device: /gpu:0
# NVIDIA GeForce RTX 2070 SUPER
# Allocated: 0.0 GB
# Cached:    0.0 GB