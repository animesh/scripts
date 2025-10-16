# ..\R-4.5.0\bin\Rscript.exe .\combineXlsx.r "L:\promec\TIMSTOF\LARS\2023\230217_Caroline\combined\txt\proteinGroups.txtLFQ.intensity.110Omego1Cntr1h00.050.5InfBiotTestBH.xlsx" "L:\promec\TIMSTOF\LARS\2023\230217_Caroline\combined\txt\proteinGroups.txtLFQ.intensity.110Omego3Cntr3h00.050.5InfBiotTestBH.xlsx" "L:\promec\TIMSTOF\LARS\2023\230217_Caroline\combined\txt\proteinGroups.txtLFQ.intensity.110Omego6Cntr6h00.050.5InfBiotTestBH.xlsx" "L:\promec\TIMSTOF\LARS\2023\230217_Caroline\combined\txt\proteinGroups.txtLFQ.intensity.110Omego12Cntr12h00.050.5InfBiotTestBH.xlsx" "Log2MedianChange" "RowGeneUniProtScorePeps"
args = commandArgs(trailingOnly=TRUE)
print(paste("supplied argument(s):", length(args)))
#args<-c("L:/promec/TIMSTOF/LARS/2023/230217_Caroline/combined/txt/proteinGroups.txtLFQ.intensity.110Omego1Cntr1h00.050.5InfBiotTestBH.xlsx","L:/promec/TIMSTOF/LARS/2023/230217_Caroline/combined/txt/proteinGroups.txtLFQ.intensity.110Omego3Cntr3h00.050.5InfBiotTestBH.xlsx","L:/promec/TIMSTOF/LARS/2023/230217_Caroline/combined/txt/proteinGroups.txtLFQ.intensity.110Omego6Cntr6h00.050.5InfBiotTestBH.xlsx","L:/promec/TIMSTOF/LARS/2023/230217_Caroline/combined/txt/proteinGroups.txtLFQ.intensity.110Omego12Cntr12h00.050.5InfBiotTestBH.xlsx","Log2MedianChange","RowGeneUniProtScorePeps")
print(args)
rN<-args[length(args)]
cN<-args[length(args)-1]
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
for(inpF in args[-c((length(args)-1),(length(args)))]) {
  #inpF<-args[1]
  data<-readxl::read_excel(path=paste0(inpF),sheet=1)
  print(inpF)
  print(colnames(data))
  hist(as.numeric(unlist(data[,cN])),main=inpF,breaks=100)
  MZ1<-unlist(data[,rN])
  dfMZ1<-union(dfMZ1,MZ1)
  colName<-basename(inpF)
  colnames(data)<-paste0(colnames(data),colName)
  data[,rN]<-MZ1
  assign(inpF,data)
}
length(dfMZ1)
summary(warnings())
summary(MZ1)
data<-data.frame(dfMZ1)
colnames(data)<-rN
for (obj in args[-c((length(args)-1),(length(args)))]) {
  #obj<-args[1]
  print(obj)
  objData<-get(obj)
  colnames(objData)
  data<-merge(data,objData,by=rN,all=T)
}
print(sum(rowSums(is.na(data))==ncol(data)))
data=data[rowSums(is.na(data))!=ncol(data),]
print(sum(rowSums(is.na(data))==ncol(data)))
write.csv(data,outRepCSV,row.names = F)
print(outRepCSV)
writexl::write_xlsx(data,outRep)
print(outRep)
dataSel<-data[,grep(cN,colnames(data))]
rownames(dataSel)<-data[,rN]
print(dim(dataSel))
writexl::write_xlsx(cbind(rownames(dataSel),dataSel),paste0(outF,"select.xlsx"))
print("common IDs")
print(sum(complete.cases(dataSel)))
