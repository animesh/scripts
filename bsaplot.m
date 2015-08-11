%% read files

prot=xlsread('X:\BSA Direct vs. Trad\MC8RProtein.xlsx')
pep=xlsread('X:\BSA Direct vs. Trad\MC8RPeptides.xlsx')
si=xlsread('X:\BSA Direct vs. Trad\MC8RSI.xlsx')
pepwg=xlsread('L:\Qexactive\MohmD\Rat_Liver_MWave_3x30Sec_4Hrs_SequestHt and Mascot.xlsx')

[bsapep1 bsapep2 bsapep3] =xlsread('X:\BSA Direct vs. Trad\Blood_Plasma_prot_ca2ug_Trypsin_1,4,8,16hours_Combined_Mascot_SequestHT_Phospho_Varia_Mod_PhosPhoRS_Medium_Peptides_List.xlsx')


%% density
histfit(pepwg(:,20));
X = [pepwg(:,22),pepwg(:,20)];
hist3(X,[40 40]);
xlabel('Retention Time'); ylabel('Molecular Weight');
title('Density of eluting peptides');

set(gcf,'renderer','opengl');
set(get(gca,'child'),'FaceColor','interp','CDataMode','auto');
colorbar

%axis equal
grid on

%% Pie chart (Ident and Phospho)

totpep=sum(~cellfun(@isempty,bsapep2(:,1)))-1
phoval=sum(~cellfun(@isempty,bsapep2(:,8)))-1
explode = [0 1];
pie([totpep phoval],explode)
colormap summer


%% Time series T v D 1,4,8,16 (prot)

hr=[16 1 4 8];
idx=[6 10 14 18];
pro=[(hr);sum(prot(:,(idx)+16)>=0)]'
pro=sortrows(pro)
plot(pro(:,1),pro(:,2),'b*-')
hold on
pro=[(hr);sum(prot(:,(idx))>=0)]'
pro=sortrows(pro)
plot(pro(:,1),pro(:,2),'r.-')
title('Time Series plot for detected Proteins: Traditional(Red) and Direct(Blue)')
hold off

fname=['X:\BSA Direct vs. Trad\TSProt']    
print('-djpeg',fname);


%% Time series T v D 1,4,8,16 (pep)


idx=[1 2 3 4];
hr=[16 1 4 8];
pepn=[pep(:,22) pep(:,11) pep(:,24) pep(:,15) pep(:,12) pep(:,18) pep(:,16) pep(:,20)];
pro=[(hr);sum(pepn(:,(idx)+4)>=0)]'
pro=sortrows(pro)
plot(pro(:,1),pro(:,2),'b*-')
hold on
pro=[(hr);sum(pepn(:,(idx))>=0)]'
pro=sortrows(pro)
plot(pro(:,1),pro(:,2),'r.-')
title('Time Series plot for detected Peptides: Traditional(Red) and Direct(Blue)')
hold off
fname=['X:\BSA Direct vs. Trad\TSPep']    
print('-djpeg',fname);

%% Time series T v D 1,4,8,16 (pep,prot,PSM)

hro1=[16 1 4 8];
hro2=[116 11 14 18];
hr=[16 1 4 8];
sid=[1 sum(si(:,14)==11);4 sum(si(:,14)==14);8 sum(si(:,14)==18);16 sum(si(:,14)==116)]
plot(sid(:,1),sid(:,2),'b.-')
hold on
sit=[1 sum(si(:,14)==1);4 sum(si(:,14)==4);8 sum(si(:,14)==8);16 sum(si(:,14)==16)]
plot(sit(:,1),sit(:,2),'r.-')
title('Time Series plot for detected Ions: Traditional(Red) and Direct(Blue)')
hold off
fname=['X:\BSA Direct vs. Trad\TSIons']    
print('-djpeg',fname);

%% PSM correlations

