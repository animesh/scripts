function [pos] = filter_end_of_contig(contig_start,contig_end,contig_length,dist)
% FILTER_END_OF_CONTIG Selects contigs that overlap end of contig
%
% Rationale: The query sequence should be mapped near the start or end of the
% reference sequence in order to find correct overlap
%
% INPUT
% contig_start : start position of alignment on contig 
% contig_end   : end position of alignment on contig
% contig_length: length of contig
% dist         : Maximum distance from start or end of contig
%
% OUTPUT    : 
% POS : positions which fulfill filtering criteria (the 'good' ones)
%       (logical)
%

s = length(contig_start); % size of data set

pos = logical(zeros(s,1));

for i = 1:s
    
    if (contig_start(i) - dist) <= 0 || (contig_end(i) + dist) >= contig_length(i)
        pos(i) = true;
    end

end