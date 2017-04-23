/*N queens
 Håvard Grimelid - hgrimelid@gmail.com
 Trond Jacobsen  - tja026@student.uib.no */

/* Hovedprogrammet sjekker løsninger for brett med NxN størrelse
   I permutasjon(L,C) blir det implisitt sjekka for konflikt i kolonner.
   Konflikt i rader er ikke mulig pga formen på input. */
queen(N,C) :-   lagListe(N,L),
                permutasjon(L,C),
                diagonal1(L,C, [], R1),
                diagonal2(L,C, [], R2),
                sjekkAtUlike(R1),
                sjekkAtUlike(R2).              

/* Genererer liste fra 1 til N */                
lagListe(0, []) :- !.
lagListe(N1, L) :-  N2 is N1 - 1, 
                    lagListe(N2, L2), 
                    append(L2, [N1], L).

/* Fjerner element fra lista */                    
slett(X, [X|Tail], Tail).
slett(X, [Head|Tail], [Head|NewTail]) :- slett(X, Tail, NewTail).

/* Genererer permutasjon av ei liste med tall */
permutasjon( [], [] ).
permutasjon( List1, [ Head | Tail] ) :- slett(Head, List1, List2), permutasjon(List2, Tail).

/* Sjekker diagonal 1 (øvre høyre til nedre venstre) */                 
diagonal1( [Head1 | Tail1], [Head2 | Tail2], Acc, R ) :-
                X is Head1 + Head2,
                append( [X], Acc, B),
                diagonal1(Tail1, Tail2, B, R).
diagonal1([], [], B, B).

/* Sjekker diagonal 2 (nedre venstre til øvre høyre) */
diagonal2( [Head1 | Tail1], [Head2 | Tail2], Acc, R ) :-
                X is Head1 - Head2,
                append( [X], Acc, B),
                diagonal2(Tail1, Tail2, B, R).
diagonal2([], [], B, B).

/* Sjekker at alle elementene i lista er ulike */
sjekkAtUlike( [Head | Tail] ) :- \+ member(Head, Tail), sjekkAtUlike(Tail).
sjekkAtUlike( [Head] ).

