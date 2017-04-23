%% read list

fo='X:\Elite\Alexey\HCD\protlist.txt';
pl=fopen(fo);
pla=textscan(pl,'%s');
fclose(pl);

%hprot=fastaread('X:\FastaDB\uniprot-human-may-13.fasta')

%% compare lists

%hprot.Header==pla{size(pla{1},2)}{1}
%pla{size(pla{1},2)}{1}

%% write retrieved protein sequences

fw=[fo,'.sequence','.fasta'];
protsw = fopen(fw,'w');

for i = 1:size(pla{1},1)
    aa=pla{size(pla{1},2)}{i};
    prot=getgenpept(aa);
    fprintf(protsw,'>PNUM%dName%s%dLEN\t%s\t%s\n%s\n',i, aa, size(prot.Sequence,2), prot.Accession, prot.Definition, prot.Sequence);
end

fclose(protsw);

