function [adj,names, name_hash, contig, overlap] = optimize_chrom_dist(clipping_thrs, adj, names, name_hash, contig, overlap, contig_ref, overlap_ref, name_hash_ref, distance, Startnode, Endnode, chromosome_fasta,AllowReverse)
% Optimize the maximum distance allowed bewteen two contigs to connect them
% with a reference node.
%

    % Try to find the mimimum distance allowed to connect to nodes with
    % a reference node. '0' is useful for finding contigs that overlap
    % when aligned to the reference (but not enough to be found by
    % nucmer)
    dist_steps = [0 100 200 300 400 500 1000 2000 3000 5000 10000 1000000 2000000 3000000 5000000 10000000 20000000];
    
    
    % Distance bonus, to give contigs at larger distance from each other a
    % lower edge weight
    dist_bonus = -2;
    
    [adj,names, name_hash, contig, overlap] = get_bounds(clipping_thrs, ...
            adj, names, name_hash, contig, overlap, contig_ref, overlap_ref, ...
            name_hash_ref, distance, dist_steps, ...
            Startnode, Endnode, chromosome_fasta, AllowReverse);
    
    
        
 
    function [adj,names, name_hash2, contig, overlap] = get_bounds(clipping_thrs, adj, names, name_hash, contig, overlap, contig_ref, overlap_ref, name_hash_ref, distance, dist_steps , Startnode_name, Endnode_name, chromosome_fasta,AllowReverse)
        % UPPER BOUND first observed connection of start and end
        % LOWER BOUND One interval step before UPPER BOUND
        
        nr_of_steps = length(dist_steps);
                
        for si = 1:nr_of_steps
            max_chromosome_dist = dist_steps(si);
            if max_chromosome_dist == 0
                min_chromosome_dist = -inf;
            else
                min_chromosome_dist = dist_steps(si-1)+1;
            end
        
            fprintf('Connecting nodes at a distance between %d and %d on the reference\n',min_chromosome_dist,max_chromosome_dist);
            
            % Create new name_hash (alternatively you can make a real copy, don't just copy the pointer)
            if ~isempty(names)
                name_hash2 = make_hash(names);
            else
                name_hash2 = containers.Map;
            end
            [adj,names, name_hash2, contig, overlap] = get_adj_with_ref_nodes(clipping_thrs, adj, names, name_hash2, contig, overlap, contig_ref, overlap_ref, name_hash_ref,  distance, max_chromosome_dist, min_chromosome_dist, Startnode_name, Endnode_name, chromosome_fasta, AllowReverse);
            
            % Check if there is a path from Start to End
            if isKey(name_hash2, Startnode_name) && isKey(name_hash2, Endnode_name)
                if isconnected(adj, names, name_hash2, contig, overlap, Startnode_name, Endnode_name)
                   return;
                end
            end
        end
    end
    

    function connected = isconnected(adj, names, name_hash2, contig, overlap, Startnode_name, Endnode_name)
        Startnode = name_hash2(Startnode_name);
        Endnode   = name_hash2(Endnode_name);
        
        % Get initial local optimum using Dijkstra on inverted weight matrix
        p = get_initial_solution(adj,Startnode,Endnode);

        if isequal(p,-1)
            connected = false;
            return
        else        
            [adj_direct] = direct_graph(adj,overlap, contig, names, name_hash2, Startnode, p, false);
            % Check if Endnode is reachable from startnode
            d = dfs(adj_direct, Startnode,[],Endnode);
            connected = (d(Endnode)~=-1);
        end
        

    end
        

    function [adj,names, name_hash, contig, overlap] = get_adj_with_ref_nodes(clipping_thrs, adj, names, name_hash, contig, overlap, contig_ref, overlap_ref, name_hash_ref, distance, max_chromosome_dist, min_chromosome_dist, Startnode_name, Endnode_name, chromosome_fasta,AllowReverse) 

        % Find pairs of contigs that align close to each other on the reference
        %[pairs] = find_pairs(contig_ref, overlap_ref, name_hash_ref, clipping_thrs, max_chromosome_dist, min_chromosome_dist, adj, names, name_hash, contig, overlap, 10, Startnode_name, Endnode_name);
        
        pairs = GetPairsSpanningUnmappedRef(contig_ref, overlap_ref, name_hash_ref, chromosome_fasta, clipping_thrs, min_chromosome_dist, max_chromosome_dist,AllowReverse);
        
        % Add these pairs the the adjency matrix
        [adj, names, name_hash, contig, overlap] = add_ref_nodes_to_adj(adj, names, name_hash, contig, overlap, contig_ref, overlap_ref, name_hash_ref, pairs, distance+dist_bonus);
        dist_bonus = dist_bonus-0.1;

    end


    function p = get_initial_solution(G, start_node, end_node)
        % We want to use Dijkstra to find the longest paths.
        % Since Dijkstra doesn't work with negative values,
        % we convert our weights to M - w + 1, where M is the
        % maximum weight in the graph, w is a arbitrary weight.
        % We add 1, since if w = M, we'll end up with a weight of
        % zero.
        inverted_G = invert_adjency_matrix(G);

        [D pred] = dijkstra(inverted_G, start_node);
        
        if isinf(D(end_node))
            p = -1;
            return;
            %error('No path from start to end node found');
        end
        
        p = build_path(pred, end_node);   % convert predecessor list to path 
    end

end
