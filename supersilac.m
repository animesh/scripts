%% read
[data,id,~]=xlsread('L:\Elite\Celine\heatmap_data.xlsx');
prot =xlsread('L:\Elite\Aida\MM20.xlsx');
protcl = tblread('L:\Elite\Aida\RawFiles\CellLines RawFiles\combined\txt\proteinGroups.txt','\t')
protmm = tblread('L:\Elite\Aida\RawFiles\Samples\combined\txt\proteinGroups.txt','\t')
prot =xlsread('L:\Elite\Aida\MM20CL8.xls');
prot =xlsread('L:\Elite\Aida\mm20celllinecanonicalpathwayheatmap.xlsx');
prot =xlsread('L:\Elite\Sissel\Nina5\tn.xlsx');
prot = tblread('L:\Elite\Celine\MM\combined\txt\proteinGroups.txt','\t')
prot = tblread('V:\felles\PROTEOMICS and XRAY\Articles in prep\sPCL\Manuscript\Results-ani and Supplementary\SSandLFQttestPB.txt','\t');
prot = tblread('L:\Elite\LARS\2014\juni\PD2\Pseudomonas-SuperSILAC\140605_Pseudomonas_S1_K0K6_T2-(03)_TargetProtein Perseus.txt','\t');
protcl=prot(:,128:201);

%% optimize find min variance

f = @(x,y) x.*exp(-x.^2-y.^2)+(x.^2+y.^2)/20;
ezsurfc(f,[-2,2])
fun = @(x) f(x(1),x(2));
x0 = [-.5; 0];
%options = optimoptions('fminunc','Algorithm','quasi-newton');
options.Display = 'iter';
[x, fval, exitflag, output] = fminunc(fun,x0,'Algorithm','quasi-newton')
cubic = @(x) x^3+x^2+x
cubic(10)+1

%% cluster
clustergram(log2(protcl), 'Cluster','column', 'Colormap', redbluecmap,'ImputeFun','knnimpute')
clustergram(log2(protcl), 'Colormap', redbluecmap,'ImputeFun','knnimpute')

%% BMC res note figures
hist(prot(abs(prot(:,9)),9))


%% check
corrprot
clprot=protcl(:,[181:6:361]);
mmprot=protmm(:,[326:6:680]);
prot=log2(data);
hist(prot)
protknn=knnimpute(prot);

%% cluster analysis
[corrprot cpv]=corrcoef(prot,'rows','pairwise')
spy(cpv)
[corrprot cpv]=corrcoef(log2(prot),'rows','pairwise')
cgprop=clustergram(corrprot, 'Colormap', redgreencmap(256),'ImputeFun','knnimpute')%,'Distance', 'mahalanobis')

%% write correlation matrix

dlmwrite('pairwisecorrcoefnum.csv',corrprot)
dlmwrite('pairwisecorrcoefpvalue.csv',cpv)


%% compare pathways
clhm=dataset('XLSFile', 'L:\Elite\Aida\celllinecanonicalpathwayheatmap.xls');
mmhm=dataset('XLSFile', 'L:\Elite\Aida\MM20CanPathHeatMap.xls');
hm=join(clhm, mmhm,'Type','outer')
hmd=hmd(:, any(~isnan(hmd), 1)); % remove columns with all NaNs
hmd=hmd(any(~isnan(hmd), 2),:); % remove rows with all NaNs
[corrprot cpv]=corrcoef(hmd,'rows','pairwise')
cgprop=clustergram(corrprot, 'Colormap', redgreencmap(256),'ImputeFun','knnimpute')%,'Distance', 'mahalanobis')
cgprop=clustergram(hmd, 'Colormap', redgreencmap(256),'ImputeFun','knnimpute')%,'Distance', 'mahalanobis')
spy(cpv)
dlmwrite('pairwisecorrcoefnum.csv',corrprot)
dlmwrite('pairwisecorrcoefpvalue.csv',cpv)

%% ugly iterator
hmd=zeros(size(hm,1),size(hm,2));
for i = 1:size(hm,1)
    for j = 1:size(hm,2)
        hmd(i,j)=str2double(hm{i,j});
    end
end


