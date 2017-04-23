/* Both of these exercises were more or less solved in the tutorial linked to
   from miside, and when I first tried to teach myself prolog, that was were I
   learned it. I have done some small modifications to these codes so that
   it fits the exercise description, and I have added comments to explain the
   code. */

/* I use two standard library function: member(X,Y) which looks for an element
   X in a list Y, and holds true if it finds it. and reverse(L,L2) which
   reverses a list L to L2. */
   
/* A. Chess Queens */

/* Holds if N is an integer larger than 0 and X is a solution to the N-queens
   problem: N is the size of a NxN chess board, on which N queens shouold be
   placed in such a way that they cannot attack another. Two queens can attack
   each other if they are on the same row or column or diagonal.*/
queen(N,X) :-
        makeList(N,L),
        reverse(L,L2),
        perm(L2,X),
        combine(L2,X,S,D),
        all_diff(S),
        all_diff(D).

/* Creates a list of numbers [N, N-1, .. , 1] */
makeList(1,[1]).
makeList(N,[L|T]) :-
        N=L,
        N > 1,
        N1 is N-1,
        makeList(N1,T).

/* Gives all possible permutations of a list */
perm([],[]).
perm([X|Y],Z) :- perm(Y,W), takeout(X,Z,W).

/* Used to take out an element from a list, and seperate it from the rest of the list*/
takeout(A,[A|B],B).
takeout(A,[B|C],[B|D]) :- takeout(A,C,D).

/* Calculates thes um and difference of elements in two lists */
combine([],[],[],[]).
combine([X1|X],[Y1|Y],[S1|S],[D1|D]) :-
        S1 is X1 +Y1,
        D1 is X1 - Y1,
        combine(X,Y,S,D).

/* Checks that all members of a list are different. Holds true if they are. */
all_diff([X]).
all_diff([X|Y]) :-  \+member(X,Y), all_diff(Y).


/* B. Map colouring */

/* Holds if and only if Colouring is a valid colouring of the Map given the
   colours. A valid colouring is one in which all countries on the map have a
   colour, and no adjacent(=neighbouring) countries have the same colour*/
col(Colours,Map,Colouring) :-
        find_regions(Map,[],Regions),
        colour_all(Regions,Colours,Colouring),
        \+ conflict(Map,Colouring).

/* Locates all the regions in a map. */
find_regions([],R,R).
find_regions([X:Y|S], R,A) :-
     (member(X,R) ->
        (member(Y,R) -> find_regions(S,R,A) ; find_regions(S,[Y|R],A)) ;
           (member(Y,R) -> find_regions(S,[X|R],A) ; find_regions(S,[X,Y|R],A) ) ).


/* Colours all the different regions */
colour_all([],_,[]).
colour_all([R|Rs],Colours,[[R,C]|A]) :-
        member(C,Colours),
        colour_all(Rs,Colours,A).

/* Checks the colouring of a map and holds true if it finds a conflict (two
   adjacent regions got the same colour). */
conflict(Map,Colouring) :-
        member([R1,C],Colouring),
        member([R2,C],Colouring),
        adjacent(R1,R2,Map).

/* Checks if the countries X and Y are adjacent in a Map. holds true if they
   are so. */
adjacent(X,Y,Map) :-  member([X,Y],Map) ; member([Y,X],Map).
