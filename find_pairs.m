function [pairs] = find_pairs(contig, overlap, name_hash, clipping_thrs, max_chromosome_dist, min_chromosome_dist, adj, names_adj, name_hash_adj, contig_adj, overlap_adj, max_edges, Startnode_name, Endnode_name)
    % Find nodes that can be connected via a reference node
        % INPUT
        % contig                Contigs aligned to the reference
        % overlap               Alignments of contigs to the reference genome
        % name_hash             The name_hash for the aligned contigs
        % clipping_thrs         Part of sequence not aligned right of A1 or left of A2
        % max_chromosome_dist   Maximum size of a reference node
        % adj                   The Adjency matrix
        % name_hash_adj         The Name hash correxponding to 'adj'
        % max_edges             If two nodes are already connected within
        %                       'max_edges' the two are not considered for a pair 
        %                       to be connected as reference node (default
        %                       6)
        % 
        % OUTPUT
        % pairs                 [node1 node2 A1 A2 A3 A4]
        
        
        %                ---------------       -----------------
        %                          |||||       ||||||
        % ------------------------------------------------------------------------------
        %                          |   |       |    |
        %                          A3  A1      A2   A4
        
        % 
        if nargin < 10
            max_edges = 6;
        end
            
         
        % [node1 node2 refstart refend]
        pairs = {};
        
        % Make adj unweighted for the 'bfs'
        adj_unweighted = adj ~= 0;
        
        % Loop through all overlaps
        for oi = 1:size(overlap,2)-1
            
            [upstream_oi downstream_oi] = down_or_upstream(overlap, oi, name_hash, contig, clipping_thrs);
                        
            % Loop through all overlaps further down the list
            for oj = oi+1:size(overlap,2)
            
                % If the nodes are already connected in the graph no reference node is needed
                % Check within 6 edges from node 'oi' for node 'oj'
                %dist_oi_oj = find_dist(adj,names_adj, name_hash_adj,contig_adj, overlap_adj, overlap(oi).Q, overlap(oj).Q);
                %if dist_oi_oj <= max_edges && dist_oi_oj > 0, continue, end;
                 
                [upstream_oj downstream_oj] = down_or_upstream(overlap, oj, name_hash, contig, clipping_thrs);
                
                if upstream_oi && downstream_oj
                    if overlap(oj).E1 < overlap(oi).E1 && overlap(oj).S1 < overlap(oi).S1
                        % If 'oj' is upstream of 'oi' && 'oi' is not contained in 'oj'
                        if overlap(oi).S1 - overlap(oj).E1 < max_chromosome_dist && overlap(oi).S1 - overlap(oj).E1 >= min_chromosome_dist
                            % If not farther apart then the maximum distance
                            
                            % If the nodes are already connected in the graph no reference node is needed
                            % Check within 6 edges from node 'oi' for node 'oj'
                            % And the nodes should be farther apart than the maximum distance
                            
                            %dist_oi_oj = find_dist(adj,names_adj, name_hash_adj,contig_adj, overlap_adj, Startnode_name, overlap(oi).Q);
                            %if dist_oi_oj <= max_edges && dist_oi_oj > 0, continue, end;
                            
                            infedge = informative_edge(adj,names_adj, name_hash_adj ,contig_adj, overlap_adj, overlap(oj).Q, overlap(oi).Q, Startnode_name, Endnode_name, max_edges, adj_unweighted);
                            if ~infedge, continue, end;
                            
                            
                            % Add pairs to the list
                            pairs = [pairs; {overlap(oj).Q overlap(oi).Q overlap(oj).E1 overlap(oi).S1 overlap(oj).S1 overlap(oi).E1} ];
                        end
                    end     
                end
                
                if downstream_oi && upstream_oj
                    if overlap(oi).S1 < overlap(oj).S1 && overlap(oi).E1 < overlap(oj).E1
                        % If 'oj' is downstream of 'oi' && 'oi' is not contained in 'oj'
                        if overlap(oj).S1 - overlap(oi).E1 < max_chromosome_dist && overlap(oj).S1 - overlap(oi).E1 >= min_chromosome_dist
                            % If not farther apart then the maximum distance
                            
                            % If the nodes are already connected in the graph no reference node is needed
                            % Check within 6 edges from node 'oi' for node 'oj'
                            % And the nodes should be farther apart than the maximum distance
                            
                            %dist_oi_oj = find_dist(adj,names_adj, name_hash_adj,contig_adj, overlap_adj, Startnode_name, overlap(oj).Q);
                            %if dist_oi_oj <= max_edges && dist_oi_oj > 0, continue, end;                          
                            
                            infedge = informative_edge(adj,names_adj, name_hash_adj ,contig_adj, overlap_adj, overlap(oi).Q, overlap(oj).Q, Startnode_name, Endnode_name, max_edges, adj_unweighted);
                            if ~infedge, continue, end;                            
                            
                            % Add pairs to the list
                            pairs = [pairs; {overlap(oi).Q overlap(oj).Q overlap(oi).E1 overlap(oj).S1 overlap(oi).S1 overlap(oj).E1} ];
                        end                        
                        
                    end
                    
                end
            end
        end
        
        
    function [U D] = down_or_upstream(overlap, nr, name_hash, contig, clipping_thrs)
        % Check which end of a contig maps to the reference
        % This information is needed to know whether to look up or
        % downstream for a matching contig to connect via the reference
        
        D = false; % Downstream
        U = false; % Upstream
        
        if overlap(nr).S2 - clipping_thrs <= 0 || (contig(name_hash(overlap(nr).Q)).size - overlap(nr).S2) <= clipping_thrs
            % Is 5' end of contig is aligned to reference, then
            % check upstream of chromosome if it can be
            % connected ti contig 'oj'
            U = true;
        end

        % Check if the rev comp is aligned     ||  Check if the straight contig complement is aligned             
        if overlap(nr).E2 - clipping_thrs <= 0 || (contig(name_hash(overlap(nr).Q)).size - overlap(nr).E2) <= clipping_thrs
            % Is 3' end of contig is aligned to reference, then
            % check downstream of chromosome if it can be connected to
            % contig 'oj'
            D = true;
        end
    end



    function infoedge = informative_edge(adj,names_adj, name_hash_adj ,contig_adj, overlap_adj, nodei_name, nodej_name, Startnode_name, Endnode_name, max_edges, adj_unweighted)
        
        % Check if nodes are in adjency
