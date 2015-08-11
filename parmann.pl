%"Stanardbibliotek":

%Not er vist ikke innebygd!?
not(P) :- call(P), !, fail.
not(_).

%BL er List med X insertet et sted
insert(X,List,BL):-
 del(X,BL,List).

%sann hviss tredjeargument er andreargument med X fjernet.
del(X,[X|T],T).
del(X,[H|T],[H|NT]):-del(X,T,NT).



%%N queen problem:

%Printemetode for et sjakkbrett.
row(N,R,[H|T]):- (H is R -> write(q) ; write(.)),row(N,R,T).
row(N,R,[]) :- nl.
board(N,R,L):- R =< N -> row(N,R,L), board(N,R+1,L) ; nl.

%Om bretttet er konsistent diagonalt, bruker hjelpemetoden under
legalDia([]).
legalDia([H|L]) :-
	legalDiaHelp(H,1,L),
	legalDia(L).
%Hjelpemetode for legalDia
legalDiaHelp(_,_,[]).
legalDiaHelp(Num,Diff,[H|T]) :-
	not(H is (Num + Diff)),
	not(H is (Num - Diff)),
	NyDiff is (Diff + 1),
	legalDiaHelp(Num, NyDiff, T).

%Om brettet er et lovlig brett.
legalBoard(L):-
	legalDia(L).

%Lager en liste med N tall fra N og nedover.
list(0,[]).
list(N,[N|T]):-!,
	N > 0,
	NyN is N-1,!,
	list(NyN,T).

%Alle mulige permutasjoner av en liste med elementer.
perm([],[]).
perm([H|L],Perm):-
	perm(L,BP),
	insert(H,BP,Perm).

%Sann hviss L er en løsning på N queen problem.
queen(N,L):-
	list(N,ListeMedNTall), %Liste med N tall
	perm(ListeMedNTall,L), %L blir en permutasjon
	legalBoard(L),
	nl,
	board(N,1,L). %Men er L lovlig tro?
	


%%Kartproblem:

%Sann hviss A er nabo til B i nabokartet.
nabo(A,B,[A:B|_]).
nabo(A,B,[B:A|_]).
nabo(A,B,[_|T]) :- nabo(A,B,T).

%Sann hviss B er alle naboene til A i NaboKart
alle_naboer(A,B,NaboKart):-
	bagof(N,nabo(A,N,NaboKart),B).

%Sann hviss Land har Farge i FargeKart
land_farge(Land,Farge,[Land:Farge|_]):-!.
land_farge(Land,Farge,[_:_|FargeKart]):-
	land_farge(Land,Farge,FargeKart).

%Sann hviss A er et land i nabolisten.
land(A,[A:_|_]).
land(A,[_:A|_]).
land(A,[_|Nabo]) :-
	land(A,Nabo).


%Hjelpemetode for nabo_farger. Egentlig en slags mapcar, kj0rer land_farge paa alle landene i en naboliste.
h_nabo_farge([],F,_,F).
%Bruker '->' her da land_farge ikke alltid er true (om landet ikke har en farge), 
%men da vil vi fortsatt videre nedover.
h_nabo_farge([H|NaboListe],FargeListe,FargeKart,FargeAkk):-
	land_farge(H,Farge,FargeKart) -> h_nabo_farge(NaboListe,FargeListe,FargeKart,[Farge|FargeAkk]);
	 h_nabo_farge(NaboListe,FargeListe,FargeKart,FargeAkk).

%Sann hviss Farger er en liste over fargene til alle naboene til Land.
nabo_farger(Land,Farger,NaboKart,FargeKart):-
	alle_naboer(Land,NaboListe,NaboKart),
	h_nabo_farge(NaboListe,Farger,FargeKart,[]).
    


%Lovlig hviss fargeKart ikke gir noen naboer like farger.
lovlig(_,_,[]).
lovlig(AlleFarger, Kart, [HLand:HFarge|FargeKart] ):-
	member(HFarge,AlleFarger),
	nabo_farger(HLand,NaboFarger,Kart,FargeKart),
	not(member(HFarge,NaboFarger)),
	lovlig(AlleFarger, Kart, FargeKart).

%Lager permutasjoner av land og farger.
farge_perm([],_,Perms,Perms).
farge_perm([H|Land],Farger,Perms,Pakk):-
	member(X,Farger),
	farge_perm(Land,Farger,Perms,[H:X|Pakk]).

col(Farger,Naboer,Fargekart):-
	setof(EttLand, land(EttLand,Naboer), Land),
	farge_perm(Land,Farger,Fargekart,[]),
	lovlig(Farger,Naboer,Fargekart).

