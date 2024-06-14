#Rscript diffExprDoseCor.r "L:\promec\USERS\SINTEF\20211207_SINTEF_30samples\combined\txt\\" "proteinGroups.txtLFQ.intensity.16" "Clin0.110.05BioRemGroups_filledMEclin.txttTestBH.xlsx"
#Rscript diffExprDoseCor.r "L:\promec\USERS\SINTEF\20211207_SINTEF_30samples\combined\txt\\" "proteinGroups.txtLFQ.intensity.16" "Ctrl0.110.05BioRemGroups_filledME.txttTestBH.xlsx"
#setup####
args = commandArgs(trailingOnly=TRUE)
print(paste("supplied argument(s):", length(args)))
print(args)
if (length(args) != 3) {stop("\n\nNeeds the full path of the directory containing excel reports and common prefix and suffix\n", call.=FALSE)}
inpD <- args[1]
inpFP <- args[2]
inpFS <- args[3]
pdf(paste0(inpD,inpFS,"combined.pdf"))
if (!requireNamespace(c("readxl", "writexl"),quietly = TRUE)) {install.packages(c("readxl", "writexl"))}
#data####
#inpD <-"L:/promec/USERS/SINTEF/20211207_SINTEF_30samples/combined/txt/"
#inpFP<-"proteinGroups.txtLFQ.intensity.16"
#inpFS<-"Ctrl0.110.05BioRemGroups_filledME.txttTestBH.xlsx"
inpFL<-list.files(pattern=paste0(inpFS,"$"),path=inpD,full.names=F,recursive=F)
inpFL<-grep(paste0("^",inpFP),inpFL,value=T)
print(inpFL)
ID<-NA
for(inpF in inpFL){
  #inpF<-inpFL[1]
  data<-readxl::read_xlsx(paste(inpD,inpF,sep="/"))
  print(inpF)
  print(dim(data))
  if(dim(data)[1]>0){
    #hist(data$`p-val`,main=inpF)
    plot(data$Log2MedianChange,data$PValueMinusLog10,main=inpF,xlab="log2MedianDiff",ylab="log10p-value",pch=16)
    text(data$Log2MedianChange,data$PValueMinusLog10,labels=data$Gene,cex=0.6,pos=4)
  }
  #sheets<-append(sheets,list(data))
  tmpID<-paste(data$RowGeneUniProtScorePeps,sep=";;")
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
#write.csv(data,paste0(inpD,inpFP,inpFS,"combined.csv"),row.names = F)
writexl::write_xlsx(data,paste0(inpD,inpFP,inpFS,"combined.xlsx"))
#correlate log2median Clinical and WT and their difference between with dose
colnames(data)
dataSel<-data[,c(grep("combID|Log2MedianChange",colnames(data)))]
colnames(dataSel)
colnames(dataSel)<-gsub("Log2MedianChange","",colnames(dataSel))
colnames(dataSel)<-gsub(inpFP,"",colnames(dataSel))
colnames(dataSel)<-gsub(inpFS,"",colnames(dataSel))
print(colnames(dataSel))
writexl::write_xlsx(dataSel,paste0(inpD,inpFP,inpFS,"select.combined.xlsx"))
#correlation####
dataSelCor<-dataSel[,!grepl("combID",colnames(dataSel))]
dataSelCor[dataSelCor==0]<-NA
rownames(dataSelCor)<-paste0(unlist(dataSel$combID))
writexl::write_xlsx(dataSelCor,paste0(inpD,inpFP,inpFS,"select.combined.cor.xlsx"))
resCor=apply(dataSelCor, 1,function(x)
  if((sum(!is.na(x))>2)){
    cort=cor.test(as.numeric(x),as.numeric(gsub("[^0-9.-]", "",colnames(dataSel)[!grepl("combID",colnames(dataSel))])),use="pairwise.complete.obs",method="pearson")
    cort=unlist(cort)
    paste(cort[[1]],cort[[2]],cort[[3]],cort[[4]],sep="--VALS--")
  }
  else{NA}
)
pValCor<-sapply(strsplit(resCor, "--VALS--",fixed=T), "[", 3)
pValNA<-sapply(pValCor,as.numeric)
hist(pValNA)
cValCor<-sapply(strsplit(resCor, "--VALS--",fixed=T), "[", 4)
cValNA<-sapply(cValCor,as.numeric)
hist(cValNA)
tValCor<-sapply(strsplit(resCor, "--VALS--",fixed=T), "[", 1)
tValNA<-sapply(tValCor,as.numeric)
hist(tValNA)
yValCor<-sapply(strsplit(resCor, "--VALS--",fixed=T), "[", 2)
yValNA<-sapply(yValCor,as.numeric)
hist(yValNA)
summary(pValNA)
summary(cValNA)
if(sum(is.na(pValNA))==nrow(dataSelCor)){pValNA[is.na(pValNA)]=1}
hist(pValNA)
dfpValNA<-as.data.frame(ceiling(pValNA))
pValNAdm<-cbind(pValNA,dataSelCor,row.names(dataSelCor))
pValNAminusLog10 = -log10(pValNA+.Machine$double.xmin)
hist(pValNAminusLog10)
library(scales)
pValNAminusLog10=squish(pValNAminusLog10,c(0,5))
hist(pValNAminusLog10)
summary(pValNAminusLog10)
length(pValNA)-(sum(is.na(pValNA))+sum(ceiling(pValNA)==0,na.rm = T))
pValBHna = p.adjust(pValNA,method = "BH")
summary(pValBHna)
hist(pValBHna)
pValBHnaMinusLog10 = -log10(pValBHna+.Machine$double.xmin)
geneName<-paste(sapply(strsplit(paste(sapply(strsplit(row.names(dataSelCor), "GN=",fixed=T), "[", 2)), " "), "[", 1))
uniprotID<-paste(sapply(strsplit(paste(sapply(strsplit(row.names(dataSelCor), ";;",fixed=T), "[", 3)), "-"), "[", 1))
corTest.results = data.frame(Uniprot=uniprotID,Gene=geneName,PValueMinusLog10=pValNAminusLog10,CorrectedPValueBH=pValBHna,CorTestPval=pValNA,Cor=cValNA,dataSelCor,Fasta=row.names(dataSelCor))
plot(corTest.results$Cor,corTest.results$PValueMinusLog10,main=inpD,xlab="correlation",ylab="log10p-value",pch=16)
text(corTest.results$Cor,corTest.results$PValueMinusLog10,labels=corTest.results$Gene,cex=0.6,pos=4)
corTest.results<-corTest.results[order(corTest.results$Cor,decreasing = T),]
corTest.results<-corTest.results[order(corTest.results$CorTestPval,decreasing = F),]
writexl::write_xlsx(corTest.results,paste0(inpD,inpFP,inpFS,"select.combined.cor.results.xlsx"))
print(inpD)
summary(warnings())
dev.off()
