hist(score)
hist(score,[100])
hist(score(score(:,1)>0),[100])
hist(score(log(score(:,1)>0)),[100])
hist(log(score(score(:,1)>0)),[100])
hist(mw(mw(:,1)<500),[40])
hist(mw(mw(:,1)<500),[50])
hist(mw(mw(:,1)<500),[200])
hist(mw(mw(:,1)<500),[100])
xlabel('Molecular Weight')
ylabel('# of proteins')
hist(log10(abd),[100])


trad=xlsread('L:\Plasma\BlooPlasmaProt_TradMethod_Anna_3CombinedFiLes.xlsx')
hist(direct(:,11),[40])
xlabel('Molecular Weight (Da.)')
ylabel('# Peptides')

direct=xlsread('L:\Plasma\BlooPlasmaProt_DirectMethod_Anna_3CombinedFiLes.xlsx')
hist((direct(direct(:,4)>0,4)),[105])
xlabel('Molecular Weight (Da.)')
ylabel('# Peptides')



bins = linspace(0,120,25)
%bins = unique([trad(:,4);direct(:,4)]); 
y1 = hist(trad(:,4), bins);   
y2 = hist(direct(:,4), bins);
bar(bins, [y1;y2]');
xlabel('# Unique Peptides')
ylabel('# Proteins')
[h p v]=ttest(trad(:,4),direct(:,4))

trad=xlsread('L:\Plasma\BlooPlasmaProt_TradMethod_Anna_3CombinedFiLesPep.xlsx')
hist(trad(:,11),[40])
xlabel('Molecular Weight (Da.)')
ylabel('# Peptides')




%% synaptos
trad=xlsread('L:\Plasma\SynaptospmalProteinComplexes_TraditionalMethod_16hrsDigestion_02_2CombFiLesPep.xlsx')
hist(trad(:,11),[40])
xlabel('Molecular Weight (Da.)')
ylabel('# Peptides')

direct=xlsread('L:\Plasma\SynaptospmalProteinComplexes_DirectMethod_16hrsDigestion_2CombFiLesPep.xlsx')
hist(direct(:,11),[40])
xlabel('Molecular Weight (Da.)')
ylabel('# Peptides')

%% comp

trad=xlsread('L:\Plasma\SynaptospmalProteinComplexes_TraditionalMethod_16hrsDigestion_02_2CombFiLes.xlsx')
hist(trad(:,11),[40])
xlabel('Molecular Weight (Da.)')
ylabel('# Peptides')

direct=xlsread('L:\Plasma\SynaptospmalProteinComplexes_DirectMethod_16hrsDigestion_2CombFiLes.xlsx')
hist(direct(:,11),[40])
xlabel('Molecular Weight (Da.)')
ylabel('# Peptides')


bins = linspace(1,50,50)
%bins = unique([trad(:,4);direct(:,4)]); 
y1 = hist(trad(:,4), bins);   
y2 = hist(direct(:,4), bins);
bar(bins, [y1;y2]');
xlabel('# Unique Peptides')
ylabel('# Proteins')
