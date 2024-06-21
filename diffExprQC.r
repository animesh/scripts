#Rscript diffExprQC.r "L:\promec\TIMSTOF\LARS\2023\230310 ChunMei\combined\txt\proteinGroups.txtIntensity.0.110.05BioRemoveGroups.txtAMHCtTestBH.combined.xlsx" Log2MedianChange 10
#setup####
args = commandArgs(trailingOnly=TRUE)
print(paste("supplied argument(s):", length(args)))
inpF <- args[1]
#inpF<-"L:/promec/TIMSTOF/LARS/2023/230310 ChunMei/combined/txt/proteinGroups.txtIntensity.0.110.05BioRemoveGroups.txtAMHCtTestBH.combined.xlsx"
selection <- args[2]
#selection<-"Log2MedianChange"
topN <- args[3]
topN<-as.numeric(topN)
#topN<-10
print(args)
#data####
data<-readxl::read_xlsx(inpF)
#intensity####
dataSel<-data[,grep(selection,colnames(data))]
rownames(dataSel)<-data$RowGeneUniProtScorePeps
colnames(dataSel)<-gsub(selection,"",colnames(dataSel))
dim(dataSel)
#hist((dataSel$BCAMHCLog2MedianChange))
pdf(paste0(inpF,selection,topN,"TopBarPlots.pdf"))
#boxplot(dataSel)
#barplotTopN####
dataSelTopN<-dataSel
dataSelTopN$rN<-rownames(dataSelTopN)
dataSelTopN<-dataSelTopN[order(dataSelTopN$STNTCAMHC,decreasing = TRUE),][c(1:topN,(nrow(dataSelTopN)-topN+1):nrow(dataSelTopN)),]
rN<-dataSelTopN$rN
dataSelTopN<-dataSelTopN[,-grep("rN",colnames(dataSelTopN))]
rownames(dataSelTopN)<-rN
colnames(dataSelTopN)
#barplot(dataSelTopN$SIAMHC,las=2,main="Top 20 up and down regulated proteins",ylab="Log2 Median Change",xlab="Proteins",col=ifelse(dataSelTopN$SIAMHC>0,"orange","darkblue"))
dataSelTopNt<-t(dataSelTopN)
dim(dataSelTopNt)
rownames(dataSelTopNt)
dataSelTopNt <- dataSelTopNt[ order(row.names(dataSelTopNt),decreasing = T), ]
rownames(dataSelTopNt)
colnames(dataSelTopNt)
colnames(dataSelTopNt)<-paste(sapply(strsplit(paste(sapply(strsplit(colnames(dataSelTopNt), "GN=",fixed=T), "[", 2)), ";| "), "[", 1))
colnames(dataSelTopNt)
colours = c("black","yellow","darkred","cyan","darkgreen","orange","violet","grey")
for(i in 1:nrow(dataSelTopNt)){
  barplot(dataSelTopNt[i,],las=2,main=paste0("Top ",topN," up/down Protein-groups in ",row.names(dataSelTopNt)[i]),ylab="Log2 Median Change to AMHC",col=colours[i],ylim=c(min(dataSelTopNt)*1.3,max(dataSelTopNt)*1.3),cex.names = 0.5)
}
barplot(dataSelTopNt,las=2,main=paste0("Top ",topN," up/down Protein-groups"),ylab="Log2 Median Change to AMHC",col=colours,beside=TRUE,ylim=c(min(dataSelTopNt)*1.3,max(dataSelTopNt)*1.3),cex.names = 0.5)
box()
legend('topright',fill=colours,legend=rownames(dataSelTopNt),cex=0.6)
print(paste0(inpF,selection,topN,".plots.pdf"))
dev.off()

