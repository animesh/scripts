% Oppgave 1:

% Funksjon som returnerer en stigende liste med tall som er N lang.
lagListe(N, N, [N]).
lagListe(N1, N2, [N1|List]) :-
  N1 < N2,
  M is N1 + 1,
  lagListe(M,N2,List).

% Returnerer lister med lovlige permuteringer i forhold til
% plasseringene til dronningene på et brett.
permutation([], P, P).
permutation(Liste, DelvisPerm,  Z) :- 
    takeout(Brikke, Liste, W),
    sameDiagonal(Brikke, DelvisPerm, 1),
    permutation(W, [Brikke|DelvisPerm], Z).

% Returnerer første brikke i listen og resten av listen uten brikken
takeout(X, [X|R], R).
takeout(X,[F|R],[F|S]) :- takeout(X,R,S).

% Sjekker om to dronninger blir plassert på samme diagonal på brettet.
% Funksjonen returnerer true hvis en dronnings plassering ikke er 
% plassert på samme diagonal som en annen dronning og false ellers.
sameDiagonal(_, [], _).
sameDiagonal(Y, [Y1|Ytail], X) :-
    Y1-Y =\= X,
    Y-Y1 =\= X,
    X1 is X+1,
    sameDiagonal(Y, Ytail, X1).

% Returnerer lister med lovlige permuteringer
queen(N,X) :- 0 < N, 
    lagListe(1,N,Liste),
    permutation(Liste, [], X),
    board(N, 1, X).

% Skriver ut brettet med dronningene
row(N,R,[H|T]):- (H is R -> write(q) ; write(.)), row(N,R,T).
row(_,_,[]) :- nl.
board(N,R,L):- (R =< N -> row(N,R,L), board(N,R+1,L) ; nl).


% Oppgave 2:

% Funksjon som returnerer en liste med landene og fargen deres.
col(Colours,Map,Colouring) :-	finnLand(Map, [], NyListe),
	fargeLand(NyListe, [], Colours, Colours, Map, Colouring).
% En funksjon som returnerer en liste med alle landene på et kart.
finnLand([], L, L).
finnLand([M:M1|T], Liste, L) :- 
	(member(M, Liste), member(M1, Liste) -> finnLand(T, Liste, L) ;
	member(M, Liste), not(member(M1, Liste)) -> finnLand(T, [M1| Liste], L) ;
	member(M1, Liste), not(member(M, Liste)) -> finnLand(T, [M|Liste], L) ;
	finnLand(T, [M,M1|Liste], L)).

% standardfunksjon fra boken
member(M, [M|_]).
member(M, [_|T]) :- member(M,T).
% Funksjon som farger landene i et kart med forskjellige farger.
% Ingen naboer blir farget med samme farge. Funksjonen returnerer
% en liste med landene bundet med fargen den har blitt tildelt.
fargeLand([], S, _, _, _, S).
fargeLand([H|Tail], DelvisFarget, [X|Rest], Colours, Map, S) :-
	hentNaboer(H, Map, [], Naboer),
	(sjekkNabo(H:X, DelvisFarget, Naboer) -> 
	     fargeLand(Tail, [H:X|DelvisFarget], 
Colours, Colours, Map, S) ;
	     fargeLand([H|Tail], DelvisFarget, Rest, Colours, Map, S)).

% Funksjon som sjekker om naboene til et land er farget med samme farge
% Returnerer true hvis ingen av naboene har samme farge og false hvis
% noen av naboene har samme farge.
sjekkNabo(X:X1,[H:H1|Tail], Naboer) :-
	(member(H, Naboer) ->
	X1 \== H1,
	sjekkNabo(X:X1, Tail, Naboer) ;
	sjekkNabo(X:X1, Tail, Naboer)).
sjekkNabo(_, [], _).

% Returnerer en liste med naboene til et land
hentNaboer(_, [], N, N).
hentNaboer(H, [Y:Y1|YTail], Naboer, Z) :-
	(H =:= Y -> hentNaboer(H, YTail, [Y1|Naboer], Z) ;
	H =:= Y1 -> hentNaboer(H, YTail, [Y|Naboer], Z) ; 
	hentNaboer(H, YTail, Naboer, Z)).