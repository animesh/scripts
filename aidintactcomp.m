%% read file
%[~,A,~]=xlsread('L:\Elite\LARS\2014\mars\B5inputStim.xls');
%[~,A,~]=xlsread('L:\Elite\LARS\2014\mars\B5inputUnstim.xls');
%[~,A,~]=xlsread('L:\Qexactive\Berit_Sissel\B005\B5Stimonly.xls');
[~,A,~]=xlsread('L:\Qexactive\Berit_Sissel\B005\B5Unstimonly.xls');
A=A(2:end,1);
size(unique(A),1)
%[~,B,~]=xlsread('L:\Qexactive\Berit_Sissel\B005\B5Stim.xls');
%[~,B,~]=xlsread('L:\Qexactive\Berit_Sissel\B005\B5Unstim.xls');
%[~,B,~]=xlsread('L:\Elite\LARS\2014\mars\B5inputStim.xls');
[~,B,~]=xlsread('L:\Elite\LARS\2014\mars\B5inputUnstim.xls');    
B=B(2:end,1);
size(unique(B),1)

%% extract ids

comm=intersect(A,B)
inA=setdiff(A,B);
inB=setdiff(B,A);

%% venn
%venn([size(inA,1)+size(comm,1) size(inB,1)+size(comm,1)],size(comm,1),'FaceColor',{'r','y'},'FaceAlpha',{1,0.6},'EdgeColor','black')
vennX([size(inA,1)+size(comm,1) size(comm,1) size(inB,1)+size(comm,1)], 0.1)

%% write IDs
%fid = fopen('L:\Qexactive\Berit_Sissel\B005\IPstimOnly.csv', 'w');
%fid = fopen('L:\Qexactive\Berit_Sissel\B005\IPUnstimOnly.csv', 'w');
fid = fopen('L:\Qexactive\Berit_Sissel\B005\UnstimIPOnly.csv', 'w');
fprintf(fid,'Gene\n'); 
%fprintf(fid,'%s\n', inB{:}); 
fprintf(fid,'%s\n', inA{:}); 
fclose(fid)



%% read files
prot=xlsread('X:\Qexactive\Berit_Sissel\MCR22Proteins.xls')
prot=prot(:,[28,36,44,52,60,68,76,84,92,100,108,116,124,132,140,148,156,164,172,180,188,196])
prot=prot(:,6:27)
prot=xlsread('L:\Qexactive\Berit_Sissel\B005\iBAQproteinGroups.xls')


%% scores and areas
scorea=xlsread('X:\Qexactive\Berit_Sissel\B005\SMAcomp.xlsx')
corr(scorea,'rows','pairwise')
corr(prot(:,38:45),'rows','pairwise')

%% tobias
ratio=xlsread('X:\Results\TS\MeanRatiosT0t5t12withTriplicateMedianValsNames.xls')
corrprot=corrcoef(ratio(:,[1:3]),'rows','pairwise')
ccprop=clustergram(corrprot, 'Colormap', redgreencmap(256),'ImputeFun','knnimpute')%,'Distance', 'mahalanobis')
spy(prot)

%% comp
[pcom, z, dev] = pca1(prot)
cumsum(dev./sum(dev) * 100)
plot3(pcom(:,1),pcom(:,2),pcom(:,3),'r.')
tags = num2str((1:size(pcom,1))','%d');
text(pcom(:,1),pcom(:,2),pcom(:,3),tags)
xlabel('PC1');
ylabel('PC2');
zlabel('PC3');
title('PCA Scatter');

%%cluster

corrprot=corrcoef(prot','rows','pairwise')
ccprop=clustergram(corrprot, 'Colormap', redgreencmap(256),'ImputeFun','knnimpute')%,'Distance', 'mahalanobis')


%% correlations

corr(prot,'rows','complete')
%corr(peparea,'rows','complete')

corr(prot(:,6:11),'rows','complete')

corr([prot(:,12),prot(:,20),prot(:,28),prot(:,36),prot(:,44),prot(:,52)],'rows','complete')
corr([prot(:,16),prot(:,24),prot(:,32),prot(:,40),prot(:,48),prot(:,56)],'rows','complete')

%% hist

hist(prot(:,6:11))


%% plot

plot(peparea(:,1),peparea(:,11),'r.')
hold
plot(peparea(:,6),peparea(:,16),'b.')
hold off
