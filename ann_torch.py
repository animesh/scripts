#coding https://mattmazur.com/2015/03/17/a-step-by-step-backpropagation-example/ with pytorch, checking with iterative version at  https://github.com/animesh/ann/blob/master/ann/Program.cs with following output
#Iteration = 1   Error = 0.298371108760003       Outputs = 0.751365069552316     0.772928465321463
#Iteration = 2   Error = 0.291027773693599       Outputs = 0.742088111190782     0.775284968294459  ...
inp=[0.05,0.10]
#inpw=[[0.15,0.20],[0.25,0.3]]
#hidw=[[0.4,0.45],[0.5,0.55]]
outputr=[0.01,0.99]
#bias=[0.35,0.6]
lr=0.5
#https://drscotthawley.github.io/devblog3/2019/02/08/My-1st-NN-Part-3-Multi-Layer-and-Backprop.html
import torch                  # it's 'PyTorch' but the package is 'torch'
device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")
print(device)
torch.manual_seed(1)  # for reproducibility
# training data
import numpy as np
X = np.array([inp],dtype=np.float32)
Y = np.array([outputr],dtype=np.float32).T
# re-cast data as PyTorch variables, on the device (CPU or GPU) were calc's are performed
print(X.shape,Y.shape)
x, y = torch.tensor(X).to(device), torch.tensor(Y).to(device)
# specify model (similar to Keras but not quite)
n_hidden = 2                           # number of hidden neurons
model = torch.nn.Sequential(
          torch.nn.Linear(X.shape[1], n_hidden),
          torch.nn.ReLU(),
          torch.nn.Linear(n_hidden, Y.shape[0]),
          torch.nn.Sigmoid()
        ).to(device)
# choices for loss and optimization method
loss_fn = torch.nn.BCELoss()      # binary cross-entropy loss
optimizer = torch.optim.Adam([{'params': model.parameters()}], lr=lr)
# training iterations
loss_hist_pytorch = []
maxiter=5000
for iter in range(maxiter):
  optimizer.zero_grad()                  # set gradients=0 before calculating more
  y_tilde = model(x)                     # feed-forward step
  loss = loss_fn(y_tilde, y)             # compute the loss
  loss_hist_pytorch.append(loss.item())  # save loss for plotting later
  loss.backward()                        # compute gradients via backprop
  optimizer.step()                       # actually update the weights
# print and plot our results
print("\nY_tilde = \n", y_tilde.cpu().data.numpy() )
import matplotlib.pyplot as plt
plt.xlabel("Iteration")
plt.ylabel("Loss")
plt.loglog(loss_hist_pytorch)
