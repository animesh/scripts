function ovi = find_index_in_overlap(contig1, contig2, ov)
    % return overlap index for two contig names        

    if isstruct(ov)
        % Convert overlap struct to cell array
        ov = struct2cell(ov);
        ov = squeeze(ov(1:2,:,:));
    end


    posR1 = ismember(ov(2,:),contig1);
    posQ1 = ismember(ov(1,:),contig2);

    if sum(posR1.*posQ1) == 0
        posR1 = ismember(ov(2,:),contig2);
        posQ1 = ismember(ov(1,:),contig1);
    end

    % position in overlap list
    ovi = find(posR1.*posQ1);
end