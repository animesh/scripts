function [Psplitted] = split_and_extend(adj, p, contig,overlap, max_len, min_alen, min_ident, max_backtrack_depth, crit)
% SPLIT_AND_EXTEND Splits a chromosome at large pseudo nodes
%
% INPUT
% adj       Adjency matrix
% p         Assembly path to be splitted and extended
% contig    The contigs in the adjency matrix
% max_len   The maximum size of a pseudo node
% min_alen  The minimum alignment length to extend a path
% min_ident The minimum identity to extend a path
% max_backtrack_depth
% crit      What criterion to use to decide if the path is better 
%          {'weigth', 'totalcontiglength'}
% 
%
% OUTPUT
% Psplitted Cell array with splitted assembly paths


    if nargin < 9
        crit = 'totalcontiglength';
        if nargin < 7
            min_ident = 98;
            if nargin < 6
                min_alen = 300;
            end
        end
    end


    Psplitted = {};   
    splpositions = split_positions(p, contig, max_len);
    
    if length(splpositions) < 1
        Psplitted = p;
        return;
    end
    
    
    while 1
        
        splposition = splpositions(1);
        
        % Get the new two contigs
        [p1, p2] = split_path(adj, contig, p, splposition, max_backtrack_depth);
        
        % Calcultate weights of new and old paths
        w1_new = getweight(adj,p1);
        w2_new = getweight(adj,p2);
        w1_old = getweight(adj,p(1:splposition-1));
        w2_old = getweight(adj,p(splposition+1:end));
        
        % Check if they're better than the old solution
                
        if isequal(crit, 'totalcontiglength')
            sizeold = sum(cell2mat({contig(p(splposition+1:end)).size}));
            sizenew = sum(cell2mat({contig(p2).size}));
            better  = logical(sizeold < sizenew);
        elseif isequal(crit, 'weigth')
            better = logical((w1_new + w2_new) > (w1_old + w2_old));
        else
            better = true;
            warning('No known criterion for extended path evaluation. Accepting all paths');
        end
            
        if better
            Psplitted = [Psplitted; p1];
            p         = p2;
            
            % If there were more split position, calculate new position,
            % else we're done.
            splpositions = split_positions(p, contig, max_len);
            if length(splpositions) < 1
                Psplitted = [Psplitted; p];
                break
            end
            
        % Else go on with the old solution    
        else
            
            Psplitted = [Psplitted; p(1:splposition-1)];
            p         = p(splposition+1:end);
            
            % If there were more split position, go to the next
            if length(splpositions) > 1
                splpositions = split_positions(p, contig, max_len);
            else
                Psplitted = [Psplitted; p];
                break
            end
                
        end
 
    end
    
    
    function [p1_new, p2_new] = split_path(adj, contig,p,splpositon,max_backtrack_depth)
    
        % Get first branchpoint on the path before and after the splitpoint
        % suc_node and pred_node are the node succeeding and preceeding the
        % branchpoints (which should be avoided in extension step)
        [p1 suc_node ]     = backtrack_to_branch(adj,contig,p,splpositon,max_backtrack_depth);
        [p2_inv pred_node] = backtrack_to_branch(adj',contig,p(end:-1:1),length(p)-splpositon+1,max_backtrack_depth);
        p2                 = p2_inv(end:-1:1);

        % Extend the paths greedily, avoiding the former path and pseudo
        % (reference) nodes.
        p1_new = extend_path(adj,contig,overlap,p1,suc_node, 'forward',min_alen,min_ident );
        p2_new = extend_path(adj,contig,overlap,p2,pred_node,'backward',min_alen,min_ident);
        
    end


    function pos = split_positions(p, contig, max_len)
       % Find reference node bigger then max_len 
       
       % Reference nodes in path
       pos = find(ismember(arrayfun(@(x) x.assembly, contig(p), 'UniformOutput', false), 'reference'));
              
       % Nodes larger than max_len
       for ri = length(pos):-1:1
           if getrefsize(contig(p(pos(ri)))) <= max_len
               pos(ri) = [];
           end
       end
    end

    

    function [p1 last_node] = backtrack_to_branch(adj,contig,p,splpositon, max_backtrack_depth)
       % Backtrack to first branch to a non-reference
       % p1 is the path up till the brachnode
       % last_node is the node just after the branchnode, in the original
       % path
       
       % By default only one step back is taken
       if nargin < 5
            max_backtrack_depth = 1;
       end
       
       
       no_branch       = true;
       last_node       = p(splpositon);
       p1              = p(1:splpositon-1);
       backtrack_depth = 1;
       
       while no_branch 
           % Find all nodes to with the last node is p1 has an edge
           branch_nodes  = find(adj(p1(end),:) ~= 0);
           % Throw out the node the we came from in the previous round
           branch_nodes  = setdiff(branch_nodes,last_node);
           % Throw out reference nodes
           ref_nodes_pos = ismember(arrayfun(@(x) x.assembly, contig(branch_nodes), 'UniformOutput', false), 'reference');
           branch_nodes  = branch_nodes(~ref_nodes_pos);
           
           % Check if there is an option to go to
           if length(branch_nodes) > 0
               % If yes, we have found branchpoint
               no_branch    = false;
           elseif backtrack_depth < max_backtrack_depth
               % If not, we make the path one step smaller
               last_node       = p1(end);
               p1              = p1(1:end-1);
               backtrack_depth = backtrack_depth + 1;
           end
           
           % If no brach is found up till first node in p or
           % the maximum backtracking depth has been reached
           if isempty(p1) || (backtrack_depth >= max_backtrack_depth)
               p1        = p(1:splpositon-1);
               last_node = p(splpositon);
               return
           end
           
       end
       
       
    end


    function w = getweight(adj,p)
        % Get the weight of a path 'p' through graph 'adj'
        w = 0;
        for pi = 1:length(p)-1
            w = w + adj(p(pi),p(pi+1));
        end
    end

end
