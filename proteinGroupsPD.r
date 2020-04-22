#parse argument(s)
print("USAGE:Rscript proteinGroups.r <complete path to proteinGroups.txt file> <SILAC>")
print("default LFQ")
#Rscript proteinGroups.r /home/animeshs/promec/promec/Qexactive/LARS/2019/oktober/Kristine\ Sonja/combined/txt/proteinGroups.txt SILAC
args = commandArgs(trailingOnly=TRUE)
print(paste("supplied argument(s):", length(args)))
print(args[1])
print(args[2])
#read
if(length(args)==0){print(paste("No proteinGroups.txt file supplied"))} else if (length(args)>0){inpF<-args[1]}
print(paste("Using proteinGroups.txt file",inpF,"with dimension(s)"))
#read
#inpF<-file.path("L:/promec/Animesh/carona_war/20200219_KKL_SARS_CoV2_pool1_F_Proteins.txt")
data<-read.table(inpF,header=T,sep="\t")
dim(data)
#select raw ratios
#selection<-"Abundance.Ratio."
print(selection)
intensity<-as.matrix(data[,grep(selection,colnames(data))])
protNum<-1:ncol(intensity)
colnames(intensity)=paste(protNum,sub(selection,"",colnames(intensity)),sep="_")
intensity<-as.matrix(intensity[,-grep("Adj.",colnames(intensity))])
summary(intensity)
log2LFQ<-log2(intensity)
log2LFQ[log2LFQ==-Inf]=NA
log2LFQt<-na.omit(log2LFQ)
print(paste("Selected and log2 transformed columns",selection))
if(dim(log2LFQ)[2]>0){
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
  outP<-paste(inpF,selection,"pdf",sep = ".")
  pdf(outP)
  #i=1
  for(i in 1:dim(intensity)[2]){hist(log2(intensity[,i]),main=paste("File:",colnames(intensity)[i]),xlab="log2 raw intensity")}
  #plot LFQ histogram
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
  dev.off()
  print(paste("Histogram, PCA, Heatmap of Log2 transform of",selection,"column(s) written to",outP))
}