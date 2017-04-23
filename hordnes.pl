% Morten Hordnes, guy001.

% Byttet kommentar tegn fra #
% til % da virket programmet, hvis jeg brukte #
% fikk jeg noen errors.

% Oppg A
maxAlignment(_,[],[]).
maxAlignment([],_,[]).
maxAlignment(Xs,Ys,Zs) :- findall(N,alig(Xs,Ys,N),L), max(L,Zs).

max([X],X).
max([H|T], E):- max(T,E), length(H,N1), length(H,N2) E1 < E2, !.
max([H|_],H).

alig([],_,[]).
alig(_,[],[]).
alig([H|T],Y,[H|Z]) :- member(H,Y),!, removeBeFore(H,Y,Y1), alig(Y1,T,Z).
alig([_|T],Y,Z) :- alig(Y,T,Z).

removeBeFore(X,Y,T) :- not member(X,Y).
removeBeFore(X,[X|T],T).
removeBeFore(X,[_|T],T1) :- removeBeFore(X,T,T1).

% OppgB 
path(A,B,L) :- member((A,B),L).
path(A,B,L) :- member((A,C),L), member((_,B),L) , path(C,B,L).

% OppgC
evalPost(E,V) :- evalPost(E,V,[]).
evalPost([],V,[N|S]) :- V is N.
evalPost([H|T],V,S) :- H = 32, evalPost(T,V,S).
evalPost([H|T],V,S) :- H >= 48, Tall is H - 48, append([Tall],S,S1), evalPost(T,V,S1).
evalPost([H|T],V,[N1,N2|R]) :- H = 42, Tall is N2 * N1, append([Tall],R,R1), evalPost(T,V,R1).
evalPost([H|T],V,[N1,N2|R]) :- H = 47, Tall is N2 / N1, append([Tall],R,R1), evalPost(T,V,R1).
evalPost([H|T],V,[N1,N2|R]) :- H = 43, Tall is N2 + N1, append([Tall],R,R1), evalPost(T,V,R1).
evalPost([H|T],V,[N1,N2|R]) :- H = 45, Tall is N2 - N1, append([Tall],R,R1), evalPost(T,V,R1).
















