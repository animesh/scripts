# ..\R-4.4.0\bin\Rscript.exe combineXlsx.r "L:\promec\TIMSTOF\LARS\2025\250428_Kamilla\new lysis\intensityreport.oxM.acetN.report.unique_genes_matrix.tsv_comb.sum.xlsx" "L:\promec\TIMSTOF\LARS\2025\250428_Kamilla\intensityreport.met.acet.report.unique_genes_matrix.tsv_comb.sum.xlsx"  
args = commandArgs(trailingOnly=TRUE)
print(paste("supplied argument(s):", length(args)))
#args<-c("L:/promec/TIMSTOF/LARS/2025/250428_Kamilla/new lysis/intensityreport.oxM.acetN.report.unique_genes_matrix.tsv_comb.sum.xlsx","L:/promec/TIMSTOF/LARS/2025/250428_Kamilla/intensityreport.met.acet.report.unique_genes_matrix.tsv_comb.sum.xlsx")
print(args)
inpFs<-basename(args)
inpFs<-strsplit(inpFs,"\\.")
inpFs<-unique(unlist(inpFs))
inpFs<-paste(unlist(inpFs),collapse=".")
#sheets<-list()
outF<-paste(dirname(args[1]),inpFs,sep = "/")
outPDF<-paste0(outF,"combo.pdf")
outRep<-paste0(outF,"combo.xlsx")
outRepCSV<-paste0(outF,"combo.csv")
pdf(outPDF)
dfMZ1<-NA
for(inpF in args){
  #inpF<-args[1]
  data<-readxl::read_excel(path=paste0(inpF),sheet=1)
  print(inpF)
  hist(as.numeric(unlist(data[,"sum"])),main=inpF,breaks=100)
  hist(log2(as.numeric(unlist(data[,"sum"]))),main=inpF,breaks=100)
  MZ1<-data$ID
  dfMZ1<-union(dfMZ1,MZ1)
  colName<-basename(inpF)
  colnames(data)<-paste0(colnames(data),colName)
  data$RowGeneUniProtScorePeps<-MZ1
  assign(inpF,data)
}
length(dfMZ1)
summary(warnings())
summary(MZ1)
#sheets <- list(data,data) #assume sheet1 and sheet2 are data frames
data<-data.frame(RowGeneUniProtScorePeps=dfMZ1)
for (obj in args) {
  #obj<-args[1]
  print(obj)
  objData<-get(obj)
  colnames(objData)
  data<-merge(data,objData,by="RowGeneUniProtScorePeps",all=T)
}
print(sum(rowSums(is.na(data))==ncol(data)))
data=data[rowSums(is.na(data))!=ncol(data),]
print(sum(rowSums(is.na(data))==ncol(data)))
write.csv(data,outRepCSV,row.names = F)
print(outRepCSV)
writexl::write_xlsx(data,outRep)
print(outRep)
dataSel<-data[,grep("^sum",colnames(data))]
rownames(dataSel)<-data$RowGeneUniProtScorePeps
writexl::write_xlsx(cbind(rownames(dataSel),dataSel),paste0(outF,"select.xlsx"))
print("common IDs")
print(sum(complete.cases(dataSel)))
dataSelRatio=dataSel
dataSelRatio[is.na(dataSelRatio)]<-1
dataSelRatio$Log2=log2(dataSelRatio[,1]/dataSelRatio[,2])
dataSelRatio<-subset(dataSelRatio,select=c(Log2))
write.table(dataSelRatio,paste0(outF,".dataSelLog2Ratio.tsv"),sep="\t",col.names=F)
dataSelScale3<-scales::squish(as.matrix(dataSel),c(1,10e9))
rowMin<-apply(dataSelScale3,1,min,na.rm=T)
summary(rowMin)
dataSelMin1<-dataSelScale3[(rowMin>1),]
summary(dataSelMin1)
svgPHC<-pheatmap::pheatmap(dataSelMin1,fontsize_row=4,cluster_cols=F,cluster_rows=F,fontsize_col  = 4)
ggplot2::ggsave(paste0(outF,".dataSelMin1.svg"), svgPHC,width=10,height=10)
