fact(x) is 1 :- x is 0, fact(x) is 1 :- x is 1, fact(x) is x*fact(x-1) :- x>1.

fact2(0, 1).
fact2(X, Y):- X1 is X - 1, fact2(X1, Y1), Y is X*Y1.

fact(N, F) :- fac(N, 1, 1, F).

fac(N, P, F, R1) :- N > P, P1 is P+1, R is F*P1, fac(N, P1, R, R1).
fac(N, N, F, F).

factorial(0,F,F).

factorial(N,A,F) :-
	    N > 0,
	        A1 is N*A,
		    N1 is N -1,
		        factorial(N1,A1,F).
