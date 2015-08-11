clear all;
path('/scratch/tom/spm2/',path);
beh=load('/scratch/tom/beh/MMBT.mat');
behmat = zeros(1,2612);
behmat(beh.onset)=1;
cd /scratch/tom/Session_1;
files = dir('*.img');

v = spm_vol(files(1).name);
[vol xyz] = spm_read_vols(v);
vold = whos('vol');  
%volall = zeros(length(files),vold.size(1)*vold.size(2)*vold.size(3)+1);

%for i=1:length(files)
for i=1:8
    cntr=0;
    v = spm_vol(files(i).name);
    [vol xyz] = spm_read_vols(v);
    vol1r1 = vol(1:2:end-1,1:2:end-1,1:2:end-1);
    vol1r2 = vol(2:2:end,2:2:end,2:2:end);
    vol1r = (vol1r1 + vol1r2)./2;
    if(behmat(2*i-1)==1||behmat(2*i)==1)
	vol2=[vol1r(:)',1];
    else
	vol2=[vol1r(:)',0];
    end
    fnamei=sprintf('vol.%d.txt',i); 
    cd /scratch/tom/scripts;
    dlmwrite(fnamei, vol2, 'delimiter', ',');
    cd /scratch/tom/Session_1;
end
cd /scratch/tom/scripts;




