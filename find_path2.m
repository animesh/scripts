function [P, Pall, Wall] = find_path2(G, begin, finish, max_depth, P, W, Pall, Wall, depth)
% Find all paths from begin to finish recursively
% before running this function, initialize global empty cell arrays called
% Pall and Wall
% 
if ~exist('P', 'var'),
    P = [];
end
if ~exist('W', 'var'),
    W = [];
end
if ~exist('Pall', 'var'),
    Pall = {};
end
if ~exist('Wall', 'var'),
    Wall = {};
end
if ~exist('depth', 'var'),
    depth = 0;
end

if depth > max_depth
    return
end

%global Pall
%global Wall

P = [P begin];

% fprintf('Node is: %d\n',begin)
% pause


    
if begin == finish        % Target node is found!
   if isempty(Pall)       % Pall saves all paths to target node
       Pall = {P};        % Add path to Pall 
       Wall = {W};        % Add weigths to Wall 
   else
       Pall = [Pall; P];  % Add path to Pall   
       Wall = [Wall; W];  % Add weigths to Wall 
   end
   return
end

nodes_connected = find(logical(G(begin,:)));  % Find the nodes connected to begin

for i = 1:length(nodes_connected)          % Extend to all nodes connected to begin
    next_node = nodes_connected(i);        % Extend to node i
    if sum(next_node == P) == 0            % If the node i is in the path, the skip to prevent cycles
        [P2 Pall Wall] = find_path2(G, next_node, finish, max_depth, P, [W G(begin,next_node)], Pall, Wall, depth + 1);  % Find path from next_node
    end
end

return 
    
