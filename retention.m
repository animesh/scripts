prot = tblread('L:\Davi\Christina\Elite\allPeptides.txt','\t')
prot = tblread('L:\Results\Ishita\Copy of Log2abs0.5 GO.txt','\t');
prot = tblread('L:\Results\Ishita\Copy of Log2abs0.5 GO Col Znorm.txt','\t');
protcl=prot(:,1:12);
[x, fval, exitflag, output] = fminunc(fun,x0,'Algorithm','quasi-newton')
cubic = @(x) x^3+x^2+x
cubic(10)+1
protclremnan=knnimpute(protcl)
protclremnanzscore=zscore(protcl)
cm=clustergram(protcl,'ImputeFun','knnimpute')
cm.RowLabels
clustergram(protclremnanzscore)
pclz=zscore(protcl(1:5,1:5))