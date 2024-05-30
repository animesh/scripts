#git checkout ebbdd3bf84fdd40e6abd7c353fc101fadcedc87c diffExprTestT.r
#Rscript.exe diffExprTestT.r L:\promec\TIMSTOF\LARS\2024\240319_Nicola\combined\txt\proteinGroups.txt L:\promec\TIMSTOF\LARS\2024\240319_Nicola\combined\txt\GroupsRem.txt Bio Rem Intensity. WT 0.1 1 0.05
#Rscript codonUsageSelect.r "L:\promec\TIMSTOF\LARS\2024\240319_Nicola\combined\txt\proteinGroups.txtIntensity.0.110.05BioRemGroupsRem.txtWTtTestBH.combined.xlsx" "Sheet1" 2 "L:\promec\TIMSTOF\LARS\2024\240319_Nicola\combined\txt\CCDS.20221027.txt" "L:\promec\TIMSTOF\LARS\2024\240319_Nicola\combined\txt\CCDS.20221027.annot.csv"
#setup####
#install.packages("ggplot2")
#install.packages("svglite")
#install.packages("pheatmap")
args = commandArgs(trailingOnly=TRUE)
print(args)
inpF <- args[1]
#inpF <-"L:/promec/TIMSTOF/LARS/2024/240319_Nicola/combined/txt/proteinGroups.txtIntensity.0.110.05BioRemGroupsRem.txtWTtTestBH.combined.xlsx"
inpS <- args[2]
#inpS <- "Sheet1"
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
#list####
dataSelCol<-data.frame(ID=data[(data[inpC]!="0")&!is.na(data[inpC]),inpC])
print(dim(dataSelCol))
dataSelColCUanno<-merge(dataCUanno,dataSelCol,by.x="V3",by.y="ID",all.y=T)
dataSelColCUanno<-dataSelColCUanno[!is.na(dataSelColCUanno$StopCodons),]
print(dim(dataSelColCUanno))
#write####
writexl::write_xlsx(dataSelColCUanno,paste0(inpF,".sheet.",inpS,".list.","hdr",inpC,".annotation.",basename(inpAnno),".count.",basename(inpCU),".xlsx"))
print(paste("processed sheet",inpS,".list.","hdr",inpC))
print(paste0(inpF,".sheet.",inpS,".list.","hdr",inpC,".annotation.",basename(inpAnno),".count.",basename(inpCU),".xlsx"))
