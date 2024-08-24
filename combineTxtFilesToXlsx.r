#Rscript combineXlsx.r
#install.packages(c("gglot2","svgite"))
inpFL<-list.files(pattern=".xls*",path=inpD,full.names=F,recursive=F)
print(inpFL)
print(paste("supplied argument(s):", length(args)))
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
pfx<-"proteinGroups.txtLFQ.intensity.11"
mfx<-"0.110.05BioRemGroups"
sfx<-".txtLFQ.intensity.tTestBH.csv"
outF<-paste(inpD,inpFs,sep = "/")
outPDF<-paste0(outF,"combo.pdf")
outRep<-paste0(outF,"combo.xlsx")
outRepCSV<-paste0(outF,"combo.csv")
pdf(outPDF)
dfMZ1<-NA
for(inpF in inpFL){
    #inpF<-inpFL[1]
    #inpF<-inpFL[2]
    data<-read.csv(inpF)
    print(inpF)
    hist(as.numeric(data[,"Log2MedianChange"]),main=inpF,breaks=100)
    plot(as.numeric(data[,"Log2MedianChange"]),as.numeric(data[,"PValueMinusLog10"]),main=inpF)
    MZ1<-paste(sapply(strsplit(data$RowGeneUniProtScorePeps,";;"), "[", 2))
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

