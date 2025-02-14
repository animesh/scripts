#Rscript combineXlsx.r L:\promec\TIMSTOF\LARS\2024\241118_Deo\tot\combined\txt\reports "proteinGroups.txtLFQ.intensity.16" "0.10.50.15BioRemGroups" ".txtLFQ.intensity.tTestBH.xlsx"
args = commandArgs(trailingOnly=TRUE)
print(paste("supplied argument(s):", length(args)))
print(args)
inpD <- args[1]
#inpD<-"L:/promec/TIMSTOF/LARS/2024/241118_Deo/tot/combined/txt/reports"
print(inpD)
pfx <- args[2]
#pfx<-"proteinGroups.txtLFQ.intensity.16"
mfx <- args[3]
#mfx<-"0.10.50.15BioRemGroups"
sfx <- args[4]
#sfx<-".txtLFQ.intensity.tTestBH.xlsx"
print(paste(pfx,mfx,sfx))
inpFL<-list.files(pattern=sfx,path=inpD,full.names=F,recursive=F)
print(inpFL)
inpFs<-basename(inpFL)
inpFs<-strsplit(inpFs,"\\.")
inpFs<-unique(unlist(inpFs))
inpFs<-paste(unlist(inpFs),collapse=".")
#sheets<-list()
outF<-paste(inpD,inpFs,sep = "/")
outPDF<-paste0(outF,"combo.pdf")
outRep<-paste0(outF,"combo.xlsx")
outRepCSV<-paste0(outF,"combo.csv")
pdf(outPDF)
dfMZ1<-NA
for(inpF in inpFL){
  #inpF<-inpFL[1]
  #inpF<-inpFL[2]
  data<-readxl::read_excel(path=paste0(inpD,"/",inpF),sheet=1)
  print(inpF)
  hist(as.numeric(unlist(data[,"Log2MedianChange"])),main=inpF,breaks=100)
  plot(as.numeric(unlist(data[,"Log2MedianChange"])),as.numeric(unlist(data[,"PValueMinusLog10"])),main=inpF)
  #MZ1<-paste(sapply(strsplit(data$RowGeneUniProtScorePeps,";;"), "[", 2))
  MZ1<-data$RowGeneUniProtScorePeps
  dfMZ1<-union(dfMZ1,MZ1)
  colName<-basename(inpF)
  colName<-gsub(pfx,"",colName,fixed=T)
  colName<-gsub(mfx,"",colName,fixed=T)
  colName<-gsub(sfx,"",colName,fixed=T)
  colnames(data)<-paste0(colnames(data),colName)
  data$RowGeneUniProtScorePeps<-MZ1
  assign(inpF,data)
}
length(dfMZ1)
summary(warnings())
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
data=data[rowSums(is.na(data))!=ncol(data),]
geneName<-paste(sapply(strsplit(paste(sapply(strsplit(data$RowGeneUniProtScorePeps, "GN=",fixed=T), "[", 2)), "[; ]"), "[", 1))
uniprotID<-paste(sapply(strsplit(paste(sapply(strsplit(data$RowGeneUniProtScorePeps, "\\|",fixed=F), "[", 2)), "\\|"), "[", 1))
geneName[is.na(geneName)]=uniprotID[is.na(geneName)]
proteinNames<-paste(sapply(strsplit(paste(sapply(strsplit(data$RowGeneUniProtScorePeps, "_",fixed=T), "[", 2)), " OS="), "[", 1))
write.csv(cbind(Uniprot=uniprotID,Gene=geneName,Protein=proteinNames,data),outRepCSV,row.names = F)
print(outRepCSV)
writexl::write_xlsx(cbind(Uniprot=uniprotID,Gene=geneName,Protein=proteinNames,data),outRep)
print(outRep)
dataSel<-data[,grep("Log2MedianChange",colnames(data))]
rownames(dataSel)<-paste(geneName,uniprotID,sep=";")
dataSelScale3<-scales::squish(as.matrix(dataSel),c(-3,3))
rowMin<-apply(dataSelScale3,1,min,na.rm=T)
summary(rowMin)
dataSelMin1<-dataSelScale3[(rowMin>1),]
summary(dataSelMin1)
svgPHC<-pheatmap::pheatmap(dataSelMin1,clustering_distance_rows = "euclidean",clustering_distance_cols = "euclidean",fontsize_row=4,cluster_cols=T,cluster_rows=T,fontsize_col  = 4)
ggplot2::ggsave(paste0(outF,".dataSelMin1.svg"), svgPHC,width=10,height=10)
rowMax<-apply(dataSel,1,max,na.rm=T)
dataSelMaxMinus1<-dataSelScale3[(rowMax<(-1)),]
summary(dataSelMaxMinus1)
svgPHC<-pheatmap::pheatmap(dataSelMaxMinus1,clustering_distance_rows = "euclidean",clustering_distance_cols = "euclidean",fontsize_row=4,cluster_cols=T,cluster_rows=T,fontsize_col  = 4)
ggplot2::ggsave(paste0(outF,".dataSelMaxMinus1.svg"), svgPHC,width=10,height=10)
dataSelMinMaxAbs1<-rbind(dataSelMin1,dataSelMaxMinus1)
summary(dataSelMinMaxAbs1)
writexl::write_xlsx(data.frame(cbind(GeneUniprot=rownames(dataSelMinMaxAbs1),dataSelMinMaxAbs1)),paste0(outF,"MinMaxAbs1.xlsx"))

