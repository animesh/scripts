%%^^A%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%^^A This is a sample file to demonstrate the use of the \LaTeX style option 
%%^^A pl.sty.
%%^^A
%%^^A The ^^A is just used to make it printable with the documentation.
%%^^A doc.sty insists on it. Otherwise a single % would have been enough.
%%^^A
%%^^A written by gene 11/94
%%^^A%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

:- module(sample). /*

This is a dummy module to show the possibilities of the \LaTeX{} style
option pl.
We define a predicate. It looks like

\Predicate select/3(Member, List, Rest).

This predicate describes the relation of the three arguments which fulfill
$\mbox{\it Member}\in\mbox{\it List}$\/ and $\mbox{\it Rest}=\mbox{\it
List}\backslash\mbox{\it Member}$.

And here comes the implementation:
\PL*/
select(Member,[Member|Rest],Rest).
select(Member,[Head|List],[Head|Rest]) :-
	select(Member,List,Rest).
/*PL

\Predicate in/2(Member, List).

This predicate is a reimplementation of the predicate \verb|member/2|
using the \verb|select/3| predicate.

\PL*/
in(Member,List)  :-
	select(Member,List,_).
/*PL
Now we are done with the example.
\EndProlog*/