%         if isKey(name_hash_adj, nodei_name)
%             nodei = name_hash_adj(nodei_name);
%         else
%             infoedge = true;
%             return ;
%         end
%         if isKey(name_hash_adj, nodej_name)
%             nodej = name_hash_adj(nodej_name);
%         else
%             infoedge = true;
%             return ;
%         end 
        
        % Check if start and endnode are in adjency
        nodei_in_adj = isKey(name_hash_adj, nodei_name);
        nodej_in_adj = isKey(name_hash_adj, nodej_name);
        start_in_adj = isKey(name_hash_adj, Startnode_name);
        end_in_adj   = isKey(name_hash_adj, Endnode_name);
        
        
        if nodei_in_adj
            nodei = name_hash_adj(nodei_name);
        end      
        if nodej_in_adj
            nodej = name_hash_adj(nodej_name);
        end             
        if start_in_adj
            Startnode = name_hash_adj(Startnode_name);
        end
        if end_in_adj
            Endnode   = name_hash_adj(Endnode_name);
        end
            
        % Direct subgraphs from Startnode en nodei
        if start_in_adj && nodei_in_adj
            [adj_direct] = direct_graph(adj,overlap_adj, contig_adj, names_adj, name_hash_adj,clipping_thrs, Startnode, nodei, false);
            adj_unweighted_direct = adj_unweighted(adj_direct~=0);
        elseif start_in_adj
            [adj_direct] = direct_graph(adj,overlap_adj, contig_adj, names_adj, name_hash_adj, clipping_thrs, Startnode, [],    false);
            adj_unweighted_direct = adj_unweighted(adj_direct~=0);
        elseif nodei_in_adj
            [adj_direct] = direct_graph(adj,overlap_adj, contig_adj, names_adj, name_hash_adj, clipping_thrs, nodei,     [],    false);
            adj_unweighted_direct = adj_unweighted(adj_direct~=0);
        end
        
              
        % Calculate distance from nodei and startnode to all other nodes
        if nodei_in_adj
            di = bfs(adj_unweighted_direct, nodei);
        end
        if start_in_adj
            ds = bfs(adj_unweighted_direct, Startnode);
        end
        
        % Check if the reference node will add extra information to the
        % graph, or if it just makes it more complex without connecting
        % subgraphs
        if nodei_in_adj
            if nodej_in_adj
                % If there is a path from i to j
                if di(nodej) <= max_edges && di(nodej) > 0
                    infoedge = false;
                    return
                end
            end
            % If there is a path from nodi to Endnode
            if end_in_adj 
                if di(Endnode) ~= -1
                    infoedge = false;
                    return
                end
            end
        end
        
        % If there is a path from start no nodej
        if start_in_adj 
            if nodej_in_adj && ds(nodej) ~= -1
                infoedge = false;
                return
            end
        end
     
        % If all above tests fail the new edge is relevant
        infoedge = true;
        
    end

    function connected = isconnected(adj, Startnode, Endnode)
        % Check if Endnode is reachable from startnode
        d = dfs(adj, Startnode,[],Endnode);
        connected = (d(Endnode)~=-1);
    end


%     function dist = find_dist(adj,names_adj, name_hash_adj ,contig_adj, overlap_adj, nodei_name, nodej_name)
%         
%         % Check if nodes are in adjency
%         if isKey(name_hash_adj, nodei_name)
%             nodei = name_hash_adj(nodei_name);
%         else
%             dist = -1;
%             return ;
%         end
%         if isKey(name_hash_adj, nodej_name)
%             nodej = name_hash_adj(nodej_name);
%         else
%             dist = -1;
%             return ;
%         end 
%         
%         [adj_direct] = direct_graph(adj,overlap_adj, contig_adj, names_adj, name_hash_adj, nodei, [], false);
%         
%         % Calculate distance 
%         [d] = bfs(adj_direct, nodei, nodej);
%         dist = d(nodej);
% 
%     end

%     function connected = isconnected(adj, names, name_hash2, contig, overlap, Startnode_name, Endnode_name)
%         Startnode = name_hash2(Startnode_name);
%         Endnode   = name_hash2(Endnode_name);
%         
%         % Get initial local optimum using Dijkstra on inverted weight matrix
%         p = get_initial_solution(adj,Startnode,Endnode);
% 
%         if isequal(p,-1)
%             connected = false;
%             return
%         else        
%             [adj_direct] = direct_graph(adj,overlap, contig, names, name_hash2, Startnode, p, false);
%             % Check if Endnode is reachable from startnode
%             d = dfs(adj_direct, Startnode,[],Endnode);
%             connected = (d(Endnode)~=-1);
%         end
%         
% 
%     end

end
