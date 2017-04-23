%% data
[~,~,ss]=xlsread('X:\Elite\Aida\SS_1R\SS1RPGsortMGUS2MMmedvals.xls');
[cu,~,~]=xlsread('L:\Elite\gaute\test\CDS_CU_EntrezID.xls');
od=xlsread('L:\Elite\Aida\CellLines\cell-lines.xlsx');
comb=xlsread('L:\Elite\kamila\SILACmRNA.xlsx');
comb=xlsread('L:\Elite\kamila\Heart\combolfqs.xlsx');
comb=xlsread('L:\Elite\kamila\mRNAwithRedone.xls');
comb=xlsread('L:\Elite\kamila\GNmRNAcombSILAC.xlsx');
comb=xlsread('L:\Elite\Celine\LbH\combo.xlsx')

%% cluster 
corrcu=corrcoef(comb(:,1:6),'rows','pairwise')
cu(isnan(cu)) = 0.5 ;
clustergram(cu(:,2:65), 'Colormap', redbluecmap,'ImputeFun','knnimpute')
colormap
corrcu=corrcoef(cu)
plot(corrcu)
%corrprot=corrcoef(prot','rows','pairwise')
ccprop=clustergram(corrcu, 'Colormap', redbluecmap)
get(ccprop)

%% plot
plot((comb(:,1)),(comb(:,2)),'r.')
xlabel('SILAC')
ylabel('mRNA')
title('Fold change')
%axis equal
grid on

%% histogram of SILAC ratios with a log2 fit
histfit(log2(SILAC))
xlim([-2.5 2.5])

%% correlation
corrcoef((comb(((comb(:,1)>0&comb(:,2)>0))|(comb(:,1)<0&comb(:,2)<0),1)),(comb(((comb(:,1)>0&comb(:,2)>0))|(comb(:,1)<0&comb(:,2)<0),2)),'rows','pairwise')
corrcoef(comb(comb(:,1)<0&comb(:,2)<0,1),comb(comb(:,1)<0&comb(:,2)<0,2),'rows','pairwise')
corrcoef(comb(comb(:,1)>0&comb(:,2)>0,1),comb(comb(:,1)>0&comb(:,2)>0,2),'rows','pairwise')
corrcoef((comb(((comb(:,1)>0&comb(:,2)>0))|(comb(:,1)<0&comb(:,2)<0),1)),(comb(((comb(:,1)>0&comb(:,2)>0))|(comb(:,1)<0&comb(:,2)<0),2)),'rows','pairwise')
sum(comb(:,1)>0&comb(:,2)>0)
sum(comb(:,1)<0&comb(:,2)<0)
[val pval]=corrcoef(comb(comb(:,1)>0&comb(:,2)>0,1),comb(comb(:,2)>0&comb(:,1)>0,2))
[val pval]=corrcoef(comb(comb(:,1)<0&comb(:,2)<0,1),comb(comb(:,2)<0&comb(:,1)<0,2))


%% handling NaN's and getting out codon values
gene=cu(:,1)
cu=cu(:,2:end)
cu=cu*10;
cu(~isfinite(cu))=1;



%% fasta
ff = fastaread('L:\FastaDB\uniprot-human-ref-jun2015.fasta');
utr5=fastaread('L:\FastaDB\ORFs_5UTR.fasta')
utr3=fastaread('L:\FastaDB\ORFs_3UTR.fasta')

%% extract sequences
utr5.Header
utr5.Sequence
utr5tab=struct2table(utr5)
utr3tab=struct2table(utr3)
fftab=struct2table(ff)

%% amino acid distribution
aacount(strjoin(utr5tab.Sequence),'chart','pie')
aacount(strjoin(utr3tab.Sequence),'chart','pie')
aacount(strjoin(fftab.Sequence),'chart','pie')

%% insilico digests lengths
lgt=[]
for i=1:size(utr3)
    [partsPK, sitesPK, lengthsPK] = cleave(utr3(i).Sequence, 'trypsin');
    lgt=[lgt;lengthsPK];
end
histfit(lgt,50,'exp')


%% compare
aacount(ff(1).Sequence,'chart','bar')
%hist(cell2mat(ss(:,13)))

aaa(1)=aacount(ff(1).Sequence)
aaa(3)=aacount(ff(1).Sequence).*1.2

aacount(aaa(1),'chart','bar')

hist([aaa(:).A].*[1.2 0.8])

[aaa(:).A].*[1.2 0.8]
aaa(1)*1.5
hist([aaa(:).A],[50])
hist([aaa(:).A].*val,[50])


%% extract Uniprot IDs and their ratios
delimiter = '|'
cnt=0
for i = 1:size(ff,1)
    delim = find(ff(i).Header == delimiter);
    val=cell2mat([ss(find(ismember(ss(:,1),ff(i).Header(delim(1)+1:delim(2)-1))),13)]);
    if isnumeric(val) & val > 0
        cnt=cnt+1;
        valarr(cnt)=val;
        aacarr(cnt)=aacount(ff(i).Sequence);
    end
end

%% compare
aastr='H'
[vm im]=max([aacarr(:).(aastr)].*valarr)
max(valarr(im))
ss(find(isequal(ss(:,13),max(valarr(im)))),1)
sum(valarr))
histfit(valarr)
aastr='V'
hist(([[aacarr(:).(aastr)]' ([aacarr(:).(aastr)].*valarr)']))

hist([aacarr(:).(aastr)].*valarr, bins)
hist([aacarr(:).(aastr)], bins)

bins = linspace(100,1000,10)
y1 = hist([aacarr(:).(aastr)].*valarr, bins);   
y2 = hist([aacarr(:).(aastr)], bins);
bar(bins, [y1;y2]');

%% boxplot
aastr=''
boxplot([[aacarr(:).(aastr)]'  ([aacarr(:).(aastr)].*(valarr))'])

sum([aacarr(:).(aastr)].*(valarr))/sum([aacarr(:).(aastr)])
boxplot([[aacarr(:).(aastr)]'.*sum([aacarr(:).(aastr)].*(valarr))/sum([aacarr(:).(aastr)])  ([aacarr(:).(aastr)].*(valarr))'])

%% loop it
fn=fieldnames(aacarr)
for i = 1:numel(fn)
    aastr=fn{i}
    sum([aacarr(:).(aastr)].*(valarr))/sum([aacarr(:).(aastr)])
end