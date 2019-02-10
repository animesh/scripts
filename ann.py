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
