#Rscript diffExprPlots.r "L:/promec/Animesh/Sigrid/Hierarchical clustering/Pasientceller mut vs wt uten beh til publ.xlsx" 0.05 0.5
#Rscript diffExprPlots.r "L:/promec/Animesh/Sigrid/Hierarchical clustering/Pasientceller mut vs wt uten beh til publ.xlsx" 0.05 0.5 Gene # for labeling points with Gene names
#setup####
#install.packages("readxl")
#install.packages("svglite")
#install.packages("ggplot2")
args = commandArgs(trailingOnly=TRUE)
inpW <- args[1]
#inpW<-"L:/promec/Animesh/Sigrid/Hierarchical clustering/Pasientceller mut vs wt uten beh til publ.xlsx"
selThr <- args[2]
#selThr<-0.05
selThrFC<-args[3]
#selThrFC<-0.5
labelS <- args[4]
#labelS<-"Gene"
print(args)
#data####
data<-readxl::read_xlsx(inpW)
data<-data.frame(data)
#volcano
data[is.na(data)] <- 0
selThr<-0.05
Significance=data$CorrectedPValueBH<selThr&data$CorrectedPValueBH>0&abs(data$Log2MedianChange)>selThrFC
sum(Significance)
dsub <- subset(data,Significance)
p <- ggplot2::ggplot(data,ggplot2::aes(Log2MedianChange,PValueMinusLog10))+ ggplot2::geom_point(ggplot2::aes(color=Significance))
p<-p + ggplot2::theme_bw(base_size=8) + ggplot2::geom_text(data=dsub,ggplot2::aes(label=labelS),hjust=0, vjust=0,size=1,position=ggplot2::position_jitter(width=0.5,height=0.1)) + ggplot2::scale_fill_gradient(low="white", high="darkblue") + ggplot2::xlab("Log2 Median Change") + ggplot2::ylab("-Log10 P-value") + ggplot2::xlim(-15, 15) + ggplot2::ylim(.Machine$double.eps,4.99999999999999)
#f=paste(file,proc.time()[3],".jpg")
#install.packages("svglite")
ggplot2::ggsave(paste0(inpW,selThr,selThrFC,labelS,"VolcanoTest.svg"),width=10, height=8,dpi=300, p)
print(p)
