%% data
data=xlsread('X:\Elite\LARS\2013\oktober\bsa dmso test\BSAN2DMSO3med.xlsx');
%data=xlsread('X:\Elite\LARS\2013\oktober\bsa dmso test\BSAhigh.xlsx');

%% compare area

plot(log(median(data(:,6:7)')),log(median(data(:,8:10)')),'r.')
ylabel('DMSO')
[h,p,ci] = ttest(median(data(:,6:7)'),median(data(:,8:10)'))
corr(median(data(:,6:7)')',median(data(:,8:10)')','rows','pairwise')

%% scores

plot(log(median([data(:,11) data(:,15)]')),log(median([data(:,19) data(:,24) data(:,29)]')),'r.')
ylabel('DMSO')
[h,p,ci] = ttest(median([data(:,11) data(:,15)],2),median([data(:,19) data(:,24) data(:,29)],2))

corr(median([data(:,11) data(:,15)],2),median([data(:,19) data(:,24) data(:,29)],2),'rows','pairwise')



