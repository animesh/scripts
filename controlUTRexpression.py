from pathlib import Path
home = Path.home()
[x for x in home.iterdir()]

inpD = '1d/UTR'
[x for x in (home/inpD).iterdir()]
inpF=home/inpD/"data2.csv"
import pandas as pd
#import modin.pandas as pd
data = pd.read_csv(str(inpF))
data.head()
data.describe()

import matplotlib.pyplot as plt
import numpy as np
data['RFPlog']=np.log2(data['Fluorescence'])
data['RFPlog'].hist()

data['ReadsLog']=np.log2(data['#Reads Col'])
data['ReadsLog'].hist()
plt.scatter(data['RFPlog'],data['ReadsLog'])

from functools import reduce
DNAortho = ('A','1000') , ('T','0100') ,  ('G','0010'), ('C','0001')
data['DNASeqOrtho']=reduce(lambda a, kv: a.str.replace(*kv), DNAortho, data['Sequence'])
print(data['DNASeqOrtho'])

sorted_inds = data.sort_values('Sequence').index.values
train_inds = sorted_inds[:int(0.75*len(sorted_inds))]
test_inds = sorted_inds[int(0.75*len(sorted_inds)):]
val_idx = int(0.75*len(train_inds))
val_inds = train_inds[val_idx:]
train_inds = train_inds[:val_idx]
print(len(train_inds))

from torch.utils.data import Dataset, DataLoader
from torch.autograd import Variable
class DNADataset(Dataset):
    def __init__(self, data, seq_len):
        self.data = data
        self.bases = ['A','C','G','T']
        self.base_dict = dict(zip(self.bases,range(4))) # {'A' : 0, 'C' : 1, 'G' : 2, 'T' : 3}
        self.total_width = seq_len + 20
    def __len__(self):
        return (self.data.shape[0])
    def __getitem__(self, idx):
        seq = self.data.iloc[idx].UTR
        X = np.zeros((1, 4, self.total_width))
        y = self.data.iloc[idx].growth_rate
        for b in range(len(seq)):
            X[0, self.base_dict[seq[b]], int(b + round((self.total_width - len(seq))/2.))] = 1.
        return(seq, X, y)

import torch.nn as nn
import torch.nn.functional as F
import torch.optim as optim
import random
class Net(nn.Module):
    def __init__(self):
        super(Net, self).__init__()
        self.conv1 = nn.Conv2d(in_channels=1, out_channels=128, kernel_size=(4, 13))
        self.dropout = nn.Dropout(p=0.15)
        self.conv2 = nn.Conv2d(128, 128, (1,13))
        self.fc1 = nn.Linear(128 * 1 * 34, 64)
        self.fc2 = nn.Linear(64, 1)
    def forward(self, x):
        x = F.relu(self.conv1(x))
        x = self.dropout(x)
        x = F.relu(self.conv2(x))
        x = self.dropout(x)
        x = F.relu(self.conv2(x))
        x = self.dropout(x)
        x = x.view(-1, 128 * 1 * 34)
        x = F.relu(self.fc1(x))
        x = self.fc2(x)
        return x

net = Net()
#net = net.cuda()

criterion = nn.MSELoss()
optimizer = optim.Adam(net.parameters())

train_data = DNADataset(data.iloc[train_inds], seq_len=50)
val_data = DNADataset(data.iloc[val_inds], seq_len=50)
test_data = DNADataset(data.iloc[test_inds], seq_len=50)
train_data_loader = DataLoader(train_data, batch_size=32,shuffle=True, num_workers=4)

val_data_loader = DataLoader(val_data, batch_size=32) # Validate everything in one batch?!

test_data_loader = DataLoader(test_data, batch_size=len(test_data)) # Validate everything in one batch?!

