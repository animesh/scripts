#https://matrices.io/deep-neural-network-from-scratch/

import tensorflow as tf
x = tf.placeholder("float", name="cars")
y = tf.placeholder("float", name="prices")
x_data=([0.05,1.00])
y_data=([0.99,0.01])
w1 = tf.Variable(tf.random_normal([3, 3]), name="W1")
w2 = tf.Variable(tf.random_normal([3, 2]), name="W2")
w3 = tf.Variable(tf.random_normal([2, 1]), name="W3")

b1 = tf.Variable(tf.random_normal([1, 3]), name="b1")
b2 = tf.Variable(tf.random_normal([1, 2]), name="b2")
b3 = tf.Variable(tf.random_normal([1, 1]), name="b3")

layer_1 = tf.nn.tanh(tf.add(tf.matmul(x, w1), b1))
layer_2 = tf.nn.tanh(tf.add(tf.matmul(layer_1, w2), b2))
layer_3 = tf.nn.tanh(tf.add(tf.matmul(layer_2, w3),  b3))

regularization = tf.nn.l2_loss(w1) + tf.nn.l2_loss(w2) + tf.nn.l2_loss(w3)
Lambda = 0.01
loss = tf.reduce_mean(tf.square(layer_3 - y)) + Lambda * regularization
learning_rate = 0.01
train_op = tf.train.GradientDescentOptimizer(learning_rate).minimize(loss)

# launching the previously defined model begins here
init = tf.global_variables_initializer()

with tf.Session() as session:
    session.run(init)
    for i in range(5000):
        session.run(train_op, feed_dict={x: x_data, y: y_data})
