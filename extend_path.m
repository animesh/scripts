function p = extend_path(adj,contig,overlap,p,forbidden_node,direction, min_len, min_ident)
   % Greedily extend from node until no further options
   % Ignore reference nodes
   %
   % INPUT:
   % adj            Adjency matrix
   % contig         Contig descriptions
   % p              Assembly path to be extended
   % forbidden_node Node to where no extension is allowed (for split and extend function)
   % direction      Direction of extension
   % min_len        Minimum length of the alignment (default: 400)
   % min_ident      Minimum percentage identity of the alignment (default: 99%)
   %
   % OUTPUT:
   % p              Extended path
   
   % Set defaults
   if nargin < 8
       min_ident = 99;
        if nargin < 7
            min_len = 400;
        end
   end
       
   % Check if contig and adjency are of same size
   if length(contig) ~= size(adj,1) || length(contig) ~= size(adj,2)
       error('contig and adjency matrix have to be the same size')
   end
   
   % Check if direction input is correct
   if isequal(direction,'backward')
       adj = adj';
       p = p(end:-1:1);
   elseif ~isequal(direction,'forward')
       error('No valid direction specified');
   end
   
   while 1
       % Find node to go to
       nodes_connected = find(adj(p(end),:)~=0);

       % Exclude forbidden node
       nodes_connected = setdiff(nodes_connected, forbidden_node);
       
       % Throw out reference nodes
       ref_nodes_pos  = ismember(arrayfun(@(x) x.assembly, contig(nodes_connected), 'UniformOutput', false), 'reference');
       nodes_connected = nodes_connected(~ref_nodes_pos);

       % Filter alignments of too low quality to extend
       for c = length(nodes_connected):-1:1
           
           % Get overlap entry
           ovc = GetOverlap(overlap,contig(nodes_connected(c)).name, contig(p(end)).name);
           if ~isequal(size(ovc),[1 1])
               error('Number of overlap entries for a pair of two nodes is not equal to one');
               
           % Filter on alignment length
           elseif ((ovc.LEN1 + ovc.LEN2) / 2) < min_len
               nodes_connected(c) = [];
               continue;
               
           % Filter on alignment identity
           elseif ovc.IDY < min_ident
               nodes_connected(c) = [];
           end
       end
               
       
       % Stop if there is no valid possibility
       if isempty(nodes_connected)
           break;
       end
       
       % Extend to edge with highest score
       [~, pos]  = max(adj(p(end),nodes_connected));
       next_node = nodes_connected(pos);
       p = [p next_node];
   end
   
   % Put p back in oritional orientation
   if isequal(direction,'backward')
       p = p(end:-1:1);
   end
   
end