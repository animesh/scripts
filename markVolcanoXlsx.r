#..\R-4.4.0\bin\Rscript.exe markVolcanoXlsx.r L:\promec\TIMSTOF\LARS\2024\240207_Deo\combined\txt\ proteinGroups.txtLFQ.intensity.16 0.110.05BioRemGroupsG.txttTestBH.csv MLH1 PMS1 PMS2
#Overall plot be smaller
#Bigger fonts
#Only top-30 interactors should be named of which, every graph should have the protein itself in bigger font
#For CDK12 plot, MLH1, PMS1, PMS2 should be in bold
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
#listID<-c("MLH1","PMS1","PMS2")
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
    data<-data[order(data$PValueMinusLog10,decreasing=T),]
    dataTop30<-data[data$PValueMinusLog10!=5&data$Log2MedianChange>0,]
    dataTop30<-dataTop30[1:30,]
    selectID<-data$RowGeneUniProtScorePeps %in% dataTop30$RowGeneUniProtScorePeps | toupper(gsub(" ","",data$Gene)) %in% toupper(listID)
    summary(sum(selectID))
    p <- ggplot2::ggplot(data,ggplot2::aes(Log2MedianChange,PValueMinusLog10))+ ggplot2::geom_point(ggplot2::aes(color=selectID),size=0.1,alpha = 0.8) + ggplot2::scale_color_manual(values = c("grey", "black"))
    dsub <- subset(data,selectID)
    print(dim(dsub))
    p<-p + ggplot2::theme_bw() + ggplot2::geom_text(fontface = "bold",data=dsub,ggplot2::aes(label=Gene),hjust=0, vjust=0.5,nudge_x = 0.1,nudge_y = 0,size=1.5,alpha =1) + ggplot2::scale_fill_gradient(low="grey", high="black") + ggplot2::xlab("Log2 Median Change") + ggplot2::ylab("-Log10 P-value")
    ggplot2::ggsave(paste0(inpD,inpF,"top30select",length(listID), "VolcanoTest.svg"), width=8,height=6,p)
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
print(paste0(outF,".select/.xlsx,csv,pdf"))

