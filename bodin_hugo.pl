% Author:   Hugo Bodin
% Date: 12.11.2009


%Take from Xs and Ys union variables, no duplicates, stuff in A

maxAlignment(Xs, Ys, A):-
                 findall((N,alignment(Xs,Ys,N),L),
                 maximum(L,A),
                 !.

%find common members
alignment(Xs,Ys,N):- member(N, Xs), member(N, Ys).
%remove duplicates from start
maximum([],[]).
maximum([X|Rest], Result) :- member(X,Rest), maximum(Rest,Result), !.
maximum([X|Rest], [X|Rest1]) :- not(member(X,Rest)), maximum(Rest,Rest1),!.


%special case of same node entered twice
path(A,A,_).
%when only one step left -> yes
path(A,B,Graph):-member((A,B), Graph).
%path does not exist, find path with A and some node, recur a path from there
path(A,C,Graph):- member((A,B),Graph), path(B,C,Graph).


evalPost(Str, V):- makePostList(Str, G),
              calcPost(G,S, V).


makePostList(Str, V):-
                   string_to_list(Str, S),
                   delete(S, 32, T), %remove spaces
                   maplist(plus(-48), T, S).   %make num-nums
                   
calcPost([], V, S).
calcPost(G|U,V,S):-
            between(0, 10, G),
            append(G,V),
            calcPost(U,V,S).
calcPost(G|U,V,S):-
                 G == -1,    %G == /
                 pop(V, A, Z), pop(Z, B, K)
                 Sum is S+(A/B),
                 calcPost(U, K, Sum),
                 !.
calcPost(G|U,V,S):-
                 G == -3,    %G == -
                 pop(V, A, Z), pop(Z, B, K)
                 Sum is S+(A-B),
                 calcPost(U, K, Sum),
                 !.
calcPost(G|U,V,S):-
                 G == -5,    %G == +
                 pop(V, A, Z), pop(Z, B, K)
                 Sum is S+(A+B),
                 calcPost(U , K, Sum),
                 !.
calcPost(G|U,V,S):-
                 G == -6,    %G == *
                 pop(V, A, Z), pop(Z, B, K)
                 Sum is S+A*B,
                 calcPost(U, K, Sum),
                 !.
%classic pop for list
pop(V, S, G):-
        last(V, G),
        removeLast(V, S).
%removes the last element from a list
removeLast([], V).
removeLast([G|U], V):- append(G,V) removeLast(U, V).
removeLast([G|[]], V).