load('flash_060')
load('dess_060')
load('fisp_060')
load('psif_060')
mask=imread('flash_060_brain_mask.png');
class=imread('flash_060_training_mask_6cla.png');
test_dess=dess.*(mask(:,:,2)~=0);
test_fisp=fisp.*(mask(:,:,2)~=0);
test_flash=flash.*(mask(:,:,2)~=0);
test_psif=flash.*(mask(:,:,2)~=0);
train_dess_magenta = dess.*(((class(:,:,1) ~= 0) & (class(:,:,2) == 0) & (class(:,:,3) ~= 0)));
train_dess_red = dess.*(((class(:,:,1) ~= 0) & (class(:,:,2) == 0) & (class(:,:,3) == 0)));
train_dess_cyan = dess.*(((class(:,:,1) == 0) & (class(:,:,2) ~= 0) & (class(:,:,3) ~= 0)));
train_dess_blue = dess.*(((class(:,:,1) == 0) & (class(:,:,2) == 0) & (class(:,:,3) ~= 0)));
train_dess_green = dess.*(((class(:,:,1) == 0) & (class(:,:,2) ~= 0) & (class(:,:,3) == 0)));
train_dess_yellow = dess.*(((class(:,:,1) ~= 0) & (class(:,:,2) ~= 0) & (class(:,:,3) == 0)));
train_fisp_magenta = fisp.*(((class(:,:,1) ~= 0) & (class(:,:,2) == 0) & (class(:,:,3) ~= 0)));
train_fisp_red = fisp.*(((class(:,:,1) ~= 0) & (class(:,:,2) == 0) & (class(:,:,3) == 0)));
train_fisp_cyan = fisp.*(((class(:,:,1) == 0) & (class(:,:,2) ~= 0) & (class(:,:,3) ~= 0)));
train_fisp_blue = fisp.*(((class(:,:,1) == 0) & (class(:,:,2) == 0) & (class(:,:,3) ~= 0)));
train_fisp_green = fisp.*(((class(:,:,1) == 0) & (class(:,:,2) ~= 0) & (class(:,:,3) == 0)));
train_fisp_yellow = fisp.*(((class(:,:,1) ~= 0) & (class(:,:,2) ~= 0) & (class(:,:,3) == 0)));
train_psif_magenta = psif.*(((class(:,:,1) ~= 0) & (class(:,:,2) == 0) & (class(:,:,3) ~= 0)));
train_psif_red = psif.*(((class(:,:,1) ~= 0) & (class(:,:,2) == 0) & (class(:,:,3) == 0)));
train_psif_cyan = psif.*(((class(:,:,1) == 0) & (class(:,:,2) ~= 0) & (class(:,:,3) ~= 0)));
train_psif_blue = psif.*(((class(:,:,1) == 0) & (class(:,:,2) == 0) & (class(:,:,3) ~= 0)));
train_psif_green = psif.*(((class(:,:,1) == 0) & (class(:,:,2) ~= 0) & (class(:,:,3) == 0)));
train_psif_yellow = psif.*(((class(:,:,1) ~= 0) & (class(:,:,2) ~= 0) & (class(:,:,3) == 0)));
train_psif_magenta = psif.*(((class(:,:,1) ~= 0) & (class(:,:,2) == 0) & (class(:,:,3) ~= 0)));
train_psif_red = psif.*(((class(:,:,1) ~= 0) & (class(:,:,2) == 0) & (class(:,:,3) == 0)));
train_psif_cyan = psif.*(((class(:,:,1) == 0) & (class(:,:,2) ~= 0) & (class(:,:,3) ~= 0)));
train_psif_blue = psif.*(((class(:,:,1) == 0) & (class(:,:,2) == 0) & (class(:,:,3) ~= 0)));
train_psif_green = psif.*(((class(:,:,1) == 0) & (class(:,:,2) ~= 0) & (class(:,:,3) == 0)));
train_psif_yellow = psif.*(((class(:,:,1) ~= 0) & (class(:,:,2) ~= 0) & (class(:,:,3) == 0)));
train_flash_magenta = flash.*(((class(:,:,1) ~= 0) & (class(:,:,2) == 0) & (class(:,:,3) ~= 0)));
train_flash_red = flash.*(((class(:,:,1) ~= 0) & (class(:,:,2) == 0) & (class(:,:,3) == 0)));
train_flash_cyan = flash.*(((class(:,:,1) == 0) & (class(:,:,2) ~= 0) & (class(:,:,3) ~= 0)));
train_flash_blue = flash.*(((class(:,:,1) == 0) & (class(:,:,2) == 0) & (class(:,:,3) ~= 0)));
train_flash_green = flash.*(((class(:,:,1) == 0) & (class(:,:,2) ~= 0) & (class(:,:,3) == 0)));
train_flash_yellow = flash.*(((class(:,:,1) ~= 0) & (class(:,:,2) ~= 0) & (class(:,:,3) == 0)));


