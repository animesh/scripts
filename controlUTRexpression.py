from pathlib import Path
home = Path.home()
[x for x in home.iterdir()]

inpD = '1d/UTR'
[x for x in (home/inpD).iterdir()]
inpF=home/inpD/"Random_UTRs.csv"
import modin.pandas as pd
#data = pd.read_csv("posw.csv")
data = pd.read_csv(str(inpF))
data.head()


# In[166]:


get_ipython().run_line_magic('matplotlib', 'inline')
import matplotlib.pyplot as plt
import numpy as np
data['RFPlog']=np.log2(data['RFP'])
data.hist()


# In[168]:


from functools import reduce
DNAortho = ('A','1000') , ('T','0100') ,  ('G','0010'), ('C','0001')
data['DNASeqOrtho']=reduce(lambda a, kv: a.str.replace(*kv), DNAortho, data['DNASeq'])
data['DNASeqOrtho']


# In[223]:


X=Variable(torch.Tensor(data['DNASeqOrtho'].apply(lambda x: float(x.find('10'))).reshape(-1,1))).cuda()
y=Variable(torch.Tensor(data['RFPlog'].reshape(-1,1))).cuda()
X, y
#int(data['DNASeqOrtho'].sum(),2)
#data['DNASeqOrtho'].apply(lambda x: x.find('1'))


# In[202]:


class LinearRegressionModel(nn.Module):
    def __init__(self, input_dim, output_dim):
        super(LinearRegressionModel, self).__init__()
        self.linear = nn.Linear(input_dim, output_dim,bias=True).cuda()
    def forward(self, x):
        out = self.linear(x)
        return out


# In[205]:


input_dim = 1
output_dim = 1
l_rate = 0.01
model = LinearRegressionModel(input_dim,output_dim)
criterion = nn.MSELoss()
optimiser = torch.optim.SGD(model.parameters(), lr = l_rate)


# In[224]:


epochs = 100
for epoch in range(epochs):
    epoch +=1
    optimiser.zero_grad()
    outputs = model.forward(X)
    loss = criterion(outputs, y)
    loss.backward()# back props
    optimiser.step()# update the parameters
    print('epoch {}, loss {}'.format(epoch,loss.data[0]))


# In[225]:


predicted =model.forward(X).cpu().data.numpy()
#plt.plot(X, y, 'i', label = 'from data', alpha = .5)
plt.plot(y.cpu().data.numpy(), predicted, label = 'prediction', alpha = 0.5)
plt.legend()
plt.show()
print(model.state_dict())


# In[21]:


#http://pytorch.org/tutorials/beginner/blitz/data_parallel_tutorial.html#sphx-glr-beginner-blitz-data-parallel-tutorial-py
import torch.nn as nn
from torch.autograd import Variable
from torch.utils.data import Dataset, DataLoader
input_size = 5
output_size = 2
batch_size = 30
data_size = 100


# In[22]:


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


# In[23]:


class Model(nn.Module):
    # Our model

    def __init__(self, input_size, output_size):
        super(Model, self).__init__()
        self.fc = nn.Linear(input_size, output_size)

    def forward(self, input):
        output = self.fc(input)
        print("  In Model: input size", input.size(),
              "output size", output.size())
        return output


# In[24]:


model = Model(input_size, output_size)
if torch.cuda.device_count() > 1:
  print("Let's use", torch.cuda.device_count(), "GPUs!")
  # dim = 0 [30, xxx] -> [10, ...], [10, ...], [10, ...] on 3 GPUs
  model = nn.DataParallel(model)

if torch.cuda.is_available():
   model.cuda()


# In[25]:


for data in rand_loader:
    if torch.cuda.is_available():
        input_var = Variable(data.cuda())
    else:
        input_var = Variable(data)

    output = model(input_var)
    print("Outside: input size", input_var.size(),
          "output_size", output.size())


# In[9]:


#https://www.youtube.com/watch?time_continue=96&v=vMZ7tK-RYYc
import numpy as np
import time

from numba import vectorize, cuda

#@vectorize(['float32(float32,float32)'],target='cuda')
def subVector(ε,σ):
    return ε + σ

Elements=10000
A=np.ones(Elements,dtype=np.float32)
B=np.ones(Elements,dtype=np.float32)
C=subVector(A,B)
ts=time.time()
te=time.time()
print(C,te-ts)


# In[ ]:


import pyro
from pyro.distributions import Normal
from pyro.infer import SVI
from pyro.optim import Adam
