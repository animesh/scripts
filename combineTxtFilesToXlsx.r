#F:\R-4.3.1\bin\Rscript.exe combineTxtFilesToXlsx.r "L:\promec\USERS\Alessandro\230130_Alessandro_35_samples\m16lfqClassic - Copy" proteinGroups.txtLFQ.intensity.18 BeadRemGroups.txttTestBH.csv
#F:\R-4.3.1\bin\Rscript.exe diffExprTestT.r "L:\promec\USERS\Alessandro\230130_Alessandro_35_samples\m16lfqClassic - Copy\proteinGroups.txt" "L:\promec\USERS\Alessandro\230130_Alessandro_35_samples\m16lfqClassic - Copy\Groups.txt" "Bead" "Rem"
args = commandArgs(trailingOnly=TRUE)
print(paste("supplied argument(s):", length(args)))
print(args)
inpD <- args[1]
#inpD<-"L:\\promec\\USERS\\Alessandro\\230130_Alessandro_35_samples\\m16lfqClassic - Copy"
filePrefix <- args[2]
#filePrefix<-"proteinGroups.txtLFQ.intensity.18"
fileSuffix <- args[3]
#fileSuffix<-"BeadRemGroups.txttTestBH.csv"
inpFL<-list.files(pattern=filePrefix,path=inpD,full.names=F,recursive=F)
inpFL<-inpFL[grepl(fileSuffix,inpFL)]
print(inpFL)
dfMZ1<-0
sheets<-list()
library(writexl)
for(inpF in inpFL){
    #inpF<-inpFL[1]
    print(inpF)
    data<-read.csv(paste(inpD,inpF,sep="\\"))
    sheets<-append(sheets,list(data))
    MZ1<-data$RowGeneUniProtScorePeps
    dfMZ1<-union(dfMZ1,MZ1)
    colnames(data)<-paste0(colnames(data),inpF)
    #hist(log2(as.numeric(data[,4])))
    data$RowGeneUniProtScorePeps<-MZ1
    assign(inpF,data)
}
length(dfMZ1)
summary(warnings())
summary(MZ1)
#sheets <- list(data,data) #assume sheet1 and sheet2 are data frames
inpFL<-gsub(fileSuffix,"",inpFL)
inpFL<-gsub(filePrefix,"",inpFL)
print(inpFL)
#names(sheets)<-inpFL[1]
names(sheets)<-inpFL
write_xlsx(sheets, paste(inpD,paste0(filePrefix,fileSuffix,".combined.xlsx"),sep="\\"))
length(sheets)
