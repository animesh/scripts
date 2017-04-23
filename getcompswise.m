for ica = 1:70
    ICAS=num2str(ica);
    if(ica<10)
        ICAS=strcat('00',ICAS);
    else
        ICAS=strcat('0',ICAS);
    end
    %strcat('ica','_',ICAS)=[];
    %ica_mat=[];
    %icamat(ica)=[];
    
    for s = 1:66
        SS=num2str(s);
        if(s<10)
            SS=strcat('00',SS);
        else
            SS=strcat('0',SS);
        end
        file=strcat('adhd70_sub',SS,'_component_ica_s1_',ICAS,'.hdr');
        folder=strcat('adhd70_sub',SS,'_component_ica_s1_');
        lf=strcat(folder,'\',file);    
        folder
        file
        ICAS
        SS
        lf
        filename=strcat('IC_',num2str(ica),'.csv');
        V = spm_vol(lf);
        [vol xyz] = spm_read_vols(V);
        %icamat(ica)=[icamat(ica),vol_all];
        dlmwrite(filename,vol(:)' , '-append')
    end
end




%adhd70_sub033_component_ica_s1_
%adhd70_sub033_component_ica_s1_031.img
%I would concatenate across subjects, separately for each IC
%i.e.
%For i = 1:n_subjects

%[vol xyz] = spm_read_vols(V);
%vol_3dto1d_s1_c1(i,:) = vol(:);

%End

%The 2d matrix, subjects by voxels is what we used for the first step in classification (we used thresholded data)

%TE