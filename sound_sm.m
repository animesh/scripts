%% load data
load('svm_mat555');
[s v t]=size(svm_mat);
sn=Design_Para(:,6)';
mn=Design_Para(:,4)';
corrcoef(mn,sn)
crosscorr(mn,sn)
autocorr(mn)
autocorr(sn)
for i = 1:size(svm_mat,1)
    for j = 1:size(svm_mat,3)
    %svm_mat_norm(i,:,j)=mat2gray(svm_mat(i,:,j));
    svm_mat_std(i,:,j)=(svm_mat(i,:,j)-mean(svm_mat(i,:,j)))/std(svm_mat(i,:,j));
    end
end


%% mode
voxmode=reshape(mode(svm_mat(:,:,:)),v,t);
voxmode_std=reshape(mode(svm_mat_std(:,:,:)),v,t);
voxmode_norm=reshape(mode(svm_mat_norm(:,:,:)),v,t);
for i = 1:size(voxmode,1)
    [tmpccv,tmpccp]=corrcoef(voxmode(i,:),sn(:));
    voxmodeWsnV(i)=tmpccv(2,1);
    voxmodeWsnP(i)=tmpccp(2,1);
    [tmpccv,tmpccp]=corrcoef(voxmode(i,:),mn(:));
    voxmodeWmnV(i)=tmpccv(2,1);
    voxmodeWmnP(i)=tmpccp(2,1);
    [tmpccv,tmpccp]=corrcoef(voxmode_std(i,:),sn(:));
    voxmode_stdWsnV(i)=tmpccv(2,1);
    voxmode_stdWsnP(i)=tmpccp(2,1);
    [tmpccv,tmpccp]=corrcoef(voxmode_std(i,:),mn(:));
    voxmode_stdWmnV(i)=tmpccv(2,1);
    voxmode_stdWmnP(i)=tmpccp(2,1);
    [tmpccv,tmpccp]=corrcoef(voxmode_norm(i,:),sn(:));
    voxmode_normWsnV(i)=tmpccv(2,1);
    voxmode_normWsnP(i)=tmpccp(2,1);
    [tmpccv,tmpccp]=corrcoef(voxmode_norm(i,:),mn(:));
    voxmode_normWmnV(i)=tmpccv(2,1);
    voxmode_normWmnP(i)=tmpccp(2,1);
end
max(voxmodeWsnV)
min(voxmodeWsnP)
max(voxmodeWmnV)
min(voxmodeWmnP)
max(voxmode_stdWsnV)
min(voxmode_stdWsnP)
max(voxmode_stdWmnV)
min(voxmode_stdWmnP)
max(voxmode_normWsnV)
min(voxmode_normWsnP)
max(voxmode_normWmnV)
min(voxmode_normWmnP)

%% mean 
voxmean=reshape(mean(svm_mat(:,:,:)),v,t);
voxmean_std=reshape(mean(svm_mat_std(:,:,:)),v,t);
voxmean_norm=reshape(mean(svm_mat_norm(:,:,:)),v,t);
for i = 1:size(voxmean,1)
    [tmpccv,tmpccp]=corrcoef(voxmean(i,:),sn(:));
    voxmeanWsnV(i)=tmpccv(2,1);
    voxmeanWsnP(i)=tmpccp(2,1);
    [tmpccv,tmpccp]=corrcoef(voxmean(i,:),mn(:));
    voxmeanWmnV(i)=tmpccv(2,1);
    voxmeanWmnP(i)=tmpccp(2,1);
    [tmpccv,tmpccp]=corrcoef(voxmean_std(i,:),sn(:));
    voxmean_stdWsnV(i)=tmpccv(2,1);
    voxmean_stdWsnP(i)=tmpccp(2,1);
    [tmpccv,tmpccp]=corrcoef(voxmean_std(i,:),mn(:));
    voxmean_stdWmnV(i)=tmpccv(2,1);
    voxmean_stdWmnP(i)=tmpccp(2,1);
    [tmpccv,tmpccp]=corrcoef(voxmean_norm(i,:),sn(:));
    voxmean_normWsnV(i)=tmpccv(2,1);
    voxmean_normWsnP(i)=tmpccp(2,1);
    [tmpccv,tmpccp]=corrcoef(voxmean_norm(i,:),mn(:));
    voxmean_normWmnV(i)=tmpccv(2,1);
    voxmean_normWmnP(i)=tmpccp(2,1);
