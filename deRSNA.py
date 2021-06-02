#!/usr/bin/env python
# coding: utf-8
# # [setup](https://www.kaggle.com/yujiariyasu/plot-3positive-classes )
#!pip install pandas
#!pip install pydicom
#!pip install tqdm
#!pip install skimage
#!pip install scikit-image
#!pip install cv2
#!pip install opencv
#!pip install opencv-python
#!pip install GDCM
#!pip install pylibjpeg
#!pip install numpy --upgrade
#!pip install pylibjpeg-libjpeg
#!pip install bokeh
#!pip install sklearn
#!doskey /HISTORY
import numpy as np
import pandas as pd
import os
import pydicom
from glob import glob
from tqdm.notebook import tqdm
from pydicom.pixel_data_handlers.util import apply_voi_lut
import matplotlib.pyplot as plt
from skimage import exposure
import cv2
import warnings
warnings.filterwarnings('ignore')
dataset_dir = 'F:/siim-covid19-detection/'
def dicom2array(path, voi_lut=True, fix_monochrome=True):
    dicom = pydicom.read_file(path)
    if voi_lut: data = apply_voi_lut(dicom.pixel_array, dicom)
    else: data = dicom.pixel_array
    if fix_monochrome and dicom.PhotometricInterpretation == "MONOCHROME1": data = np.amax(data) - data
    data = data - np.min(data)
    data = data / np.max(data)
    data = (data * 255).astype(np.uint8)
    return data
def plot_img(img, size=(7, 7), is_rgb=True, title="", cmap='gray'):
    plt.figure(figsize=size)
    plt.imshow(img, cmap=cmap)
    plt.suptitle(title)
    plt.show()
def plot_imgs(imgs, cols=4, size=7, is_rgb=True, title="", cmap='gray', img_size=(500,500)):
    rows = len(imgs)//cols + 1
    fig = plt.figure(figsize=(cols*size, rows*size))
    for i, img in enumerate(imgs):
        if img_size is not None:
            img = cv2.resize(img, img_size)
        fig.add_subplot(rows, cols, i+1)
        plt.imshow(img, cmap=cmap)
    plt.suptitle(title)
    plt.show()
dicom_paths = glob(f'{dataset_dir}/train/*/*/*.dcm')
len(dicom_paths)
dicom_paths[:4]
#dicom2array(dicom_paths)
imgs = [dicom2array(path) for path in dicom_paths[:4]]
plot_imgs(imgs)
imgs = [exposure.equalize_hist(img) for img in imgs]
plot_imgs(imgs)

from bokeh.plotting import figure as bokeh_figure
from bokeh.io import output_notebook, show, output_file
from bokeh.models import ColumnDataSource, HoverTool, Panel
from bokeh.models.widgets import Tabs
import pandas as pd
from PIL import Image
from sklearn import preprocessing
import random
from random import randint

train = pd.read_csv(f'{dataset_dir}/train_image_level.csv')
print(train)
train_study = pd.read_csv(f'{dataset_dir}/train_study_level.csv')
print(train_study)

train_study['StudyInstanceUID'] = train_study['id'].apply(lambda x: x.replace('_study', ''))
del train_study['id']
train = train.merge(train_study, on='StudyInstanceUID')
train.head()


group_col = 'StudyInstanceUID'
df=pd.DataFrame(train.groupby(group_col)['id'].count())
df.columns = [f'{group_col}_count']
train=train.merge(df.reset_index(), on=group_col)
one_study_multi_image_df = train[train[f'{group_col}_count'] > 1]
print(len(one_study_multi_image_df))
#https://www.kaggle.com/c/siim-covid19-detection/discussion/239980
train = train[train[f'{group_col}_count'] == 1] # delete 'StudyInstanceUID_count > 1' data

def bar_plot(train_df, variable):
    var = train_df[variable]
    varValue = var.value_counts()
    plt.figure(figsize = (9,3))
    plt.bar(varValue.index, varValue)
    plt.xticks(varValue.index, varValue.index.values)
    plt.ylabel("Frequency")
    plt.title(variable)
    plt.show()
    print("{}: \n {}".format(variable,varValue))

