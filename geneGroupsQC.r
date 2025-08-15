#Rscript geneGroupsQC.r "L:/promec/TIMSTOF/LARS/2025/250805_Kamila/DIANNv2p2/report.gg_matrix.tsv" 1 4 4
#setup####
args = commandArgs(trailingOnly=TRUE)
print(paste("supplied argument(s):", length(args)))
inpF <- args[1]
#inpF<-"L:/promec/TIMSTOF/LARS/2025/250805_Kamila/DIANNv2p2/report.gg_matrix.tsv"
#inpD<- gsub("[^[:alnum:]]+", ".", dirname(inpF))
#inpD<- strsplit(dirname(inpF), "/", fixed = TRUE)[[1]][length(split_result[[1]])]
geneC <- args[2]
#geneC<-"1"
selection <- args[3]
#selection<-"4"
cName <- args[4]
#cName<-"4"
print(args)
#data####
data<-read.table(inpF,header = T,sep = "\t",quote = "")
print(summary(data))
#intensity####
intdata<-data[,as.numeric(unlist(strsplit(selection," "))):ncol(data)]
colnames(intdata)<-sapply(strsplit(colnames(intdata),"_",fixed=T), "[", as.integer(cName))
log2Int<-as.matrix(log2(intdata))
log2Int[log2Int==-Inf]=NA
rownames(log2Int)<-data[,as.numeric(geneC)]
summary(log2Int)
#corHCint####
colnames(log2Int)
log2IntCorr<-log2Int
log2IntimpCorr<-cor(log2IntCorr,use="pairwise.complete.obs",method="pearson")
colnames(log2IntimpCorr)<-colnames(log2IntCorr)
rownames(log2IntimpCorr)<-colnames(log2IntCorr)
write.csv(log2IntimpCorr,paste0(inpF,geneC,selection,cName,"log2IntimpCorr.csv"))
bk1 <- c(seq(-1,-0.01,by=0.01))
bk2 <- c(seq(0.01,1,by=0.01))
bk <- c(bk1,bk2)  #combine the break limits for purpose of graphing
palette <- c(colorRampPalette(colors = c("yellow", "orange"))(n = length(bk1)-1),"orange", "orange",c(colorRampPalette(colors = c("orange","red"))(n = length(bk2)-1)))
svgPHC<-pheatmap::pheatmap(log2IntimpCorr,color=palette,fontsize_row=6,fontsize_col=6,cluster_cols=T,cluster_rows=T)#,clustering_distance_rows= "euclidean",clustering_distance_cols="euclidean")
ggplot2::ggsave(paste0(inpF,geneC,selection,cName,"log2IntimpCorr.heatmap.jpg"),plot=svgPHC,width=10,height=8)
print(paste0(inpF,geneC,selection,cName,"log2IntimpCorr.heatmap.jpg"))
#CV####
intdata[intdata==0]=NA
cvInt<-(apply(intdata,1,function(x) sd(x,na.rm=T)/mean(x,na.rm=T)))*100
jpeg(paste0(inpF,geneC,selection,cName,".CVhist.jpg"))
hist(cvInt,main = paste("Gene Group Intensity",inpF,sep="\n"),sub=paste(list(colnames(log2Int)),sep="\n"),font.sub=3,xlab = "%CV",ylab="Frequency",breaks=length(cvInt))
dev.off()
cvInt<-as.data.frame(cvInt)
rownames(cvInt)<-data[,as.numeric(geneC)]
write.csv(cvInt,paste0(inpF,geneC,selection,cName,".CV.csv"))
print(paste0(inpF,geneC,selection,cName,".CVhist.jpg"))
#boxplot####
jpeg(paste0(inpF,geneC,selection,cName,".boxplot.jpg"))
par(mar=c(10,4,2,2))
boxplot(log2Int,main = paste("Gene Group Intensity",inpF,sep="\n"),sub=paste(list(colnames(log2Int)),sep="\n"),font.sub=3,xlab = "Samples",ylab="Log2 Intensity",las=2)
dev.off()
print(paste0(inpF,geneC,selection,cName,".boxplot.jpg"))
dim(log2Int)
print("Quantified protein-groups(s)")
data.frame(colSums(!is.na(log2Int)))