end
max(voxmeanWsnV)
min(voxmeanWsnP)
max(voxmeanWmnV)
min(voxmeanWmnP)
max(voxmean_stdWsnV)
min(voxmean_stdWsnP)
max(voxmean_stdWmnV)
min(voxmean_stdWmnP)
max(voxmean_normWsnV)
min(voxmean_normWsnP)
max(voxmean_normWmnV)
min(voxmean_normWmnP)

%% median
voxmedian=reshape(median(svm_mat(:,:,:)),v,t);
voxmedian_std=reshape(median(svm_mat_std(:,:,:)),v,t);
voxmedian_norm=reshape(median(svm_mat_norm(:,:,:)),v,t);
for i = 1:size(voxmedian,1)
    [tmpccv,tmpccp]=corrcoef(voxmedian(i,:),sn(:));
    voxmedianWsnV(i)=tmpccv(2,1);
    voxmedianWsnP(i)=tmpccp(2,1);
    [tmpccv,tmpccp]=corrcoef(voxmedian(i,:),mn(:));
    voxmedianWmnV(i)=tmpccv(2,1);
    voxmedianWmnP(i)=tmpccp(2,1);
    [tmpccv,tmpccp]=corrcoef(voxmedian_std(i,:),sn(:));
    voxmedian_stdWsnV(i)=tmpccv(2,1);
    voxmedian_stdWsnP(i)=tmpccp(2,1);
    [tmpccv,tmpccp]=corrcoef(voxmedian_std(i,:),mn(:));
    voxmedian_stdWmnV(i)=tmpccv(2,1);
    voxmedian_stdWmnP(i)=tmpccp(2,1);
    [tmpccv,tmpccp]=corrcoef(voxmedian_norm(i,:),sn(:));
    voxmedian_normWsnV(i)=tmpccv(2,1);
    voxmedian_normWsnP(i)=tmpccp(2,1);
    [tmpccv,tmpccp]=corrcoef(voxmedian_norm(i,:),mn(:));
    voxmedian_normWmnV(i)=tmpccv(2,1);
    voxmedian_normWmnP(i)=tmpccp(2,1);
end
max(voxmedianWsnV)
min(voxmedianWsnP)
max(voxmedianWmnV)
min(voxmedianWmnP)
max(voxmedian_stdWsnV)
min(voxmedian_stdWsnP)
max(voxmedian_stdWmnV)
min(voxmedian_stdWmnP)
max(voxmedian_normWsnV)
min(voxmedian_normWsnP)
max(voxmedian_normWmnV)
min(voxmedian_normWmnP)

%% Voxel ED
for i=1:v
    [voxcoords] = svm2mni(P_in, i);
    vxcrds(i,1)=voxcoords.XYZmm(1);
    vxcrds(i,2)=voxcoords.XYZmm(2);
    vxcrds(i,3)=voxcoords.XYZmm(3);
end

%% ED

load('svm_mat555_cords.mat');
edVox=pdist(vxcrds);
voxmean_std_cc=corrcoef(voxmean_std);
mhVox=pdist(vxcrds,'mahalanobis',voxmean_std_cc);
mhVoxSF=squareform(mhVox);
edVoxSF=squareform(edVox);
voxmean_ccd = pdist(voxmean_std,'correlation');
plot(edVox,voxmean_ccd,'r');


%% coherence
for i=1:4
    for j=i+1:4
        i, j
    [c_ww,lags] = xcorr(voxmean_std(i,:),voxmean_std(j,:),'coeff');
    stem(lags,c_ww)
    %whos c_ww
    %whos lags
    [val,idx]=max(c_ww)
    end
end
[c_ww,lags] = crosscorr(voxmean_std(3,:),voxmean_std(100,:))
    stem(lags,c_ww)

    x=0:0.01:10;
