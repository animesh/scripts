%% read

[data,id,~]=xlsread('L:\Qexactive\Linda\MaxLFQall.xlsx');
protab = tblread('c:\users\animeshs\Desktop\MCRshalinitonje.txt','\t')
protab = tblread('L:\Qexactive\Linda\LFQALLseries\proteinGroups.txt','\t')
[data,id,~]=xlsread('L:\Elite\Ani\lfq.xlsx');
lfq=data(:,10:33);
%% extract LFQ
lfq=protab(:,[103:107])
lfq=protab(:,[97:99])
lfq(lfq == 0) = NaN
plot(log2(lfq(:,3)),log2(lfq(:,1)),'.')
%lfq=data(:,901:1019);
[corrprot cpv]=corrcoef(log2(lfq),'rows','pairwise')
[corrprot cpv]=corrcoef(lfq,'rows','pairwise')
cgprop=clustergram(corrprot, 'Colormap', redgreencmap(256),'ImputeFun','knnimpute')%,'Distance', 'mahalanobis')


%% correlate
[corrprot cpv]=corrcoef((lfq),'rows','pairwise')
dlmwrite('pairwisecorrcoefnum.csv',corrprot)
dlmwrite('pairwisecorrcoefpvalue.csv',cpv)
cgprop=clustergram(corrprot, 'Colormap', redgreencmap(256),'ImputeFun','knnimpute')%,'Distance', 'mahalanobis')

prot=protab(:,7:60)
corrprot=corrcoef((prot),'rows','pairwise')
corrprot(corrprot == 1) = NaN
[val indx]=max(abs(corrprot))
val=val'
indx=indx'
cgprop=clustergram(corrprot, 'Colormap', redgreencmap(256),'ImputeFun','knnimpute')%,'Distance', 'mahalanobis')
