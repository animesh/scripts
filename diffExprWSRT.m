fo='L:\promec\USERS\Synnøve\20200825_3samples\QE\1stRun\combined\txt-rabit-noMBR-1\proteinGroups.txt';
testtype=' WSRT';
data=readtable(fo);
IDX=[1 7 8];%Uniprots, Gene Name, Fasta header
sdx=108;
edx=119;
rep=3;
log2data=log2(table2array(data(:,sdx:edx))+1);
log2ctr=log2data(:,[1:ceil((edx-sdx+1)/rep):size(log2data,2)]);
log2ctr=repelem(log2ctr,1,ceil((edx-sdx+1)/rep));
log2data=log2data-log2ctr;
log2data(log2data==0)=NaN;
hist(log2data)
idnm=data(:,IDX);
id=cell(data.Properties.VariableNames(sdx:edx));
pv=zeros(size(data,1),ceil((edx-sdx+1)/rep)-1);
ln=zeros(size(data,1),1);
hdr='Line ';
pcvt=0;
for j = 1:size(log2data,2)/rep
    hdr=[hdr strcat(num2str(j),id(j),testtype)];
    pcvt=pcvt+1;
    for i = 1:size(data,1)
        i,j%=1 %test with 1%
        %tmparr=log2(table2array(data(i,st:en))+1)-log2(table2array(data(i,st))+1);
        tmparr=log2data(i,[j:size(log2data,2)/rep:size(log2data,2)])
        ln(i)=i;
         if sum(isnan(tmparr))<length(tmparr)
            pv(i,pcvt)=signrank(tmparr);
         else
            pv(i,pcvt)=1;
         end
    end
end
hist(pv)
writetable(([[cell(data.Properties.VariableNames(IDX));idnm] [hdr;num2cell([ln pv])] [id;num2cell(log2data)]]),strcat(fo,testtype,'pVal.csv'))