hr=[16 1 4 8];
idx=[6 10 14 18];
for i=1:4
    sp=idx(i)+3
    tm=hr(i)
    [rho pval]=corr(prot(:,sp+16),prot(:,sp),'rows','complete')
end

%% confidence

hr=[16 1 4 8];
idx=[6 10 14 18];
for prop=1:3
    sp=idx(i)+prop-1
    for i=1:4
        tm=hr(i)
        [hyp,pvalue]=ttest(prot(:,sp),prot(:,sp+16))
    end
end

%% BSA detection

hist(si(si(:,1)==1,14),[100])

corr(si(si(:,14)==11,9),si(si(:,14)==1,9))

%% protein

hist(log(prot(prot(:,1)>0&prot(:,6)>0,6))) % direct 16
hist(log(prot(prot(:,1)>0&prot(:,22)>0,22))) % trad 16

hist([log(prot(prot(:,1)>0&prot(:,22)>0,22));log(prot(prot(:,1)>0&prot(:,6)>0,6))],100) % trad 16

%% scores

figure; 
cc=hsv(8);
hold on;
sp=7;
for i=1:8
    (i-1)*4+sp
    [val freq]=hist(log(prot(prot(:,1)>0&prot(:,(i-1)*4+sp)>0,(i-1)*4+sp))); % trad 16
    plot(freq,val,'color',cc(i,:));
    %rgbn(cc(i,:))
end
xlabel('Log Sequest Score')
ylabel('# of proteins with the score')
title('Histogram of score, Traditional and Direct Methods')
legend('Direct 16h','Direct 1h','Direct 4h','Direct 8h','Traditional 16h','Traditional 1h','Traditional 4h','Traditional 8h')
hold off;



 
%% boxplot

