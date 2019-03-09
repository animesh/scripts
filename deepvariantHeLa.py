import tensorflow as tf
#starting tf with https://mattmazur.com/2015/03/17/a-step-by-step-backpropagation-example, checking with iterative version at  https://github.com/animesh/ann/blob/master/ann/Program.cs with following inp/output
inp=[0.05,0.10]
inpw=[[0.15,0.20],[0.25,0.3]]
hidw=[[0.4,0.45],[0.5,0.55]]
outputr=[0.01,0.99]
bias=[0.35,0.6]
lr=0.5


x = tf.placeholder("float", name="x")
y = tf.placeholder("float", name="y")
w1 = tf.Variable(inpw, name="W1")
w2 = tf.Variable(hidw, name="W2")
x_data=inp
y_data=outputr

b1 = tf.Variable(bias[0], name="b1")
b2 = tf.Variable(bias[1], name="b2")

layer_1 = tf.nn.tanh(tf.add(tf.matmul(x, w1), b1))
layer_2 = tf.nn.tanh(tf.add(tf.matmul(layer_1, w2), b2))

Lambda = 1
learning_rate = lr

regularization = tf.nn.l2_loss(w1) + tf.nn.l2_loss(w2)
loss = tf.reduce_mean(tf.square(layer_2 - y)) + Lambda * regularization
train_op = tf.train.GradientDescentOptimizer(learning_rate).minimize(loss)

init = tf.global_variables_initializer()

with tf.Session() as session:
    session.run(init)
    for i in range(1):
        session.run(train_op, feed_dict={x: x_data, y: y_data})
