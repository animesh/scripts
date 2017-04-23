%Task_A
alignment(Xs, Ys, Alignment) :- singleAlignment(Xs, Alignment), singleAlignment(Ys, Alignment).

singleAlignment(_, []).
singleAlignment([H|Xs], [H|Alignment]) :- singleAlignment(Xs, Alignment).
singleAlignment([_|Xs], [H|Alignment]) :- singleAlignment(Xs, [H|Alignment]).

maximum([X|Xs], [M|Ms]) :- member([M|Ms], [X|Xs]), length([M|Ms], Lm),  \+ ( member(A, [X|Xs]), length(A, La), La > Lm).

maxAlignment([X|Xs], [Y|Ys], Ms) :- findall(N, alignment([X|Xs], [Y|Ys], N), L), maximum(L, Ms).

%Task_B
path(S,T,[X|Xs]) :- member((S,T),[X|Xs]).
path(S,T,[X|Xs]) :- member((A,T), [X|Xs]), select((A,T),[X|Xs], L), path(S,A,L).

%Task_C
evalPost(S,V) :- helpEval(S,V,[]).

helpEval([], V, [L|_]) :- V is L.
helpEval([X|Xs], V, Ls) :- X == 32, helpEval(Xs, V, Ls).
helpEval([X|Xs], V, Ls) :- X >= 48, X =< 57, L is X-48, helpEval(Xs, V, [L|Ls]).
helpEval([A|Xs], V, [X,Y|Ls]) :- evalExpr(X, Y, A, P), helpEval(Xs, V, [P|Ls]).

evalExpr(X,Y,A,V) :- A == 42, P is X*Y, P = V.
evalExpr(X,Y,A,V) :- A == 43, P is X+Y, P = V.
evalExpr(X,Y,A,V) :- A == 45, P is Y-X, P = V.
evalExpr(X,Y,A,V) :- A == 47, P is Y/X, P = V.
