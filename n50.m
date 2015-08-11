
%% plot N50 from various assemblers at coverage;
clear all
hold on


N50 = load('n50s.txt.cov');
x = N50(:,1);
y = mean(N50(:,2:11)');
e = std(N50(:,2:11)');
errorbar(x,y',e','or-');

N50 = load('n50r.txt.cov');
x = N50(:,1);
y = mean(N50(:,2:11)');
e = std(N50(:,2:11)');
errorbar(x,y',e','.r--');


N50 = load('n50tech.txt.cov');
x = N50(:,1);
y = N50(:,2);
plot(x,y,'.y-');


N50 = load('n50qs.txt.cov');
x = N50(:,1);
y = N50(:,2);
plot(x,y,'.b-');

xlabel('Coverage')
ylabel('N50')
title('N50 for E.coli with various read selection strategies using Newbler')
legend('ML','Random','454Tech','Quality','Location','best')
hold off



%% ls
N50 = load('n50ls.txt.cov');
x = N50(:,1);
y = N50(:,2);
plot(x,y,'.c-');


%% other assemblers

hold on
N50 = load('c50s.txt.cov');
x = N50(:,1);
y = mean(N50(:,2:11)');
e = std(N50(:,2:11)');
errorbar(x,y',e','>k-');
N50 = load('c50r.txt.cov');
x = N50(:,1);
y = mean(N50(:,2:11)');
e = std(N50(:,2:11)');
errorbar(x,y',e','<k--');

N50 = load('clc50s.txt.cov');
x = N50(:,1);
y = mean(N50(:,2:11)');
e = std(N50(:,2:11)');
errorbar(x,y',e','^m-');
N50 = load('clc50r.txt.cov');
x = N50(:,1);
y = mean(N50(:,2:11)');
e = std(N50(:,2:11)');
errorbar(x,y',e','vm--');


N50 = load('v50s.txt.cov');
x = N50(:,1);
y = mean(N50(:,2:11)');
e = std(N50(:,2:11)');
errorbar(x,y',e','xg-');
N50 = load('v50r.txt.cov');
x = N50(:,1);
y = mean(N50(:,2:11)');
e = std(N50(:,2:11)');
errorbar(x,y',e','+g--');

xlabel('Coverage')
ylabel('N50')
title('N50 for E.coli using Celera, CLC and Velvet')
legend('Celera(S)','Celera(R)','CLC(S)','CLC(R)','Velvet(S)','Velvet(R)','Location','best')
hold off