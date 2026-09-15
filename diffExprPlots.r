#Rscript diffExprPlots.r "L:/promec/Animesh/Kamila/Help_with_poster_for_Eadv_conference/BCC_PRM90_final for LARS.xlsx" 0.5 0.5 Gene
#setup####
#install.packages("readxl")
#install.packages("svglite")
#install.packages("ggplot2")
args = commandArgs(trailingOnly=TRUE)
inpW <- args[1]
#inpW<-"L:/promec/Animesh/Kamila/Help_with_poster_for_Eadv_conference/BCC_PRM90_final for LARS.xlsx"
selThr <- args[2]
#selThr<-0.5
selThrFC<-args[3]
#selThrFC<-0.5
labelS <- args[4]
#labelS<-"Gene"
print(args)
#data####
data<-readxl::read_xlsx(inpW,sheet=1)
data<-data.frame(data)
data[,"ID"]<-data[,labelS]
#volcano
#data[is.na(data)] <- 0
#data[,grep("FC",colnames(data))]<-log2(data[,grep("FC",colnames(data))])
plot(data[,"Tumor_FC"],data[,"Stroma_FC"])
data[,"log2Stroma_FC"]<-log2(data[,"Stroma_FC"])
data[,"log10Stroma_padj"]<-log10(data[,"Stroma_padj"])*(-1)
significance=data$Stroma_padj<selThr&abs(data$log2Stroma_FC)>selThrFC
sum(significance,na.rm=TRUE)
dsub <- subset(data,significance)
p <- ggplot2::ggplot(data,ggplot2::aes(log2Stroma_FC,log10Stroma_padj))+ ggplot2::geom_point(ggplot2::aes(color=significance))
p<-p + ggplot2::theme_bw(base_size=8) + ggplot2::geom_text(data=dsub,ggplot2::aes(label=ID),hjust=0, vjust=0,size=1,position=ggplot2::position_jitter(width=0.5,height=0.1)) + ggplot2::scale_fill_gradient(low="white", high="darkblue") + ggplot2::xlab("Log2 Median Change") + ggplot2::ylab("-Log10 P-value") + ggplot2::xlim(-15, 15) + ggplot2::ylim(.Machine$double.eps,4.99999999999999)
#f=paste(file,proc.time()[3],".jpg")
#install.packages("svglite")
ggplot2::ggsave(paste0(inpW,selThr,selThrFC,labelS,".Stroma.VolcanoTest.svg"),width=10, height=8,dpi=300, p)
print(p)
data[,"log2Tumor_FC"]<-log2(data[,"Tumor_FC"])
data[,"log10Tumor_padj"]<-log10(data[,"Tumor_padj"])*(-1)
significance=data$Tumor_padj<selThr&abs(data$log2Tumor_FC)>selThrFC
sum(significance,na.rm=TRUE)
dsub <- subset(data,significance)
p <- ggplot2::ggplot(data,ggplot2::aes(log2Tumor_FC,log10Tumor_padj))+ ggplot2::geom_point(ggplot2::aes(color=significance))
p<-p + ggplot2::theme_bw(base_size=8) + ggplot2::geom_text(data=dsub,ggplot2::aes(label=ID),hjust=0, vjust=0,size=1,position=ggplot2::position_jitter(width=0.5,height=0.1)) + ggplot2::scale_fill_gradient(low="white", high="darkblue") + ggplot2::xlab("Log2 Median Change") + ggplot2::ylab("-Log10 P-value") + ggplot2::xlim(-15, 15) + ggplot2::ylim(.Machine$double.eps,4.99999999999999)
#f=paste(file,proc.time()[3],".jpg")
#install.packages("svglite")
ggplot2::ggsave(paste0(inpW,selThr,selThrFC,labelS,".Tumor.VolcanoTest.svg"),width=10, height=8,dpi=300, p)
print(p)
