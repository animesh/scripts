%% file
prot=xlsread('L:\Tony\121005_CSR_SILAC_Velos_pro\combo.xlsx');
mrna=prot(:,9:14);

%% extract plot and correlate

mm=2
pm=5
sum(mrna(:,mm)>0&mrna(:,pm)>0|mrna(:,mm)<0&mrna(:,pm)<0)
corr(mrna((mrna(:,mm)>0&mrna(:,pm)>0|mrna(:,mm)<0&mrna(:,pm)<0),mm),mrna((mrna(:,mm)>0&mrna(:,pm)>0|mrna(:,mm)<0&mrna(:,pm)<0),pm),'rows','pairwise')
plot(mrna((mrna(:,mm)>0&mrna(:,pm)>0|mrna(:,mm)<0&mrna(:,pm)<0),mm),mrna((mrna(:,mm)>0&mrna(:,pm)>0|mrna(:,mm)<0&mrna(:,pm)<0),pm),'r.')

%% trending partners

mm=2
pm=5
thr=std(mrna(abs(mrna(:,mm))>0&abs(mrna(:,pm))>0,mm)-mrna(abs(mrna(:,mm))>0&abs(mrna(:,pm))>0,pm))/10
sum(abs(mrna(:,mm))-abs(mrna(:,pm))<thr)
plot(mrna((mrna(:,mm)>thr&mrna(:,pm)>thr|mrna(:,mm)<thr&mrna(:,pm)<thr),mm),mrna((mrna(:,mm)>thr&mrna(:,pm)>thr|mrna(:,mm)<thr&mrna(:,pm)<thr),pm),'r.')


