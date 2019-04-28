%% threshold 
[data,id,~]=xlsread('L:\Elite\kamila\SILAC1p25.mRNA1p25all.xlsx');
corrcoef(data(:,11)>0,data(:,12))
axis equal
plot(data(:,11),data(:,12),'r.')
grid on
xlabel('SILAC')
ylabel('mRNA')
upup=sum(data(:,11)>0&data(:,12)>0)
updn=sum(data(:,11)>0&data(:,12)<0)
dnup=sum(data(:,11)<0&data(:,12)>0)
dndn=sum(data(:,11)<0&data(:,12)<0)
ccupup1p25=corrcoef(data1p25(data1p25(:,11)>0&data1p25(:,12)>0,11),data1p25(data1p25(:,11)>0&data1p25(:,12)>0,12))
ccdndn1p25=corrcoef(data1p25(data1p25(:,11)<0&data1p25(:,12)<0,11),data1p25(data1p25(:,11)<0&data1p25(:,12)<0,12))


%% all
[data1p25,id1p25,~]=xlsread('L:\Elite\kamila\SILAC1p25.mRNA1p25only.xlsx');
axis equal
plot(data1p25(:,11),data1p25(:,12),'r.')
grid on
xlabel('SILAC')
ylabel('mRNA')
upup=sum(data1p25(:,11)>0&data1p25(:,12)>0)
updn=sum(data1p25(:,11)>0&data1p25(:,12)<0)
dnup=sum(data1p25(:,11)<0&data1p25(:,12)>0)
dndn=sum(data1p25(:,11)<0&data1p25(:,12)<0)
ccupup=corrcoef(data(data(:,11)>0&data(:,12)>0,11),data(data(:,11)>0&data(:,12)>0,12))
ccdndn=corrcoef(data(data(:,11)<0&data(:,12)<0,11),data(data(:,11)<0&data(:,12)<0,12))
