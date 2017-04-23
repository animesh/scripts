%% read
%prot = tblread('L:\Elite\LARS\2014\oktober\OLUF HUNT\endelig\results\proteinGroups.txt','\t')
%prot = tblread('L:\Elite\LARS\2014\november\Kamilla\combined\txt\proteinGroups.txt','\t')
prot = xlsread('L:\Elite\kamila\Heart\Sub12LFQ.xlsx')
protlfq=prot(:,[1:36])
%protlfq=prot(:,[117:128])
%protlfq=prot(:,[501:560])
prot = xlsread('L:\Elite\LARS\2015\january\Ishita\Copy of LFQmedTtestBHcorr.xlsx')
prot = tblread('L:\Qexactive\LARS\2015\mars\Lympma Tissueslides test\Multiconsensus from 3 Reports.txt','\t')
prot = dataset('file','L:\Davi\2015\03\_ODR_HUNT\combined\txt\proteinGroups.txt','delimiter','\t','ReadObsNames',true,'ReadVarNames',true);
prot = dataset('file','L:\Elite\LARS\2014\oktober\OLUF HUNT\endelig\combined\txt\proteinGroups.txt','delimiter','\t','ReadObsNames',true,'ReadVarNames',true);
prot = dataset('file','L:\Elite\LARS\2014\oktober\OLUF HUNT\endelig\results\Smoker2NonSmoker.txt','delimiter','\t','ReadObsNames',true,'ReadVarNames',true);
protlfq=prot(:,[427:484]);
protlfq=prot(:,[1:30]);
protlfqlog=log2(double(protlfq));
protlfqlog(~isfinite(protlfqlog))=0
%to make sure row/sample IDs are unique: awk '{print $1}' /cygdrive/l/Elite/LARS/2014/oktober/OLUF\ HUNT/endelig/results/Smoker2NonSmoker.txt | sort | uniq -c

protlfq
%% cluster analysis
import bioma.data.*
protlfqdm=DataMatrix(double(protlfq(:,:)),'RowNames',cellstr(protlfq.Properties.ObsNames(:)),'ColNames',cellstr(protlfq.Properties.VarNames(:)));
protlfqdm=DataMatrix(double(protlfqlog(:,:)),'RowNames',cellstr(protlfq.Properties.ObsNames(:)),'ColNames',cellstr(protlfq.Properties.VarNames(:)));
cgprop=clustergram(protlfqdm, 'Colormap', redgreencmap(256),'ImputeFun','knnimpute')
[corrprot cpv]=corrcoef(protlfq,'rows','pairwise')
[corrprot cpv]=corrcoef(protlfqknn,'rows','pairwise')
cgprop=clustergram(protlfq, 'Colormap', redgreencmap(256),'ImputeFun','knnimpute','Cluster', 2)
cgprop=clustergram(protlfq, 'Colormap', redgreencmap(256),'ImputeFun','knnimpute','Cluster', 1)%,'Distance', 'mahalanobis')
spy(cpv)
[corrprot cpv]=corrcoef(log2(protlfqnan),'rows','pairwise')
cgprop=clustergram(corrprot, 'Colormap', redgreencmap(256),'ImputeFun','knnimpute')%,'Distance', 'mahalanobis')

%% write correlation matrix

dlmwrite('pairwisecorrcoefnum.csv',corrprot)
dlmwrite('pairwisecorrcoefpvalue.csv',cpv)

%% score distribution
histfit((prot),15,'exponential')
histfit(log2(prot))
xlabel('Score')
ylabel('Count')
title('Score distribution of IDs exclusive to RT120')

