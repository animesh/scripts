#Rscript selectIDfromXlsx.r "L:\promec\Elite\LARS\2018\mai\Vibeke V\PDv2p5\Clots\suppltab2_v1.xlsx" "L:\promec\Elite\LARS\2018\mai\Vibeke V\PDv2p5\Clots\180507_VIBEKEV_C1-(12)Proteins.xlsx"
#install.packages(c("gglot2","svgite"))
args = commandArgs(trailingOnly=TRUE)
print(paste("supplied argument(s):", length(args)))
#args<-c("L:/promec/Elite/LARS/2018/mai/Vibeke V/PDv2p5/Clots/suppltab2_v1.xlsx","L:/promec/Elite/LARS/2018/mai/Vibeke V/PDv2p5/Clots/180507_VIBEKEV_C1-(12)Proteins.xlsx")
print(args)
inpFL<-args
print(inpFL)
inpD<-dirname(inpFL)
inpD<-unique(inpD)[1]
print(inpD)
inpFs<-basename(inpFL)
inpFs<-strsplit(inpFs,"\\.")
inpFs<-unique(unlist(inpFs))
inpFs<-paste(unlist(inpFs),collapse=".")
#sheets<-list()
outF<-paste(inpD,inpFs,sep = "/")
outRep<-paste0(outF,"combo.xlsx")
outRepCSV<-paste0(outF,"combo.csv")
dfMZ1<-NA
for(inpF in inpFL){
  #inpF<-inpFL[1]
  print(inpF)
  data<-readxl::read_excel(inpF)
  if(!"Uniprot" %in% names(data)){data$Uniprot<-paste(sapply(strsplit(paste(sapply(strsplit(paste(sapply(strsplit(data$`FASTA Title Lines`, "|",fixed=T), "[", 2)), " "), "[", 1)), ":"), "[", 1))}
  MZ1<-data$Uniprot
  dfMZ1<-union(dfMZ1,MZ1)
  colnames(data)<-paste0(colnames(data),basename(inpF))
  data$Uniprot<-MZ1
  assign(inpF,data)
}
length(dfMZ1)
summary(warnings())
summary(MZ1)
#sheets <- list(data,data) #assume sheet1 and sheet2 are data frames
data<-data.frame(Uniprot=dfMZ1)
for (obj in inpFL) {
  #obj<-inpFL[1]
  print(obj)
  objData<-get(obj)
  colnames(objData)
  data<-merge(data,objData,by="Uniprot",all=F)
}
print(sum(rowSums(is.na(data))==ncol(data)))
data=data[rowSums(is.na(data))!=ncol(data),]
write.csv(data,outRepCSV,row.names = F)
print(outRepCSV)
writexl::write_xlsx(data,outRep)
print(outRep)
