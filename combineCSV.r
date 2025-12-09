# ..\R-4.5.0\bin\Rscript.exe .\combineCSV.r "F:\maren\extra\251203_3kda_A9_dda1_2_desalt.raw.centroid.MGF.csv" "F:\maren\extra\251203_3kda_A9_dda1_2.raw.centroid.MGF.csv" "F:\maren\extra\251203_3kda_A3_dda1_2_desalt.raw.centroid.MGF.csv" "F:\maren\extra\251203_3kda_A3_dda1_2.raw.centroid.MGF.csv" "F:\maren\extra\251203_1kda_A7_dda1_2_desalt.raw.centroid.MGF.csv" "F:\maren\extra\251203_1kda_A7_dda1_2.raw.centroid.MGF.csv" "F:\maren\extra\251203_1kda_A3_dda1_2_desalt.raw.centroid.MGF.csv" "F:\maren\extra\251203_1kda_A3_dda1_2.raw.centroid.MGF.csv" "20" "score" "peptide"
# for i in /mnt/f/maren/extra/*.raw ; do echo $i;  mono RawRead.exe $i ; done
# for %i in ("F:\maren\*.MGF") do (java -jar "Z:\Download\SearchGUI-4.3.15-windows\SearchGUI-4.3.17\resources\Novor\novor.jar" "%i" -p novo.params -f)
args = commandArgs(trailingOnly=TRUE)
print(paste("supplied argument(s):", length(args)))
#args<-c("F:/maren/extra/251203_3kda_A9_dda1_2_desalt.raw.centroid.MGF.csv","20","score","peptide")
print(args)
rN<-args[length(args)]
cN<-args[length(args)-1]
sN<-as.integer(args[length(args)-2])
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
for(inpF in args[-c((length(args)-2):(length(args)))]) {
  #inpF<-args[1]
  data<-read.csv(inpF,skip=sN,header=T)
  print(inpF)
  print(colnames(data))
  hist(as.numeric(unlist(data[,cN])),main=inpF,breaks=100)
  data[,rN]=gsub(" ", "", data[,rN], fixed = TRUE)
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
