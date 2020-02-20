#coding https://mattmazur.com/2015/03/17/a-step-by-step-backpropagation-example/ with tensorflow/keras, checking with iterative version at  https://github.com/animesh/ann/blob/master/ann/Program.cs with following output
#Iteration = 1   Error = 0.298371108760003       Outputs = 0.751365069552316     0.772928465321463
#Iteration = 2   Error = 0.291027773693599       Outputs = 0.742088111190782     0.775284968294459  ...
#https://matrices.io/deep-neural-network-from-scratch/ using https://www.tensorflow.org/alpha/guide/eager
#pip3 install tensorflow==2.0.0-rc0
#https://youtu.be/5ECD8J3dvDQ?t=455
inp=[0.05,0.10]
#inpw=[[0.15,0.25],[0.20,0.3]]
#hidw=[[0.4,0.5],[0.45,0.55]]
outputr=[0.01,0.99]
#bias=[0.35,0.6]
lr=0.5
import tensorflow
print(tensorflow.__version__)
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense, Activation
from tensorflow.keras.optimizers import Adam
import numpy as np
X = np.array([inp])
Y = np.array([outputr])
n_hidden = 2
#from tensorflow.keras import backend #or pip uninstall keras
#https://drscotthawley.github.io/devblog3/2019/02/08/My-1st-NN-Part-3-Multi-Layer-and-Backprop.html
model = Sequential([
    Dense(n_hidden, input_shape=(X.shape[1],), activation='relu'),
    Dense(Y.shape[1], activation='sigmoid')])
# choices for loss and optimization method
opt = Adam(lr=lr)   # We'll talk about optimizer choices later
model.compile(optimizer=opt, loss='binary_crossentropy',metrics=['binary_accuracy'])
# training iterations
maxiter=5000
model.fit(X, Y, epochs=maxiter, batch_size=Y.shape[1], verbose=0)
print("\nY_tilde = \n", model.predict(X) )
