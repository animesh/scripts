function [pred] = greedy_longest_path(G, start_node)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    
    % We want to use Dijkstra to find the longest paths.
    % Since Dijkstra doesn't work with negative values,
    % we convert our weights to M - w + 1, where M is the
    % maximum weight in the graph, w is an arbitrary weight.
    % We add 1, since if w = M, we'll end up with a weight of
    % zero.
    inverted_G = max(max(G)) - G(G~=0) + 1;
 
    [D pred] = dijkstra(inverted_G, start_node);
end

