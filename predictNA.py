# #### Effect of pooling samples on the efficiency of comparative studies using microarrays
# https://academic.oup.com/bioinformatics/article/21/24/4378/180078
# #### Baseed on https://www.curiousily.com/posts/deploy-keras-deep-learning-project-to-production-with-flask/
#python -m pip install --upgrade pip --user
#python -m pip install pandas --user --upgrade setuptools
#python -m pip install gdown --user
#!python -m pip install tensorflow-gpu --user
#python -m pip install seaborn --user
#python -m pip install sklearn --user

import numpy as np
import tensorflow as tf
from tensorflow import keras
import pandas as pd
import seaborn as sns
from pylab import rcParams
import matplotlib.pyplot as plt
from matplotlib import rc
from sklearn.model_selection import train_test_split
import joblib
sns.set(style='whitegrid', palette='muted', font_scale=1.5)
rcParams['figure.figsize'] = 8, 6
RANDOM_SEED = 42
np.random.seed(RANDOM_SEED)
tf.random.set_seed(RANDOM_SEED)

from pathlib import Path
inpF = Path("L:/promec/HF/Lars/2019/november/siri_marit/combined/txt/proteinGroups.txt")
Path.exists(inpF)
df = pd.read_csv(inpF,sep='\t')
df.head()
df.shape
df.columns
sns.distplot(df.Peptides);
sns.distplot(np.log1p(df.Peptides));
sns.countplot(x='Number of proteins', data=df);
sns.countplot(x='Peptide counts (all)', data=df);
sns.distplot(df.Peptides);
corr_matrix = df.corr()
corrPeptides = corr_matrix['Peptides']
corrPeptides.iloc[corrPeptides.abs().argsort()]
#palette = sns.diverging_palette(20, 220, n=256)
sns.heatmap(corr_matrix)#, annot=True, fmt=".2f", cmap=palette, vmax=.3, center=0,square=True, linewidths=.5);

missing = df.isnull().sum()
missing[missing > 0].sort_values(ascending=False)

import numpy as np
dfLFQ=df.loc[:, df.columns.str.startswith('LFQ')&df.columns.str.contains('pim')]
#df['Ratio H/L normalized 161205_1_19913'].apply(np.log2).hist()
dfLFQ=(dfLFQ+1).apply(np.log2)
dfLFQ.hist()

missing = (dfLFQ==0).sum()
missing[missing > 0].sort_values(ascending=False)

missing = df.isnull().sum()
missing[missing > 0].sort_values(ascending=False)

dfLFQ.columns
dfLFQ.head()
X = dfLFQ[dfLFQ.columns[-3:]]#'LFQ intensity 14_TK9_apim_poolet','LFQ intensity 14_TK9_apim_poolet']
y = dfLFQ['LFQ intensity 14_TK9_apim_poolet']

from sklearn.preprocessing import OneHotEncoder
data = [['value'], ['NA']]
OneHotEncoder(sparse=False).fit_transform(data)

from sklearn.preprocessing import MinMaxScaler, OneHotEncoder
from sklearn.compose import make_column_transformer
transformer = make_column_transformer(#(OneHotEncoder(handle_unknown="ignore"), ['neighbourhood_group', 'room_type']),
    (MinMaxScaler(), ['LFQ intensity 5_TK9_apim_2','LFQ intensity 6_TK9_apim_3'])
)

transformer.fit(X)
X = transformer.transform(X)
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=RANDOM_SEED)
X_train.shape

def plot_mse(history):
  hist = pd.DataFrame(history.history)
  hist['epoch'] = history.epoch

  plt.figure()
  plt.xlabel('Epoch')
  plt.ylabel('MSE')
  plt.plot(hist['epoch'], hist['mse'],
            label='Train MSE')
  plt.plot(hist['epoch'], hist['val_mse'],
            label = 'Val MSE')
  plt.legend()
  plt.show()

model = keras.Sequential()
model.add(keras.layers.Dense(units=64, activation="relu", input_shape=[X_train.shape[1]]))
model.add(keras.layers.Dropout(rate=0.3))
model.add(keras.layers.Dense(units=32, activation="relu"))
model.add(keras.layers.Dropout(rate=0.5))

model.add(keras.layers.Dense(1))

model.compile(
    optimizer=keras.optimizers.Adam(0.0001),
    loss = 'mse',
    metrics = ['mse'])

BATCH_SIZE = 32

early_stop = keras.callbacks.EarlyStopping(
  monitor='val_mse',
  mode="min",
  patience=10
)

history = model.fit(
  x=X_train,
  y=y_train,
  shuffle=True,
  epochs=100,
  validation_split=0.2,
  batch_size=BATCH_SIZE,
  callbacks=[early_stop]
)

plot_mse(history)

from sklearn.metrics import mean_squared_error
from sklearn.metrics import mean_absolute_error
from math import sqrt
from sklearn.metrics import r2_score

print(X_test.shape,y_test.shape)
y_pred = model.predict(X_test)

print(mean_squared_error(y_test, y_pred))
print(mean_absolute_error(y_test, y_pred))
print(np.sqrt(mean_squared_error(y_test, y_pred)))
print(r2_score(y_test, y_pred))

joblib.dump(transformer, "data_transformer.joblib")
model.save("missing_value_prediction_model.h5")
