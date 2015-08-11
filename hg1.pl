maxAlignment(Xs, Ys, A):-
                 findall(N,alignment(Xs,Ys,N),L),
                 maximum(L,A).

%find common members
alignment(Xs,Ys,N):- member(N, Xs), member(N, Ys).
%remove duplicates from start
maximum([],[]).
maximum([X|Rest], Result) :- member(X,Rest), maximum(Rest,Result), !.
maximum([X|Rest], [X|Rest1]) :- not(member(X,Rest)), maximum(Rest,Rest1),!.

isNotTraveled(_, []).
isNotTraveled(A, [Trave|Ed]):- \+ A = Trave, isNotTraveled(A, Ed).

%special case of same node entered twice
path_(A,A,_, _).
%when only one step left -> yes
path_(A,B,Graph, _):-member((A,B), Graph).
%path does not exist, find path with A and some node, recur a path from there
path_(A,C,Graph, Traveled):- member((A,B),Graph),isNotTraveled((A,B), Traveled), path_(B,C,Graph, [(A,B)|Traveled]).

path(Start, End, Graph) :- path_(Start, End, Graph, []).
