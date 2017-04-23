/*<tt><pre>*/
/* "warren.pl", a parser by Warren   */
%use with our input routine
%parser(FileName) :-
%	open(FileName, 'read', Rstream) ,
%	read(Rstream,Z0) ,
%	close(Rstream) ,
%	program(Z0,Z,X) ,
%	write(Z) ,
%	write(X).
%
parser:- phrase(tokens(Z0),"if x == y then x=x+1 else y=y-1;"),program(Z0,Z,X),
	write(Z),write(X).

program(Z0,Z,X) :-
	statements(Z0,Z,X).

statements(Z0,Z,X):-
	statement(Z0,Z1,X0) ,
	reststatements(Z1,Z,X0,X).

reststatements([';'|Z0],Z,X0,[X0,;|[X]]) :-
	statements(Z0,Z,X).
reststatements(Z,Z,X,X).

statement([V,:=|Z0],Z,assign(name(V),Expr)):-
	atom(V) ,
	expr(Z0,Z,Expr).
statement([if|Z0],Z,if(Test,Then,Else)):-
	test(Z0,[then|Z1],Test) ,
	statement(Z1,[else|Z2],Then) ,
	statement(Z2,Z,Else).
statement([while|Z0],Z,while(Test,Do)):-
	test(Z0,[do|Z1],Test) ,
	statement(Z1,Z,Do).
statement([read,V|Z],Z,read(name(V))) :-
	atom(V).
statement([write|Z0],Z,write(Expr)) :-
	expr(Z0,Z,Expr).
statement(['('|Z0],Z,S) :-
	statements(Z0,[')'|Z],S).
statement([other|Z],Z,other).

test(Z0,Z,test(Op,X1,X2)):-
	expr(Z0,[Op|Z1],X1) ,
	comparisionop(Op) ,
	expr(Z1,Z,X2).

expr(Z0,Z,X) :-
	subexpr(2,Z0,Z,X).

subexpr(N,Z0,Z,X) :-
	N > 0 ,
	N1 is N - 1 ,
	subexpr(N1,Z0,Z1,X0) ,
	restexpr(N,Z1,Z,X0,X).
subexpr(0,[X|Z],Z,name(X)) :-
	atom(X).
subexpr(0,[X|Z],Z,const(X)) :-
	integer(X).
subexpr(0,['('|Z0],Z,X) :-
	subexpr(2,Z0,[')'|Z],X).

restexpr(N,[Op|Z0],Z,X1,X) :-
	op(N,Op),
	N1 is N - 1 ,
	subexpr(N1,Z0,Z1,X2) ,
	restexpr(N,Z1,Z,expr(Op,X1,X2),X).
restexpr(_,Z,Z,X,X).

%comparisionop(eq).  /* You could have also used '==','>', etc. */
comparisionop(==).  /* You could have also used '==','>', etc. */
comparisionop(gt).
comparisionop(lt).
comparisionop(ge).
comparisionop(le).
%comparisionop(ne).
comparisionop(<>).

op(2,*).
op(2,/).
op(1,+).
op(1,-).

