function [overlap, contig, names, name_hash] = filter_containment_edges(overlap, contig, names, clipping_thrs)
% filter_containment_edges Simplify adjency graph by removing containment
% edges from the 'overlap' list
%
% INPUT 
% (overlap, contig, names, name_hash, clipping_thrs, z_scores, filter_type)
% 
% OUTPUT
% [overlap, contig, names, name_hash, z_scores]


    [overlap] = filter_overlap(overlap, contig, clipping_thrs);
    [contig, names, name_hash] = filter_contig_and_name(overlap, contig, names);
    

    function [overlap] = filter_overlap(overlap, contig, clipping_thrs)

        S1    = cell2mat({overlap.S1});
        E1    = cell2mat({overlap.E1});
        S2    = cell2mat({overlap.S2});
        E2    = cell2mat({overlap.E2});
        LENQ  = cell2mat({overlap.LENQ});
        LENR  = cell2mat({overlap.LENR});
        
        % Reference
        to_delete1 = ((S1 - clipping_thrs < 0) .* (LENR - E1 - clipping_thrs < 0)) + ((E1 - clipping_thrs < 0) .* (LENR - S1 - clipping_thrs < 0));
        
        % Query
        to_delete2 = ((S2 - clipping_thrs < 0) .* (LENQ - E2 - clipping_thrs < 0)) + ((E2 - clipping_thrs < 0) .* (LENQ - S2 - clipping_thrs < 0));

        to_delete = (to_delete1 + to_delete2);
        
        overlap  = overlap(to_delete==0);
        
        %{
        for oi = 1:size(overlap,2)
            
            % If the begin of the contig and the end of the contig are
            % aligned, the contig R is contained. Check this for both the
            % normal and reverse complement
            if     (overlap(oi).S1 - clipping_thrs < 0 && contig(name_hash(overlap(oi).R)).size - overlap(oi).E1 - clipping_thrs < 0)... 
                || (overlap(oi).E1 - clipping_thrs < 0 && contig(name_hash(overlap(oi).R)).size - overlap(oi).S1 - clipping_thrs < 0)
                to_delete(oi) = 1;
                
            elseif (overlap(oi).S2 - clipping_thrs < 0 && contig(name_hash(overlap(oi).Q)).size - overlap(oi).E2 - clipping_thrs < 0)... 
                || (overlap(oi).E2 - clipping_thrs < 0 && contig(name_hash(overlap(oi).Q)).size - overlap(oi).S2 - clipping_thrs < 0)
                to_delete(oi) = 1;
                       
            end

        end
        
        overlap  = overlap(~to_delete);
        z_scores = z_scores(~to_delete,:);
        %}
        
    end



end

