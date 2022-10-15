#..\R-4.2.1-win\bin\Rscript.exe diffExprTestRank.r L:\promec\TIMSTOF\LARS\2022\july\Elise\combined\txt\proteinGroups.txt L:\promec\TIMSTOF\LARS\2022\july\Elise\combined\txt\Groups.txt Tissue Rem
#setup
#install.packages(c("readxl","writexl","svglite","ggplot2","BiocManager"),repos="http://cran.us.r-project.org",lib=.libPaths())
#BiocManager::install(c("limma","pheatmap"),repos="http://cran.us.r-project.org",lib=.libPaths())
#install.packages("devtools")
#devtools::install_github("jdstorey/qvalue")
print("USAGE:<path to>Rscript diffExprTestRank.r <complete path to directory containing proteinGroups.txt> <Groups.txt file> <name of group column in Groups.txt annotating data/rows to be used for analysis> <name of column in Groups.txt marking data NOT to be considered in analysis>")
args = commandArgs(trailingOnly=TRUE)
print(paste("supplied argument(s):", length(args)))
print(args)
if (length(args) != 4) {stop("\n\nNeeds FOUR arguments, the full path of the directory containing BOTH proteinGroups.txt AND Groups.txt files followed by the name of GROUP-to-compare and data-to-REMOVE columns in Groups.txt file, for example: c:/Users/animeshs/R-4.2.1-win/bin/Rscript.exe diffExprTestRank.r L:/promec/TIMSTOF/LARS/2022/july/Elise/combined/txt/proteinGroups.txt L:/promec/TIMSTOF/LARS/2022/july/Elise/combined/txt/Groups.txt Tissue Rem", call.=FALSE)}
inpF <- args[1]
#inpF <-"L:/promec/TIMSTOF/LARS/2022/july/Elise/combined/txt/proteinGroups.txt"
inpL <- args[2]
#inpL <-"L:/promec/TIMSTOF/LARS/2022/july/Elise/combined/txt/Groups.txt"
lGroup <- args[3]
#lGroup<-"Tissue"
rGroup <- args[4]
#rGroup<-"Rem"
inpD<-dirname(inpF)
fName<-basename(inpF)
lName<-basename(inpL)
selection<-"iBAQ."
thr=0.0#count
selThr=0.05#pValue-WilcoxTest
selThrFC=0.5#log2-MedianDifference
cvThr=0.1#threshold for coefficient-of-variation
hdr<-gsub("[^[:alnum:]]", "",inpD)
outP=paste(inpF,selection,selThr,selThrFC,cvThr,hdr,lGroup,rGroup,lName,"VolcanoTestWilcox","pdf",sep = ".")
pdf(outP)
#data####
data <- read.table(inpF,stringsAsFactors = FALSE, header = TRUE, quote = "", comment.char = "", sep = "\t")
##clean####
#data = data[!data$Reverse=="+",]
#data = data[!data$Potential.contaminant=="+",]
#data = data[!data$Only.identified.by.site=="+",]
row.names(data)<-paste(row.names(data),data$Fasta.headers,data$Protein.IDs,data$Protein.names,data$Gene.names,data$Score,data$Peptide.counts..unique.,sep=";;")
summary(data)
dim(data)
log2Int<-as.matrix(log2(data[,grep("Intensity",colnames(data))]))
log2Int[log2Int==-Inf]=NA
hist(log2Int,main=paste("Mean:",mean(log2Int,na.rm=T),"SD:",sd(log2Int,na.rm=T)),breaks=round(max(log2Int,na.rm=T)),xlim=range(min(log2Int,na.rm=T),max(log2Int,na.rm=T)))
summary(log2(data[,grep("Intensity",colnames(data))]))
par(mar=c(12,3,1,1))
boxplot(log2Int,las=2)
#corHCint####
scale=3
log2Intimp<-matrix(rnorm(dim(log2Int)[1]*dim(log2Int)[2],mean=mean(log2Int,na.rm = T)-scale,sd=sd(log2Int,na.rm = T)/(scale)), dim(log2Int)[1],dim(log2Int)[2])
log2Intimp[log2Intimp<0]<-0
par(mar=c(12,3,1,1))
boxplot(log2Intimp,las=2)
bk1 <- c(seq(-3,-0.01,by=0.01))
bk2 <- c(seq(0.01,3,by=0.01))
bk <- c(bk1,bk2)  #combine the break limits for purpose of graphing
my_palette <- c(colorRampPalette(colors = c("darkblue", "white"))(n = length(bk1)-1),"gray", "gray",c(colorRampPalette(colors = c("white","darkred"))(n = length(bk2)-1)))
colnames(log2Intimp)<-colnames(log2Int)
log2IntimpCorr<-cor(log2Int,use="pairwise.complete.obs",method="spearman")
colnames(log2IntimpCorr)<-colnames(log2Int)
rownames(log2IntimpCorr)<-colnames(log2Int)
svgPHC<-pheatmap::pheatmap(log2IntimpCorr,clustering_distance_rows = "euclidean",clustering_distance_cols = "euclidean",fontsize_row=8,cluster_cols=T,cluster_rows=T,fontsize_col  = 8)
ggplot2::ggsave(paste0(outP,"heatmap.intensity.svg"), svgPHC)
#maxLFQ####
LFQ<-as.matrix(data[,grep(selection,colnames(data))])
LFQ<-LFQ[,2:ncol(LFQ)]
#protNum<-1:ncol(LFQ)
#protNum<-"LFQ intensity"#1:ncol(LFQ)
#colnames(LFQ)=paste(protNum,sub(selection,"",colnames(LFQ)),sep=";")
colnames(LFQ)=sub(selection,"",colnames(LFQ))
dim(LFQ)
log2LFQ<-log2(LFQ)
log2LFQ[log2LFQ==-Inf]=NA
log2LFQ[log2LFQ==0]=NA
summary(log2LFQ)
hist(log2LFQ,main=paste("Mean:",mean(log2LFQ,na.rm=T),"SD:",sd(log2LFQ,na.rm=T)),breaks=round(max(log2Int,na.rm=T)),xlim=range(min(log2Int,na.rm=T),max(log2Int,na.rm=T)))
par(mar=c(12,3,1,1))
boxplot(log2LFQ,las=2)
rowName<-paste(sapply(strsplit(paste(sapply(strsplit(data$Fasta.headers, "|",fixed=T), "[", 2)), "-"), "[", 1))
writexl::write_xlsx(as.data.frame(cbind(rowName,log2LFQ,rownames(data))),paste0(inpD,"log2LFQ.xlsx"))
data$geneName<-paste(sapply(strsplit(paste(sapply(strsplit(data$Gene.names, ";",fixed=T), "[", 1)), " "), "[", 1))
data$uniprotID<-paste(sapply(strsplit(paste(sapply(strsplit(data$Protein.IDs, ";",fixed=T), "[", 1)), "-"), "[", 1))
data[data$geneName=="NA","geneName"]=data[data$geneName=="NA","uniprotID"]
#corHClfq####
log2LFQimp<-matrix(rnorm(dim(log2LFQ)[1]*dim(log2LFQ)[2],mean=mean(log2LFQ,na.rm = T)-scale,sd=sd(log2LFQ,na.rm = T)/(scale)), dim(log2LFQ)[1],dim(log2LFQ)[2])
log2LFQimp[log2LFQimp<0]<-0
par(mar=c(12,3,1,1))
boxplot(log2LFQimp,las=2)
colnames(log2LFQimp)<-colnames(log2LFQ)
log2LFQimpCorr<-cor(log2LFQ,use="pairwise.complete.obs",method="spearman")
colnames(log2LFQimpCorr)<-colnames(log2LFQ)
rownames(log2LFQimpCorr)<-colnames(log2LFQ)
svgPHC<-pheatmap::pheatmap(log2LFQimpCorr,clustering_distance_rows = "euclidean",clustering_distance_cols = "euclidean",fontsize_row=8,cluster_cols=T,cluster_rows=T,fontsize_col  = 8)
ggplot2::ggsave(paste0(outP,"heatmap.iBAQ.svg"), svgPHC)
#label####
label<-read.table(inpL,header=T,sep="\t",row.names=1)#, colClasses=c(rep("factor",3)))
rownames(label)=sub(selection,"",rownames(label))
label["pair2test"]<-label[lGroup]
if(rGroup %in% colnames(label)){label["removed"]<-label[rGroup]} else{label["removed"]=NA}
print(label)
#table(label$Tissue)
#minmaxScale####
colnames(log2LFQ)
log2LFQsel=log2LFQ[,gsub("-",".",rownames(label[is.na(label$removed)|label$removed==" "|label$removed=='',]))]
summary(log2LFQsel)
maxM=matrix(rep(apply(log2LFQsel,2,function(x) max(x,na.rm=T)),each=nrow(log2LFQsel)),nrow=nrow(log2LFQsel),ncol=ncol(log2LFQsel))
minM=matrix(rep(apply(log2LFQsel,2,function(x) min(x,na.rm=T)),each=nrow(log2LFQsel)),nrow=nrow(log2LFQsel),ncol=ncol(log2LFQsel))
log2LFQselScale=(log2LFQsel-minM)/(maxM-minM)
write.csv(log2LFQselScale,paste0(inpF,".minmax.csv"))
#corHCminmax####
hist(log2LFQselScale)
log2LFQselScaleimp<-matrix(rnorm(dim(log2LFQselScale)[1]*dim(log2LFQselScale)[2],mean=mean(log2LFQselScale,na.rm = T)-scale,sd=sd(log2LFQselScale,na.rm = T)/(scale)), dim(log2LFQselScale)[1],dim(log2LFQselScale)[2])
hist(log2LFQselScaleimp)
par(mar=c(12,3,1,1))
boxplot(log2LFQselScaleimp,las=2)
#log2LFQselScaleimp[log2LFQselScaleimp<0]<-0
#colnames(log2LFQselScaleimp)<-colnames(log2LFQselScale)
log2LFQselScaleimpCorr<-cor(log2LFQselScale,use="pairwise.complete.obs",method="spearman")
hist(log2LFQselScaleimpCorr)
colnames(log2LFQselScaleimpCorr)<-colnames(log2LFQselScale)
rownames(log2LFQselScaleimpCorr)<-colnames(log2LFQselScale)
svgPHC<-pheatmap::pheatmap(log2LFQselScaleimpCorr,clustering_distance_rows = "euclidean",clustering_distance_cols = "euclidean",fontsize_row=8,cluster_cols=T,cluster_rows=T,fontsize_col  = 8)
ggplot2::ggsave(paste0(outP,"heatmap.iBAQminmax.svg"), svgPHC)
#test####
testWilcox <- function(log2LFQ,sel1,sel2,cvThr){
  #sel1<-"PIN"
  #sel2<-"PNI"#HGcancer"
  #log2LFQ<-log2LFQselScale#[,gsub("-",".",rownames(label[label$Remove!="Y",]))]
  #hist(log2LFQ)
  #log2LFQ<-sapply(log2LFQ, as.numeric)
  #colnames(log2LFQ)
  d1<-data.frame(log2LFQ[,gsub("-",".",rownames(label[label$pair2test==sel1,]))])
  rNd1<-rownames(d1)
  d1<-sapply(d1, as.numeric)
  rownames(d1)<-rNd1
  colnames(d1)<-rownames(label[label$pair2test==sel1,])
  d2<-data.frame(log2LFQ[,gsub("-",".",rownames(label[label$pair2test==sel2,]))])
  rNd2<-rownames(d2)
  d2<-sapply(d2, as.numeric)
  rownames(d2)<-rNd2
  colnames(d2)<-rownames(label[label$pair2test==sel2,])
  dataSellog2grpwilcoxTest<-as.matrix(cbind(d1,d2))
  if(sum(!is.na(d1))>1&sum(!is.na(d2))>1){
    hist(d1)
    hist(d2)
    #assign(paste0("hda",sel1,sel2),dataSellog2grpwilcoxTest)
    #get(paste0("hda",sel1,sel2))
    dataSellog2grpwilcoxTest[dataSellog2grpwilcoxTest==0]=NA
    hist(dataSellog2grpwilcoxTest)
    row.names(dataSellog2grpwilcoxTest)<-row.names(data)
    comp<-paste0(sel1,sel2)
    sCol<-1
    eCol<-ncol(dataSellog2grpwilcoxTest)
    mCol<-ncol(d1)#ceiling((eCol-sCol+1)/2)
    dim(dataSellog2grpwilcoxTest)
    options(nwarnings = 1000000)
    pValNA = apply(
      dataSellog2grpwilcoxTest, 1, function(x)
        if(sum(!is.na(x[c(sCol:mCol)]))<2&sum(!is.na(x[c((mCol+1):eCol)]))<2){NA}
      else if(sum(is.na(x[c(sCol:mCol)]))==0&sum(is.na(x[c((mCol+1):eCol)]))==0){
        wilcox.test(as.numeric(x[c(sCol:mCol)]),as.numeric(x[c((mCol+1):eCol)]),alternative = "two.sided",exact = FALSE, correct = FALSE,na.rm=T)$p.value}
      else if(sum(!is.na(x[c(sCol:mCol)]))>1&sum(!is.na(x[c((mCol+1):eCol)]))<1&(sd(x[c(sCol:mCol)],na.rm=T)/mean(x[c(sCol:mCol)],na.rm=T))<cvThr){0}
      else if(sum(!is.na(x[c(sCol:mCol)]))<1&sum(!is.na(x[c((mCol+1):eCol)]))>1&(sd(x[c((mCol+1):eCol)],na.rm=T)/mean(x[c((mCol+1):eCol)],na.rm=T))<cvThr){0}
      else if(sum(!is.na(x[c(sCol:mCol)]))>=2&sum(!is.na(x[c((mCol+1):eCol)]))>=1){
        wilcox.test(as.numeric(x[c(sCol:mCol)]),as.numeric(x[c((mCol+1):eCol)]),na.rm=T,alternative = "two.sided",exact = FALSE, correct = FALSE,na.rm=T)$p.value}
      else if(sum(!is.na(x[c(sCol:mCol)]))>=1&sum(!is.na(x[c((mCol+1):eCol)]))>=2){
        wilcox.test(as.numeric(x[c(sCol:mCol)]),as.numeric(x[c((mCol+1):eCol)]),na.rm=T,alternative = "two.sided",exact = FALSE, correct = FALSE,na.rm=T)$p.value}
      else{NA}
    )
    summary(warnings())
    summary(pValNA)
    if(sum(is.na(pValNA))==nrow(dataSellog2grpwilcoxTest)){pValNA[is.na(pValNA)]=1}
    hist(pValNA)
    dfpValNA<-as.data.frame(ceiling(pValNA))
    pValNAdm<-cbind(pValNA,dataSellog2grpwilcoxTest,row.names(data))
    pValNAminusLog10 = -log10(pValNA+.Machine$double.xmin)
    hist(pValNAminusLog10)
    library(scales)
    pValNAminusLog10=squish(pValNAminusLog10,c(0,5))
    hist(pValNAminusLog10)
    length(pValNA)-(sum(is.na(pValNA))+sum(ceiling(pValNA)==0,na.rm = T))
    pValBHna = p.adjust(pValNA,method = "BH")
    hist(pValBHna)
    pValBHnaMinusLog10 = -log10(pValBHna+.Machine$double.xmin)
    hist(pValBHnaMinusLog10)
    logFCmedianGrp1=if(is.null(dim(dataSellog2grpwilcoxTest[,c(sCol:mCol)]))){dataSellog2grpwilcoxTest[,c(sCol:mCol)]} else{apply(dataSellog2grpwilcoxTest[,c(sCol:mCol)],1,function(x) median(x,na.rm=T))}
    grp1CV=if(is.null(dim(dataSellog2grpwilcoxTest[,c(sCol:mCol)]))){dataSellog2grpwilcoxTest[,c(sCol:mCol)]} else{apply(dataSellog2grpwilcoxTest[,c(sCol:mCol)],1,function(x) sd(x,na.rm=T)/mean(x,na.rm=T))}
    #summary(logFCmedianGrp11-logFCmedianGrp1)
    logFCmedianGrp2=if(is.null(dim(dataSellog2grpwilcoxTest[,c((mCol+1):eCol)]))){dataSellog2grpwilcoxTest[,c((mCol+1):eCol)]} else{apply(dataSellog2grpwilcoxTest[,c((mCol+1):eCol)],1,function(x) median(x,na.rm=T))}
    grp2CV=if(is.null(dim(dataSellog2grpwilcoxTest[,c((mCol+1):eCol)]))){dataSellog2grpwilcoxTest[,c((mCol+1):eCol)]} else{apply(dataSellog2grpwilcoxTest[,c((mCol+1):eCol)],1,function(x) sd(x,na.rm=T)/mean(x,na.rm=T))}
    logFCmedianGrp1[is.na(logFCmedianGrp1)]=0
    logFCmedianGrp2[is.na(logFCmedianGrp2)]=0
    hda<-cbind(logFCmedianGrp1,logFCmedianGrp2)
    plot(hda)
    limma::vennDiagram(hda>0)
    logFCmedian = logFCmedianGrp1-logFCmedianGrp2
    logFCmedianFC = 2^(logFCmedian+.Machine$double.xmin)
    logFCmedianFC=squish(logFCmedianFC,c(0.01,100))
    hist(logFCmedianFC)
    log2FCmedianFC=log2(logFCmedianFC)
    hist(log2FCmedianFC)
    wilcoxTest.results = data.frame(Uniprot=rowName,Gene=data$Gene.names,Protein=data$Protein.names,logFCmedianGrp1,logFCmedianGrp2,PValueMinusLog10=pValNAminusLog10,FoldChanglog2median=logFCmedianFC,CorrectedPValueBH=pValBHna,WilcoxTestPval=pValNA,dataSellog2grpwilcoxTest,Log2MedianChange=logFCmedian,grp1CV,grp2CV,RowGeneUniProtScorePeps=rownames(dataSellog2grpwilcoxTest))
    writexl::write_xlsx(wilcoxTest.results,paste0(inpF,selection,sCol,eCol,comp,selThr,selThrFC,cvThr,lGroup,rGroup,lName,"WilcoxTestBH.xlsx"))
    write.csv(wilcoxTest.results,paste0(inpF,selection,sCol,eCol,comp,selThr,selThrFC,cvThr,lGroup,rGroup,lName,"WilcoxTestBH.csv"),row.names = F)
    wilcoxTest.results.return<-wilcoxTest.results
    #volcano
    wilcoxTest.results$RowGeneUniProtScorePeps<-data$geneName
    wilcoxTest.results[is.na(wilcoxTest.results)]=selThr
    Significance=wilcoxTest.results$CorrectedPValueBH<selThr&wilcoxTest.results$CorrectedPValueBH>0&abs(wilcoxTest.results$Log2MedianChange)>selThrFC
    sum(Significance)
    dsub <- subset(wilcoxTest.results,Significance)
    p <- ggplot2::ggplot(wilcoxTest.results,ggplot2::aes(Log2MedianChange,PValueMinusLog10))+ ggplot2::geom_point(ggplot2::aes(color=Significance))
    p<-p + ggplot2::theme_bw(base_size=8) + ggplot2::geom_text(data=dsub,ggplot2::aes(label=RowGeneUniProtScorePeps),hjust=0, vjust=0,size=1,position=ggplot2::position_jitter(width=0.5,height=0.1)) + ggplot2::scale_fill_gradient(low="white", high="darkblue") + ggplot2::xlab("Log2 Median Change") + ggplot2::ylab("-Log10 P-value")
    #f=paste(file,proc.time()[3],".jpg")
    #install.packages("svglite")
    ggplot2::ggsave(paste0(inpF,selection,sCol,eCol,comp,selThr,selThrFC,cvThr,lGroup,rGroup,lName,"VolcanoTestWilcox.svg"), p)
    print(p)
    return(wilcoxTest.results.return)
  }
}
#compare####
summary(log2LFQselScale)
colnames(log2LFQselScale)
dim(log2LFQselScale)
hist(log2LFQselScale)
wilcox.test(seq(1,4),seq(5,9))
wilcox.test(seq(0.1,0.4,0.1),seq(0.5,0.9,0.1))
wilcox.test(c(0.266527699,0.284150421,0.298255709),c(0.418783725,0.393943028,0.456900289,0.45373957,0.332984375),alternative = "two.sided",exact = FALSE, correct = FALSE,na.rm=T)
tmparr=log2LFQsel[1,1:ncol(log2LFQselScale)]
tmparr=log2LFQselScale[1,1:ncol(log2LFQselScale)]
wilcox.test(tmparr[1:ncol(log2LFQsel)/2],tmparr[ncol(log2LFQsel)/2+1:ncol(log2LFQsel)],alternative = "two.sided",exact = FALSE, correct = FALSE,na.rm=T)
label=label[is.na(label$removed)|label$removed==" "|label$removed=='',]
table(label$pair2test)
cnt=0
for(i in 1:length(rownames(table(label$pair2test)))){
  cnt=cnt+1
  i=rownames(table(label$pair2test))[cnt]
  j=rownames(table(label$pair2test))[-cnt]
  print(paste(i,j))
  rtPair=testWilcox(log2LFQselScale,i,j,cvThr)
  #assign(paste0(i,j),ttPair)
}
