%
% John Ringø
% INF 121 - Obligatorisk oppgave 3
% UiB, 18.11.2008
%
% ------------------
% A. Chess Queens  
% ------------------

% Genererer en liste med N tall fra 1->N
generer_liste(0, []).
generer_liste(N, L) :- append(L2, [N], L), M is N-1, generer_liste(M, L2).

% Setter sammen elementene fra to lister i par
merge([], [], []).
merge([X|L], [Y|M], [X:Y|P]) :- merge(L,M,P).

% Sjekker om noen elementer er på samme diagonal
check_diag([]).
check_diag([D|Ds]) :- not_diag(D,Ds), check_diag(Ds).

not_diag(_, []).
not_diag(D1, [D2|Ds]) :- nsub(D1, D2), nadd(D1, D2), not_diag(D1, Ds).

nsub(X1:Y1, X2:Y2) :- A is X1-X2, B is Y1-Y2, not(A = B).
nadd(X1:Y1, X2:Y2) :- A is X1+Y1, B is X2+Y2, not(A = B).

% Fjern par- elemenetene
convert([],[]).
convert([H:A|T], [A|X]) :- convert(T, X).

queen(N, X) :- generer_liste(N, L),!, permutation(L,M), merge(L,M,R), check_diag(R), convert(R,X).

% ------------------
% B. Map Colouring
% ------------------

% Basetilfelle
col(L,[], []).

% Både X og Y får tildelt en farge
col(L,[X:Y|T], C) :- 
	col(L,T,C), 
	member(X:Fx,C), 
	member(Y:Fy,C), 
	\+ Fx=Fy.

% Bare X får tildelt en farge
col(L,[X:Y|T], [Y:Fy|C]) :- 
	col(L,T,C), 
	member(X:Fx,C), 
	\+ member(Y:Fy,C), 
	member(Fy, L), 
	\+ Fy=Fx.

% Bare Y får tildelt en farge
col(L,[X:Y|T], [X:Fx|C]) :- 
	col(L,T,C), 
	member(Y:Fy,C), 
	\+ member(X:Fx,C), 
	member(Fx, L), 
	\+ Fx=Fy.

% Verken X eller Y får tildelt en farge
col(L,[X:Y|T], C3) :- 
	col(L,T,C),
	\+ member(X:Fx,C),
	\+ member(Y:Fy,C),
	member(Fx,L),
	member(Fy,L),
	\+ Fx=Fy,
	append([X:Fx],C,C2),
	append([Y:Fy],C2,C3).


% +-----------------------------+
% | Innebygde funksjoner brukt: |
% +-----------------------------+
% * append(List1, List2, List12) succeeds if the concatenation of the list List1 and the list List2 is the list List12.
% * member(Element, List) succeeds if Element belongs to the List. 
% * permutation(List1, List2) succeeds if List2 is a permutation of the elements of List1.

