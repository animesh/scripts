%% UNG2

seq=getgenpept('P13051')
aacount(seq,'chart','bar')
molweight(seq)
isoelectric(seq)


%% Danio rerio

DRA=fastaread('C:\Users\animeshs\Google Drive\DANRE.fasta\DANRE.fasta');

%% brain specific protein list http://www.uniprot.org/uniprot/?query=organism%3A%22danio+rerio%22+AND+tissue%3Abrain&sort=score , download on top right

DRA=fastaread('C:\Users\animeshs\Google Drive\MSA\ZFbrainP.fasta');

aacount([DRA.('Sequence')],'chart','bar')


DR={DRA.('Sequence')};
molweight(regexprep(cell2mat(DR(57:57)),'[UX\*]',''))

G2DR=zeros(size(DR,2),2);
for i=1:size(DR,2)
    G2DR(i,1)=molweight(regexprep(cell2mat(DR(i)),'[UX\*]',''));
    G2DR(i,2)=isoelectric(regexprep(cell2mat(DR(i)),'[UX\*]',''));
end


smoothhist2D(G2DR,5,[100, 100],[],'surf')
ksdensity(G2DR(:,2))
ksdensity(G2DR(:,1))

%[idx]=(G2DR(:,1)<18000&G2DR(:,1)>16000&G2DR(:,2)>2&G2DR(:,2)<4)
[idx]=(G2DR(:,1)<18000&G2DR(:,1)>1000&G2DR(:,2)>2&G2DR(:,2)<4)
DRA(idx).('Header')

smoothhist2D(G2DR(idx,:),5,[100, 100],[],'surf')

hist3(G2DR(idx,:))

%% read fasta file

HP = fastaread('Homo_sapiens.GRCh37.68.pep.all.fa')
TD = fastaread('Sarcophilus_harrisii.DEVIL7.0.68.pep.all.fa')
aminolookup(HP(1).Sequence)
molweight(HP(1).Sequence)
aacount(HP(1).Sequence,'chart','bar')
isoelectric(HP(2).Sequence)
isoelectric([HP.('Sequence')])
molweight([HP.('Sequence')])
aacount([HP.('Sequence')],'chart','bar')  %leucine rich
aacount([TD.('Sequence')],'chart','bar')    %lucifer ;)


%% isoelectric point and molecular weight (Da-g/Mol)

C={HP.('Sequence')};
molweight(regexprep(cell2mat(C(57:57)),'[UX\*]',''))
molweight(strrep(cell2mat(C(2:2)),'U',''))
x=strrep(strrep(strrep([TD.('Sequence')],'U',''),'X',''),'*','');
%molweight(strrep(strrep(strrep(x,'U',''),'X',''),'*',''))
%ans =  4.2358e+09
isoelectric([C])

G2D=zeros(size(C,2),2);
for i=1:size(C,2)
    G2D(i,1)=molweight(regexprep(cell2mat(C(i)),'[UX\*]',''));
    G2D(i,2)=isoelectric(regexprep(cell2mat(C(i)),'[UX\*]',''));
end
   
%% Tasmanian Devil

CTD={TD.('Sequence')};

G2DTD=zeros(size(CTD,2),2);
for i=1:size(CTD,2)
    G2DTD(i,1)=molweight(regexprep(cell2mat(CTD(i)),'[UX\*]',''));
    G2DTD(i,2)=isoelectric(regexprep(cell2mat(CTD(i)),'[UX\*]',''));
end
   
%% fragment digestion http://www.mathworks.se/help/bioinfo/ref/cleave.html