%% comp
%protimp=knnimpute(log2(prot'))
prot=protab(:,[181:6:361]);
prot(any(isnan(prot), 2),:)=[];
%[wcoeff,score,latent,tsquared,explained] = pca(prot','Rows','pairwise');
[wcoeff,score,latent,tsquared,explained] = pca(log2(prot'),'Rows','pairwise');
plot3(score(:,1),score(:,2),score(:,3),'.')
xlabel('1st Principal Component')
ylabel('2nd Principal Component')
zlabel('3rd Principal Component')
%gname

%% random playing with components

pareto(explained)
biplot(wcoeff(:,1:2),'scores',score(:,1:2));

%source http://www.mathworks.se/help/stats/feature-transformation.html#f75476

%% auto label plot
tags = num2str((1:size(pcom,1))','%d');
text(score(:,1),score(:,2),score(:,3),tags,'FontSize',8)
[st2,index] = sort(tsquared,'descend');
cumsum(dev./sum(dev) * 100)
plot(pcom(:,1),pcom(:,2),'r.')
tags = num2str((1:size(pcom,1))','%d');
text(pcom(:,1),pcom(:,2),tags)
text(score(:,1),score(:,2),tags)
xlabel('PC1');
ylabel('PC2');
title('PCA Scatter');


%% check IDs
upid=id(2:end,1);
size(unique(upid),1)

%% extract ratios
both=[30:3:99]
bod=data(:,both);
mor=[30    33    36    39    42    45    48    51    66    69    72    75    90    93    96    99 ]
eve=[54 57 60 63 78 81 84 87]
mod=data(:,mor);
evd=data(:,eve);

%% distribution
hist(log2(evd))
hist(log2(mod))

%% correlation
corrprot=corrcoef(log2(bod),'rows','pairwise')
corrprot=corrcoef((bod),'rows','pairwise')

%% compare
histfit(median(log2((evd(~isnan(evd)))),2))
histfit(median(log2((mod(~isnan(mod)))),2))


%% 
load yeastdata
whos yeastvalues genes

%% time points
cnt=~isnan(prot);
[r c]=size(prot)
tp=zeros(r,c/4);
tc=0;
for i=1:4:c
    tc=tc+1;
    tp(:,tc)=sum(cnt(:,i:i+3),2);
end
hist(tp)
hist(prot)
histfit(prot(:,26))
%reshape(prot(~isnan(prot)),r,c)

%% cluster analysis
clustergram(prot(:,4:66), 'Cluster','column', 'Colormap', redbluecmap,'ImputeFun','knnimpute')
corrprot=corrcoef(prot,'rows','pairwise')
ccprop=clustergram(corrprot, 'Colormap', redgreencmap(256),'ImputeFun','knnimpute')%,'Distance', 'mahalanobis')
get(ccprop)
corrprot=corrcoef(prot','rows','pairwise')
ccprop=clustergram(corrprot, 'Colormap', redgreencmap(256),'ImputeFun','knnimpute')%,'Distance', 'mahalanobis')
spy(prot(:,2:25))

%% subgroup analysis
protsg=prot(:,[61:63,22:24,34:36,10:12,19:21]);
corrprot=corr(protsg,'rows','pairwise')
ccprop=clustergram(corrprot, 'Colormap', redgreencmap(256),'ImputeFun','knnimpute');
dpst = linkage(ccprop, 'ward');

csize=2;
dpsg = pdist(protsg', 'euclid');
dpst = linkage(dpsg, 'ward');
getid = cluster(dpst, 'maxclust',csize);


%% tags

cd = clusterdata(pcom(:,1:2),4);
gscatter(pcom(:,1),pcom(:,2),cd)
gname('name')


>>>>>>> 5307f70af61f5ac82ab8a44b805cae431deb83da


%% plot MM with MGUS

corr(log10(prot(:,1)),log10(prot(:,2)),'rows','pairwise')
plot(log10(prot(:,1)),log10(prot(:,2)),'b.')

%% find significant diffs

mavolcanoplot(prot(:,1), prot(:,2), mattest(prot(:,1), prot(:,2)),'LogTrans','True')
mavolcanoplot(proto(:,1), proto(:,2), mattest(proto(:,1), proto(:,2)),'LogTrans','True')



%% check rand vals

proto=randn(1000,1).*(2*pi)
proto=[proto  2*proto -1*proto sin(proto) cos(proto) sin(proto).*cos(proto)]


<<<<<<< HEAD
%% cluster analysis

corrprot=corrcoef(prot,'rows','pairwise')
corrprot=corrcoef(prot','rows','pairwise')
ccprop=clustergram(corrprot, 'Colormap', redgreencmap(256)) %,'ImputeFun',@('distance', 'mahalanobis')knnimpute)%,'Distance', 'mahalanobis')
get(ccprop)
=======
>>>>>>> 5307f70af61f5ac82ab8a44b805cae431deb83da

%% correlation plot
corrprot=corr(prot,'rows','pairwise')
HeatMap(corrprot,'Colormap', redgreencmap(256))


%% compare forward and reverse ratios against molecular weights

plot(protrev(:,15),protrev(:,20),'r.')
hold
plot(prot(:,15),1./prot(:,20),'b.')
hold

%% correlation

hist(protcomb(:,2),[100])
hist(1./protcomb(:,3),[100])
plot(protcomb(:,2),1./protcomb(:,3),'k.')
[rho val]=corrcoef(protcomb(:,2),1./protcomb(:,3),'rows','pairwise')
hist(protcomb(:,2)-1./protcomb(:,3),[100])


%% outliers

X = 1:1000; % Pseudo Time
Y = 5000 + randn(1000, 1); % Pseudo Data
Outliers = randi(1000, 10, 1); % Index of Outliers
Y(Outliers) = Y(Outliers) + randi(1000, 10, 1); % Pseudo Outliers
[YY,I,Y0,LB,UB] = hampel(X,Y);

plot(X, Y, 'b.'); hold on; % Original Data
plot(X, YY, 'r'); % Hampel Filtered Data
plot(X, Y0, 'b--'); % Nominal Data
plot(X, LB, 'r--'); % Lower Bounds on Hampel Filter
plot(X, UB, 'r--'); % Upper Bounds on Hampel Filter
plot(X(I), Y(I), 'ks'); % Identified Outlie



%% compare maxquant with proteome discoverer

mqpd=[0.825	0.772	0.774	0.306	0.252	0.302	1.672	1.729	1.779	0.977	0.999	1.023	0.778	0.709	0.788	0.972	0.980	0.928	0.385	0.369	0.383	0.970	0.963	0.998 ;
0.70866	0.71609	0.74699	0.37127	0.3181	0.323	1.2621	1.1789	1.258	0.60449	0.68233	0.84355	0.73261	0.73799	0.76839	0.8078	0.86479	0.83016	0.45036	0.45852	0.49714	0.73496	0.72891	0.71174]


[hyp pval ci stats]=ttest(mqpd(1,:),mqpd(2,:))

plot(mqpd(1,:),mqpd(2,:),'b.')
comm -12 <(sort pd.txt) <(sort mq.txt) | wc


%% fit dist

pd = fitdist(kam,'Normal')
pd = fitdist(kam,'Kernel','Kernel','epanechnikov')
x_values = 0:0.01:50;
pdf = pdf(pd,x_values);
plot(x_values,pdf,'LineWidth',2)
