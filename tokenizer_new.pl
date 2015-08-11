%Created by Bruno Dufour, Fall 2005
%
% Append
append([ ],A,A).
append([A|B],C,[A|D]) :- append(B,C,D).


gather(Chars) --> [C],  {alphaNumeric(C)}, gather(Rest), {Chars=[C|Rest]}.

gather([]) --> {true}.
alphaNumeric(C):- 96<C,C<123;
                  64<C, C<91;
                  47<C, C<58.

% - Floats ---------------------------------------------------------------------
digit(D) --> [D], {47 < D, D < 58}.
nzdigit(D) --> [D], {48 < D, D < 58}.

floatlit(F) -->
        nzdigit(D0),
        digits(D1),
        ".",
        nedigits(D2),
        {append([D0|D1], [46], T), append(T, D2, D), name(F, D)}.

nedigits([D|T]) -->
        digit(D), !,
        digits(T).

digits(L) --> nedigits(L).
digits([]) --> [].
% ------------------------------------------------------------------------------

% - Strings --------------------------------------------------------------------

quote('"').

gatherString(Chars) --> [C], {\+quote(C)}, gatherString(Rest), {Chars=[C|Rest]}.
gatherString([]) --> {true}.

stringlit(S) --> "\"", gatherString(Chars), "\"", {S = Chars}.

% ------------------------------------------------------------------------------

% Tokenize float
tokenize(Result) --> floatlit(F), tokenize(Rest), {Result=[F|Rest]}.
% Tokenize string
tokenize(Result) --> stringlit(S), tokenize(Rest), {Result=[S|Rest]}.
% Tokenize id / int
tokenize(Result)-->gather(Chars),{\+ Chars =[]},tokenize(RestResult), 
                 	{name(N,Chars), Result=[N|RestResult]}. 
% Discard whitespace
tokenize(R)-->[C],{C<33},tokenize(R).
% Tokenize special character
tokenize([N|R]) --> [C],{C>32},
                        {name(N,[C])},tokenize(R).
tokenize([])-->[].

