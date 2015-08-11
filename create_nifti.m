SimFile=spm_load('spike_detector-21-0.gdf')

Neurons=zeros(20,2000);
%Neurons_conv = Neurons;

for i=1:length(SimFile)
    Neurons(round(SimFile(i,1)),round(SimFile(i,2)/0.01))=1;
end

 hrf01=spm_hrf(0.1);
 
 for i=1:size(Neurons,1)
     Neurons_conv(i,:)=conv(Neurons(i,:),hrf01);
 end
 
nrows = size(Neurons_conv,2);

% Dummy header
    Vm.mat = [ -5     0     0    82; ...
                0     5     0  -117; ...
                0     0     5   -55; ...
                0     0     0     1];
    Vm.dt  = [4 0];
    Vm.dim = [32 38 28 ];

    Nest=randn(Vm.dim(1),Vm.dim(2),Vm.dim(3),nrows);
    
    posx=round(rand(1,20)*Vm.dim(1));
    posy=round(rand(1,20)*Vm.dim(2));
    
    for t=1:nrows        
        for n=1:size(Neurons_conv,1)       
            Nest(posx(n),posy(n),:,i) = Neurons_conv(n,t);
        end
    end
    
    Vm.fname = ['test.nii'];
    Vm       = spm_write_vol(Vm,Nest);