%[partsPK, sitesPK, lengthsPK] = cleave(gpSeq.Sequence, 'trypsin', ... 
[partsPK, sitesPK, lengthsPK] = cleave(x, 'trypsin', ... 
    'exception', 'KP', ... 
    'missedsites',0);

TDHPMWPI=zeros(size(sitesPK,1),1);


for i=1:size(sitesPK,1)
    %fprintf('%5d%5d%5d %s\n',i, sitesPK(i),lengthsPK(i),partsPK{i})
    %TDHPMWPI(i,1)=molweight(partsPK{i});
    %TDHPMWPI(i,2)=isoelectric(partsPK{i});
    %fprintf('%10d\t%10d %s\n',i, TDHPMWPI(i,2),partsPK{i})
end


scatterhist(TDHPMWPI(:,2),TDHPMWPI(:,1))
hist3(TDHPMWPI,[15 15])

smoothhist2D([TDHPMWPI(:,2),TDHPMWPI(:,1)],200,[100,50])
colorbar
ylabel('Molecular Weight')
xlabel('Isoelectric point')
title('Trypsin digested human proteome')

smoothhist2D(TDHPMWPI,5,[100, 100])
smoothhist2D(TDHPMWPI,5,[100, 100],[],'surf')
ksdensity(TDHPMWPI(:,2)) % checkin the tri/quadri? modal distribution

smoothhist2D([TDHPMWPI(:,2),lengthsPK(:)],5,[100, 100],[],'surf')

DataDensityPlot(TDHPMWPI(:,2),lengthsPK(:),10)

% does not work on this one
cloudPlot(TDHPMWPI(:,2),TDHPMWPI(:,1))
ksdensity(lengthsPK(lengthsPK(:)<20))

sum((lengthsPK(:)==1))

% too slow but looks good
y=[rand(10,10);rand(10,10)]
DataDensityPlot(y(:,2),y(:,1),10)


%% random weighted protein sequence http://www.mathworks.se/help/bioinfo/ref/randseq.html

%rw=randi(20,20,1)'
%RSPW=randseq(length(x)/1000,'alphabet','amino','weights',rw/sum(rw))

RSPW=randseq(length(x)/10,'alphabet','amino','FromStructure',aacount([TD.('Sequence')]));


[RSPWpartsPK, RSPWsitesPK, RSPWlengthsPK] = cleave(RSPW, 'trypsin', ... 
    'exception', 'KP', ... 
    'missedsites',0);

RSPWMWPI=zeros(size(RSPWsitesPK,1),1);


for i=1:size(RSPWsitesPK,1)
    RSPWMWPI(i,1)=molweight(RSPWpartsPK{i});
    RSPWMWPI(i,2)=isoelectric(RSPWpartsPK{i});
    fprintf('%10d\t%10d %s\n',i, RSPWMWPI(i,2),RSPWpartsPK{i})
end

smoothhist2D(RSPWMWPI,5,[100, 100])
smoothhist2D(RSPWMWPI,5,[100, 100],[],'surf')
ksdensity(RSPWMWPI(:,2)) % checkin the tri/quadri? modal distribution




%% random protein sequence, trypsin digestion and PI values

RSP=randseq(length(x)/10,'alphabet','amino');


[RSPpartsPK, RSPsitesPK, RSPlengthsPK] = cleave(RSP, 'trypsin', ... 
    'exception', 'KP', ... 
    'missedsites',0);

RSPMWPI=zeros(size(RSPsitesPK,1),1);


for i=1:size(RSPsitesPK,1)
    RSPMWPI(i,1)=molweight(RSPpartsPK{i});
    RSPMWPI(i,2)=isoelectric(RSPpartsPK{i});
    fprintf('%10d\t%10d %s\n',i, RSPMWPI(i,2),RSPpartsPK{i})
end

smoothhist2D(RSPMWPI,5,[100, 100])
smoothhist2D(RSPMWPI,5,[100, 100],[],'surf')
ksdensity(RSPMWPI(:,2)) % checkin the tri/quadri? modal distribution


%% plot for presentation

cd M:\TS-desktop\MS
aacount([TD.('Sequence')],'chart','bar')
smoothhist2D([RSPWlengthsPK(:),RSPWMWPI(:,2)],5,[100, 100])
aacount([TD.('Sequence')],'chart','bar')
smoothhist2D(G2DTD,50,[150, 150])
smoothhist2D(G2DTD)
smoothhist2D(G2DTD,5,[100, 100],[],'surf')
smoothhist2D(TDHPMWPI,5,[100, 100],[],'surf')
smoothhist2D([TDHPMWPI(:,2),lengthsPK(:)],5,[100, 100],[],'surf')
smoothhist2D(RSPWMWPI,5,[100, 100],[],'surf')
ksdensity(TDHPMWPI(:,2))
ksdensity(lengthsPK(lengthsPK(:)<20))


