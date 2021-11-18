#coding https://mattmazur.com/2015/03/17/a-step-by-step-backpropagation-example/ with numpy, checking with iterative version at  https://github.com/animesh/ann/blob/master/ann/Program.cs with following output
#Iteration = 1   Error = 0.298371108760003       Outputs = 0.751365069552316     0.772928465321463
#Iteration = 2   Error = 0.291027773693599       Outputs = 0.742088111190782     0.775284968294459  ...

inp=[0.05,0.10]
inpw=[[0.15,0.20],[0.25,0.3]]
hidw=[[0.4,0.45],[0.5,0.55]]
outputr=[0.01,0.99]
bias=[0.35,0.6]
lr=0.5

import numpy as np
x=np.asarray(inp)
y=np.asarray(outputr)
#b=np.asarray(bias) # precision issues with unrounding? so using bias array as is ...
w1=np.asarray(inpw)
w2=np.asarray(hidw)
print(x,y,bias,w1,w2)

h=1/(1+np.exp(-(x.dot(w1.T)+bias[0])))
y_pred=1/(1+np.exp(-(h.dot(w2.T)+bias[1])))
print(0.5*np.square(y_pred - y).sum())
#0.298371108760003

w3=w2-lr*np.outer((y_pred - y)*(1-y_pred)*y_pred,h)
print(w3)
#  Weight: 0.35891647971788465
#  Weight: 0.4086661860762334
#  Bias: 0.6
#  Weight: 0.5113012702387375
#  Weight: 0.5613701211079891
#inpw0.149780716132763,delin0.0363503063931447,hidden0.593269992107187,input0.05,diff0.000219283867237173
#inpw0.24975114363237,delin0.0413703226487447,hidden0.596884378259767,input0.05,diff0.00024885636763043
#inpw0.199561432265526,delin0.0363503063931447,hidden0.593269992107187,input0.1,diff0.000438567734474347
#inpw0.299502287264739,delin0.0413703226487447,hidden0.596884378259767,input0.1,diff0.00049771273526086

w4=w1-lr*np.outer(w2.T.dot((y_pred - y)*(1-y_pred)*y_pred)*h*(1-h),x)
print(w4)
#  Weight: 0.1497807161327628
#  Weight: 0.19956143226552567
#  Bias: 0.35
#  Weight: 0.24975114363236958
#  Weight: 0.29950228726473915

h1=1/(1+np.exp(-(x.dot(w4.T)+bias[0])))
y_pred_h1=1/(1+np.exp(-(h1.dot(w3.T)+bias[1])))
print(0.5*np.square(y_pred_h1 - y).sum())
#0.291027773693599

#https://github.com/google/jax#installation
from jax import grad
import jax.numpy as jnp
def tanh(x):  # Define a function
  y = jnp.exp(-2.0 * x)
  return (1.0 - y) / (1.0 + y)
grad_tanh = grad(tanh)  # Obtain its gradient function
print(grad_tanh(1.0))   # Evaluate it at x = 1.0
# prints 0.4199743
#https://jax.readthedocs.io/en/latest/developer.html#additional-notes-for-building-jaxlib-from-source-on-windows

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
import os
os.environ['KMP_DUPLICATE_LIB_OK']='True'
import torch                  # it's 'PyTorch' but the package is 'torch'
torch.cuda.is_available()
torch.cuda.current_device()
print(torch.cuda.get_device_name(torch.cuda.current_device()))
device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")
print(device)
print('Allocated:', round(torch.cuda.memory_allocated(0)/1024**3,1), 'GB')
print('Cached:   ', round(torch.cuda.memory_reserved(0)/1024**3,1), 'GB')
torch.manual_seed(1)  # for reproducibility
# training data
import numpy as np
X = np.array([inp],dtype=np.float32)
Y = np.array([outputr],dtype=np.float32).T
# re-cast data as PyTorch variables, on the device (CPU or GPU) were calc's are performed
print(X.shape,Y.shape)
x, y = torch.tensor(X).to(device), torch.tensor(Y).to(device)
# ispecify model (similar to Keras but not quite)
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
  loss = loss_fn(y_tilde, y.T)             # compute the loss
  loss_hist_pytorch.append(loss.item())  # save loss for plotting later
  loss.backward()                        # compute gradients via backprop
  optimizer.step()                       # actually update the weights
# print and plot our results
print("\nY_tilde = \n", y_tilde.cpu().data.numpy() )
import matplotlib.pyplot as plt
plt.xlabel("Iteration")
plt.ylabel("Loss")
plt.loglog(loss_hist_pytorch)
#https://github.com/PyTorchLightning/pytorch-lightning
import os
import torch
from torch import nn
import torch.nn.functional as F
from torchvision.datasets import MNIST
from torch.utils.data import DataLoader, random_split
from torchvision import transforms
import pytorch_lightning as pl
class LitAutoEncoder(pl.LightningModule):
    def __init__(self):
        super().__init__()
        self.encoder = nn.Sequential(nn.Linear(28 * 28, 128), nn.ReLU(), nn.Linear(128, 3))
        self.decoder = nn.Sequential(nn.Linear(3, 128), nn.ReLU(), nn.Linear(128, 28 * 28))
    def forward(self, x):
        # in lightning, forward defines the prediction/inference actions
        embedding = self.encoder(x)
        return embedding
    def training_step(self, batch, batch_idx):
        # training_step defined the train loop. It is independent of forward
        x, y = batch
        x = x.view(x.size(0), -1)
        z = self.encoder(x)
        x_hat = self.decoder(z)
        loss = F.mse_loss(x_hat, x)
        self.log('train_loss', loss)
        return loss
    def configure_optimizers(self):
        optimizer = torch.optim.Adam(self.parameters(), lr=1e-3)
        return optimizer
dataset = MNIST(os.getcwd(), download=True, transform=transforms.ToTensor())
train, val = random_split(dataset, [55000, 5000])
autoencoder = LitAutoEncoder()
trainer = pl.Trainer(gpus=1)
trainer.fit(autoencoder, DataLoader(train), DataLoader(val))

