ls %% read data
[cu,~,~]=xlsread('L:\Elite\gaute\test\CDS_CU_EntrezID.xls');
cu(isnan(cu)) = 0.5 ; % cleanup and replace mssing vals

%% clusters
corrcu=corrcoef(cu)
cg=clustergram(cu(:,2:65), 'Colormap', redbluecmap,'ImputeFun','knnimpute')

%% pick interesting categories via uniprot search and ID mapping tool http://www.uniprot.org/jobs/2014030890DLN22R2H

gsea=[1 3 5 7];
gs=[7374 7466];
gs=csvread('C:\Users\animeshs\SkyDrive\metaeg.list');
gs=csvread('C:\Users\animeshs\SkyDrive\epigeneg.list');
gs=csvread('C:\Users\animeshs\SkyDrive\gotranslationeg.list');
gs=csvread('C:\Users\animeshs\SkyDrive\homorec.list');
gs=csvread('C:\Users\animeshs\SkyDrive\apoeg.list');
gs=csvread('C:\Users\animeshs\SkyDrive\dnarepeg.list');
gs=csvread('C:\Users\animeshs\SkyDrive\angioeg.list');
gs=sort(gs(:,1))'
idpos = arrayfun(@(x)find(cu(:,1)==x,1),gs,'UniformOutput',false) % http://yagtom.googlecode.com/svn/trunk/html/speedup.html
clustergram(cu(cell2mat(idpos'),2:65), 'Colormap', redbluecmap,'ImputeFun','knnimpute')

%grep -i "Apoptosis" /cygdrive/l/Elite/gaute/test/gene2go | awk '{print $1}' | sort | uniq

%% find gene list and write to file
get(cg)
set(cg,'Dendrogram', 1)
get(cg)
cg.RowLabelsLocation
cg.RowLabels
gene=cg.RowLabels
sample=cg.ColumnLabels
egn=cu(1,gene)
egn=cu(1,:)
egn=cu(gene,1)
egn=cu(:,1)
egn=cu(gene(:),1)
egn=cu(gene(1),1)
gene
str2num(gene)
cell2num(gene)
cell2mat(gene)
gene
egn=cu(cell2mat(gene),1)
egno=cu(:,1)
egno(1)
egno(ans)
egn=egno(cell2mat(gene))
cell2mat(gene)
gc2m=cell2mat(gene)
str2num(gc2m)
gns=str2num(gc2m)
egno(gns)
egnn=egno(gns)
save geneclus.txt egnn -ASCII

