#Rscript proteinGroupsQC.r "L:/promec/TIMSTOF/LARS/2023/230310 ChunMei/combined/txt/proteinGroups.txt" "L:/promec/Animesh/Mathilde/Groups.xlsx"
#setup####
#remotes::install_github('wolski/prolfquapp', dependencies = TRUE, force = FALSE)
#https://github.com/fgcz/prolfqua/issues/77
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
#label####
inputAnnotation <-"L:/promec/Animesh/Mathilde/Groups.xlsx"
labelD<-basename(inputAnnotation)
annotation <- readxl::read_xlsx(inputAnnotation)
head(annotation$raw.file)
startdata <- prolfqua::tidyMQ_ProteinGroups(inputMQfile)
head(startdata$raw.file)
outP=paste(inputMQfile,labelD,"prolfqua","pdf",sep = ".")
#pdf(outP)
startdata <- dplyr::inner_join(annotation, startdata, by = "raw.file")
#data[grep("A0A023T778",data$Protein.IDs),grep("Intensity",colnames(data))]
#A0A023T778<-data[grep("A0A023T778",data$Protein.IDs),]#76_slot2.24_1_3925 intensity 49608 LFQ 57589
#startdata <- dplyr::filter(startdata, nr.peptides > 1)
atable <- prolfqua::AnalysisTableAnnotation$new()
atable$fileName = "raw.file"
head(startdata$proteinID)
atable$hierarchy[["protein_Id"]] <- c("proteinID")
atable$factors[["mouse."]] = "sample"
atable$set_response("mq.protein.intensity")
config <- prolfqua::AnalysisConfiguration$new(atable)
adata <- prolfqua::setup_analysis(startdata, config)
lfqdata <- prolfqua::LFQData$new(adata, config)
lfqdata$remove_small_intensities()
dataLFQ<-lfqdata[["to_wide"]]()$data
head(dataLFQ)
dataLFQd<-data.frame(dataLFQ[,3:61])
dataLFQd<-log2(dataLFQd)
dataLFQd<-sapply(dataLFQd,as.numeric)
hist(dataLFQd)
