#Rscript combineTxtFilesToXlsx.r L:\promec\TIMSTOF\LARS\2024\240207_Deo\combined\txt\ proteinGroups.txtLFQ.intensity.16 0.110.05BioRemGroupsG.txttTestBH.csv MSH2 MLH1 PMS1 PMS2
#install.packages(c("gglot2","svgite"))
args = commandArgs(trailingOnly=TRUE)
print(paste("supplied argument(s):", length(args)))
print(args)
inpD <- args[1]
#inpD<-"L:/promec/TIMSTOF/LARS/2024/240207_Deo/combined/txt/"
filePrefix <- args[2]
#filePrefix<-"proteinGroups.txtLFQ.intensity.16"
filePrefixS <- paste0("^",filePrefix)
fileSuffix <- args[3]
#fileSuffix<-"0.110.05BioRemGroupsG.txttTestBH.csv"
fileSuffixS <- paste0(fileSuffix,"$")
listID <- args[4:length(args)]
#listID<-c("MSH2","MLH1","PMS1","PMS2")
inpFL<-list.files(pattern=filePrefix,path=inpD,full.names=F,recursive=F)
inpFL<-inpFL[grepl(filePrefixS,inpFL)]
inpFL<-inpFL[grepl(fileSuffixS,inpFL)]
print(inpFL)
dfMZ1<-NA
#sheets<-list()
outF<-paste0(inpD,filePrefix,fileSuffix,paste(unlist(listID),collapse=""),"combined")
outPDF<-paste0(outF,".pdf")
outRep<-paste0(outF,".xlsx")
outRepSel<-paste0(outF,".select.xlsx")
outRepCSV<-paste0(outF,".csv")
outRepSelCSV<-paste0(outF,".select.csv")
pdf(outPDF)
for(inpF in inpFL){
    #inpF<-inpFL[3]
    data<-read.csv(paste(inpD,inpF,sep="/"))
    inpF<-gsub(fileSuffix,"",inpF)
    inpF<-gsub(filePrefix,"",inpF)
    print(inpF)
    hist(as.numeric(data[,"Log2MedianChange"]),main=inpF,breaks=100)
    plot(as.numeric(data[,"Log2MedianChange"]),as.numeric(data[,"PValueMinusLog10"]),main=inpF)
    data[is.na(data$PValueMinusLog10),"PValueMinusLog10"]<-0
    selectID<-toupper(gsub(" ","",data$Gene)) %in% toupper(listID)
    summary(sum(selectID))
    p <- ggplot2::ggplot(data,ggplot2::aes(Log2MedianChange,PValueMinusLog10))+ ggplot2::geom_point(ggplot2::aes(color=selectID),size=1,alpha = 0.6) + ggplot2::scale_color_manual(values = c("grey", "black"))
    #dsub <- data[toupper(gsub(" ","",data$Gene)) %in% toupper(listID) ,]
    dsub <- subset(data,selectID)
    print(dim(dsub))
    p<-p + ggplot2::theme_bw(base_size=10) + ggplot2::geom_point(data=dsub,size=1.2,alpha=1) + ggplot2::geom_text(data=dsub,ggplot2::aes(label=Gene),hjust=1, vjust=0,size=1.5,alpha =0.9 ,position=ggplot2::position_jitter(width=0.1,height=0.1)) + ggplot2::scale_fill_gradient(low="grey", high="black") + ggplot2::xlab("Log2 Median Change") + ggplot2::ylab("-Log10 P-value")
    ggplot2::ggsave(paste0(inpD,inpF,paste(unlist(listID),collapse=""),"VolcanoTest.svg"), width=10,height=8,p)
    print(p)
    #sheets<-append(sheets,list(data))
    MZ1<-dsub$RowGeneUniProtScorePeps
    dfMZ1<-union(dfMZ1,MZ1)
    colnames(dsub)<-paste0(colnames(dsub),inpF)
    dsub$RowGeneUniProtScorePeps<-MZ1
    assign(inpF,dsub)
}
length(dfMZ1)
summary(warnings())
inpFL<-gsub(fileSuffix,"",inpFL)
inpFL<-gsub(filePrefix,"",inpFL)
print(inpFL)
summary(MZ1)
#sheets <- list(data,data) #assume sheet1 and sheet2 are data frames
data<-data.frame(RowGeneUniProtScorePeps=dfMZ1)
for (obj in inpFL) {
  print(obj)
  objData<-get(obj)
  colnames(objData)
  selectID<-paste0("Gene",obj)
  objDataSel<-objData[toupper(gsub(" ","",objData[,selectID])) %in% toupper(listID),]
  data<-merge(data,objDataSel,by="RowGeneUniProtScorePeps",all=T)
}
print(sum(rowSums(is.na(data))==ncol(data)))
data=data[rowSums(is.na(data))!=ncol(data),]
writexl::write_xlsx(data,outRep)
write.csv(data,outRepCSV,row.names = F)
dataSel<-data[,grep("Log2MedianChange",colnames(data))]
print(sum(is.na(data[,"RowGeneUniProtScorePeps"])))
rownames(dataSel)<-data[,"RowGeneUniProtScorePeps"]
plot(dataSel)
writexl::write_xlsx(cbind(rownames(dataSel),dataSel),outRepSel)
write.csv(dataSel,outRepSelCSV,row.names=T)
#names(sheets)<-inpFL[1]
#names(sheets)<-inpFL
#write_xlsx(sheets, paste(inpD,paste0(filePrefix,fileSuffix,".combined.xlsx"),sep="\\"))
#length(sheets)
combinations<-list()
for(i in colnames(dataSel)){
  print(i)
  proteinL=rownames(dataSel)
  proteinL=list(t(data.frame(proteinL)))
  names(proteinL)=paste0(gsub("Log2MedianChange|G25_","",i),"#",summary(proteinL)[1])
  combinations<-c(combinations,proteinL)
}
dataSetCommon<-Reduce(intersect, combinations)
dataSetDiff<-Reduce(setdiff, combinations)
plot(eulerr::euler(combinations),quantities=TRUE,main=paste0("#Total with absolute-Log2MedianChange > "))
print(paste0(outF,".select/.xlsx,csv,pdf"))

