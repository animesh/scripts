%% read

el=xlsread('X:\Qexactive\130529_Incremental\Multiconsensus from 3 ReportsPepSNPG.xlsx')
el=xlsread('X:\Qexactive\130529_Incremental\ELINP.xlsx')


%% plot

hist(el(:,18)) % charge

hist(el(:,19),[100])     % detect

hist(el(:,20)) % MZ

hist(el(:,22),[100]) % RT

hist(el(:,21),[1000]) % RT


hist((el(:,18).*el(:,19))-(el(:,20)+el(:,18)-1))

%% write to file
mw=2.5
fc=1
fn=['EL',int2str(fc),'.csv'];
fileID = fopen(fn,'w');
fprintf(fileID,'Mass [m/z],Polarity,Start [min],End [min],nCE,CS [z],Comment\n');
for i = 1:size(el,1)
    if(el(i,1)==0 && el(i,14)==fc)
        fprintf(fileID,'%6.6f,Positive,%6.6f,%6.6f, ,%d,MH+%6.6f-Scan#%d\n',el(i,9),el(i,12)-mw,el(i,12)+mw,el(i,11),el(i,10),el(i,13));
    end
end
fclose(fileID);
