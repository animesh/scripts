import tensorflow as tf
tf.keras.backend.clear_session()
from tensorflow.python.client import device_lib
print(device_lib.list_local_devices())
print("Version: ", tf.__version__)
print("Eager mode: ", tf.executing_eagerly())
print("GPU is", "available" if tf.test.is_gpu_available() else "NOT AVAILABLE")
print(tf.config.list_physical_devices('GPU'))

