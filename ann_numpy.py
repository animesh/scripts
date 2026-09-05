import numpy as np
import sys

x = np.array([0.1, 0.2])
w1 = np.array([[0.15, 0.20], [0.25, 0.3]])
w2 = np.array([[0.4, 0.45], [0.5, 0.55]])
y = np.array([0.2, 0.1])
bias = np.array([0.35, 0.6])
lr = 0.5

iterations = int(sys.argv[1]) if len(sys.argv) > 1 else 1

for iteration in range(iterations):
    h = 1/(1+np.exp(-(x.dot(w1.T)+bias[0])))
    y_pred = 1/(1+np.exp(-(h.dot(w2.T)+bias[1])))
    
    w2 = w2-lr*np.outer((y_pred - y)*(1-y_pred)*y_pred, h)
    w1 = w1-lr*np.outer(w2.T.dot((y_pred - y)*(1-y_pred)*y_pred)*h*(1-h), x)
    
    error = 0.5*np.square(y_pred - y).sum()
    print(f"Iteration {iteration+1}: Error = {error:.10f}")

print(f"Expected Output:\n{y}")
print(f"Predicted Output:\n{y_pred}")
print(f"Hidden Output:\n{h}")
print(f"W1 Final Output:\n{w1}")
print(f"W2 Final Output:\n{w2}")
