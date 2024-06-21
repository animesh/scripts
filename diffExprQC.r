#Rscript diffExprQC.r "L:\promec\TIMSTOF\LARS\2023\230310 ChunMei\combined\txt\proteinGroups.txtIntensity.0.110.05BioRemoveGroups.txtAMHCtTestBH.combined.xlsx" Log2MedianChange "L:\promec\TIMSTOF\LARS\2023\230310 ChunMei\combined\txt\Exosome and ion channel proteins.csv" "Exosome..1276."
#setup####
args = commandArgs(trailingOnly=TRUE)
print(paste("supplied argument(s):", length(args)))
inpF <- args[1]
#inpF<-"L:/promec/TIMSTOF/LARS/2023/230310 ChunMei/combined/txt/proteinGroups.txtIntensity.0.110.05BioRemoveGroups.txtAMHCtTestBH.combined.xlsx"
selection <- args[2]
#selection<-"Log2MedianChange"
selectN <- args[3]
#selectN <-"L:/promec/TIMSTOF/LARS/2023/230310 ChunMei/combined/txt/Exosome and ion channel proteins.csv"
colN <- args[4]
#colN<-"Ion.channel..220."
print(args)
#selection####
list<-read.csv(selectN,header = T,sep = ";")
summary(list)
listCheck<-data.frame(toupper(unique(list[,colN])))
colnames(listCheck)<-colN
print(table(listCheck))
#plot####
pdf(paste0(inpF,selection,basename(selectN),colN,"selectBarPlots.pdf"))
#data####
data<-readxl::read_xlsx(inpF)
#intensity####
dataSel<-data[,grep(selection,colnames(data))]
#hist((dataSel$BCAMHCLog2MedianChange))
colnames(dataSel)<-gsub(selection,"",colnames(dataSel))
#boxplot(dataSel)
dim(dataSel)
dataSel[,colN]<-toupper(paste(sapply(strsplit(paste(sapply(strsplit(data$RowGeneUniProtScorePeps, "GN=",fixed=T), "[", 2)), ";| "), "[", 1)))
dim(dataSel)
#barplotselectN####
dataSelN<-merge(listCheck,dataSel,by=colN)
write.csv(dataSelN,paste0(inpF,selection,basename(selectN),colN,"selectData.csv"))
dataSelNt<-t(dataSelN[,-grep(colN,colnames(dataSelN))])
dim(dataSelNt)
rownames(dataSelNt)
dataSelNt <- dataSelNt[ order(row.names(dataSelNt),decreasing = T), ]
rownames(dataSelNt)
colnames(dataSelNt)
colnames(dataSelNt)<-dataSelN[,grep(colN,colnames(dataSelN))]
#dataSelNt<-dataSelNt[-grep(colN,row.names(dataSelNt)),]
#dataSelNt<-data.frame(apply(dataSelNt, 2, function(x) as.numeric(as.character(x))))
#boxplot(dataSelNt)
colnames(dataSelNt)
colours = c("black","yellow","darkred","cyan","darkgreen","orange","violet","grey")
for(i in 1:nrow(dataSelNt)){
  barplot(dataSelNt[i,],las=2,main=paste0(basename(selectN),"\nselect ",colN," Protein-groups ",row.names(dataSelNt)[i]),ylab="Log2 Median Change to AMHC",col=colours[i],ylim=c(min(dataSelNt)*1.3,max(dataSelNt)*1.3),cex.names = 0.5)
}
barplot(dataSelNt,las=2,main=paste0(basename(selectN),"\nselect ",colN," Protein-groups"),ylab="Log2 Median Change to AMHC",col=colours,beside=TRUE,ylim=c(min(dataSelNt)*1.3,max(dataSelNt)*1.3),cex.names = 0.5)
box()
legend('topright',fill=colours,legend=rownames(dataSelNt),cex=0.5)
print(paste0(inpF,selection,basename(selectN),colN,"selectBarPlots.pdf"))
dev.off()

