%% read
prot=xlsread('L:\Elite\LARS\2014\juni\Pseudomonas\PesudoSproteinGroups.xls');
prot=prot(:,5:8);

%% check
plot(prot)
histfit(prot(~isnan(prot)))

