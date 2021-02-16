import tensorflow as tf
print(tf.__version__)
#https://stackoverflow.com/a/40219528/1137129
tf.random.set_seed(42)
#vecs=tf.random.uniform(shape=[n],minval=0,maxval=n,dtype=tf.dtypes.int64)
#https://laurentlessard.com/bookproofs/mismatched-socks/
n=1000
j=0
k=[]
while j < n:
    vecs=tf.range(0,j, delta=1, dtype=tf.dtypes.int64, name='range')
    vecs=tf.concat([vecs, vecs],-1)
    vecs=tf.random.shuffle(vecs)
    print(vecs)

    i=0
    a = { i : 0 for i in vecs.numpy() }
    while i < len(vecs):
        if a[vecs[i].numpy()]>0:
            print(i,vecs[i].numpy())
            k.append(i)
            break
        a[vecs[i].numpy()]+=1
        i += 1
    j+=1
# Open a file
from pathlib import Path
(Path.cwd()/"k.txt")

import matplotlib.pyplot as plt
plt.hist(k)
plt.plot(k)

vecs = tf.random.uniform(shape=[n, 10, 1])
mats = tf.random.uniform(shape=[n, 10, 10])
print(vecs.shape,mats.shape,tf.linalg.solve(mats, vecs))

import numpy as np
def for_loop_solve():
  return np.array(
    [tf.linalg.solve(mats[i, ...], vecs[i, ...]) for i in range(1000)])
for_loop_solve()

a = tf.constant(np.pi)
b = tf.constant(np.e)
with tf.GradientTape() as tape:
  tape.watch([a, b])
  c = .5 * (a**2 + b**2)
grads = tape.gradient(c, [a, b])
print(grads[0],a,grads[1],b)

#https://www.tensorflow.org/probability/api_docs/python/tfp/stats/correlation
x = tf.random.normal(shape=(100, 2, 3))
y = tf.random.normal(shape=(100, 2, 3))

import tensorflow_probability as tfp
print(tfp.__version__)

corr = tfp.stats.correlation(x, y, sample_axis=0, event_axis=None)
corr_matrix = tfp.stats.correlation(x, y, sample_axis=0, event_axis=-1)

plt.hist(corr)

tfd = tfp.distributions
normal = tfd.Normal(loc=0., scale=1.)
print(normal.log_prob(0.))

import seaborn as sns
samples = normal.sample(1000)
sns.distplot(samples)

tfb = tfp.bijectors
normal_cdf = tfb.NormalCDF()
xs = np.linspace(-4., 4., 200)
import matplotlib.pyplot as plt
plt.plot(xs, normal_cdf.forward(xs))

exp_bijector = tfb.Exp()
log_normal = exp_bijector(tfd.Normal(0., .5))

samples = log_normal.sample(1000)
xs = np.linspace(1e-10, np.max(samples), 200)
sns.distplot(samples, norm_hist=True, kde=False)
plt.plot(xs, log_normal.prob(xs), c='k', alpha=.75)


def f(x, w):
  x = tf.pad(x, [[1, 0], [0, 0]], constant_values=1)
  linop = tf.linalg.LinearOperatorFullMatrix(w[..., np.newaxis])
  result = linop.matmul(x, adjoint=True)
  return result[..., 0, :]

num_features = 2
num_examples = 50
noise_scale = .5
true_w = np.array([-1., 2., 3.])

xs = np.random.uniform(-1., 1., [num_features, num_examples])
ys = f(xs, true_w) + np.random.normal(0., noise_scale, size=num_examples)
# Visualize the data set
plt.scatter(*xs, c=ys, s=100, linewidths=0)

grid = np.meshgrid(*([np.linspace(-1, 1, 100)] * 2))
xs_grid = np.stack(grid, axis=0)
fs_grid = f(xs_grid.reshape([num_features, -1]), true_w)
fs_grid = np.reshape(fs_grid, [100, 100])
plt.contour(xs_grid[0, ...], xs_grid[1, ...], fs_grid, 20, linewidths=1)


features = tfp.distributions.Normal(loc=0., scale=1.).sample(int(100e3))
labels = tfp.distributions.Bernoulli(logits=1.618 * features).sample()

# Specify model.
model = tfp.glm.Bernoulli()

# Fit model given data.
coeffs, linear_response, is_converged, num_iter = tfp.glm.fit(
    model_matrix=features[:, tf.newaxis],
    response=tf.cast(labels,tf.float32),
    model=model)

print(coeffs, linear_response, is_converged, num_iter)
