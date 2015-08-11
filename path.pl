path(S,S,_).
path(S,End,Edges) :- findEdge(S,Next,Edges,EdgesRest), path(Next, End, EdgesRest).
findEdge(S,N,[(S,N)|Rest],Rest).
findEdge(S,N,[_|R],Rest) :- findEdge(S,N,R,Rest).