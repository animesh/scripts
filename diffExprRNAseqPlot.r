#F:\R-4.3.1\bin\Rscript.exe diffExprRNAseqPlot.r "F:\seqRNA\count.thread6.txt"
#setup####
args = commandArgs(trailingOnly=TRUE)
if (length(args) != 1) {stop("USAGE:<path to Rscript.exe> diffExprRNAseqPlot.r <complete path to counts file>
                             example:
                             F:\\R-4.3.1\\bin\\Rscript.exe diffExprRNAseqPlot.r \"F:\\OneDrive - NTNU\\TK\\mergeHISAT\\subread.1697973662.results\\Homo_sapiens.GRCh38.110.30.count.txt\"")}
print(paste("supplied argument(s):", length(args)))
inpF<-args[1]
print(args)
#inpF<-"F:/seqRNA/count.thread6.txt"
colName<-1
colChr<-2
colStart<-3
colStrand<-5
colLen<-6
colSample<-7
#data####
countTable = read.table(inpF,header=TRUE,comment.char = "#")
numSample<-length(countTable)
print(paste("colName","colChr","colStart","colStrand","colLen","colSample","Total"))
paramName<-paste(colName,colChr,colStart,colStrand,colLen,colSample,numSample-colSample+1,sep=".")
print(paramName)
#pdf####
hdr<-gsub("[^[:alnum:]]", "",inpF)
outP=paste(inpF,hdr,paramName,"pdf",sep = ".")
pdf(outP)
#columns####
print(colnames(countTable))
colNum<-1:length(colnames(countTable))
colnames(countTable)<-paste(sapply(strsplit(colnames(countTable),"\\."), "[", length(strsplit(colnames(countTable),"\\.")[[colSample]])-2),colNum,sep=".")
print(paste("changed to",colnames(countTable)))
print(summary(countTable[,colSample:numSample]))
#hist((countTable[,colSample:numSample]))
#hist(as.matrix(countTable[,colSample:numSample]))
#log2Length####
countTable[countTable==0]=NA
countTable$rowLog2Length<-log2(countTable[,colLen])
hist(countTable$rowLog2Length)
print(summary(countTable$rowLog2Length))
#minMaxLog2Length####
countTable$rowMinMaxLength<-(countTable$rowLog2Length-min(countTable$rowLog2Length))/(max(countTable$rowLog2Length)-min(countTable$rowLog2Length))
hist(countTable$rowMinMaxLength)
#startPos####
countTable$rowStart<-as.numeric(paste(sapply(strsplit(paste(sapply(strsplit(countTable[,colStart], ";",fixed=T), "[", 1)), " "), "[", 1)))
hist(countTable$rowStart)
print(summary(countTable$rowStart))
#strand####
countTable$rowStrand<-paste(sapply(strsplit(paste(sapply(strsplit(countTable[,colStrand], ";",fixed=T), "[", 1)), " "), "[", 1))
print(table(countTable$rowStrand))
#chromosome####
countTable$rowChr<-paste(sapply(strsplit(paste(sapply(strsplit(countTable[,colChr], ";",fixed=T), "[", 1)), " "), "[", 1))
print(table(countTable$rowChr))
#log2data####
log2data<-countTable
log2data[,colSample:numSample]<-log2((log2data[,colSample:numSample]+1))
log2data[log2data==-Inf]<-NA
print(summary(log2data[,colSample:numSample]))
#hist((log2data[,colSample:numSample]))
boxplot(log2data[,colSample:numSample],las=2,main="log2data",ylab="log2(count+1)")
#mirrorDataStrandPlot####
mirrorDataStrand<-log2data
#mirrorDataStrand<-countTable
#mirrorDataStrand[,colSample:numSample]=with(mirrorDataStrand, ifelse(rowStrand=="-", -mirrorDataStrand[,colSample:numSample], mirrorDataStrand[,colSample:numSample]))
for(i in rownames(table(countTable$rowChr))){
  if(sum(!is.na(mirrorDataStrand[mirrorDataStrand[,"rowChr"]==i,colSample:numSample]))>0){
    print(paste("Chr",i))
    #print(summary(mirrorDataStrand[mirrorDataStrand[,"rowChr"]==i,colSample:numSample]))
    print(summary(mirrorDataStrand[mirrorDataStrand[,"rowChr"]==i,"rowStart"]))
  #}
#}
    #minMirror<-min(mirrorDataStrand[mirrorDataStrand[,"rowChr"]==i,colSample:numSample],na.rm=T)
    maxMirror<-max(mirrorDataStrand[mirrorDataStrand[,"rowChr"]==i,colSample:numSample],na.rm=T)
    maxMirrorPos<-max(mirrorDataStrand[mirrorDataStrand[,"rowChr"]==i,"rowStart"],na.rm=T)
    minMirrorPos<-min(mirrorDataStrand[mirrorDataStrand[,"rowChr"]==i,"rowStart"],na.rm=T)
    #boxplot(data.matrix(mirrorDataStrand[mirrorDataStrand[,"rowChr"]==i,colSample:numSample]),las=2,main=paste("Chr Log2Counts",i))
    #hist(mirrorDataStrand[mirrorDataStrand[,"rowChr"]==i,"rowStart"],main=paste("Chr Length",i),xlab = "Position",ylab = "Frequency")
    for(j in colnames(mirrorDataStrand[,colSample:numSample])){
      if(sum(!is.na(mirrorDataStrand[mirrorDataStrand[,"rowChr"]==i,j]))>0){
        print(paste(i,j))
        #i="13"
        #j="TK12_R1_.10"
        mirrorDataStrand[mirrorDataStrand[,"rowChr"]==i&mirrorDataStrand[,"rowStrand"]=="-",j]=mirrorDataStrand[mirrorDataStrand[,"rowChr"]==i&mirrorDataStrand[,"rowStrand"]=="-",j]*(-1)
        #mirrorDataStrand[,j]=with(mirrorDataStrand, ifelse(rowStrand=="-", mirrorDataStrand[,j]*(-1), mirrorDataStrand[,j]))
        print(summary(mirrorDataStrand[mirrorDataStrand[,"rowChr"]==i,j]))
        #hist(mirrorDataStrand[mirrorDataStrand[,"rowChr"]==i,j],breaks=100,main=paste("Chr",i,"Sample",j),xlab = "log2(count+1)",ylab = "Frequency",xlim=c(floor(-maxMirror),ceiling(maxMirror)))
        plot(mirrorDataStrand[mirrorDataStrand[,"rowChr"]==i,"rowStart"],mirrorDataStrand[mirrorDataStrand[,"rowChr"]==i,j],pch=16,col=gray(mirrorDataStrand[,"rowMinMaxLength"]),main=paste("Chr",i,"Sample",j),xlab = "Position",ylab = "log2(count+1)",ylim=c(floor(-maxMirror),ceiling(maxMirror)),,xlim=c(floor(minMirrorPos),ceiling(maxMirrorPos)))
        #ttPair=testT(log2LFQsel,i,j,cvThr)
        #print(ttPair)
      }
    }
  }
}
#countTableChr13<-countTable[countTable$rowChr=="13",]
#countTableChr13$X.cluster.projects.nn9036k.scripts.TK.mergeHISAT.TK12_R3_.sort.bam <- with(countTableChr13, ifelse(rowStrand=="-", -X.cluster.projects.nn9036k.scripts.TK.mergeHISAT.TK12_R3_.sort.bam, X.cluster.projects.nn9036k.scripts.TK.mergeHISAT.TK12_R3_.sort.bam))
#index <- mydata$Var1 <= 1
#countTableChr13[countTableChr13$rowStrand=="-","X.cluster.projects.nn9036k.scripts.TK.mergeHISAT.TK12_R3_.sort.bam"]=countTableChr13[countTableChr13$rowStrand=="-","X.cluster.projects.nn9036k.scripts.TK.mergeHISAT.TK12_R3_.sort.bam"]*(-1)
#plot(countTableChr13$rowStart,log2(countTableChr13$X.cluster.projects.nn9036k.scripts.TK.mergeHISAT.TK12_R3_.sort.bam))
#plot(countTableChr13$rowStart,countTableChr13$X.cluster.projects.nn9036k.scripts.TK.mergeHISAT.TK12_R3_.sort.bam,,pch=16,col=gray(countTableChr13$rowMinMaxLength))
#countTableChr13<-countTable[countTable$rowChr=="13",]
#summary(countTableChr13)
#countTableChr13$X.cluster.projects.nn9036k.scripts.TK.mergeHISAT.TK9_1L5_R.sort.bam <- with(countTableChr13, ifelse(rowStrand=="-", -X.cluster.projects.nn9036k.scripts.TK.mergeHISAT.TK9_1L5_R.sort.bam, X.cluster.projects.nn9036k.scripts.TK.mergeHISAT.TK9_1L5_R.sort.bam))
#summary(countTableChr13)
#index <- mydata$Var1 <= 1
#countTableChr13[countTableChr13$rowStrand=="-","X.cluster.projects.nn9036k.scripts.TK.mergeHISAT.TK12_R3_.sort.bam"]=countTableChr13[countTableChr13$rowStrand=="-","X.cluster.projects.nn9036k.scripts.TK.mergeHISAT.TK12_R3_.sort.bam"]*(-1)
#plot(countTableChr13$rowStart,log2(countTableChr13$X.cluster.projects.nn9036k.scripts.TK.mergeHISAT.TK12_R3_.sort.bam))
#plot(countTableChr13$rowStart,countTableChr13$X.cluster.projects.nn9036k.scripts.TK.mergeHISAT.TK9_1L5_R.sort.bam,,pch=16,col=gray(countTableChr13$rowMinMaxLength))
#countTableSelLog2lenStartStrand<-merge(countTableSelLog2,countTableLen[,c("rowLength","rowStart","rowStrand")],by="row.names")
#countTableSel=countTable[,grep("TK",colnames(countTable))]
#colnames(countTableSel)
#colnames(countTableSel)=gsub("X.cluster.projects.nn9036k.scripts.TK.mergeHISAT.","",colnames(countTableSel))
#colnames(countTableSel)
#colnames(countTableSel)=gsub(".sort.bam","",colnames(countTableSel))
#colnames(countTableSel)
#hist(sapply(countTableSel,as.numeric))
#par(mar=c(12,3,1,1))
#boxplot(countTableSel,las=2,main="countTableSel")
#countTableSelLog2=log2(countTableSel)
#countTableSelLog2[countTableSelLog2==-Inf]=NA
#summary(countTableSelLog2)
#min(countTableSelLog2,na.rm=T)
#max(countTableSelLog2,na.rm=T)
#hist(sapply(countTableSelLog2,as.numeric),breaks=100)
#par(mar=c(12,3,1,1))
#boxplot(countTableSelLog2,las=2,main="countTableSelLog2")
#countTableLen<-countTable[,grep("row",colnames(countTable))]
#hist(countTable$Length)
#countTableSelLog2NA0<-countTableSelLog2lenStartStrand
#countTableSelLog2NA0[is.na(countTableSelLog2NA0)]=0.0
#summary(countTableSelLog2NA0)
#countTableSelLog2Chr12<-countTableSelLog2NA0[countTableSelLog2NA0$rowStrand=='+',]
#plot(countTableSelLog2Chr12$rowStart,countTableSelLog2Chr12$TK12_R3_,col=gray(countTableSelLog2Chr12))
#output####
write.csv(mirrorDataStrand,file=paste(inpF,hdr,"mirrorDataStrand",paramName,"csv",sep="."))
