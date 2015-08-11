% Author:
% Date: 17.11.2008

% Program made with inspiration and help from the Prolog Tutorial website linked
% to in course resources for Compulsory Exercise 3. Adaptions have been made to
% suit a userselected number of queens, instead of a set number.

% Creates a list to hold numbers rising from 1 to the selected value

create_list(0,[]):- !.
create_list(N,List):-
     append([N],Temp,List),
     NewN is N-1,
     create_list(NewN,Temp).

% calculates the combinations which solves the queen puzzle

calculate(N,Per):-
     create_list(N,List),
     permutation(List,Per),
     unite(List,Per,Right,Left),
     difference_check(Right),
     difference_check(Left).

% looks at the values and put them into variables for use later on by the
% check function

unite([A1|A],[B1|B],[Right1|Right],[Left1|Left]) :-
     Right1 is A1 + B1,
     Left1 is A1 - B1,
     unite(A,B,Right,Left).
unite([],[],[],[]).

% Checks the values of diagonals

difference_check([A|B]) :-
     \+member(A,B),
     difference_check(B).
difference_check([A]).