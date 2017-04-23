%% random 2 class m/z cps

mzv=100;
sample_size=100;
sn=sample_size;
st=sample_size/2;

MZn=randi([400 2000],mzv ,1);
CPSn=randi([0 100],sn,mzv);
stem(MZn,CPSn(sn,:),'g')
class0=zeros(sn,1)

hold
MZt=randi([400 2000],mzv,1);
CPSt=randi([0 100],st,mzv);
stem(MZt,CPSt(st,:),'y')
class1=zeros(st,1)+1
hold

[feat,stat] = rankfeatures([CPSn;CPSt]',[class0; class1],'CRITERION','entropy','NUMBER',5);
feat

%% polynomial fitting

[p,p_struct,mu] = polyfit((ts(i)+tg(j))/2,ts(i)-tg(j),20);
sf = @(z) polyval(p,(z-mu(1))./mu(2));
figure(fh6)
plot(tg,sf(tg),'r')


%% align reduce warp effect

samplealign(sort(CPSn),sort(CPSt))



%% LDA

Y=[CPSn;CPSt]';
grp=[class0; class1];
per_eval = 0.10;  
rand('twister',0);
cv  = cvpartition(grp,'holdout',per_eval)

cp_lda1 = classperf(grp); 
for k=1:10 
    cv = repartition(cv);
    feat = rankfeatures(Y(:,training(cv)),grp(training(cv)),'NUMBER',100);
    c = classify(Y(feat,test(cv))',Y(feat,training(cv))',grp(training(cv)));
    classperf(cp_lda1,c,test(cv)); 
end

cp_lda1

%% LDA 2

cp_lda2 = classperf(grp); 
for k=1:10 
    cv = repartition(cv);
    feat = rankfeatures(Y(:,training(cv)),grp(training(cv)),'NUMBER',100,'NWEIGHT',5);
    c = classify(Y(feat,test(cv))',Y(feat,training(cv))',grp(training(cv)));
    classperf(cp_lda2,c,test(cv));
end
cp_lda2.CorrectRate

%% PCA

cp_pcalda = classperf(grp); 
for k=1:10 
    cv = repartition(cv);
    feat = rankfeatures(Y(:,training(cv)),grp(training(cv)),'NUMBER',1000);
    P = princomp(Y(feat,training(cv))');
    x = Y(feat,:)' * P(:,1:100);
    c = classify(x(test(cv),:),x(training(cv),:),grp(training(cv)));
    classperf(cp_pcalda,c,test(cv));
end
cp_pcalda.CorrectRate


%% random search for optimal feature sub set

cv = repartition(cv);
[feat,fCount] = randfeatures(Y(:,training(cv)),grp(training(cv)),'CLASSIFIER','da','PerformanceThreshold',0.50);
hist(fCount,max(fCount)+1);

nSig = sum(fCount>10);
for i = 1:nSig
    for j = 1:10
        cv = repartition(cv);
        P = princomp(Y(feat(1:i),training(cv))');
        x = Y(feat(1:i),:)' * P;
        c = classify(x(test(cv),:),x(training(cv),:),grp(training(cv)));
        cp = classperf(grp,c,test(cv));
        cp_rndfeat(j,i) = cp.CorrectRate;
    end
end
figure
plot(1:nSig, [max(cp_rndfeat);mean(cp_rndfeat)]);
legend({'Best CorrectRate','Mean CorrectRate'},4)

%% best feature plot

[bestAverageCR, bestNumFeatures] = max(mean(cp_rndfeat));
figure; hold on;
sigFeats = fCount;
sigFeats(sigFeats<=10) = 0;
ax_handle = plot(MZ,[mean_N mean_C]);
stem(MZ(feat(1:bestNumFeatures)),sigFeats(feat(1:bestNumFeatures)),'r');
axis([7650,8850,-1,80])
legend({'Control Group Avg.','Ovarian Cancer Group Avg.','Significant Features'})
xlabel(xAxisLabel); ylabel(yAxisLabel);


%% Oribitrap RAW to MZXML conversion
uf-mzxml Obb01926.RAW > Obb01926.MZXML
uf-mzxml Obb01937.RAW > Obb01937.MZXML
 
%% read into matlab structure

%MG132_3 = mzxmlread('M:\RAW\Lars\130107_MG132_3_HCD.mzXML');
Obb01926=mzxmlread('M:\RAW\melfalan0hr\Obb01926.MZXML')
Obb01937=mzxmlread('M:\RAW\melfalan0hr\Obb01937.MZXML')
Obb01937=mzxmlread('X:\Elite\Alexey\HCD\SIM66_Elite_HCD.mzXML')

mohd=mzxmlread('L:\Qexactive\MohmD\LCR_tarLiverProteins_microWave_140224201741.mzXML')

mohd=xlsread('L:\Qexactive\MohmD\MS2ScanRawMeat.xls')
hist(ms2(:,2),[240*60])
hist(ms2(:,7),[100])
ms2=xlsread('L:\Qexactive\MohmD\FullScanRawMeat.xls')

plot(ms2(:,2),ms2(:,7))
hist(ms2(:,7))
hist(ms2(:,2),[10000])


%% 

[MZs,Ys] = msheatmap(msppresample(mzxml2peaks(Obb01937,'level',1),5000))
plot(Ys,'r.')
%fh1 = msheatmap(MZs,Ys)
plot(MZs,'r.')
plot(Ys,'r.')

proteinpropplot('EKMRHF')
proteinplot('EKMRHF')

%% hist color

hist(randn(100,1))
hold
hist(randn(100,1))
h = findobj(gca,'Type','patch')
display(h)
set(h(1),'FaceColor','y','EdgeColor','k','facealpha',0.75);
set(h(2),'FaceColor','b','EdgeColor','k','facealpha',0.5);
hold

%% source

http://www.mathworks.se/help/bioinfo/examples/identifying-significant-features-and-classifying-protein-profiles.html
http://www.mathworks.se/help/bioinfo/examples/differential-analysis-of-complex-protein-and-metabolite-mixtures-using-liquid-chromatography-mass-spectrometry-lc-ms.html