%
% perform a quick sanity check
%

uint64(4)  + uint64(2)
uint64(4)  - uint64(2)
uint64(4) ./ uint64(2)
uint64(4) .* uint64(2)

%% read
prot=xlsread('L:\Elite\LARS\2014\juni\Pseudomonas\PesudoSproteinGroups.xls');
prot=prot(:,5:8);

%% check
plot(prot)
histfit(prot(~isnan(prot)))


