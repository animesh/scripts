%% download AICDA sequence

AICDA=getgenpept('Q9GZX7')
AICDA.Sequence

%% in silico trypsin digestion of AICDA with Trypsin

[AICDApartsT, AICDAsitesT, AICDAlengthsT] = cleave(AICDA, 'trypsin','missedsites',1)
plot(AICDAlengthsT)
hist(AICDAlengthsT)
size(AICDAlengthsT)


%% add PO3 to S/T/Y and calculate+write molecular weight of fragments to file

po3mm=MolMass('HPO3')

fileID = fopen('AICDAfragsT.tab.txt','w');

for i=1:size(AICDAsitesT,1)
    if(AICDAlengthsT(i)>=8)
        stypos=regexp(upper(AICDApartsT{i}),'[STY]')
        fprintf(fileID,'%s\t%s\t%5.5f\n',[int2str(i),' ',int2str(AICDAlengthsT(i))], ...
            AICDApartsT{i}, molweight(AICDApartsT{i}));
        for j=1:size((stypos'),1)
            fprintf(fileID,'%s\t%s\t%5.5f\n',[int2str(i),' ',int2str(stypos(j))], ...
                AICDApartsT{i}(1:stypos(j)), molweight(AICDApartsT{i})+j*po3mm);
        end
    end
end
fclose(fileID);


%% in silico trypsin digestion of AICDA with http://web.expasy.org/peptide_cutter/peptidecutter_enzymes.html#LysC

[AICDApartsL, AICDAsitesL, AICDAlengthsL] = cleave(AICDA, 'lysc','missedsites',1)
plot(AICDAlengthsL)
hist(AICDAlengthsL)
size(AICDAlengthsL)


%% add PO3 to S/T/Y and calculate+write molecular weight of fragments to file

po3mm=MolMass('HPO3')


fileID = fopen('AICDAfragsL.tab.txt','w');

for i=1:size(AICDAsitesL,1)
    if(AICDAlengthsL(i)>=8)
        stypos=regexp(upper(AICDApartsL{i}),'[STY]')
        fprintf(fileID,'%s\t%s\t%5.5f\n',[int2str(i),' ',int2str(AICDAlengthsL(i))], ...
            AICDApartsL{i}, molweight(AICDApartsL{i}));
        for j=1:size((stypos'),1)
            fprintf(fileID,'%s\t%s\t%5.5f\n',[int2str(i),' ',int2str(stypos(j))], ...
                AICDApartsL{i}(1:stypos(j)), molweight(AICDApartsL{i})+j*po3mm);
        end
    end
end
fclose(fileID);


%% in silico trypsin digestion of AICDA with ARG-C proteinase http://www.mathworks.se/help/bioinfo/ref/cleavelookup.html#brp475t-5

[AICDApartsA, AICDAsitesA, AICDAlengthsA] = cleave(AICDA, 'arg-c','missedsites',1)
plot(AICDAlengthsA)
hist(AICDAlengthsA)
size(AICDAlengthsA)

%% add PO3 to S/T/Y and calculate+write molecular weight of fragments to file

po3mm=MolMass('HPO3')


fileID = fopen('AICDAfragsA.tab.txt','w');

for i=1:size(AICDAsitesA,1)
    if(AICDAlengthsA(i)>=8)
        stypos=regexp(upper(AICDApartsA{i}),'[STY]')
        fprintf(fileID,'%s\t%s\t%5.5f\n',[int2str(i),' ',int2str(AICDAlengthsA(i))], ...
            AICDApartsA{i}, molweight(AICDApartsA{i}));
        for j=1:size((stypos'),1)
            fprintf(fileID,'%s\t%s\t%5.5f\n',[int2str(i),' ',int2str(stypos(j))], ...
                AICDApartsA{i}(1:stypos(j)), molweight(AICDApartsA{i})+j*po3mm);
        end
    end
end
fclose(fileID);