train['target'] = 'Negative for Pneumonia'
train.loc[train['Typical Appearance']==1, 'target'] = 'Typical Appearance'
train.loc[train['Indeterminate Appearance']==1, 'target'] = 'Indeterminate Appearance'
train.loc[train['Atypical Appearance']==1, 'target'] = 'Atypical Appearance'
bar_plot(train, 'target')

train.boxes.values[0] # x_min, y_min, width, height
train.label.values[0] # x_min, y_min, x_max, y_max
train = train[~train.boxes.isnull()]
class_names = ['Typical Appearance', 'Indeterminate Appearance', 'Atypical Appearance'] # we have 3 positive classes
unique_classes = np.unique(train[class_names].values, axis=0)
unique_classes # no multi label

imgs = []
label2color = {
    '[1, 0, 0]': [255,0,0], # Typical Appearance
    '[0, 1, 0]': [0,255,0], # Indeterminate Appearance
    '[0, 0, 1]': [0,0,255], # Atypical Appearance
}
print('Typical Appearance: red')
print('Indeterminate Appearance: green')
print('Atypical Appearance: blue')
thickness = 3
scale = 5
for _, row in train[train['Negative for Pneumonia']==0].iloc[:8].iterrows():
    study_id = row['StudyInstanceUID']
    img_path = glob(f'{dataset_dir}/train/{study_id}/*/*')[0]
    img = dicom2array(path=img_path)
    img = cv2.resize(img, None, fx=1/scale, fy=1/scale)
    img = np.stack([img, img, img], axis=-1)
    claz = row[class_names].values
    color = label2color[str(claz.tolist())]
    bboxes = []
    bbox = []
    for i, l in enumerate(row['label'].split(' ')):
        if (i % 6 == 0) | (i % 6 == 1):
            continue
        bbox.append(float(l)/scale)
        if i % 6 == 5:
            bboxes.append(bbox)
            bbox = []
    for box in bboxes:
        img = cv2.rectangle(
            img,
            (int(box[0]), int(box[1])),
            (int(box[2]), int(box[3])),
            color, thickness
    )
    img = cv2.resize(img, (500,500))
    imgs.append(img)


#plot_imgs(imgs, cmap=None)
plot_img(img)

train
imgs = []
for _, row in train[train['Negative for Pneumonia']==0].iloc[:8].iterrows():
    study_id = row['StudyInstanceUID']
    img_path = glob(f'{dataset_dir}/train/{study_id}/*/*')[0]
    img = dicom2array(path=img_path)
    #img = img.pixel_array
    img.shape
    img = cv2.resize(img,  (500,500))
    imgs.append(img)
len(imgs)
N4P=imgs
imgs = []
for _, row in train[train['Typical Appearance']==0].iloc[:8].iterrows():
    study_id = row['StudyInstanceUID']
    img_path = glob(f'{dataset_dir}/train/{study_id}/*/*')[0]
    img = dicom2array(path=img_path)
    #img = img.pixel_array
    img.shape
    img = cv2.resize(img,  (500,500))
    imgs.append(img)
len(imgs)
TA=imgs
imgs = []
for _, row in train[train['Indeterminate Appearance']==0].iloc[:8].iterrows():
    study_id = row['StudyInstanceUID']
    img_path = glob(f'{dataset_dir}/train/{study_id}/*/*')[0]
    img = dicom2array(path=img_path)
    #img = img.pixel_array
    img.shape
    img = cv2.resize(img,  (500,500))
    imgs.append(img)
len(imgs)
IA=imgs
imgs = []
for _, row in train[train['Atypical Appearance']==0].iloc[:8].iterrows():
    study_id = row['StudyInstanceUID']
    img_path = glob(f'{dataset_dir}/train/{study_id}/*/*')[0]
    img = dicom2array(path=img_path)
    #img = img.pixel_array
    img.shape
    img = cv2.resize(img,  (500,500))
    imgs.append(img)
len(imgs)
AA=imgs

print(len(AA),len(IA),len(TA),len(N4P),train.shape)
#plot_img(TA[1])

