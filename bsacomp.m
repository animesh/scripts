bsad=csvread('X:\Elite\Mohmd\bsad.csv')
bsat=csvread('X:\Elite\Mohmd\bsat.csv')

%hist(bsat(bsat(:,1)>0,1),[100])
hist(bsat(:,1),[100])

hold

%hist(bsad(bsad(:,1)>0,1),[100])
hist(bsad(:,1),[100])

h = findobj(gca,'Type','patch')

display(h)
set(h(1),'FaceColor','b','EdgeColor','k','facealpha',0.5);
set(h(2),'FaceColor','y','EdgeColor','k','facealpha',0.5);

hold

%% text

hold
ksdensity(bsat(:,1))
hold
ksdensity(bsad(:,1))

%% peptides
bsadp=csvread('X:\Elite\Mohmd\bsadpep.csv')
bsatp=csvread('X:\Elite\Mohmd\bsatpep.csv')

hist(bsatp(:,12))
hold
hist(bsadp(:,12))
h = findobj(gca,'Type','patch')

display(h)
set(h(1),'FaceColor','b','EdgeColor','k','facealpha',0.5);
set(h(2),'FaceColor','y','EdgeColor','k','facealpha',0.25);
hold


%% multi report

prot=xlsread('X:\Elite\Mohmd\Multiconsensus from 2 Reports.xlsx');
axis square
plot(prot(:,6),prot(:,10),'r.')
axis equal
plot(prot(:,7),prot(:,11),'r.')

%% peptide MR

pep=xlsread('X:\Elite\Mohmd\Multiconsensus from 2 ReportsPep.xlsx')
plot(pep(:,10),pep(:,12),'r.')


%% compeare
[h,p,ci]=ttest(prot(:,6),prot(:,10))

