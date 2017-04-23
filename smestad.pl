/* Helper relations */

% Taking out first element of second list yields third list
takeout(X,[X|R],R).
takeout(X,[F|R],[F|S]) :- takeout(X,R,S).

% Putting first element into second list yields third list
putin(A, B, L) :- takeout(A, L, B).

% A and B are distinct elements of L.
pairs(A, B, L) :- putin(B, C, L), putin(A, _, C).

/* End helper relations */


/*
  N-queens problem
  ================

   Theory behind naïve solution of the N-queens problem: Two queens are on the
   same diagonal if and only if the sums or differences of their respective X
   and Y coordinates are equal.

   These relations assume that the list representing the chess board does
   not contain any duplicate elements. Such a list is never a solution to
   the N-queens problem, but none of my relations verify this. In other words,
   we can generate every candidate board by permutating the list of each number
   from 1 to N.
*/



% First argument is a permutation of second
perm([E], [E]).
perm([A|B], [C|D]) :- member(A, [C|D]), takeout(A, [C|D], L), perm(B, L).




% L is a range list of N elements: [1,2,3,...N]
rangeList([], 0) :- !.
rangeList(L, N1) :-
    N2 is N1-1,
    rangeList(L2, N2),
    append(L2, [N1], L).


% Generates a list of differences between X and Y coordinates of each queen
diagonal1([X|R], [Y|F],ACC, L) :-
    DIFF is X - Y,
    append(ACC, [DIFF], N),
    diagonal1(R, F, N, L).

diagonal1([], [], R, R).

% Generates a list of sums between X and Y coordinates of each queen
diagonal2([X|R], [Y|F],ACC, L) :-
    SUM is X + Y,
    append(ACC, [SUM], N),
    diagonal2(R, F, N, L).

diagonal2([], [], R, R).

% Returns true if there is a conflict on the right diagonal of BOARD
conflict1(BOARD) :-
    length(BOARD, LEN),
    rangeList(COL, LEN),

    diagonal1(COL,BOARD, [], CL1),

    % Compare pairs of queen coordinate differences, fail if two are identical
    pairs(A,B,CL1), A=B.

% Returns true if there is a conflict on the left diagonal of BOARD
conflict2(BOARD) :-
    length(BOARD, LEN),
    rangeList(COL, LEN),

    diagonal2(COL,BOARD, [], CL2),

    % Compare pairs of queen coordinate sums, fail if two are identical
    pairs(A,B,CL2), A=B.

% Returns true if there is a conflict on BOARD
conflict(BOARD) :- conflict1(BOARD) ; conflict2(BOARD).



% X is a solution to the N-queens problem
queen(N,X) :- rangeList(C, N), perm(X, C), not(conflict(X)).






/*
   Map coloring problem
   ====================

   My approach is, as suggested in the exercise, to generate every coloring
   and test whether one of them works for the given map.

   I interpreted the exercise to mean that it wanted to generate solutions -
   hence it will not generate maps or the color set if these variables
   are unknown.

   The built-in relation list_to_set(A, B) succeeds when B contains the
   members of A in order, but with only one of each duplicate element.
*/


% P is an A:B pair in neighbor list L
neighborPair(P, L) :- A:B = P, member(A:B, L).

% A and B are neighbors in neighbor list L
neighbors(A, B, L) :- neighborPair(P, L), (A:B = P ; B:A = P), !.


% CL is a list of countries in map
countries(CL, MAP) :- countries(CL, MAP, ACC).

countries(CL, [], ACC) :-
    list_to_set(ACC, CL).

countries(CL, [X:Y|T], ACC) :-
    append(ACC, [X, Y], R),
    countries(CL, T, R),
    !.


% C is a coloring of MAP using COLORS
coloring(MAP, COLORS, C) :-
    countries(COUNTRIES, MAP),
    coloring(MAP, COUNTRIES, COLORS, C, []).

coloring(MAP, [], COLORS, ACC, ACC).

coloring(MAP, COUNTRIES, COLORS, C, ACC) :-
    [H|T] = COUNTRIES,
    member(COL, COLORS),
    append(ACC, [H:COL], NACC),
    coloring(MAP, T, COLORS, C, NACC).


% C is an invalid coloring for map
invalid(C, MAP) :-
    pairs(A:B, X:Y, C),
    neighbors(A, X, MAP),
    B = Y, !.

% C is a valid coloring of map using colors
col(COLORS, MAP, C) :-
    coloring(MAP, COLORS, C),
    not(invalid(C, MAP)).



