edge(a,b).
edge(b,c).
edge(c,d).
edge(d,a).

connect(X,Y) :- edge(X,Y) ; edge(Y,X).
path(A,B,Path) :- vei(A,B,[A],Q), 
reverse(Q,Path).
vei(A,B,P,[B|P]) :- connect(A,B).
vei(A,B,Visited,Path) :- connect(A,C),C \== B,\+member(C,Visited),vei(C,B,[C|Visited],Path).