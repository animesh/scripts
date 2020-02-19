#https://blog.tensorflow.org/2020/01/hyperparameter-tuning-with-keras-tuner.html
import kerastuner as kt


from sklearn import ensemble
from sklearn import linear_model

def build_model(hp):
    model_type = hp.Choice('model_type', ['random_forest', 'ridge'])
    if model_type == 'random_forest':
        with hp.conditional_scope('model_type', 'random_forest'):
            model = ensemble.RandomForestClassifier(
                n_estimators=hp.Int('n_estimators', 10, 50, step=10),
                max_depth=hp.Int('max_depth', 3, 10))
    elif model_type == 'ridge':
        with hp.conditional_scope('model_type', 'ridge'):
            model = linear_model.RidgeClassifier(
                alpha=hp.Float('alpha', 1e-3, 1, sampling='log'))
    else:
        raise ValueError('Unrecognized model_type')
    return model

#https://github.com/keras-team/keras-tuner
tmp_dir="."
tuner = kt.Hyperband(
    build_model,
    objective='val_accuracy',
    max_epochs=30,
    hyperband_iterations=2)
tuner = kt.tuners.Sklearn(
        oracle=kt.oracles.BayesianOptimization(
            objective=kt.Objective('score', 'max'),
            max_trials=10),
        hypermodel=build_model,
        directory=tmp_dir)
X, y = [[1,2,3,4,6],[4,8,12,16,20]]
tuner.search(X+1.0, y+1.0)
tuner.search_space_summary()

#https://matrices.io/deep-neural-network-from-scratch/ using https://www.tensorflow.org/alpha/guide/eager
#pip3 install tensorflow==2.0.0-rc0
#https://youtu.be/5ECD8J3dvDQ?t=455
import tensorflow as tf
print(tf.__version__)
import datetime
print(datetime.datetime.now())

inp=[0.05,0.10]
inpw=[[0.15,0.25],[0.20,0.3]]
hidw=[[0.4,0.5],[0.45,0.55]]
outputr=[0.01,0.99]
bias=[0.35,0.6]
lr=0.5

#https://jaredwinick.github.io/what_is_tf_keras/
w1 = tf.Variable(inpw)
w2 = tf.Variable(hidw)
x = tf.constant(inp)
y = tf.constant(outputr)


layer_1 = 1/(1+tf.exp(-(tf.add(tf.matmul([x], w1), bias[0]))))
layer_2 = 1/(1+tf.exp(-(tf.add(tf.matmul(layer_1, w2), bias[1]))))
print(layer_2)

epochs = 2
for epoch in range(epochs):
    with tf.GradientTape() as t:
        layer_1 = 1/(1+tf.exp(-(tf.add(tf.matmul([x], w1), bias[0]))))
        layer_2 = 1/(1+tf.exp(-(tf.add(tf.matmul(layer_1, w2), bias[1]))))
        loss = y - layer_2
    #dW, dB = t.gradient(loss, [w2, bias[1]])
    print(t.gradient(loss, [w2, bias[1]]))
    #weights.assign_sub(lr * dW)
    #bias.assign_sub(lr * dB)

#https://www.tensorflow.org/tensorboard/scalars_and_keras
import numpy as np
data_size = 1000
# 80% of the data is for training.
train_pct = 0.8

train_size = int(data_size * train_pct)

# Create some input data between -1 and 1 and randomize it.
x = np.linspace(-1, 1, data_size)
np.random.shuffle(x)

# Generate the output data.
# y = 0.5x + 2 + noise
y = 0.5 * x + 2 + np.random.normal(0, 0.05, (data_size, ))

# Split into test and train pairs.
x_train, y_train = x[:train_size], y[:train_size]
x_test, y_test = x[train_size:], y[train_size:]


from datetime import datetime
from tensorflow import keras
logdir = "logs/scalars/" + datetime.now().strftime("%Y%m%d-%H%M%S")
tensorboard_callback = keras.callbacks.TensorBoard(log_dir=logdir)

model = keras.models.Sequential([
    keras.layers.Dense(16, input_dim=1),
    keras.layers.Dense(1),
])

model.compile(
    loss='mse', # keras.losses.mean_squared_error
    optimizer=keras.optimizers.SGD(lr=0.2),
)

print("Training ... With default parameters, this takes less than 10 seconds.")
training_history = model.fit(
    x_train, # input
    y_train, # output
    batch_size=train_size,
    verbose=0, # Suppress chatty output; use Tensorboard instead
    epochs=100,
    validation_data=(x_test, y_test),
    callbacks=[tensorboard_callback],
)

print("Average test loss: ", np.average(training_history.history['loss']))
