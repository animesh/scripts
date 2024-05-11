#Rscript diffExprPlots.r "L:\promec\TIMSTOF\LARS\2023\230310 Sonali\combined\txtNoDN\T test for fertilisation outcome.xlsx"
#setup####
#install.packages("ggplot2")
#install.packages("svglite")
#install.packages("pheatmap")
args = commandArgs(trailingOnly=TRUE)
print(args)
inpF <- args[1]
sizeF<-6
#inpF <-"L:/promec/TIMSTOF/LARS/2023/230310 Sonali/combined/txtNoDN/T test for fertilisation outcome.xlsx"
#OF####
data<-readxl::read_xlsx(inpF,sheet = 1)
data<-data.frame(data)
colnames(data)<-data[1,]
dim(data)
data<-data[-1,]
selection<-"^O"
dataS<-data[,grep(selection,colnames(data))]
dataS<-sapply(dataS,as.numeric)
rownames(dataS)<-data[,1]
range(dataS,na.rm=T)
data_selr_na0=scales::squish(as.matrix(dataS),c(5,30))
summary(data_selr_na0)
dim(data_selr_na0)
svgPHC=pheatmap::pheatmap(data_selr_na0,clustering_distance_rows="euclidean",clustering_distance_cols = "euclidean",cluster_cols=F,cluster_rows=F,fontsize_col=sizeF,fontsize_row=sizeF)
ggplot2::ggsave(file=paste0(inpF,".cluster.",gsub("\\^","",selection),".svg"),plot=svgPHC,width=10,height=10)
write.csv(data_selr_na0,paste0(inpF,".select.",gsub("\\^","",selection),".csv"),row.names = T)
print(selection)
#Oocyte####
data<-readxl::read_xlsx(inpF,sheet = 2)
data<-data.frame(data)
colnames(data)<-data[1,]
dim(data)
data<-data[-1,]
selection<-"^U[0-9]"
dataS<-data[,grep(selection,colnames(data))]
dataS<-sapply(dataS,as.numeric)
rownames(dataS)<-data[,1]
dataS<-dataS[!is.na(data[,1]),]
range(dataS,na.rm=T)
data_selr_na0=scales::squish(as.matrix(dataS),c(5,30))
summary(data_selr_na0)
dim(data_selr_na0)
svgPHC=pheatmap::pheatmap(data_selr_na0,clustering_distance_rows="euclidean",clustering_distance_cols = "euclidean",cluster_cols=F,cluster_rows=F,fontsize_col=sizeF,fontsize_row=sizeF)
ggplot2::ggsave(file=paste0(inpF,".cluster.",gsub("\\^|\\[0-9\\]","",selection),".svg"),plot=svgPHC,width=10,height=10)
write.csv(data_selr_na0,paste0(inpF,".select.",gsub("\\^|\\[0-9\\]","",selection),".csv"),row.names = T)
print(selection)
#EyedEmbryo####
data<-readxl::read_xlsx(inpF,sheet = 3)
data<-data.frame(data)
colnames(data)<-data[1,]
dim(data)
data<-data[-1,]
selection<-"^EP"
dataS<-data[,grep(selection,colnames(data))]
dataS<-sapply(dataS,as.numeric)
rownames(dataS)<-data[,1]
range(dataS,na.rm=T)
data_selr_na0=scales::squish(as.matrix(dataS),c(5,30))
summary(data_selr_na0)
dim(data_selr_na0)
svgPHC=pheatmap::pheatmap(data_selr_na0,clustering_distance_rows="euclidean",clustering_distance_cols = "euclidean",cluster_cols=F,cluster_rows=F,fontsize_col=sizeF,fontsize_row=sizeF)
ggplot2::ggsave(file=paste0(inpF,".cluster.",gsub("\\^","",selection),".svg"),plot=svgPHC,width=10,height=10)
write.csv(data_selr_na0,paste0(inpF,".select.",gsub("\\^","",selection),".csv"),row.names = T)
print(selection)
print(paste("processed sheet from",inpF))
