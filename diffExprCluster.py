#https://github.com/bendemeo/shannonca
#reduce function accepts a (num genes) x (num cells) matrix X, and outputs a dimensionality-reduced version 
from shannonca.dimred import reduce
from scipy.io import mmread
import os
os.chdir('F:/GD/OneDrive/Dokumenter/GitHub/scripts/')
os.getcwd()
X = mmread('Supplementary Table 2 for working purpose.xlsxtrp.id.wekG3.csv.arff.csv')#.transpose() #reduction is an (num cells) x (n_comps)-dimensional matrix. The function optionally returns SCA's score matrix (if keep_scores=True), metagene loadings (if keep_loadings=True), or intermediate results (if iters>1 and keep_all_iters=True). If at least one of these is returned, the return type is a dictionary with keys for 'reduction', 'scores', and 'loadings'. If keep_all_iters=True, the reductions after each iteration will be keyed by 'reduction_i' for each iteration
sreduction = reduce(X, n_comps=50, n_pcs=50, iters=1, nbhd_size=15, metric='euclidean', model='wilcoxon', chunk_size=1000, n_tests='auto')

#https://github.com/microsoft/FLAML
from flaml import AutoML
from sklearn.datasets import load_iris
# Initialize an AutoML instance
automl = AutoML()
# Specify automl goal and constraint
automl_settings = {
    "time_budget": 10,  # in seconds
    "metric": 'accuracy',
    "task": 'classification',
    "log_file_name": "test/iris.log",
}
X_train, y_train = load_iris(return_X_y=True)
# Train with labeled input data
automl.fit(X_train=X_train, y_train=y_train,**automl_settings)
# Predict
print(automl.predict_proba(X_train))
# Export the best model
print(automl.model)
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