#https://github.com/iterative/cml_tensorboard_case/blob/master/train.py
import tensorflow as tf
import datetime
#mnist = tf.keras.datasets.mnist
#(x_train, y_train),(x_test, y_test) = mnist.load_data()
#x_train, x_test = x_train / 255.0, x_test / 255.0

model=tf.keras.models.Sequential([
    tf.keras.layers.Flatten(input_shape=(500, 500)),
    tf.keras.layers.Dense(512, activation='relu'),
    tf.keras.layers.Dropout(0.2),
    tf.keras.layers.Dense(250000, activation='softmax')
  ])
model.compile(optimizer='adam',
              loss='sparse_categorical_crossentropy',
              metrics=['accuracy'])
log_dir = "logs/fit/" + datetime.datetime.now().strftime("%Y%m%d-%H%M%S")
tensorboard_callback = tf.keras.callbacks.TensorBoard(log_dir=log_dir, histogram_freq=1)
img=TA[1]
#img.flatten()
img=np.reshape(img,(-1,250000))
model.fit(x=img,y=img,epochs=5,validation_data=(img,img),callbacks=[tensorboard_callback])

imgs = []
thickness = 3
scale = 5

for _, row in train[train['Typical Appearance'] == 1].iloc[:16].iterrows():
    study_id = row['StudyInstanceUID']
    img_path = glob(f'{dataset_dir}/train/{study_id}/*/*')[0]
    img = dicom2array(path=img_path)
    img = cv2.resize(img, None, fx=1/scale, fy=1/scale)

    claz = row[class_names].values
    color = label2color[str(claz.tolist())]

    bboxes = []
    bbox = []
    for i, l in enumerate(row['label'].split(' ')):
        if (i % 6 == 0) | (i % 6 == 1):
            continue
        bbox.append(float(l)/scale)
        if i % 6 == 5:
            bboxes.append(bbox)
            bbox = []

    for box in bboxes:
        img = cv2.rectangle(
            img,
            (int(box[0]), int(box[1])),
            (int(box[2]), int(box[3])),
            color, thickness
    )
    img = cv2.resize(img, (500,500))
    imgs.append(img)

plot_imgs(imgs, cmap=None)


# In[20]:


np.sum(train['Indeterminate Appearance'].iloc[:16]==1)
#np.sum(train['Atypical Appearance'].iloc[:16]==1)
#np.sum(train['Typical Appearance'].iloc[:16]==1)


# # Indeterminate Appearance only

# In[21]:


imgs = []
thickness = 3
scale = 5

for _, row in train[train['Indeterminate Appearance'] == 1].iloc[:2186].iterrows():
    study_id = row['StudyInstanceUID']
    img_path = glob(f'{dataset_dir}/train/{study_id}/*/*')[0]
    img = dicom2array(path=img_path)
    img = cv2.resize(img, None, fx=1/scale, fy=1/scale)
    img = np.stack([img, img, img], axis=-1)

    claz = row[class_names].values
    color = label2color[str(claz.tolist())]

    bboxes = []
    bbox = []
    for i, l in enumerate(row['label'].split(' ')):
        if (i % 6 == 0) | (i % 6 == 1):
            continue
        bbox.append(float(l)/scale)
        if i % 6 == 5:
            bboxes.append(bbox)
            bbox = []

    for box in bboxes:
        img = cv2.rectangle(
            img,
            (int(box[0]), int(box[1])),
            (int(box[2]), int(box[3])),
            color, thickness
    )
    img = cv2.resize(img, (500,500))
    imgs.append(img)

plot_imgs(imgs, cmap=None)


# # Atypical Appearance only

# In[23]:


imgs = []
thickness = 3
scale = 5

