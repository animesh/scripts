%Problem a:
maxAlignment(X,Y,Z):- findall(N,alignment(X,Y,N),L ), maximum(L,Z).

maximum([],L).
maximum(L,X):- member(X,L), longest(L,X).

find(X,Y,L):- findall(N,ali(X,Y,N),L).

longest([],X).
longest([H|L],X):- listlen(X,N1), listlen(H,N2), N1 >= N2, longest(L,X).

listlen([],0).
listlen([H|T],N):- listlen(T,N1), N is N1 + 1.


alignment(_,_,[]).
alignment([X|T],Y,[Z|T1]):-  alignment(T,Y,[Z|T1]).
alignment(X,[Y|T],[Z|T1]):-  alignment(X,T,[Z|T1]).
alignment([X|T],[X|T1],[X|T2]):- alignment(T,T1,T2).


%Problem b:
path(X,Y,Z):- pathmaker(X,Y,Z,[]).
pathmaker(X,X,_,_).
pathmaker(X,Y,L,T):- member((X,Z),L),legal(Z,T), pathmaker(Z,Y,L,[Z|T]).

legal(X,[]).
legal(X,[H|T]):- \+ X = H, legal(X,T).

%Problem c:
evalPost(S,V):- string_to_list(S,T), list(T,[],V).

list([],X,X).
list([H|T],T1,T2):- H = 32, list(T,T1,T2).
list([H|T],T1,T2):- isNum(H,V), list(T,[V|T1],T2).
list([H|T],T1,T2):- H = 43, pop(T1,E1,E2,L), V is (E1 + E2),
		    list(T,[V|L],T2).
list([H|T],T1,T2):- H = 45, pop(T1,E1,E2,L), V is (E1 - E2),
		    list(T,[V|L],T2).
list([H|T],T1,T2):- H = 42, pop(T1,E1,E2,L), V is (E1 * E2),
		    list(T,[V|L],T2).
list([H|T],T1,T2):- H = 47, pop(T1,E1,E2,L), V is (E1 / E2),
		    list(T,[V|L],T2).

isNum(H,S):- H > 47, H < 58, S is H - 48.

pop([E1,E2|L],E1,E2,L).



























































