#coding https://mattmazur.com/2015/03/17/a-step-by-step-backpropagation-example/ with pytorch, checking with iterative version at  https://github.com/animesh/ann/blob/master/ann/Program.cs with following output
#Iteration = 1   Error = 0.298371108760003       Outputs = 0.751365069552316     0.772928465321463
#Iteration = 2   Error = 0.291027773693599       Outputs = 0.742088111190782     0.775284968294459  ...

inp=[0.05,0.10]
inpw=[[0.15,0.20],[0.25,0.3]]
hidw=[[0.4,0.45],[0.5,0.55]]
outputr=[0.01,0.99]
bias=[0.35,0.6]
lr=0.5

import torch
Device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")
print(device)
x=torch.tensor(inp, dtype=torch.double, device=Device)
y=torch.tensor(outputr, dtype=torch.double, device=Device)
b=torch.tensor(bias, dtype=torch.double, device=Device)
w1=torch.tensor(inpw, dtype=torch.double, device=Device)
w2=torch.tensor(hidw, dtype=torch.double, device=Device)
print(x.size(),y,b,w1.size(),w2)
iter=0
while iter<1:
    iter+=1
    h = torch.sigmoid(x.matmul(w1.transpose(0,1))+b[0])
    y_pred = torch.sigmoid(h.matmul(w2.transpose(0,1))+b[1])
    print("iteration:",iter,"MSE: ",0.5*(((y_pred - y).pow(2)).sum()))
    print(w1)
    print(w2)

#https://medium.com/dair-ai/a-simple-neural-network-from-scratch-with-pytorch-and-google-colab-c7f3830618e0
class Neural_Network(torch.nn.Module):
    def __init__(self, ):
        super(Neural_Network, self).__init__()
        self.W1 = w1.transpose(0,1) # 3 x 2 tensor
        self.W2 = w2.transpose(0,1)
    def forward(self, x):
        self.z = torch.matmul(x, self.W1) # 3 x 3 ".dot" does not broadcast in PyTorch
        self.z2 = self.sigmoid(self.z) # activation function
        self.z3 = torch.matmul(self.z2, self.W2)
        o = self.sigmoid(self.z3) # final activation function
        return o
    def sigmoid(self, s):
        return 1 / (1 + torch.exp(-s))
    def sigmoidPrime(self, s):
        return s * (1 - s)
    def backward(self, x, y, o):
        self.o_error = y - o # error in output
        self.o_delta = self.o_error * self.sigmoidPrime(o) # derivative of sig to error
        self.z2_error = torch.matmul(self.o_delta, torch.t(self.W2))
        self.z2_delta = self.z2_error * self.sigmoidPrime(self.z2)
        self.W1 += torch.matmul(x, self.z2_delta.transpose(0,1)) #torch.sigmoid(x.matmul(w1.transpose(0,1))+b[0])
        self.W2 += torch.matmul(self.z2, self.o_delta)
    def train(self, x, y):
        o = self.forward(x)
        self.backward(x, y, o)
    def saveWeights(self, model):
        torch.save(model, "NN")
    def predict(self):
        print ("Predicted weights: ")
        print ("Input (scaled): \n" + str(xPredicted))
        print ("Output: \n" + str(self.forward(xPredicted)))

NN = Neural_Network()
for i in range(1000):  # trains the NN 1,000 times
    print ("#" + str(i) + " Loss: " + str(torch.mean((y - NN(x))**2).detach().item()))  # mean sum squared loss
    NN.train(x, y)
NN.saveWeights(NN)
NN.predict()
