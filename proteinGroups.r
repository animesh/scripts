#F:\R-4.3.1\bin\Rscript.exe proteinGroups.r "F:\OneDrive - NTNU\Ale\proteinGroups mouse.txt"
print("USAGE:Rscript proteinGroups.r <complete path to proteinGroups.txt file> <LFQ or SILAC if performed else it defaults to raw Intensity columns>")
#supplying input file for testing
#inpF<-file.path("L:/promec/TIMSTOF/LARS/2023/230222 Katja/proteinGroups.txt")
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
print("Selecting Raw Intensity Values(s)")
#summary(data)
if(sum(grep(selection,colnames(data)))>0){
  #clean####
  nData<-nrow(data)
  if(sum(is.na(data[["Reverse"]]))<nData){data = data[!data[["Reverse"]]=="+",]}
  dim(data)
  nrow(data)/nData
  nDataR<-nrow(data)
  if(sum(is.na(data[["Potential.contaminant"]]))<nDataR){data = data[!data[["Potential.contaminant"]]=="+",]}
  dim(data)
  nrow(data)/nData
  nDataC<-nrow(data)
  if(sum(is.na(data[["Only.identified.by.site"]]))<nDataC){data = data[!data[["Only.identified.by.site"]]=="+",]}
  dim(data)
  nrow(data)/nData
  print("Removed Reverse,Potential.contaminant and Only.identified.by.site")
  intensity<-as.matrix(data[,grep(selection,colnames(data))]);protNum<-1:nrow(data);row.names(data)<-paste(protNum,data$Fasta.headers,protNum,sep=";")}  else if(sum(grep("Abundance.",colnames(data)))>0){selection<-"Abundance.";intensity<-as.matrix(data[,grep("Abundance.",colnames(data))]);data = data[data[["Master"]]=="IsMasterProtein",];protNum<-1:nrow(data);row.names(data)<-paste(protNum,data$FASTA.Title.Lines,protNum,sep=";")}  else{print('Neither Abundance[PD] nor Intensity[MQ] columns detected!')}
print("Converted Fasta.headers to rownames")
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
#select raw intensity
print("Selecting Raw Intensity Values(s) after filtering")
if(sum(grep(selection,colnames(data)))>0){intensity<-as.matrix(data[,grep(selection,colnames(data))])}  else if(sum(grep("Abundance.",colnames(data)))>0){selection<-"Abundance.";intensity<-as.matrix(data[,grep("Abundance.",colnames(data))])}  else{print('Neither Abundance[PD] nor Intensity[MQ] columns detected!')}
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
print("Converted Fasta headers to rownames intensity DF")
write.csv(intensityLFQ,paste(inpF,selection,"csv",sep = "."))
outP<-paste(inpF,selection,"pdf",sep = ".")
pdf(outP)
par(mar=c(12,3,1,1))
boxplot(intensityLFQ,las=2,main=selection)
#logBAQ####
selection="iBAQ."
if(sum(grep(selection,colnames(data)))>0){
  LFQ<-as.matrix(data[,grep(selection,colnames(data))])
  LFQ<- LFQ[,colnames(LFQ)!=paste0(selection,"peptides")]
  protNum<-1:ncol(LFQ);colnames(LFQ)=paste(protNum,sub(selection,"",colnames(LFQ)),protNum,sep="_");print(selection)
  log2LFQ<-log2(LFQ)
  log2LFQ[log2LFQ==-Inf]=NA
  write.csv(log2LFQ,paste(inpF,selection,"csv",sep = "."))
  boxplot(log2LFQ,las=2,main=selection)
  }
