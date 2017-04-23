%% read
d=xlsread('X:\Elite\LARS\2013\April\T Slordahl\Multiconsensus from 3 ReportsMH.xlsx')
p0=xlsread('X:\Elite\LARS\2013\mars\tobias\Multiconsensus from 3 Reports 0t MH.xlsx')
p5=xlsread('X:\Elite\LARS\2013\April\T Slordahl\Multiconsensus from 3 Reports 5t MH.xlsx')
p12=xlsread('X:\Elite\LARS\2013\April\T Slordahl\Multiconsensus from 3 Reports 12t MH.xlsx')

%% combo
d=csvread('X:\Results\TS\comboall.csv',1,1)
hist(d(:,5))

for i=1:12
    d=csvread('X:\Results\TS\comboall.csv',1,1);
    d(d(:,i)~=0,i)=1./d(d(:,i)~=0,i);
    corr(d(d(:,i)~=0,:))
end


plot(d(:,1),1./d(:,4),'r.')

corr(d(d(:,4)!=0,1),1./d(:,4))

x=[1:1000]
y=[2001:3000];
plot(((x-mean(x)./std(x)))',1./y')
plot(x',1./y')
plot(1./((x-mean(x)./std(x)))',1./((y-mean(y)./std(y)))')


%% overlay
plot(d(:,12),d(:,14),'r.')
hold
plot(d(:,1),d(:,2),'r-')
hold off
x=[   1.9941260e+03   8.1647116e+00
   1.9941480e+03   8.1452801e+00
   1.9942100e+03   8.0332465e+00
   1.9942230e+03   8.0937453e+00
   1.9942420e+03   8.1511486e+00
   1.9942880e+03   8.2760447e+00
]

%% distribution
hist(log(d(:,12))/log(10),[100])
hist(log(d(:,13)),[100])

plot(mean(d(:,6:8),2),d(:,12))

hist(mean(d(:,6:8),2)-d(:,12))
hist(std(d(:,6:8),0,2)-d(:,13))

std(d(:,6:8),0,2)


sum(log(d(:,12))/log(10)>0.4)

dl10=log(d(:,12))/log(10)

mean(d(~isnan(d(:,12)),12))

sum(normcdf(-abs(d(:,12)),mean(d(~isnan(d(:,12)),12)),std(d(~isnan(d(:,12)),12)))<0.05)

plot(normcdf(-abs(d(:,12)),mean(d(~isnan(d(:,12)),12)),std(d(~isnan(d(:,12)),12))))

pm=mean([p(:,9),p(:,12),p(:,15)],2)
ps=std([p(:,9),p(:,12),p(:,15)],0,2)

hist(ps)
hist(log(pm)/log(10),[100])



%% source
% http://www.mathworks.com/matlabcentral/newsreader/view_thread/298645