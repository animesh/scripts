fo='Y:\felles\PROTEOMICS and XRAY\Ani\Voin\Supplementary wilcoxon.xlsx'
testtype=' WSRT'
[data,id,~]=xlsread(fo)
idx=3;
edx=20;
jmp=3;
pv=zeros(size(data,1),(edx-idx+1)/jmp)
hdr=''
for j = idx:jmp:edx
    pcvt=j/jmp
    st=j
    en=j+jmp-1
    hdr=[hdr strcat(id(1,j),num2str(j),testtype)]
    for i = 1:size(data,1)
         if sum(isnan(data(i,st:en)))<(en-st+1)
            pv(i,pcvt)=signrank(log2(data(i,st:en)/100));
            %pv(i,pcvt)=signrank(data(i,st:en));
         else
            pv(i,pcvt)=1;
         end
    end
end
hist(pv)
xlswrite(strcat(fo,testtype,'un.xls'),[hdr;num2cell(pv)])
