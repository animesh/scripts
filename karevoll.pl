/*
INF121 Compulsory Exercise 3
Sjur Gjøstein Karevoll
ska032@student.uib.no

The solutions to both parts of the exercise are rather similar:
Both are non-deterministic algorithms following the pattern of:
1. Deterministically select an element to solve (e.g. a country)
2. Non-deterministically select a solution for that element (e.g. a colour)
3. Check if that solution is valid according to the other solutions found
4. If valid, recurse on the reduced problem, if not, reject the solution.
5. When no more unsolved elements remain, the collection of solutions for
   individual elements is taken as the solution for the entire problem.

In the case of the n queens problem the elements to solve are implicit, and so
is selecting the next element to solve. In the map colouring problem it is
simply the head of the list of unsolved countries. Non-determinism is achieved
by prolog backtracking whenever a solution is rejected.
*/

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% N queens problem:
% queen(+N, -Solution). Finds solutions to the n queens problem,
% or verifies a solution.
%
% Here the elements to solve are columns, and their solution are rows.
% The entire problem has a solution where all the elements have a solution,
% with the additional constraint that no queen may attack.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


queen(N, Out) :-
  N > 0,
  numlist(1, N, Rows), % Creates a list from 1 to N inclusive. Built-in.
  queen(Rows, [], Out).

% The queens are placed column by column in sequence. Its row position is
% chosen from a list of non-occupied rows. A given queen position is valid if
% it cannot attack any of the previously placed queens and there is at least one
% valid position left for every unplaced queen.
queen([], Out, Out).
queen(FreeRows, TakenRows, Out) :-
  select(Q, FreeRows, NFreeRows), % select(?Element, ?List, ?ListWithoutElement)
  cannotAttack(Q, 1, TakenRows),
  queen(NFreeRows, [Q|TakenRows], Out).

% A queen can attack if the difference between the column indices is the same as
% the difference between the row indices. Two queens will never occupy the same
% row or column because of the way they're selected.
cannotAttack(_,_,[]).
cannotAttack(Q,N,[P|Ps]) :-
  Q =\= P+N,
  Q =\= P-N,
  cannotAttack(Q, N+1, Ps).

% Directly from the assignment. They seem to work as advertised, so I saw no
% reason to change them.
row(N,R,[H|T]):- (H is R -> write(q) ; write(.)),row(N,R,T).
row(N,R,[]) :- nl.
board(N,R,L):- R =< N -> row(N,R,L), board(N,R+1,L) ; nl.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Map colouring problem:
% col(+Colours, +Map, -Colouring). Finds valid colourings given valid colours
% and a map listing adjacent countries, or verifies a colouring.
%
% The elements to solve are countries, and their solutions are colours.
% The entire problem's solutions is the list of [country:colour] mappings, with
% the additional constraint that no two adjacent countries share the same
% colour.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


col(Colours, Map, Colouring) :-
  listCountries(Map, List),
  sort(List, Countries), % remove duplicates (O_o)
  colour(Colours, Map, Countries, [], Colouring).

% First a country is selected, then a colour is selected
% non-deterministically. If the chosen country:colour combination satisfies
% the sameAdjacentColour predicate then the solution is rejected, otherwise
% it recurses on the reduced problem of having one less country to colour.
colour(_,_,[],C, C).
colour(Colours, Map, [Country|Countries], Colouring, Out) :-
  member(Colour, Colours), % Built-in member(?A,+B) if A is an element in B
  \+sameAdjacentColour(Country, Colour, Map, Colouring),
  colour(Colours, Map, Countries, [Country:Colour|Colouring], Out).

% This predicate succeeds if there is a country B such that A and B are adjacent
% and B has already been coloured the same as A.
sameAdjacentColour(A, C, Map, Colouring) :-
  (member(A:B, Map);
   member(B:A, Map)),
  member(B:C, Colouring).

listCountries([], []).
listCountries([A:B|T], [A,B|R]) :- listCountries(T, R).