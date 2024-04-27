#Rscript combineTxtFilesToXlsx.r /mnt/promec-ns9036k/NORSTORE_OSL_DISK/NS9036K/promec/promec/TIMSTOF/LARS/2024/240207_Deo/combined/txt ^proteinGroups.txtLFQ.intensity.16 0.110.05BioRemGroupsG.txttTestBH.csv$ 0.1 0
#install.packages(c("writexl","eulerr"))
args = commandArgs(trailingOnly=TRUE)
print(paste("supplied argument(s):", length(args)))
print(args)
inpD <- args[1]
#inpD<-"/mnt/promec-ns9036k/NORSTORE_OSL_DISK/NS9036K/promec/promec/TIMSTOF/LARS/2024/240207_Deo/combined/txt/"
filePrefix <- args[2]
#filePrefix<-"^proteinGroups.txtLFQ.intensity.16"
fileSuffix <- args[3]
#fileSuffix<-"0.110.05BioRemGroupsG.txttTestBH.csv$"
selFDR <- args[4]
#selFDR<-0.1
selLog2 <- args[5]
#selLog2<-0
inpFL<-list.files(pattern=filePrefix,path=inpD,full.names=F,recursive=F)
inpFL<-inpFL[grepl(filePrefix,inpFL)]
inpFL<-inpFL[grepl(fileSuffix,inpFL)]
print(inpFL)
dfMZ1<-""
#sheets<-list()
outPDF<-paste0(inpD,filePrefix,fileSuffix,selFDR,selLog2,"combined.pdf")
outRep<-paste0(inpD,filePrefix,fileSuffix,selFDR,selLog2,"combined.xlsx")
outRepSel<-paste0(inpD,filePrefix,fileSuffix,selFDR,selLog2,"combined.select.xlsx")
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
inpFL<-gsub(fileSuffix,"",inpFL)
inpFL<-gsub(filePrefix,"",inpFL)
print(inpFL)
summary(MZ1)
#sheets <- list(data,data) #assume sheet1 and sheet2 are data frames
data<-data.frame(RowGeneUniProtScorePeps=dfMZ1)
#data<-merge(data,`210408_EL500_SAX_urt3.raw.intensityThreshold1000.errTolDecimalPlace3.MZ1R.csv`, by="MZ1",all=T)
#plot(data$MZ1,data$MZ1210408_EL500_SAX_urt3.raw.intensityThreshold1000.errTolDecimalPlace3.MZ1R.csv)
for (obj in inpFL) {
  print(obj)
  objData<-get(obj)
  colnames(objData)
  valFDR<-paste0("CorrectedPValueBH",obj)
  objDataSel<-objData[!is.na(objData[,valFDR]),]
  objDataSel<-objDataSel[objDataSel[,valFDR]<selFDR,]
  data<-merge(data,objDataSel,by="RowGeneUniProtScorePeps",all=T)
}
writexl::write_xlsx(data,outRep)
dataSel<-data[,grep("Log2MedianChange",colnames(data))]
sum(is.na(data[,"RowGeneUniProtScorePeps"]))
rownames(dataSel)<-data[,"RowGeneUniProtScorePeps"]
dataSel<-dataSel[rowSums(abs(dataSel),na.rm=T)>selLog2,]
writexl::write_xlsx(cbind(rownames(dataSel),dataSel),outRepSel)
#names(sheets)<-inpFL[1]
#names(sheets)<-inpFL
#write_xlsx(sheets, paste(inpD,paste0(filePrefix,fileSuffix,".combined.xlsx"),sep="\\"))
#length(sheets)
combinations<-list()
for(i in colnames(dataSel)){
  print(i)
  print(summary(dataSel[,i]>selLog2))
  proteinL=rownames(dataSel[!is.na(dataSel[,i])&dataSel[,i]>selLog2,]==TRUE)
  proteinL=list(t(data.frame(proteinL)))
  names(proteinL)=paste0(gsub("Log2MedianChange|G25_","",i),"#",summary(proteinL)[1])
  combinations<-c(combinations,proteinL)
}
plot(eulerr::euler(combinations),quantities=TRUE,main=paste0("#Total with Log2MedianChange > ",selLog2))
combinations<-list()
for(i in colnames(dataSel)){
  print(i)
  print(summary(dataSel[,i]<selLog2))
  proteinL=rownames(dataSel[!is.na(dataSel[,i])&dataSel[,i]<selLog2,]==TRUE)
  proteinL=list(t(data.frame(proteinL)))
  names(proteinL)=paste0(gsub("Log2MedianChange|G25_","",i),"#",summary(proteinL)[1])
  combinations<-c(combinations,proteinL)
}
plot(eulerr::euler(combinations),quantities=TRUE,main=paste0("#Total with Log2MedianChange < ",selLog2))
print(outPDF)
print(outRep)
print(outRepSel)
