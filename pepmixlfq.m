%% read
pep=xlsread('L:\Qexactive\Ani\PepMixWJPT.xlsx');
prot=xlsread('L:\Tony\121116_CSR_SILAC_Qexactive\SILACproteinGroupsQE.xlsx');
lfq=pep(:,[16:20]); 
ibaq=pep(:,[21:40]);
int=pep(:,[1:4]);

%% protein abundance
hist((prot(prot(:,33)>0,33)),[100]) % raw intensities, area under curve?
hist(log2(prot(prot(:,33)>0,33)),[128])
hist(log10(prot(prot(:,33)>0,33)),[100])
plot(prot(:,33),'r.')

hist(log10(prot(prot(:,48)>0,48)),[100]) % iBAQ
hist(log2((prot(prot(:,63)>1,63))),[256]) % LFQ L
hist(log2((prot(prot(:,64)>1,64))),[256]) % LFQ H
hist(log2(mean(prot(:,63:70),2)),[256]) % mean label free values

%% cluster
corrprot=corrcoef(prot(:,2:5),'rows','pairwise')
corrprot=corrcoef(prot(:,36:47),'rows','pairwise')
ccprop=clustergram(corrprot, 'Colormap', redgreencmap(256),'ImputeFun','knnimpute')

%% regress
plot(log(mean(int(:,[1:2]),2)),log(mean(int(:,[3:4]),2)),'b.')
log(mean(int(:,[3:4])))\log(mean(int(:,[1:2])))
plot(int(:,[1]),int(:,[2]),'r.')
plot(mean(int(:,[1:2]),2),mean(int(:,[3:4]),2),'b.')

%% cluster analysis

corrpep=corrcoef(int,'rows','pairwise')
ccprop=clustergram(corrpep, 'Colormap', redgreencmap(256),'ImputeFun','knnimpute')%,'Distance', 'mahalanobis')
get(ccprop)
corrprot=corrcoef(int','rows','pairwise')
ccprop=clustergram(corrprot, 'Colormap', redgreencmap(256),'ImputeFun','knnimpute')%,'Distance', 'mahalanobis')

