data=xlsread('P:\begrenset\HUNTER\MR-metabolomics\NMR_all_cancer_types.xlsx');
dataval=data(2:37,1:66)
[coefs,score] = pca(zscore(dataval));
[coefs,score] = pca((dataval));
biplot(coefs(:,1:2),'scores',score(:,1:2))

