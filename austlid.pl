queen(N,X) :- N>0,
	makelist(N,1,L),
	solve(L,X).

makelist(0,_,[]) :- !.
makelist(Len,Start,[Start|Tail]) :- M is Len-1,
	K is Start+1,
	makelist(M,K,Tail).

solve(L,P) :-
    perm(L,P),
    combine(L,P,S,D),
    all_diff(S),
    all_diff(D).

combine([X1|X],[Y1|Y],[S1|S],[D1|D]) :-
    S1 is X1 + Y1,
    D1 is X1 - Y1,
    combine(X,Y,S,D).
combine([],[],[],[]).

all_diff([X|Y]) :- \+member(X,Y),
	all_diff(Y).
all_diff([_]).

member(X,[_|R]) :- member(X,R).
member(X,[X|_]).

takeout(X,[X|R],R).
takeout(X,[F|R],[F|S]) :- takeout(X,R,S).

perm([X|Y],Z) :- perm(Y,W),
	takeout(X,Z,W).
perm([],[]).

:- op(500,xfy,:).

adjacent(X,Y,Map) :-  member(X:Y,Map) ; member(Y:X,Map).

find_regions([],R,R).
find_regions([X:Y|S],R,A) :-
	(member(X,R) ->
		(member(Y,R) -> find_regions(S,R,A) ; find_regions(S,[Y|R],A)) ;
			(member(Y,R) -> find_regions(S,[X|R],A) ; find_regions(S,[X,Y|R],A))).

col(Colors,Map,Coloring) :-
	find_regions(Map,[],Regions), 
	color_all(Regions,Colors,Coloring), 
	\+ conflict(Map,Coloring). 
 
color_all([R|Rs],Colors,[R:C|A]) :- 
	member(C,Colors), 
	color_all(Rs,Colors,A). 
color_all([],_,[]). 

conflict(Map,Coloring) :- 
	member(R1:C,Coloring), 
	member(R2:C,Coloring), 
	adjacent(R1,R2,Map). 