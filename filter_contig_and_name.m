function [contig, names, name_hash] = filter_contig_and_name(overlap, contig, names)
    % Throw out contigs that don't occur in the overlap matrix anymore

    c1 = struct2cell(overlap);
    c1 = c1(1:2,:,:);
    c1 = squeeze(c1);

    to_keep = ismember(names,c1);

    contig = contig(to_keep);
    names = names(to_keep);
    name_hash = make_hash(names);

end
    


    
            