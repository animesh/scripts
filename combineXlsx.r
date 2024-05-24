#Rscript combineXlsx.r L:\promec\Animesh\Mathilde\STNTCasControl
#Rscript combineXlsx.r L:\promec\Animesh\Mathilde\AMHCasControl
#install.packages(c("writexl"s))
args = commandArgs(trailingOnly=TRUE)
print(paste("supplied argument(s):", length(args)))
print(args)
inpD <- args[1]
#inpD<-"L:/promec/Animesh/Mathilde/STNTCasControl"
inpFL<-list.files(pattern=".xls*",path=inpD,full.names=F,recursive=F)
print(inpFL)
dfMZ1<-NA
#sheets<-list()
outF<-paste0(inpD,"combined")
outPDF<-paste0(outF,".pdf")
outRep<-paste0(outF,".xlsx")
outRepSel<-paste0(outF,".select.xlsx")
outRepCSV<-paste0(outF,".csv")
outRepSelCSV<-paste0(outF,".select.csv")
pdf(outPDF)
for(inpF in inpFL){
    #inpF<-inpFL[1]
    data<-readxl::read_xlsx(paste(inpD,inpF,sep="/"))
    print(inpF)
    print(summary(data))
    print(dim(data))
    hist(data$Log2MedianChange,main=inpF,breaks=100)
    plot(data$Log2MedianChange,data$PValueMinusLog10,main=inpF)
    #sheets<-append(sheets,list(data))
    MZ1<-data$RowGeneUniProtScorePeps
    dfMZ1<-union(dfMZ1,MZ1)
    colnames(data)<-paste0(colnames(data),inpF)
    data$RowGeneUniProtScorePeps<-MZ1
    assign(inpF,data)
}
length(dfMZ1)
summary(warnings())
print(inpFL)
summary(MZ1)
#sheets <- list(data,data) #assume sheet1 and sheet2 are data frames
data<-data.frame(RowGeneUniProtScorePeps=dfMZ1)
for (obj in inpFL) {
  #obj<-inpFL[1]
  print(obj)
  objData<-get(obj)
  colnames(objData)
  data<-merge(data,objData,by="RowGeneUniProtScorePeps",all=T)
}
print(sum(rowSums(is.na(data))==ncol(data)))
writexl::write_xlsx(data,outRep)
write.csv(data,outRepCSV,row.names = F)
