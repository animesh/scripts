function adj = rank_reference_edges(adj,contig,quality)
% Add some extra penalty score to get be able to distinct between different
% reference edges when finding a path
%

% TODO extend this function to also make distinction between lengths

% Check the number of assemblies and rank them accoording to quality
assembly_names = keys(quality);
quality_array = [];
for i = 1:length(assembly_names)
    quality_array = [quality_array quality(assembly_names{i})];
end

[quality_array, ind] = sort(quality_array,'descend');
assembly_names = assembly_names(ind);

% Make an array with extra penalties to be added
extra_penalty = cell(1,length(assembly_names));
pen = -0.1;
for i = 1:length(assembly_names)
    extra_penalty{i} = pen;
    pen = pen - .1;
end

% Extra penalty per assembly
penalty_hash = containers.Map(assembly_names,extra_penalty);

% matrix to hold the penalties
penalty_mat = -inf(size(adj));

% Find all links to a reference nod
[x,y] = find(adj == -10);

for c = 1:length(x)

    % Only consider links from normal node to reference node
    if isequal(contig(x(c)).assembly,'reference')
        continue
    end
    
    node     = x(c);  % Normal node      
    ref_node = y(c);  % Referende node

    % Find all node accesible from this reference node
    nodes_to_target = find(adj(ref_node,:));
    nodes_to_target = setdiff(nodes_to_target,node);

    % Penalty to be added to the outgoing edge of 'node'
    highest_penalty = -inf; % Higher value means less penalty (z-score)

    % Add penalty values from reference to other connencted nodes
    % and keep track of the best assembly the reference node links to
    for i = 1:length(nodes_to_target)
        pen_temp = penalty_hash(contig(nodes_to_target(i)).assembly);
        penalty_mat(ref_node, nodes_to_target(i)) = pen_temp;
        if pen_temp > highest_penalty
            highest_penalty = pen_temp;
        end
    end
    
    % The outgoing node gets the best penalty found in previous loop
    penalty_mat(node,ref_node) = highest_penalty;
    penalty_mat(ref_node,node) = penalty_hash(contig(node).assembly);
end

% Add penalties the the graph
penalty_mat(isinf(penalty_mat)) = 0;
penalty_mat(adj==0) = 0; % just to be sure to make no new links
adj = adj + penalty_mat;

    










% Give each assembly a quality penalty for the reference nodes
% -0 for velvet
% -.1 for s288c
% -.2 for YJM789



% Get all nodes that have an edge



% Loop through node and add some variable to the different assemblied
 
