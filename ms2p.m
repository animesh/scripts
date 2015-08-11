%%  List of monoisotopic mass of fragments for inclusion/exclusion input to Elite orbitrap

fo='X:\Results\Alexey\peptides.txt';
fw=[fo,'.pepmonoisomasslist','.txt'];

peph=fopen(fo);
pep=textscan(peph,'%s');
pepw = fopen(fw,'w');

em=0.0005485799094;
pm=1.007276466812;

pepmol=zeros(size(pep{1},1),1);
for i = 1:size(pep{1},1)
    i
    aa=pep{size(pep{1},2)}{i};
    HI=proteinpropplot(aa);
    RT =-2.6687 + 0.4954 * sum(HI.Data)/ length(HI.Data); % http://hs2.proteome.ca/SSRCalc/SSRCalcX.html
    WRT=5;
    [MD, Info, DF] =isotopicdist(aa,'showplot', false);
    pepmol(i)=Info.MonoisotopicMass;
    notes=[int2str(i),'-',aa,'-',int2str(size(aa,2)),'-',int2str(molweight(aa))];
    fprintf(pepw,'%6.6f\t%6.6f\t%6.6f\t%s-%s\n', ...
      (Info.MonoisotopicMass+2*pm)/2,RT-WRT/2 ,RT+WRT/2 , notes, int2str(2));
    fprintf(pepw,'%6.6f\t%6.6f\t%6.6f\t%s\n',(Info.MonoisotopicMass+3*pm)/3,RT-WRT/2 ,RT+WRT/2 , notes);
end

fclose(peph);
fclose(pepw);

%% pep to fas

fo='X:\Results\Alexey\peptides.txt';
fw=[fo,'.fasta'];

peph=fopen(fo);
pep=textscan(peph,'%s');
pepw = fopen(fw,'w');

for i = 1:size(pep{1},1)
    aa=pep{size(pep{1},2)}{i};
    fprintf(pepw,'>PEP %d LEN %d \n%s\n',i, size(aa,2), aa);
end

fclose(peph);
fclose(pepw);

