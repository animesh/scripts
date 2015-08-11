%% load data
load('/media/DATA/documents/courses_uib/bmed360/presentation/svm_mat555.mat');
[s v t]=size(svm_mat);
sn=Design_Para(:,6)';
mn=Design_Para(:,4)';
corrcoef(mn,sn)
crosscorr(mn,sn)
autocorr(mn)
autocorr(sn)
for i = 1:size(svm_mat,1)
    for j = 1:size(svm_mat,3)
    svm_mat_norm(i,:,j)=mat2gray(svm_mat(i,:,j));
    svm_mat_std(i,:,j)=(svm_mat(i,:,j)-mean(svm_mat(i,:,j)))/std(svm_mat(i,:,j));
    end
end
clear ind*;
clear Des*;

%% mean 
voxmean_std=reshape(mean(svm_mat_std(:,:,:)),v,t);
for i = 1:size(voxmean_std,1)
    [tmpccv,tmpccp]=corrcoef(voxmean_std(i,:),sn(:));
    voxmean_stdWsnV(i)=tmpccv(2,1);
    voxmean_stdWsnP(i)=tmpccp(2,1);
end

%% median
voxmedian_norm=reshape(median(svm_mat_norm(:,:,:)),v,t);
for i = 1:size(voxmedian_norm,1)
    [tmpccv,tmpccp]=corrcoef(voxmedian_norm(i,:),mn(:));
    voxmedian_normWmnV(i)=tmpccv(2,1);
    voxmedian_normWmnP(i)=tmpccp(2,1);
end

%% Voxel ED
vxcrds=load('voxcoords.csv');

%% ED

voxmean_std_cc=corrcoef(voxmean_std');
ccDvoxmean_std = pdist(voxmean_std,'correlation');
voxmedian_norm_cc=corrcoef(voxmedian_norm');
ccDvoxmedian_norm = pdist(voxmedian_norm,'correlation');
edVox=pdist(vxcrds);

mhVox=pdist(vxcrds,'mahalanobis');
voxmedian_norm_cc(1,2)
ccDvoxmedian_norm(1)
voxmean_std_cc(1,2)
11965*13
for i=6:160
    j=0.1;
    ccr=sum(edVox(((ccDvoxmean_std(1,:)<j)|(ccDvoxmean_std(1,:)>(2-j)))&(edVox(1,:)<i)))/sum(edVox(edVox(1,:)<i))
    ccratio(i)=ccr;
end
hist(edVox((ccDvoxmean_std(1,:)>0.15)&(ccDvoxmean_std(1,:)<0.25)|(ccDvoxmean_std(1,:)<1.85)&(ccDvoxmean_std(1,:)>1.75)))
sum(edVox((ccDvoxmean_std(1,:)>0.15)&(ccDvoxmean_std(1,:)<0.25)|(ccDvoxmean_std(1,:)<1.85)&(ccDvoxmean_std(1,:)>1.75)))
%mhVoxSF=squareform(mhVox);
%edVoxSF=squareform(edVox);
%plot(edVox,voxmean_ccd,'r');


%plot(squeeze(svm_mat(1,1,:)),squeeze(svm_mat(4,1,:)),'r.')


%% sbbf eval

mnsebf = load('mnsebf')
snsebf = load('snsebf')
P_in=    
[voxcoords] = svm2mni('svm_mat555.mat', mnsebf);
[voxcoords] = svm2mni('svm_mat555.mat', snsebf);


%% acorr
voxxa=load('voxmean_std_auto.csv');
voxxcidx=load('voxmean_std_cidx.csv');
voxxcval=load('voxmean_std_cval.csv');
voxxcidx(11965,:)=0;
voxxcval(11965,:)=0;
whos voxxa
voxxcidx=squareform(voxxcidx+voxxcidx');
voxxcval=squareform(voxxcval+voxxcval');
hist(voxxcval);
edVox;
smoothhist2d([voxxcidx(1,:)',voxxcval(1,:)'],2,[100,100])
smoothhist2d([edVox(1,:)',voxxcval(1,:)'],2,[100,100])
smoothhist2d([edVox(1,:)',voxxcidx(1,:)'],2,[100,100])
hist(edVox((voxxcval(1,:)>=0.999)&(voxxcval(1,:)<1)))
find(voxxcidx(:,:)==732)
spy(voxxcval)
max(max(voxxcval))
[voxxcvalrow,voxxcvalcol]=find(voxxcval(:,:)<1);
11965*11965
voxxacc=pdist(voxxa,'correlation');
plot(voxxa(11366,:),'g.')
hold
ur=unique(colacc)
max(ccDvoxmean_std)
[edVox(1,1:10)',ccDvoxmean_std(1,1:10)']
smoothhist2d([edVox(1,:)',ccDvoxmean_std(1,:)'],2,[100,100])
plot([edVox(1,:),ccDvoxmean_std(1,:)],'g.')
scatter(edVox(1,1:100000)',ccDvoxmean_std(1,1:100000)')

X = [mvnrnd([0 5], [3 0; 0 3], 2000);
            mvnrnd([0 8], [1 0; 0 5], 2000);
            mvnrnd([3 5], [5 0; 0 1], 2000)];
       smoothhist2D(X,5,[100, 100],.05);

       X

%% plot vox
for i=46
    ur(i)    
    plot(voxxa(ur(i),:),'r.')
    [voxcoords] = svm2mni('svm_mat555.mat', i);
end

%% plot
[c,l]=xcorr(squeeze(svm_mat(15,11366,:)),'coeff');
stem(l,c);
%plot(squeeze(svm_mat(1,1366,:)),'g')


%% voxxacc
hold off
voxxacc=squareform(voxxacc);
[val,idx]=max(max(voxxacc))
[rowacc, colacc]=find(voxxacc(:,:)>=0.95)
whos rowacc
whos colacc
unique(rowacc)
colacc(1)


%% xcorr
voxxc=load('voxmean_std_cval.csv');
whos row*
whos col*
whos voxxc

(11965*11964)^(1/3)

[rown, coln]=find((voxxc(:,:)<1));
[row1, col1]=find((voxxc(:,:)==1));
[rowm, colm]=find((voxxc(:,:)>1));

plot(sn+mn,'r.')

%% save file
%save('a.txt','a','-ascii','-tabs');

%% run perl
%system('perl tab2csv.pl a.txt.csv');

%% run weka
%system('export CLASSPCLASSPATHATH=$CLASSPATH:/media/DATA');
%setenv('CLASSPATH', '/media/DATA' );
%system('java weka.classifiers.functions.MultilayerPerceptron -t a.txt.csv');

%publish;

