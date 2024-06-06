#Rscript combineXlsx.r L:\promec\USERS\SINTEF\20211207_SINTEF_30samples\GO\2024-05-05_go_term_enrichment_tables_ttest_v1\2024-05-05_go_term_enrichment_tables_ttest_v1
#install.packages(c("writexl","readxl"))
args = commandArgs(trailingOnly=TRUE)
print(paste("supplied argument(s):", length(args)))
print(args)
inpD <- args[1]
#inpD<-"L:/promec/USERS/SINTEF/20211207_SINTEF_30samples/GO/2024-05-05_go_term_enrichment_tables_ttest_v1/2024-05-05_go_term_enrichment_tables_ttest_v1"
inpFL<-list.files(pattern=".xls*",path=inpD,full.names=F,recursive=F)
print(inpFL)
outF<-paste0(inpD,"combined")
outPDF<-paste0(outF,".pdf")
outRep<-paste0(outF,".xlsx")
outRepSel<-paste0(outF,".select.xlsx")
outRepCSV<-paste0(outF,".csv")
outRepSelCSV<-paste0(outF,".select.csv")
pdf(outPDF)
#sheets<-list()
ID<-NA
for(inpF in inpFL){
    #inpF<-inpFL[1]
    #inpF<-"go_enrichment_ctrl50_ttestfdr=0.01_gofdr=0.05.xlsx"
    data<-readxl::read_xlsx(paste(inpD,inpF,sep="/"))
    print(inpF)
    print(summary(data))
    print(dim(data))
    if(dim(data)[1]>0){
      #hist(data$`p-val`,main=inpF)
      plot(data$`p-val`,data$Enrichment,main=inpF,xlab="p-value",ylab="Enrichment",pch=7)
      text(data$`p-val`,data$Enrichment,labels=data$`GO explanation`,cex=0.6,pos=2)
      text(data$`p-val`,data$Enrichment,labels=data$`GO explanation`,cex=0.6,pos=4)
    }
    #sheets<-append(sheets,list(data))
    tmpID<-data$`GO explanation`
    ID<-union(ID,tmpID)
    colnames(data)<-paste0(colnames(data),inpF)
    data$combID<-tmpID
    assign(inpF,data)
}
length(ID)
summary(warnings())
print(inpFL)
summary(tmpID)
#sheets <- list(data,data) #assume sheet1 and sheet2 are data frames
data<-data.frame(combID=ID)
for (obj in inpFL) {
  #obj<-inpFL[1]
  print(obj)
  objData<-get(obj)
  colnames(objData)
  data<-merge(data,objData,by="combID",all=T)
}
print(sum(rowSums(is.na(data))==ncol(data)))
writexl::write_xlsx(data,outRep)
write.csv(data,outRepCSV,row.names = F)
dataSel<-data[,c(grep("combID|Enrichment",colnames(data)))]
colnames(dataSel)<-gsub("Enrichmentgo_enrichment_|fdr|=|ttest|.xlsx","",colnames(dataSel))
sort(colnames(dataSel))
dataSelClin<-dataSel[,c(grep("clin",colnames(dataSel)))]
dataSelCtr<-dataSel[,c(grep("ctr",colnames(dataSel)))]
dataSel$CliNA<-rowSums(!is.na(dataSelClin))
dataSel$CtrNA<-rowSums(!is.na(dataSelCtr))
dataSel<-dataSel[order(dataSel$CtrNA,decreasing = T),]
dataSel<-dataSel[order(dataSel$CliNA,decreasing = T),]
writexl::write_xlsx(dataSel,outRepSel)
write.csv(dataSel,outRepSelCSV,row.names = F)
print(colnames(dataSel))
print(inpD)
print(outF)
