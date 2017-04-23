%Oblig3 - INF121 - Sondre Langeland Hisdal.

%Oppgave A
maxAlignment(Xs, Ys, Alignment) :- findall(N, alignment(Xs, Ys, N), L), maximum(L, Alignment).

alignment([], _, []).
alignment(_, [], []).
alignment([X|Xs], [X|Ys], [X|A]) :- alignment(Xs, Ys, A).
alignment(Xs, [_|Ys], A) :- alignment(Xs, Ys, A).
alignment([_|Xs], Ys, A) :- alignment(Xs, Ys, A).

maximum([], []).
maximum([X|Xs], M) :- maximum(Xs, M1), largestList(M1, X, M).

largestList(X, Y, Y) :- length(X, L1), length(Y, L2),  L1 =< L2.
largestList(X, Y, X) :- length(X, L1), length(Y, L2),  L1 > L2. 


%Oppgave B
path(Start, Start, _).
path(Start, Target, Edges) :- find(Start, Edges, Y), removePath((Start,Y), Edges, Z), path(Y, Target, Z).

find(X, [(X,Y)|_], Y).
find(X, [_|T], Y) :- find(X,T,Y).

%Oppgave C
removePath(A, [A|L], L).
removePath(A, [B|L], [B|M]) :-removePath(A, L, M).

evalPost(E,V) :- eval(E, [], V).

eval([], L,  V):- pop(V, L, _).
eval([X|T], L, V):- X == 32, eval(T, L, V).
eval([X|T], L, V):- X == 42, pop2(Z, Y, L, L1), V1 is Y*Z, push(V1, L1, L2), eval(T, L2, V).
eval([X|T], L, V):- X == 43, pop2(Z, Y, L, L1), V1 is Y+Z, push(V1, L1, L2), eval(T, L2, V).
eval([X|T], L, V):- X == 45, pop2(Z, Y, L, L1), V1 is Y-Z, push(V1, L1, L2), eval(T, L2, V).
eval([X|T], L, V):- X == 47, pop2(Z, Y, L, L1), V1 is Y/Z, push(V1, L1, L2), eval(T, L2, V).
eval([X|T], L, V):- X >= 48, X =< 57, X1 is X - 48, push(X1, L, L1), eval(T, L1, V).

push(V, S, L) :- append(S, [V], L).

pop(_, [], _) :-!.
pop(X, Stack, L) :- getLast(X, Stack), removeLast(Stack, L).

getLast(X, [X]).
getLast(X, [_|T]) :- getLast(X,T).

removeLast([_|[]], []).
removeLast([Y|T], [Y|L]) :- removeLast(T, L).

%Dette predikatet er strengt talt ikke nødvendig, men jeg syns det var greit å ha det.
pop2(X, Y, S, L) :- pop(X, S, T), pop(Y, T, L).
