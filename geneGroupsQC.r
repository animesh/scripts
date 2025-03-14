#Rscript geneGroupsQC.r "L:/promec/TIMSTOF/LARS/2024/241219_Hela_DDA_DIA/dia/DIANN1p9p2/report.gg_matrix.tsv" "1" "2 3 4"
#Rscript geneGroupsQC.r "L:/promec/TIMSTOF/LARS/2024/241219_Hela_DDA_DIA/dia/DIANN1p9p2/report.gg_matrix.tsv" "1" "5 6 7"
#Rscript geneGroupsQC.r "L:/promec/TIMSTOF/LARS/2024/241219_Hela_DDA_DIA/dda/combined/txt/proteinGroups.txt" "2" "51 52 53"
#Rscript geneGroupsQC.r "L:/promec/TIMSTOF/LARS/2024/241219_Hela_DDA_DIA/dda/combined/txt/proteinGroups.txt" "2" "54 55 56"
#setup####
args = commandArgs(trailingOnly=TRUE)
print(paste("supplied argument(s):", length(args)))
inpF <- args[1]
#inpF<-"L:/promec/TIMSTOF/LARS/2024/241210_HELA_DDA_DIA/DIANN1p9p2/report.gg_matrix.tsv"
geneC <- args[2]
#geneC<-"1"
selection <- args[3]
#selection<-"2 3 4"
print(args)
#data####
data<-read.table(inpF,header = T,sep = "\t",quote = "")
print(summary(data))
#intensity####
intdata<-data[,as.numeric(unlist(strsplit(selection," ")))]
log2Int<-as.matrix(log2(intdata))
dim(log2Int)
log2Int[log2Int==-Inf]=NA
rownames(log2Int)<-data[,as.numeric(geneC)]
summary(log2Int)
#corHCint####
colnames(log2Int)
log2IntCorr<-log2Int
log2IntimpCorr<-cor(log2IntCorr,use="pairwise.complete.obs",method="pearson")
colnames(log2IntimpCorr)<-colnames(log2IntCorr)
rownames(log2IntimpCorr)<-colnames(log2IntCorr)
write.csv(log2IntimpCorr,paste0(inpF,geneC,selection,"log2IntimpCorr.csv"))
bk1 <- c(seq(-1,-0.01,by=0.01))
bk2 <- c(seq(0.01,1,by=0.01))
bk <- c(bk1,bk2)  #combine the break limits for purpose of graphing
palette <- c(colorRampPalette(colors = c("yellow", "orange"))(n = length(bk1)-1),"orange", "orange",c(colorRampPalette(colors = c("orange","red"))(n = length(bk2)-1)))
svgPHC<-pheatmap::pheatmap(log2IntimpCorr,color=palette,fontsize_row=6,fontsize_col=6,cluster_cols=T,cluster_rows=T)#,clustering_distance_rows= "euclidean",clustering_distance_cols="euclidean")
ggplot2::ggsave(paste0(inpF,geneC,selection,"log2IntimpCorr.heatmap.jpg"),plot=svgPHC,width=10,height=8)
print(paste0(inpF,geneC,selection,"log2IntimpCorr.heatmap.jpg"))
#CV####
intdata[intdata==0]=NA
cvInt<-(apply(intdata,1,function(x) sd(x,na.rm=T)/mean(x,na.rm=T)))*100
jpeg(paste0(inpF,geneC,selection,".CVhist.jpg"))
hist(cvInt,main = paste("Gene Group Intensity",inpF,sep="\n"),sub=paste(list(colnames(log2Int)),sep="\n"),font.sub=3,xlab = "%CV",ylab="Frequency",breaks=length(cvInt))
dev.off()
cvInt<-as.data.frame(cvInt)
rownames(cvInt)<-data[,as.numeric(geneC)]
write.csv(cvInt,paste0(inpF,geneC,selection,".CV.csv"))
print(paste0(inpF,geneC,selection,".CVhist.jpg"))
