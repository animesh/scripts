%% files

beckprot=xlsread('V:\felles\PROTEOMICS and XRAY\Abundance\Beck-2011-supplementary table 1-protein copies per cell.xls')
commprot=xlsread('V:\felles\PROTEOMICS and XRAY\Abundance\Common proteins in IF studies-Supplementary from review modified GS.xls')
commprot=xlsread('X:\Elite\kamila\idcombo.xls')

%% mRNA with SILAC
corr(commprot)
plot(commprot(:,1),commprot(:,2),'r.')

thr=1.25
sum(commprot(:,1)>=thr & commprot(:,2)>=thr)
sum(commprot(:,1)<=-thr & commprot(:,2)<=-thr)
sum(commprot(:,1)>=thr & commprot(:,2)<=thr)
sum(commprot(:,1)<=thr & commprot(:,2)>=thr)

%% compare lists

mcomm=log10(commprot(:,3))
beck=log10(beckprot(:,1)) %./size(beckprot,1)
hist(comm,[4])
hist(beck,[4])
ax(log(beckprot(:,1)))

ksdensity(comm)
hold
ksdensity(comm+rand())
hold off

bins = linspace(1,10,10)
%bins = unique([comm;beck]); 
y1 = hist(repmat(comm,30,1), bins);   
y2 = hist(beck, bins);
bar(bins, [y1;y2]');

% perl matchlist.pl /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Abundance/comm.csv /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Abundance/beck.csv > /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Abundance/match.csv

%% read file
prot=xlsread('X:\Elite\Mohmd\Area.xlsx')
hr=prot(1,:)
prot=prot(2:end,:)
hr
plot(prot(:,6),prot(:,2),'r.')


%% read file
prot=xlsread('C:\Users\animeshs\SkyDrive\Multiconsensus from 6 Reports_Last_Run.xlsx')

%% plot
hr=[12 1 24 3 6 0]
prot=prot(:,6:11)


%% parameters
for i=1:6
    i
    mxv(i)=max(isfinite(prot(:,i)./prot(:,6)));
    x(i)=prot(:,6)\prot(:,i);
    [rho(i) val(i)]=corr(prot(:,i),prot(:,6),'rows','pairwise');
end
mxv,x,rho,val,hr
plot(hr,x,'b.')

%% write for weka
size(prot)

csvwrite('area.csv',[prot;hr]')

dlmwrite('my_data.csv',A, ';')

java weka.classifiers.meta.AttributeSelectedClassifier -E "weka.attributeSelection.PrincipalComponents -R 0.95 -A 5" -S "weka.attributeSelection.Ranker -T -1.7976931348623157E308 -N -1" -t ..\areatrp.csv

%% plots

plot(hr,prot(368,:),'k.')
plot(hr,prot(626,:),'k.')
plot(hr,prot(1508,:),'k.')
plot(hr,prot(2149,:),'k.')
plot(hr,prot(3496,:),'k.')
plot(hr,prot(4324,:),'k.')
plot(hr,prot(4329,:),'k.')
plot(hr,prot(4815,:),'k.')



%% error histogram
errx=bsxfun(@minus,bsxfun(@times,prot(:,6),x),prot)
hist(errx)

%% gen prot mat
bval=randn(100,1)
muval=[6 5 4 3 2 1]
prot=[bval.*6 bval.*5 bval.*4 bval.*3 bval.*2 bval.*1]


%% correlation
[rho val]=corr(prot(:,6)./prot(:,11),prot(:,8)./prot(:,11),'rows','pairwise')
[rho val]=corr(prot(:,6),prot(:,8),'rows','pairwise')

