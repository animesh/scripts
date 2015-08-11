function s_counts = getGeneCounts(s_sam_file, genes, chrs)
% Return a cell array of vectors containing the read counts.
% s_sam_file - Sorted SAM file name
% genes      - DataMatrix object containing these columns in such order: 
%               gene names or ids, 
%               chromosome name,
%               gene start(bp), 
%               gene end(bp)
% chrs       - vector of reference numbers.

% Create BioindexedFile object of the sorted SAM file
s_bif = BioIndexedFile('sam',               s_sam_file,...
                       'IndexedByKeys',     false,...
                       'MemoryMappedIndex', false,...
                       'Verbose',           false);
                             
% Obtain a list of all the reference names presents in s_sam_file.                            
s_ref = getDictionary(s_bif);                         

% Loop through each queried references to get counts.
s_counts_cell = cell(numel(chrs),1);
for iloop = 1:numel(chrs)
    chrN = chrs(iloop);
    s_chr_bm = BioMap(s_bif, 'SubsetReference', s_ref{chrN});
    chr_genes = genes(genes(:, 1)==chrN, :);
    s_counts_cell{iloop} = s_chr_bm.getCounts(chr_genes.(':')(2),...
                                              chr_genes.(':')(3),...
                                              'independent', true);
end

% Convert to a vector.
s_counts = cell2mat(s_counts_cell);
end