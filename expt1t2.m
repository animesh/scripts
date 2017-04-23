%% time 
x=[0:0.01:10]
hold

%% T1
t1=1-exp(-x)
plot(x,t1,'r.')

%% T2
t2=exp(-x)
plot(x,t2,'b.')

%% paramaters
plot(t2,t1)
whos
hold off
