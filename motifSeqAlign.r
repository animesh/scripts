#Rscript motifSeqAlign.r  L:\promec\Animesh\Motif\uniprot_sprot.motif.found.seq.txt "enolase"
#setup####
args = commandArgs(trailingOnly=TRUE)
print(paste("supplied argument(s):", length(args)))
inpF <- args[1]
#perl motif.pl uniprot_sprot.fasta "[RK][FWY][ALVI][GALVI][RK]" | awk -F '\t' '$3!=""' > uniprot_sprot.motif.found.seq.txt
#inpF<-"L:/promec/Animesh/Motif/uniprot_sprot.motif.found.seq.txt"
annotationGO <- args[2]
#annotationGO <- "enolase"
print(args)
#data####
data<-read.csv(inpF,sep="\t",header=T)
data[,"Uniprot"]<-sapply(strsplit(rownames(data),"\\|"),function(x) x[2])
data[,"UnID"]<-sapply(strsplit(sapply(strsplit(rownames(data),"\\|"),function(x) x[3])," "),function(x) x[1])
data[,"Gene"]<-sapply(strsplit(sapply(strsplit(rownames(data),"GN="),function(x) x[2])," "),function(x) x[1])
data[,"Species"]<-sapply(strsplit(sapply(strsplit(rownames(data),"OS="),function(x) x[2])," "),function(x) x[2])
dataS<-data[grepl(annotationGO,rownames(data)),]#cos ,ignore.case=TRUE),] includes probable sequence
print(colnames(dataS))
print(summary(dataS))
print(dim(dataS)[1])
write.csv(dataS,paste0(inpF,basename(annotationGO),".csv"))
writexl::write_xlsx(cbind(rownames(dataS),dataS),paste0(inpF,basename(annotationGO),".xlsx"))
cat(do.call(rbind,lapply(1:nrow(dataS),function(x) rbind(paste0(">",dataS[x,"Species"],dataS[x,"X.RK..FWY..ALVI..GALVI..RK..found.as.Sequence.s..Position.s.0.for.1st.."],dataS[x,"UnID"]),dataS[x,"Sequence.Header.in.uniprot_sprot.fasta"]))),sep="\n",file=paste0(inpF,basename(annotationGO),".fasta"))
print(paste0(inpF,basename(annotationGO),".fasta"))
#meme uniprot_sprot.motif.found.seq.txtvalS.fasta -protein -oc . -nostatus -time 14400 -mod oops -nmotifs 3 -minw 6 -maxw 50 -objfun classic -markov_order 0
#https://meme-suite.org/meme/info/status?service=MEME&id=appMEME_5.5.71734442863187409890499
#meme uniprot_sprot.motif.found.seq.txtvalS.fasta -protein -oc . -nostatus -time 14400 -mod zoops -nmotifs 3 -minw 5 -maxw 5 -objfun classic -markov_order
#https://meme-suite.org/meme/opal-jobs/appMEME_5.5.71734442863187409890499/meme.html
#meme uniprot_sprot.motif.found.seq.txtvalS.fasta -protein -oc . -nostatus -time 14400 -mod zoops -nmotifs 10 -minw 5 -maxw 5 -objfun classic -markov_order 0
#https://meme-suite.org/meme/info/status?service=MEME&id=appMEME_5.5.717344454173761278761072
#https://www.ebi.ac.uk/jdispatcher/msa/clustalo/summary?jobId=clustalo-I20241218-095608-0553-62464059-p1m
