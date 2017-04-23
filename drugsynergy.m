%% read data

synergi=xlsread('L:\Elite\kamila\Copy of FA UDC IM raw data.xlsx')

%% synergy check
dLR5=synergi(2:5,1:4)'
dLR5=synergi(2:5,6:9)'
dLR5=synergi(7:10,1:4)'
dLR5=synergi(7:10,6:9)'
d=dLR5(:,2:4)./repmat(dLR5(:,1),1,3) % control normalization
p=anova2(d,1,'off')
[h p]=ttest(2-(d(:,1)+d(:,2)),1-d(:,3)) % two tailed t test for effect


%% fit and f-stat
ds=mat2dataset(d)
fitlm(ds,'RobustOpts','on')
fitlm(ds,'d3~1+d1*d2')
fitlm(ds,'d3~1+d1+d2')

%% two way anova
anova2(mat2dataset(dLR5),1)
boxplot(dLR5)
boxplot(dLR5(:,2:4)./repmat(dLR5(:,1),1,3))
d=dLR5(:,2:4)./repmat(dLR5(:,1),1,3)
corrcoef(d(:,1).*d(:,2),d(:,3))
anovan(reshape(d(:,1:2),1,8),{[repmat({'m'},1,4) repmat({'n'},1,4)] [repmat({'a'},1,4) repmat({'b'},1,4)]},'model','interaction')
anova2(reshape(dLR5,size(dLR5,1)*size(dLR5,2)))
ds=mat2dataset(dLR5(:,2:4)./repmat(dLR5(:,1),1,3))
anovan(ds.Var3,{ds.Var1 ds.Var2},'model','interaction')
mdl = stepwiselm(mat2dataset(dLR5(:,2:4)./repmat(dLR5(:,1),1,3)),'interactions')
plotInteraction(mdl,Var2)
anova2((dLR5(:,2:4)./repmat(dLR5(:,1),1,3)))

y = [ds.Var1;ds.Var2;ds.Var3]
g1 = [repmat(1,4,1);repmat(0,8,1)]
g2 = [repmat(0,4,1);repmat(1,4,1);repmat(0,4,1)]
g3 = [repmat(0,8,1);repmat(1,4,1)]
p = anovan(y,{g1 g2 g3},'model','interaction')
p = anovan(y,{g1 g2},'model',2,'sstype',3,'random',1)
p = anovan(ds.Var3,{ds.Var1 ds.Var2},'model',2,'sstype',3,'random',1)


[h p]=ttest(2-(d(:,1)+d(:,2)),1-d(:,3))
[h p]=anova2([d(:,1) d(:,2) d(:,3)])
plot(2-(d(:,1)+d(:,2)),1-d(:,3),'r.')

