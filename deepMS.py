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
mIsoMass=[(out[k]['pep_mass']-1.00727647)*int(out[k]['charge'].split('+')[0]) for k, _ in out.items()]
#import matplotlib.pyplot as plt
#plt.hist(mIsoMass)
#plt.savefig('hist.png')
mzRT=[out[k]['rtinseconds'] for k, _ in out.items()]
plt.hist(mzRT)
plt.scatter(mzRT,mIsoMass)
mzRTnp=np.float32(np.array(mzRT).reshape(1, -1))
mIsoMassnp=np.float32(np.array(mIsoMass).reshape(1, -1))
print(type(mIsoMassnp))
#X=np.expand_dims(X, axis=0)
print(mIsoMassnp.shape,mzRTnp.shape)

from scipy.stats import skew
print(skew(mIsoMass))
print(min(mzRT))

#https://www.analyticsvidhya.com/blog/2016/10/an-introduction-to-implementing-neural-networks-using-tensorflow/
seed=mIsoMassnp.shape[1]
rng = np.random.RandomState(seed)
input_num_units = seed
hidden_num_units = seed
output_num_units = seed
learning_rate=0.01
epochs=100
weights = {
    'hidden': tf.Variable(tf.random_normal([input_num_units, hidden_num_units], seed=seed)),
    'output': tf.Variable(tf.random_normal([hidden_num_units, output_num_units], seed=seed))
}
biases = {
    'hidden': tf.Variable(tf.random_normal([hidden_num_units], seed=seed)),
    'output': tf.Variable(tf.random_normal([output_num_units], seed=seed))
}
hidden_layer = tf.add(tf.matmul(mIsoMassnp, weights['hidden']), biases['hidden'])
hidden_layer = tf.nn.relu(hidden_layer)

output_layer = tf.matmul(hidden_layer, weights['output']) + biases['output']
cost = tf.reduce_mean(output_layer-mzRTnp)
optimizer = tf.train.AdamOptimizer(learning_rate=learning_rate).minimize(cost)
init = tf.initialize_all_variables()
batch_size=seed
train=mIsoMassnp
with tf.Session() as sess:
    sess.run(init)
    for epoch in range(epochs):
        avg_cost = 0
        total_batch = int(train.shape[0]/batch_size)
        for i in range(total_batch):
            batch_x, batch_y = batch_creator(batch_size, train_x.shape[0], 'train')
            _, c = sess.run([optimizer, cost], feed_dict = {x: batch_x, y: batch_y})
            avg_cost += c / total_batch
        print("Epoch:", (epoch+1), "cost =", "{:.5f}".format(avg_cost))
    print("\nTraining complete!")
    # find predictions on val set
    pred_temp = tf.equal(tf.argmax(output_layer, 1), tf.argmax(y, 1))
    accuracy = tf.reduce_mean(tf.cast(pred_temp, "float"))
    predict = tf.argmax(output_layer, 1)
