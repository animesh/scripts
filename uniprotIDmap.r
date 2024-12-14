#C:\Users\animeshs>R-4.4.0\bin\Rscript.exe "drive\My Drive\scripts\uniprotIDmap.r"  L:\promec\Animesh\Motif\uniprot_sprot.motif.found.txt L:\promec\Animesh\Motif\GOeu.tsv
#setup####
#download.file("https://rest.uniprot.org/uniprotkb/stream?download=true&fields=accession%2Creviewed%2Cid%2Cprotein_name%2Cgene_names%2Corganism_name%2Clength%2Cgo_p%2Cgo_c%2Cgo_f%2Cxref_ensembl_full&format=tsv&query=%28%28reviewed%3Atrue%29+AND+%28taxonomy_id%3A2759%29%29","L:/promec/Animesh/Motif/GOeu.tsv")
args = commandArgs(trailingOnly=TRUE)
print(paste("supplied argument(s):", length(args)))
inpF <- args[1]
#perl motif.pl uniprot_sprot.fasta "[RK][FWY][ALVI][GALVI][RK]" | awk -F '\t' '$2!=""' > uniprot_sprot.motif.found.txt
#inpF<-"L:/promec/Animesh/Motif/uniprot_sprot.motif.found.txt"
annotationGO <- args[2]
#wget https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/complete/uniprot_sprot.fasta.gz
#gunzip uniprot_sprot.fasta.gz
#annotationGO <- "L:/promec/Animesh/Motif/GOeu.tsv"
print(args)
#data####
data<-read.csv(inpF,sep="\t",header=T)
data[,"Uniprot"]<-sapply(strsplit(data[,"Sequence.Header.in.uniprot_sprot.fasta"],"\\|"),function(x) x[2])
print(summary(data))
print(dim(data))
print(colnames(data))
#GO####
upData<-read.csv(annotationGO,sep="\t",header=T)
print(dim(upData))
print(names(upData))
annoGOBP<-data.frame(table(unlist(strsplit(upData[,"Gene.Ontology..biological.process."], "; "))))
#hist(annoGOBP$Freq)
print(summary(annoGOBP$Freq))
#dataGOBP<-dataGOBP[sort(dataGOBP$Freq,decreasing = F),]
write.csv(annoGOBP,paste0(annotationGO,"GOID.count.csv"))
#hist(log2(as.numeric(upData$Length)))
dataMap<-merge(data,upData,by.y="Entry",by.x="Uniprot")#,all=TRUE)
write.csv(dataMap,paste0(inpF,basename(annotationGO),"GOIDs.csv"))
#dataGOBP<-data.frame(table(unlist(strsplit(dataMap[,"Gene.Ontology..biological.process."], "\\[GO:|;|\\]"  , perl = TRUE))))
dataGOBP<-data.frame(table(unlist(strsplit(dataMap[,"Gene.Ontology..biological.process."], "; "))))
#dataGOBP<-dataGOBP[dataGOBP$Var1!="",]
#hist(dataGOBP$Freq)
print(summary(dataGOBP$Freq))
#dataGOBP<-dataGOBP[sort(dataGOBP$Freq,decreasing = F),]
write.csv(dataGOBP,paste0(inpF,basename(annotationGO),"GOID.count.csv"))
