%% file

TMS2=xlsread('X:\Qexactive\Alexey\20130827_tMS2_JPT_01.xlsx');
[~,~,IL]=tblread('X:\Qexactive\Alexey\incl.CSV',',');
FMS2EX=xlsread('X:\Qexactive\Alexey\20130827_FullMS-MS2_JPT_Ecxl_01.xlsx');

%% compare inclusion list with search input
hist(mze)
a=unique(sort(str2num(IL)));
%mze=a+(rand(size(a,1),1)/10e6)
%mze=unique(sort(TMS2(TMS2(:,6)==2,4))); % inclusion
mze=unique(sort(FMS2EX(FMS2EX(:,6)==2,4))); % exclusion
ppm=10;
clear cntax;
for i=1:size(mze,1)
    for j=1:size(a,1)
        if(((abs(a(j)-mze(i))<=mze(i)*(ppm/10e6))||(abs(a(j)-mze(i))<=a(j)*(ppm/10e6))))
            cntax(i)=a(j)-mze(i);
        else
            cntax(i)=0;
        end
    end
end

sum(abs(cntax)>0)
sum(cntax==0)
plot(mze,a)
plot3(cntax,a,mze,'r.')


%% read files

[ ~ , ~ , FMS3EX3] =xlsread('X:\Qexactive\Sissel\HEK_PO4\Multiconsensus from 6 Reports SI.xlsx');

ScoreC =xlsread('X:\Qexactive\Sissel\HEK_PO4\Multiconsensus from 6 ReportsMedScore.xlsx');

%% compare scores with/out exclusion list

plot((ScoreC(:,57)),(ScoreC(:,58)),'b.')
plot(log(ScoreC(:,57)),log(ScoreC(:,58)),'b.')
corr(ScoreC(:,57),ScoreC(:,58),'rows','pairwise')
hold
plot3(log(ScoreC(:,6)),log(ScoreC(:,14)),log(ScoreC(:,22)),'r.')
plot3(log(ScoreC(:,30)),log(ScoreC(:,38)),log(ScoreC(:,46)),'b.')

%% Extract rows

FMS=[FMS3EX3(find(ismember(FMS3EX3(:,2),'A')),9);FMS3EX3(find(ismember(FMS3EX3(:,2),'B')),9);FMS3EX3(find(ismember(FMS3EX3(:,2),'C')),9)];
EX=[FMS3EX3(find(ismember(FMS3EX3(:,2),'D')),9);FMS3EX3(find(ismember(FMS3EX3(:,2),'E')),9);FMS3EX3(find(ismember(FMS3EX3(:,2),'F')),9)];
plot([EX{:}],'r.')

%% extract vals and compare

% EX=FMS % test
a=(sort([FMS{:}]))';
mze=(sort([EX{:}]))';
plot(mze)
ppm=10;
stj=1;
clear cntax;
for i=1:size(mze,1)
    for j=stj:size(a,1)
        if(((abs(a(j)-mze(i))<=mze(i)*(ppm/10e6))||(abs(a(j)-mze(i))<=a(j)*(ppm/10e6))))
            cntax(i)=a(j)-mze(i);
            stj=j+1;
            break;
        else
            cntax(i)=0;
        end
    end
end

plot(cntax,'b.')
hist(cntax)
sum((cntax==0))
sum(abs(cntax)>0)

hist(find(cntax<1),[1000])

plot(cntax,mze,'b.')

%% with repmat (needs humongous memory!)

ar=repmat(a,1,size(mze,1));
mzer=ar-repmat(mze',size(a,1),1);
[av,mzev]=find(mzer<=ppm/10e6);


%% Ingvild stuff

hist(d(:,9))
hist(d(:,4))
hist(I24QPS(:,1))

%% SIM stuff

a=xlsread('X:\Elite\Alexey\Test_Incl_Excl\Multiconsensus from 3 ReportsSImod.xlsx');
a=xlsread('X:\Elite\Alexey\HCD\130617_1SegGenMSSI.xlsx')
EL=xlsread('X:\Elite\Alexey\Test_Incl_Excl\List.xlsx');
ELMI=xlsread('X:\Elite\Alexey\Test_Incl_Excl\peptides.txt.pepmonoisomass.xlsx');

a=xlsread('X:\Qexactive\Alexey\Multiconsensus from 4 ReportsQexSImod.xlsx');

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