for sp=6
    boxplot(log(prot(prot(:,1)>0&prot(:,6)>0,6)) log(prot(prot(:,1)>0&prot(:,22)>0,22))
end

%% val

for sp=6:4:18
    sp
    [val idx]=find(prot(:,sp)>=0);
    A1=sum(idx)
    [val idx]=find(prot(:,sp+16)>=0);
    A2=sum(idx)
    [val idx]=find(prot(:,sp+16)>=0&prot(:,sp>=0));
    Com=sum(idx);
    Area=[A1 A2];
end

%% vennX

vennX([100 50 0],0.05)
vennX([10 5 20],0.05)
 

%% vennX prot


hr=[16 1 4 8];
idx=[6 10 14 18];
for i=1:4
    sp=idx(i)
    tm=hr(i)
    %vennX([sum(prot(:,sp+16)>=0)-sum(prot(:,sp+16)>=0 & prot(:,sp)>=0), sum(prot(:,sp+16)>=0 & prot(:,sp)>=0), sum(prot(:,sp)>=0)-sum(prot(:,sp+16)>=0 & prot(:,sp)>=0)],0.01)
    vennX([sum(prot(:,sp+16)>=0), sum(prot(:,sp+16)>=0 & prot(:,sp)>=0), sum(prot(:,sp)>=0)],0.05)
    axis equal, axis off
    figtit=['Venn diagram: Traditional and Direct Methods for detected Proteins (',int2str(tm),'h)']
    title(figtit)
    fname=['X:\BSA Direct vs. Trad\VennProt',int2str(tm)]    
    print('-djpeg',fname);
end

%% vennX pep


hro=[116 4 11 8 14 18 16 1];
idxo=[11 12 15 16 18 20 22 24];
idx=[1 2 3 4]
hr=[16 1 4 8];
pepn=[pep(:,22) pep(:,11) pep(:,24) pep(:,15) pep(:,12) pep(:,18) pep(:,16) pep(:,20)]
%plot(hr,idx,'r.')
for i=1:4
    sp=idx(i)
    tm=hr(i)
    vennX([sum(pepn(:,sp+4)>=0), sum(pepn(:,sp+4)>=0 & pepn(:,sp)>=0), sum(pepn(:,sp)>=0)],0.05)
    axis equal, axis off
    figtit=['Venn diagram: Traditional and Direct Methods for detected Peptides (',int2str(tm),'h)']
    title(figtit)
    fname=['X:\BSA Direct vs. Trad\VennPep',int2str(tm)]    
    print('-djpeg',fname);
end

%% vennX SI
sum(si(:,14)==16)

hro=[16 1 4 8 116 11 14 18];
idx=[1 2 3 4]
hr=[16 1 4 8];
for i=1:4
    sp=idx(i)
    tm=hr(i)
    vennX([sum(si(:,14)==hro(i)), sum(si(:,14)==hro(i) & si(:,14)==hro(i+4)), sum(si(:,14)==hro(i+4))],0.05)
    axis equal, axis off
    figtit=['Venn diagram: Traditional and Direct Methods for detected spectras (',int2str(tm),'h)']
    title(figtit)
    fname=['X:\BSA Direct vs. Trad\VennSI',int2str(tm)]    
    print('-djpeg',fname);
end

%% plot 
h=figure
plot(sin(1:100))
fname=['VennProt',int2str(sp),'.jpg']    
saveas(h,'ytest','jpg');
    

%% venn
A=[prot(:,6)>=0]


%% sandbox

ksdensity(log(prot(prot(:,1)>0&prot(:,6)>0,6))) % direct 16
hold
ksdensity(log(prot(prot(:,1)>0&prot(:,22)>0,22))) % direct 16

[rd,cd]=find(detect>0);
unique(rd);
size(ans,1)
chix=1
rd(chix)
cd(chix)
detect(rd(chix),cd(chix))


%% compare R1 with R1EX1

mze1=EL1(:,1)
rt1e1=EL1(:,3)
rt2e1=EL1(:,4)
ce1=EL1(:,6)

mze2=EL2(:,1)
rt1e2=EL2(:,3)
rt2e2=EL2(:,4)
ce2=EL2(:,6)

mze3=EL3(:,1)
rt1e3=EL3(:,3)
rt2e3=EL3(:,4)
ce3=EL3(:,6)

plot(mze1,ce1,'r.')

mz=d(:,9)
rt=d(:,12)
c=d(:,11)

mze=[mze1;mze2;mze3]

%% compare
ppm=10
cnt=0;
for i=1:size(mze1,1)
    for j=1:size(mz,1)
        if(mz(j)<=(mze1(i)+mze1(i)*(ppm/10e6)) && mz(j)>=(mze1(i)-mze1(i)*(ppm/10e6)) && rt(j)>=rt1e1(i) && rt(j)<=rt2e1(i) && (d(j,14)==10))
           cnt=cnt+1; 
        end
    end
end

cnt2=0;
for i=1:size(mze2,1)
    for j=1:size(mz,1)
        if(mz(j)==mze2(i) && rt(j)>=rt1e2(i) && rt(j)<=rt2e2(i))
           cnt2=cnt2+1; 
        end
    end
end

cnt3=0;
for i=1:size(mze3,1)
    for j=1:size(mz,1)
        if(mz(j)==mze3(i) && rt(j)>=rt1e3(i) && rt(j)<=rt2e3(i))
           cnt=cnt3+1; 
        end
    end
end

%% replicate compare

e1=d(d(:,14)==10,9)
e2=d(d(:,14)==20,9)
e3=d(d(:,14)==30,9)

[r,lags]=xcorr(e1,e2)
max(r)
plot(lags,r,'r.')

ecnt=0;
ppm=10
for i=1:size(e2,1)
    for j=1:size(e3,1)
        if(abs(e2(i)-e3(j))<=(e3(j)*ppm/10e6) || abs(e2(i)-e3(j))<=(e2(i)*ppm/10e6))
           ecnt=ecnt+1; 
        end
    end
end

%% source

http://stackoverflow.com/questions/2028818/automatically-plot-different-colored-lines-in-matlab
