%% demo gso

hold on
grid on
axis equal
x=-5:5;

plot(2,3,'ro')
plot(x,3*x/2,'k-')
plot(x,3*x/2+65/26,'k-')
plot(1,4,'go')
plot(x,4*x,'c-')
plot(-15/13,10/13,'bo')
plot(x,-2*x/3,'y-')
plot(x,-2*x/3+7,'m-')
plot(x,-2*x/3+14/3,'k-')

plot(14*2/13,14*3/13,'ko')

hold off


%% sphering - decorrelation and normalization with mean vector

A=[2 3;1 4]
A=rand(100,100)
inv(A)
[U D V]=svd(A)
corr(U)

