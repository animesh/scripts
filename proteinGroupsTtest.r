#https://github.com/cox-labs/PerseusR ; on windows if "Error in utils::download.file(url, path, method = method, quiet = quiet,  :cannot open URL 'https://api.github.com/repos/cox-labs/PerseusR/tarball/HEAD'"
#options(download.file.method = "wininet")
#install.packages("devtools")
#devtools::install_github("cox-labs/PerseusR")
#script: C:\Users\animeshs\GD\scripts\proteinGroupsTtest.r
#R: C:\MR-4.0.2\bin\x64\Rscript.exe
library(PerseusR)
args = commandArgs(trailingOnly=TRUE)
if (length(args) != 2) {stop("NOTE: NaN imputed with 0 AND using midpoint to separate main matrix into two groups, DONT supply any argument(s)!", call.=FALSE)}
inFile <- args[1]
outFile <- args[2]
#mCol <- args[3]
mdata <- read.perseus(inFile)
#Samples<-mdata@annotRows$Samples
#Uniprot<-paste(mdata@annotCols$FASTA.Title.Lines)
dataSellog2grpTtest <- main(mdata)
sCol<-1
eCol<-ncol(dataSellog2grpTtest)
mCol <- ceiling((eCol-sCol)/2)
#outMdata <- matrixData(main=dataSellog2grpTtest[,1:mCol])
#inFile<-"C:/Users/animeshs/GD/scripts/matrix.txt"
#outFile<-"C:/Users/animeshs/GD/scripts/matrix.out"

dim(dataSellog2grpTtest)
options(nwarnings = 1000000)
mdata@imputeData[is.na(dataSellog2grpTtest)]="True"
dataSellog2grpTtest[is.na(dataSellog2grpTtest)]<-0
#dataSellog2grpTtest<-dataSellog2grpTtest[complete.cases(dataSellog2grpTtest),]
#samples<-mdata@annotRows$Grouping
samples<-t(mdata@annotRows[ncol(mdata@annotRows)])
#library(PerseusR)
args = commandArgs(trailingOnly=TRUE)
if (length(args) != 2) {stop("Using the separating column index of middle point as integer argument!", call.=FALSE)}
pValNA = apply(
  dataSellog2grpTtest, 1, function(x)
    if(sum(!is.na(x[c(sCol:mCol)]))<2&sum(!is.na(x[c((mCol+1):eCol)]))<2){1}
  else if(sum(is.na(x[c(sCol:mCol)]))==0&sum(is.na(x[c((mCol+1):eCol)]))==0){
    t.test(as.numeric(x[c(sCol:mCol)]),as.numeric(x[c((mCol+1):eCol)]),na.rm=T,var.equal=T)$p.value}
  else if(sum(!is.na(x[c(sCol:mCol)]))>1&sum(!is.na(x[c((mCol+1):eCol)]))<1){0}
  else if(sum(!is.na(x[c(sCol:mCol)]))<1&sum(!is.na(x[c((mCol+1):eCol)]))>1){0}
  else if(sum(!is.na(x[c(sCol:mCol)]))==1&sum(!is.na(x[c((mCol+1):eCol)]))>1){
    t.test(as.numeric(x[c(sCol:mCol)]),as.numeric(x[c((mCol+1):eCol)]),na.rm=T,var.equal=T)$p.value}
  else if(sum(!is.na(x[c(sCol:mCol)]))>1&sum(!is.na(x[c((mCol+1):eCol)]))==1){
    t.test(as.numeric(x[c(sCol:mCol)]),as.numeric(x[c((mCol+1):eCol)]),na.rm=T,var.equal=T)$p.value}
  else{1}
)
summary(warnings())
hist(pValNA)
pValNAdm<-cbind(pValNA,dataSellog2grpTtest,row.names(dataSellog2grpTtest))
pValNAminusLog10 = -log10(pValNA+.Machine$double.xmin)
hist(pValNAminusLog10)
pValBHna = p.adjust(pValNA,method = "BH")
hist(pValBHna)
pValBHnaMinusLog10 = -log10(pValBHna+.Machine$double.xmin)
hist(pValBHnaMinusLog10)
dataSellog2grpTtestNum<-apply(dataSellog2grpTtest, 2,as.numeric)
logFCmedianGrp1 = apply(
  dataSellog2grpTtest, 1, function(x)
    median(x[c(sCol:mCol)],na.rm=T)    )
hist(logFCmedianGrp1)
logFCmedianGrp2 = apply(
  dataSellog2grpTtest, 1, function(x)
    median(x[c(mCol+1:eCol)],na.rm=T)    )
hist(logFCmedianGrp2)
logFCmedianGrp1[is.nan(logFCmedianGrp1)]=0
logFCmedianGrp2[is.nan(logFCmedianGrp2)]=0
logFCmedian = logFCmedianGrp1-logFCmedianGrp2
logFCmedianFC = 2^(logFCmedian+.Machine$double.xmin)
hist(logFCmedianFC)
log2FCmedianFC=log2(logFCmedianFC)
hist(log2FCmedianFC)
ttest.results = data.frame(dataSellog2grpTtest,Log2MedianChange=logFCmedian,PValueMinusLog10=pValNAminusLog10,FoldChanglog2median=logFCmedianFC,CorrectedPValueBH=pValBHna,TtestPval=pValNA,Row=rownames(dataSellog2grpTtest))
dfTest=data.frame(matrix("tesT", nrow = (ncol(ttest.results)-ncol(dataSellog2grpTtest)), ncol = ncol(mdata@annotRows)))
colnames(dfTest)=colnames(mdata@annotRows)
dfTest=rbind(mdata@annotRows,dfTest)
write.perseus(ttest.results, outFile,imputeData=mdata@imputeData,qualityData = mdata@qualityData,annotCols=mdata@annotCols,annotRows=dfTest)
