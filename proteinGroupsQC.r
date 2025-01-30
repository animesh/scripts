#Rscript proteinGroupsQC.r "L:/promec/TIMSTOF/LARS/2024/240404_Mathilde/combined/txt/proteinGroups.txt" "240404_Mathilde_TN_PDAC_P1_Slot2-4_1_7011 240404_Mathilde_TN_PDAC_P2_Slot2-5_1_7013 240404_Mathilde_TN_PDAC_P4_Slot2-7_1_7017"
#setup####
args = commandArgs(trailingOnly=TRUE)
print(paste("supplied argument(s):", length(args)))
inpF <- args[1]
#inpF<-"L:/promec/TIMSTOF/LARS/2024/240404_Mathilde/combined/txt/proteinGroups.txt"
selection <- args[2]
#selection<-"240404_Mathilde_TN_PDAC_P1_Slot2-4_1_7011 240404_Mathilde_TN_PDAC_P2_Slot2-5_1_7013 240404_Mathilde_TN_PDAC_P4_Slot2-7_1_7017"
print(args)
#data####
data<-read.table(inpF,header = T,sep = "\t",quote = "")
dataCovClip50<-data[,match(gsub("-",".",gsub("240404_Mathilde_TN_PD","",paste0("Sequence.coverage.",strsplit(selection," ")[[1]],"...."))),colnames(data))]
data$Sequence.coverage....<-apply(dataCovClip50,1,function(x) max(x,na.rm=T))
#https://www.nature.com/articles/s41597-024-03355-4#Sec8
pdf(paste0(inpF,selection,"Sequence.coverage.pdf"),width=40,height=40)
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
intdata<-data[,match(gsub("-",".",gsub("240404_Mathilde_TN_PD","",paste0("Intensity.",strsplit(selection," ")[[1]]))),colnames(data))]
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
svgPHC<-pheatmap::pheatmap(log2IntimpCorr,color=palette,fontsize_row=20,fontsize_col=20,cluster_cols=T,cluster_rows=T)#,clustering_distance_rows= "euclidean",clustering_distance_cols="euclidean")
ggplot2::ggsave(paste0(inpF,selection,"log2IntimpCorr.heatmap.pdf"),plot=svgPHC, device="pdf",dpi=300, units = "in",width=40,height=40)
print(paste0(inpF,selection,"log2IntimpCorr.heatmap.pdf"))
#CV####
intdata[intdata==0]=NA
cvInt<-(apply(intdata,1,function(x) sd(x,na.rm=T)/mean(x,na.rm=T)))*100
pdf(paste0(inpF,selection,".CVhist.pdf"),width=40,height=40)
hist(cvInt,main = "Protein Group Intensity",xlab = "%CV",ylab="Frequency",breaks=length(cvInt))
dev.off()
print(paste0(inpF,selection,".CVhist.pdf"))
