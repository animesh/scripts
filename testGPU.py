#https://docs.docker.com/docker-for-windows/wsl/
#docker run --rm -it --gpus=all nvcr.io/nvidia/k8s/cuda-sample:nbody nbody -gpu -benchmark
#> Windowed mode
#> Simulation data stored in video memory
#> Single precision floating point simulation
#> 1 Devices used for simulation
#MapSMtoCores for SM 7.5 is undefined.  Default to use 64 Cores/SM
#GPU Device 0: "GeForce RTX 2060 with Max-Q Design" with compute capability 7.5
#> Compute 7.5 CUDA device: [GeForce RTX 2060 with Max-Q Design]
#GPU Device 0: "GeForce RTX 2070 SUPER" with compute capability 7.5
#> Compute 7.5 CUDA device: [GeForce RTX 2060 with Max-Q Design]
#30720 bodies, total time for 10 iterations: 69.280 ms
#= 136.219 billion interactions per second
#= 2724.379 single-precision GFLOP/s at 20 flops per interaction
#> Compute 7.5 CUDA device: [GeForce RTX 2070 SUPER]
#40960 bodies, total time for 10 iterations: 57.055 ms
#= 294.053 billion interactions per second
#= 5881.050 single-precision GFLOP/s at 20 flops per interaction
#https://docs.microsoft.com/en-us/windows/win32/direct3d12/gpu-tensorflow-wsl
#https://github.com/microsoft/tensorflow-directml
import tensorflow as tf#.compat.v1 as tf
#tf.enable_eager_execution(tf.ConfigProto(log_device_placement=True))
a = tf.constant([1.0, 2.0])
b = tf.constant([3.0, 4.0])
c = tf.add(a,b)
print(c)
#2020-06-15 11:27:18.235973: I tensorflow/core/common_runtime/dml/dml_device_factory.cc:45] DirectML device enumeration: found 1 compatible adapters.
#2020-06-15 11:27:18.240065: I tensorflow/core/common_runtime/dml/dml_device_factory.cc:32] DirectML: creating device on adapter 0 (AMD Radeon VII)
#2020-06-15 11:27:18.323949: I tensorflow/stream_executor/platform/default/dso_loader.cc:60] Successfully opened dynamic library libdirectml.so.ba106a7c621ea741d21598708ee581c11918380
#2020-06-15 11:27:18.337830: I tensorflow/core/common_runtime/eager/execute.cc:571] Executing op Add in device /job:localhost/replica:0/task:0/device:DML:0
#tf.Tensor([4. 6.], shape=(2,), dtype=float32)
#(directml) animeshs@DMED7596:~$ python scripts/testGPU.py
#NVD3D10: CPU cyclestats are disabled on client virtualization
#2021-02-19 17:15:28.162482: I tensorflow/stream_executor/platform/default/dso_loader.cc:98] Successfully opened dynamic library libdirectml.bdb07c797e1af1b4a42d21c67ce5494d73991459.so
#2021-02-19 17:15:28.203199: I tensorflow/core/common_runtime/dml/dml_device_cache.cc:126] DirectML device enumeration: found 1 compatible adapters.
#2021-02-19 17:15:28.203756: I tensorflow/core/platform/cpu_feature_guard.cc:142] Your CPU supports instructions that this TensorFlow binary was not compiled to use: AVX2 FMA
#2021-02-19 17:15:28.205025: I tensorflow/core/common_runtime/dml/dml_device_cache.cc:109] DirectML: creating device on adapter 0 (NVIDIA GeForce RTX 2070 SUPER
#NVD3D10: CPU cyclestats are disabled on client virtualization
#NVD3D10: CPU cyclestats are disabled on client virtualization
#2021-02-19 17:15:30.374504: I tensorflow/core/common_runtime/eager/execute.cc:571] Executing op Add in device /job:localhost/replica:0/task:0/device:DML:0
#tf.Tensor([4. 6.], shape=(2,), dtype=float32)
#more on https://github.com/microsoft/DirectML/tree/master/TensorFlow/squeezenet
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
with tf.Session() as sess:
    cart = tf.Session().run(cart_prod(a,b,c))
    print(cart)
