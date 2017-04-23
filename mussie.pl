% Oblig 3 - INF121 - Høst 2009

% Mussie E.Mesfin  &  Franklin Jesuthasan


% A. Sequence Alignment -----------------------

alignment(Xs, Ys, [Head | Tail]) :-
           append(_, [Head | Tail1], Xs),
           append(_, [Head | Tail2], Ys),
           alignment(Tail1, Tail2, Tail).
alignment(Xs1, Ys1, []).

% Tester
% ?- alignment([a,c,g,r], [g,y,r], A).
% A = [g, r] ;
% A = [g] ;
% A = [r] ;
% A = [].

% alignment([s,r,y,a,x,m,a],[r,y,m,m,a],A).
% ?- findall( A,alignment([s,r,y,a,x,m,a],[r,y,m,m,a],A), L).
% L = [[r, y, a], [r, y, m, a], [r, y, m], [r, y, m, a], [r, y, m], [r, y, a], [r, y], [r|...], [...|...]|...].



maximum([List], List) :- !.
maximum([H | T], H) :- length(H, A), maximum(T, B), length(B, Max), A > Max, !.
maximum([H | T], B) :- maximum(T, B), !.

% Tester
% ?- maximum([[r, y, a], [r, y, m, a], [r, y, m], [r, y, m, a], [r, y, m], [r, y, a], [r, y]], X).
% X = [r, y, m, a].

% findall(N, alignment(Xs,Ys,N), L).


maxAlignment(Xs,Ys,Alignment) :- 
	   findall(N, alignment(Xs,Ys,N), L),
           maximum(L, Alignment), !.

% Tester
% maxAlignment([a,c,g,r],[g,y,r],A).      
& A = [g, r].

% maxAlignment([s,r,y,a,x,m,a],[r,y,m,m,a],A). Tar lang tid før du får svar
% A = [r, y, m, a]. 




% B. Path search -----------------------------

path(Start, Start, Edges).
path(Start, Target, Edges) :- findPath(Start, Target, Edges, []).
findPath(Start, Target, Edges, _List) :- member((Start, Target), Edges).
findPath(Start, Target, Edges, List) :- member((Start, Temp), Edges), not(member((Start, Temp), List)),
                                        append(([Start, Temp]), List, List1), 
                                        findPath(Temp, Target, Edges, List1).

% Tester
% path(c,a,[(a,b),(b,c),(c,d)]). false.
% path(a,c,[(a,b),(b,c),(c,d)]). true .
% path(a,b,[(a,c),(c,d),(d,b)]). true .
% path(a,b,[(b,a)]). false.
% path(a,b,[(a,c),(c,d),(d,a)]). Vet ikke om det virker
% path(a,b,[(a,e),(a,c),(c,d),(d,b)]). true .







% C. Expression parser and evaluator ---------
