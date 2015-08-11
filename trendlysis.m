%% data
[prot gene ~]=xlsread('L:\Elite\Celine\final.xlsx');
a=[10	20	12	131	31];
b=[4 5 6 7 8];
c=[0.9 1 2 3 4];
d=[0.2 0.4 0.6 0.8 1];
t=[1 2 3 4]
%b=rand()*a/2
%c=rand()*a/4
%d=rand()*a/8

%% trending
plot(prot(end,:),prot(1:end-1,:))
plot(prot(end,:),prot(16,:),'r.')

%% stabdardize

a=zscore(a)
b=zscore(b)
c=zscore(c)
d=zscore(d)

%% plot
plot(t,[a./a;b./a;c./a;d./a]')
%plot(t,[a;b;c;d]')
%plot(t,(d./a)')
