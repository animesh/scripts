#setup####
#install.packages("ggplot2")
#install.packages("svglite")
#install.packages("limma")
#install.packages("pheatmap")
#R\bin\Rscript.exe C:\Users\animeshs\OneDrive\Desktop\Scripts\diffExprPlots.r L:\promec\USERS\Alessandro\230119_66samples-redo\combined\txt\
args = commandArgs(trailingOnly=TRUE)
print(args)
if (length(args) != 1) {stop("\n\nNeeds the full path of the directory containing BOTH proteinGroups.txt from MaxQuant & Groups.txt files followed by the name of GROUP column in Groups.txt file whch will be used for the t-test, for example
\"c:/Users/animeshs/R/bin/Rscript.exe diffExprPlots.r L:/promec/USERS/Alessandro/230119_66samples-redo/combined/txt/\"
                             ", call.=FALSE)}
inpD <- args[1]
#inpD <-"L:/promec/USERS/Alessandro/230119_66samples-redo/combined/txt/"
lGroup<-"Sample"
inpF<-paste0(inpD,"proteinGroups.txt")
inpL<-paste0(inpD,"Groups.txt")
inpS<-paste0(inpD,"Genes.txt")

selection<-"LFQ.intensity."
#data####
data <- read.table(inpF,stringsAsFactors = FALSE, header = TRUE, quote = "", comment.char = "", sep = "\t")
##clean####
#data = data[!data$Reverse=="+",]
#data = data[!data$Potential.contaminant=="+",]
#data = data[!data$Only.identified.by.site=="+",]
row.names(data)<-paste(row.names(data),data$Fasta.headers,data$Protein.IDs,data$Protein.names,data$Gene.names,data$Score,data$Peptide.counts..unique.,sep=";;")
summary(data)
dim(data)
hist(as.matrix(log2(data[,grep("Intensity",colnames(data))])))
summary(log2(data[,grep("Intensity",colnames(data))]))
LFQ<-as.matrix(data[,grep(selection,colnames(data))])
#protNum<-1:ncol(LFQ)
#protNum<-"LFQ intensity"#1:ncol(LFQ)
#colnames(LFQ)=paste(protNum,sub(selection,"",colnames(LFQ)),sep=";")
colnames(LFQ)=sub(selection,"",colnames(LFQ))
dim(LFQ)
log2LFQ<-log2(LFQ)
log2LFQ[log2LFQ==-Inf]=NA
log2LFQ[log2LFQ==0]=NA
summary(log2LFQ)
hist(log2LFQ)
rowName<-paste(sapply(strsplit(paste(sapply(strsplit(data$Fasta.headers, "|",fixed=T), "[", 2)), "-"), "[", 1))
data$geneName<-paste(sapply(strsplit(paste(sapply(strsplit(data$Gene.names, ";",fixed=T), "[", 1)), " "), "[", 1))
data$uniprotID<-paste(sapply(strsplit(paste(sapply(strsplit(data$Protein.IDs, ";",fixed=T), "[", 1)), " "), "[", 1))
data[data$geneName=="NA","geneName"]=data[data$geneName=="NA","uniprotID"]
#label####
label<-read.table(inpL,header=T,sep="\t",row.names=1)#, colClasses=c(rep("factor",3)))
rownames(label)=sub(selection,"",rownames(label))
label["pair2test"]<-label[lGroup]
#label["pair2test"]<-label["Bio"]
print(label)
#corHC####
scale=3
log2LFQimp<-matrix(rnorm(dim(log2LFQ)[1]*dim(log2LFQ)[2],mean=mean(log2LFQ,na.rm = T)-scale,sd=sd(log2LFQ,na.rm = T)/(scale)), dim(log2LFQ)[1],dim(log2LFQ)[2])
log2LFQimp[log2LFQimp<0]<-0
bk1 <- c(seq(-1,-0.01,by=0.01))
bk2 <- c(seq(0.01,1,by=0.01))
bk <- c(bk1,bk2)  #combine the break limits for purpose of graphing
my_palette <- c(colorRampPalette(colors = c("darkblue", "white"))(n = length(bk1)-1),"gray", "gray",c(colorRampPalette(colors = c("white","darkred"))(n = length(bk2)-1)))
colnames(log2LFQimp)<-colnames(log2LFQ)
log2LFQimpCorr<-cor(log2LFQ,use="pairwise.complete.obs",method="spearman")
colnames(log2LFQimpCorr)<-colnames(log2LFQ)
rownames(log2LFQimpCorr)<-colnames(log2LFQ)
svgPHC<-pheatmap::pheatmap(log2LFQimpCorr,clustering_distance_rows = "euclidean",clustering_distance_cols = "euclidean",fontsize_row=8,cluster_cols=T,cluster_rows=T,fontsize_col  = 8)
ggplot2::ggsave(paste0(inpF,selection,"HeatMap.svg"), svgPHC)
#meanBio####
colnames(log2LFQ)
table(label$Bio)
meanLog2LFQ <- data.frame(matrix(ncol=length(names(table(label$Bio))),nrow=nrow(log2LFQ)))
colnames(meanLog2LFQ) <- names(table(label$Bio))
rownames(meanLog2LFQ)<-rownames(log2LFQ)
for(i in names(table(label$Bio))){
  print(i)
  log2LFQvals<-data.frame(log2LFQ[,gsub("-",".",rownames(label[label$Bio==i,]))])
  print(summary(log2LFQvals))
  meanLog2LFQ[i]<-apply(log2LFQvals,1, function(x) mean(x,na.rm=T))
  print(summary(meanLog2LFQ[i]))
}
write.csv(meanLog2LFQ,paste0(inpF,selection,basename(inpL),lGroup,"log2LFQ.csv"))
#genes####
genes<-read.table(inpS,header=T,sep="\t")#, colClasses=c(rep("factor",3)))
print(genes)
unique(genes$geneName)
#corGenesLFQ####
gData<-merge(genes,data,by="geneName",all=F)
gLFQ<-as.matrix(gData[,grep(selection,colnames(gData))])
colnames(gLFQ)=sub(selection,"",colnames(gLFQ))
dim(gLFQ)
log2gLFQ<-log2(gLFQ)
log2gLFQ[log2gLFQ==-Inf]=NA
log2gLFQ[log2gLFQ==0]=NA
summary(log2gLFQ)
hist(log2gLFQ)
range(log2gLFQ,na.rm=T)
colnames(log2gLFQ)
rownames(log2gLFQ)<-paste(gData$geneName,gData$uniprotID,sep=";")
write.csv(log2gLFQ,paste0(inpF,selection,basename(inpL),basename(inpS),"log2LFQ.csv"))
table(label)
meanLog2gLFQ <- data.frame(matrix(ncol=length(names(table(label$Bio))),nrow=nrow(log2gLFQ)))
colnames(meanLog2gLFQ) <- names(table(label$Bio))
rownames(meanLog2gLFQ)<-paste(gData$geneName,gData$uniprotID,sep=";")
for(i in names(table(label$Bio))){
  print(i)
  log2LFQvals<-data.frame(log2gLFQ[,gsub("-",".",rownames(label[label$Bio==i,]))])
  print(summary(log2LFQvals))
  meanLog2gLFQ[i]<-apply(log2LFQvals,1, function(x) mean(x,na.rm=T))
  print(summary(meanLog2gLFQ[i]))
}
summary(meanLog2gLFQ)
range(meanLog2gLFQ,na.rm=T)
write.csv(meanLog2gLFQ,paste0(inpF,selection,basename(inpL),basename(inpS),"log2LFQ.mean.csv"))
scale=12
set.seed(42)
log2gLFQimp<-matrix(rnorm(dim(meanLog2gLFQ)[1]*dim(meanLog2gLFQ)[2],mean=mean(as.matrix(meanLog2gLFQ),na.rm=T)-scale,sd=sd(as.matrix(meanLog2gLFQ),na.rm = T)/(scale)), dim(meanLog2gLFQ)[1],dim(meanLog2gLFQ)[2])
log2gLFQimp[log2gLFQimp<0]<-0
hist(log2gLFQimp)
range(log2gLFQimp)
meanLog2gLFQ[is.na(meanLog2gLFQ)]<-log2gLFQimp[is.na(meanLog2gLFQ)]
write.csv(meanLog2gLFQ,paste0(inpF,selection,basename(inpL),basename(inpS),"log2LFQ.mean.imp.csv"))
svgPHC<-pheatmap::pheatmap(meanLog2gLFQ,clustering_distance_rows = "euclidean",clustering_distance_cols = "euclidean",fontsize_row=4,cluster_cols=T,cluster_rows=T,fontsize_col  = 8)
ggplot2::ggsave(paste0(inpF,selection,basename(inpL),basename(inpS),"HeatMap.svg"), svgPHC)
#remControl####
rownames(label[label$pair2test=="Control",])
meanLog2gLFQnc<-meanLog2gLFQ[,-grep("C_",colnames(meanLog2gLFQ))]
svgPHC<-pheatmap::pheatmap(meanLog2gLFQnc,clustering_distance_rows = "euclidean",clustering_distance_cols = "euclidean",fontsize_row=4,cluster_cols=T,cluster_rows=T,fontsize_col  = 8)
ggplot2::ggsave(paste0(inpF,selection,basename(inpL),basename(inpS),"HeatMap.NC.svg"), svgPHC)

