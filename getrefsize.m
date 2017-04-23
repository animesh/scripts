function s = getrefsize(contig)
% Get the size of a reference node assuming name 'refnode_pos1_pos2'

    r = regexp(contig.name,'_','split');

    pos1 = str2num(r{2});
    pos2 = str2num(r{3});
    
    if pos1 >= pos2
        s = 0;
    else
        s = pos2 - pos1;
    end



end