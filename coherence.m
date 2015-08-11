load('svm_mat555');
[s v t]=size(svm_mat);
sn=Design_Para(:,6)';
mn=Design_Para(:,4)';
corrcoef(mn,sn)
for i = 1:size(svm_mat,1)
    for j = 1:size(svm_mat,3)
    %svm_mat_norm(i,:,j)=mat2gray(svm_mat(i,:,j));
    svm_mat_std(i,:,j)=(svm_mat(i,:,j)-mean(svm_mat(i,:,j)))/std(svm_mat(i,:,j));
    end
end
voxmode_std=reshape(mode(svm_mat_std(:,:,:)),v,t);
    for i=1:v
        i
        [c_ww,lags] = xcorr(voxmean_std(i,:),'coeff');
        voxmean_std_c(i,:)=c_ww(:);
        tmpautcorrmax=max(c_ww)
        for j=i+1:v
            [c_ww,lags] = xcorr(voxmean_std(i,:),voxmean_std(j,:),'coeff');
            [val,idx]=max(c_ww);  
            voxmean_std_cval(i,j)=val;
            voxmean_setd_cidx(i,j)=idx;
        end
    end
    
%% get max cc
voxMrel(1)=max(voxmeanWsnV)
voxMrel(2)=max(voxmean_normWsnV)
voxMrel(3)=max(voxmean_stdWsnV)
voxMrel(4)=max(voxmedianWsnV)
voxMrel(5)=max(voxmedian_normWsnV)
voxMrel(6)=max(voxmedian_stdWsnV)
voxMrel(7)=max(voxmodeWsnV)
voxMrel(8)=max(voxmode_normWsnV)
voxMrel(9)=max(voxmode_stdWsnV)


voxMNrel(1)=max(voxmeanWmnV)
voxMNrel(2)=max(voxmean_normWmnV)
voxMNrel(3)=max(voxmean_stdWmnV)
voxMNrel(4)=max(voxmedianWmnV)
voxMNrel(5)=max(voxmedian_normWmnV)
voxMNrel(6)=max(voxmedian_stdWmnV)
voxMNrel(7)=max(voxmodeWmnV)
voxMNrel(8)=max(voxmode_normWmnV)
voxMNrel(9)=max(voxmode_stdWmnV)


%% write cc file
tmp=[voxmean_std;sn]';
whos tmp
corrcoef(tmp(:,11966),sn)
csvwrite('voxmean_std.csv',tmp)
tmp=[voxmedian_norm;mn]';
whos tmp
corrcoef(tmp(:,11966),mn)
csvwrite('voxmedian_norm.csv',tmp)

    