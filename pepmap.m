%% create and read file 
%awk '{print ">Pep"NR;print $0}' peppho.txt
%http://www.uniprot.org/uniprot/P05198
prot=fastaread('L:\Elite\LARS\2014\november\Lars Inger Ane Serum\kng1prot.fasta')
peps=fastaread('L:\Elite\LARS\2014\november\Lars Inger Ane Serum\kng1pep.fasta')

%% map
plot([1 length(prot.Sequence)],[1 1],'k-')
ylim([0 size(peps,1)+4])
hold
pos=zeros(size(peps,1),1);
len=zeros(size(peps,1),1);
id=zeros(length(prot.Sequence),1);
for i=1:size(peps,1)
    if exist(strfind(upper(prot.Sequence),upper(peps(i).Sequence)))
        i
        pos(i)=strfind(upper(prot.Sequence),upper(peps(i).Sequence))+0;
        len(i)=length(peps(i).Sequence);
        %plot([pos(i) pos(i)+len(i)],[i+2 i+2],'r-')
        %plot([pos(i) pos(i)+len(i)],[2 2],'b-')
        for j=pos(i):(pos(i)+len(i)-1)
            id(j)=1;
        end
    end
end
hold
covered=sum(id)/length(prot.Sequence)*100

%% check
%http://blast.ncbi.nlm.nih.gov/Blast.cgi#alnHdr_113576
[i chk]=max(pos)
len(chk),pos(chk),upper(peps(chk).Sequence),prot.Sequence

%% view

plot(pos,len,'r.')
%proteinplot(prot.Sequence)

