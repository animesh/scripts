#Rscript proteinGroupsQC.r "L:/promec/TIMSTOF/LARS/2024/241210_HELA_DDA_DIA/combined/txtDDA/proteinGroups.txt" "evosep_dda_b_S1.A2_1_9243 evosep_dda_c_S1.A3_1_9244 evosep_dda_c_S1.A4_1_9245"
#setup####
args = commandArgs(trailingOnly=TRUE)
print(paste("supplied argument(s):", length(args)))
inpF <- args[1]
#inpF<-"L:/promec/TIMSTOF/LARS/2024/241210_HELA_DDA_DIA/combined/txtDDA/proteinGroups.txt"
selection <- args[2]
#selection<-"DDA_A_Slot1.54_1_9233 DDA_B_Slot1.54_1_9234 DDA_C_Slot1.54_1_9235"
print(args)
#data####
data<-read.table(inpF,header = T,sep = "\t",quote = "")
dataCovClip50<-data[,match(gsub("-",".",gsub("241210_","",paste0("Sequence.coverage.",strsplit(selection," ")[[1]],"...."))),colnames(data))]
data$Sequence.coverage....<-apply(dataCovClip50,1,function(x) max(x,na.rm=T))
#https://www.nature.com/articles/s41597-024-03355-4#Sec8
jpeg(paste0(inpF,selection,"Sequence.coverage.jpg"))
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
intdata<-data[,match(gsub("-",".",gsub("241210_","",paste0("Intensity.",strsplit(selection," ")[[1]]))),colnames(data))]
log2Int<-as.matrix(log2(intdata))
dim(log2Int)
log2Int[log2Int==-Inf]=NA
colnames(log2Int)<-gsub("Intensity.","",colnames(log2Int))
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
#CV####
intdata[intdata==0]=NA
cvInt<-(apply(intdata,1,function(x) sd(x,na.rm=T)/mean(x,na.rm=T)))*100
jpeg(paste0(inpF,selection,".CVhist.jpg"))
hist(cvInt,main = "Protein Group Intensity",xlab = "%CV",ylab="Frequency",breaks=length(cvInt))
dev.off()
print(paste0(inpF,selection,".CVhist.jpg"))
