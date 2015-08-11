evalPost(Xs,V):-evalPost(Xs,[],V).
evalPost([],[X],X).
evalPost([32|Ys],Xs,V):-evalPost(Ys,Xs,V).
evalPost([48|Ys],Xs,V):-evalPost(Ys,[0|Xs],V).
evalPost([49|Ys],Xs,V):-evalPost(Ys,[1|Xs],V).
evalPost([50|Ys],Xs,V):-evalPost(Ys,[2|Xs],V).
evalPost([51|Ys],Xs,V):-evalPost(Ys,[3|Xs],V).
evalPost([52|Ys],Xs,V):-evalPost(Ys,[4|Xs],V).
evalPost([53|Ys],Xs,V):-evalPost(Ys,[5|Xs],V).
evalPost([54|Ys],Xs,V):-evalPost(Ys,[6|Xs],V).
evalPost([55|Ys],Xs,V):-evalPost(Ys,[7|Xs],V).
evalPost([56|Ys],Xs,V):-evalPost(Ys,[8|Xs],V).
evalPost([57|Ys],Xs,V):-evalPost(Ys,[9|Xs],V).
evalPost([47|Ys],[First,Second|Xs],V):-Devide is Second/First,evalPost(Ys,[Devide|Xs],V). 
evalPost([43|Ys],[First,Second|Xs],V):-Sum is First+Second, evalPost(Ys,[Sum|Xs],V).
evalPost([42|Ys],[First,Second|Xs],V):-Prod is First*Second,evalPost(Ys,[Prod|Xs],V).
evalPost([45|Ys],[First,Second|Xs],V):-Minus is Second-First,evalPost(Ys,[Minus|Xs],V).

