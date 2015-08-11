%% read
lfq = tblread('L:\Elite\Aida\RawFiles\Samples\LFQcc.txt','\t');
ss = tblread('L:\Elite\Aida\RawFiles\Samples\SScc.txt','\t');
ssc=tblread('L:\Elite\Aida\RawFiles\CellLines RawFiles\hierarchical-data-1col.txt','\t');

%% linearize
lfqr=lfq(:)
ssr=ss(:)
lfqr(isnan(lfqr))=1
ssr(isnan(ssr))=1

%% plot
plot(lfqr)
histfit(lfqr)
hist3([lfqr ssr],[20 20])
set(get(gca,'child'),'FaceColor','interp','CDataMode','auto');
scatter(lfqr,ssr)

%% fit
[pts, r] = fit( lfqr,ssr,  'poly2' )
plot( pts,lfqr,ssr );

%% HC
[corrprot cpv]=corrcoef(ssc,'rows','pairwise')
cgprop=clustergram(corrprot, 'Colormap', redgreencmap(256))

%% write correlation matrix
dlmwrite('pairwisecorrcoefnum.csv',corrprot)
dlmwrite('pairwisecorrcoefpvalue.csv',cpv)
