# "c:\Program Files\R\R-4.5.1\bin\Rscript.exe" combineCSV.r "F:\promec\HF\Lars\2025\251204_Maren_Gemma\Extra\251203_3kda_A9_dda1_2_desalt.raw.centroid.MGF.csv" "F:\promec\HF\Lars\2025\251204_Maren_Gemma\Extra\251203_3kda_A9_dda1_2.raw.centroid.MGF.csv" "F:\promec\HF\Lars\2025\251204_Maren_Gemma\Extra\251203_3kda_A3_dda1_2_desalt.raw.centroid.MGF.csv" "F:\promec\HF\Lars\2025\251204_Maren_Gemma\Extra\251203_3kda_A3_dda1_2.raw.centroid.MGF.csv" "F:\promec\HF\Lars\2025\251204_Maren_Gemma\Extra\251203_1kda_A7_dda1_2_desalt.raw.centroid.MGF.csv" "F:\promec\HF\Lars\2025\251204_Maren_Gemma\Extra\251203_1kda_A7_dda1_2.raw.centroid.MGF.csv" "F:\promec\HF\Lars\2025\251204_Maren_Gemma\Extra\251203_1kda_A3_dda1_2_desalt.raw.centroid.MGF.csv" "F:\promec\HF\Lars\2025\251204_Maren_Gemma\Extra\251203_1kda_A3_dda1_2.raw.centroid.MGF.csv" "20" "score" "peptide"
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
outF<-paste(dirname(args[1]),sep = "/")
outPDF<-paste0(outF,"combo.pdf")
outRepCSV<-paste0(outF,"combo.csv")
pdf(outPDF)
dfMZ1<-NA
for(inpF in args[-c((length(args)-2):(length(args)))]) {
  #inpF<-args[1]
  print(inpF)
  data<-read.csv(inpF,skip=sN,header=T)
  print(colnames(data))
  hist(as.numeric(unlist(data[,cN])),main=inpF,breaks=100)
  data[,rN]=toupper(data[,rN])
  data[,rN]=gsub(" ", "", data[,rN], fixed = TRUE)
  data[,rN]=gsub("[^[:alnum:]]+","_",data[,rN])
  data<-aggregate(data[,cN],data[rN], max)
  rownames(data)<-data[,rN]
  data[,rN]<-NULL
  colnames(data)<-basename(inpF)
  MZ1<-unlist(rownames(data))
  dfMZ1<-union(dfMZ1,MZ1)
  assign(inpF,data)
  print(dim(data))
}
length(dfMZ1)
summary(warnings())
summary(MZ1)
data<-data.frame(dfMZ1)
colnames(data)<-rN
for (obj in args[-c((length(args)-2):(length(args)))]) {
  #obj<-args[1]
  print(obj)
  objData<-get(obj)
  print(colnames(objData))
  print(dim(objData))
  data<-merge(data,objData,by.x=rN,by.y=0,all=T)
  print(dim(data))
  rm(objData)
}
print(sum(rowSums(is.na(data))==ncol(data)))
data=data[rowSums(is.na(data))!=ncol(data),]
print(sum(rowSums(is.na(data))==ncol(data)))
data=data[order(rowSums(data[,-1],na.rm=T),decreasing=T),]
write.csv(data,outRepCSV,row.names = F)
print(outRepCSV)
print(sum(complete.cases(data)))
