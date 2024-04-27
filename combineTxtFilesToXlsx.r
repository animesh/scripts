#Rscript combineTxtFilesToXlsx.r /mnt/promec-ns9036k/NORSTORE_OSL_DISK/NS9036K/promec/promec/TIMSTOF/LARS/2024/240207_Deo/combined/txt proteinGroups.txtLFQ.intensity.16 0.110.05BioRemGroupsG.txttTestBH.csv
args = commandArgs(trailingOnly=TRUE)
print(paste("supplied argument(s):", length(args)))
print(args)
inpD <- args[1]
#inpD<-"/mnt/promec-ns9036k/NORSTORE_OSL_DISK/NS9036K/promec/promec/TIMSTOF/LARS/2024/240207_Deo/combined/txt/"
filePrefix <- args[2]
#filePrefix<-"proteinGroups.txtLFQ.intensity.16"
fileSuffix <- args[3]
#fileSuffix<-"0.110.05BioRemGroupsG.txttTestBH.csv"
inpFL<-list.files(pattern=filePrefix,path=inpD,full.names=F,recursive=F)
inpFL<-inpFL[grepl(fileSuffix,inpFL)]
print(inpFL)
dfMZ1<-0
#sheets<-list()
#library(writexl)
outPDF<-paste0(inpD,filePrefix,fileSuffix,"combined.pdf")
outRep<-paste0(inpD,filePrefix,fileSuffix,"combined.xlsx")
pdf(outPDF)
for(inpF in inpFL){
    #inpF<-inpFL[1]
    data<-read.csv(paste(inpD,inpF,sep="/"))
    inpF<-gsub(fileSuffix,"",inpF)
    inpF<-gsub(filePrefix,"",inpF)
    print(inpF)
    hist(as.numeric(data[,"Log2MedianChange"]),main=inpF,breaks=100)
    plot(as.numeric(data[,"Log2MedianChange"]),as.numeric(data[,"PValueMinusLog10"]),main=inpF)
    #sheets<-append(sheets,list(data))
    MZ1<-data$RowGeneUniProtScorePeps
    dfMZ1<-union(dfMZ1,MZ1)
    colnames(data)<-paste0(colnames(data),inpF)
    data$RowGeneUniProtScorePeps<-MZ1
    assign(inpF,data)
}
length(dfMZ1)
summary(warnings())
summary(MZ1)
#sheets <- list(data,data) #assume sheet1 and sheet2 are data frames
inpFL<-gsub(fileSuffix,"",inpFL)
inpFL<-gsub(filePrefix,"",inpFL)
print(inpFL)
#names(sheets)<-inpFL[1]
#names(sheets)<-inpFL
#write_xlsx(sheets, paste(inpD,paste0(filePrefix,fileSuffix,".combined.xlsx"),sep="\\"))
#length(sheets)
print(outPDF)
print(outRep)
