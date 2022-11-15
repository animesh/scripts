print("USAGE:Rscript proteinGroups.r <complete path to proteinGroups.txt file> <LFQ or SILAC if performed else it defaults to raw Intensity columns>")
#example####
#..\R\bin\Rscript.exe proteinGroupsSplit.r "L:\promec\Qexactive\LARS\2022\NOVEMBER\combined\txt\proteinGroups.txt"
#supplying input file for testing
#inpF<-file.path("L:/promec/Qexactive/LARS/2022/NOVEMBER/combined/txt/proteinGroups.txt")
#parse argument(s)0
args = commandArgs(trailingOnly=TRUE)
print(paste("supplied argument(s):", length(args)))
print(args[1])
#read####
if(length(args)==0){print(paste("No proteinGroups.txt file supplied"))} else if (length(args)>0){inpF<-args[1]}
print(paste("Using proteinGroups.txt file",inpF,"with dimension(s)"))
#read MaxQuant output
options(nwarnings = 1000000)
data<-read.table(inpF,header=T,sep="\t")
dim(data)
selection="Intensity."
#selection<-"iBAQ."
#selection="LFQ.intensity"
outP<-paste(inpF,selection,"pdf",sep = ".")
pdf(outP)
print("Selecting Raw Intensity Values(s)")
if(sum(grep(selection,colnames(data)))>0){intensity<-as.matrix(data[,grep(selection,colnames(data))])}  else if(sum(grep("Abundance.",colnames(data)))>0){intensity<-as.matrix(data[,grep("Abundance.",colnames(data))])}  else{print('Neither Abundance[PD] nor Intensity[MQ] columns detected!')}
#logInt####
intensityLFQ<-log2(intensity)
intensityLFQ[intensityLFQ==-Inf]=NA
print("Quantified protein-groups(s)")
data.frame(colSums(!is.na(intensityLFQ)))
print("Unquantified protein-groups(s)")
data.frame(colSums(is.na(intensityLFQ)))
isNA<-colSums(is.na(intensityLFQ))/colSums(!is.na(intensityLFQ))
print("Proportion of NA(s)")
print(isNA)
#summary(data)
#clean####
nData<-nrow(data)
#data = data[!data[["Reverse"]]=="+",]
dim(data)
nrow(data)/nData
#data = data[!data[["Potential.contaminant"]]=="+",]
dim(data)
nrow(data)/nData
#data = data[!data[["Only.identified.by.site"]]=="+",]
dim(data)
nrow(data)/nData
print("Removed Reverse,Potential.contaminant and Only.identified.by.site")
protNum<-1:nrow(data)
row.names(data)<-paste(protNum,data$Fasta.headers,data$Protein.IDs,data$Peptide.sequences,sep=";")
print("Converted Fasta.headers to rownames")
#summary(data)
#select raw intensity
print("Selecting Raw Intensity Values(s) after filtering")
if(sum(grep(selection,colnames(data)))>0){intensity<-as.matrix(data[,grep(selection,colnames(data))])}  else if(sum(grep("Abundance.",colnames(data)))>0){intensity<-as.matrix(data[,grep("Abundance.",colnames(data))])}  else{print('Neither Abundance[PD] nor Intensity[MQ] columns detected!')}
protNum<-1:ncol(intensity)
colnames(intensity)=paste(protNum,sub(selection,"",colnames(intensity)),sep="_")
LFQ=intensity
summary(LFQ)
dim(LFQ)
#select certain marker proteins and calculate their intensity proportion, e.g. using histone as a protein ruler http://www.coxdocs.org/doku.php?id=perseus:user:plugins:proteomicruler
LFQhistone<-LFQ[grep("histone",row.names(LFQ),ignore.case = TRUE),]
#summary(LFQhistone)
print("Proportion of histone(s)")
dim(LFQhistone)
if(!is.null(dim(LFQhistone))){colSums(LFQhistone)/colSums(LFQ)*100}
LFQactin<-LFQ[grep("actin",row.names(LFQ),ignore.case = TRUE),]
#summary(LFQactin)
print("Proportion of actin(s)")
dim(LFQactin)
if(!is.null(dim(LFQactin))){colSums(LFQactin)/colSums(LFQ)*100}
log2LFQ<-LFQ
log2LFQ[log2LFQ==0]=NA
print("LFQ protein-groups(s)")
data.frame(colSums(!is.na(log2LFQ)))
print("unLFQ protein-groups(s)")
data.frame(colSums(is.na(log2LFQ)))
isNA<-colSums(is.na(log2LFQ))/colSums(!is.na(log2LFQ))
print("Ratio protein-groups(s)")
print(isNA)
log2LFQimpCorr<-cor(log2LFQ,use="pairwise.complete.obs",method="pearson")
colnames(log2LFQimpCorr)<-paste0(sapply(strsplit(colnames(log2LFQ),"_"), `[`, 2),gsub("\\.","",sapply(strsplit(colnames(log2LFQ),"_"), `[`, 3)))
rownames(log2LFQimpCorr)<-colnames(log2LFQimpCorr)
heatmap(log2LFQimpCorr)
dim(log2LFQ)
log2LFQt<-na.omit(log2LFQ)
dim(log2LFQ)
summary(log2LFQ)
summary(intensityLFQ)
  boxplot(intensity)
  par(mar=c(12,3,1,1))
  boxplot(intensityLFQ,las=2)
  par(mar=c(12,3,1,1))
  boxplot(log2LFQ,las=2)
  Uniprot<-sapply(strsplit(row.names(log2LFQ),";"), `[`, 2)
  uniprot<-sapply(strsplit(Uniprot,"|",fixed=TRUE),`[`, 2)
  #i=1
  #plot LFQ histogram
  write.csv(log2LFQ,paste(inpF,selection,".csv",sep="."))
  for(i in 1:dim(log2LFQ)[2]){
    hist(log2LFQ[,i],main=paste("File:",colnames(log2LFQ)[i]),sub=paste("Quantified Protein Group(s):",sum(!is.na(log2LFQ[,i])),"NA",sum(is.na(log2LFQ[,i]))),xlab=paste("Select ",selection),breaks=log2(max(log2LFQ,na.rm=T)/min(log2LFQ,na.rm=T)),xlim=c(min(log2LFQ,na.rm=T), max(log2LFQ,na.rm=T)))
    log2LFQsel<-data.frame(log2LFQ[!is.na(log2LFQ[,i]),i])
    fastaNames<-rownames(log2LFQsel)
    uniprot<-sapply(strsplit(fastaNames,"|",fixed=T), `[`, 2)
    gene<-sapply(strsplit(fastaNames,"GN=",fixed=TRUE),`[`, 2)
    gene<-sapply(strsplit(gene," ",fixed=TRUE),`[`, 1)
    colnames(log2LFQsel)<-selection
    log2LFQsel<-cbind(uniprot,gene,fastaNames,data.frame(log2LFQsel))
    log2LFQsel<-data.frame(log2LFQsel[order(-log2LFQsel$Intensity.),])
    write.csv(log2LFQsel,paste(inpF,selection,colnames(log2LFQ)[i],".csv",sep="."),row.names = F)
  }
  #pca
dev.off()
summary(warnings())
