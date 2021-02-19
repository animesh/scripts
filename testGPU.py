#https://docs.microsoft.com/en-us/windows/win32/direct3d12/gpu-tensorflow-wsl
#https://github.com/microsoft/tensorflow-directml
import tensorflow.compat.v1 as tf
tf.enable_eager_execution(tf.ConfigProto(log_device_placement=True))
print(tf.add([1.0, 2.0], [3.0, 4.0]))
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
