function fn = digest(s,e,m,l,dct,tct,cl,ch,ntlc,mod,msite)
    fprintf('Sequence %s\t Enzyme %s\t Missed Cleavage %d\t Minimum Length %d MZ Range %d-%d\t Charge Range %d-%d\t N-term truncation %d\tModification %s-%s',s,e,m,l,dct,tct,cl,ch, ntlc, mod,msite);
    fn=[s,e,'MC',int2str(m),'L',int2str(l),'MZl',int2str(dct),'MZh',int2str(tct),'CHl',int2str(cl),'CHh',int2str(ch),'Ntrun',int2str(ntlc),'Mod',mod,'Site',msite,'.csv'];
    fileID = fopen(fn,'w');
    fas=[s,e,'MC',int2str(m),'L',int2str(l),'MZl',int2str(dct),'MZh',int2str(tct),'CHl',int2str(cl),'CHh',int2str(ch),'Ntrun',int2str(ntlc),'Mod',mod,'Site',msite,'.fasta'];
    fileIDfas = fopen(fas,'w');
    pm=1.007276466812;
    seq=getgenpept(s);
    [parts, sites, lengths] = cleave(seq, e,'missedsites',m)
    fprintf(fileID,'Mass [m/z],Polarity,Start [min],End [min],nCE,CS [z],Comment\n');
    lenseq=length(seq.Sequence);
    fprintf(fileIDfas,'>%s\t%s\t%d\n%s\n',seq.LocusName,seq.Definition,lenseq,upper(seq.Sequence));
    for i=1:size(sites,1)
        if(sites(i)<ntlc)
        for nt=1:lengths(i)
            if(length(parts{i}(nt:lengths(i)))>=l)
                [MD, Info, DF] =isotopicdist(parts{i}(nt:lengths(i)),'nterm','acetyl','showplot', false);
                fprintf(fileIDfas,'>%s\t%d-%d\t%d-%d\n%s\n',seq.LocusName,i,nt,sites(i),lengths(i),parts{i}(nt:lengths(i)));
                for cz=cl:ch
                    if(length(parts{i}(nt:lengths(i)))>=l & ((Info.MonoisotopicMass+cz*pm)/cz > dct) & ((Info.MonoisotopicMass+cz*pm)/cz < tct) & ((tct-((Info.MonoisotopicMass+ch*pm)/ch))>eps(tct)))
                        fprintf(fileID,'%6.6f,Positive,,,,%d,%s%d-%dP%d-%d%s\n',(Info.MonoisotopicMass+cz*pm)/cz,cz, seq.LocusName,i,nt,sites(i),lengths(i),parts{i}(nt:lengths(i)));
                    end
                    if(~isempty(mod) & ~isempty(msite))
                        modw=MolMass(mod);
                        stypos=regexp(upper(parts{i}(nt:lengths(i))),msite);
                        for j=1:size((stypos'),1)
                            if(length(parts{i}(nt:lengths(i)))>=l & ((Info.MonoisotopicMass+j*modw+cz*pm)/cz > dct) & ((Info.MonoisotopicMass+j*modw+cz*pm)/cz < tct) & ((tct-((Info.MonoisotopicMass+ch*pm)/ch))>eps(tct)))
                                fprintf(fileID,'%6.6f,Positive,,,,%d,%s%d-%dP%d-%d%s-%d%s\n',(Info.MonoisotopicMass+j*modw+cz*pm)/cz,cz, seq.LocusName,i,nt,sites(i),lengths(i),mod,stypos(j),parts{i}(nt:stypos(j)));
                            end
                        end
                    end
                end
            end
        end
        elseif(lengths(i)>=l)
            [MD, Info, DF] =isotopicdist(parts{i}, 'showplot', false);
            fprintf(fileIDfas,'>%s\t%d\t%d-%d\n%s\n',seq.LocusName,i,sites(i),lengths(i),parts{i});
            for cz=cl:ch
                if(lengths(i)>=l & ((Info.MonoisotopicMass+cz*pm)/cz > dct) & ((Info.MonoisotopicMass+cz*pm)/cz < tct) & ((tct-((Info.MonoisotopicMass+ch*pm)/ch))>eps(tct)))
                    fprintf(fileID,'%6.6f,Positive,,,,%d,%s-%d-%d-%d%s\n',(Info.MonoisotopicMass+cz*pm)/cz,cz, seq.LocusName,i,sites(i),lengths(i),parts{i});
                end
                if(~isempty(mod) & ~isempty(msite))
                    modw=MolMass(mod);
                    stypos=regexp(upper(parts{i}),msite);
                    for j=1:size((stypos'),1)
                        if(lengths(i)>=l & ((Info.MonoisotopicMass+j*modw+cz*pm)/cz > dct) & ((Info.MonoisotopicMass+j*modw+cz*pm)/cz < tct) & ((tct-((Info.MonoisotopicMass+ch*pm)/ch))>eps(tct)))
                            fprintf(fileID,'%6.6f,Positive,,,,%d,%s%d-%d-%d%s-%d%s\n',(Info.MonoisotopicMass+j*modw+cz*pm)/cz,cz,seq.LocusName,i,sites(i),lengths(i),mod,stypos(j), parts{i}(1:stypos(j)));
                        end
                    end
                end
            end
        end
    end
    fclose(fileID);
    fclose(fileIDfas);
end

% functional version using ideas from http://stackoverflow.com/questions/3569933/is-it-possible-to-define-more-than-one-function-per-file-in-matlab
