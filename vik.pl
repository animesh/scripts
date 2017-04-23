/* Oppgave 1 */
queen(N,X) :-
    sjekkInput(N),
    lagListe(N,X1),
    permutation(X,X1),
    trygg(X).

sjekkInput(X) :- not(X<0).

lagListe(0, []) :- !.
lagListe(N1, L) :-
    N2 is N1 - 1,
    lagListe(N2, L2),
    append(L2, [N1], L).

trygg([]).
trygg([X|Rest]) :-
    X1 is X+1, X2 is X-1,
    erLovlig(X,Rest,X1,X2),
    trygg(Rest).

erLovlig(_,[],_,_).
erLovlig(Punkt,[Head|Tail],X,Y) :-
    not(Head = X), not(Head = Y), not(Head = Punkt),
    X1 is X+1, Y1 is Y-1,
    erLovlig(Punkt,Tail,X1,Y1).



/* Oppgave 2
col([a,b,c,d], [1:2,1:3,2:3,1:4,2:4,3:4], C). 
Klarer ikke aa bli kvitt trailingen som forekommer.
*/
col(Colors, [Country1:Country2], Coloring) :-
    sjekkFarger(Country1:Country2, Coloring, Colors), !.

col(Colors, [Country1:Country2|Rest], Coloring) :-
    sjekkFarger(Country1:Country2, Coloring, Colors),
    col(Colors, Rest, Coloring).

sjekkFarger(Country1:Country2, Coloring, Colors) :-
    member(Country1:Color1, Coloring),
    member(Country2:Color2, Coloring),!,
    member(Color1, Colors), member(Color2, Colors),
    not(Color1=Color2).

