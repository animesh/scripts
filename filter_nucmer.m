function a = filter_nucmer(a,dist)
% FILTER_NUCMER filters nucmer matrix on several properties
% 
% 1. Alignments should overlap an end of one of the two contigs 
% 2. Two contigs can only be aligned once (if more all are deleted)
%
%
% Jurgen Nijkamp

% Find and remove alignments that don't map to the end of a contig
p1 = filter_end_of_contig(a{1},a{2},a{8},dist); % End of reference contigs is overlapped
p2 = filter_end_of_contig(a{2},a{3},a{9},dist); % End of query contig is overlapped
for i = 1:size(a,2)
    a{i} = a{i}(p1|p2);
end

% Find alignments where both ends are mapped to the one contig
uRnames = unique(a{12});
uQnames = unique(a{13});
al = zeros(size(uRnames,1),size(uQnames,1));
for i = 1:size(a{1},1)
    Ri = find(ismember(uRnames,a{12}(i)));
    Qi = find(ismember(uQnames,a{13}(i)));
    al(Ri,Qi) = al(Ri,Qi)+1;
end

% Locate positions in nucmer table
p3 = ones(size(a{1},1),1);
for i = 1:size(a{1},1)
    Ri = find(ismember(uRnames,a{12}(i)));
    Qi = find(ismember(uQnames,a{13}(i)));
    if al(Ri,Qi)>1
        p3(i) = 0;
    end 
end

% Remove alignment that map double
for i = 1:size(a,2)
    a{i} = a{i}(logical(p3));
end

