% ***** Exercise A *****

%makes a list of every number from 1 to given number.
%The length of the list gives colums on the board.
%Each number gives the row to place a queen.
%Only one queen in each row (since no same number in the list).
%
makelist( 0, [] ).
makelist( N1, [N1|L] ):-
	N1 > 0,
	N2 is N1-1,
	makelist( N2, L ).

	
%makes permutations of given list.
perm( [],[] ).
perm( [H|T], P1 ):- 
	perm( T, P2 ),
	del( H, P1, P2 ).


%deletes given number from a list. Used by method perm.
del( X, [X|T], T ).
del( X, [Y|T], [Y|T1] ):- 
	del( X, T, T1 ).


%checks every following column to make sure the queens are not 
%placed on the same diagonals as the queen in the first column.
diagonal( _, [], _ ).
diagonal( Q1, [ Q2 | Qtail ], Column ):- 
	( Q1-Q2 ) =\= Column,
	( Q2-Q1 ) =\= Column,
	NextC is Column + 1,
	diagonal( Q1, Qtail, NextC ).


%calls method diagonal on every queen on the board.
check_diag( [] ).
check_diag( [H | T] ):- 
	diagonal( H, T, 1 ), 
	check_diag( T ).


%holds if C is a solution to the N-queens problem on a NxN chess board.
queen( N, C ):- 
	makelist( N, L ),
	perm( L, C ),
	check_diag( C ).


row( N, R, [H|T] ):- 
	( H is R -> write(o) ; write(-) ),
	row( N,R,T ).
row( _,_,[] ):- nl.


board( N, R, L ):- 
	queen( N, L ),
	R =< N -> row( N, R, L ), 
	board( N, R+1, L ) ; nl.




%***** Exercise B *****

%checks for members in a list.
member( M, [M|_] ).
member( M, [_|T] ):- member( M,T ).


%makes a list of all countries in a map.
countryList( [],[] ).
countryList( [X:Y|T], [X,Y|T1] ):- 
	countryList( T,T1 ).


%removes duplicates from the list of countries.
remove_dup( [],[] ).
remove_dup( [X|T], L ):- 
	member( X, T ), remove_dup( T, L ), !.
remove_dup( [X|T], [X|T1] ):-
	not( member( X, T ) ), remove_dup( T, T1 ), !.


%colouring the countries.
colour( _, [], [] ).
colour( Colours, [X|Land], [X:Y|Colouring] ):-
	member( Y, Colours ),
	colour( Colours, Land, Colouring ).
	

%return false if neighbouring countries have the same colour.
no_conflict( [],_ ).
no_conflict( [X:Y|Map], Colouring ):-
	member( X:C1, Colouring ),
	member( Y:C2, Colouring ),
	C1 == C2 -> !, fail; no_conflict(Map,Colouring).

 
%holds if Colouring is a valid colouring of Map with the colours Colour.     
col( Colour, Map, Colouring ):- 
	countryList( Map, M ), 
	remove_dup( M, Countries ), 	
	colour( Colour, Countries, Colouring ),
	no_conflict( Map, Colouring ).
	
       
	
	
	
	             













