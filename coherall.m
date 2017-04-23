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
voxmean_std=reshape(mean(svm_mat_std(:,:,:)),v,t);
    for i=1:v
        i
        %[c_ww,lags] = xcorr(voxmean_std(i,:),'coeff');
        %voxmean_std_c(i,:)=c_ww(:);
        %tmpautcorrmax=max(c_ww)
        for j=i+1:v
            [c_ww,lags] = xcorr(voxmean_std(i,:),voxmean_std(j,:),'coeff');
            [val,idx]=max(c_ww);  
            %voxmean_std_cval_all(i,j,:)=c_ww(:);
            voxmean_std_cidx(i,j)=idx;
        end
    end
%csvwrite('voxmean_std_auto.csv',voxmean_std_c)
%csvwrite('voxmean_std_cval_all.csv',voxmean_std_cval_all)
csvwrite('voxmean_std_cidx.csv',voxmean_std_cidx)

    
