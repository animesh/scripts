#c:/Users/animeshs/R/bin/Rscript.exe proteinGroupsTtestCombine.r L:/promec/TIMSTOF/LARS/2021/November/SIGRID/combined/txtNoNQd/ BiotTestBH.csv
args = commandArgs(trailingOnly=TRUE)
print(paste("supplied argument(s):", length(args)))
print(args)
#if (length(args) != 3) {stop("\n\nNeeds THREE arguments, the full path of the directory containing REPORTS, PATTERN, COLUMN for example: c:/Users/animeshs/R/bin/Rscript.exe proteinGroupsTtestCombine.r L:/promec/TIMSTOF/LARS/2022/februar/Sigrid/combined/txtDQnoPHOS/reports/TS/ BiotTestBH.csv RowGeneUniProtScorePeps", call.=FALSE)}
#data####
inpD <- args[1]
#inpD<-"L:/promec/TIMSTOF/LARS/2021/November/SIGRID/combined/txtNoNQd/TS/"
lGroup <- args[2]
#lGroup<-"0.050.50.05grouptTestBH"
cSel <- args[3]
#cSel<-"RowGeneUniProtScorePeps"
inpF<-list.files(pattern=lGroup,path=inpD,full.names=F,recursive=F)
#combine####
data<-read.csv(paste0(inpD,inpF[1]))
dataC<-data.frame(ID=data[,cSel])
#pdf(paste0(inpD,strsplit(lGroup,'\\.')[[1]][1],"combined.pdf"))
for(inpF in inpF){
    #inpF=inpF[1]
    print(inpF)
    data<-read.csv(paste0(inpD,inpF))
    #hist(data$Log2MedianChange,labels = inpF)
    cName<-gsub("proteinGroups.txtLFQ.intensity.16","",inpF)
    cName<-gsub(lGroup,"",cName)
    cName<-gsub(" ","",cName)
    colnames(data)<-paste0(cName,colnames(data))
    dataC<-merge(dataC,data,by.x="ID",by.y =paste0(cName,cSel),all=T)
}
write.csv(dataC,paste0(inpD,lGroup,"combined.csv"))
#writexl::write_xlsx(dataC,paste0(inpD,lGroup,"combined.xlsx"))
dataS<-dataC[,grep("ID|FoldChanglog2median|CorrectedPValueBH|TtestPval|Log2MedianChange",colnames(dataC))]
dataS["Uniprot"]<-paste(sapply(strsplit(paste(sapply(strsplit(dataS$ID, "|",fixed=T), "[", 2)), "-"), "[", 1))
write.csv(dataS,paste0(inpD,lGroup,"combined.select.csv"))
#writexl::write_xlsx(dataS,paste0(inpD,lGroup,"combined.select.xlsx"))
