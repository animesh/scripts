%% LODIST from http://online.liebertpub.com/doi/full/10.1089/cmb.2011.0052

[lcs sas na]=PairLcs;%('C:\Users\animeshs\SkyDrive\matlab_toolbox\LODIST\testseqs.fasta')
[distmatrix,asydistmatrix]=DistMat(lcs,[500,50],3)

%% Ecoli genomes

[lcs sas na]=PairLcs