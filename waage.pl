
/* Queens Problem Solver, up to n = 13*/
/* Could be improved by using a depth first search instead instead of testing all permutations*/
/**********************************************************/

/*Take out of*/
takeout(X,[X|R],R).
takeout(X,[F|R],[F|S]) :- takeout(X,R,S).

/*Are there no equal parts in this array*/
all_diff([X|Y]) :- \+member(X,Y), all_diff(Y).
all_diff([]).

/*Creates permutations*/
perm([X|Y],Z) :- perm(Y,W), takeout(X,Z,W).
perm([],[]).


/*Create a list of numbers from 1 to N , or from X to Y depending on number of variables given*/
int_arr(N,W) :- F is N+1 , int_arr(1,F,W).
int_arr(N,N,[]).
int_arr(A,Z,[A|B]) :- A=<Z, P is A+1 ,int_arr(P,Z,B).

/*Creates crossing positions*/
cross([X1|X],[Y1|Y],[Z1|Z],[A1|A]) :- Z1 is X1+Y1, A1 is X1-Y1, cross(X,Y,Z,A).
cross([],[],[],[]).

/*Uses cross and aldiff to check solutions*/
check(W,P) :- cross(W,P,Z,A), all_diff(Z), all_diff(A).

/*Create permutations of numbers from 1-N and checks if they solve the queens puzzle*/
queen(N,P) :- int_arr(N,W), perm(W,P), check(W,P).

/**********************************************************/






/*Prolog coloring using tail recursion*/
/*Inspiration from J.R. Fishers site*/
/*The use of tali recursion reduces use of stack, and can therefore quickly solve colorings of larger maps then one*/
/*Could not otherwise solve*/


/**Get the elements of the tuple, NOT USED**/
getA(A:_,C) :- C is A.
getB(_:B,C) :- C is B.

/**Get adjacent elements**/
adj(A,B,C):- member(A:B,C) ; member(B:A,C).

/**contains , NOT USED**/
cont(A,B:C) :- A=B ; A = C. 

/**finds the regions the tuples create**/
regions([],A,A).
regions([X:Y|Z],A,B) :- (member(X,A) -> (member(Y,A) -> regions(Z,A,B) ; regions(Z,[Y|A],B)) ;
										(member(Y,A) -> regions(Z,[X|A],B) ; regions(Z,[X,Y|A],B))).

/*Adds colors to regions and then checks if they are legal. Is tailrecursive.*/
color_reg(Map,[R|Rt],Colors,W,C) :- member(U,Colors), (not(cCol(Map,R,U,W)) -> color_reg(Map,Rt,Colors,[[R:U]|W],C) ;
																			   color_reg(Map,R,Colors,W,C) ).
color_reg(_,[],_,A,A).

/*looks for conflicts*/
cCol(Map,R,U,Coloring) :- member([B:U],Coloring) , adj(R,B,Map).

/**Finds a map coloring**/
col(Clr,Map,C) :- regions(Map,[],Res1), color_reg(Map,Res1,Clr,[],C).

/*******************************************************************/
