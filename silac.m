%% read
scorea=xlsread('X:\Elite\LARS\2013\oktober\PRN3R.xlsx')

%% scores and areas
prot=prot(:,[28,36,44,52,60,68,76,84,92,100,108,116,124,132,140,148,156,164,172,180,188,196])
prot=prot(:,6:27)
corr(scorea,'rows','pairwise')


%% cluster analysis

corrprot=corrcoef(prot,'rows','pairwise')
corrprot=corrcoef(prot','rows','pairwise')
ccprop=clustergram(prot, 'Colormap', redgreencmap(256),'ImputeFun','knnimpute')%,'Distance', 'mahalanobis')
get(ccprop)

%% comp

[pcom, z, dev] = pca(prot)
cumsum(dev./sum(dev) * 100)
plot(pcom(:,1),pcom(:,2),'r.')
tags = num2str((1:size(pcom,1))','%d');
text(pcom(:,1),pcom(:,2),tags)
xlabel('PC1');
ylabel('PC2');
title('PCA Scatter');