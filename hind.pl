/**** A. CHESS QUEENS ****/

/* N er antall kollonner, Q er en loesning */
queen(N,Q) :- genlist(1,N,R),
              perm(Q,R),
              diagonal(Q).

/* Genererer en liste av alle tall mellom A og B */
genlist(A,A,[A]).
genlist(A,B,[A|L]) :- A < B, N is A+1, 
                      genlist(N,B,L).

/* Genererer alle permutasjoner av en liste.
   Sammen med genlist blir det garanti for at
   Ingen dronninger kan angripe hverandre 
   horisontalt eller vertikalt */
perm([],[]).
perm([Y1|Y],Q) :- fjern(Y1,Q,R),
                  perm(Y,R).

/* Tar ut element X fra en liste */
fjern(X1,[X1|X],X).
fjern(X1,[Y1|Y],[Y1|Z]) :- fjern(X1,Y,Z).

/* Tester at ingen dronninger staar paa samme diagonalonal */
diagonal(Q) :- diagonal(Q,1,[],[]).
diagonal([],_,_,_).
diagonal([Y1|Y],X1,C,D) :- C1 is X1-Y1,
/* member sjekker om C1 et element i mengden C */
                       \+ member(C1,C),
                       D1 is X1+Y1, 
                       \+ member(D1,D),
                       X2 is X1+1,
                       diagonal(Y,X2,[C1|C],[D1|D]).


/**** B. MAP COLOURING ****/

/* Lager liste over alle ulike land i Land_liste */
/* setof samler alle X-er som er resultat av finnes(X,Land_liste),
   resultatet er listen S */
list(Land_liste,S) :- setof(X,finnes(X,Land_liste),S).

/* Kontrollerer om et land, X, finnes i listen Y */
finnes(X,Y) :- member(X:_,Y);
               member(_:X,Y).

/* Fargelegger M med fargene i Farger */
col(Farger,M,Farging) :- list(M,Land),
                         fargelegg(Farger,Land,Farging),
                         \+ ulovlig(M,Farging).
fargelegg(_,[],[]). 
fargelegg(Farger,[R1|R],[R1:F|A]) :- member(F,Farger),
                                     fargelegg(Farger,R,A).

/* Sjekker om to land med samme farge ligger inntil hverandre */
ulovlig(M,Farging) :- member(X:Z,Farging),
                      member(Y:Z,Farging),
                      inntil(X,Y,M).

/* Kontrollerer om landene X og Y er par i listen M */
/* member kontrollerer om et element inngaar i en mengde */
inntil(X,Y,M) :- member(X:Y,M);
                 member(Y:X,M).
