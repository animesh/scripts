% Author:
% Date: 11.11.2008

%Problem A:

append([],L,L).
append([H|T],L,[H|TogL]) :- append(T,L,TogL).

% make_list makes a list X which contains [1,2,3....N].
make_list(0,[]) :- !.
make_list(N,X) :-
               K is N - 1,
               append(L,[N],X),
               (>(N,0) -> make_list(K,L)).

% queen makes lists containing the solutions for the N-queen problem. make_list makes the N long list,
% can_not_attack is called for each permutation of the List, and in the end, the solution boards are printed out.
% permutation(List,X) makes lists X of all permutations of List.
queen(N,X) :- make_list(N,List),
              print('Finding solutions for n='),print(N),nl,
              permutation(List,X),
              can_not_attack(X),board(N,1,X).

% can_not_attack checks if the list of queens is a valid solution to the N-queens problem. Calls on not_on_diag and is recursive, going through
% each column and checking if it "crashes" with another queen on the diagonal. Because of our representation of the board, we dont need a check
% to see if the queens are on the same column or row.
can_not_attack([_]) :- !.
can_not_attack([Col1|Other_Cols]) :- !,
                     not_on_diag(Col1,Other_Cols,1),
                     can_not_attack(Other_Cols).

% not_on_diag checks both diagonals if the queen Col is on the same diagonal as other queens. Dist is the distance from Col which gets updated
% in each recursive call (to check further down the diagonal). Right_diag and Left_diag is each of the two diagonals, which are checked up against
% the other queen. It makes a recursive call with an updated distance and the next queen in line to test against the Col queen.
not_on_diag(_,[],_) :- !.
not_on_diag(Col,[Col1|Rest],Dist) :-   !,
                               Right_diag is Col + Dist,
                               Left_diag is Col - Dist,
                               Col1 =\= Right_diag,
                               Col1 =\= Left_diag,
                               NewDist is Dist + 1,
                               not_on_diag(Col,Rest,NewDist).

%row and board are used to make a nicer representation of the boards, instead of just a list representation.
row(N,R,[H|T]):- (H is R -> print('|Q ') ; print('|. ')),row(N,R,T).
row(N,R,[]) :- nl.
board(N,R,L):- R =< N -> row(N,R,L), board(N,R+1,L) ; nl.


% Problem B:

% col first calls on insert_countries to get a list of the Countries in the Map, then calls on colour_countries which colours each country
% in the right way. Colouring is the answer which gives out a list of tuples with each country and it's colour
col(Colours,Map,Colouring) :- insert_countries(Map,Countries),
                              colour_countries(Countries,Colours,Map,Colouring).

% insert_countries makes a list (Countries) of all the countries, from the Map(a list of lists(tuples)). It checks if the country already
% exists and only adds it if it does. F.ex. the query insert_countries([[1,2],[2,3],[3,4]],[],X). will give the answer X = [1,2,3,4].
insert_countries([],Helplist,Helplist) :- !.
insert_countries([[Country,Neighbour]|Rest],Helplist,Countries) :-
                                              (member(Country, Helplist) -> (member(Neighbour,Helplist) ->
                                                                                      insert_countries(Rest,Helplist,Countries);
                                                                                      append(Helplist,[Neighbour],Result),
                                                                                      insert_countries(Rest,Result,Countries)) ;
                                                                             (member(Neighbour,Helplist) ->
                                                                                      append(Helplist,[Country],Result),
                                                                                      insert_countries(Rest,Result,Countries);
                                                                                      append(Helplist,[Country],List),
                                                                                      append(List,[Neighbour],Result),
                                                                                      insert_countries(Rest,Result,Countries))).

% colour_countries colours each country so that no neighbouring country has the same colour, makes a call on neighbours..
% colour_countries(Countries,Colours,Map,Coloured) :- ... .

% check_neighbours checks the neighbours of a country
% check_neighbours