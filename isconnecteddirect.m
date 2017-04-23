function connected = isconnecteddirect(adj, names, name_hash, contig, overlap, Startnode_name, Endnode_name)
    Startnode = name_hash(Startnode_name);
    Endnode   = name_hash(Endnode_name);

    % Get initial local optimum using Dijkstra on inverted weight matrix
    p = get_initial_solution(adj,Startnode,Endnode);

    if isequal(p,-1)
        connected = false;
        return
    else        
        [adj_direct] = direct_graph(adj,overlap, contig, names, name_hash, clipping_thrs, Startnode, p, false);
        % Check if Endnode is reachable from startnode
        d = dfs(adj_direct, Startnode,[],Endnode);
        connected = (d(Endnode)~=-1);
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