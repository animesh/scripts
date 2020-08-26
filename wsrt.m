fo='L:\promec\HF\Lars\2020\AUGUST\siri\combined\txt_PHOSTY\proteinGroups.txt';
testtype=' WSRT';
data=readtable(fo);
IDX=1;
sdx=108;
edx=119;
rep=3;
log2data=log2(table2array(data(:,sdx:edx))+1);
log2ctr=log2data(:,[1:ceil((edx-sdx+1)/rep):size(log2data,2)]);
log2ctr=repelem(log2ctr,1,ceil((edx-sdx+1)/rep));
log2data=log2data-log2ctr;
hist(log2data)
idnm=data(:,IDX);
id=cell(data.Properties.VariableNames(sdx:edx));
pv=zeros(size(data,1),ceil((edx-sdx+1)/rep)-1);
ln=zeros(size(data,1),1);
hdr='Line ';
pcvt=0;
for j = 1:ceil((edx-sdx+1)/rep):size(log2data,2)
    hdr=[hdr strcat(num2str(j),id(j),testtype)]
    pcvt=pcvt+1;
    for i = 1:size(data,1)
        %tmparr=log2(table2array(data(i,st:en))+1)-log2(table2array(data(i,st))+1);
        %tmparr(tmparr==0)=nan;
        %tmparr=tmparr(2:4)
        i%=1 %test with 1%
        tmparr=log2data(i,j+1:j+rep)
        ln(i)=i;
         if sum(isnan(tmparr))<length(tmparr)
            pv(i,pcvt)=signrank(tmparr);
         else
            pv(i,pcvt)=1;
         end
    end
end
hist(pv)
xlswrite(strcat(fo,testtype,'pval.xls'),table2cell([[cell(data.Properties.VariableNames(IDX));idnm] [hdr;num2cell([ln pv])] [id;num2cell(log2data)]]))
