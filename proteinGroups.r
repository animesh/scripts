print("USAGE:Rscript proteinGroups.r <complete path to proteinGroups.txt file>")
args = commandArgs(trailingOnly=TRUE)
#read
if(length(args)==0){inpF<-file.path("L:/promec/Qexactive/LARS/2019/oktober/HEIDI_NANO/101929 Eksperiment 2/txt/proteinGroups.txt");print(paste("No proteinGroups.txt file supplied, using",inpF))} else if (length(args)==1){inpF<-args[1];print(paste("Using proteinGroups.txt file",inpF,"with dimension(s)"))}
data<-read.table(inpF,header=T,sep="\t")
dim(data)
#clean
data = data[!data$Reverse=="+",]
data = data[!data$Potential.contaminant=="+",]
data = data[!data$Only.identified.by.site=="+",]
print("Removed Reverse,Potential.contaminant and Only.identified.by.site")
dim(data)
row.names(data)<-data$Fasta.headers
print("Converted Fasta.headers to rownames")
#summary(data)
#select
selection="LFQ.intensity"
LFQ<-as.matrix(data[,grep(selection,colnames(data))])
summary(LFQ)
#select certain marker proteins and calculate their intensitt proportion
LFQglyceraldehyde<-LFQ[grep("glyceraldehyde",row.names(LFQ),ignore.case = TRUE),]
#summary(LFQglyceraldehyde)
print("Proportion of glyceraldehyde(s)")
dim(LFQglyceraldehyde)
if(!is.null(dim(LFQglyceraldehyde))){colSums(LFQglyceraldehyde)/colSums(LFQ)*100}
LFQactin<-LFQ[grep("actin",row.names(LFQ),ignore.case = TRUE),]
#summary(LFQactin)
print("Proportion of actin(s)")
dim(LFQactin)
if(!is.null(dim(LFQactin))){colSums(LFQactin)/colSums(LFQ)*100}
log2LFQ<-log2(LFQ)
log2LFQ[log2LFQ==-Inf]=NA
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
colnames(log2LFQ)=sub(selection,"",colnames(log2LFQ))
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
#plot
outP<-paste(inpF,selection,"pdf",sep = ".")
pdf(outP)
i=1
for(i in 1:dim(log2LFQ)[2]){
  log2lfq <- hist(log2LFQ[,i],xlab=paste("File:",colnames(log2LFQ)[i],"Missing Values:",NAcols[i]),breaks=max(log2LFQ))
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
dev.off()
print(paste("Histogram, PCA, Heatmap of Log2 transform of",selection,"column(s) written to",outP))

