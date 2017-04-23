%% bi-phasic log-sigmoid function

t=100;
b=0;
s=t-b;
f=0.4;
kd1=0.5;
kd2=0.5;
m1=1;
m2=1;
x=0.01:0.001:1;
y=b+(s*f)./(1+10.^(log(kd1-x)*m1))+(s*(1-f))./(1+10.^(log(kd2-x)*m2))
plot(x,y,'r.')

%% data from MST

d=[3.9063	926.4901
7.8125	928.6018
15.6250	926.7656
31.2500	923.3865
62.5000	920.1771
125.0000	918.1742
250.0000	914.5995
500.0000	913.0282
1000.0000	912.5943
2000.0000	914.1325
]
k
%corr(d)
%d=flipud(d)
plot(d(:,1),d(:,2),'r-');


%% source

http://books.google.no/books?id=tIsjh56pI0IC&lpg=PA295&ots=dP_wyva3Q_&dq=log%20sigmoid%20biphasic&pg=PA295#v=onepage&q=log%20sigmoid%20biphasic&f=false