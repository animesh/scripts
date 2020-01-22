#Example: Masked Autoregressive Flow
#https://arxiv.org/abs/1705.07057
#https://medium.com/tensorflow/introducing-tensorflow-probability-dca4c304e245
#https://github.com/tensorflow/probability/blob/master/tensorflow_probability/examples/jupyter_notebooks/A_Tour_of_TensorFlow_Probability.ipynb
#https://www.analyticsvidhya.com/blog/2019/10/mathematics-behind-machine-learning/
#pip3 install tensorflow==2.0.0-beta1 #for windows
#pip3 instapip3 install tf-nightly-2.0-preview --user #2.0.0-dev20190819
#pip3 install tfp-nightly --user
import tensorflow as tf
print(tf.__version__)
import tensorflow_probability as tfp
print(tfp.__version__)

mats = tf.random.uniform(shape=[1000, 10, 10])
vecs = tf.random.uniform(shape=[1000, 10, 1])
vecs.shape


import numpy as np
def for_loop_solve():
  return np.array(
    [tf.linalg.solve(mats[i, ...], vecs[i, ...]) for i in range(1000)])

def vectorized_solve():
  return tf.linalg.solve(mats, vecs)

for_loop_solve()
print(vectorized_solve())

a = tf.constant(np.pi)
b = tf.constant(np.e)
with tf.GradientTape() as tape:
  tape.watch([a, b])
  c = .5 * (a**2 + b**2)
grads = tape.gradient(c, [a, b])
print(grads[0])
print(grads[1])

tfd = tfp.distributions
normal = tfd.Normal(loc=0., scale=1.)
print(normal.log_prob(0.))

#pip3 install pandas==0.24 --user
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
