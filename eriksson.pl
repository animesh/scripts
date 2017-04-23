#Author: Carl Nicklas Eriksson, Torbjørn Tessem.
#Oppgave A
maxAlignment([],_,[]).
maxAlignment(_,[],[]).
maxAlignment(Xs,Ys,Zs) :- findall(N,alignment(Xs,Ys,N),L), maximum(L,Zs).

alignment([],_,[]).
alignment(_,[],[]).
alignment([H|T],Y,[H|Z]) :- member(H, Y),!, removeBefore(H,Y,Y1), alignment(Y1,T,Z).
alignment([_|T],Y,Z) :- alignment(Y,T,Z).

removeBefore(X,Y,_) :- not member(X,Y).
removeBefore(X,[X|T],T).
removeBefore(X,[Y|T],T1) :- removeBefore(X,T,T1).

maximum([X],X).
maximum([H|T],E) :- maximum(T,E),length(H,N1),length(E,N2, N1 < N2, !.
maximum([H|_],H).

#Oppgave B
path(_,_,[]) :- false.
path(A,B,L) :- member((A,B),L).
path(A,B,L) :- member((A,C),L), select((A,C), L, L1), path(C,B,L1).

#Oppgave C
#Trenger denne metoden for ellers så starte ikke evalPost i kate. Rart program....
kateerrar([],[]).
evalPost(X, Z) :- parsePost(X, [], Z).
parsePost([], [X] , X).
parsePost([X|Xs], Zs,T) :- X >= 48,!, charcode(X,Xt), parsePost(Xs,[Xt|Zs], T).
parsePost([X|Xs],Zs,T) :- X = 32,!, parsePost(Xs,Zs,T).
parsePost([X|Xs],[Z,Y|Zs],T) :- X = 43,!, add(Z,Y,Res), parsePost(Xs, [Res|Zs],T).
parsePost([X|Xs],[Z,Y|Zs],T) :- X = 45,!, minus(Y,Z,Res), parsePost(Xs, [Res|Zs],T).
parsePost([X|Xs],[Z,Y|Zs],T) :- X = 42,!, multi(Z,Y,Res), parsePost(Xs, [Res|Zs],T).
parsePost([X|Xs],[Z,Y|Zs],T) :- X = 47,!, div(Y,Z,Res), parsePost(Xs, [Res|Zs],T).

add(X,Y,Res) :- Res is X + Y.
minus(X,Y,Res) :- Res is X - Y.
multi(X,Y,Res) :- Res is X * Y.
div(X,Y,Res) :- Res is X / Y.
#Trekker fra -48 på alle tallen over 48. Det vil returnere et verdi.
charcode(X,Yt) :- Yt is X - 48.

