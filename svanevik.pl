%A. Chess Queens
perm(1,[1]) :- !.
perm(N,L2) :- M is N - 1, perm(M,L), append(X1,X2,L), append(X1,[N|X2],L2).

diagclear(_,M,N,_) :- M > N, !.
diagclear([P|X],M,N,Acc) :-
  \+ member(P:M,Acc),
  pattern(P,M,N,BadL,[-,1]),
  pattern(P,M,N,BadM,[+,1]),
  append(BadL,BadM,Bad),
  M1 is M + 1,
  append(Bad,Acc,NewAcc),
  diagclear(X,M1,N,NewAcc).

pattern(P,M,N,[],_) :- (M > N ; P < 1 ; P > N), !.
pattern(P,M,N,Bad,[Hp|Tp]) :-
  Op =.. [Hp,P|Tp],
  Pnew is Op,
  Mmore is M + 1,
  pattern(Pnew,Mmore,N,Bad2,[Hp|Tp]),
  Bad = [Pnew:Mmore|Bad2].

queen(N,X) :-
  perm(N,X),
  diagclear(X,1,N,[]).

%B. Map colouring
countries([],Acc,Acc).
countries([H1:H2|T1],C,Acc) :-
  (member(H1,Acc) -> Acc2 = Acc ; Acc2 = [H1|Acc]),
  (member(H2,Acc2) -> Acc3 = Acc2 ; Acc3 = [H2|Acc2]),
  countries(T1,C,Acc3).

colour([],_,[]).
colour([H1|T1],Col,[H1:C|T2]) :-
  member(C,Col), colour(T1,Col,T2).

legal([],_).
legal([H1:H2|T1],Col) :-
  member(H1:C1,Col), member(H2:C2,Col), C1 \= C2, legal(T1,Col).

col(Col,F,C) :-
  countries(F,Cntr,[]), colour(Cntr,Col,C), legal(F,C).