%% load file
load('svm_mat_UMS_svm_20110520.mat')
whos
%% write csv
a=csvread('voxel_index.csv');
csvwrite(svm_mat,'dysl,csv');
%% extract voxel coordinates
v=size(ind,1);
P_in='svm_mat_UMS_svm_20110520.mat';
for i=1:v
    i
    [voxcoords] = svm2mni(P_in, i);
    vxcrds(i,1)=voxcoords.XYZmm(1);
    vxcrds(i,2)=voxcoords.XYZmm(2);
    vxcrds(i,3)=voxcoords.XYZmm(3);
end
%save('vxcrds.tab','vxcrds','-ascii','-tabs');

    
%% check
whos
plot(svm_mat(:,11967),svm_mat(:,11966),'r.')
train=svm_mat(:,1:11965);
class=svm_mat(:,11968);
svmStruct = svmtrain(train,class,'showplot',true);  
reg=train\class
plot(reg)
sum((reg(:,:)~=0))
idx=find(reg~=0)
idxP=find(reg>0)
idxN=find(reg<0)
reg(11852)
svm2mni(P_in, idx)
save('regvox.txt','idx','-ascii','-tabs');
svm2mni(P_in, idxP)
save('regvoxP.txt','idx','-ascii','-tabs');
svm2mni(P_in, idxN)
save('regvoxN.txt','idx','-ascii','-tabs');



%% mvpa
%addpath /home/animesh/export/mvpa
help tutorial_easy 


%% chech reg
x=[1 2 ;-2 -1]
y=[3;-3]
w=x\y
plot(y)
