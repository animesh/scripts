import os
from glob import glob
dataP="L://Animesh/ChestX-ray14/"
imgs = glob(os.path.join(dataP+'images', "*.png")) #https://nihcc.app.box.com/v/ChestXray-NIHCC/file/221185642661
imgs[2]

%matplotlib inline
import cv2
import matplotlib.pylab as plt
cvimg = cv2.imread(imgs[1000],1)
plt.imshow(cvimg)

import numpy as np
Xrays256 = np.array([cv2.resize(cv2.imread(img,0), (256, 256), interpolation = cv2.INTER_AREA)/255 for img in imgs[:]])
print(Xrays256.shape)

import pandas as pd
validation = pd.read_table(dataP+'labels/val_list.txt.sel', sep=' ', header=None, index_col=0)
train = pd.read_table(dataP+"labels/train_list.txt.sel", sep=' ',index_col=0,header=None)
test = pd.read_table(dataP+"labels/test_list.txt.sel", sep=' ',index_col=0,header=None)
print(validation, train, test)

#https://stanfordmlgroup.github.io/projects/chexnet/
#https://www.nih.gov/news-events/news-releases/nih-clinical-center-provides-one-largest-publicly-available-chest-x-ray-datasets-scientific-community
pathology_list = ['Atelectasis','Cardiomegaly','Effusion','Infiltration','Mass','Nodule','Pneumonia','Pneumothorax','Consolidation','Edema','Emphysema','Fibrosis','Pleural_Thickening','Hernia']
print(len(pathology_list))
sample_labels=validation.append([train, test],ignore_index=True)
sample_labels.columns=pathology_list
print(sample_labels.head())
