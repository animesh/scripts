%% read
data=mzxmlread('F:\promec\Davi\_QE\BSAs\20150512_BSA_The-PEG-envelope.mzXML');
pkl=csvread('F:\promec\Davi\_QE\BSAs\20150512_BSA_The-PEG-envelope.pkl')

%% plot
pkli=pkl(pkl(:,2)>100000,:)
scatter(pkli(:,1),log(pkli(:,2)))
hist(pkli(:,1))
hist(log(pkli(:,2)))
pdpkl=pdist(pkl(:,1));
[nelements,centers]=hist(pdpkl,[1000000]);
[nelements2,centers2]=hist((centers(nelements>10000)),[100])
hist((centers2(nelements2>0)),[100])
pdpklsf=squareform(pdpkl);
spy(pdpklsf)


%% extract peaks
[pks, rt]= mzxml2peaks(data,'Levels', 1)

%% plot against retention time
msdotplot(pks, rt,'Quantile',0.8)
[MZ,Y] = msppresample(ms_peaks,5000)
msheatmap(MZ,ret_time,log(Y))

%% overlay
msdotplot(ms_peaks,ret_time)
axis([480 532 375 485])