print("USAGE:Rscript proteinGroups.r <complete path to proteinGroups.txt file> <LFQ or SILAC if performed else it defaults to raw Intensity columns>")
#example####
#..\R-4.2.1-win\bin\Rscript.exe proteinGroups.r "L:\promec\TIMSTOF\LARS\2022\august\220819 Toktam\combined\txt\proteinGroups.txt"
#supplying input file for testing
#inpF<-file.path("L:/promec/TIMSTOF/LARS/2022/august/Toktam/combined/txt/proteinGroups.txt")
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
selection="Intensity.";
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
data = data[!data[["Reverse"]]=="+",]
dim(data)
nrow(data)/nData
data = data[!data[["Potential.contaminant"]]=="+",]
dim(data)
nrow(data)/nData
data = data[!data[["Only.identified.by.site"]]=="+",]
dim(data)
nrow(data)/nData
print("Removed Reverse,Potential.contaminant and Only.identified.by.site")
protNum<-1:nrow(data)
row.names(data)<-paste(protNum,data$Fasta.headers,protNum,sep=";")
print("Converted Fasta.headers to rownames")
#summary(data)
#select raw intensity
print("Selecting Raw Intensity Values(s) after filtering")
if(sum(grep(selection,colnames(data)))>0){intensity<-as.matrix(data[,grep(selection,colnames(data))])}  else if(sum(grep("Abundance.",colnames(data)))>0){intensity<-as.matrix(data[,grep("Abundance.",colnames(data))])}  else{print('Neither Abundance[PD] nor Intensity[MQ] columns detected!')}
protNum<-1:ncol(intensity)
colnames(intensity)=paste(protNum,sub(selection,"",colnames(intensity)),sep="_")
intensityLFQ<-log2(intensity)
intensityLFQ[intensityLFQ==-Inf]=NA
data.frame(colSums(!is.na(intensityLFQ)))
data.frame(colSums(is.na(intensityLFQ)))
isNA<-colSums(is.na(intensityLFQ))/colSums(!is.na(intensityLFQ))
print(isNA)
#hist(intensity[,1])
#select from arg[]
rownames(intensity)<-rownames(data)
#logLFQ####
if(sum(grep("LFQ",colnames(data)))>0){
  selection="LFQ.intensity";print(paste("No columns to select, using"));
  LFQ<-as.matrix(data[,grep(selection,colnames(data))])
  protNum<-1:ncol(LFQ);colnames(LFQ)=paste(protNum,sub(selection,"",colnames(LFQ)),protNum,sep="_");print(selection)} else if (sum(grep("Ratio",colnames(data)))>0){
    selection1="Ratio."
    LFQ<-as.matrix(data[,grep(selection1,colnames(data))])
    selection2=".normalized."
    LFQ<-as.matrix(LFQ[,grep(selection2,colnames(LFQ))])
    selection<-paste(selection1,selection2)
    LFQ<-apply(LFQ,2, as.numeric)
    rownames(LFQ)<-rownames(data)
    colnames(LFQ)=sub(selection1,"",colnames(LFQ))
    colnames(LFQ)=sub(selection2,"",colnames(LFQ))
    protNum<-1:ncol(LFQ)
    colnames(LFQ)=paste(protNum,colnames(LFQ),protNum,sep="_")
    print(paste("Using proteinGroups.txt file column(s)",selection,"with dimension(s)"))
} else{LFQ=intensity}
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
log2LFQ<-log2(LFQ)
log2LFQ[log2LFQ==-Inf]=NA
print("LFQ protein-groups(s)")
data.frame(colSums(!is.na(log2LFQ)))
print("unLFQ protein-groups(s)")
data.frame(colSums(is.na(log2LFQ)))
isNA<-colSums(is.na(log2LFQ))/colSums(!is.na(log2LFQ))
print("Ratio protein-groups(s)")
print(isNA)
log2LFQimpCorr<-cor(log2LFQ,use="pairwise.complete.obs",method="pearson")
colnames(log2LFQimpCorr)<-paste0(sapply(strsplit(colnames(log2LFQ),"\\."), `[`, 2),gsub("\\.","",sapply(strsplit(colnames(log2LFQ),"_"), `[`, 1)))
rownames(log2LFQimpCorr)<-colnames(log2LFQimpCorr)
heatmap(log2LFQimpCorr)
if(require("pheatmap")){#https://stackoverflow.com/a/43051932
  grid::grid.draw(pheatmap::pheatmap(log2LFQimpCorr,clustering_distance_rows = "euclidean",clustering_distance_cols = "euclidean",fontsize_row=6,cluster_cols=T,cluster_rows=T,fontsize_col=6)$gtable)
  }
