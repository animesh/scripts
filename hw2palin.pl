%append 2 lists
append([],A,A).
append([A|X],Y,[A|T]):- append(X,Y,T).


%reverse a list into another list
rev([],[]).
rev([H|T],L):-rev(T,Z),append(Z,[H],L).

%a palindrome is a list that is the same as its reverse
palin(X):- rev(X,Y),same(X,Y).

%same checks that each list contains the same elements
%note we do not have to explicitly check the elements as 
%the list constructor does that for us
same([],[]).
same([H|T],[H|X]):- same(T,X).

