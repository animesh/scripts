#coding https://mattmazur.com/2015/03/17/a-step-by-step-backpropagation-example/ with pytorch, checking with iterative version at  https://github.com/animesh/ann/blob/master/ann/Program.cs with following output
#Iteration = 1   Error = 0.298371108760003       Outputs = 0.751365069552316     0.772928465321463
#Iteration = 2   Error = 0.291027773693599       Outputs = 0.742088111190782     0.775284968294459  ...
#https://youtu.be/FHdlXe1bSe4?t=319
input=[0.05,0.10]
inpw=[[0.15,0.20],[0.25,0.3]]
hidw=[[0.4,0.45],[0.5,0.55]]
output=[0.01,0.99]
bias=[0.35,0.6]
lr=0.5
#mamba create -n torch -c nvidia -c pytorch -c conda-forge pytorch torchvision torchaudio cudatoolkit=11.6
import torch
print("PyTorch ",torch.__version__)
from datetime import datetime
startTime = datetime.now()
print("Start time:", startTime)
if torch.cuda.is_available():
    print(torch.cuda.get_device_name(torch.cuda.current_device()))
    print('Allocated:', round(torch.cuda.memory_allocated(0)/1024**3,1), 'GB')
    print('Cached:   ', round(torch.cuda.memory_reserved(0)/1024**3,1), 'GB')
import torch.nn as nn
import torch.nn.functional as F
from torch.optim import SGD
class mANN(nn.Module):
    def __init__(self):
        super().__init__()
        self.iw00 = nn.Parameter(torch.tensor(inpw[0][0]), requires_grad=True)
        self.iw01 = nn.Parameter(torch.tensor(inpw[0][1]), requires_grad=True)
        self.iw10 = nn.Parameter(torch.tensor(inpw[1][0]), requires_grad=True)
        self.iw11 = nn.Parameter(torch.tensor(inpw[1][1]), requires_grad=True)
        self.bi0 = nn.Parameter(torch.tensor(bias[0]), requires_grad=True)
        self.hw00 = nn.Parameter(torch.tensor(hidw[0][0]), requires_grad=True)
        self.hw01 = nn.Parameter(torch.tensor(hidw[0][1]), requires_grad=True)
        self.hw10 = nn.Parameter(torch.tensor(hidw[1][0]), requires_grad=True)
        self.hw11 = nn.Parameter(torch.tensor(hidw[1][1]), requires_grad=True)
        self.bi1 = nn.Parameter(torch.tensor(bias[1]), requires_grad=True)
    def forward(self, input):
        input_to_top_relu = input * self.iw00 + self.bi0
        top_relu_output = F.relu(input_to_top_relu)
        scaled_top_relu_output = top_relu_output * self.iw01
        input_to_bottom_relu = input * self.iw10 + self.bi0
        bottom_relu_output = F.relu(input_to_bottom_relu)
        scaled_bottom_relu_output = bottom_relu_output * self.iw11
        input_to_final_relu = scaled_top_relu_output + scaled_bottom_relu_output + self.bi1
        output = F.relu(input_to_final_relu)
        return output
model = mANN()
output_values = model(input)
inputs = torch.tensor(input)
labels = torch.tensor(output)

optimizer = SGD(model.parameters(), lr=lr)
print("Final bias, before optimization: " + str(model.final_bias.data) + "\n")
for epoch in range(2):
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
iter=0
while iter<0:
    iter+=1
    h = torch.sigmoid(x.matmul(w1.transpose(0,1))+b[0])
    y_pred = torch.sigmoid(h.matmul(w2.transpose(0,1))+b[1])
    print("iteration:",iter,"MSE: ",0.5*(((y_pred - y).pow(2)).sum()))
    grad=(y_pred - y)*(1-y_pred)*y_pred # numerically unstable?
    w1-=lr*w2.matmul(grad.reshape(-1, 1))*h*(1-h).reshape(-1, 1).matmul(x) # though it seems like descent is faster if first layer done in end? #FILO
    print(w1)
    #w2-=lr*np.outer(grad,h)
    print(w2)
print("Time taken:", datetime.now() - startTime)

#https://alphasignalai.beehiiv.com/p/gpulevel-inference-cpu?utm_source=alphasignalai.beehiiv.com&utm_medium=newsletter&utm_campaign=gpu-level-inference-on-your-cpu
from torch.utils.tensorboard import SummaryWriter
import torchvision

# Init writer and model
writer = SummaryWriter('runs/demo')
model = torchvision.models.resnet50()
dummy_data, _ = load_dataset()

# Add model graph
writer.add_graph(model, dummy_data)

# Fake training loop for demo
for epoch in range(5):
    loss = epoch * 0.1  # Simulated loss
    writer.add_scalar('train_loss', loss, epoch)

# Close writer
writer.close()
