#Rscript proteinGroupsQC.r "L:/promec/TIMSTOF/LARS/2023/230310 ChunMei/combined/txt/proteinGroups.txt"
#setup####
args = commandArgs(trailingOnly=TRUE)
print(paste("supplied argument(s):", length(args)))
print(args)
inpF <- args[1]
#inpF<-"L:/promec/TIMSTOF/LARS/2023/230310 ChunMei/combined/txt/proteinGroups.txt"
data<-read.table(inpF,header = T,sep = "\t",quote = "")
#https://www.nature.com/articles/s41597-024-03355-4#Sec8
jpeg(paste0(inpF,"F1D.jpg"))
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
#hist(dataCovClip50,xlim=c(0,50),main="Sequence coverage",xlab="Sequence coverage",ylab="Frequency")
