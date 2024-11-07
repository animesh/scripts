#Rscript proteinGroupsQC.r "L:/promec/TIMSTOF/LARS/2024/240404_Mathilde/combined/txt/proteinGroups.txt" "Intensity."
#setup####
args = commandArgs(trailingOnly=TRUE)
print(paste("supplied argument(s):", length(args)))
inpF <- args[1]
#inpF<-"L:/promec/TIMSTOF/LARS/2024/240404_Mathilde/combined/txt/proteinGroups.txt"
selection <- args[2]
#selection<-"Intensity."
print(args)
#data####
data<-read.table(inpF,header = T,sep = "\t",quote = "")
#https://www.nature.com/articles/s41597-024-03355-4#Sec8
jpeg(paste0(inpF,"Sequence.coverage.jpg"))
range(data$Sequence.coverage....)
#hist(data$Sequence.coverage....)
dataCovClip50<-scales::squish(data$Sequence.coverage....,c(0,50))
#hist(dataCovClip50,xlim=c(0,50),main="Sequence coverage",xlab="Sequence coverage",ylab="Frequency")
range(dataCovClip50)
dataCovClip50Bin6<-cut(dataCovClip50, breaks =6)
dataCovClip50Bin6T<-table(dataCovClip50Bin6)
levels(dataCovClip50Bin6)<-paste(c("0-10","10-20","20-30","30-40","40-50",">50"),rep("[",6),round(100*dataCovClip50Bin6T/sum(dataCovClip50Bin6T),2),rep("%",6),rep("]",6))
pie(table(dataCovClip50Bin6),main="Sequence coverage")
dev.off()
#intensity####
intdata<-data[,grep(selection,colnames(data))]
log2Int<-as.matrix(log2(intdata))
dim(log2Int)
log2Int[log2Int==-Inf]=NA
colnames(log2Int)<-gsub(selection,"",colnames(log2Int))
summary(log2Int)
#corHCint####
colnames(log2Int)
log2IntCorr<-log2Int
log2IntimpCorr<-cor(log2IntCorr,use="pairwise.complete.obs",method="pearson")
colnames(log2IntimpCorr)<-colnames(log2IntCorr)
rownames(log2IntimpCorr)<-colnames(log2IntCorr)
bk1 <- c(seq(-1,-0.01,by=0.01))
bk2 <- c(seq(0.01,1,by=0.01))
bk <- c(bk1,bk2)  #combine the break limits for purpose of graphing
palette <- c(colorRampPalette(colors = c("yellow", "orange"))(n = length(bk1)-1),"orange", "orange",c(colorRampPalette(colors = c("orange","red"))(n = length(bk2)-1)))
svgPHC<-pheatmap::pheatmap(log2IntimpCorr,color=palette,fontsize_row=6,fontsize_col=6,cluster_cols=T,cluster_rows=T)#,clustering_distance_rows= "euclidean",clustering_distance_cols="euclidean")
ggplot2::ggsave(paste0(inpF,selection,"log2IntimpCorr.heatmap.jpg"),plot=svgPHC,width=10,height=8)
print(paste0(inpF,selection,"log2IntimpCorr.heatmap.jpg"))
