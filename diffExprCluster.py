import  os
os.path.expanduser("~")
import datetime
print(datetime.datetime.now())

from pathlib import Path
#inpD = Path.cwd()
inpD = Path("F:\\HeLa\\txt\\")
print(inpD)
inpF="proteinGroups.txt"
Path.exists(inpD/inpF)

import pandas as pd
df = pd.read_table(inpD/inpF)
df.describe()

import numpy as np
dfSILAC=df.loc[:,df.columns.str.startswith('Ratio')&df.columns.str.contains('normalized')]

dfSILAC=dfSILAC.rename(columns = lambda x : str(x)[21:])
rowName= df["Protein IDs"].str.split(';').str[0]
dfSILAC=dfSILAC.rename(index=rowName)
#print(dfSILAC.columns)
#df.hist()

#https://followthedata.wordpress.com/2020/01/20/modelling-tabular-data-with-catboost-and-node/
#pip install catboost
from catboost import CatBoostClassifier, Pool
#pip install hyperopt
from hyperopt import fmin, hp, tpe
from sklearn.model_selection import StratifiedKFold
nfolds = 5
skf = StratifiedKFold(n_splits=nfolds, shuffle=True)
acc = []

#https://github.com/BIMSBbioinfo/maui/blob/master/vignette/maui_vignette.ipynb
import maui
import maui.utils
print(f'Maui version: {maui.__version__}')
#https://scikit-learn.org/stable/modules/generated/sklearn.preprocessing.PowerTransformer.html
from sklearn.preprocessing import PowerTransformer
pt = PowerTransformer()
dfSILAClog2=np.log2(dfSILAC+1) #really weird scaling
print(pt.fit(dfSILAClog2))
dfSILACtf=pt.transform(dfSILAClog2)
print(pt.lambdas_)
dfSILAClog2tf = maui.utils.scale(dfSILAClog2)
from keras import backend as K
import tensorflow as tf
#K.set_session(K.tf.Session(config=K.tf.ConfigProto(intra_op_parallelism_threads=12, inter_op_parallelism_threads=12)))
maui_model = maui.Maui(n_hidden=[1100], n_latent=70, epochs=400)
z = maui_model.fit_transform({'mRNA': dfSILAClog2tf})
maui_model.hist.plot()
maui_model.cluster(ami_y = z)

maui_model.kmeans_scores.plot()
import seaborn as sns
sns.clustermap(maui_model.z_)

inp=[0.05,0.10]
inpw=[[0.15,0.25],[0.20,0.3]]
hidw=[[0.4,0.5],[0.45,0.55]]
outputr=[0.01,0.99]
bias=[0.35,0.6]
lr=0.5
#https://jaredwinick.github.io/what_is_tf_keras/
w1 = tf.Variable(inpw)
w2 = tf.Variable(hidw)
x = tf.constant(inp)
y = tf.constant(outputr)


layer_1 = 1/(1+tf.exp(-(tf.add(tf.matmul([x], w1), bias[0]))))
layer_2 = 1/(1+tf.exp(-(tf.add(tf.matmul(layer_1, w2), bias[1]))))
print(layer_2)

epochs = 2
for epoch in range(epochs):
    with tf.GradientTape() as t:
        layer_1 = 1/(1+tf.exp(-(tf.add(tf.matmul([x], w1), bias[0]))))
        layer_2 = 1/(1+tf.exp(-(tf.add(tf.matmul(layer_1, w2), bias[1]))))
        loss = y - layer_2
    #dW, dB = t.gradient(loss, [w2, bias[1]])
    print(t.gradient(loss, [w2, bias[1]]))
    #weights.assign_sub(lr * dW)
    #bias.assign_sub(lr * dB)
