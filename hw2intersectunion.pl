memberof(X, [X|T]).
memberof(X, [H|T]) :- memberof(X,T).

%calculates the intersection of 2 sets represented as lists
%calculates an empty list if there is an empty intersection; otherwise
%calculates a list of the elements in the intersection

intersect([],Y,[]).
intersect([H|T],Y,[H|Z]) :- memberof(H,Y), intersect(T,Y,Z).
intersect([H|T],Y,Z) :- intersect(T,Y,Z).

%calculates the union of two sets represented as lists
union([],Y,Y).
union(Y,[],Y).
union([H|T],Y,Z) :- memberof(H,Y), union(T,Y,Z).
union([H|T],Y,[H|Z]) :- union(T,Y,Z).