dim(log2LFQ)
log2LFQt<-na.omit(log2LFQ)
dim(log2LFQ)
summary(log2LFQ)
summary(intensityLFQ)
print(paste("Selected and log2 transformed columns",selection))
if(dim(log2LFQ)[2]>0){
  barplot(isNA,main=paste("Protein group #",paste(t(colSums(!is.na(intensityLFQ)))),paste(t(colSums(is.na(intensityLFQ))))))
  boxplot(intensity)
  par(mar=c(12,3,1,1))
  boxplot(intensityLFQ,las=2)
  par(mar=c(12,3,1,1))
  boxplot(log2LFQ,las=2)
  boxplot(2^log2LFQ)
  NAcols<-colSums(is.na(log2LFQ))
  NAcols<-c(NAcols, mean(NAcols),median(NAcols),sum(is.na(NAcols)),sd(NAcols)/mean(NAcols),sum(NAcols),"MissingValue(s)")
  print(paste("Summarised missing-values in log2 transformed columns",t(NAcols)))
  Means<-apply(log2LFQ,1, mean, na.rm = TRUE)
  Medians<-apply(log2LFQ,1, median, na.rm = TRUE)
  Stdevs<-apply(log2LFQ,1, sd, na.rm = TRUE)
  NAs<-rowSums(is.na(log2LFQ))
  CVs<-Stdevs/Means
  summary(log2LFQ)#[7]
  log2LFQ[is.na(log2LFQ)]=0
  Sums<-rowSums(log2LFQ)
  dim(log2LFQ)
  summary(log2LFQ)
  #rowsum(s)
  #extract-uniprot-id(s)
  Uniprot<-sapply(strsplit(row.names(log2LFQ),";"), `[`, 2)
  uniprot<-sapply(strsplit(Uniprot,"|",fixed=TRUE),`[`, 2)
  #write-csv
  outF=paste(inpF,selection,"log2","csv",sep = ".")
  write.csv(rbind(cbind(log2LFQ,Means,Medians,NAs,CVs,Sums,uniprot),NAcols),outF)
  print(paste("Log2 transform of",selection,"columns written to",outF))
  #plot raw intensity histogram
  #i=1
  for(i in 1:dim(intensity)[2]){hist(log2(intensity[,i]),main=paste("File:",colnames(intensity)[i]),xlab="log2 raw intensity")}
  #plot LFQ histogram
  for(i in 1:dim(log2LFQ)[2]){
    log2lfq <- hist(log2LFQ[,i],main=paste("File:",colnames(log2LFQ)[i]),sub=paste("Quantified Protein Group(s):",dim(log2LFQ)[1]-as.integer(NAcols[i]),"out of ",dim(log2LFQ)[1],",","Missing Value(s):",NAcols[i]),xlab=paste("log2",selection),breaks=max(log2LFQ)-min(log2LFQ),xlim=c(min(log2LFQ), max(log2LFQ)))
  }
  #pca
  plot(princomp(log2LFQ))
  biplot(prcomp(log2LFQ))
  heatmap(log2LFQ)
  hist(log2LFQ,main=paste("Mean:",mean(log2LFQ),"SD:",sd(log2LFQ)),breaks=round(max(log2LFQ)))
  #impute-plot
  scale=3
  set.seed(scale)
  log2LFQimp<-matrix(rnorm(dim(log2LFQ)[1]*dim(log2LFQ)[2],mean=mean(log2LFQ)-scale,sd=sd(log2LFQ)/(scale)), dim(log2LFQ)[1],dim(log2LFQ)[2])
  log2LFQimp[log2LFQimp<0]<-0
  hist(log2LFQimp,main=paste("Mean:",mean(log2LFQimp),"SD:",sd(log2LFQimp)),breaks=round(max(log2LFQ)))
  print(paste("Imputation constant:",mean(log2LFQimp),"sd:",sd(log2LFQimp)))
  hist(log2LFQ,breaks=round(max(log2LFQ)), col=rgb(0,1,0,0.5))
  hist(log2LFQimp,breaks=round(max(log2LFQ)),col=rgb(0,0,1,0.5), add=T)
  log2LFQ[log2LFQ==0]<-log2LFQimp[log2LFQ==0]
  outF<-paste(inpF,selection,"log2","Imputation",mean(log2LFQimp),"sd",sd(log2LFQimp),"csv",sep = ".")
  write.csv(rbind(cbind(log2LFQ,Means,Medians,NAs,CVs,Sums,uniprot),NAcols),outF)
  print(paste("Log2 transform of",selection,"columns written to",outF))
  summary(log2LFQ)
  hist(log2LFQ,breaks=round(max(log2LFQ)),col=rgb(1,0,0,0.5), add=T)
  plot(princomp(log2LFQ),main=paste("Imputed value:",mean(log2LFQimp),"sd:",sd(log2LFQimp)))
  biplot(prcomp(as.matrix(log2LFQ),scale=TRUE),cex=c(0.5, 0.4), xlab=NULL,arrow.len = 0)
  heatmap(log2LFQ, scale = "row")
  #plot with 0 containing proteinGroups removed
  if(dim(log2LFQt)[1]>0){
    log2LFQt<-t(log2LFQt)
    log2LFQtPCA<-prcomp(log2LFQt,scale=TRUE)
    log2LFQtPCAsumm<-summary(log2LFQtPCA)
    #plot(prcomp(log2LFQt))
    plot(log2LFQtPCA$x[,1], log2LFQtPCA$x[,2], pch = 16, col = factor(rownames(log2LFQt)),xlab = paste0("PC1 (", round(100*log2LFQtPCAsumm$importance[2,1],1), "%)"), ylab = paste0("PC2 (", round(100*log2LFQtPCAsumm$importance[2,2],1), "%)"),main=paste("PCA 1/2 with 0 containing proteinGroups removed"),sub=paste("Protein groups", dim(log2LFQt)[2],"across samples",dim(log2LFQt)[1]))
    op <- par(cex = 0.4)
    legend("bottomright", col = factor(rownames(log2LFQt)), legend = factor(rownames(log2LFQt)), pch = 16)
    log2LFQt<-t(log2LFQ)
    log2LFQtPCA<-prcomp(log2LFQt,scale=TRUE)
    log2LFQtPCAsumm<-summary(log2LFQtPCA)
    plot(prcomp(log2LFQt))
    plot(log2LFQtPCA$x[,1], log2LFQtPCA$x[,2], pch = 16, col = factor(rownames(log2LFQt)),xlab = paste0("PC1 (", round(100*log2LFQtPCAsumm$importance[2,1],1), "%)"), ylab = paste0("PC2 (", round(100*log2LFQtPCAsumm$importance[2,2],1), "%)"),main=paste("PCA 1/2 with 0 containing proteinGroups imputed"),sub=paste("Protein groups", dim(log2LFQt)[2],"across samples",dim(log2LFQt)[1]))
    op <- par(cex = 0.4)
    legend("bottomright", col = factor(rownames(log2LFQt)), legend = factor(rownames(log2LFQt)), pch = 16)
    heatmap(log2LFQt)
  }
  print(dim(log2LFQt))
  print(paste("Histogram, PCA, Heatmap of Log2 transform of",selection,"column(s) written to",outP))
}
#close####
dev.off()
summary(warnings())
