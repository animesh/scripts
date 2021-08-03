# In[74]:
import numpy as np
import tensorflow as tf
print(tf.__version__)

# In[74]:
from tflite_model_maker import configs
from tflite_model_maker import ExportFormat
from tflite_model_maker import model_spec
from tflite_model_maker import image_classifier
from tflite_model_maker.image_classifier import DataLoader
assert tf.__version__.startswith('2')

# In[74]:
tf.get_logger().setLevel('ERROR')
#data_path = tf.keras.utils.get_file('flower_photos','https://storage.googleapis.com/download.tensorflow.org/example_images/flower_photos.tgz',untar=True)
data_path='F:\\Pneumonia\\chest_xray\\chest_xray\\train'
#data_path='/mnt/f/Pneumonia/chest_xray/chest_xray/train'
data = DataLoader.from_folder(data_path)
train_data, test_data = data.split(0.5)
model = image_classifier.create(train_data)
print(model)
loss, accuracy = model.evaluate(test_data)
print(loss,accuracy)

data_path='F:\\Pneumonia\\chest_xray\\chest_xray\\test'
#data_path='/mnt/f/Pneumonia/chest_xray/chest_xray/test'
data = DataLoader.from_folder(data_path)
train_data, test_data = data.split(0.5)
print(train_data, test_data)
loss, accuracy = model.evaluate(test_data)
print(loss,accuracy)

loss, accuracy = model.evaluate(train_data)

print(loss,accuracy)


# In[74]:


model.export(export_dir='.')


# In[75]:


model.evaluate_tflite('model.tflite', test_data)


# In[72]:


import pickle
filenaM = "tfliteModel.pkl"
with open(filenaM, 'wb') as file:
    pickle.dump(model, file)
