inp=[0.05,0.10]
inpw=[[0.15,0.20],[0.25,0.3]]
hidw=[[0.4,0.45],[0.5,0.55]]
outputr=[0.01,0.99]
bias=[0.35,0.6]
lr=0.5

import numpy as np
x=np.asarray(inp)
y=np.asarray(outputr)
#b=np.asarray(bias) # ignoring due to precision issues with unrounding? so using bias array as is check with... python -c "b=[0.35,0.6];print b[0]/b[1];import numpy as np;bias=np.asarray(b);print bias[0]/bias[1]"
w1=np.asarray(inpw)
w2=np.asarray(hidw)
print(x,y,bias,w1,w2)

iter=0
while iter<10000:
    iter+=1
    h=1/(1+np.exp(-(x.dot(w1.T)+bias[0])))
    y_pred=1/(1+np.exp(-(h.dot(w2.T)+bias[1])))
    print("iteration:",iter,"MSE: ",0.5*np.square(y_pred - y).sum())
    grad=(y_pred - y)*(1-y_pred)*y_pred # numerically unstable?
    w1-=lr*np.outer(w2.T.dot(grad)*h*(1-h),x) # though it seems like descent is faster if first layer done in end? #FILO
    #print(w1)
    w2-=lr*np.outer(grad,h)
    #print(w2)

#coding https://mattmazur.com/2015/03/17/a-step-by-step-backpropagation-example/ with numpy, checking with iterative version at  https://github.com/animesh/ann/blob/master/ann/Program.cs with following output
#Iteration = 1   Error = 0.298371108760003       Outputs = 0.751365069552316     0.772928465321463
#Iteration = 2   Error = 0.291027773693599       Outputs = 0.742088111190782     0.775284968294459  ...
#inpw0.149780716132763,delin0.0363503063931447,hidden0.593269992107187,input0.05,diff0.000219283867237173
#inpw0.24975114363237,delin0.0413703226487447,hidden0.596884378259767,input0.05,diff0.00024885636763043
#inpw0.199561432265526,delin0.0363503063931447,hidden0.593269992107187,input0.1,diff0.000438567734474347
#inpw0.299502287264739,delin0.0413703226487447,hidden0.596884378259767,input0.1,diff0.00049771273526086
#j0,i0,hidw=>0.358916479717885
#j1,i0,hidw=>0.511301270238738
#j0,i1,hidw=>0.408666186076233
#j1,i1,hidw=>0.561370121107989
