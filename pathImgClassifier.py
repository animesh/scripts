from pathlib import Path
pathmura = Path('C:/Users/animeshs/OneDrive - NTNU/MURA-v1.1/MURA-v1.1')
trainlist=list(pathmura.glob('train/*/*/*/*.png'))
import numpy as np
import cv2
from matplotlib import pyplot as plt
img = cv2.imread(str(trainlist[-1]),0)
plt.imshow(img, cmap = 'gray', interpolation = 'bicubic')
plt.show()

matching = [s for s in (tinlist) if 'negative' in s...]
trainlist[2].parts[-2]

import random
import torch
N=5
scale=10
D_in, H, D_out = N*scale*scale, N*scale*scale, N*scale

class DynamicNet(torch.nn.Module):
    def __init__(self, D_in, H, D_out):
        super(DynamicNet, self).__init__()
        self.input_linear = torch.nn.Linear(D_in, H)
        self.middle_linear = torch.nn.Linear(H, H)
        self.output_linear = torch.nn.Linear(H, D_out)
    def forward(self, x):
        h_relu = self.input_linear(x).clamp(min=0)
        for _ in range(random.randint(0, int(N/scale))):
            h_relu = self.middle_linear(h_relu).clamp(min=0)
        y_pred = self.output_linear(h_relu)
        return y_pred

x = torch.randn(N, D_in)
y = torch.randn(N, D_out)

model = DynamicNet(D_in, H, D_out)

criterion = torch.nn.MSELoss(reduction='sum')
optimizer = torch.optim.SGD(model.parameters(), lr=1e-4, momentum=0.9)
for t in range(H):
    y_pred = model(x)
    loss = criterion(y_pred, y)
    print(t, loss.item())
    optimizer.zero_grad()
    loss.backward()
    optimizer.step()


import pandas as pd
pd.read_csv((pathmura /'train_image_paths.csv'))

#check with https://github.com/animesh/ann/blob/master/ann/Program.cs
#Iteration = 1   Error = 0.298371108760003       Outputs = 0.751365069552316     0.772928465321463
#Iteration = 2   Error = 0.291027773693599       Outputs = 0.742088111190782     0.775284968294459
inp=[0.05,0.10]
inpw=[[0.15,0.20],[0.25,0.3]]
hidden=2
hidw=[[0.4,0.45],[0.5,0.55]]
outputc=2
outputr=[0.01,0.99]
bias=[0.35,0.6]
cons=[1,1]
lr=0.5
error=1
itr=1000

#https://github.com/jcjohnson/pytorch-examples/blob/master/README.md  numpy
import numpy as np
x=np.asarray(inp)
y=np.asarray(outputr)
b=np.asarray(bias)
w1=np.asarray(inpw)
w1=w1.T
w2=np.asarray(hidw)
w2=w2.T
print(x,y,b,w1,w2)

h=1/(1+np.exp(-(x.dot(w1)+b[0])))
y_pred=1/(1+np.exp(-(h.dot(w2)+b[1])))
0.5*np.square(y_pred - y).sum()

w3=w2-(lr*(y_pred - y)*(1-y_pred)*y_pred*h)
w2-lr*(y_pred[1] - y[1])*(1-y_pred[1])*y_pred[1]*h[1]
w2-lr*(y_pred[0] - y[0])*(1-y_pred[0])*y_pred[0]*h[0]
w4=w1-lr*sum((y_pred - y)*(1-y_pred)*y_pred*w2)*h*(1-h)*x

h1=1/(1+np.exp(-(x.dot(w4)+b[0])))
y_pred_h1=1/(1+np.exp(-(h1.dot(w3)+b[1])))
0.5*np.square(y_pred_h1 - y).sum()

