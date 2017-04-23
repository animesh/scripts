%% prob 2 

rng(0,'v5uniform');
n=100;
m=300;
A=rand(m,n);
b=A*ones(n,1)/2;
c=-rand(n,1);

plot(c,A'*b,'r.')


%% simple_portfolio_data from https://class.stanford.edu/courses/Engineering/CVX101/Winter2014/courseware/
n=20;
rng(5,'v5uniform');
pbar = ones(n,1)*.03+[rand(n-1,1); 0]*.12;
rng(5,'v5normal');
S = randn(n,n);
S = S'*S;
S = S/max(abs(diag(S)))*.2;
S(:,n) = zeros(n,1);
S(n,:) = zeros(n,1)';
x_unif = ones(n,1)/n;


%% test

ri=(inv(pbar'*pbar)*pbar'*S)
risk=sqrt(S(:,1)'*(S(:,1)))
sqrt(ri*(ri)')

%% check analytical solution for least square
x=[1:100]'
y=3*x
d=inv(x'*x)*x'*y
x\y

%% project
plot(1:n,S(:,1),'r.')
retn=pbar'*S %(:,1)
sqrt(x_unif'*(x_unif))
retrn=pbar'*x_unif
risk=std(pbar'*sum(x_unif))
ri=(inv(pbar'*pbar)*pbar'*x_unif)



