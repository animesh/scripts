clc;
clear all;
close all;
G1 = 1;  % row number of gene 1 in the data set
G2 = 2;  % row number of gene 2 in the data set
% [filename, pathname] = uigetfile({'*.txt';'*.xls';'*.*'},'Select file');
% gene_raw=load(strcat(pathname,filename));
% gene_raw=xlsread('SigAll.xlsx');
c1 = 3;    % number of samples in class 1
c2 = 3;    % number of samples in class 2
[row, col]=size(gene_raw);
res=zeros(row,row);
for i=1:row
    for j=i:row
        gene_indices=[i j];
        phenotype_indicator=[ones(c1,1);zeros(c2,1)];
        cutoff_distance=1.5;
        syn_v=synergy(gene_indices, cutoff_distance, phenotype_indicator,gene_raw);
        res(i,j)=syn_v;
    end
end
dlmwrite('result.csv',res)
HeatMap(res)
max(max(res))
min(min(res))

