#Rscript selectIDfromXlsx.r L:\promec\USERS\Alessandro\230119_66samples-redo\combined\txt\proteinGroups.txtLFQ.intensity.18PL_2080_4hWB_2080_4h0.110.05BioRemGroupsInt.txtLFQ.intensity.tTestBH.csv L:\promec\USERS\Alessandro\230119_66samples-redo\combined\txt\proteinGroups.txtLFQ.intensity.18PL_4060_4hWB_4060_4h0.110.05BioRemGroupsInt.txtLFQ.intensity.tTestBH.csv L:\promec\USERS\Alessandro\230119_66samples-redo\combined\txt\proteinGroups.txtLFQ.intensity.18PL_AP_4hWB_AP_4h0.110.05BioRemGroupsInt.txtLFQ.intensity.tTestBH.csv L:\promec\USERS\Alessandro\230119_66samples-redo\combined\txt\proteinGroups.txtLFQ.intensity.18PL_UP_4hWB_UP_4h0.110.05BioRemGroupsInt.txtLFQ.intensity.tTestBH.csv
#Rscript.exe diffExprTestT.r "L:\promec\USERS\Alessandro\230119_66samples-redo\combined\txt\proteinGroups.txt" "L:\promec\USERS\Alessandro\230119_66samples-redo\combined\txt\GroupsInt.txt" "Bio" "Rem" "LFQ.intensity." "PL_2080_4h" "WB_2080_4h" 0.1 1 0.05
#Rscript.exe diffExprTestT.r "L:\promec\USERS\Alessandro\230119_66samples-redo\combined\txt\proteinGroups.txt" "L:\promec\USERS\Alessandro\230119_66samples-redo\combined\txt\GroupsInt.txt" "Bio" "Rem" "LFQ.intensity." "PL_4060_4h" "WB_4060_4h" 0.1 1 0.05
#Rscript.exe diffExprTestT.r "L:\promec\USERS\Alessandro\230119_66samples-redo\combined\txt\proteinGroups.txt" "L:\promec\USERS\Alessandro\230119_66samples-redo\combined\txt\GroupsInt.txt" "Bio" "Rem" "LFQ.intensity." "PL_AP_4h" "WB_AP_4h" 0.1 1 0.05
#Rscript.exe diffExprTestT.r "L:\promec\USERS\Alessandro\230119_66samples-redo\combined\txt\proteinGroups.txt" "L:\promec\USERS\Alessandro\230119_66samples-redo\combined\txt\GroupsInt.txt" "Bio" "Rem" "LFQ.intensity." "PL_UP_4h" "WB_UP_4h" 0.1 1 0.05
#install.packages(c("gglot2","svgite"))
args = commandArgs(trailingOnly=TRUE)
print(paste("supplied argument(s):", length(args)))
#args<-c("L:/promec/USERS/Alessandro/230119_66samples-redo/combined/txt/proteinGroups.txtLFQ.intensity.18PL_2080_4hWB_2080_4h0.110.05BioRemGroupsInt.txtLFQ.intensity.tTestBH.csv","L:/promec/USERS/Alessandro/230119_66samples-redo/combined/txt/proteinGroups.txtLFQ.intensity.18PL_4060_4hWB_4060_4h0.110.05BioRemGroupsInt.txtLFQ.intensity.tTestBH.csv","L:/promec/USERS/Alessandro/230119_66samples-redo/combined/txt/proteinGroups.txtLFQ.intensity.18PL_AP_4hWB_AP_4h0.110.05BioRemGroupsInt.txtLFQ.intensity.tTestBH.csv","L:/promec/USERS/Alessandro/230119_66samples-redo/combined/txt/proteinGroups.txtLFQ.intensity.18PL_UP_4hWB_UP_4h0.110.05BioRemGroupsInt.txtLFQ.intensity.tTestBH.csv")
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
outPDF<-paste0(outF,"combo.pdf")
outRep<-paste0(outF,"combo.xlsx")
outRepCSV<-paste0(outF,"combo.csv")
pdf(outPDF)
dfMZ1<-NA
for(inpF in inpFL){
    #inpF<-inpFL[1]
    data<-read.csv(inpF)
    print(inpF)
    hist(as.numeric(data[,"Log2MedianChange"]),main=inpF,breaks=100)
    plot(as.numeric(data[,"Log2MedianChange"]),as.numeric(data[,"PValueMinusLog10"]),main=inpF)
    MZ1<-data$RowGeneUniProtScorePeps
    dfMZ1<-union(dfMZ1,MZ1)
    colnames(data)<-paste0(colnames(data),inpF)
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

