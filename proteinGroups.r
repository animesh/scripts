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
#inpF<-file.path("L:/promec/Qexactive/LARS/2019/november/Kristian Starheim/combined/txt/proteinGroups.txt")
data<-read.table(inpF,header=T,sep="\t")
dim(data)
#select raw intensity
print("Selecting Raw Intensity Values(s)")
intensity<-as.matrix(data[,grep("Intensity.",colnames(data))])
colnames(intensity)=sub("Intensity.","",colnames(intensity))
#clean
data = data[!data$Reverse=="+",]
data = data[!data$Potential.contaminant=="+",]
data = data[!data$Only.identified.by.site=="+",]
print("Removed Reverse,Potential.contaminant and Only.identified.by.site")
dim(data)
row.names(data)<-data$Fasta.headers
print("Converted Fasta.headers to rownames")
#summary(data)
#select from arg[]
if(length(args)==1){
  selection="LFQ.intensity";print(paste("No columns to select, using",selection))
  LFQ<-as.matrix(data[,grep(selection,colnames(data))])
  colnames(LFQ)=sub(selection,"",colnames(LFQ))
} else if (args[2]=="SILAC"){
    selection1="Ratio."
    LFQ<-as.matrix(data[,grep(selection1,colnames(data))])
    selection2=".normalized."
    LFQ<-as.matrix(LFQ[,grep(selection2,colnames(LFQ))])
    selection<-paste(selection1,selection2)
    LFQ<-apply(LFQ,2, as.numeric)
    rownames(LFQ)<-rownames(data)
    colnames(LFQ)=sub(selection1,"",colnames(LFQ))
    colnames(LFQ)=sub(selection2,"",colnames(LFQ))
    print(paste("Using proteinGroups.txt file column(s)",selection,"with dimension(s)"))
}
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
log2LFQt<-na.omit(log2LFQ)
print(paste("Selected and log2 transformed columns",selection))
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
Uniprot<-sapply(strsplit(row.names(log2LFQ),";"), `[`, 1)
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
#impute-plot
scale=4
set.seed(scale)
imputeConst<-rnorm(1,mean=mean(log2LFQ)-scale,sd=sd(log2LFQ)/scale)
print(paste("Imputation constant:",imputeConst))
log2LFQ[log2LFQ==0]<-imputeConst
summary(log2LFQ)
plot(princomp(log2LFQ),main=paste("Imputed value:",imputeConst))
biplot(prcomp(as.matrix(log2LFQ),scale=TRUE),cex=c(0.5, 0.4), xlab=NULL,arrow.len = 0)
heatmap(log2LFQ, scale = "row")
#plot with 0 containing proteinGroups removed
log2LFQt<-t(log2LFQt)
log2LFQtPCA<-prcomp(log2LFQt,scale=TRUE)
log2LFQtPCAsumm<-summary(log2LFQtPCA)
#plot(prcomp(log2LFQt))
plot(log2LFQtPCA$x[,1], log2LFQtPCA$x[,2], pch = 16, col = factor(rownames(log2LFQt)),xlab = paste0("PC1 (", round(100*log2LFQtPCAsumm$importance[2,1],1), "%)"), ylab = paste0("PC2 (", round(100*log2LFQtPCAsumm$importance[2,2],1), "%)"),main=paste("PCA 1/2 with 0 containing proteinGroups removed","\nProtein groups", dim(log2LFQt)[2],"across samples",dim(log2LFQt)[1]))
op <- par(cex = 0.4)
legend("bottomright", col = factor(rownames(log2LFQt)), legend = factor(rownames(log2LFQt)), pch = 16)
heatmap(log2LFQt)
dev.off()
print(paste("Histogram, PCA, Heatmap of Log2 transform of",selection,"column(s) written to",outP))