X = sin(x);
[r,lags]=xcorr(X,'coeff');  
max(r)
ww = randn(1000,1)
[c_ww,lags] = xcorr(ww,10,'coeff');
stem(lags,c_ww)
hist(ww)
cosD=cos(-2*pi:0.1:2*pi);
sinD=sin(-2*pi:0.1:2*pi);
cosD=cos(1:100);
sinD=sin(1:100);
plot(cosD);
[c_ww,lags] = xcorr(sinD,'coeff')
stem(lags,c_ww)
whos c_ww
whos lags
[val,idx]=max(c_ww)
cosD(15)
corrcoef(cosD(15:100),sinD(1:86))

voxmean_xc=xcorr(voxmean','coeff');
xcross(voxmean_std(1,:),voxmean_std(1,:));
voxmean_xc=xcorr(voxmean','coeff');
voxmean_xc=xcorr(voxmean,'coeff');

%% tmp
%plot(voxmedres(1,:),voxmeanres(1,:),'r.');
corrcoef(voxmedres(1,:),voxmeanres(1,:))
corrcoef(voxmedres(1,:),voxmodres(1,:))
corrcoef(voxmodres(1,:),voxmeanres(1,:))

plot(voxmedres(1,:),voxmeanres(1,:));


load('svm_mat555');
%-- 3/30/11 10:55 PM --%
edit sound.m
edit sound_sm.m
voxmeanres=reshape(mean(svm_mat(:,:,:)),v,t);
voxmodres=reshape(mode(svm_mat(:,:,:)),v,t);
hist(rand(100))
hist(rand(100,1))
hist(rand(10000,1))
hist(randn(10000,1))
hist(svm_mat(:,1,:));
hist(svm_mat(:,2,:));
voxmodres(1,:)
hist(voxmodres(1,:))
hist(voxmodres(2,:))
hist(voxmodres(3,:))
hist(voxmedres(3,:))
hist(voxmeanres(3,:))
hist(voxmedres(3,:))
hist(voxmodres(3,:))
hist(svm_mat(:,2,:));
hist(svm_mat(:,2,:)-min(svm_mat(:,2,:)));
hist(svm_mat(:,2,:).-min(svm_mat(:,2,:)));
hist(svm_mat(:,2,:)-.min(svm_mat(:,2,:)));
min(svm_mat(:,2,:))
hist(svm_mat(:,2,:)-min(svm_mat(:,2,:)));
(svm_mat(:,2,:)-min(svm_mat(:,2,:)));
z=min(svm_mat(:,2,:))
whos
(svm_mat(:,2,:)-min(svm_mat(:,2,:)));
hist(svm_mat(:,2,:));
hist(mat2gray(svm_mat(:,2,:)));
hist(svm_mat(:,2,:));
hist(mat2gray(svm_mat(:,2,:)));
hist(mat2gray(svm_mat(:,:,:)));
%-- 3/31/11 10:21 AM --%
cd export/sp
cd export/speech/
size(voxmodres,1)
size(voxmodres)
size(Design_Events)
size(Design_Events,1)
size(Design_Events,2)
zeros(size(Design_Events,2))
zeros(1,size(Design_Events,2))
zeros(1,size(voxmodres,1));
zeros(size(voxmodres,1),1);
for i = 1:size(voxmodres,1)
voxmodreswsn(i)=corrcoef(voxmodres(i,:),sn);
end
for i = 1:size(voxmodres,1)
voxmodreswsn(i)=corrcoef(voxmodres(i,:),sn(:));
end
tmpcc=corrcoef(voxmodres(i,:),sn(:));
whos
tmpcc(2,1)
tmpcc(1,2)
[tmpccv,tmpccs]=corrcoef(voxmodres(i,:),sn(:));
tmpccv(1,2)
tmpccs(1,2)
tmpccs(2,1)
for i = 1:size(voxmodres,1)
[tmpccv,tmpccp]=corrcoef(voxmodres(i,:),sn(:));
voxmodreswsnv(i)=tmpccv(2,1);
voxmodreswsnp(i)=tmpccp(2,1);
end
whos
max(voxmodreswsnv)
max(voxmodreswsnp)
voxmedreswsnv=zeros(size(voxmedres,1),1);
voxmedreswsnp=zeros(size(voxmedres,1),1);
for i = 1:size(voxmedres,1)
[tmpccv,tmpccp]=corrcoef(voxmedres(i,:),sn(:));
voxmedreswsnv(i)=tmpccv(2,1);
voxmedreswsnp(i)=tmpccp(2,1);
end
max(voxmedreswsnv)
max(voxmedreswsnp)
voxmeanreswsnv=zeros(size(voxmeanres,1),1);
voxmeanreswsnp=zeros(size(voxmeanres,1),1);
for i = 1:size(voxmeanres,1)
[tmpccv,tmpccp]=corrcoef(voxmeanres(i,:),sn(:));
voxmeanreswsnv(i)=tmpccv(2,1);
voxmeanreswsnp(i)=tmpccp(2,1);
end
max(voxmeanreswsnv)
max(voxmeanreswsnp)
min(voxmeanreswsnp)
[val idx]=min(voxmeanreswsnp)
voxmeanreswsnv(min(voxmeanreswsnp))
voxmeanreswsnv(2646)
plot(svm_mat(:,1,:),'r.')
svm_mat(:,1,:)
svm_mat(:,1,:);
plot(svm_mat(:,1,1),'r.')
plot(mn,sn,'r.')
axis
axis balance
help axis
axis qual
axis equal
corrcoef(mn,sn)
crosscorr(mn,sn)
autocorr(mn,sn)
autocorr(mn)
autocorr(sn)
s=sin(1:100);
[s v t]=size(svm_mat);
autocorr(sin(1:100),cos(1:100))
autocorr(sin(1:100))
autocorr(sin(-2*pi:2*pi))
autocorr(sin(-4*pi:4*pi))
autocorr(sin(1:100),cos(1:100))
crosscorr(sin(1:100),cos(1:100))
autocorr(sin(-100*pi:100*pi))
help xcorr
help crosscorr
crosscorr(mn,sn)
xcorr(mn,sn)
max(abs(xcorr(mn,sn)))
min(abs(xcorr(mn,sn)))
axis equal
min(abs(xcorr(mn,sn)))
crosscorr(mn,sn)
crosscorr(svm_mat(1,:,1),svm_mat(2,:,1))
autocorr(svm_mat(1,:,1))
svm_mat(1,:,1)
autocorr(svm_mat(1,1,:))
crosscorr(svm_mat(1,1,:),svm_mat(2,1,:))
max(voxmedreswsnv)
max(voxmodreswsnv)
max(voxmeanreswsnv)
[val idx]=max(voxmeanreswsnv)
plot(voxmeanres(2646,:),sn(:))
plot(voxmeanres(2646,:),sn(:),'r.')
plot(voxmeanres(2646,:),mn(:),'r.')
corrcoef(voxmeanres(2646,:),mn(:))
svm_mat(1,1,1)
t11=svm_mat(1,:,1)
mat2gray(t11)
t11m2g=mat2gray(t11)
hist(t11)
hist(t11m2g)
t11=mat2gray(svm_mat(1,:,1))
hist(t11m2g)
hist(t11)
ls
for i = 1:size(svm_mat,1)
for j = 1:size(svm_mat,3)
svm_mat_norm(i,:,j)=mat2gray(svm_mat(i,:,j));
end
end
hist(svm_mat(1,:,1))
hist(svm_mat_norm(1,:,1))
hist(svm_mat_norm(:,1,1))
hist(svm_mat(:,1,1))
hist(svm_mat_norm(:,1,1))
median(svm_mat_norm(:,1,1))
median(svm_mat(:,1,1))
mode(svm_mat_norm(:,1,1))
median(svm_mat(:,1,1))
median(svm_mat_norm(:,1,1))
mean(svm_mat_norm(:,1,1))
mode(svm_mat_norm(:,1,1))
corrcoef(svm_mat_norm(1,:,1),svm_mat_norm(2,:,1))
corrcoef(svm_mat(1,:,1),svm_mat(2,:,1))
corrcoef(svm_mat_norm(1,1,:),svm_mat_norm(2,1,:))
corrcoef(svm_mat(1,1,:),svm_mat(2,1,:))
corrcoef(svm_mat(1,:,1),svm_mat(2,:,1))
corrcoef(svm_mat(1,:,1),svm_mat(3,:,1))
corrcoef(svm_mat(1,:,1),svm_mat(4,:,1))
plot(svm_mat(1,:,1),svm_mat(4,:,1))
plot(svm_mat(1,:,1),svm_mat(4,:,1),'r.')
plot(svm_mat(1,1,:),svm_mat(4,1,:),'r.')
corrcoef(svm_mat(1,1,:),svm_mat(4,1,:))
corrcoef(svm_mat(1,1,:),svm_mat_norm(4,1,:))
corrcoef(svm_mat_norm(1,1,:),svm_mat_norm(4,1,:))
plot(svm_mat_norm(1,1,:),svm_mat_norm(4,1,:))
svm_mat_norm(4,1,:)
plot(squeeze(svm_mat_norm(1,1,:)),squeeze(svm_mat_norm(4,1,:)))
plot(squeeze(svm_mat_norm(1,1,:)),squeeze(svm_mat_norm(4,1,:)),'r.')
plot(squeeze(svm_mat(1,1,:)),squeeze(svm_mat(4,1,:)),'r.')
plot(squeeze(svm_mat_norm(1,1,:)),squeeze(svm_mat_norm(4,1,:)),'r.')
help mat2gray
plot(squeeze(svm_mat_norm(1,1,:)),squeeze(svm_mat_norm(4,1,:)),'r.')
plot(squeeze(svm_mat(1,1,:)),squeeze(svm_mat(4,1,:)),'r.')
(svm_mat(i,:,j)-mean(svm_mat(i,:,j)))/std(svm_mat(i,:,j))
for i = 1:size(svm_mat,1)
for j = 1:size(svm_mat,3)
svm_mat_norm(i,:,j)=mat2gray(svm_mat(i,:,j));
svm_mat_std(i,:,j)=(svm_mat(i,:,j)-mean(svm_mat(i,:,j)))/std(svm_mat(i,:,j));
end
end
plot(squeeze(svm_mat_std(1,1,:)),squeeze(svm_mat_std(4,1,:)),'r.')
plot(squeeze(svm_mat_std(1,1,:)),squeeze(svm_mat_std(2,1,:)),'r.')
plot(squeeze(svm_mat_std(1,1,:)),squeeze(svm_mat_std(3,1,:)),'r.')
corrcoef(svm_mat_std(1,1,:)),squeeze(svm_mat_std(4,1,:)))
corrcoef(svm_mat_std(1,1,:)),squeeze(svm_mat_std(4,1,:))
corrcoef(svm_mat_std(1,1,:),svm_mat_std(4,1,:))
corrcoef(svm_mat_std(1,1,:),svm_mat_norm(4,1,:))
corrcoef(svm_mat_std(1,1,:),svm_mat_norm(2,1,:))
corrcoef(svm_mat_norm(1,1,:),svm_mat_norm(2,1,:))
corrcoef(svm_mat(1,1,:),svm_mat(2,1,:))
corrcoef(svm_mat_std(1,1,:),svm_mat_std(2,1,:))
voxmode=reshape(mode(svm_mat(:,:,:)),v,t);
voxmode_std=reshape(mode(svm_mat_std(:,:,:)),v,t);
voxmode_norm=reshape(mode(svm_mat_norm(:,:,:)),v,t);
for i = 1:size(voxmode,1)
[tmpccv,tmpccp]=corrcoef(voxmode(i,:),sn(:));
voxmodeWsnV(i)=tmpccv(2,1);
voxmodeWsnP(i)=tmpccp(2,1);
[tmpccv,tmpccp]=corrcoef(voxmode(i,:),mn(:));
voxmodeWmnV(i)=tmpccv(2,1);
voxmodeWmnP(i)=tmpccp(2,1);
end
max(voxmodeWsnV)
min(voxmodeWsnP)
max(voxmodeWmnV)
min(voxmodeWmnP)
voxmode=reshape(mode(svm_mat(:,:,:)),v,t);
voxmode_std=reshape(mode(svm_mat_std(:,:,:)),v,t);
voxmode_norm=reshape(mode(svm_mat_norm(:,:,:)),v,t);
for i = 1:size(voxmode,1)
[tmpccv,tmpccp]=corrcoef(voxmode(i,:),sn(:));
voxmodeWsnV(i)=tmpccv(2,1);
voxmodeWsnP(i)=tmpccp(2,1);
[tmpccv,tmpccp]=corrcoef(voxmode(i,:),mn(:));
voxmodeWmnV(i)=tmpccv(2,1);
voxmodeWmnP(i)=tmpccp(2,1);
[tmpccv,tmpccp]=corrcoef(voxmode_std(i,:),sn(:));
voxmode_stdWsnV(i)=tmpccv(2,1);
voxmode_stdWsnP(i)=tmpccp(2,1);
[tmpccv,tmpccp]=corrcoef(voxmode_std(i,:),mn(:));
voxmode_stdWmnV(i)=tmpccv(2,1);
voxmode_stdWmnP(i)=tmpccp(2,1);
[tmpccv,tmpccp]=corrcoef(voxmode_norm(i,:),sn(:));
voxmode_normWsnV(i)=tmpccv(2,1);
voxmode_normWsnP(i)=tmpccp(2,1);
[tmpccv,tmpccp]=corrcoef(voxmode_norm(i,:),mn(:));
voxmode_normWmnV(i)=tmpccv(2,1);
voxmode_normWmnP(i)=tmpccp(2,1);
end
max(voxmodeWsnV)
min(voxmodeWsnP)
max(voxmodeWmnV)
min(voxmodeWmnP)
max(voxmode_stdWsnV)
min(voxmode_stdWsnP)
max(voxmode_stdWmnV)
min(voxmode_stdWmnP)
max(voxmode_normWsnV)
min(voxmode_normWsnP)
max(voxmode_normWmnV)
min(voxmode_normWmnP)
voxmean=reshape(mean(svm_mat(:,:,:)),v,t);
voxmean_std=reshape(mean(svm_mat_std(:,:,:)),v,t);
voxmean_norm=reshape(mean(svm_mat_norm(:,:,:)),v,t);
for i = 1:size(voxmean,1)
[tmpccv,tmpccp]=corrcoef(voxmean(i,:),sn(:));
voxmeanWsnV(i)=tmpccv(2,1);
voxmeanWsnP(i)=tmpccp(2,1);
[tmpccv,tmpccp]=corrcoef(voxmean(i,:),mn(:));
voxmeanWmnV(i)=tmpccv(2,1);
voxmeanWmnP(i)=tmpccp(2,1);
[tmpccv,tmpccp]=corrcoef(voxmean_std(i,:),sn(:));
voxmean_stdWsnV(i)=tmpccv(2,1);
voxmean_stdWsnP(i)=tmpccp(2,1);
[tmpccv,tmpccp]=corrcoef(voxmean_std(i,:),mn(:));
voxmean_stdWmnV(i)=tmpccv(2,1);
voxmean_stdWmnP(i)=tmpccp(2,1);
[tmpccv,tmpccp]=corrcoef(voxmean_norm(i,:),sn(:));
voxmean_normWsnV(i)=tmpccv(2,1);
voxmean_normWsnP(i)=tmpccp(2,1);
[tmpccv,tmpccp]=corrcoef(voxmean_norm(i,:),mn(:));
voxmean_normWmnV(i)=tmpccv(2,1);
voxmean_normWmnP(i)=tmpccp(2,1);
end
max(voxmeanWsnV)
min(voxmeanWsnP)
max(voxmeanWmnV)
min(voxmeanWmnP)
max(voxmean_stdWsnV)
min(voxmean_stdWsnP)
max(voxmean_stdWmnV)
min(voxmean_stdWmnP)
max(voxmean_normWsnV)
min(voxmean_normWsnP)
max(voxmean_normWmnV)
min(voxmean_normWmnP)
voxmode=reshape(mode(svm_mat(:,:,:)),v,t);
voxmode_std=reshape(mode(svm_mat_std(:,:,:)),v,t);
voxmode_norm=reshape(mode(svm_mat_norm(:,:,:)),v,t);
for i = 1:size(voxmode,1)
[tmpccv,tmpccp]=corrcoef(voxmode(i,:),sn(:));
voxmodeWsnV(i)=tmpccv(2,1);
voxmodeWsnP(i)=tmpccp(2,1);
[tmpccv,tmpccp]=corrcoef(voxmode(i,:),mn(:));
voxmodeWmnV(i)=tmpccv(2,1);
voxmodeWmnP(i)=tmpccp(2,1);
[tmpccv,tmpccp]=corrcoef(voxmode_std(i,:),sn(:));
voxmode_stdWsnV(i)=tmpccv(2,1);
voxmode_stdWsnP(i)=tmpccp(2,1);
[tmpccv,tmpccp]=corrcoef(voxmode_std(i,:),mn(:));
voxmode_stdWmnV(i)=tmpccv(2,1);
voxmode_stdWmnP(i)=tmpccp(2,1);
[tmpccv,tmpccp]=corrcoef(voxmode_norm(i,:),sn(:));
voxmode_normWsnV(i)=tmpccv(2,1);
voxmode_normWsnP(i)=tmpccp(2,1);
[tmpccv,tmpccp]=corrcoef(voxmode_norm(i,:),mn(:));
voxmode_normWmnV(i)=tmpccv(2,1);
voxmode_normWmnP(i)=tmpccp(2,1);
end
max(voxmodeWsnV)
min(voxmodeWsnP)
max(voxmodeWmnV)
min(voxmodeWmnP)
max(voxmode_stdWsnV)
min(voxmode_stdWsnP)
max(voxmode_stdWmnV)
min(voxmode_stdWmnP)
max(voxmode_normWsnV)
min(voxmode_normWsnP)
max(voxmode_normWmnV)
min(voxmode_normWmnP)
max(voxmedian_normWmnV)
max(voxmedian_normWsnV)
max(voxmean_normWsnV)
max(voxmean_normWmnV)
edit svm2mni.m
P_in=spm_select(1,'mat','Select svm-mat file');
svm2mni(P_in, 1)
roi_label(i).XYZmm
svm2mni(P_in, 1)
roi_label(1).XYZmm
roi_label(1)
Tab(i)
str2mat(Tab{:})
AAL_out.XYZmm
help svm2mni
xyz
[xyz] = svm2mni(P_in, 1)
AAL_out
[xyz] = svm2mni(P_in, 1)
svm2mni(P_in, 1)
AAL_out
[xyz] = svm2mni(P_in, 1)
xyz
xyz.XYZmm
[voxcoords] = svm2mni(P_in, 1);
voxcoords.XYZmm
voxcoords.XYZmm[1]
voxcoords.XYZmm[1,1]
voxcoords.XYZmm(1,1)
voxcoords.XYZmm(1)
voxcoords.XYZmm(2)
voxcoords.XYZmm(3)
min(voxmodeWsnP)

%% rest

temp=reshape(svm_mat,s*v,t);
time=Design_Para(:,4)';
temp=[temp;time];
temp=temp';
%save('musicness.txt','temp','-ascii','-tabs');
SV=load('MusicnessSVMtopWeightedVoxels.wv');
VSV=temp(:,SV(:,2));
SOTP=time';
x = VSV;
y = SOTP;
m=x\y;
plot(y)
%axis equal;axis off;
hold
plot(x*m,'r')
corrcoef(x*m,y)
hold off

%% Speechness and Musicness
sn=Design_Para(:,6)';
mn=Design_Para(:,4)';
plot(mn,sn)

%% Extract speechness
temp=reshape(svm_mat,s*v,t);
time=Design_Para(:,6)';
temp=[temp;time];
temp=temp';
%save('speechness.txt','temp','-ascii','-tabs');
SV=load('SpeechinessSVMtopWeightedVoxels.wv');
VSV=temp(:,SV(:,2));
SOTP=time';
x = VSV;
y = SOTP;
m=x\y;
plot(y)
%axis equal;axis off;
hold
plot(x*m,'r')
corrcoef(x*m,y)
hold off

%% check reshape with temp
%temp=zeros(2,4,4)
%[s v t]=size(svm_mat);
%[s v t]=size(temp)
%for i = 1:s
%for j = 1:v
%for k = 1:t
%        temp(i,j,k)=(i*100+10*j+k)
%        end
%    end
%end
%temp=reshape(temp,s*v,t);
%time1=1:4
%temp=[temp;time1]
%temp=temp'

%% save file
%save('a.txt','a','-ascii','-tabs');

%% run perl
%system('perl tab2csv.pl a.txt.csv');

%% run weka
%system('export CLASSPCLASSPATHATH=$CLASSPATH:/media/DATA');
%setenv('CLASSPATH', '/media/DATA' );
%system('java weka.classifiers.functions.MultilayerPerceptron -t a.txt.csv');

%publish;