w3-=lr*(y_pred - y)*(1-y_pred)*y_pred*h
w4=w4-lr*sum(((y_pred - y)*(1-y_pred)*y_pred*w2)*h*(1-h)*x
h1=1/(1+np.exp(-(x.dot(w4)+b[0])))
y_pred_h1=1/(1+np.exp(-(h1.dot(w3)+b[1])))
0.5*np.square(y_pred_h1 - y).sum()


import random
import torch
N=22
scale=10
D_in, H, D_out = N*scale*scale, N*scale*scale, N*scale

class DynamicNet(torch.nn.Module):
    def __init__(self, D_in, H, D_out):
        super(DynamicNet, self).__init__()
        self.input_linear = torch.nn.Linear(D_in, H)
        self.middle_linear = torch.nn.Linear(H, H)
        self.output_linear = torch.nn.Linear(H, D_out)
    def forward(self, x):
        h_relu = self.input_linear(x).clamp(min=0)
        for _ in range(random.randint(0, int(N/scale))):
            h_relu = self.middle_linear(h_relu).clamp(min=0)
        y_pred = self.output_linear(h_relu)
        return y_pred

x = torch.randn(N, D_in)
y = torch.randn(N, D_out)

model = DynamicNet(D_in, H, D_out)

criterion = torch.nn.MSELoss(reduction='sum')
optimizer = torch.optim.SGD(model.parameters(), lr=1e-4, momentum=0.9)
for t in range(H):
    y_pred = model(x)
    loss = criterion(y_pred, y)
    print(t, loss.item())
    optimizer.zero_grad()
    loss.backward()
    optimizer.step()

import pathlib
file = pathlib.Path.cwd().parent.parent/'PAVES Challenge'
file=file.rglob('')
for i in file: print(i)
imgs = [i for i in file]
print(i)

import pydicom
from pydicom.data import get_testdata_files
from pydicom.filereader import read_dicomdir
dicom_dir = read_dicomdir(file.absolute())
#ds = pydicom.dcmread("C:\Users\animeshs\OneDrive - NTNU\PAVES Challenge\Case 9")

import cv2
import matplotlib.pylab as plt
%matplotlib inline
cvimg = cv2.imread(i,1)
plt.imshow(i)

import numpy as np
Xrays256 = np.array([cv2.resize(cv2.imread(img,0), (256, 256), interpolation = cv2.INTER_AREA)/255 for img in imgs[:]])
print(Xrays256.shape)

import pandas as pd
validation = pd.read_table(dataP+'labels/val_list.txt.sel', sep=' ', header=None, index_col=0)
train = pd.read_table(dataP+"labels/train_list.txt.sel", sep=' ',index_col=0,header=None)
test = pd.read_table(dataP+"labels/test_list.txt.sel", sep=' ',index_col=0,header=None)
topl=5
print(validation.head(topl), train.head(topl), test.head(topl))

#https://stanfordmlgroup.github.io/projects/chexnet/
pathology_list = ['Atelectasis','Cardiomegaly','Effusion','Infiltration','Mass','Nodule','Pneumonia','Pneumothorax','Consolidation','Edema','Emphysema','Fibrosis','Pleural_Thickening','Hernia']
print(len(pathology_list))
sample_labels=validation.append([train, test],ignore_index=True)
sample_labels.columns=pathology_list
print(sample_labels.shape)

import tensorflow as tf
learning = 0.01
epochs = 100
hidden_1 = 256
hidden_2 = 256
input = 256*256
classes = 14
print(learning,epochs,hidden_1,hidden_2,input,classes)

X = tf.placeholder("float", [None, input])
Y = tf.placeholder("float", [None, classes])

weights = {
    'h1': tf.Variable(tf.random_normal([input, hidden_1])),
    'h2': tf.Variable(tf.random_normal([hidden_1, hidden_2])),
    'out': tf.Variable(tf.random_normal([hidden_2, classes]))
}
biases = {
    'b1': tf.Variable(tf.random_normal([hidden_1])),
    'b2': tf.Variable(tf.random_normal([hidden_2])),
    'out': tf.Variable(tf.random_normal([classes]))
}

def mlp(x):
    layer_1 = tf.add(tf.matmul(x, weights['h1']), biases['b1'])
    layer_2 = tf.add(tf.matmul(layer_1, weights['h2']), biases['b2'])
    out_layer = tf.matmul(layer_2, weights['out']) + biases['out']
    return out_layer

logits = mlp(X)

# Define loss and optimizer
loss_op = tf.reduce_mean(tf.nn.softmax_cross_entropy_with_logits(
    logits=logits, labels=Y))
optimizer = tf.train.AdamOptimizer(learning_rate=learning)
train_op = optimizer.minimize(loss_op)
init = tf.global_variables_initializer()

with tf.Session() as sess:
    sess.run(init)
    for epoch in range(epochs):
        avg_cost = 0.
        sess.run([train_op, loss_op], feed_dict={X: Xrays256, Y: sample_labels})
        avg_cost += c / total_batch
        print("Epoch:", '%04d' % (epoch+1), "cost={:.9f}".format(avg_cost))

    pred = tf.nn.softmax(logits)  # Apply softmax to logits
    correct_prediction = tf.equal(tf.argmax(pred, 1), tf.argmax(Y, 1))
    # Calculate accuracy
    accuracy = tf.reduce_mean(tf.cast(correct_prediction, "float"))
    print("Accuracy:", accuracy.eval({X: mnist.test.images, Y: mnist.test.labels}))
