#Rscript proteinGroupsQC.r "L:/promec/TIMSTOF/LARS/2023/230310 ChunMei/combined/txt/proteinGroups.txt" "Intensity." "L:/promec/Animesh/Mathilde/Groups.xlsx" "sample"
#mkdir -p /home/animeshs/promec/promec/TIMSTOF/LARS/2023/230310\ ChunMei/combined/txt
#rsync -Parv  ash022@login.nird-lmd.sigma2.no:TIMSTOF/LARS/2023/230310\\\ ChunMei/combined/txt/proteinGroups.txt /home/animeshs/promec/promec/TIMSTOF/LARS/2023/230310\ ChunMei/combined/txt/.
#setup####
args = commandArgs(trailingOnly=TRUE)
print(paste("supplied argument(s):", length(args)))
inpF <- args[1]
#inpF<-"L:/promec/TIMSTOF/LARS/2023/230310 ChunMei/combined/txt/proteinGroups.txt"
selection <- args[2]
#selection<-"Intensity."
labelF <- args[3]
#labelF <-"L:/promec/Animesh/Mathilde/Groups.xlsx"
lGroup <- args[4]
#lGroup<-"sample"
print(args)
#data####
data<-read.table(inpF,header = T,sep = "\t",quote = "")
#https://www.nature.com/articles/s41597-024-03355-4#Sec8
jpeg(paste0(inpF,"F1D.jpg"))
range(data$Sequence.coverage....)
#hist(data$Sequence.coverage....)
dataCovClip50<-scales::squish(data$Sequence.coverage....,c(0,50))
#hist(dataCovClip50,xlim=c(0,50),main="Sequence coverage",xlab="Sequence coverage",ylab="Frequency")
range(dataCovClip50)
dataCovClip50Bin6<-cut(dataCovClip50, breaks =6)
dataCovClip50Bin6T<-table(dataCovClip50Bin6)
levels(dataCovClip50Bin6)<-paste(c("0-10","10-20","20-30","30-40","40-50",">50"),rep("[",6),round(100*dataCovClip50Bin6T/sum(dataCovClip50Bin6T),2),rep("%",6),rep("]",6))
pie(table(dataCovClip50Bin6),main="Sequence coverage")
dev.off()
print(paste0(inpF,"plots.pdf"))
#hist(dataCovClip50,xlim=c(0,50),main="Sequence coverage",xlab="Sequence coverage",ylab="Frequency")
pdf(paste0(inpF,"plots.pdf"))
#intensity####
intdata<-data[,grep(selection,colnames(data))]
log2Int<-as.matrix(log2(intdata))
dim(log2Int)
log2Int[log2Int==-Inf]=NA
hist(log2Int,main=paste("Mean:",mean(log2Int,na.rm=T),"SD:",sd(log2Int,na.rm=T)),breaks=round(max(log2Int,na.rm=T)),xlim=range(min(log2Int,na.rm=T),max(log2Int,na.rm=T)))
colnames(log2Int)<-gsub(selection,"",colnames(log2Int))
summary(log2Int)
#label####
labelD<-basename(labelF)
label <- readxl::read_xlsx(labelF)
head(label)
anno<-data.frame((label[,lGroup]))
names(anno)<-lGroup
rownames(anno)<-gsub("s","S",label$raw.file)
head(anno)
anno<-anno[order(anno[,lGroup]),,drop=FALSE]
head(anno)
table(anno)
#corHCint####
colnames(log2Int)
log2IntCorr<-log2Int[,rownames(anno)]
log2IntimpCorr<-cor(log2IntCorr,use="pairwise.complete.obs",method="pearson")
colnames(log2IntimpCorr)<-colnames(log2IntCorr)
rownames(log2IntimpCorr)<-colnames(log2IntCorr)
bk1 <- c(seq(-1,-0.01,by=0.01))
bk2 <- c(seq(0.01,1,by=0.01))
bk <- c(bk1,bk2)  #combine the break limits for purpose of graphing
palette <- c(colorRampPalette(colors = c("yellow", "orange"))(n = length(bk1)-1),"orange", "orange",c(colorRampPalette(colors = c("orange","red"))(n = length(bk2)-1)))
svgPHC<-pheatmap::pheatmap(log2IntimpCorr,color=palette,fontsize_row=6,fontsize_col=6,annotation_row=anno,annotation_col=anno,cluster_cols=F,cluster_rows=F,)#,clustering_distance_rows= "euclidean",clustering_distance_cols="euclidean")
ggplot2::ggsave(paste0(inpF,selection,labelD,lGroup,"log2IntimpCorr.heatmap.svg"),plot=svgPHC,width=10,height=8)
write.csv(log2IntimpCorr,paste0(inpF,selection,"log2IntimpCorr.log2.csv"))
print(paste0(inpF,selection,labelD,lGroup,"log2IntimpCorr.heatmap.svg"))
#violin####
#boxplot(log2IntCorr,main=paste("Mean:",mean(log2IntCorr,na.rm=T),"SD:",sd(log2IntCorr,na.rm=T)),col=(factor(anno$sample)))
log2IntCorrStack<-stack(data.frame(log2IntCorr))
table(log2IntCorrStack$ind)
anno$ind<-paste0("X",rownames(anno))
log2IntCorrStackM<-merge(log2IntCorrStack,anno,by="ind",all=T)
colnames(log2IntCorrStackM)
#,colnames(log2IntCorr))#,direction="wide")
#ggplot2::ggplot(log2IntCorr, ggplot2::aes(log2IntCorr[,1])) + ggplot2::geom_violin()# + ggplot2::geom_boxplot(width=0.2)
violinP<-ggplot2::ggplot(log2IntCorrStackM, ggplot2::aes(y=values,x=ind,fill=sample)) + ggplot2::geom_violin() + ggplot2::geom_boxplot(width=0.1) + ggplot2::xlab("Sample") + ggplot2::ylab("log2 Intensity") + ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 90, hjust = 1))
violinP
ggplot2::ggsave(paste0(inpF,selection,labelD,lGroup,"log2IntimpCorr.violin.svg"),plot=violinP,width=10,height=8)
print(paste0(inpF,selection,labelD,lGroup,"log2IntimpCorr.violin.svg"))
#PCA####
scale=2
set.seed(scale)
log2LFQrem<-scale(log2IntCorr)
boxplot(log2LFQrem)
hist(log2LFQrem)
log2LFQimp<-matrix(rnorm(dim(log2LFQrem)[1]*dim(log2LFQrem)[2],mean=mean(log2LFQrem,na.rm = T)-scale,sd=sd(log2LFQrem,na.rm = T)/(scale)), dim(log2LFQrem)[1],dim(log2LFQrem)[2])
hist(log2LFQimp)
boxplot(log2LFQimp)
#log2LFQimp[log2LFQimp<0]<-0
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
write.csv(x = data.frame(log2LFQtPCA$x),file = paste0(inpF,"log2LFQtPCA.csv"))
dflog2LFQtPCA<-data.frame(log2LFQtPCA$x)
#rownames(dflog2LFQtPCA)<-gsub("\\.","-",rownames(dflog2LFQtPCA))
rownames(dflog2LFQtPCA)
rownames(anno)
dflog2LFQtPCAlab<-merge(x = dflog2LFQtPCA,y = anno,by = 'row.names', all = T)
write.csv(x = dflog2LFQtPCAlab,file = paste0(inpF,selection,labelD,lGroup,scale,"dflog2LFQtPCAlab.csv"))
log2LFQtPCAsumm<-summary(log2LFQtPCA)
write.csv(x = (log2LFQtPCAsumm$importance),file = paste0(inpF,selection,labelD,lGroup,scale,"log2LFQtPCAsummimportance.csv"))
plot(log2LFQtPCA$x[,1], log2LFQtPCA$x[,2], pch = 16, col = factor(rownames(log2LFQt)),xlab = paste0("PC1 (", round(100*log2LFQtPCAsumm$importance[2,1],1), "%)"), ylab = paste0("PC2 (", round(100*log2LFQtPCAsumm$importance[2,2],1), "%)"),main=paste("PCA 1/2 with 0 containing proteinGroups imputed scale",scale,"\nProtein groups", dim(log2LFQt)[2],"across samples",dim(log2LFQt)[1]))
legend("topleft", col = factor(rownames(log2LFQt)), legend = factor(rownames(log2LFQt)), pch = 16)
dev.off()
print(paste0(inpF,"plots.pdf"))
png(paste0(inpF,selection,labelD,lGroup,scale,".log2LFQtPCA.png"),width=1024, height=800,res=150)
plot(log2LFQtPCA$x[,1], log2LFQtPCA$x[,2], pch = 16, col = factor(anno[,lGroup]),xlab = paste0("PC1 (", round(100*log2LFQtPCAsumm$importance[2,1],1), "%)"), ylab = paste0("PC2 (", round(100*log2LFQtPCAsumm$importance[2,2],1), "%)"),main=paste("PCA 1/2 with 0 containing proteinGroups imputed scale",scale,"\nProtein groups", dim(log2LFQt)[2],"across samples",dim(log2LFQt)[1]))
legend("bottomright", col = unique(factor(anno[,lGroup])), legend = levels(factor(anno[,lGroup])), pch = 16, cex = 0.7)
dev.off()
print(paste0(inpF,selection,labelD,lGroup,scale,".log2LFQtPCA.png"))