train_magenta=[reshape(train_dess_magenta,1,prod(size(train_dess_magenta)));reshape(train_flash_magenta,1,prod(size(train_flash_magenta)));reshape(train_fisp_magenta,1,prod(size(train_fisp_magenta)));reshape(train_psif_magenta,1,prod(size(train_psif_magenta)))]';
train_yellow=[reshape(train_dess_yellow,1,prod(size(train_dess_yellow)));reshape(train_flash_yellow,1,prod(size(train_flash_yellow)));reshape(train_fisp_yellow,1,prod(size(train_fisp_yellow)));reshape(train_psif_yellow,1,prod(size(train_psif_yellow)))]';
train_red=[reshape(train_dess_red,1,prod(size(train_dess_red)));reshape(train_flash_red,1,prod(size(train_flash_red)));reshape(train_fisp_red,1,prod(size(train_fisp_red)));reshape(train_psif_red,1,prod(size(train_psif_red)))]';
train_green=[reshape(train_dess_green,1,prod(size(train_dess_green)));reshape(train_flash_green,1,prod(size(train_flash_green)));reshape(train_fisp_green,1,prod(size(train_fisp_green)));reshape(train_psif_green,1,prod(size(train_psif_green)))]';
train_blue=[reshape(train_dess_blue,1,prod(size(train_dess_blue)));reshape(train_flash_blue,1,prod(size(train_flash_blue)));reshape(train_fisp_blue,1,prod(size(train_fisp_blue)));reshape(train_psif_blue,1,prod(size(train_psif_blue)))]';
train_cyan=[reshape(train_dess_cyan,1,prod(size(train_dess_cyan)));reshape(train_flash_cyan,1,prod(size(train_flash_cyan)));reshape(train_fisp_cyan,1,prod(size(train_fisp_cyan)));reshape(train_psif_cyan,1,prod(size(train_psif_cyan)))]';


train_magenta_form=train_magenta((train_magenta(:,1)+train_magenta(:,2)+train_magenta(:,3)+train_magenta(:,4))~=0,:);
train_red_form=train_red((train_red(:,1)+train_red(:,2)+train_red(:,3)+train_red(:,4))~=0,:);
train_green_form=train_green((train_green(:,1)+train_green(:,2)+train_green(:,3)+train_green(:,4))~=0,:);
train_blue_form=train_blue((train_blue(:,1)+train_blue(:,2)+train_blue(:,3)+train_blue(:,4))~=0,:);
train_cyan_form=train_cyan((train_cyan(:,1)+train_cyan(:,2)+train_cyan(:,3)+train_cyan(:,4))~=0,:);
train_yellow_form=train_yellow((train_yellow(:,1)+train_yellow(:,2)+train_yellow(:,3)+train_yellow(:,4))~=0,:);
%train_all=[train_magenta_form,train_yellow_form,train_red_form,train_green_form,train_blue_form,train_cyan_form];

red=[1 0 0 0 0 0];
green=[0 1 0 0 0 0];
blue=[0 0 1 0 0 0];
magenta=[0 0 0 1 0 0];
yellow=[0 0 0 0 1 0];
cyan=[0 0 0 0 0 1];


all=[train_magenta_form;train_yellow_form;train_red_form;train_green_form;train_blue_form;train_cyan_form];
out=[repmat(magenta,size(train_magenta_form,1),1);repmat(yellow,size(train_yellow_form,1),1);repmat(red,size(train_red_form,1),1);repmat(green,size(train_green_form,1),1);repmat(blue,size(train_blue_form,1),1);repmat(cyan,size(train_cyan_form,1),1)];
check=[reshape(dess,1,prod(size(dess)));reshape(flash,1,prod(size(flash)));reshape(fisp,1,prod(size(fisp)));reshape(psif,1,prod(size(psif)));]';

clear test* clear train* clear ans psif flash dess fisp 

net=knn(size(all),size(out),5,all,out);
knnfwd(net, check);

    


% classlabel.air.no = 1; classlabel.air.col = 'magenta'; classlabel.air.rgb = [255, 0, 255];
% classlabel.gm.no = 2; classlabel.gm.col = 'red'; classlabel.gm.rgb = [255, 0, 0];
% classlabel.wm.no = 3; classlabel.wm.col = 'cyan'; classlabel.wm.rgb = [0, 255, 255];
% classlabel.csf.no = 4; classlabel.csf.col = 'blue'; classlabel.csf.rgb = [0, 0, 255];
% classlabel.mus.no = 5; classlabel.mus.col = 'green'; classlabel.mus.rgb = [0, 255, 0];
% classlabel.fat.no = 6; classlabel.fat.col = 'yellow'; classlabel.fat.rgb = [255, 255, 0];
% chnlabel.flash.no = 1; chnlabel.flash.name = 'flash';
% chnlabel.dess.no = 2; chnlabel.dess.name = 'dess';
% chnlabel.fisp.no = 3; chnlabel.fisp.name = 'fisp';
% chnlabel.psif.no = 4; chnlabel.psif.name = 'psif';
% 
% grid on;hold on;
% p1=plot3(train_flash_yellow, train_dess_yellow, train_fisp_yellow, '.');set(p1, 'Color', classlabel.air.rgb/255);
% p2=plot3(train_flash_red, train_dess_red, train_fisp_red, '.');set(p2, 'Color', classlabel.gm.rgb/255);
% p3=plot3(train_flash_green, train_dess_green, train_fisp_green, '.');set(p3, 'Color', classlabel.wm.rgb/255);
% p4=plot3(train_flash_blue, train_dess_blue, train_fisp_blue, '.');set(p4, 'Color', classlabel.csf.rgb/255);
% p5=plot3(train_flash_cyan, train_dess_cyan, train_fisp_cyan, '.');set(p5, 'Color', classlabel.mus.rgb/255);
% p6=plot3(train_flash_magenta, train_dess_magenta, train_fisp_magenta, '.');set(p6, 'Color', classlabel.fat.rgb/255);
% xlabel('FLASH (chn1)'); ylabel('DESS (chn2)'); zlabel('FISP (chn3)');title('Training data in 3D feature space', 'FontSize', 14);
% %legend([p1, p2, p3, p4, p5, p6], 'air', 'gm ', 'wm ', 'csf', 'mus', 'fat');
% grid off;hold off;
