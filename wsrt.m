%[data,id,~]=xlsread('Y:\felles\Voin\===Methodology paper===\Supplementary table MO stats.xlsx')
%[data,id,~]=xlsread('Y:\felles\Voin\===JJN3===\JJN3 for wilcoxon.xlsx')
[data,id,~]=xlsread('Y:\felles\Voin\t24\Copy of t24 for wilcoxon.xlsx')
st=9%6%3%7%4%1%26%21%16%11%6%1;
en=11%8%5%9%6%3%28%23%18%13%8%3;
pvo=pv;
clear pv;
parfor i = 1:size(data,1)
     if sum(isnan(data(i,st:en)))<3
        pv(i)=signrank(log2(data(i,st:en)/100));
        %pv(i)=signrank(data(i,st:en));
     else
        pv(i)=1;
     end
end
hist(pv)
