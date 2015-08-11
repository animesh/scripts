function [overlap, contig, names, name_hash] = filter_dove_tails(overlap, contig, names, clipping_thrs, filter_type)
% Filter end-to-end overlaps
% filter_type 'single' only filters query contigs, 'double' filters both

     % Check implemented filter_types
     implemented_types = {'single','double'};
     if ~ismember(filter_type,implemented_types)
         error('Not an expected filter type given');
     end


    [overlap] = filter_overlap(overlap, contig, clipping_thrs, filter_type);
    [contig, names, name_hash] = filter_contig_and_name(overlap, contig, names);
    

    function [overlap] = filter_overlap(overlap, contig, clipping_thrs, filter_type)

        %to_delete = zeros(1,size(overlap,2));
        
        sizes = cell2mat({contig.size});
        S1    = cell2mat({overlap.S1});
        E1    = cell2mat({overlap.E1});
        S2    = cell2mat({overlap.S2});
        E2    = cell2mat({overlap.E2});
        LENQ  = cell2mat({overlap.LENQ});
        LENR  = cell2mat({overlap.LENR});
        Rs    = {overlap.R};
        Qs    = {overlap.Q};
        
        
        if isequal('double',filter_type)
                % Check dove tail on reference contig
                to_delete1 = ((S1 - clipping_thrs > 0) .* ((E1 + clipping_thrs) < LENR)) .* ((E1 - clipping_thrs > 0) .* ((S1 + clipping_thrs) < LENR));
        end
        
        
        if isequal('single',filter_type) || isequal('double',filter_type)
            % Check if the alignment is not near the begin or end of the 
            % query contig, then delete    
            to_delete2 = ( (S2 - clipping_thrs > 0) .* ((E2 + clipping_thrs) < LENQ))  .* ((E2 - clipping_thrs > 0) .* ((S2 + clipping_thrs) < LENQ));
        end
        
        if isequal('double',filter_type)
            to_delete = to_delete1 + to_delete2;
        else
            to_delete = to_delete2;
        end
        
        overlap  = overlap(to_delete==0);

        %{
        for oi = 1:size(overlap,2)
            
            if isequal('double',filter_type)
                % Check if the alignment is not near the begin or end of the
                % reference contig, then delete
                
                
                if   (overlap(oi).S1 - clipping_thrs > 0 && (overlap(oi).E1 + clipping_thrs) < contig(name_hash(overlap(oi).R)).size) ...
                  && (overlap(oi).E1 - clipping_thrs > 0 && (overlap(oi).S1 + clipping_thrs) < contig(name_hash(overlap(oi).R)).size)
                    to_delete(oi) = 1;
                end
                
                
            end

            if isequal('single',filter_type) || isequal('double',filter_type)
                % Check if the alignment is not near the begin or end of the 
                % query contig, then delete    
                if (overlap(oi).S2 - clipping_thrs > 0 && (overlap(oi).E2 + clipping_thrs) < contig(name_hash(overlap(oi).Q)).size) ...
                 && (overlap(oi).E2 - clipping_thrs > 0 && (overlap(oi).S2 + clipping_thrs) < contig(name_hash(overlap(oi).Q)).size)
                    to_delete(oi) = 1;
                end
            end
        end

        
        overlap  = overlap(~to_delete);
        %z_scores = z_scores(~to_delete,:);
        %}
    end

  
end

