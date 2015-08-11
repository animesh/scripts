% Obligatorisk øvelse 3
% Bjørnar Vister Hansen (Stud.nr. 185856)
% bha100@student.uib.no

% Oppgave A
alignment(Xs,Ys,[]).
alignment(Xs,Ys,[A|T]) :- append(U,[A|T1],Xs), append(I,[A|T2],Ys), alignment(T1,T2,T).

maximum([],M).
maximum([X|T],M) :- length(X,Y), length(M,Z), Z >= Y, maximum(T,M).

maxAlignment(Xs,Ys,Alignment) :- findall(N,alignment(Xs,Ys,N),L), maximum(L,Alignment), alignment(Xs,Ys,Alignment).

% Oppgave B
path(X,Y,Graph) :- member((X,Y),Graph).
path(X,Y,Graph) :- member((X,Z),Graph), member((_,Y),Graph), path(Z,Y,Graph).

% Oppgave C
evalPost(E,V) :- evalPost(E,V,[]).
evalPost([],V,[V]).
evalPost([H|T],V,S) :- H = 32, evalPost(T,V,S).
evalPost([H|T],V,S) :- H >= 48, Num is H - 48, append([Num],S,S1), evalPost(T,V,S1).
evalPost([H|T],V,[N1,N2|R]) :- H = 42, Num is N2 * N1, append([Num],R,R1), evalPost(T,V,R1).
evalPost([H|T],V,[N1,N2|R]) :- H = 47, Num is N2 / N1, append([Num],R,R1), evalPost(T,V,R1).
evalPost([H|T],V,[N1,N2|R]) :- H = 43, Num is N2 + N1, append([Num],R,R1), evalPost(T,V,R1).
evalPost([H|T],V,[N1,N2|R]) :- H = 45, Num is N2 - N1, append([Num],R,R1), evalPost(T,V,R1).
