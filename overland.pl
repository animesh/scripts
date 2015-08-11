/*
* Oppgave 1:
*/
queen(N,X) :-
    makelist(N,X1),
    permutation(X,X1),
    safe(X).
noConflict(Orig,[First|Rest],Up,Down) :-
    not(First = Up), not(First = Down), not(First = Orig),
    X is Up+1, Y is Down-1,
    noConflict(Orig,Rest,X,Y).
noConflict(_,[],_,_).
safe([]).
safe([X|Y]) :-
    X1 is X+1, X2 is X-1,
    noConflict(X,Y,X1,X2),
    safe(Y).
makelist(0, []) :- !.
makelist(N1, L) :-
    N2 is N1 - 1,
    makelist(N2, L2),
    append(L2, [N1], L).
/*
* Oppgave 2:
*/
col(Colors,Map,Coloring) :-
    checkMap(Colors,Map,Coloring).
checkMap(Colors,[Country1:Country2],Coloring) :-
    goodColor(Country1:Country2,Coloring,Colors).
checkMap(Colors,[Country1:Country2|Rest],Coloring) :-
    goodColor(Country1:Country2,Coloring,Colors),
    checkMap(Colors,Rest,Coloring).
goodColor(Country1:Country2,Coloring,Colors) :-
    mem(Country1:Color1,Coloring),!,
    mem(Country2:Color2,Coloring),!,
    mem(Color1,Colors), mem(Color2,Colors),
    not(Color1=Color2).
mem(Var,[Var|_]).
mem(Var,[_|Rest]) :-
    mem(Var,Rest).
