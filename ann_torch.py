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
