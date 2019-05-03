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

%% get pubmed record for key words

%DRL=getpubmed('drug+AND+resistance+AND+proteomics','NUMBEROFRECORDS',1000)

DRL=getpubmed('drug+effect','NUMBEROFRECORDS',200)

%% do frequency count

word = regexp(lower([DRL(:).Abstract]),' ','split')';
[val,idxW, idxV] = unique(word);
num = accumarray(idxV,1);

%% exploratory 


mean(num) 
median(num)
skewness(num)
kurtosis(num)

find(abs(zscore(num))>3);

%% plot

[counts bins]=hist(num.*idxW)
plot(bins, counts)

ksdensity(num)

hist(log(num),[40])

histfit(num)
probplot('normal',num)


%% source

http://www.mathworks.com/matlabcentral/answers/39759
http://www.mathworks.se/help/bioinfo/ug/creating-get-functions.html
http://stackoverflow.com/questions/2597743/matlab-frequency-distribution
http://www.mathworks.se/help/stats/example.html

%% tika tools

http://pdfbox.apache.org/commandlineutilities/Overlay.html

java -jar C:\Users\animeshs\SkyDrive\pdfbox-app-1.7.1.jar ExtractText "V:\felles\PROTEOMICS and XRAY\Articles in prep\AAG\litsur\MCP-2006-Stewart-433-43.pdf"


