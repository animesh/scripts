function weighted_z = weighted_z_scores(overlap, contig, name_hash, z_weights, overlap_all, contig_all)
% Calculate weighted z-score
% z = [z_Q_to_R z_R_to_Q] : 
    
    if nargin < 7
        contig_all = contig;
    end

    if nargin < 6
        % Overlap_all are the unfiltered alignments to estimate null distributions
        overlap_all = overlap;
    end

    nr_of_alignments = estimate_nr_of_alignments(contig_all);
    %nr_of_alignments = length(overlap_all);
    
    % Get values for Null distributions
    contig_sizes = cell2mat({contig_all.size});
    alignsizes   = struct2cell(overlap_all);
    alignsizes = cell2mat(squeeze(alignsizes(7:8,:,:)));
    
    
%    if nargin < 5
%        % If nr_of_alignments not specified, estimate them
%        nr_of_alignments = estimate_nr_of_alignments(contig);
%    end

    

    % Calculate the z-scores
    z1 = z_contig_length(overlap,contig_sizes);
    z2 = z_alignment_length(overlap,nr_of_alignments,alignsizes);
    z3 = z_non_aligned_overlap(overlap, overlap_all, nr_of_alignments);
    z4 = z_assembly_quality(overlap, contig, name_hash);

    % Combine z-score in a weighted sum
    weighted_z = weighted_sum(z1,z2,z3,z4,z_weights);
    
    
    
    function weighted_z = weighted_sum(z1,z2,z3,z4,w)
        % Calculate weighted sum of z-scores
        
        if size(w) ~= 4
            w = w';
            if size(w) ~= 4
                error('Not the expected number of weights for the z-scores');
            end
        end
    
        weighted_z = (z1.*w(1) + z2.*w(2) + z3.*w(3) + z4.*w(4)) ...
                     ./ sqrt(w(1)^2+w(2)^2+w(3)^2+w(4)^2);    
    end
    

    function z = z_assembly_quality(overlap, contig, name_hash)
        
        z = zeros(size(overlap,2),2);
        
        % Get assembly qualities for every edge in two directions
        for oi = 1:size(overlap,2)
             z_R_Q = contig(name_hash(overlap(oi).Q)).assembly_quality;
             z_Q_R = contig(name_hash(overlap(oi).R)).assembly_quality;
             z(oi,:) = [z_Q_R z_R_Q];
        end
        
        
        
    end
    

    function [z] = z_contig_length(overlap,contig_sizes)
        
        tic
        total_number_of_contigs = length(contig_sizes);
        
        nr_bigger_then_R = zeros(size(overlap,2),1);
        nr_bigger_then_Q = nr_bigger_then_R;
        
        % Sort to lengths to do a binary search
        ContigLengthsR         = cell2mat({overlap.LENR});
        ContigLengthsQ         = cell2mat({overlap.LENQ});
        [ContigSortedR Ri]     = sort(ContigLengthsR,'descend');
        [ContigSortedQ Qi]     = sort(ContigLengthsQ,'descend');
        [ContigSortedAll Alli] = sort(contig_sizes,'descend');        
        
        fprintf('Calculating z-score for contig length\n');
        
        posAllR = 1;
        posAllQ = 1;
        sizeAll = size(ContigSortedAll,2);
        for oi = 1:size(overlap,2)        
            
            % Look for first entry in sorted array that is smaller than contig length
            while (posAllR <= sizeAll) && (ContigSortedR(oi) <= ContigSortedAll(posAllR))
                posAllR = posAllR + 1;
            end
            nr_bigger_then_R(oi) = posAllR - 1;

            while (posAllQ <= sizeAll) && (ContigSortedQ(oi) <= ContigSortedAll(posAllQ))
                posAllQ = posAllQ + 1;
            end
            nr_bigger_then_Q(oi) = posAllQ - 1;
            

        end
        
        % Undo the sorting
        [UnUsed, Ri] = sort(Ri); 
        [UnUsed, Qi] = sort(Qi);
        nr_bigger_then_R = nr_bigger_then_R(Ri);
        nr_bigger_then_Q = nr_bigger_then_Q(Qi);
        
        % Calculate p-values
        p_Q_R = nr_bigger_then_R./total_number_of_contigs;
        p_R_Q = nr_bigger_then_Q./total_number_of_contigs;
         
        % Add eps for p-values == 0, subtract eps for p-values == 0
        p_Q_R = check_p_values(p_Q_R);
        p_R_Q = check_p_values(p_R_Q);
        
        % Calculate z-scores
        z_Q_R = norminv(1-p_Q_R);
        z_R_Q = norminv(1-p_R_Q);        
        
        z = [z_Q_R z_R_Q];
        
        toc
        
    end



    function z = z_alignment_length(overlap,nr_of_alignments,alignsizes)
        
        tic
        % Matrix for p-values
        %p_Q_R = ones(size(overlap,2),1);
        %p_R_Q = p_Q_R;
        
        Al_R = zeros(size(overlap,2),1);
        Al_Q = Al_R;
        
        [AlRSorted Ri] = sort(cell2mat({overlap.LEN1}),'descend');
        [AlQSorted Qi] = sort(cell2mat({overlap.LEN2}),'descend');
        SizesAllR      = sort(alignsizes(1,:),'descend');
        SizesAllQ      = sort(alignsizes(2,:),'descend');
        
        % Make list of alignment lengths
        %align_lengths = struct2cell(overlap);
        %align_lengths = cell2mat(squeeze(align_lengths(7:8,:,:)));

        fprintf('Calculating z-score for contig length\n');    

        posAllR = 1;
        posAllQ = 1;
        sizeAll = size(SizesAllR,2);        
        for oi = 1:size(overlap,2) 

            
            while (posAllR <= sizeAll) && (AlRSorted(oi) <= SizesAllR(posAllR))  
                posAllR = posAllR + 1;
            end
            Al_R(oi) = posAllR - 1;
            
            while (posAllQ <= sizeAll) && (AlQSorted(oi) <= SizesAllQ(posAllQ))  
                posAllQ = posAllQ + 1;
            end
            Al_Q(oi) = posAllQ - 1;
          
        end
        
        % Undo the sorting
        [UnUsed, Ri] = sort(Ri); 
        [UnUsed, Qi] = sort(Qi);
        Al_R = Al_R(Ri);
        Al_Q = Al_Q(Qi);
        
        p_Q_R = (Al_R ./ nr_of_alignments);
        p_R_Q = (Al_Q ./ nr_of_alignments);
        
        p_Q_R = check_p_values(p_Q_R);
        p_R_Q = check_p_values(p_R_Q);
        
        % Calculate z-scores
        z_Q_R = norminv(1-p_Q_R);
        z_R_Q = norminv(1-p_R_Q);
        
        z = [z_Q_R z_R_Q];
     
        toc
    end

    function z = z_non_aligned_overlap(overlap, overlap_all, nr_of_alignments)
        % Calculate a-scores for the non-aligned overlap
        
        tic
        % Matrix for p-values
        p = ones(size(overlap,2),1);
        
        % Get the percentage of non-aligned overlap    
        naosAll = get_nao(overlap_all);
        naos    = get_nao(overlap);
        
        nr_nao_bigger = zeros(size(overlap,2),1);
        
        naosAllSorted     = sort(naosAll,'descend');
        [naosSorted naoi] = sort(naos,'descend');


        fprintf('Calculating z-score for contig length\n');

        posAll = 1;
        sizeAll = size(naosAllSorted,2);    
        
        
        % Loop through all edges
        for oi = 1:size(overlap,2)
                    
            
            while (posAll <= sizeAll) && (naosSorted(oi) <= naosAllSorted(posAll))  
                posAll = posAll + 1;
            end
            nr_nao_bigger(oi) = posAll - 1;
            
            
        end
        % Undo the sorting
        [UnUsed, naoi] = sort(naoi); 
        nr_nao_bigger = nr_nao_bigger(naoi);
        
        p = (nr_of_alignments-nr_nao_bigger)./nr_of_alignments;
        
        p = check_p_values(p);
        
        % Calculate z-score from p-values
        z_R_Q = norminv(1-p);
        z_Q_R = z_R_Q;
        
        z = [z_Q_R z_R_Q];
      
        toc
    end


 
    function nao = get_nao(overlap)
        
        % There are the following possibilities
        LEN1 = cell2mat({overlap.LEN1});
        LEN2 = cell2mat({overlap.LEN2});
        
        % Number of bases to clip on both sides of both contigs
        [parallel_aligned_RQ parallel_aligned_QR begin_aligned end_aligned] = ...
            clipping_required(overlap);

        % The long 'clip' part is actually the extension of the contig,
        % only the smallest 'clip' will be clipped when merged
        
        K = min([begin_aligned; end_aligned; parallel_aligned_QR; parallel_aligned_RQ]);
        L = double(LEN1+LEN2) ./ 2; % Average alignment length
        nao = double(K) ./ (L+double(K));
        
    end


    function [parallel_aligned_RQ parallel_aligned_QR begin_aligned end_aligned] = clipping_required(overlap)
    % Calculate the amount of clipping needed when the two contigs in
    % overlap are merged, assuming that the 'dove-tail' filtering is
    % already done and that consequently the smallest overhang will be
    % clippend when merging the two.

    %                        <clip>
    %                         |  | 
    %                         V  V
    %   R.S1 --------------------- R.E1
    %                     ||||
    %              Q.S2  ----------------------- Q.E2
    %                    ^
    %                    |
    %                 <clip>

    
        ContigsizesR = cell2mat({overlap.LENR});
        ContigsizesQ = cell2mat({overlap.LENQ});
        S1           = cell2mat({overlap.S1});
        S2           = cell2mat({overlap.S2});
        E1           = cell2mat({overlap.E1});
        E2           = cell2mat({overlap.E2});
        
        % x---------->
        %         x----------->
        parallel_aligned_RQ = (ContigsizesR - E1) + (S2 - 1);
                
        
        %         x----------->
        % x---------->
        parallel_aligned_QR  = (S1-1) + (ContigsizesQ - E2);
        
        %         x---------->
        % <----------x
        begin_aligned = (S1-1) + (E2-1);
        
        
        % x---------->
        %         <----------x
        end_aligned = (ContigsizesR - E1) + (ContigsizesQ - S2);
        
    end

    function nr_of_alignments = estimate_nr_of_alignments(contig)
        % Calculate the number of alignments made when an all-vs-all
        % alignent would be made with the sets of contigs in 'contig'
        % So, all contigs vs. all contigs, but all sets vs all sets,
        % where a set is all contigs resulting from one assembly
        
        tic
        
        fprintf('Estimating number of possible alignments\n');
        %fprintf('1000 edges of %d processed per dot [',size(overlap,2));    
        
        nr_of_alignments = 0;
        assemblies = containers.Map;
        
        for ci = 1:size(contig,1)
            if isKey(assemblies,contig(ci).assembly)
                assemblies(contig(ci).assembly) = assemblies(contig(ci).assembly) + 1;
            else
                assemblies(contig(ci).assembly) = 1;
            end
        end
        
        k = keys(assemblies);
        
        for k1 = 1:length(k)-1
            for k2 = k1+1:length(k)
                nr_of_alignments = nr_of_alignments + (assemblies(k{k1}) * assemblies(k{k2}));
            end
        end
        
        toc
        
    end

    function p = check_p_values(p)
    % Checks if p-values are not '1' or '0' since this will result in 
    % z-scores of -inf and inf
        
        iszero = p == 0;
        p(iszero) = p(iszero) + eps;
        isone = p == 1;
        p(isone) = p(isone) - eps;
    
    
    end
end