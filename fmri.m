%path('/home/fimm/ii/ash022/tom/spm2/',path);
path('/home/fimm/ii/ash022/tom/spm2/',path);
beh=load('/home/fimm/ii/ash022/tom/beh/MMBT.mat');
behmat = zeros(1,2612);
behmat(beh.onset)=1;
cd /home/fimm/ii/ash022/tom/Session_1;
files = dir('*.img');
%for i=1:length(files)
for i=1:2
    v = spm_vol(files(i).name);
    [vol xyz] = spm_read_vols(v);
    %imagesc(squeeze(vol(:,:,10)));
    if(behmat(2*i-1)==1||behmat(2*i)==1)
        %xyzall(2*i-1,:)=[xyz(1,:),xyz(2,:),xyz(3,:),1];
        %xyzall(2*i,:)=[xyz(1,:),xyz(2,:),xyz(3,:),1];
        xyzall(i,:)=[xyz(1,:),xyz(2,:),xyz(3,:),1];
    else
        %xyzall(2*i-1,:)=[xyz(1,:),xyz(2,:),xyz(3,:),0];
        %xyzall(2*i,:)=[xyz(1,:),xyz(2,:),xyz(3,:),0];
        xyzall(i,:)=[xyz(1,:),xyz(2,:),xyz(3,:),0];
    end
end
cd /home/fimm/ii/ash022/tom/scripts;
dlmwrite('xyzallotp.txt', xyzall, 'delimiter', ',', 'precision', 2);
quit


