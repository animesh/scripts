#Rscript diffExprPlots.r "C:/Users/animeshs/OneDrive - NTNU/Kristine/proteinGroups.txtLFQ.intensity.11224hT2Arg024hC400Arg0.050.50.05tTestBH.xlsx"
#Rscript diffExprPlots.r "C:/Users/animeshs/OneDrive - NTNU/Kristine/proteinGroups.txtLFQ.intensity.11248hT2Arg048hC400Arg0.050.50.05tTestBH.xlsx"
#setup####
#install.packages("readxl")
#install.packages("svglite")
#install.packages("ggplot2")
args = commandArgs(trailingOnly=TRUE)
inpF <- args[1]
#inpF<-"C:/Users/animeshs/OneDrive - NTNU/Kristine/proteinGroups.txtLFQ.intensity.11224hT2Arg024hC400Arg0.050.50.05tTestBH.xlsx"
selection<-"Slot"
data<-readxl::read_xlsx(inpF,sheet = 1)
data<-data.frame(data)
dim(data)
#data####
dataS<-data[,grep(selection,colnames(data))]
dim(dataS)
log2LFQrem<-sapply(dataS,as.numeric)
summary(log2LFQrem)
dim(log2LFQrem)
range(log2LFQrem,na.rm=T)
log2LFQrem<-log2LFQrem[rowSums(is.na(log2LFQrem)) != ncol(log2LFQrem),]
summary(log2LFQrem)
dim(log2LFQrem)
range(log2LFQrem,na.rm=T)
#PCA####
log2LFQt<-t(log2LFQrem[complete.cases(log2LFQrem),])
row.names(log2LFQt)<-colnames(log2LFQrem)
plot(prcomp(log2LFQt))
log2LFQtPCA<-prcomp(log2LFQt)
write.csv(x = data.frame(log2LFQtPCA$x),file = paste0(inpF,"log2LFQtPCA.csv"))
dflog2LFQtPCA<-data.frame(log2LFQtPCA$x)
rownames(dflog2LFQtPCA)<-gsub("\\.","-",rownames(dflog2LFQtPCA))
rownames(dflog2LFQtPCA)
#label####
label<-data.frame(paste(sapply(strsplit(rownames(dflog2LFQtPCA),"_"), "[", 1)))
rownames(label)<-rownames(dflog2LFQtPCA)
dflog2LFQtPCAlab<-merge(x = dflog2LFQtPCA,y = label,by = 'row.names', all = F)
write.csv(x = dflog2LFQtPCAlab,file = paste0(inpF,"dflog2LFQtPCAlab.csv"))
log2LFQtPCAsumm<-summary(log2LFQtPCA)
write.csv(x = (log2LFQtPCAsumm$importance),file = paste0(inpF,"log2LFQtPCAsummimportance.csv"))
svglite::svglite(paste0(inpF,"log2LFQtPCA12.svg"),width = 12, height = 10)
op <- par(cex = 0.9)
plot(log2LFQtPCA$x[,1], log2LFQtPCA$x[,2], pch = 16, col = factor(rownames(log2LFQt)),xlab = paste0("PC1 (", round(100*log2LFQtPCAsumm$importance[2,1],1), "%)"), ylab = paste0("PC2 (", round(100*log2LFQtPCAsumm$importance[2,2],1), "%)"),main=paste("PCA 1 and 2 with complete-case","\nTotal protein groups", dim(log2LFQt)[2],"across samples",dim(log2LFQt)[1]))
legend("topleft", col = factor(rownames(log2LFQt)), legend = factor(rownames(log2LFQt)), pch = 16)
dev.off()
#PCAimp####
scale=2
set.seed(scale)
boxplot(log2LFQrem)
colnames(log2LFQrem)
log2LFQimp<-matrix(rnorm(dim(log2LFQrem)[1]*dim(log2LFQrem)[2],mean=mean(log2LFQrem,na.rm = T)-scale,sd=sd(log2LFQrem,na.rm = T)/(scale)), dim(log2LFQrem)[1],dim(log2LFQrem)[2])
hist(log2LFQrem)
hist(log2LFQimp)
boxplot(log2LFQimp)
log2LFQimp[log2LFQimp<0]<-0
summary(log2LFQimp)
dataHighNormLog2<-log2LFQimp
dataHighNormLog2[!is.na(log2LFQrem)]<-log2LFQrem[!is.na(log2LFQrem)]
summary(dataHighNormLog2)
hist(dataHighNormLog2)
boxplot(dataHighNormLog2)
log2LFQt<-t(dataHighNormLog2)
row.names(log2LFQt)<-colnames(log2LFQrem)
plot(prcomp(log2LFQt))
log2LFQtPCA<-prcomp(log2LFQt)
write.csv(x = data.frame(log2LFQtPCA$x),file = paste0(inpF,"log2LFQtPCAimp.csv"))
dflog2LFQtPCA<-data.frame(log2LFQtPCA$x)
rownames(dflog2LFQtPCA)<-gsub("\\.","-",rownames(dflog2LFQtPCA))
rownames(dflog2LFQtPCA)
dflog2LFQtPCAlab<-merge(x = dflog2LFQtPCA,y = label,by = 'row.names', all = F)
write.csv(x = dflog2LFQtPCAlab,file = paste0(inpF,"dflog2LFQtPCAimplab.csv"))
log2LFQtPCAsumm<-summary(log2LFQtPCA)
write.csv(x = (log2LFQtPCAsumm$importance),file = paste0(inpF,"log2LFQtPCAimpsummimportance.csv"))
svglite::svglite(paste0(inpF,"log2LFQtPCA12imp.svg"),width = 12, height = 10)
op <- par(cex = 0.8)
plot(log2LFQtPCA$x[,1], log2LFQtPCA$x[,2], pch = 16, col = factor(rownames(log2LFQt)),xlab = paste0("PC1 (", round(100*log2LFQtPCAsumm$importance[2,1],1), "%)"), ylab = paste0("PC2 (", round(100*log2LFQtPCAsumm$importance[2,2],1), "%)"),main=paste("PCA 1/2 with 0 containing proteinGroups imputed scale",scale,"\nProtein groups", dim(log2LFQt)[2],"across samples",dim(log2LFQt)[1]))
legend("topleft", col = factor(rownames(log2LFQt)), legend = factor(rownames(log2LFQt)), pch = 16)
dev.off()


