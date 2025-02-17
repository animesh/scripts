#Rscript markVolcanoXlsx.r L:\promec\TIMSTOF\LARS\2024\241118_Deo\tot\combined\txt\reports "proteinGroups.txtLFQ.intensity.16" "0.10.50.15BioRemGroups" ".txtLFQ.intensity.tTestBH.xlsx" "L:\promec\TIMSTOF\LARS\2024\241118_Deo\tot\combined\txt\reports\proteinGroups.txtLFQ.intensity.16C2C10.10.50.15BioRemGroups.tTestBH.xlsx.16C4C10.16C6C10MinMaxAbs1.xlsx"
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
markID <- args[5]
#markID<-"L:/promec/TIMSTOF/LARS/2024/241118_Deo/tot/combined/txt/reports/proteinGroups.txtLFQ.intensity.16C2C10.10.50.15BioRemGroups.tTestBH.xlsx.16C4C10.16C6C10MinMaxAbs1.xlsx"
markID <- args[5]
#markID<-"L:/promec/TIMSTOF/LARS/2024/241118_Deo/tot/combined/txt/reports/proteinGroups.txtLFQ.intensity.16C2C10.10.50.15BioRemGroups.tTestBH.xlsx.16C4C10.16C6C10MinMaxAbs1.xlsx"
markIDF<-basename(markID)
print(markIDF)
markData<-readxl::read_excel(path=markID,sheet=1)
splitMarkData<-data.frame(markID=paste(sapply(strsplit(markData$GeneUniprot,";"), "[", 1)))
inpFL<-list.files(pattern=sfx,path=inpD,full.names=F,recursive=F)
print(inpFL)
inpFs<-basename(inpFL)
inpFs<-strsplit(inpFs,"\\.")
inpFs<-unique(unlist(inpFs))
inpFs<-paste(unlist(inpFs),collapse=".")
#sheets<-list()
outF<-paste(inpD,inpFs,sep = "/")
outPDF<-paste0(outF,"mark.pdf")
outRep<-paste0(outF,"mark.xlsx")
outRepCSV<-paste0(outF,"mark.csv")
pdf(outPDF)
dfMZ1<-NA
for(inpF in inpFL){
  #inpF<-inpFL[1]
  #inpF<-inpFL[2]
  data<-readxl::read_excel(path=paste0(inpD,"/",inpF),sheet=1)
  print(inpF)
  hist(as.numeric(unlist(data[,"Log2MedianChange"])),main=inpF,breaks=100)
  #plot(as.numeric(unlist(data[,"Log2MedianChange"])),as.numeric(unlist(data[,"PValueMinusLog10"])),main=inpF)
  dataMark<-merge(splitMarkData,data,by.y="Gene",by.x="markID")
  Significance=data$Gene %in% splitMarkData$markID
  dsub <- subset(data,Significance)
  colName<-basename(inpF)
  colName<-gsub(pfx,"",colName,fixed=T)
  colName<-gsub(mfx,"",colName,fixed=T)
  colName<-gsub(sfx,"",colName,fixed=T)
  p <- ggplot2::ggplot(data,ggplot2::aes(Log2MedianChange,PValueMinusLog10))+ ggplot2::geom_point(ggplot2::aes(color=Significance))
  p<-p + ggplot2::theme_bw(base_size=8) + ggplot2::geom_text(data=dsub,ggplot2::aes(label=Gene),hjust=0, vjust=0,size=1,position=ggplot2::position_jitter(width=0.5,height=0.1)) + ggplot2::scale_fill_gradient(low="white", high="darkblue") + ggplot2::xlab("Log2 Median Change") + ggplot2::ylab("-Log10 P-value")
  #f=paste(file,proc.time()[3],".jpg")
  #install.packages("svglite")
  ggplot2::ggsave(paste0(inpD,"/",colName,markIDF,"MarkVolcanoPlot.svg"), p)
  print(p)
  print(sum(Significance))
  #MZ1<-paste(sapply(strsplit(data$RowGeneUniProtScorePeps,";;"), "[", 2))
  MZ1<-data$RowGeneUniProtScorePeps
  dfMZ1<-union(dfMZ1,MZ1)
  colnames(data)<-paste0(colnames(data),colName)
  data$RowGeneUniProtScorePeps<-MZ1
  assign(inpF,data)
}
length(dfMZ1)
summary(warnings())
summary(MZ1)
dev.off()
