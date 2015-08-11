
% Oppgave 1

% blir brukt av alignment.
hjelp(X,[]).
hjelp([A|B],[A|D]):- hjelp(B,D).
hjelp([A|B],L):-hjelp(B,L).

alignment(Xs,Ys,Alignment):- hjelp(Xs,Alignment),hjelp(Ys,Alignment).

maximum([[]],M):-M=[].
maximum([A|[]],M):-M=A.
maximum([A|C],M):- valg(C,A,M).

valg([A|[]],B,M):-listlen(A,X),listlen(B,Y),X>Y,M=A.
valg([A|[]],B,M):-listlen(A,X),listlen(B,Y),X=<Y,M=B.
valg([A|C],B,M):- listlen(A,X),listlen(B,Y), Y>X,valg(C,B,M).
valg([A|C],B,M):- valg(C,A,M).

listlen([],0).
listlen([H|T],N):- listlen(T,N1),N is N1+1.

maxAlignment(Xs,Ys,A):-findall(N,alignment(Xs,Ys,N),L),maximum(L,A).


% Oppgave 2

% blir brukt av path, for aa sjekke om liste inneholder "maal" element. Hvis ja - returnerer ny liste N og ny "maal" K.
inneh(A,B,[(X,B)|Y],P,K):-P=Y,K=X.
inneh(A,B,[X|Y],[X|P],K):-inneh(A,B,Y,P,K).

path(A,B,[(A,B)|Y]).
path(A,B,Y):-  inneh(A,B,Y,N,K),path(A,K,N).
path(A,B,[(X,Z)|Y]):-path(A,B,Y).


% Oppgave 3

% fjerner mellomrom
remspace([],[]).
remspace(S1,S2) :- append(" ",R,S1),!,remspace(R,S2).
remspace([H|R],[H|S]) :- remspace(R,S).

m([Resultat|[]],[],Resultat).
m(NyListe,[N|Streng],Resultat):-N>=48,N=<57,K is N-48,m([K|NyListe],Streng,Resultat).
m([A,B|NyListe],[N|Streng],Resultat):- op(N,A,B,Res),m([Res|NyListe],Streng,Resultat).

op(Op,A,B,Res):-char_code('/',Op),Res is B/A.
op(Op,A,B,Res):-char_code('*',Op),Res is B*A.
op(Op,A,B,Res):-char_code('+',Op),Res is B+A.
op(Op,A,B,Res):-char_code('-',Op),Res is B-A.

evalPost(S,V):-remspace(S,St),m([],St,V).
