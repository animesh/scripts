prot = tblread('L:\Elite\Camilla\2016\juni\log2LFQvalues.txt','\t');
[data,id,idx]=xlsread('L:\Results\Ishita\Log2abs0.5.xlsx');
data=dataset('XLSFile','L:\Results\Ishita\Log2abs0.5.xlsx');
prot = tblread('L:\Results\Ishita\Copy of Log2abs0.5 GO.txt','\t');
idx(:,1)
protcl=data(:,8:19);
clustergram((protcl), 'Colormap', redbluecmap,'ImputeFun','knnimpute','RowLabels', idx(:,1))
clustergram(protcl, 'Colormap', redbluecmap,'ImputeFun','knnimpute')
cg = clustergram(progValues, 'RowLabels', progAccession,...
                             'ColumnLabels', progSamples,...
                             'RowPdist', 'correlation',...
                             'ColumnPdist', 'correlation',...
                             'ImputeFun', @knnimpute)
                       
progValues = str2double(dataset2cell(data(:,2:13)));
progAccession = dataset2cell(data(:,1));
progSamples = dataset2cell(data(1,2:13));
cg_s = clustergram(progValues, 'RowLabels', progAccession,...
                               'Colormap', 'parula',...
                               'ImputeFun', @knnimpute)
                           
load bc_proggenes231
protcl=prot(:,1:12);
cubic = @(x) x^3+x^2+x
[protcl, fval, exitflag, output] = fminunc(protcl,cubic,'Algorithm','quasi-newton')
protclremnan=knnimpute(protcl)
protclremnanzscore=zscore(protcl)
cm=clustergram(protcl,'Colormap', parula,'ImputeFun','knnimpute')
get(cm)
cm.RowLabels
cm.ColumnLabels
clustergram(protclremnanzscore)
pclz=zscore(protcl(1:5,1:5))