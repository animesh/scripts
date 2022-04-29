#coding https://mattmazur.com/2015/03/17/a-step-by-step-backpropagation-example/ with pytorch, checking with iterative version at  https://github.com/animesh/ann/blob/master/ann/Program.cs with following output
#Iteration = 1   Error = 0.298371108760003       Outputs = 0.751365069552316     0.772928465321463
#Iteration = 2   Error = 0.291027773693599       Outputs = 0.742088111190782     0.775284968294459  ...
#https://youtu.be/FHdlXe1bSe4?t=319
inp=[0.05,0.10]
inpw=[[0.15,0.20],[0.25,0.3]]
hidw=[[0.4,0.45],[0.5,0.55]]
outputr=[0.01,0.99]
bias=[0.35,0.6]
lr=0.5
import torch
#torch.cuda.set_device(0)
import torch.nn as nn
import torch.nn.functional as F
from torch.optim import SGD
class BasicNN(nn.Module):
    def __init__(self):
        super().__init__()
        self.w00 = nn.Parameter(torch.tensor(inpw[0][0]), requires_grad=True)
        self.b00 = nn.Parameter(torch.tensor(-0.85), requires_grad=True)
        self.w01 = nn.Parameter(torch.tensor(-40.8), requires_grad=True)
        self.w10 = nn.Parameter(torch.tensor(12.6), requires_grad=True)
        self.b10 = nn.Parameter(torch.tensor(0.0), requires_grad=True)
        self.w11 = nn.Parameter(torch.tensor(2.7), requires_grad=True)
        self.final_bias = nn.Parameter(torch.tensor(-16.), requires_grad=True)
    def forward(self, input):
        input_to_top_relu = input * self.w00 + self.b00
        top_relu_output = F.relu(input_to_top_relu)
        scaled_top_relu_output = top_relu_output * self.w01
        input_to_bottom_relu = input * self.w10 + self.b10
        bottom_relu_output = F.relu(input_to_bottom_relu)
        scaled_bottom_relu_output = bottom_relu_output * self.w11
        input_to_final_relu = scaled_top_relu_output + scaled_bottom_relu_output + self.final_bias
        output = F.relu(input_to_final_relu)
        return output

model = BasicNN_train() 
output_values = model(input_doses)
inputs = torch.tensor([0., 0.5, 1.])
labels = torch.tensor([0., 1., 0.])
model = BasicNN_train()

optimizer = SGD(model.parameters(), lr=lr)
print("Final bias, before optimization: " + str(model.final_bias.data) + "\n")
for epoch in range(100):
    total_loss = 0
    for iteration in range(len(inputs)):
        input_i = inputs[iteration]
        label_i = labels[iteration]
        output_i = model(input_i)
        loss = (output_i - label_i)**2
        loss.backward()
        total_loss += float(loss)
    if (total_loss < 0.0001):
        print("Num steps: " + str(epoch))
        break
    optimizer.step()
    optimizer.zero_grad()
    print("Step: " + str(epoch) + " Final Bias: " + str(model.final_bias.data) + "\n")
print("Total loss: " + str(total_loss))
print("Final bias, after optimization: " + str(model.final_bias.data))
x=torch.tensor(inp, dtype=torch.float64)
y=torch.tensor([outputr], dtype=torch.float64)
b=torch.tensor(bias, dtype=torch.float64)
w1=torch.tensor(inpw, dtype=torch.float64)
w2=torch.tensor(hidw, dtype=torch.float64)
print(x,y,b,w1,w2)
#print(torch.tensor(inpw).transpose(0,1),torch.tensor(hidw).transpose(0,1))
#x.matmul(y.transpose(0,1))
x.reshape(-1, 1) - y

iter=0
while iter<2:
    iter+=1
    h = torch.sigmoid(x.matmul(w1.transpose(0,1))+b[0])
    y_pred = torch.sigmoid(h.matmul(w2.transpose(0,1))+b[1])
    print("iteration:",iter,"MSE: ",0.5*(((y_pred - y).pow(2)).sum()))
    grad=(y_pred - y)*(1-y_pred)*y_pred # numerically unstable?
    w1-=lr*w2.matmul(grad.reshape(-1, 1))*h*(1-h).reshape(-1, 1).matmul(x) # though it seems like descent is faster if first layer done in end? #FILO
    print(w1)
    #w2-=lr*np.outer(grad,h)
    print(w2)


def init_weights(m):
    if type(m) == torch.nn.Linear:
        torch.nn.init.xavier_uniform_(m.weight)
        m.bias.data.fill_(0.01)

net = torch.nn.Sequential(torch.nn.Linear(2, 2), torch.nn.Linear(2, 2))
net.apply(init_weights)

class Net(torch.nn.Module):
    def __init__(self, n_feature, n_hidden, n_output):
        super(Net, self).__init__()
        self.hidden = torch.nn.Linear(n_feature, n_hidden)
        self.predict = torch.nn.Linear(n_hidden, n_output)
    def forward(self, x):
        x = torch.sigmoid(self.hidden(x))
        x = self.predict(x)
        return x

#print(x.view)
#net = Net(n_feature=1, n_hidden=10, n_output=1)
net=Net(outputc,outputc,outputc)
print(net)  # net architecture

optimizer = torch.optim.SGD(net.parameters(), lr)
loss_func = torch.nn.MSELoss()

prediction = net(x)
loss = loss_func(prediction, y)
optimizer.zero_grad()
loss.backward()
optimizer.step()
print(x.data.numpy(), y.data.numpy())
print(x.data.numpy(), prediction.data.numpy())
print(loss.data.numpy())

w3p=[[0.35891647971788465, 0.5113012702387375],
       [0.4086661860762334, 0.5613701211079891]]
print(w3p-w3)

N=22
scale=10
D_in, H, D_out = N*scale*scale, N*scale*scale, N*scale

class DynamicNet(torch.nn.Module):
    def __init__(self, D_in, H, D_out):
        super(DynamicNet, self).__init__()
        self.input_linear = torch.nn.Linear(D_in, H)
        self.middle_linear = torch.nn.Linear(H, H)
        self.output_linear = torch.nn.Linear(H, D_out)
    def forward(self, x):
        h_relu = self.input_linear(x).clamp(min=0)
        for _ in range(random.randint(0, int(N/scale))):
            h_relu = self.middle_linear(h_relu).clamp(min=0)
        y_pred = self.output_linear(h_relu)
        return y_pred

x = torch.randn(N, D_in)
y = torch.randn(N, D_out)

model = DynamicNet(D_in, H, D_out)

criterion = torch.nn.MSELoss(reduction='sum')
optimizer = torch.optim.SGD(model.parameters(), lr=1e-4, momentum=0.9)