#logTop3####
selection="Top3."
if(sum(grep(selection,colnames(data)))>0){
  LFQ<-as.matrix(data[,grep(selection,colnames(data))])
  LFQ<- LFQ[,colnames(LFQ)!=paste0(selection,"peptides")]
  protNum<-1:ncol(LFQ);colnames(LFQ)=paste(protNum,sub(selection,"",colnames(LFQ)),protNum,sep="_");print(selection)
  log2LFQ<-log2(LFQ)
  log2LFQ[log2LFQ==-Inf]=NA
  write.csv(log2LFQ,paste(inpF,selection,"csv",sep = "."))
  boxplot(log2LFQ,las=2,main=selection)
}
#logMS2####
selection="MS.MS.count."
if(sum(grep(selection,colnames(data)))>0){
  LFQ<-as.matrix(data[,grep(selection,colnames(data))])
  LFQ<- LFQ[,colnames(LFQ)!=paste0(selection,"peptides")]
  protNum<-1:ncol(LFQ);colnames(LFQ)=paste(protNum,sub(selection,"",colnames(LFQ)),protNum,sep="_");print(selection)
  log2LFQ<-LFQ
  log2LFQ[log2LFQ==0]=NA
  write.csv(log2LFQ,paste(inpF,selection,"csv",sep = "."))
  boxplot(log2LFQ,las=2,main=selection)
}
#logLFQ####
if(sum(grep("LFQ",colnames(data)))>0){
  selection="LFQ.intensity";print(paste("No columns to select, using"));
  LFQ<-as.matrix(data[,grep(selection,colnames(data))])
  protNum<-1:ncol(LFQ);colnames(LFQ)=paste(protNum,sub(selection,"",colnames(LFQ)),protNum,sep="_");print(selection)} else if (sum(grep("Abundance.",colnames(data)))>0){
    selection1<-selection
    selection2="Normalized."
    #selection2="Scaled."
    LFQ<-as.matrix(intensity[,grep(selection2,colnames(intensity))])
    selection<-paste0(selection1,selection2)
    LFQ<-apply(LFQ,2, as.numeric)
    rownames(LFQ)<-rownames(data)
    colnames(LFQ)=sub(selection1,"",colnames(LFQ))
    colnames(LFQ)=sub(selection2,"",colnames(LFQ))
    protNum<-1:ncol(LFQ)
    colnames(LFQ)=paste(protNum,colnames(LFQ),protNum,sep="_")
    print(paste("Using proteinGroups.txt file column(s)",selection,"with dimension(s)"))
  } else if (sum(grep("Ratio",colnames(data)))>0){
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
LFQHordein<-LFQ[grep("Hordein",row.names(LFQ),ignore.case = TRUE),]
print("Proportion of Hordein(s)")
dim(LFQHordein)
if(!is.null(dim(LFQHordein))){colSums(LFQHordein)/colSums(LFQ,na.rm=T)*100}
LFQGlutelins<-LFQ[grep("Glutelin",row.names(LFQ),ignore.case = TRUE),]
print("Proportion of Glutelin(s)")
dim(LFQGlutelins)
if(!is.null(dim(LFQGlutelins))){colSums(LFQGlutelins)/colSums(LFQ,na.rm=T)*100}
LFQAlbumin<-LFQ[grep("Albumin",row.names(LFQ),ignore.case = TRUE),]
print("Proportion of Albumin(s)")
dim(LFQAlbumin)
if(!is.null(dim(LFQAlbumin))){colSums(LFQAlbumin)/colSums(LFQ,na.rm=T)*100}
LFQGlobulins<-LFQ[grep("Globulins",row.names(LFQ),ignore.case = TRUE),]
print("Proportion of Globulins(s)")
dim(LFQGlobulins)
if(!is.null(dim(LFQGlobulins))){colSums(LFQGlobulins)/colSums(LFQ,na.rm=T)*100}
LFQhistone<-LFQ[grep("histone",row.names(LFQ),ignore.case = TRUE),]
#summary(LFQhistone)
print("Proportion of histone(s)")
dim(LFQhistone)
if(!is.null(dim(LFQhistone))){colSums(LFQhistone)/colSums(LFQ,na.rm=T)*100}
LFQactin<-LFQ[grep("actin",row.names(LFQ),ignore.case = TRUE),]
#summary(LFQactin)
print("Proportion of actin(s)")
dim(LFQactin)
if(!is.null(dim(LFQactin))){colSums(LFQactin)/colSums(LFQ,na.rm=T)*100}
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
  boxplot(intensity,main="Intensity")
  par(mar=c(12,3,1,1))
  boxplot(intensityLFQ,las=2,main="log2Intensity")
  par(mar=c(12,3,1,1))
  boxplot(log2LFQ,las=2,main="log2LFQ")
  boxplot(2^log2LFQ,main="LFQ")
  log2LFQhigh<-log2LFQ
  log2LFQhigh[log2LFQhigh<5]=NA
  hist(log2LFQ,breaks=100,main="log2LFQ bin 100")
  hist(log2LFQhigh,breaks=100,main="log2LFQ>5 bin 100")
  boxplot(log2LFQhigh,las=2,main="log2LFQ>5")
  log2LFQhigh<-log2LFQ
  log2LFQhigh[log2LFQhigh<quantile(log2LFQhigh,na.rm=T,probs = 0.375)]=NA
  hist(log2LFQhigh,breaks=100,main="log2LFQ>probs=0.375 bin 100")
  boxplot(log2LFQhigh,las=2,main="log2LFQ>probs=0.375")
  NAcols<-colSums(is.na(log2LFQ))
  NAcols<-c(NAcols, mean(NAcols),median(NAcols),sum(is.na(NAcols)),sd(NAcols)/mean(NAcols),sum(NAcols),"MissingValue(s)")
  print(paste("Summarised missing-values in log2 transformed columns",t(NAcols)))
  Means<-apply(log2LFQ,1, mean, na.rm = TRUE)
  Medians<-apply(log2LFQ,1, median, na.rm = TRUE)
  Stdevs<-apply(log2LFQ,1, sd, na.rm = TRUE)
  NAs<-rowSums(is.na(log2LFQ))
  CVs<-Stdevs/Means
  summary(log2LFQ)#[7]
  Sums<-rowSums(log2LFQ,na.rm=T)
  dim(log2LFQ)
  summary(log2LFQ)
  #rowsum(s)
  #extract-uniprot-id(s)
  Uniprot<-sapply(strsplit(row.names(log2LFQ),";"), `[`, 2)
  uniprot<-sapply(strsplit(Uniprot,"|",fixed=TRUE),`[`, 2)
  uniprot<-sapply(strsplit(uniprot," ",fixed=TRUE),`[`, 1)
  #write-csv
  outF=paste(inpF,selection,"log2","csv",sep = ".")
  #write.csv(rbind(cbind(log2LFQ,Means,Medians,NAs,CVs,Sums,uniprot),NAcols),outF,row.names = FALSE, quote=FALSE)
  write.csv(cbind(fastaHdr=gsub("[^[:alnum:]]",";;",row.names(log2LFQ)),log2LFQ,Means,Medians,NAs,CVs,Sums,uniprot),outF,row.names = FALSE, quote=FALSE)
  print(paste("Log2 transform of",selection,"columns written to",outF))
  #plot raw intensity histogram
  #i=1
  #for(i in 1:dim(intensity)[2]){hist(log2(intensity[,i]),main=paste("File:",colnames(intensity)[i]),xlab="log2 raw intensity")}
  #plot LFQ histogram
  log2LFQ[is.na(log2LFQ)]=0
  for(i in 1:dim(log2LFQ)[2]){
    #i<-1
    log2lfq <- hist(log2LFQ[,i],main=paste("Quantified Protein Group(s):",dim(log2LFQ)[1]-as.integer(NAcols[i]),"out of ",dim(log2LFQ)[1],",","Missing Value(s):",NAcols[i]),sub=paste("File:",colnames(log2LFQ)[i]),xlab=paste("log2",selection),breaks=max(log2LFQ,na.rm=T)-min(log2LFQ,na.rm=T),xlim=c(min(log2LFQ,na.rm=T), max(log2LFQ,na.rm=T)))
  }
  #pca
  plot(princomp(log2LFQ))
  biplot(prcomp(log2LFQ))
  heatmap(log2LFQ)
  hist(log2LFQ,main=paste("Mean:",mean(log2LFQ,na.rm=T),"SD:",sd(log2LFQ,na.rm=T)),breaks=round(max(log2LFQ,na.rm=T)))
  #impute-plot
  scale=3
  set.seed(scale)
  log2LFQimp<-matrix(rnorm(dim(log2LFQ)[1]*dim(log2LFQ)[2],mean=mean(log2LFQ,na.rm=T)-scale,sd=sd(log2LFQ,na.rm=T)/(scale)), dim(log2LFQ)[1],dim(log2LFQ)[2])
  log2LFQimp[log2LFQimp<0]<-0
  hist(log2LFQimp,main=paste("Mean:",mean(log2LFQimp,na.rm=T),"SD:",sd(log2LFQimp,na.rm=T)),breaks=round(max(log2LFQ,na.rm=T)))
  print(paste("Imputation constant:",mean(log2LFQimp,na.rm=T),"sd:",sd(log2LFQimp,na.rm=T)))
  hist(log2LFQ,breaks=round(max(log2LFQ,na.rm=T)), col=rgb(0,1,0,0.5))
  hist(log2LFQimp,breaks=round(max(log2LFQ,na.rm=T)),col=rgb(0,0,1,0.5), add=T)
  log2LFQ[log2LFQ==0]<-log2LFQimp[log2LFQ==0]
  outF<-paste(inpF,selection,"log2","Imputation",mean(log2LFQimp,na.rm=T),"sd",sd(log2LFQimp,na.rm=T),"csv",sep = ".")
  write.csv(rbind(cbind(log2LFQ,Means,Medians,NAs,CVs,Sums,uniprot),NAcols),outF)
  print(paste("Log2 transform of",selection,"columns written to",outF))
  summary(log2LFQ)
  hist(log2LFQ,breaks=round(max(log2LFQ,na.rm=T)),col=rgb(1,0,0,0.5), add=T)
  plot(princomp(log2LFQ),main=paste("Imputed value:",mean(log2LFQimp,na.rm=T),"sd:",sd(log2LFQimp,na.rm=T)))
  biplot(prcomp(as.matrix(log2LFQ),scale=TRUE),cex=c(0.5, 0.4), xlab=NULL,arrow.len = 0)
  heatmap(log2LFQ, scale = "row")
  #plot with 0 containing proteinGroups removed
  if(dim(log2LFQt)[1]>0){
    log2LFQt<-t(log2LFQt)
    log2LFQtPCA<-prcomp(log2LFQt,scale=TRUE)
    log2LFQtPCAsumm<-summary(log2LFQtPCA)
    #plot(prcomp(log2LFQt))
    plot(log2LFQtPCA$x[,1], log2LFQtPCA$x[,2], pch = 16, col = factor(rownames(log2LFQt)),xlab = paste0("PC1 (", round(100*log2LFQtPCAsumm$importance[2,1],1), "%)"), ylab = paste0("PC2 (", round(100*log2LFQtPCAsumm$importance[2,2],1), "%)"),main=paste("PCA 1/2 with 0 containing proteinGroups removed","\nProtein groups", dim(log2LFQt)[2],"across samples",dim(log2LFQt)[1]))
    op <- par(cex = 0.4)
    legend("bottomright", col = factor(rownames(log2LFQt)), legend = factor(rownames(log2LFQt)), pch = 16)
    log2LFQt<-t(log2LFQ)
    log2LFQtPCA<-prcomp(log2LFQt,scale=TRUE)
    log2LFQtPCAsumm<-summary(log2LFQtPCA)
    plot(prcomp(log2LFQt))
    plot(log2LFQtPCA$x[,1], log2LFQtPCA$x[,2], pch = 16, col = factor(rownames(log2LFQt)),xlab = paste0("PC1 (", round(100*log2LFQtPCAsumm$importance[2,1],1), "%)"), ylab = paste0("PC2 (", round(100*log2LFQtPCAsumm$importance[2,2],1), "%)"),main=paste("PCA 1/2 with 0 containing proteinGroups imputed","\nProtein groups", dim(log2LFQt)[2],"across samples",dim(log2LFQt)[1]))
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
