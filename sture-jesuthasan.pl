% INF121 Oblig3 H2008 Jan Erik Sture og Franklin Jesuthasan

% Oppgave A

% Kjoreeksempel: ----------------------------
% ?- queen(4,X).
% X = [3, 1, 4, 2] ;
% X = [2, 4, 1, 3] ;
% fail.

% ?- queen(4,[3,1,4,2]).
% true .

% ?- queen(4,[1,2,3,4]).
% fail.
%---------------------------------------------

fjern(X,[X|R],R).
fjern(X,[F|R],[F|S]) :- fjern(X,R,S).

perm([X|Y],Z) :- perm(Y,W),fjern(X,Z,W).
perm([],[]).

% N er et heltall, og L er listen av tall [0,1,...,N]
list(0,L,L) :- !.
list(N,L,R) :- Y is N-1, list(Y,L,[N|R]).

% konverterer en liste til par-liste 
listtopl([],_,L,S) :- reverse(L,S).
listtopl([Lh|Lt],[Rh|Rt],L,LR) :- listtopl(Lt,Rt,[Rh|L],LR).

% fjerner diagonals

diagonalL([H|[]],N) :- B is N - 1, not(B=H).
diagonalL([H|T],N) :- B is N - 1 , not(B=H),diagonalL(T,B).

diagonalR([H|[]],N) :- B is N + 1, not(B=H).
diagonalR([H|T],N) :- B is N + 1, not(B=H),diagonalR(T,B).

diagonal([_|[]]).
diagonal([H|T]) :- diagonalL(T,H),diagonalR(T,H),diagonal(T).

%queen(N,P) :- list(N,B,[]),perm(B,Bs),diagonal(Bs),listtopl(B,Bs,[],P). 
queen(N,P) :- list(N,B,[]),perm(B,P),diagonal(P). %,listtopl(B,Bs,[],P). 

% Oppgave B
% Merk - implementerte kartet som liste av lister, litt annen syntaks enn i oppgaveteksten

% Kjoreeksempel: ---------------------------------
% ?- col([a,b],[[1,2],[1,3],[2,3]],C).
% fail.

% ?- col([a,b,c],[[1,2],[1,3],[2,3]],C).
% C = [[3, a], [1, b], [2, c]] ;
% C = [[3, a], [1, c], [2, b]] ;
% C = [[3, b], [1, a], [2, c]] ;
% C = [[3, b], [1, c], [2, a]] ;
% C = [[3, c], [1, a], [2, b]] ;
% C = [[3, c], [1, b], [2, a]] ;
% fail.
% ------------------------------------------------


% Sjekker om to land er naboer
naboer(A,B,Kart) :- member([A,B],Kart); member([B,A],Kart).

% Fjerner duplikater i land-listen
remdup([],L,L).
remdup([[A,B]|C],L,D):-
  (member(A,L)-> (member(B,L)-> remdup(C,L,D); remdup(C,[B|L],D));
    (member(B,L)-> remdup(C,[A|L],D); remdup(C,[A,B|L],D))).

% Kombinerer land og farger
cols([L|La],Farger,[[L,D]|Z]):- member(D,Farger), cols(La, Farger, Z).
cols([],_,[]).

% sjekker om noen naboer har samme farge
ilcomb(Kart,X):- member([B,D],X),member([C,D],X),naboer(B,C,Kart).

% Selve kommandoen som kjores:
col(Farger,Kart,X):- remdup(Kart,[],Land), cols(Land,Farger,X), \+ ilcomb(Kart,X).
