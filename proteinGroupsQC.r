#Rscript proteinGroupsQC.r "L:/promec/TIMSTOF/LARS/2023/230414 mathilde/proteinGroups.txt" "230414_Mathilde_3_Slot2-48_1_4330"
#setup####
args = commandArgs(trailingOnly=TRUE)
print(paste("supplied argument(s):", length(args)))
inpF <- args[1]
#inpF<-"L:/promec/TIMSTOF/LARS/2023/230414 mathilde/proteinGroups.txt"
selection <- args[2]
#selection<-"230414_Mathilde_3_Slot2-48_1_4330"
print(args)
#data####
data<-read.table(inpF,header = T,sep = "\t",quote = "")
dataCovClip50<-data[,match(gsub("-",".",gsub("230414_Mathilde_","",paste0("Sequence.coverage.",strsplit(selection," ")[[1]],"...."))),colnames(data))]
data$Sequence.coverage....<-dataCovClip50
#https://www.nature.com/articles/s41597-024-03355-4#Sec8
jpeg(paste0(inpF,selection,"Sequence.coverage.jpg"),dpi=300)
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
intdata<-data[,match(gsub("-",".",gsub("230414_Mathilde_","",paste0("Intensity.",strsplit(selection," ")[[1]]))),colnames(data))]
log2Int<-as.matrix(log2(intdata))
dim(log2Int)
log2Int[log2Int==-Inf]=NA
colnames(log2Int)<-gsub("Intensity.","",colnames(log2Int))
summary(log2Int)
