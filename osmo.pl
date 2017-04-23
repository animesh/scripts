%Oblig 3 Jan Ove Osmo(jos021@student.uib.no)

%Oppgave 1

queen([], X, X).
queen(UplassX, TryggX, X) :- perm(UplassX, UplassX1, Q), kombiner(TryggX, Q), queen(UplassX1, [Q|TryggX], X).
queen(N, X) :- laglist(1, N, Ns), queen(Ns, [], X).

kombiner(Xs, X) :- kombiner(Xs, X, 1).
kombiner([], _, _) :- !.
kombiner([Y|Ys], X, N) :-  X =\= Y+N,  X =\= Y-N, N1 is N+1, kombiner(Ys, X, N1).

perm([X|Xs], Xs, X).
perm([Y|Ys], [Y|Zs], X) :- perm(Ys, Zs, X).

laglist(N, N, [N]) :- !.
laglist(M, N, [M|Ns]) :- M < N, M1 is M+1, laglist(M1, N, Ns).

% svar på denne oppgaven ved å kjøre queen(N,X) kommer
% på formen [3,1,4,2] som vil være queen(4,X). første tall representerer
% rad1 og kolonne 3, tall2 er rad2 kolonne 1 osv.

%Oppgave 2

list(0,L,L) :- !.
list(N,L,R) :- Y is N-1, list(Y,L,[N|R]).

mekklist([],X,X).
mekklist([L1:L2|T],X,Y):- (member(L1,X)->(member(L2,X) -> mekklist(T,X,Y) ; 
	mekklist(T,[L2|X],Y));(member(L2,X) -> mekklist(T,[L1|X],Y) ;
	mekklist(T,[L1,L2|X],Y) ) ). 

nabo(_,[],[]):- !.
nabo(X,[X:Z|Kart],[Z|Y]):- nabo(X,Kart,Y),!.
nabo(X,[Z:X|Kart],[Z|Y]):- nabo(X,Kart,Y),!.
nabo(X,[_:_|Kart],Y):- nabo(X,Kart,Y).

finn(_,[],_):- fail.
finn(X,[X:Y|_],Y).
finn(X,[_|T],Y):- finn(X,T,Y).

nabofarge([],_,[]):-!.
nabofarge(_,[],[]):-!.
nabofarge([N|Naboer],Col,[F|Naboav]):- finn(N,Col,F), nabofarge(Naboer,Col,Naboav).
nabofarge([N|Naboer],Col,Naboav) :- not(finn(N,Col,_)), nabofarge(Naboer,Col,Naboav).

farge([],_,_,U,U).
farge([H|T],M,F,FL,X):- nabo(H,M,NL),nabofarge(NL,FL,NC),member(A,F),
	not(member(A,NC)),farge(T,M,F,[H:A|FL],X).

col(X,Y,Z):-mekklist(X,[],B), length(B,C),list(C,V,[]), reverse(V,G)
	,farge(G,X,Y,[],Z).