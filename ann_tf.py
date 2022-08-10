#coding https://mattmazur.com/2015/03/17/a-step-by-step-backpropagation-example/ with tensorflow/keras, checking with iterative version at  https://github.com/animesh/ann/blob/master/ann/Program.cs with following output
#Iteration = 1   Error = 0.298371108760003       Outputs = 0.751365069552316     0.772928465321463
#Iteration = 2   Error = 0.291027773693599       Outputs = 0.742088111190782     0.775284968294459  ...
#https://matrices.io/deep-neural-network-from-scratch/ using https://www.tensorflow.org/alpha/guide/eager
#https://colab.research.google.com/github/tensorchiefs/dl_book/blob/master/chapter_03/nb_ch03_04.ipynb#scrollTo=zACb9J35KP92
#pip3 install tensorflow==2.0.0-rc0
#https://youtu.be/5ECD8J3dvDQ?t=455
#https://tensorchiefs.github.io/dl_book/
#conda create --name tf python=3.9
#conda activate tf
#mamba install - c nvidia - c conda-forge cudatoolkit = 11.2 cudnn = 8.1.0
#pip install tensorflow
#export LD_LIBRARY_PATH =$LD_LIBRARY_PATH: $CONDA_PREFIX/lib/
os.environ["LD_LIBRARY_PATH"] = "/home/ash022/mambaforge/envs/tf/lib"
#!ls $LD_LIBRARY_PATH
import tensorflow as tf
tf.keras.backend.clear_session()
from tensorflow.python.client import device_lib
print(device_lib.list_local_devices())
print("Version: ", tf.__version__)
print("Eager mode: ", tf.executing_eagerly())
tf.compat.v1.disable_eager_execution()
print("Eager mode: ", tf.executing_eagerly())
print("GPU is", "available" if tf.config.list_physical_devices('GPU') else "NOT AVAILABLE")
print(tf.config.list_physical_devices('GPU'))
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense, Activation
from tensorflow.keras.optimizers import Adam
import numpy as np
inp=[0.05,0.10]
#inpw=[[0.15,0.25],[0.20,0.3]]
#hidw=[[0.4,0.5],[0.45,0.55]]
outputr=[0.01,0.99]
#bias=[0.35,0.6]
lr=0.5
X = np.asarray(inp, np.float32)
Y = np.asarray(outputr, np.float32)
tf.reset_default_graph()                                   # “Wipe the blackboard”, construct a new graph
a_  = tf.Variable(0.0, name='a_var')                       # Variables, with starting values, will be optimized later
b_  = tf.Variable(139.0, name='b_var')                     # we name them so that they look nicer in the graph
x_  = tf.constant(X[0], name='x_const')                       # Constants, these are fixed tensors holding the data values and cannot be changed by the optimization
y_  = tf.constant(X[1], name='y_const')
ax_ = a_* x_
abx_ = ax_ + b_
r_ = abx_ - y_
s_ = tf.square(r_)
mse_ = tf.reduce_mean(s_)

grad_mse_s_ = tf.gradients(mse_, [s_])                      # gradient of mse_ w.r.t s_
grad_s_r_ = tf.gradients(s_, [r_])                          # gradient of s_ w.r.t r_
grad_r_abx_ = tf.gradients(r_, [abx_])                      # gradient of r_ w.r.t abx_
grad_abx_b_ = tf.gradients(abx_, [b_])                      # gradient of abx_ w.r.t b_
grad_abx_ax_ = tf.gradients(abx_, [ax_])                    # gradient of abx_ w.r.t ax_
grad_ax_a_ = tf.gradients(ax_, [a_])                        # gradient of ax_ w.r.t a_

grads_mse_a_b_ = tf.gradients(mse_, [a_,b_])                # gradient of mse_ w.r.t a_ and b_ (what we actually want)


writer = tf.summary.FileWriter("linreg/", tf.get_default_graph())
writer.close()

n_hidden = 2
#from tensorflow.keras import backend #or pip uninstall keras
#https://drscotthawley.github.io/devblog3/2019/02/08/My-1st-NN-Part-3-Multi-Layer-and-Backprop.html
model = Sequential([
    Dense(n_hidden, input_shape=(X.shape[1],), activation='relu'),
    Dense(Y.shape[1], activation='sigmoid')])
# choices for loss and optimization method
opt = Adam()   # We'll talk about optimizer choices later
model.compile(optimizer=opt, loss='binary_crossentropy',metrics=['binary_accuracy'])
# training iterations
maxiter=5000
model.fit(X, Y, epochs=maxiter, batch_size=Y.shape[1], verbose=0)
print("\nY_tilde = \n", model.predict(X) )
