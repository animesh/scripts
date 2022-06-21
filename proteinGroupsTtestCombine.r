#c:/Users/animeshs/R/bin/Rscript.exe proteinGroupsTtestCombine.r L:/promec/TIMSTOF/LARS/2021/November/SIGRID/combined/txtNoNQd/ BiotTestBH.csv
args = commandArgs(trailingOnly=TRUE)
print(paste("supplied argument(s):", length(args)))
print(args)
if (length(args) != 5) {stop("\n\nNeeds THREE arguments, the full path of the directory containing REPORTS, file-PATTERN, ID-column, log2Threshold, FDR-threshold for example: c:/Users/animeshs/R/bin/Rscript.exe proteinGroupsTtestCombine.r L:/promec/TIMSTOF/LARS/2021/November/SIGRID/combined/txtNoNQd/TS/ 0.050.50.05grouptTestBH RowGeneUniProtScorePeps 0.5 0.1", call.=FALSE)}
#data####
inpD <- args[1]
#inpD<-"L:/promec/TIMSTOF/LARS/2022/februar/Sigrid/combined/txtDQnoPHOS/reports/TS/"
lGroup <- args[2]
#lGroup<-"BiotTestBH.csv"
cSel <- args[3]
#cSel<-"RowGeneUniProtScorePeps"
log2Thr <- args[4]
#log2Thr<-0.5
cpvalThr <- args[5]
#cpvalThr<-0.1
inpF<-list.files(pattern=lGroup,path=inpD,full.names=F,recursive=F)
#combine####
data<-read.csv(paste0(inpD,inpF[1]))
dataC<-data.frame(ID=data[,cSel])
#pdf(paste0(inpD,strsplit(lGroup,'\\.')[[1]][1],"combined.pdf"))
fCnt=0
for(inpF in inpF){
    fCnt=fCnt+1
    #inpF="proteinGroups.txtLFQ.intensity.16WT TMZ 24hWT Ctrl0.050.50.05BiotTestBH.csv"#inpF[1]
    print(paste(fCnt,inpF))
    data<-read.csv(paste0(inpD,inpF))
    data<-data[!is.na(data$CorrectedPValueBH) & abs(data$Log2MedianChange)>log2Thr & data$CorrectedPValueBH<cpvalThr,]
    #hist(data$Log2MedianChange,labels = inpF)
    cName<-gsub("proteinGroups.txtLFQ.intensity.16","",inpF)
    cName<-gsub(lGroup,"",cName)
    cName<-gsub(" ","",cName)
    colnames(data)<-paste0(cName,colnames(data))
    dataC<-merge(dataC,data,by.x="ID",by.y =paste0(cName,cSel),all=T)
}
write.csv(dataC,paste0(inpD,"proteinGroups",cSel,log2Thr,cpvalThr,"combined.csv"))
#writexl::write_xlsx(dataC,paste0(inpD,lGroup,"combined.xlsx"))
dataS<-dataC[,grep("ID|FoldChanglog2median|CorrectedPValueBH|TtestPval|Log2MedianChange",colnames(dataC))]
dataS["Uniprot"]<-paste(sapply(strsplit(paste(sapply(strsplit(dataS$ID, "|",fixed=T), "[", 2)), "-"), "[", 1))
write.csv(dataS,paste0(inpD,"proteinGroups",cSel,log2Thr,cpvalThr,"combined.select.csv"))
data24h<-dataS[,grep("ID|24h",colnames(dataS))]
data24h<-data24h[,grep("ID|Log2MedianChange",colnames(data24h))]
data24h["Uniprot"]<-paste(sapply(strsplit(paste(sapply(strsplit(data24h$ID, "|",fixed=T), "[", 2)), "-"), "[", 1))
data24h[is.na(data24h)]=0
names(data24h)<-substr(names(data24h),1,10)
limma::vennDiagram(abs(data24h[,2:5])>log2Thr)
limma::vennDiagram(data24h[,2:5]>log2Thr)
limma::vennDiagram(data24h[,2:5]<(log2Thr)*-1)
write.csv(data24h,paste0(inpD,"proteinGroups24h",cSel,log2Thr,cpvalThr,"combined.select.csv"))
#writexl::write_xlsx(dataS,paste0(inpD,lGroup,"combined.select.xlsx"))
#c:/Users/animeshs/R/bin/Rscript.exe proteinGroupsTtestCombine.r L:/promec/TIMSTOF/LARS/2022/februar/Sigrid/combined/txtDQnoPHOS/reports/TS/ BiotTestBH.csv RowGeneUniProtScorePeps 0.5 0.1 running via command line we are losing Q8WWK9-6 in "WT TMZ 24h" group?
