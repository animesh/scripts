#Rscript codonUsageSelect.r "L:\promec\TIMSTOF\LARS\2024\240319_Nicola\combined\txt\2024.05.16_analysis nico.xlsx" "Lists codon usage" 2 "L:\promec\TIMSTOF\LARS\2024\240319_Nicola\combined\txt\CCDS.20221027.txt" "L:\promec\TIMSTOF\LARS\2024\240319_Nicola\combined\txt\CCDS.20221027.annot.csv"
#setup####
#install.packages("ggplot2")
#install.packages("svglite")
#install.packages("pheatmap")
args = commandArgs(trailingOnly=TRUE)
print(args)
inpF <- args[1]
#inpF <-"L:/promec/TIMSTOF/LARS/2024/240319_Nicola/combined/txt/2024.05.16_analysis nico.xlsx"
inpS <- args[2]
#inpS <- "Lists codon usage"
inpC <- args[3]
inpC <- as.numeric(inpC)
#inpC <- 2
inpAnno <- args[4]
#inpAnno <- "L:/promec/TIMSTOF/LARS/2024/240319_Nicola/combined/txt/CCDS.20221027.txt"
inpCU<-args[5]
#inpCU <- "L:/promec/TIMSTOF/LARS/2024/240319_Nicola/combined/txt/CCDS.20221027.annot.csv"
#data####
data<-readxl::read_xlsx(inpF,sheet = inpS)
data<-data.frame(data)
if(inpC>1){
  colnames(data)<-paste0(colnames(data),data[inpC-1,])
  data<-data[-(inpC-1),]
}
dim(data)
#annotation####
#wget https://ftp.ncbi.nlm.nih.gov/pub/CCDS/current_human/CCDS.20221027.txt
dataAnno<-read.table(inpAnno,sep="\t",header=F)
#sed 's/\t/,/g' CCDS.20221027.txt > CCDS.20221027.csv
#wget https://ftp.ncbi.nlm.nih.gov/pub/CCDS/current_human/CCDS_nucleotide.20221027.fna.gz
#perl codonusage.pl CCDS_nucleotide.20221027.fna CCDS.20221027.csv > CCDS.20221027.annot.csv 2>err
#CU####
dataCU<-read.csv(inpCU,header=T)
#merge####
dataCUanno<-merge(dataCU,dataAnno,by.x="ID",by.y="V5",all=T)
#upInAll<-dataCUanno[data$`FC0.5UP in all` %in% dataCUanno$V3,]
#dataUpInAll<-merge(data,objData,by="RowGeneUniProtScorePeps",all=T)
#data<-data[!duplicated(data$RowGeneUniProtScorePeps),]
#dataS<-data[,grep(selection,colnames(data))]
#dataS<-data.frame(sapply(dataS,as.numeric))
#list####
for(i in colnames(data)){
  #i<-"FC0.5UP in all"
  print(i)
  dataSelCol<-data.frame(ID=data[(data[i]!="0")&!is.na(data[i]),i])
  print(dim(dataSelCol))
  dataSelColCUanno<-merge(dataCUanno,dataSelCol,by.x="V3",by.y="ID",all.y=T)
  dataSelColCUanno<-dataSelColCUanno[!is.na(dataSelColCUanno$StopCodons),]
  print(dim(dataSelColCUanno))
  #write####
  writexl::write_xlsx(dataSelColCUanno,paste0(inpF,".sheet.",inpS,".list.",i,"hdr",inpC,".annotation.",basename(inpAnno),".count.",basename(inpCU),".xlsx"))
  print(paste("processed sheet",inpS,".list.",i,"hdr",inpC))
  print(paste0(inpF,".sheet.",inpS,".list.",i,"hdr",inpC,".annotation.",basename(inpAnno),".count.",basename(inpCU),".xlsx"))
}
