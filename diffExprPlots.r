#Rscript diffExprPlots.r "L:\promec\TIMSTOF\LARS\2023\230310 Sonali\combined\txtNoDN\Proteomics_LFQ for heatmaps.xlsx" 3 "Eyed egg" 1 1 "^EP[0-9]" 6 10 10 3
#Rscript diffExprPlots.r "L:\promec\TIMSTOF\LARS\2023\230310 Sonali\combined\txtNoDN\Proteomics_LFQ for heatmaps.xlsx" 2 "Oocyte" 1 1 "^O[0-9]" 6 3 10 3
#Rscript diffExprPlots.r "L:\promec\TIMSTOF\LARS\2023\230310 Sonali\combined\txtNoDN\Proteomics_LFQ for heatmaps.xlsx" 1 "Ovarian fluid" 1 1 "^OF[0-9]" 6 10 10 3
#setup####
#install.packages("ggplot2")
#install.packages("svglite")
#install.packages("pheatmap")
args = commandArgs(trailingOnly=TRUE)
print(args)
inpF <- args[1]
#inpF <-"L:/promec/TIMSTOF/LARS/2023/230310 Sonali/combined/txtNoDN/Protein vs fertilisation.xlsx"
inpS <- args[2]
#inpS <- 2
inpN <- args[3]
#inpN <- "Oo"
inpR <- args[4]
inpR <- as.numeric(inpR)
#inpR <- 1
inpC <- args[5]
inpC <- as.numeric(inpC)
#inpC <- 1
selection<-args[6]
#selection<-"^U[0-9]"
sizeF<-args[7]
#sizeF<-6
sizeH<-args[8]
#sizeH<-10
sizeW<-args[9]
#sizeW<-10
scale<-args[10]
scale<-as.numeric(scale)
#scale<-3
#data####
data<-readxl::read_xlsx(inpF,sheet = as.numeric(inpS))
data<-data.frame(data)
if(inpC>1){
  colnames(data)<-data[inpC,]
  data<-data[-inpC,]
}
dim(data)
#data####
dataS<-data[,grep(selection,colnames(data))]
#dataS<-data.frame(sapply(dataS,as.numeric))
if(inpR>0){
  rownames(dataS)<-data[,inpR]
} else {
  rownames(dataS)<-paste0("row",seq(1,nrow(dataS)))
}
range(dataS,na.rm=T)
#heatmap####
svgPHC=pheatmap::pheatmap(dataS,clustering_distance_rows="euclidean",clustering_distance_cols = "euclidean",cluster_cols=F,cluster_rows=F,fontsize_col=as.numeric(sizeF),fontsize_row=as.numeric(sizeF),main=paste("File",basename(inpF),"Sheet",inpN))
ggplot2::ggsave(file=paste0(inpF,inpS,inpN,"ID",colnames(data)[inpR],inpC,".heatmap.",gsub("\\^|\\[0-9\\]","",selection),"Font",sizeF,"H",sizeH,"W",sizeW,".svg"),plot=svgPHC,width=as.numeric(sizeW),height=as.numeric(sizeH))
ggplot2::ggsave(file=paste0(inpF,inpS,inpN,"ID",colnames(data)[inpR],inpC,".heatmap.",gsub("\\^|\\[0-9\\]","",selection),"Font",sizeF,"H",sizeH,"W",sizeW,".jpg"),plot=svgPHC,width=as.numeric(sizeW),height=as.numeric(sizeH))
write.csv(dataS,paste0(inpF,inpS,inpN,"ID",colnames(data)[inpR],inpC,".select.",gsub("\\^|\\[0-9\\]","",selection),".csv"),row.names = T)
#https://promova.com/english-vocabulary/list-of-colors
bk1 <- c(seq((-1)*(scale),-0.01,by=0.01))
bk2 <- c(seq(0.01,scale,by=0.01))
bk <- c(bk1,bk2)  #combine the break limits for purpose of graphing
palette <- c(colorRampPalette(colors = c("skyblue", "white"))(n = length(bk1)-1),"white", "white",c(colorRampPalette(colors = c("white","orange"))(n = length(bk2)-1)))
data_selr_na0<-(dataS-apply(dataS,1,median,na.rm=T))/(apply(dataS,1,sd,na.rm=T))
data_selr_na0=scales::squish(as.matrix(data_selr_na0),c((-1)*(scale),scale))
summary(data_selr_na0)
dim(data_selr_na0)
svgPHC=pheatmap::pheatmap(data_selr_na0,clustering_distance_rows="euclidean",clustering_distance_cols = "euclidean",cluster_cols=F,cluster_rows=F,fontsize_col=as.numeric(sizeF),fontsize_row=as.numeric(sizeF),main=paste("File",basename(inpF),"Sheet",inpN),color = palette)
ggplot2::ggsave(file=paste0(inpF,inpS,inpN,"ID",colnames(data)[inpR],inpC,"scale",scale,".heatmap.",gsub("\\^|\\[0-9\\]","",selection),"Font",sizeF,"H",sizeH,"W",sizeW,".svg"),plot=svgPHC,width=as.numeric(sizeW),height=as.numeric(sizeH))
ggplot2::ggsave(file=paste0(inpF,inpS,inpN,"ID",colnames(data)[inpR],inpC,"scale",scale,".heatmap.",gsub("\\^|\\[0-9\\]","",selection),"Font",sizeF,"H",sizeH,"W",sizeW,".jpg"),plot=svgPHC,width=as.numeric(sizeW),height=as.numeric(sizeH))
write.csv(data_selr_na0,paste0(inpF,inpS,inpN,"ID",colnames(data)[inpR],inpC,"scale",scale,".select.",gsub("\\^|\\[0-9\\]","",selection),".csv"),row.names = T)
print(paste("processed sheet",inpS,inpN,inpF,"ID",colnames(data)[inpR],inpC,"Font",sizeF,"H",sizeH,"W",sizeW,"scale",scale))
print(selection)



