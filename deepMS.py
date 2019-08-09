#git clone https://github.com/animesh/DeepNovo-DIA
#USAGE: python deepMS.py

import tensorflow as tf
print("TensorFlow version: {}".format(tf.__version__))

import numpy as np
def parseMGF(mgfData):
    data = open(str(mgfData), "r").read().splitlines()
    _comments = '#;!/'
    reading_spectrum = False
    params = {}
    masses = []
    intensities = []
    charges = []
    out = {}
    cnt = 0
    pep_mass = 0
    pep_intensity = 0
    out = {}
    for line in data:
        if not reading_spectrum:
            if line.strip() == 'BEGIN IONS': reading_spectrum = True
        else:
            if not line.strip() or any(line.startswith(c) for c in _comments): pass
            elif line.strip() == 'END IONS':
                reading_spectrum = False
                title = params['title'].split()[0]
                if 'pepmass' in params:
                    try:
                        pl = params['pepmass'].split()
                        if len(pl) > 1:
                            pep_mass = float(pl[0])
                            pep_intensity = float(pl[2])
                        elif len(pl) == 1: pep_mass = float(pl[0])
                    except ValueError: print("Error in parsing pepmass value")
                out[cnt] = {'pep_mass': pep_mass,'pep_intensity': pep_intensity,'rtinseconds': params['rtinseconds'],'title': params['title'],'charge': params['charge'],'mz_array': np.array(masses),'intensity_array': np.array(intensities)}
                cnt += 1
            else:
                l = line.split('=', 1)
                if len(l) > 1: params[l[0].lower()] = l[1].strip()
                elif len(l) == 1:  # looks like a peak list ;)
                    l = line.split()
                    if len(l) >= 2:
                        try:
                            masses.append(float(l[0]))
                            intensities.append(float(l[1]))
                        except ValueError:
                            print("Error in parsing line "+line)
    return out

from pathlib import Path
home=Path.cwd()
print(home)
#file = home.parent.rglob('*.MGF')
file = home.parent / 'Documents/RawRead/171010_Ip_Hela_ugi.raw.intensity0.charge0.MGF'
#print(open(str(file), "r").read().splitlines())

out=parseMGF(file)
X=[(out[k]['pep_mass']-1.00727647)*int(out[k]['charge'].split('+')[0]) for k, _ in out.items()]
X=np.array(X).reshape(-1, 1)
#X=np.expand_dims(X, axis=0)
print(X.shape)

#import matplotlib.pyplot as plt
#plt.hist(X)
#plt.savefig('hist.png')
from scipy.stats import skew
print (skew(X))

#https://stackoverflow.com/a/41134887/1137129
K=4
# Import MNIST data
#from tensorflow.examples.tutorials.mnist import input_data
#mnist = input_data.read_data_sets("/tmp/data/", one_hot=True)
#Xtr, Ytr = mnist.train.next_batch(55000)  # whole training set
#Xte, Yte = mnist.test.next_batch(10000)  # whole test set
# tf Graph Input
Xtr, Ytr = X.transpose(),X.transpose().astype(int)#.train.next_batch(55000)  # whole training set
Xte, Yte = X,X.astype(int)#.train.next_batch(55000)  # whole training set
xtr = tf.placeholder("float", [None, X.shape[0]])
ytr = tf.placeholder("float", [None, X.shape[1]])
xte = tf.placeholder("float", [X.shape[0]])
# Euclidean Distance
distance = tf.negative(tf.sqrt(tf.reduce_sum(tf.square(tf.subtract(xtr, xte)), reduction_indices=1)))
# Prediction: Get min distance neighbors
values, indices = tf.nn.top_k(distance, k=K, sorted=False)
nearest_neighbors = []
for i in range(K):
    nearest_neighbors.append(tf.argmax(ytr[indices[i]], 0))
neighbors_tensor = tf.stack(nearest_neighbors)
y, idx, count = tf.unique_with_counts(neighbors_tensor)
pred = tf.slice(y, begin=[tf.argmax(count, 0)], size=tf.constant([1], dtype=tf.int64))[0]
accuracy = 0.
# Initializing the variables
init = tf.initialize_all_variables()
# Launch the graph
with tf.Session() as sess:
    sess.run(init)
    # loop over test data
    for i in range(len(Xte)):
        # Get nearest neighbor
        nn_index = sess.run(pred, feed_dict={xtr: Xtr, ytr: Ytr, xte: Xte[i, :]})
        # Get nearest neighbor class label and compare it to its true label
        print("Test", i, "Prediction:", nn_index,
             "True Class:", np.argmax(Yte[i]))
        #Calculate accuracy
        if nn_index == np.argmax(Yte[i]):
            accuracy += 1. / len(Xte)
    print("Done!")
    print("Accuracy:", accuracy)