from tqdm import tqdm_notebook as tqdm
for epoch in range(10):
    for i_batch, sampled_batch in enumerate(tqdm(train_data_loader)):
        DNASeqOrtho, RFPlog,ReadsLog = sampled_batch
        inputs, labels = Variable(transformed_sequence.float()), Variable(growth_rate.float())
        optimizer.zero_grad()
        net.train()
        outputs = net(inputs)
        loss = criterion(outputs, labels)
        loss.backward()
        optimizer.step()
    error = 0
    totalE = 0
    net.eval()
    for batch in tqdm(val_data_loader):
      v_seq, X_v, y_v = batch
      v_pred = net(Variable(X_v.float()))#.cuda()))
      totalE = totalE + y_v.size(0)
      raw_error = v_pred[:,0].data - y_v.float()#.cuda()
      error += (raw_error**2).sum()
      avg_mse = error / float(totalE)

import time
torch.save(net, 'saved_model'+str(time.time()))

error = 0
total = 0
for batch in tqdm(val_data_loader):
                v_seq, X_v, y_v = batch
                v_pred = net(Variable(X_v.float()))#.cuda()))
                total += y_v.size(0)
                raw_error = v_pred[:,0].data - y_v.float()#.cuda()
                error += (raw_error**2).sum()

avg_mse = error / float(total)
print("Validation error: {}".format(avg_mse))

error = 0
total = 0
for batch in tqdm(test_data_loader):
                v_seq, X_v, y_v = batch
                v_pred = net(Variable(X_v.float()))#.cuda()))
                total += y_v.size(0)
                raw_error = v_pred[:,0].data - y_v.float()#.cuda()
                error += (raw_error**2).sum()

avg_mse = error / float(total)
print("Test error: {}".format(avg_mse))


import torch
X=list(data['DNASeqOrtho'].str)
y=torch.Tensor(data['RFPlog'])

class LinearRegressionModel(nn.Module):
    def __init__(self, input_dim, output_dim):
        super(LinearRegressionModel, self).__init__()
        self.linear = nn.Linear(input_dim, output_dim,bias=True).cuda()
    def forward(self, x):
        out = self.linear(x)
        return out

input_dim = 1
output_dim = 1
l_rate = 0.01
model = LinearRegressionModel(input_dim,output_dim)
criterion = nn.MSELoss()
optimiser = torch.optim.SGD(model.parameters(), lr = l_rate)


epochs = 100
for epoch in range(epochs):
    epoch +=1
    optimiser.zero_grad()
    outputs = model.forward(X)
    loss = criterion(outputs, y)
    loss.backward()# back props
    optimiser.step()# update the parameters
    print('epoch {}, loss {}'.format(epoch,loss.data[0]))

predicted =model.forward(X).cpu().data.numpy()
#plt.plot(X, y, 'i', label = 'from data', alpha = .5)
plt.plot(y.cpu().data.numpy(), predicted, label = 'prediction', alpha = 0.5)
plt.legend()
plt.show()
print(model.state_dict())

#http://pytorch.org/tutorials/beginner/blitz/data_parallel_tutorial.html#sphx-glr-beginner-blitz-data-parallel-tutorial-py
import torch.nn as nn
from torch.autograd import Variable
from torch.utils.data import Dataset, DataLoader
input_size = 5
output_size = 2
batch_size = 30
data_size = 100

class RandomDataset(Dataset):
    def __init__(self, size, length):
        self.len = length
        self.data = torch.randn(length, size)
    def __getitem__(self, index):
        return self.data[index]
    def __len__(self):
        return self.len

rand_loader = DataLoader(dataset=RandomDataset(input_size, 100),
                         batch_size=batch_size, shuffle=True)

class Model(nn.Module):
    def __init__(self, input_size, output_size):
        super(Model, self).__init__()
        self.fc = nn.Linear(input_size, output_size)
    def forward(self, input):
        output = self.fc(input)
        print("  In Model: input size", input.size(),
              "output size", output.size())
        return output

model = Model(input_size, output_size)

if torch.cuda.device_count() > 1:
  print("Let's use", torch.cuda.device_count(), "GPUs!")
  # dim = 0 [30, xxx] -> [10, ...], [10, ...], [10, ...] on 3 GPUs
  model = nn.DataParallel(model)

if torch.cuda.is_available():
   model.cuda()


for data in rand_loader:
    if torch.cuda.is_available():
        input_var = Variable(data.cuda())
    else:
        input_var = Variable(data)

    output = model(input_var)
    print("Outside: input size", input_var.size(),
          "output_size", output.size())
