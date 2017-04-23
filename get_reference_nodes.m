function [adj, names, name_hash, contig, overlap, deltafiles_ref, Startnode_name, Endnode_name] = get_reference_nodes( ... 
    adj, names, name_hash, contig, overlap, target_chromosome, contig_ref, ... 
    overlap_ref, name_hash_ref, deltafiles_ref, ...
    max_chromosome_dist, distance, clipping_thrs, ref_first, ... 
    Startnode_name, Endnode_name, AllowReverse)
% get_reference_nodes add nodes to the adjency graph based on a reference
% chromosome
%
% 
%

    % Align all contigs in 'contig_sets_fasta' to the reference chromosome 
    % [contig_ref, overlap_ref, name_hash_ref, deltafiles_ref] = align_contigs_sets(ref_genome_fasta, contig_sets_fasta, contig_set_names, quality, clipping_thrs, z_weights, distance,max_chromosome_dist);
    
    % If start and end node were not provided, they can be obtained here by
    % creating a tiling
    % Create tiling
    if isequal(Startnode_name, '') || isequal(Endnode_name, '')
        
        % Get the tiling results for the target chromosome
        unix(['show-tiling -v 80 out2.delta | sed -n ''/^>[\s]*' target_chromosome '/,/>/p'' | grep -v \> > tiling.txt']);
        fid = fopen('tiling.txt');
        tiling = textscan(fid,'%d%d%d%d%f%f%c%s','Delimiter','\t');
        fclose(fid);
        
        if length(tiling{1}) ==0
            error('No tiling possbile with provided contigs for reference')
        end
        if isequal(Startnode_name, '')
            Startnode_name = tiling{8}{1};
        end
        if isequal(Endnode_name, '')
            Endnode_name   = tiling{8}{end};
        end
    end
    
    
    if nargin > 14
        if isKey(name_hash, Startnode_name)
            Startnode = name_hash(Startnode_name);
        else
            Startnode = nan;
        end
        if isKey(name_hash, Endnode_name)
            Endnode = name_hash(Endnode_name);
        else
            Endnode = nan;
        end 
    end

    % Optimize the chromosomal distance needed to connect the start and end 
    % components in the graph
    if isequal(max_chromosome_dist, 'opt')
        
        if nargin < 15
            error('When ''opt'' is specified for maximum chromosomal distance, Startnode and Endnode have to be specified');
        end   
        
        % If already connected, no reference nodes needed
        if (~isnan(Startnode) && ~isnan(Endnode)) && isconnecteddirect(adj, names, name_hash, contig, overlap, Startnode_name, Endnode_name) %isconnected(adj, Startnode, Endnode)
            return;
        else
            [adj,names, name_hash, contig, overlap] = optimize_chrom_dist(clipping_thrs, adj, names, name_hash, contig, overlap, contig_ref, overlap_ref, name_hash_ref, distance, Startnode_name, Endnode_name, chromosome_fasta, AllowReverse);
        end
        
    elseif isequal(max_chromosome_dist, 'tiling')
        [adj,names, name_hash, contig, overlap] = PseudoNodesFromTiling(clipping_thrs, adj, names, name_hash, contig, overlap, contig_ref, overlap_ref, name_hash_ref, distance, Startnode_name, Endnode_name, AllowReverse, target_chromosome, ref_first);
        
    elseif isequal(max_chromosome_dist, 'fuzzytiling')
        [adj,names, name_hash, contig, overlap, deltafiles_ref] = PseudoNodesFromFuzzyTiling(clipping_thrs, adj, names, name_hash, contig, overlap, contig_ref, overlap_ref, name_hash_ref, distance, Startnode_name, Endnode_name, chromosome_fasta, deltafiles_ref);
    
    % If distance is provided, just add the reference nodes with that maximum distance    
    else
        % Find pairs of contigs that align close to each other on the reference
        [pairs] = find_pairs(contig_ref, overlap_ref, name_hash_ref, clipping_thrs, max_chromosome_dist, -inf, adj, name_hash);
        % Add these pairs the the adjency matrix
        [adj, names, name_hash, contig, overlap] = add_ref_nodes_to_adj(adj, names, name_hash, contig, overlap, contig_ref, overlap_ref, name_hash_ref, pairs, distance);         

    end
    
 
    % Save orientation of the contigs to help directing the graph
    contig = SetPreferredOrientation(contig, deltafiles_ref);
    
    function contig = SetPreferredOrientation(contig, deltafiles_ref)
        % Determine orientation based on alignment to reference.
        for ci = 1:size(deltafiles_ref,2)
            if isKey(name_hash,deltafiles_ref(ci).Q)
                if deltafiles_ref(ci).S2 < deltafiles_ref(ci).E2
                    contig(name_hash(deltafiles_ref(ci).Q)).preferred_orient = 53;
                else
                    contig(name_hash(deltafiles_ref(ci).Q)).preferred_orient = 35;
                end
            end
        end 
    end


    function connected = isconnected(adj, Startnode, Endnode)
        % Check if Endnode is reachable from startnode
        d = dfs(adj, Startnode,[],Endnode);
        connected = (d(Endnode)~=-1);
    end
        
    


end
