% INFO 121 - Obligatorisk Oppgave 3 %
%                                   %
%     Studentnummer: 181585         %
%        samarbeidet med 186041     %
%===================================%


% Oppgave 1 %
% --------- %



maxAlignment(X,Y,Longest):-
                   findall(N,allAlign(X,Y,[],N),List),
                   maximum(List,[],Longest).

maximum([],Longest,Longest):-!.


maximum([Head|Rest],Longest,X):-
                    length(Head,L1),
                    length(Longest,L2),
                    L1 > L2,
                    !,
                    maximum(Rest,Head,X).
                    
maximum([Head|Rest],Longest,X):-
                             maximum(NewList,Longest,X).


% Sender ut svaret når X-listen er ferdigsøkt
allAlign([],_,Alignment,Alignment).

% Finner alignment for et element, søker kun når X forekommer i Y-listen
allAlign([X|Xs],Y,Alignment,AllAlignment):-
                              member(X,Y),
                              alignment([X],Y,RestList,Alignment,NewAlignment),
                              allAlign(Xs,RestList,NewAlignment,AllAlignment).

% Søker videre med neste X-element om member-testen failer i det andre predikatet.
allAlign([X|Xs],Y,Alignment,AllAlignment):-
                              allAlign(Xs,Y,Alignment,AllAlignment).

alignment([],[],_,_,_).
alignment([],_,_,_,_).
alignment(_,[],_,_,_).


% Søker videre i neste element i y-listen om ikkematch.
alignment([X],[Y|Ys],RestList,Alignment,NewAlignment):-
                              X \== Y,
                              alignment([X],Ys,RestList,Alignment,NewAlignment).

% Returnerer funnet element, og restlisten som fortsatt må søkes
alignment([X],[X|Ys],RestList,Alignment,NewAlignment):-
                                    RestList = Ys,
                                    append(Alignment,[X],NewAlignment).
                                    



% Oppgave 2 %
% --------- %


%path(a,b,[(a,e),(a,c),(c,d),(d,b)])

% Sjekker om stien er funnet
path(A,B,List):-
                member((A,B),List).

% Sjekker om det finnes en sti fra A til en node i List,
% søker isåfall videre med den nye noden som A, og fjerner brukt sti fra List.
path(A,B,List):-
                member((A,Z),List),
                delete(List,(A,Z),NewList),
                path(Z,B,NewList).

% Oppgave 3 %
% --------- %


% Hovedfunksjon
evalPost(E,V):-
               atom_codes(AtomL,E), % Gjør om strengen til et atom
               concat_atom(List,' ',AtomL), % Gjør om atomet til en liste av enkeltelementene.
               calculateV(List,[],V).

% Beregner det endelige tallet når strengen er tom
calculateV([],[Head|Rest],V):-
                        atom_number(Head,V).

% Legger til nye tall på stacken
calculateV([Head|Rest],Stack,V):-
                      isNumber(Head),
                      append([Head],Stack,NewStack),
                      calculateV(Rest,NewStack,V).

% Tar seg av operatorene
calculateV([Head|Rest],Stack,V):-
                        head(Stack,First),
                        second(Stack,Second), % Henter ut listen (da concat_atom genererer to)
                        atom_number(First,FirstV),   % Henter ut verdien til det første tallet i stacken
                        atom_number(Second,SecondV), % Henter ut verdien til det andre tallet i stacken
                        getValue(FirstV,SecondV,Head,NewValue),% Beregner den nye verdien som skal erstatte de to som var der fra før av
                        atom_number(NewAtom,NewValue),        % Gjør verdien om til et atom igjen
                        tail2(Stack,ReducedStack), % Tar vekk de to tallene som ble brukt
                        append([NewAtom],ReducedStack,NewStack),   % Legger den nye verdien på toppen av stacken
                        calculateV(Rest,NewStack,V).           % Kaller videre
                                          

% Sjekker om noe er ett tall
isNumber(V):-
             char_code('0',Min),
             char_code('9',Max),
             char_code(V,This),
             This > Min,
             This < Max.

% Funksjoner for å beregne verdiene
getValue(N1,N2,Operator,Value):-
                          char_code('*',Mul),
                          char_code(Operator,This),
                          This == Mul,
                          Value is (N1 * N2).

getValue(N1,N2,Operator,Value):-
                                char_code('+',Sum),
                                char_code(Operator,This),
                                This == Sum,
                                Value is (N1 + N2).

getValue(N1, N2, Operator, Value):-
                           char_code('/',Div),
                           char_code(Operator,This),
                           This == Div,
                           Value is (N2 / N1).

getValue(N1, N2, Operator, Value):-
                           char_code('-',Sub),
                           char_code(Operator,This),
                           This == Sub,
                           Value is (N2 - N1).
%%%%%%%%%%%%%%%%%%%%
% Hjelpefunksjoner %
%%%%%%%%%%%%%%%%%%%%


head([Head|Tail],Head):-!.
head(Head,Head)!:-!.
second([First,Second|Tail],Second).
tail([Head|Tail],Tail).
tail2([First,Second|Tail],Tail).





            
