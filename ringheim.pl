% - - HJELPEMETODAR
append([], Y, Y).
append([H|X], Y, [H|Z]):- append(X, Y, Z).

member(M, [M|Tail]).
member(M, [Head|Tail]):-member(M, Tail).

del(X, [X|Tail], Tail).
del(X, [Y|Tail], [Y|Tail1]):-del(X, Tail, Tail1).

permutation([],[]).
permutation(L, [X|P]):- del(X, L, L1), permutation(L1, P).

% - - OPPGÅVE 1

makelist(0, []).
makelist(N1, L):- N1>0, N2 is N1-1, makelist(N2, L2), append(L2, [N1], L).

%Sjekker om det er noko kollisjonar i rekkene. Denne treng me ikkje, sidan makelist aldri vil lage ei liste med doble verdiar.
rekker(C):- permutation(C, CP), conatomic(C, CP, []).

%Gå gjennom alle dronningar og sjekk diagonalen.
diagcheck([]).
diagcheck([Q|Others]):- diag(Q, Others, 1), diagcheck(Others). 

%Sjekk diagonalen for gjeldande dronning, i forhold til alle andre dronningar:
diag(Y, [], _).
diag(Y, [Q|Others], Dist):- Dist1 is Dist+1, S is Y+Dist, not(S = Q), T is Y-Dist, not(T = Q), diag(Y, Others, Dist1).

queen(N, C):- makelist(N, L), permutation(L, C), diagcheck(C), board(N, 1, C). %, rekker(C).

row(N,R,[H|T]):- (H is R -> write(o) ; write( - )),row(N,R,T).
row(N,R,[]) :- nl.
board(N,R,L):- R =< N -> row(N,R,L), board(N,R+1,L) ; nl.


% - - OPPGÅVE 2

%Konstruer ei liste med alle landa
conlist([], []).
conlist([H:K|Restmap], [H,K|Conlist]):- conlist(Restmap, Conlist).

%Ta ut berre dei einskilde elementa frå ei liste. Rekkefylgja vil ikkje korrespondere med input, men det gjer ikkje noko.
conatomic([], L, L).
conatomic([H|Tail], List, L):- member(H, L), conatomic(Tail, List, L).
conatomic([H|Tail], List, L):- not(member(H, L)), conatomic(Tail, List, [H|L]).

%Fins ein av desse, L1:L2 eller L2:L1, i Map?:
adjacent(L1,L2,Map) :-  member(L1:L2,Map).
adjacent(L1,L2,Map) :-  member(L2:L1,Map).

%Hvis det fins nokon land (R1, R2) i Colouring med same farge (C) som også er naboar:
conflict(Map, Colouring):- member(R1:C,Colouring), member(R2:C,Colouring), adjacent(R1,R2,Map). 

%Finn ein farge J i Colours, og legg den saman med H i lista:
colorall([H|Restcons], Colours, [H:J|Restcolouring]):- member(J, Colours), colorall(Restcons, Colours, Restcolouring).
colorall([],_,[]).

%Farge alle landa slik at det ikkje blir konflikt mellom nokon av dei.
col(Colours,Map,Colouring):- conlist(Map, Conlist), conatomic(Conlist, Conatom, []), colorall(Conatom,Colours,Colouring), \+ conflict(Map,Colouring).
