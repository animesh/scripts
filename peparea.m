%% read csv

%pep=csvread('X:\Elite\LARS\2013\mars\tobias\reverse.csv');
%pepval=csvread('M:\Results\Sissel\HeK50\mascot\peparea.csv');
%pepval=csvread('X:\Results\Sissel\HeK50\sequest\pep12.csv');
%rt=csvread('X:\Qexactive\WTH6\WTHRT9RepMHpep.csv',1,6);
%rt=xlsread('X:\Qexactive\WTH6\Multiconsensus from 9 ReportsMHpep.xlsx');
%rt=xlsread('X:\Qexactive\WTH6\Multiconsensus from 9 Reports.xlsx');
rt=csvread('X:\Results\Alexey\rtrep.csv')

%% retention time analysis

rt(:,1)';rt(:,1)';
corrcoef(rt)
boxplot(rt)
scatter3(rt(:,1),rt(:,2),rt(:,3))
plot(mean([rt(:,2)';rt(:,3)']),std([rt(:,2)';rt(:,3)']),'r.')
plot(std([rt(:,2)';rt(:,3)']),rt(:,7),'r.')
corrcoef(std([rt(:,1)';rt(:,2)';rt(:,3)']),rt(:,4))
plot(std([rt(:,1)';rt(:,2)';rt(:,3)']),rt(:,4),'r.')
ksdensity((rt(:,1)))
hist((rt(:,1)))



%% peptide area against concentration

plot(pepval(1,:),pepval(2:end,:),'r.')
pvc=corr(pepval);
plot(pvc)
plot(log(pep(:,1)),log(pep(:,2)),'b.')
qqplot((pep(:,1)),(pep(:,2)))
qqplot((pep(:,1)))
corr((pep(:,1)),(pep(:,2)))
ksdensity(log(pep(:,1)))

%% pep raw
rtv=[2,2,2,4,4,4,6,6,6]
sum(rt(:,48)>=0)
boxplot(rt(:,7:15))
boxplot([rt(:,48),rt(:,66),rt(:,84),rt(:,49),rt(:,67),rt(:,85),rt(:,50),rt(:,68),rt(:,86)])
plot(rtv,[ sum(rt(:,48)>=0), sum(rt(:,66)>=0), sum(rt(:,84)>=0), sum(rt(:,49)>=0), sum(rt(:,67)>=0), sum(rt(:,85)>=0), sum(rt(:,50)>=0), sum(rt(:,68)>=0), sum(rt(:,86)>=0)],'r.')
plot(rt(:,48),rt(:,50),'g.')
scatter3(rt(:,48),rt(:,49),rt(:,50))
scatter3(rt(:,7),rt(:,8),rt(:,9))
hist(rt(:,49),[100])
corrcoef(rt(:,7:15))
sum(rt(:,7:15))
boxplot(pep)
stem(pep(2:end,:))
plot(pep(1,:),pep(:,:),'r.');
corrcoef(sum(pep),pep(1,:)),
plot(sum(pep(2:end,:)),pep(1,:),'b.')


%% error bar plot

plot(pep(1,:), sum(pep(2:end,:))/length(pep),'ro')
hold
plot(pep(1,:), std(pep(2:end,:)),'b*')
hold

hist(pep((pep(2:end,1))>10000))

hold
errorbar(pep(1,:),mean(pep(2:end,:)),std(pep(2:end,:)),'<k--');
hold

hist(log(pep(2:end,1)))
hist(pep(pep(2:end,1)>10000000,1),[200])


%% regression
reg=[pep(1,:)' ones(size(pep(1,:)'))]\sum(pep(2:end,:))'
aest=reg(1).*pep(1,:)'+reg(2)
plot(pep(1,:), sum(pep(2:end,:)),'b.')
hold
plot(pep(1,:), aest(:),'r')
hold

%% xrcc hpo3/total
val=csvread('X:\Qexactive\LARS\2013\mars\xrcc1\values.csv',1,1)
a1=[val(1:3,1)./val(1:3,2)]
a2=[val(4:6,1)./val(4:6,2)]
a3=[val(7:9,1)./val(7:9,2)]
a4=[val(12:14,1)./val(12:14,2)]
boxplot([a1 a2 a3 a4])
ttest([a3 a4])
anova1([a1 a2 a3 a4])

%% source
http://stackoverflow.com/questions/9315666/matlab-linear-regression
http://hs2.proteome.ca/SSRCalc/Slope/