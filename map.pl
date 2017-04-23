/* map - Fargelegging av kart

Håvard Grimelid - hgrimelid@gmail.com
Trond Jacobsen  - tja026@student.uib.no */

% Querys for testing:
% col([red,blue],[1:2,2:3,3:4],Colouring).
% toNaboerMedLikFarge([1:2,2:3,3:4],[1:red,2:red,3:green,4:red]).
% fargeleggLand([1,2,3],[red,blue],[],Colouring).

% Hovedprogram.
% Finner mulige fargelegginger av land(Colouring), uten at naboer får samme farge. 
col(Colours,Map,Colouring) :-
        		finnLandUtenDup(Map,LandUtenDup), 
			fargeleggLand(LandUtenDup,Colours,[],Colouring), 
        		not(toNaboerMedLikFarge(Map,Colouring)).
		
%***************************************************************		
% Finner alle land uten duplikater fra liste med land (Map)
% på formen [1:2, 2:3,.... ]
finnLandUtenDup(Map,LandUtenDup) :- 
				finnLandMedDup( Map,[], LandMedDup ),
				fjernDup(LandMedDup,[], LandUtenDup ).
							
							
finnLandMedDup([H|T],A, LandMedDup) :- H=X:Y, 
					append([X],A,B),
					append([Y],B,C),
					finnLandMedDup(T,C,LandMedDup).							
finnLandMedDup([],C,C).


fjernDup([H|T],A,UtenDup) :- (not(member(H,A)) -> 
				append([H],A,B),
				fjernDup(T,B,UtenDup);
				fjernDup(T,A,UtenDup)).
fjernDup([],B,B).

%***************************************************************
% Gir farge til land 
fargeleggLand([H|T],Colours,A,Colouring) :-
					member(C,Colours),
					append(A,[H:C],B),
					fargeleggLand(T,Colours,B,Colouring).
fargeleggLand([],_,B,B).
		
%***************************************************************
% Er true hvis to naboer i Map har samme farge
toNaboerMedLikFarge(Map,Colouring) :-
				finnToLandLikFarge(Colouring,L1,L2),
				sjekkOmNabo(Map,L1,L2).

							
finnToLandLikFarge( Colouring, L1,L2) :- member(L1:F, Colouring),
					member(L2:F, Colouring).

% Sjekker om A og B er naboland
sjekkOmNabo( Map,A,B):- member(A:B,Map) ; member(B:A,Map). 
