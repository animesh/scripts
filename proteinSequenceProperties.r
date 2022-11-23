#..\R\bin\Rscript.exe proteinSequenceProperties.r
#setup####
#https://github.com/dosorio/Peptides/
#install.packages("Peptides", dependencies=TRUE)
#https://github.com/jedick/canprot
#install.packages("canprot", dependencies=TRUE)
#http://chnosz.net/canprot/doc/canprot.html
#proteins <- c("LYSC_CHICK", "RNAS1_BOVIN", "AMYA_PYRFU")
#library(canprot)
#AA <- CHNOSZ::pinfo(CHNOSZ::pinfo(proteins))
#https://github.com/Proteomicslab57357/UniprotR
#install.packages("UniprotR", dependencies=TRUE)
#https://alakazam.readthedocs.io/en/stable/install/
#install.packages("alakazam", dependencies=TRUE)
#BiocManager::install("Biostrings")
#BiocManager::install("GenomicAlignments")
#Atomic Composition (number of C/H/N/O/S)
#Total number of negatively charged residues - Peptides package
#Total number of positively charged residues - Peptides package
#Aliphatic index - Alakazam package
#Grand average of hydropathicity (GRAVY) - Alakazam package
#data####
#inpF<-"L:/promec/Qexactive/LARS/2022/juli/toktam/PDv2p5/Beer/220706_toktam1_Proteins.txt.Abundance.Normalized..log2.csvSample14S1S20.0510.05ClassRemGroupsR1.txttTestBH.csv"
inpF<-"L:/promec/Qexactive/LARS/2022/juli/toktam/PDv2p5/Beer/220706_toktam1_Proteins.txt"
data<-read.table(inpF,header=T,sep="\t")
summary(data)
data = data[data[["Master"]]=="IsMasterProtein",]
#phyicoChemisT####
colnames(data)
summary(data["MW.in.kDa"])
hist(as.numeric(unlist(data["MW.in.kDa"])))
hist(as.numeric(unlist(data["calc.pI"])))
plot(as.numeric(unlist(data["calc.pI"])),as.numeric(unlist(data["MW.in.kDa"])))
#Peptides::mw(data$Sequence)
#data$Sequence[1]
#alakazam::charge(data$Sequence[1])
#alakazam::acidic(data$Sequence[1])
#alakazam::basic(data$Sequence[1])
#alakazam::bulkiness(data$Sequence[1])
#alakazam::bulk(data$Sequence[1])
#Peptides::mw(strsplit(data$Sequence,"")[[1]][1])
#Peptides::pI(strsplit(data$Sequence,"")[[1]][1])
#(Peptides::aaComp(strsplit(data$Sequence,"")))
#Peptides::charge(strsplit(data$Sequence,"")[[1]][1])
#aaPositive<-sapply(data$Sequence, sum(Peptides::charge(strsplit(x,""))>0))
#sum(Peptides::charge(strsplit(data$Sequence,"")[[1]])<(-0.9))
#sum(Peptides::lengthpep(strsplit(data$Sequence,"")[[1]]))
cor(Peptides::mw(data$Sequence),as.numeric(unlist(data["MW.in.kDa"])))
#plot(Peptides::mw(data$Sequence),as.numeric(unlist(data["MW.in.kDa"])))
cor(Peptides::pI(data$Sequence, pKscale="Bjellqvist" ),as.numeric(unlist(data["calc.pI"])))
#plot(Peptides::pI(data$Sequence, pKscale="Bjellqvist" ),as.numeric(unlist(data["calc.pI"])))
cor(Peptides::lengthpep(data$Sequence),as.numeric(unlist(data["Number.of.AAs"])))
#plot(Peptides::lengthpep(data$Sequence),as.numeric(unlist(data["Number.of.AAs"])))
seqProt<-data.frame(data$Sequence)
positive<-apply(seqProt,1,function(x) sum(Peptides::charge(strsplit(x,"")[[1]])>0.9))
negative<-apply(seqProt,1,function(x) sum(Peptides::charge(strsplit(x,"")[[1]])<(-0.9)))
#Peptides::charge("H")
#Peptides::pI("H")
charge<-Peptides::charge(data$Sequence)
aaSmiles<-Peptides::aaSMILES(data$Sequence)
gravy<-alakazam::gravy(data$Sequence)
aliphatic<-alakazam::aliphatic(data$Sequence)
#UniprotR####
#GeneOntologyObj <- UniprotR::GetProteinInteractions(rownames(data))
#GeneOntologyObj$ID <- rownames(GeneOntologyObj)
#write.csv(GeneOntologyObj,paste0(inpF,"GeneOntologyObj.csv"))
#length(grep(term,GeneOntologyObj$Gene.ontology..cellular.component.,ignore.case=T))
#GeneOntologyObj$term <- apply(GeneOntologyObj, 1, function(x)as.integer(any(grep(term,x,ignore.case=T))))
#sum(GeneOntologyObj$term)
protResults = data.frame(Uniprot=data$Accession,Protein=data$Description,positive,negative,gravy,aliphatic,AtomiComposite=aaSmiles)
write.csv(protResults,paste0(inpF,"protparamRemaining.csv"),row.names = F)
