not(P) :- call(P),!,fail.
not(_).

% is country iff in the list of countries [c1:c2,c1:c3,c2:c3|...]
country(A,[A:_|_]).
country(A,[_:A|_]).
country(A,[_|T]) :- country(A,T).

% A and B are neighbours iff they are in country list as pair separated by ':' : [c1:c2,c1,c3]
neighbour(A,B,[A:B|_]).
neighbour(A,B,[B:A|_]).
neighbour(A,B,[_|T]) :- neighbour(A,B,T).

% colouring Country:Colour is valid if none of the neighbours of Country has Colour as colour.
legal_colour([Country:Colour],Colours,Countries) :- !,
	country(Country,Countries),
	member(Colour,Colours).

legal_colour([Country:Colour,OtherCountry:Colour|Rest],Colours,Countries) :-
	!,
	not(neighbour(Country,OtherCountry,Countries)),
	legal_colour([Country:Colour|Rest],Colours,Countries),
	legal_colour([OtherCountry:Colour|Rest],Colours,Countries).

legal_colour([Country:Colour,OtherCountry:OtherColour|RestOfColouring],Colours,Countries) :-
	not(Colour=OtherColour),!,
	legal_colour([Country:Colour|RestOfColouring],Colours,Countries),
	legal_colour([OtherCountry:OtherColour|RestOfColouring],Colours,Countries).


colour_permutation([],_,Colouring,Colouring).
colour_permutation([H|Map],Colours,Colouring,Acc) :-
	country(Country,[H|Map]),
	not(member(Country:_,Acc)),
	member(Col,Colours),
	colour_permutation(Map,Colours,Colouring,[Country:Col|Acc]).

col(Colours,Map,Colouring) :-
	colour_permutation(Map,Colours,Colouring,[]),
	legal_colour(Colouring,Colours,Map).

queen(N,X) :-
	% Follows the interface/contract given by Truls, i.e.
	% is true iff X is a solution of the N-queen puzzle
	list(N,Y),
	permute(Y,X),
	legal_queen(X).

% empty board has no attacks
legal_queen([]).
legal_queen([H|T]) :-
	% The queen H attacks no-one:
	% in the same row
	legal_direction([H|T],0),
	% diagonally up
	legal_direction([H|T],1),
	% diagonally down
	legal_direction([H|T],-1),
	% and the rest of the board doesn't attack anyone
	legal_queen(T).

% empty board is legal
legal_direction([],_).
% one queen has no-one to attack
legal_direction([_],_).
% Inc is the incrementor, 0 for horizontally, 1 for diagonally up and -1 for diagonally down
legal_direction([H1,H2|T],Inc) :-
	Q is H1 + Inc,
	Q =\= H2,
	legal_direction([Q|T],Inc).

% the list of all numbers from 1 to N.
% 0 is the empty list
list(0,[]).
list(N,[N|T]):-!,
	N > 0,
	Nd is N-1,!,
	list(Nd,T).

remove(H,[H|T],T).
remove(X,[H|T], [H|NewT]) :-
	remove(X,T,NewT).

permute([],[]).
permute(L,[H|T]) :-
	remove(H,L,L1),
	permute(L1,T).