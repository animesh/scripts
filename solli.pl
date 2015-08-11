%member is a builtin, but could be defined this way:
%member(Elt,[Elt|_]).
%member(Elt,[_|Tail]):- member(Elt,Tail).

nocol(A,L):- (member(A,L) -> fail ; true).
nodiag(A,[A+1|_]):- !,fail.
nodiag(A,[A-1|_]):- !,fail.
nodiag(A,[_|T]):- nodiag(A+1,T),nodiag(A-1,T).
queen(1,[A],L).
queen(N,[H|T],L):- nodiag(H,L),nocol(H,L),queen(N-1,T,[H|L]).
queen(N,X):- queen(N,X,X).

countries([],C,C). 
countries([X:Y|S],C,A):- (member(X,C) -> (member(Y,C) -> countries(S,C,A) ; countries(S,[Y|C],A)) ; (member(Y,C) -> countries(S,[X|C],A) ; countries(S,[X,Y|C],A))).
paint([],_,[]).
paint([C|Ct],Colours,[C:D|Tc]):- member(D,Colours), paint(Ct,Colours,Tc).
adjacent(X,Y,Map):- member(X:Y,Map) ; member(Y:X,Map).
neighbourtest(Map,Colouring):- member(A:D,Colouring),member(B:D,Colouring),adjacent(A,B,Map).
col(Colours,Map,Colouring):- countries(Map,[],Countries),paint(Countries,Colours,Colouring),\+ neighbourtest(Map,Colouring).
