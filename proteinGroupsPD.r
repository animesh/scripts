#example:"c:\Program Files\Microsoft\R Open\R-4.0.2\bin\Rscript.exe" proteinGroupsPD.r  "F:\promec\Animesh\Kathleen\PCA\Exosome_Shotgun_190118_KATHLENN_HCT_R5.xlsx"
Sys.setenv(TZ="GMT")
print("USAGE:Rscript proteinGroupsPD.r <complete path to proteinGroups.txt file>")
print("default values: Abundances.Scaled.")
#parse argument(s)
args = commandArgs(trailingOnly=TRUE)
print(paste("supplied argument(s):", length(args)))
print(args[1])
#read
fName<-"Exosome_Shotgun_190118_KATHLENN_HCT_R5.xlsx"
inpD <-"L:/promec/Animesh/Kathleen/PCA/"
inpF<-paste0(inpD,fName)
selection<-"Scaled"
if(length(args)==0){print(paste("No proteinGroups.xlsx file supplied"))} else if (length(args)>0){inpF<-args[1];selection<-args[2]}
print(paste("Using proteinGroupsPD.xlsx file",inpF,"with dimension(s)"))
options(nwarnings = 1000000)
data <- readxl::read_xlsx(inpF)
data<-data[!is.na(data$`Protein FDR Confidence: Combined`),]
dim(data)
print("Removed NA(s)")
data = as.data.frame(data[!data$Contaminant=="TRUE",])
dim(data)
print("Removed Potential.contaminant(s)")
protNum<-1:nrow(data)
row.names(data)<-paste(protNum,data$Accession,protNum,sep=";")
print("Converted Accession to rownames")
#select
LFQ<-(data[,grep(selection,colnames(data))])
LFQ<-sapply(LFQ, as.numeric)
summary(LFQ)
colnames(LFQ)=sub(selection,"",colnames(LFQ))
colnames(LFQ)=sub("Abundances","",colnames(LFQ))
colnames(LFQ)=sub("Sample","",colnames(LFQ))
colnames(LFQ)=sub(":","",colnames(LFQ))
colnames(LFQ)=sub("\\(","",colnames(LFQ))
colnames(LFQ)=sub("\\)","",colnames(LFQ))
colnames(LFQ)=sub(","," ",colnames(LFQ))
dim(LFQ)
LFQhistone<-LFQ[grep("histone",data$Description,ignore.case = TRUE),]
#summary(LFQhistone)
print("Proportion of histone(s)")
dim(LFQhistone)
if(!is.null(dim(LFQhistone))){colSums(LFQhistone,na.rm = T)/colSums(LFQ,na.rm = T)*100}
log2LFQ<-log2(LFQ)
log2LFQ[log2LFQ==-Inf]=NA
dim(log2LFQ)
log2LFQt<-na.omit(log2LFQ)
dim(log2LFQ)
summary(log2LFQ)
print(paste("Selected and log2 transformed columns",selection))
if(dim(log2LFQ)[2]>0){
  outP<-paste(inpF,selection,"pdf",sep = ".")
  pdf(outP)
  boxplot(log2LFQ)
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
  Uniprot<-sapply(strsplit(row.names(data),";"), `[`, 2)
  uniprot<-sapply(strsplit(Uniprot,"-",fixed=TRUE),`[`, 1)
  #write-csv
  outF=paste(inpF,selection,"log2","csv",sep = ".")
  write.csv(rbind(cbind(log2LFQ,Means,Medians,NAs,CVs,Sums,uniprot),NAcols),outF,row.names = F)
  print(paste("Log2 transform of",selection,"columns written to",outF))
  #plot raw intensity histogram
  #i=1
  for(i in 1:dim(log2LFQ)[2]){
    log2lfq <- hist(log2LFQ[,i],main=paste("File:",colnames(log2LFQ)[i],"\n","Quantified Protein Group(s):",dim(log2LFQ)[1]-as.integer(NAcols[i]),"out of ",dim(log2LFQ)[1],",","Missing Value(s):",NAcols[i]),xlab=paste("log2",selection),breaks=max(log2LFQ)-min(log2LFQ),xlim=c(min(log2LFQ), max(log2LFQ)))
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
  write.csv(rbind(cbind(log2LFQ,Means,Medians,NAs,CVs,Sums,uniprot),NAcols),outF,row.names = F)
  print(paste("Log2 transform of",selection,"columns written to",outF))
  summary(log2LFQ)
  hist(log2LFQ,breaks=round(max(log2LFQ)),col=rgb(1,0,0,0.5), add=T)
  plot(princomp(log2LFQ),main=paste("Imputed value:",mean(log2LFQimp),"sd:",sd(log2LFQimp)))
  biplot(prcomp(as.matrix(log2LFQ),scale=TRUE),cex=c(1, 1), xlab=NULL,arrow.len = 0)
  #plot with 0 containing proteinGroups removed
  if(dim(log2LFQt)[1]>0){
    log2LFQt<-t(log2LFQt)
    log2LFQtPCA<-prcomp(log2LFQt,scale=TRUE)
    log2LFQtPCAsumm<-summary(log2LFQtPCA)
    #plot(prcomp(log2LFQt))
    plot(log2LFQtPCA$x[,1], log2LFQtPCA$x[,2], pch = 16, col = factor(rownames(log2LFQt)),xlab = paste0("PC1 (", round(100*log2LFQtPCAsumm$importance[2,1],1), "%)"), ylab = paste0("PC2 (", round(100*log2LFQtPCAsumm$importance[2,2],1), "%)"),main=paste("PCA 1/2 with 0 containing proteinGroups removed","\nProtein groups", dim(log2LFQt)[2],"across samples",dim(log2LFQt)[1]))
    op <- par(cex = 1)
    legend("bottomright", col = factor(rownames(log2LFQt)), legend = factor(rownames(log2LFQt)), pch = 16)
    log2LFQt<-t(log2LFQ)
    log2LFQtPCA<-prcomp(log2LFQt,scale=TRUE)
    log2LFQtPCAsumm<-summary(log2LFQtPCA)
    plot(prcomp(log2LFQt))
    plot(log2LFQtPCA$x[,1], log2LFQtPCA$x[,2], pch = 16, col = factor(rownames(log2LFQt)),xlab = paste0("PC1 (", round(100*log2LFQtPCAsumm$importance[2,1],1), "%)"), ylab = paste0("PC2 (", round(100*log2LFQtPCAsumm$importance[2,2],1), "%)"),main=paste("PCA 1/2 with 0 containing proteinGroups imputed","\nProtein groups", dim(log2LFQt)[2],"across samples",dim(log2LFQt)[1]))
    op <- par(cex = 1)
    legend("bottomright", col = factor(rownames(log2LFQt)), legend = factor(rownames(log2LFQt)), pch = 16)
  }
  print(dim(log2LFQt))
  dev.off()
  print(paste("Histogram and PCA for Log2 transform of",selection,"column(s) written to",outP))
}
summary(warnings())
