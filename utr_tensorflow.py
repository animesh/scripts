import pandas as pd
data = pd.read_csv('F:/OneDrive - NTNU/UTR/data2.csv')
data.head()
data.describe()

import numpy as np
data['RFPlog']=np.log2(data['Fluorescence'])
data['RFPlog'].hist()

data['ReadsLog']=np.log2(data['#Reads Col'])
data['ReadsLog'].hist()
import matplotlib.pyplot as plt
plt.scatter(data['RFPlog'],data['ReadsLog'])

from functools import reduce
DNAortho = ('A','1000') , ('T','0100') ,  ('G','0010'), ('C','0001')
data['DNASeqOrtho']=reduce(lambda a, kv: a.str.replace(*kv), DNAortho, data['Sequence'])
print(data['DNASeqOrtho'])

df = df.dropna(axis=1, how='all')
df = df.dropna(axis=0, how='all')
print(df['DNASeqOrtho'])

input=df['DNASeqOrtho'].apply(lambda x: pd.Series(list(x)))
input = input.dropna(axis=1, how='all')
input = input.dropna(axis=0, how='all')
input.describe()
len(input.index)
input=input.loc[:,input.count()==len(input.index)].values
len(input)
df = data['RFPlog'].dropna(axis=0, how='all')
output=df.values
len(output)

X_scale=input
Y_scale=output
X=input
Y=output

from sklearn.model_selection import train_test_split
X_train, X_val_and_test, Y_train, Y_val_and_test = train_test_split(X_scale, Y, test_size=0.3)
X_val, X_test, Y_val, Y_test = train_test_split(X_val_and_test, Y_val_and_test, test_size=0.5)
print(X_train.shape, X_val.shape, X_test.shape, Y_train.shape, Y_val.shape, Y_test.shape)

from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense
model = Sequential([
    Dense(32, activation='relu', input_shape=(116,)),
    Dense(32, activation='relu'),
    Dense(1, activation='sigmoid'),
])
model.compile(optimizer='sgd',
              loss='binary_crossentropy',
              metrics=['accuracy'])
hist = model.fit(X_train, Y_train,
          batch_size=32, epochs=100,
          validation_data=(X_val, Y_val))
model.evaluate(X_test, Y_test)[1]
import matplotlib.pyplot as plt
plt.plot(hist.history['loss'])
plt.plot(hist.history['val_loss'])
plt.title('Model loss')
plt.ylabel('Loss')
plt.xlabel('Epoch')
plt.legend(['Train', 'Val'], loc='upper right')
plt.show()


model_2 = Sequential([
    Dense(1000, activation='relu', input_shape=(116,)),
    Dense(1000, activation='relu'),
    Dense(1000, activation='relu'),
    Dense(1000, activation='relu'),
    Dense(1, activation='sigmoid'),
])
model_2.compile(optimizer='adam',
              loss='binary_crossentropy',
              metrics=['accuracy'])
hist_2 = model_2.fit(X_train, Y_train,
          batch_size=32, epochs=100,
          validation_data=(X_val, Y_val))

plt.plot(hist_2.history['loss'])
plt.plot(hist_2.history['val_loss'])
plt.title('Model loss')
plt.ylabel('Loss')
plt.xlabel('Epoch')
plt.legend(['Train', 'Val'], loc='upper right')
plt.show()

from tensorflow.keras.layers import Dropout
from tensorflow.keras import regularizers
model_3 = Sequential([
    Dense(1000, activation='relu', kernel_regularizer=regularizers.l2(0.01), input_shape=(116,)),
    Dropout(0.3),
    Dense(1000, activation='relu', kernel_regularizer=regularizers.l2(0.01)),
    Dropout(0.3),
    Dense(1000, activation='relu', kernel_regularizer=regularizers.l2(0.01)),
    Dropout(0.3),
    Dense(1000, activation='relu', kernel_regularizer=regularizers.l2(0.01)),
    Dropout(0.3),
    Dense(1, activation='sigmoid', kernel_regularizer=regularizers.l2(0.01)),
])

model_3.compile(optimizer='adam',
              loss='binary_crossentropy',
              metrics=['accuracy'])
hist_3 = model_3.fit(X_train, Y_train,
          batch_size=32, epochs=100,
          validation_data=(X_val, Y_val))

plt.plot(hist_3.history['loss'])
plt.plot(hist_3.history['val_loss'])
plt.title('Model loss')
plt.ylabel('Loss')
plt.xlabel('Epoch')
plt.legend(['Train', 'Val'], loc='upper right')
plt.ylim(top=1.2, bottom=0)
plt.show()
