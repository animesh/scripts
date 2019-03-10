#https://matrices.io/deep-neural-network-from-scratch/ using https://www.tensorflow.org/alpha/guide/eager
#!sudo pip3 install tf-nightly-2.0-preview
import tensorflow as tf
print(tf.__version__)
#tf.enable_eager_execution()
tf.executing_eagerly()
tf.test.is_gpu_available()#:with tf.device("/gpu:0"):
tf.keras.backend.clear_session()
inp=[0.05,0.10]
inpw=[[0.15,0.20],[0.25,0.3]]
hidw=[[0.4,0.45],[0.5,0.55]]
outputr=[0.01,0.99]
bias=[0.35,0.6]
lr=0.5

w1 = tf.Variable(inpw, name="W1")
w2 = tf.Variable(hidw, name="W2")
x = tf.constant(inp)
y = tf.constant(outputr)

layer_1 = tf.nn.tanh(tf.add(tf.matmul([x], w1), b1[0]))
layer_2 = tf.nn.tanh(tf.add(tf.matmul(layer_1, w2), b1[1]))

@tf.custom_gradient
def log1pexp(x):
  e = tf.exp(x)
  def grad(dy):
    return dy * (1 - 1 / (1 + e))
  return tf.math.log(1 + e), grad
def grad_log1pexp(x):
  with tf.GradientTape() as tape:
    tape.watch(x)
    value = log1pexp(x)
  return tape.gradient(value, x)


grad_log1pexp(tf.constant(100.))#.numpy()

regularization = tf.nn.l2_loss(w1) + tf.nn.l2_loss(w2)
loss = tf.reduce_mean(tf.square(layer_2 - y))
learning_rate = lr


with tf.Session() as session:
    session.run(init)
    for i in range(5000):
        session.run(train_op)

model = tf.keras.models.Sequential([
  tf.keras.layers.Flatten(input_shape=(2,1)),
  tf.keras.layers.Dense(2, activation='relu'),
  tf.keras.layers.Dense(2, activation='softmax')
])

model.compile(optimizer='adam',
              loss='sparse_categorical_crossentropy',
              metrics=['accuracy'])

model.fit([x], y, epochs=1,steps_per_epoch=1)
model.evaluate(x, y)


#https://www.tensorflow.org/alpha/guide/autograph
@tf.function
def simple_nn_layer(x, y):
  return tf.nn.relu(tf.matmul(x, y))


x = tf.random.uniform((3, 3))
y = tf.random.uniform((3, 3))

simple_nn_layer(x, y)

def square_if_positive_vectorized(x):
  return tf.where(x > 0, x ** 2, x)

square_if_positive_vectorized(tf.range(-5, 5))

from tensorflow.keras import layers
original_dim = 784
intermediate_dim = 64
latent_dim = 32

class Sampling(layers.Layer):
  """Uses (z_mean, z_log_var) to sample z, the vector encoding a digit."""

  def call(self, inputs):
    z_mean, z_log_var = inputs
    batch = tf.shape(z_mean)[0]
    dim = tf.shape(z_mean)[1]
    epsilon = tf.keras.backend.random_normal(shape=(batch, dim))
    return z_mean + tf.exp(0.5 * z_log_var) * epsilon
# Define encoder model.
original_inputs = tf.keras.Input(shape=(original_dim,), name='encoder_input')
x = layers.Dense(intermediate_dim, activation='relu')(original_inputs)
z_mean = layers.Dense(latent_dim, name='z_mean')(x)
z_log_var = layers.Dense(latent_dim, name='z_log_var')(x)
z = Sampling()((z_mean, z_log_var))
encoder = tf.keras.Model(inputs=original_inputs, outputs=z, name='encoder')

# Define decoder model.
latent_inputs = tf.keras.Input(shape=(latent_dim,), name='z_sampling')
x = layers.Dense(intermediate_dim, activation='relu')(latent_inputs)
outputs = layers.Dense(original_dim, activation='sigmoid')(x)
decoder = tf.keras.Model(inputs=latent_inputs, outputs=outputs, name='decoder')

# Define VAE model.
outputs = decoder(z)
vae = tf.keras.Model(inputs=original_inputs, outputs=outputs, name='vae')

# Add KL divergence regularization loss.
kl_loss = - 0.5 * tf.reduce_sum(
    z_log_var - tf.square(z_mean) - tf.exp(z_log_var) + 1)
vae.add_loss(kl_loss)

# Train.
optimizer = tf.keras.optimizers.Adam(learning_rate=1e-3)
vae.compile(optimizer, loss=tf.keras.losses.MeanSquaredError())
(x_train, _), _ = tf.keras.datasets.mnist.load_data()
x_train = x_train.reshape(60000, 784).astype('float32') / 255
vae.fit(x_train, x_train, epochs=3, batch_size=64)


#https://www.tensorflow.org/tensorboard/r2/get_started
import datetime
current_time = datetime.datetime.now().strftime("%Y%m%d-%H%M%S")
train_log_dir = 'logs/gradient_tape/' + current_time + '/train'
test_log_dir = 'logs/gradient_tape/' + current_time + '/test'
train_summary_writer = tf.summary.create_file_writer(train_log_dir)
test_summary_writer = tf.summary.create_file_writer(test_log_dir)
tf.summary
python -m tensorflow.tensorboard
%tensorboard --logdir logs/gradient_tape
  train_loss.reset_states()
  test_loss.reset_states()
  train_accuracy.reset_states()
  test_accuracy.reset_states()


#!python3 -m tensorflow.tensorboard  --logdir logs/gradient_tape