for _, row in train[train['Atypical Appearance'] == 1].iloc[:16].iterrows():
    study_id = row['StudyInstanceUID']
    img_path = glob(f'{dataset_dir}/train/{study_id}/*/*')[0]
    img = dicom2array(path=img_path)
    img = cv2.resize(img, None, fx=1/scale, fy=1/scale)
    img = np.stack([img, img, img], axis=-1)

    claz = row[class_names].values
    color = label2color[str(claz.tolist())]

    bboxes = []
    bbox = []

    for i, l in enumerate(row['label'].split(' ')):
        if (i % 6 == 0) | (i % 6 == 1):
            continue
        bbox.append(float(l)/scale)
        if i % 6 == 5:
            bboxes.append(bbox)
            bbox = []

    for box in bboxes:
        img = cv2.rectangle(
            img,
            (int(box[0]), int(box[1])),
            (int(box[2]), int(box[3])),
            color, thickness
    )
    img = cv2.resize(img, (500,500))
    imgs.append(img)

plot_imgs(imgs, cmap=None)


# In[24]:


sub = pd.read_csv(dataset_dir+'/sample_submission.csv')
sub.loc[sub['id'].str.endswith('study'), 'PredictionString'] = 'negative 1 0 0 1 1 atypical 1 0 0 1 1 typical 1 0 0 1 1 indeterminate 1 0 0 1 1'
sub.to_csv('submission.csv', index=False)
sub


# In[38]:


np.sum(train['Atypical Appearance']==1)


# In[18]:




# In[6]:


# https://codelabs.developers.google.com/tflite-computer-vision-train-model?continue=https%3A%2F%2Fdevelopers.google.com%2Flearn%2Fpathways%2Fgoing-further-image-classification%3Futm_source%3Dgoogle-io%26utm_medium%3Dorganic%26utm_campaign%3Dio21-learninglab%23codelab-https%3A%2F%2Fcodelabs.developers.google.com%2Ftflite-computer-vision-train-model#4
#Imports and check that we are using TF2.x
import numpy as np
import os
import tensorflow as tf
print(tf.__version__)
from tflite_model_maker import configs
from tflite_model_maker import ExportFormat
from tflite_model_maker import model_spec
from tflite_model_maker import image_classifier
from tflite_model_maker.image_classifier import DataLoader
assert tf.__version__.startswith('2')
tf.get_logger().setLevel('ERROR')
#data_path = tf.keras.utils.get_file('flower_photos','https://storage.googleapis.com/download.tensorflow.org/example_images/flower_photos.tgz',untar=True)
data_path='F:\\Pneumonia\\chest_xray\\chest_xray\\train'
data = DataLoader.from_folder(data_path)
train_data, test_data = data.split(0.5)
model = image_classifier.create(train_data)
print(model)


# In[84]:


loss, accuracy = model.evaluate(test_data)
print(loss,accuracy)


# In[79]:


data_path='F:\\Pneumonia\\chest_xray\\chest_xray\\test'
data = DataLoader.from_folder(data_path)
train_data, test_data = data.split(0.5)
print(train_data, test_data)

loss, accuracy = model.evaluate(test_data)
print(loss,accuracy)


# In[76]:


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

from drawdata import draw_scatter
draw_scatter()#data.hist()
import pandas as pd
data=pd.read_clipboard(sep=",")
data.columns
data["z"].hist()

# https://blog.tensorflow.org/2021/05/introducing-tensorflow-decision-forests.html
get_ipython().system('pip install tensorflow_decision_forests')
# Load TensorFlow Decision Forests
import tensorflow_decision_forests as tfdf
# Load the training dataset using pandas
import pandas
train_df = pandas.read_csv("sample.csv")
# Convert the pandas dataframe into a TensorFlow dataset
train_ds = tfdf.keras.pd_dataframe_to_tf_dataset(train_df, label="class")
model = tfdf.keras.RandomForestModel()
model.fit(train_ds)
test_df = pandas.read_csv("penguins_test.csv")
# Convert it to a TensorFlow dataset
test_ds = tfdf.keras.pd_dataframe_to_tf_dataset(test_df, label="species")
# Evaluate the model
model.compile(metrics=["accuracy"])
print(model.evaluate(test_ds))
# Export the model to a TensorFlow SavedModel
model.save("project/model")
tfdf.model_plotter.plot_model_in_colab(model, tree_idx=0)
# Print all the available information about the model
model.summary()
# Get feature importance as a array
model.make_inspector().variable_importances()["MEAN_DECREASE_IN_ACCURACY"]
