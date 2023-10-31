#F:\R-4.3.1\bin\Rscript.exe diffExprTestRank.r "L:\promec\TIMSTOF\LARS\2023\230526 ROLF\combined\txt\proteinGroups.txt" "L:\promec\TIMSTOF\LARS\2023\230526 ROLF\combined\txt\Groups.txt" "LFQ.intensity." "Infection" "Fish" "Remove"
#F:\R-4.3.1\bin\Rscript.exe diffExprTestRank.r "L:\promec\TIMSTOF\LARS\2023\230526 ROLF\combined\txt\proteinGroups.txt" "L:\promec\TIMSTOF\LARS\2023\230526 ROLF\combined\txt\Groups.txt" "LFQ.intensity." "Gender" "Fish" "Remove"
#setup####
#install.packages(c("readxl","writexl","svglite","ggplot2","BiocManager"),repos="http://cran.us.r-project.org",lib=.libPaths())
#BiocManager::install(c("limma","pheatmap"),repos="http://cran.us.r-project.org",lib=.libPaths())
#install.packages("devtools")
#devtools::install_github("jdstorey/qvalue")
print("USAGE:<path to>Rscript diffExprTestRank.r <complete path to directory containing proteinGroups.txt> <Groups.txt file> <name of group column in Groups.txt annotating data/rows to be used for analysis> <name of column in Groups.txt marking data NOT to be considered in analysis>")
args = commandArgs(trailingOnly=TRUE)
print(paste("supplied argument(s):", length(args)))
print(args)
if (length(args) != 6) {stop("\n\nNeeds SIX arguments, the full path of the directory containing BOTH proteinGroups.txt AND Groups.txt files followed by the name column to use for LFQ, GROUP-to-compare, column to correct for, and data-to-REMOVE columns in Groups.txt file, for example: c:/Users/animeshs/R-4.2.1-win/bin/Rscript.exe diffExprTestRank.r L:/promec/TIMSTOF/LARS/2022/july/Elise/combined/txt/proteinGroups.txt L:/promec/TIMSTOF/LARS/2022/july/Elise/combined/txt/corrected_order.txt LFQ.intensity. Tissue Ratio Rem", call.=FALSE)}
#args####
inpF <- args[1]
#inpF <-"L:/promec/TIMSTOF/LARS/2023/230526 ROLF/combined/txt/proteinGroups.txt"
inpL <- args[2]
#inpL <-"L:/promec/TIMSTOF/LARS/2023/230526 ROLF/combined/txt/Groups.txt"
selection<-args[3]
#selection<-"LFQ.intensity."
lGroup <- args[4]
#lGroup<-"Infection"
scaleF <- args[5]
#scaleF<-"Fish"
rGroup <- args[6]
#rGroup<-"Remove"
inpD<-dirname(inpF)
fName<-basename(inpF)
lName<-basename(inpL)
thr=0.0#count
selThr=0.1#pValue-WilcoxTest
selThrFC=0.1#log2-MedianDifference
cvThr=Inf#threshold for coefficient-of-variation
hdr<-gsub("[^[:alnum:]]", "",inpD)
outP=paste(inpF,selection,selThr,selThrFC,cvThr,hdr,lGroup,rGroup,lName,"VolcanoTestWilcox","pdf",sep = ".")
pdf(outP)
#label####
label<-read.csv(inpL,header=T,sep="\t",row.names=1)#, colClasses=c(rep("factor",3)))
rownames(label)<-gsub("-", ".",rownames(label))
#cor(label$cell.number/label$cur.area,label$ratio.correction.factor)
rownames(label)=sub(selection,"",rownames(label))
label["pair2test"]<-label[lGroup]
if(rGroup %in% colnames(label)){label["removed"]<-label[rGroup]} else{label["removed"]=NA}
label[label[lGroup]=="","removed"]<-"R"
print(label)
table(label["removed"])
table(label[lGroup])
table(label[label["removed"]!="R",lGroup])
rownames(label)
annoFactor<-label[lGroup]
names(annoFactor)<-lGroup
anno<-data.frame(factor(label[,lGroup]))
row.names(anno)<-rownames(label)
names(anno)<-lGroup
table(anno)
annoR<-data.frame(factor(annoFactor[rownames(label[is.na(label$removed)|label$removed==" "|label$removed=='',]),]))
row.names(annoR)<-rownames(label[is.na(label$removed)|label$removed==" "|label$removed=='',])
names(annoR)<-lGroup
summary(annoR)
#data####
data <- read.table(inpF,stringsAsFactors = FALSE, header = TRUE, quote = "", comment.char = "", sep = "\t")
##clean###
#data = data[!data$Reverse=="+",]
#data = data[!data$Potential.contaminant=="+",]
#data = data[!data$Only.identified.by.site=="+",]
row.names(data)<-paste(row.names(data),data$Fasta.headers,data$Score,data$Peptide.counts..unique.,sep=";;")
data$geneName<-paste(sapply(strsplit(paste(sapply(strsplit(data$Fasta.headers, "GN=",fixed=T), "[", 2)), " "), "[", 1))
data$uniprotID<-paste(sapply(strsplit(paste(sapply(strsplit(data$Fasta.headers, "|",fixed=T), "[", 2)), "-"), "[", 1))
data[data$geneName=="NA","geneName"]=data[data$geneName=="NA","uniprotID"]
summary(data)
dim(data)
#clusIntensity####
log2Int<-as.matrix(log2(data[,grep("Intensity",colnames(data))]))
log2Int[log2Int==-Inf]=NA
colnames(log2Int)=sub(selection,"",colnames(log2Int))
hist(log2Int,main=paste("Mean:",mean(log2Int,na.rm=T),"SD:",sd(log2Int,na.rm=T)),breaks=round(max(log2Int,na.rm=T)),xlim=range(min(log2Int,na.rm=T),max(log2Int,na.rm=T)))
summary(log2(data[,grep("Intensity",colnames(data))]))
par(mar=c(12,3,1,1))
boxplot(log2Int,las=2,main="Log2Intensity")
#corHCint####
scale=3
log2Intimp<-matrix(rnorm(dim(log2Int)[1]*dim(log2Int)[2],mean=mean(log2Int,na.rm = T)-scale,sd=sd(log2Int,na.rm = T)/(scale)), dim(log2Int)[1],dim(log2Int)[2])
log2Intimp[log2Intimp<0]<-0
par(mar=c(12,3,1,1))
boxplot(log2Intimp,las=2,main="Imputed log2Intensity")
bk1 <- c(seq(-3,-0.01,by=0.01))
bk2 <- c(seq(0.01,3,by=0.01))
bk <- c(bk1,bk2)  #combine the break limits for purpose of graphing
my_palette <- c(colorRampPalette(colors = c("darkblue", "white"))(n = length(bk1)-1),"gray", "gray",c(colorRampPalette(colors = c("white","darkred"))(n = length(bk2)-1)))
colnames(log2Intimp)<-colnames(log2Int)
log2IntimpCorr<-cor(log2Int,use="pairwise.complete.obs",method="pearson")
colnames(log2IntimpCorr)<-gsub("Intensity.","",colnames(log2Int))
rownames(log2IntimpCorr)<-gsub("Intensity.","",colnames(log2Int))
summary(log2IntimpCorr)
hist(log2IntimpCorr)
svgPHC<-pheatmap::pheatmap(log2IntimpCorr,annotation_row = anno, annotation_col = anno,clustering_distance_rows = "euclidean",clustering_distance_cols = "euclidean",fontsize_row=4,cluster_cols=T,cluster_rows=T,fontsize_col=4)
ggplot2::ggsave(paste0(inpF,lName,lGroup,"Intensity",".heatmap.log2.pearson.svg"), svgPHC)
log2IntimpCorr<-cor(log2Int,use="pairwise.complete.obs",method="spearman")
colnames(log2IntimpCorr)<-gsub("Intensity.","",colnames(log2Int))
rownames(log2IntimpCorr)<-gsub("Intensity.","",colnames(log2Int))
summary(log2IntimpCorr)
hist(log2IntimpCorr)
svgPHC<-pheatmap::pheatmap(log2IntimpCorr,annotation_row = anno, annotation_col = anno,clustering_distance_rows = "euclidean",clustering_distance_cols = "euclidean",fontsize_row=4,cluster_cols=T,cluster_rows=T,fontsize_col=4)
ggplot2::ggsave(paste0(inpF,lName,lGroup,"Intensity",".heatmap.log2.spearman.svg"), svgPHC)
#medianScale####
medianScale <- function(log2LFQsel) {
  #log2LFQsel<-log2LFQ
  #https://stats.stackexchange.com/a/134239
  quart <- function(x) {
    x <- sort(x)
    n <- length(x)
    m <- (n+1)/2
    if (floor(m) != m) {
      l <- m-1/2; u <- m+1/2
    } else {
      l <- m-1; u <- m+1
    }
    c(Q1=median(x[1:l],na.rm=T), Q3=median(x[u:n],na.rm=T))
  }
  q3M=matrix(rep(apply(log2LFQsel,2,function(x) quart(x)[2]),each=nrow(log2LFQsel)),nrow=nrow(log2LFQsel),ncol=ncol(log2LFQsel))
  hist(q3M)
  q1M=matrix(rep(apply(log2LFQsel,2,function(x) quart(x)[1]),each=nrow(log2LFQsel)),nrow=nrow(log2LFQsel),ncol=ncol(log2LFQsel))
  hist(q1M)
  q2M=matrix(rep(apply(log2LFQsel,2,function(x) median(x,na.rm=T)),each=nrow(log2LFQsel)),nrow=nrow(log2LFQsel),ncol=ncol(log2LFQsel))
  hist(q2M)
  log2LFQselScale=(log2LFQsel-q2M)/(q3M-q1M)
  return(log2LFQselScale)
}
#quartScale####
quartScale <- function(log2LFQsel) {
  q3M=matrix(rep(apply(log2LFQsel,2,function(x) quantile(x,na.rm=T)[4]),each=nrow(log2LFQsel)),nrow=nrow(log2LFQsel),ncol=ncol(log2LFQsel))
  hist(q3M)
  q1M=matrix(rep(apply(log2LFQsel,2,function(x) quantile(x,na.rm=T)[2]),each=nrow(log2LFQsel)),nrow=nrow(log2LFQsel),ncol=ncol(log2LFQsel))
  hist(q1M)
  q2M=matrix(rep(apply(log2LFQsel,2,function(x) median(x,na.rm=T)),each=nrow(log2LFQsel)),nrow=nrow(log2LFQsel),ncol=ncol(log2LFQsel))
  hist(q2M)
  log2LFQselScale=(log2LFQsel-q2M)/(q3M-q1M)
  return(log2LFQselScale)
}
#scaleSD####
scaleSD <- function(log2LFQselScaleSD) {
  #log2LFQselScaleSD<-log2LFQselScale
  ratioFactor<-apply(log2LFQselScaleSD, 2,sd, na.rm = TRUE)
  names(ratioFactor)
  colnames(log2LFQselScaleSD)
  ratioFactor[colnames(log2LFQselScaleSD)[1]]
  hist(ratioFactor)
  summary(ratioFactor)
  for(i in colnames(log2LFQselScaleSD)){
    print(i)
    print(ratioFactor[i])
    print(summary(log2LFQselScaleSD[,i]))
    print(summary(log2LFQselScaleSD[,i]/ratioFactor[i]))
    log2LFQselScaleSD[,i]<-log2LFQselScaleSD[,i]/ratioFactor[i]
    print(summary(log2LFQselScaleSD[,i]))
  }
  return(log2LFQselScaleSD)
}
#minmaxScale####
minmaxScale <- function(log2LFQsel) {
  summary(log2LFQsel)
  maxM=matrix(rep(apply(log2LFQsel,2,function(x) max(x,na.rm=T)),each=nrow(log2LFQsel)),nrow=nrow(log2LFQsel),ncol=ncol(log2LFQsel))
  minM=matrix(rep(apply(log2LFQsel,2,function(x) min(x,na.rm=T)),each=nrow(log2LFQsel)),nrow=nrow(log2LFQsel),ncol=ncol(log2LFQsel))
  log2LFQselScale=(log2LFQsel-minM)/(maxM-minM)
  return(log2LFQselScale)
}
#medianScaleF####
medianScaleF <- function(log2LFQ){
  colnames(log2LFQ)
  rownames(label)
  table(label[,scaleF])
  medianLog2LFQ <- data.frame(matrix(ncol=length(names(table(label[,scaleF]))),nrow=nrow(log2LFQ)))
  colnames(medianLog2LFQ) <- names(table(label[,scaleF]))
  rownames(medianLog2LFQ)<-rownames(log2LFQ)
  for(i in names(table(label[,scaleF]))){
    #print(i)
    log2LFQvals<-log2LFQ[,gsub("-",".",rownames(label[label[,scaleF]==i,]))]
    #print(summary(log2LFQvals))
    medianLog2LFQ[i]<-apply(log2LFQvals,1, function(x) median(x,na.rm=T))
  }
  print(summary(medianLog2LFQ))
  return(medianLog2LFQ)
}
#maxScaleF####
maxScaleF <- function(log2LFQ){
  colnames(log2LFQ)
  rownames(label)
  table(label[,scaleF])
  maxLog2LFQ <- data.frame(matrix(ncol=length(names(table(label[,scaleF]))),nrow=nrow(log2LFQ)))
  colnames(maxLog2LFQ) <- names(table(label[,scaleF]))
  rownames(maxLog2LFQ)<-rownames(log2LFQ)
  for(i in names(table(label[,scaleF]))){
    #print(i)
    log2LFQvals<-log2LFQ[,gsub("-",".",rownames(label[label[,scaleF]==i,]))]
    #print(summary(log2LFQvals))
    maxLog2LFQ[i]<-apply(log2LFQvals,1, function(x) max(x,na.rm=T))
  }
  print(summary(maxLog2LFQ))
  maxLog2LFQ[maxLog2LFQ==-Inf]=NA
  print(summary(maxLog2LFQ))
  return(maxLog2LFQ)
}
#test####
testWilcox <- function(log2LFQ,sel1,sel2,fName){
  #log2LFQ<-medianLog2LFQ
  #sel1<-"Low"
  #sel2<-"High"
  #fName<-"median"
  d1<-data.frame(log2LFQ[,as.character(labelM[labelM[,lGroup]==sel1,scaleF])])
  rNd1<-rownames(d1)
  d1<-sapply(d1, as.numeric)
  rownames(d1)<-rNd1
  #colnames(d1)<-rownames(label[label$pair2test==sel1,])
  hist(d1)
  #summary(d1)
  d2<-data.frame(log2LFQ[,as.character(labelM[labelM[,lGroup]==sel2,scaleF])])
  rNd2<-rownames(d2)
  d2<-sapply(d2, as.numeric)
  rownames(d2)<-rNd2
  #summary(d2)
  hist(d2)
  dataSellog2grpwilcoxTest<-as.matrix(cbind(d1,d2))
  rowName<-paste(sapply(strsplit(paste(sapply(strsplit(row.names(log2LFQ), "|",fixed=T), "[", 2)), "-"), "[", 1))
  if(sum(!is.na(d1))>1&sum(!is.na(d2))>1){
    #assign(paste0("hda",sel1,sel2),dataSellog2grpwilcoxTest)
    #get(paste0("hda",sel1,sel2))
    hist(dataSellog2grpwilcoxTest)
    row.names(dataSellog2grpwilcoxTest)<-row.names(data)
    sCol<-1
    eCol<-ncol(dataSellog2grpwilcoxTest)
    mCol<-ncol(d1)
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
    logFCmeanGrp1=if(is.null(dim(dataSellog2grpwilcoxTest[,c(sCol:mCol)]))){dataSellog2grpwilcoxTest[,c(sCol:mCol)]} else{apply(dataSellog2grpwilcoxTest[,c(sCol:mCol)],1,function(x) mean(x,na.rm=T))}
    grp1CV=if(is.null(dim(dataSellog2grpwilcoxTest[,c(sCol:mCol)]))){dataSellog2grpwilcoxTest[,c(sCol:mCol)]} else{apply(dataSellog2grpwilcoxTest[,c(sCol:mCol)],1,function(x) sd(x,na.rm=T)/mean(x,na.rm=T))}
    #summary(logFCmedianGrp11-logFCmedianGrp1)
    logFCmedianGrp2=if(is.null(dim(dataSellog2grpwilcoxTest[,c((mCol+1):eCol)]))){dataSellog2grpwilcoxTest[,c((mCol+1):eCol)]} else{apply(dataSellog2grpwilcoxTest[,c((mCol+1):eCol)],1,function(x) median(x,na.rm=T))}
    logFCmeanGrp2=if(is.null(dim(dataSellog2grpwilcoxTest[,c((mCol+1):eCol)]))){dataSellog2grpwilcoxTest[,c((mCol+1):eCol)]} else{apply(dataSellog2grpwilcoxTest[,c((mCol+1):eCol)],1,function(x) mean(x,na.rm=T))}
    grp2CV=if(is.null(dim(dataSellog2grpwilcoxTest[,c((mCol+1):eCol)]))){dataSellog2grpwilcoxTest[,c((mCol+1):eCol)]} else{apply(dataSellog2grpwilcoxTest[,c((mCol+1):eCol)],1,function(x) sd(x,na.rm=T)/mean(x,na.rm=T))}
    logFCmedianGrp1[is.na(logFCmedianGrp1)]=0
    logFCmedianGrp2[is.na(logFCmedianGrp2)]=0
    hda<-cbind(logFCmedianGrp1,logFCmedianGrp2)
    plot(hda)
    limma::vennDiagram(hda>0)
    log2meanDiff = logFCmeanGrp1-logFCmeanGrp2
    logFCmedian = logFCmedianGrp1-logFCmedianGrp2
    logFCmedianFC = 2^(logFCmedian+.Machine$double.xmin)
    logFCmedianFC=squish(logFCmedianFC,c(0.01,100))
    hist(logFCmedianFC)
    log2FCmedianFC=log2(logFCmedianFC)
    hist(log2FCmedianFC)
    wilcoxTest.results = data.frame(Uniprot=rowName,logFCmedianGrp1,logFCmedianGrp2,PValueMinusLog10=pValNAminusLog10,FoldChanglog2median=logFCmedianFC,CorrectedPValueBH=pValBHna,WilcoxTestPval=pValNA,dataSellog2grpwilcoxTest,Log2MedianChange=logFCmedian,grp1CV,grp2CV,log2meanDiff,RowGeneUniProtScorePeps=rownames(dataSellog2grpwilcoxTest))
    writexl::write_xlsx(wilcoxTest.results,paste0(inpF,fName,selection,scaleF,lGroup,sCol,sel1,mCol,sel2,eCol,selThr,selThrFC,cvThr,rGroup,lName,"WilcoxTestBH.xlsx"))
    write.csv(wilcoxTest.results,paste0(inpF,fName,selection,scaleF,lGroup,sCol,sel1,mCol,sel2,eCol,selThr,selThrFC,cvThr,rGroup,lName,"WilcoxTestBH.csv"),row.names = F)
    wilcoxTest.results.return<-wilcoxTest.results
    #volcano
    wilcoxTest.results$RowGeneUniProtScorePeps<-data$geneName
    wilcoxTest.results[is.na(wilcoxTest.results)]=selThr
    Significance=wilcoxTest.results$CorrectedPValueBH<selThr&wilcoxTest.results$CorrectedPValueBH<selThr&abs(wilcoxTest.results$Log2MedianChange)>selThrFC
    dsub <- subset(wilcoxTest.results,Significance)
    p <- ggplot2::ggplot(wilcoxTest.results,ggplot2::aes(Log2MedianChange,PValueMinusLog10))+ ggplot2::geom_point(ggplot2::aes(color=Significance))
    p<-p + ggplot2::theme_bw(base_size=8) + ggplot2::geom_text(data=dsub,ggplot2::aes(label=RowGeneUniProtScorePeps),hjust=0, vjust=0,size=1,position=ggplot2::position_jitter(width=0.5,height=0.1)) + ggplot2::scale_fill_gradient(low="white", high="darkblue") + ggplot2::xlab("Log2 Median Change") + ggplot2::ylab("-Log10 P-value")
    #f=paste(file,proc.time()[3],".jpg")
    #install.packages("svglite")
    ggplot2::ggsave(paste0(inpF,fName,selection,scaleF,lGroup,sCol,sel1,mCol,sel2,eCol,selThr,selThrFC,cvThr,rGroup,lName,"WilcoxTestBH.svg"), p)
    print(p)
    return(sum(Significance))
  }
}
#maxLFQ####
LFQ<-as.matrix(data[,grep(selection,colnames(data))])
#LFQ<-LFQ[,2:ncol(LFQ)]
#protNum<-1:ncol(LFQ)
#protNum<-"LFQ intensity"#1:ncol(LFQ)
#colnames(LFQ)=paste(protNum,sub(selection,"",colnames(LFQ)),sep=";")
colnames(LFQ)=sub(selection,"",colnames(LFQ))
dim(LFQ)
log2LFQ<-log2(LFQ)
log2LFQ[log2LFQ==-Inf]=NA
summary(log2LFQ)
hist(log2LFQ,main=paste("Mean:",mean(log2LFQ,na.rm=T),"SD:",sd(log2LFQ,na.rm=T)),breaks=round(max(log2Int,na.rm=T)),xlim=range(min(log2Int,na.rm=T),max(log2Int,na.rm=T)))
par(mar=c(12,3,1,1))
boxplot(log2LFQ,las=2,main=selection)
write.csv(log2LFQ,paste0(inpF,selection,"log2.csv"),row.names = T)
#corHClfq####
log2LFQimp<-matrix(rnorm(dim(log2LFQ)[1]*dim(log2LFQ)[2],mean=mean(log2LFQ,na.rm = T)-scale,sd=sd(log2LFQ,na.rm = T)/(scale)), dim(log2LFQ)[1],dim(log2LFQ)[2])
log2LFQimp[log2LFQimp<0]<-0
par(mar=c(12,3,1,1))
boxplot(log2LFQimp,las=2,main=paste("imp",selection))
colnames(log2LFQimp)<-colnames(log2LFQ)
log2LFQimpCorr<-cor(log2LFQ,use="pairwise.complete.obs",method="pearson")
colnames(log2LFQimpCorr)<-colnames(log2LFQ)
rownames(log2LFQimpCorr)<-colnames(log2LFQ)
summary(log2LFQimpCorr)
hist(log2LFQimpCorr)
svgPHC<-pheatmap::pheatmap(log2LFQimpCorr,annotation_row = annoR,annotation_col = annoR,clustering_distance_rows = "euclidean",clustering_distance_cols = "euclidean",fontsize_row=4,cluster_cols=T,cluster_rows=T,fontsize_col=4)
ggplot2::ggsave(paste0(inpF,lName,lGroup,selection,"heatmap.log2pearson.svg"), svgPHC)
#log2LFQselScale####
log2LFQselScale<-medianScale(log2LFQ)
dim(log2LFQ)==dim(log2LFQselScale)
boxplot(log2LFQselScale,las=2,main=paste("scale",selection))
write.csv(log2LFQselScale,paste0(inpF,lName,lGroup,selection,scaleF,".log2LFQselScale.csv"))
log2IntimpCorr<-cor(log2LFQselScale,use="pairwise.complete.obs",method="pearson")
colnames(log2IntimpCorr)<-colnames(log2LFQselScale)
rownames(log2IntimpCorr)<-colnames(log2LFQselScale)
hist(log2IntimpCorr)
svgPHC<-pheatmap::pheatmap(log2IntimpCorr,annotation_row = annoR,annotation_col = annoR,clustering_distance_rows = "euclidean",clustering_distance_cols = "euclidean",fontsize_row=4,cluster_cols=T,cluster_rows=T,fontsize_col=4)
ggplot2::ggsave(paste0(inpF,lName,lGroup,selection,scaleF,"heatmap.log2LFQselScale.pearson.svg"), svgPHC)
#log2LFQselScaleSD####
log2LFQselScaleSD<-scaleSD(log2LFQselScale)
summary(log2LFQselScaleSD)
hist(log2LFQselScaleSD)
boxplot(log2LFQselScaleSD,las=2,main=paste(selection,scaleF,"log2LFQselScaleSD"))
boxplot(log2LFQselScale,las=2,main=paste(selection,scaleF,"log2LFQselScale"))
write.csv(log2LFQselScaleSD,paste0(inpF,lName,lGroup,selection,scaleF,"log2LFQselScaleSD.csv"))
log2IntimpCorr<-cor(log2LFQselScaleSD,use="pairwise.complete.obs",method="pearson")
colnames(log2IntimpCorr)<-colnames(log2LFQselScaleSD)
rownames(log2IntimpCorr)<-colnames(log2LFQselScaleSD)
svgPHC<-pheatmap::pheatmap(log2IntimpCorr,annotation_row = annoR,annotation_col = annoR,clustering_distance_rows = "euclidean",clustering_distance_cols = "euclidean",fontsize_row=4,cluster_cols=T,cluster_rows=T,fontsize_col=4)
ggplot2::ggsave(paste0(inpF,lName,lGroup,selection,scaleF,"heatmap.log2LFQselScaleSD.pearson.svg"), svgPHC)
#log2LFQselScale####
log2LFQselMM<-minmaxScale(log2LFQselScale)
summary(log2LFQselMM)
par(mar=c(12,3,1,1))
boxplot(log2LFQselMM,las=2,main=paste(selection,"minMax"))
write.csv(log2LFQselMM,paste0(inpF,lName,lGroup,selection,scaleF,".log2LFQselMM.minMax.csv"))
hist(log2LFQselMM)
log2LFQselScaleimp<-matrix(rnorm(dim(log2LFQselMM)[1]*dim(log2LFQselMM)[2],mean=mean(log2LFQselMM,na.rm = T)-scale,sd=sd(log2LFQselMM,na.rm = T)/(scale)), dim(log2LFQselMM)[1],dim(log2LFQselMM)[2])
hist(log2LFQselScaleimp)
par(mar=c(12,3,1,1))
boxplot(log2LFQselScaleimp,las=2,main=paste(selection,"minMaxImp"))
#log2LFQselScaleimp[log2LFQselScaleimp<0]<-0
#colnames(log2LFQselScaleimp)<-colnames(log2LFQselScale)
log2LFQselScaleimpCorr<-cor(log2LFQselMM,use="pairwise.complete.obs",method="pearson")
hist(log2LFQselScaleimpCorr)
colnames(log2LFQselScaleimpCorr)<-colnames(log2LFQselMM)
rownames(log2LFQselScaleimpCorr)<-colnames(log2LFQselMM)
svgPHC<-pheatmap::pheatmap(log2LFQselScaleimpCorr,annotation_row = annoR,annotation_col = annoR,clustering_distance_rows = "euclidean",clustering_distance_cols = "euclidean",fontsize_row=4,cluster_cols=T,cluster_rows=T,fontsize_col=4)
ggplot2::ggsave(paste0(inpF,lName,lGroup,selection,scaleF,"heatmap.minMax.pearson.svg"), svgPHC)
#labelM####
labelM<-unique(label[,c(scaleF,lGroup)])
colnames(labelM)<-c(scaleF,lGroup)
#data.frame(colnames(medianLog2LFQ))
#merge(labelM,label,by=scaleF)
annoR<-data.frame(labelM[,lGroup])
colnames(annoR)<-lGroup
rownames(annoR)<-labelM[,scaleF]
#compare####
for(i in (names(table(labelM[,lGroup])))){
  print(i)
  print(labelM[labelM[,lGroup]==i,])
}
#medianLog2LFQ####
print("medianLog2LFQ")
hist(log2LFQ)
medianLog2LFQ<-medianScaleF(log2LFQ)
hist(as.matrix(medianLog2LFQ))
boxplot(medianLog2LFQ,las=2,main=paste(selection,"medianLog2LFQ"))
#log2LFQselScaleimp[log2LFQselScaleimp<0]<-0
#colnames(log2LFQselScaleimp)<-colnames(log2LFQselScale)
log2LFQselScaleimpCorr<-cor(medianLog2LFQ,use="pairwise.complete.obs",method="pearson")
hist(log2LFQselScaleimpCorr)
colnames(log2LFQselScaleimpCorr)<-colnames(medianLog2LFQ)
rownames(log2LFQselScaleimpCorr)<-colnames(medianLog2LFQ)
svgPHC<-pheatmap::pheatmap(log2LFQselScaleimpCorr,annotation_row = annoR,annotation_col = annoR,clustering_distance_rows = "euclidean",clustering_distance_cols = "euclidean",fontsize_row=4,cluster_cols=T,cluster_rows=T,fontsize_col=4)
ggplot2::ggsave(paste0(inpF,lName,lGroup,selection,scaleF,"heatmap.medianLog2LFQ.pearson.svg"), svgPHC)
print(testWilcox(medianLog2LFQ,names(table(labelM[,lGroup]))[1],names(table(labelM[,lGroup]))[2],"medianLog2LFQ"))
#medianScaleLog2LFQ####
print("medianScaleLog2LFQ")
log2LFQscale<-scale(log2LFQ,center = TRUE, scale = TRUE)
hist(log2LFQscale)
boxplot(log2LFQscale,las=2,main=paste(selection,"medianScaleLog2LFQ"))
medianLog2LFQ<-medianScaleF(log2LFQscale)
hist(as.matrix(medianLog2LFQ))
boxplot(medianLog2LFQ,las=2,main=paste(selection,"medianLog2LFQ"))
#log2LFQselScaleimp[log2LFQselScaleimp<0]<-0
#colnames(log2LFQselScaleimp)<-colnames(log2LFQselScale)
log2LFQselScaleimpCorr<-cor(medianLog2LFQ,use="pairwise.complete.obs",method="pearson")
hist(log2LFQselScaleimpCorr)
colnames(log2LFQselScaleimpCorr)<-colnames(medianLog2LFQ)
rownames(log2LFQselScaleimpCorr)<-colnames(medianLog2LFQ)
svgPHC<-pheatmap::pheatmap(log2LFQselScaleimpCorr,annotation_row = annoR,annotation_col = annoR,clustering_distance_rows = "euclidean",clustering_distance_cols = "euclidean",fontsize_row=4,cluster_cols=T,cluster_rows=T,fontsize_col=4)
ggplot2::ggsave(paste0(inpF,lName,lGroup,selection,scaleF,"heatmap.medianScaleLog2LFQ.pearson.svg"), svgPHC)
print(testWilcox(medianLog2LFQ,names(table(labelM[,lGroup]))[1],names(table(labelM[,lGroup]))[2],"medianScaleLog2LFQ"))
#medianlog2LFQselScale####
print("medianlog2LFQselScale")
hist(log2LFQselScale)
medianLog2LFQ<-medianScaleF(log2LFQselScale)
hist(as.matrix(medianLog2LFQ))
boxplot(medianLog2LFQ,las=2,main=paste(selection,"medianLog2LFQ"))
#log2LFQselScaleimp[log2LFQselScaleimp<0]<-0
#colnames(log2LFQselScaleimp)<-colnames(log2LFQselScale)
log2LFQselScaleimpCorr<-cor(medianLog2LFQ,use="pairwise.complete.obs",method="pearson")
hist(log2LFQselScaleimpCorr)
colnames(log2LFQselScaleimpCorr)<-colnames(medianLog2LFQ)
rownames(log2LFQselScaleimpCorr)<-colnames(medianLog2LFQ)
svgPHC<-pheatmap::pheatmap(log2LFQselScaleimpCorr,annotation_row = annoR,annotation_col = annoR,clustering_distance_rows = "euclidean",clustering_distance_cols = "euclidean",fontsize_row=4,cluster_cols=T,cluster_rows=T,fontsize_col=4)
ggplot2::ggsave(paste0(inpF,lName,lGroup,selection,scaleF,"heatmap.log2LFQselScale.pearson.svg"), svgPHC)
print(testWilcox(medianLog2LFQ,names(table(labelM[,lGroup]))[1],names(table(labelM[,lGroup]))[2],"medianlog2LFQselScale"))
#medianlog2LFQselScaleSD####
print("medianlog2LFQselScaleSD")
medianLog2LFQ<-medianScaleF(log2LFQselScaleSD)
hist(as.matrix(medianLog2LFQ))
boxplot(medianLog2LFQ,las=2,main=paste(selection,"medianLog2LFQ"))
#log2LFQselScaleimp[log2LFQselScaleimp<0]<-0
#colnames(log2LFQselScaleimp)<-colnames(log2LFQselScale)
log2LFQselScaleimpCorr<-cor(medianLog2LFQ,use="pairwise.complete.obs",method="pearson")
hist(log2LFQselScaleimpCorr)
colnames(log2LFQselScaleimpCorr)<-colnames(medianLog2LFQ)
rownames(log2LFQselScaleimpCorr)<-colnames(medianLog2LFQ)
svgPHC<-pheatmap::pheatmap(log2LFQselScaleimpCorr,annotation_row = annoR,annotation_col = annoR,clustering_distance_rows = "euclidean",clustering_distance_cols = "euclidean",fontsize_row=4,cluster_cols=T,cluster_rows=T,fontsize_col=4)
ggplot2::ggsave(paste0(inpF,lName,lGroup,selection,scaleF,"heatmap.log2LFQselScaleSD.pearson.svg"), svgPHC)
print(testWilcox(medianLog2LFQ,names(table(labelM[,lGroup]))[1],names(table(labelM[,lGroup]))[2],"medianlog2LFQselScaleSD"))
#log2LFQselMM####
print("log2LFQselMM")
medianLog2LFQ<-medianScaleF(log2LFQselMM)
hist(as.matrix(medianLog2LFQ))
boxplot(medianLog2LFQ,las=2,main=paste(selection,"medianLog2LFQ"))
#log2LFQselScaleimp[log2LFQselScaleimp<0]<-0
#colnames(log2LFQselScaleimp)<-colnames(log2LFQselScale)
log2LFQselScaleimpCorr<-cor(medianLog2LFQ,use="pairwise.complete.obs",method="pearson")
hist(log2LFQselScaleimpCorr)
colnames(log2LFQselScaleimpCorr)<-colnames(medianLog2LFQ)
rownames(log2LFQselScaleimpCorr)<-colnames(medianLog2LFQ)
svgPHC<-pheatmap::pheatmap(log2LFQselScaleimpCorr,annotation_row = annoR,annotation_col = annoR,clustering_distance_rows = "euclidean",clustering_distance_cols = "euclidean",fontsize_row=4,cluster_cols=T,cluster_rows=T,fontsize_col=4)
ggplot2::ggsave(paste0(inpF,lName,lGroup,selection,scaleF,"heatmap.minMax.pearson.svg"), svgPHC)
print(testWilcox(medianLog2LFQ,names(table(labelM[,lGroup]))[1],names(table(labelM[,lGroup]))[2],"log2LFQselMM"))
#maxLog2LFQ####
print("maxLog2LFQ")
hist(log2LFQ)
maxLog2LFQ<-maxScaleF(log2LFQ)
hist(as.matrix(maxLog2LFQ))
boxplot(maxLog2LFQ,las=2,main=paste(selection,"maxLog2LFQ"))
#log2LFQselScaleimp[log2LFQselScaleimp<0]<-0
#colnames(log2LFQselScaleimp)<-colnames(log2LFQselScale)
log2LFQselScaleimpCorr<-cor(maxLog2LFQ,use="pairwise.complete.obs",method="pearson")
hist(log2LFQselScaleimpCorr)
colnames(log2LFQselScaleimpCorr)<-colnames(maxLog2LFQ)
rownames(log2LFQselScaleimpCorr)<-colnames(maxLog2LFQ)
svgPHC<-pheatmap::pheatmap(log2LFQselScaleimpCorr,annotation_row = annoR,annotation_col = annoR,clustering_distance_rows = "euclidean",clustering_distance_cols = "euclidean",fontsize_row=4,cluster_cols=T,cluster_rows=T,fontsize_col=4)
ggplot2::ggsave(paste0(inpF,lName,lGroup,selection,scaleF,"heatmap.maxLog2LFQ.pearson.svg"), svgPHC)
print(testWilcox(maxLog2LFQ,names(table(labelM[,lGroup]))[1],names(table(labelM[,lGroup]))[2],"maxLog2LFQ"))
#maxScaleLog2LFQmax####
print("maxScaleLog2LFQmax")
log2LFQscale<-scale(log2LFQ,center = TRUE, scale = TRUE)
hist(log2LFQscale)
boxplot(log2LFQscale,las=2,main=paste(selection,"maxScaleLog2LFQ"))
maxLog2LFQ<-maxScaleF(log2LFQscale)
hist(as.matrix(maxLog2LFQ))
boxplot(maxLog2LFQ,las=2,main=paste(selection,"maxLog2LFQ"))
#log2LFQselScaleimp[log2LFQselScaleimp<0]<-0
#colnames(log2LFQselScaleimp)<-colnames(log2LFQselScale)
log2LFQselScaleimpCorr<-cor(maxLog2LFQ,use="pairwise.complete.obs",method="pearson")
hist(log2LFQselScaleimpCorr)
colnames(log2LFQselScaleimpCorr)<-colnames(maxLog2LFQ)
rownames(log2LFQselScaleimpCorr)<-colnames(maxLog2LFQ)
svgPHC<-pheatmap::pheatmap(log2LFQselScaleimpCorr,annotation_row = annoR,annotation_col = annoR,clustering_distance_rows = "euclidean",clustering_distance_cols = "euclidean",fontsize_row=4,cluster_cols=T,cluster_rows=T,fontsize_col=4)
ggplot2::ggsave(paste0(inpF,lName,lGroup,selection,scaleF,"heatmap.maxScaleLog2LFQ.pearson.svg"), svgPHC)
print(testWilcox(maxLog2LFQ,names(table(labelM[,lGroup]))[1],names(table(labelM[,lGroup]))[2],"maxScaleLog2LFQmax"))
#maxlog2LFQselScaleMax####
print("maxlog2LFQselScaleMax")
hist(log2LFQselScale)
maxLog2LFQ<-maxScaleF(log2LFQselScale)
hist(as.matrix(maxLog2LFQ))
boxplot(maxLog2LFQ,las=2,main=paste(selection,"maxLog2LFQ"))
#log2LFQselScaleimp[log2LFQselScaleimp<0]<-0
#colnames(log2LFQselScaleimp)<-colnames(log2LFQselScale)
log2LFQselScaleimpCorr<-cor(maxLog2LFQ,use="pairwise.complete.obs",method="pearson")
hist(log2LFQselScaleimpCorr)
colnames(log2LFQselScaleimpCorr)<-colnames(maxLog2LFQ)
rownames(log2LFQselScaleimpCorr)<-colnames(maxLog2LFQ)
svgPHC<-pheatmap::pheatmap(log2LFQselScaleimpCorr,annotation_row = annoR,annotation_col = annoR,clustering_distance_rows = "euclidean",clustering_distance_cols = "euclidean",fontsize_row=4,cluster_cols=T,cluster_rows=T,fontsize_col=4)
ggplot2::ggsave(paste0(inpF,lName,lGroup,selection,scaleF,"heatmap.log2LFQselScale.pearson.svg"), svgPHC)
print(testWilcox(maxLog2LFQ,names(table(labelM[,lGroup]))[1],names(table(labelM[,lGroup]))[2],"maxlog2LFQselScaleMax"))
#maxlog2LFQselScaleSDmax####
print("maxlog2LFQselScaleSDmax")
maxLog2LFQ<-maxScaleF(log2LFQselScaleSD)
hist(as.matrix(maxLog2LFQ))
boxplot(maxLog2LFQ,las=2,main=paste(selection,"maxLog2LFQ"))
#log2LFQselScaleimp[log2LFQselScaleimp<0]<-0
#colnames(log2LFQselScaleimp)<-colnames(log2LFQselScale)
log2LFQselScaleimpCorr<-cor(maxLog2LFQ,use="pairwise.complete.obs",method="pearson")
hist(log2LFQselScaleimpCorr)
colnames(log2LFQselScaleimpCorr)<-colnames(maxLog2LFQ)
rownames(log2LFQselScaleimpCorr)<-colnames(maxLog2LFQ)
svgPHC<-pheatmap::pheatmap(log2LFQselScaleimpCorr,annotation_row = annoR,annotation_col = annoR,clustering_distance_rows = "euclidean",clustering_distance_cols = "euclidean",fontsize_row=4,cluster_cols=T,cluster_rows=T,fontsize_col=4)
ggplot2::ggsave(paste0(inpF,lName,lGroup,selection,scaleF,"heatmap.log2LFQselScaleSD.pearson.svg"), svgPHC)
print(testWilcox(maxLog2LFQ,names(table(labelM[,lGroup]))[1],names(table(labelM[,lGroup]))[2],"maxlog2LFQselScaleSDmax"))
#maxlog2LFQselMM####
print("maxlog2LFQselMM")
maxLog2LFQ<-maxScaleF(log2LFQselMM)
#summary(maxLog2LFQ)
#summary(log2LFQselMM)
hist(as.matrix(maxLog2LFQ))
boxplot(maxLog2LFQ,las=2,main=paste(selection,"maxLog2LFQ"))
#log2LFQselScaleimp[log2LFQselScaleimp<0]<-0
#colnames(log2LFQselScaleimp)<-colnames(log2LFQselScale)
log2LFQselScaleimpCorr<-cor(maxLog2LFQ,use="pairwise.complete.obs",method="pearson")
hist(log2LFQselScaleimpCorr)
colnames(log2LFQselScaleimpCorr)<-colnames(maxLog2LFQ)
rownames(log2LFQselScaleimpCorr)<-colnames(maxLog2LFQ)
svgPHC<-pheatmap::pheatmap(log2LFQselScaleimpCorr,annotation_row = annoR,annotation_col = annoR,clustering_distance_rows = "euclidean",clustering_distance_cols = "euclidean",fontsize_row=4,cluster_cols=T,cluster_rows=T,fontsize_col=4)
ggplot2::ggsave(paste0(inpF,lName,lGroup,selection,scaleF,"heatmap.minMax.pearson.svg"), svgPHC)
print(testWilcox(maxLog2LFQ,names(table(labelM[,lGroup]))[1],names(table(labelM[,lGroup]))[2],"maxlog2LFQselMM"))
#medianMaxLog2LFQ####
print("medianMaxLog2LFQ")
hist(log2LFQ)
maxLog2LFQ<-maxScaleF(log2LFQ)
hist(as.matrix(maxLog2LFQ))
boxplot(maxLog2LFQ,las=2,main=paste(selection,"maxLog2LFQ"))
medianMaxLog2LFQ<-medianScale(maxLog2LFQ)
hist(as.matrix(medianMaxLog2LFQ))
boxplot(medianMaxLog2LFQ,las=2,main=paste(selection,"maxLog2LFQ"))
#log2LFQselScaleimp[log2LFQselScaleimp<0]<-0
#colnames(log2LFQselScaleimp)<-colnames(log2LFQselScale)
log2LFQselScaleimpCorr<-cor(medianMaxLog2LFQ,use="pairwise.complete.obs",method="pearson")
hist(log2LFQselScaleimpCorr)
colnames(log2LFQselScaleimpCorr)<-colnames(maxLog2LFQ)
rownames(log2LFQselScaleimpCorr)<-colnames(maxLog2LFQ)
svgPHC<-pheatmap::pheatmap(log2LFQselScaleimpCorr,annotation_row = annoR,annotation_col = annoR,clustering_distance_rows = "euclidean",clustering_distance_cols = "euclidean",fontsize_row=4,cluster_cols=T,cluster_rows=T,fontsize_col=4)
ggplot2::ggsave(paste0(inpF,lName,lGroup,selection,scaleF,"heatmap.medianMaxLog2LFQ.pearson.svg"), svgPHC)
print(testWilcox(medianMaxLog2LFQ,names(table(labelM[,lGroup]))[1],names(table(labelM[,lGroup]))[2],"medianMaxLog2LFQ"))
#quartileLog2LFQ####
print("quartileLog2LFQ")
hist(log2LFQ)
maxLog2LFQ<-maxScaleF(log2LFQ)
hist(as.matrix(maxLog2LFQ))
boxplot(maxLog2LFQ,las=2,main=paste(selection,"quartMaxLog2LFQ"))
quartMaxLog2LFQ<-quartScale(maxLog2LFQ)
hist(as.matrix(quartMaxLog2LFQ))
boxplot(quartMaxLog2LFQ,las=2,main=paste(selection,"quartMaxLog2LFQ"))
#log2LFQselScaleimp[log2LFQselScaleimp<0]<-0
#colnames(log2LFQselScaleimp)<-colnames(log2LFQselScale)
log2LFQselScaleimpCorr<-cor(quartMaxLog2LFQ,use="pairwise.complete.obs",method="pearson")
hist(log2LFQselScaleimpCorr)
colnames(log2LFQselScaleimpCorr)<-colnames(maxLog2LFQ)
rownames(log2LFQselScaleimpCorr)<-colnames(maxLog2LFQ)
svgPHC<-pheatmap::pheatmap(log2LFQselScaleimpCorr,annotation_row = annoR,annotation_col = annoR,clustering_distance_rows = "euclidean",clustering_distance_cols = "euclidean",fontsize_row=4,cluster_cols=T,cluster_rows=T,fontsize_col=4)
ggplot2::ggsave(paste0(inpF,lName,lGroup,selection,scaleF,"heatmap.quartMaxLog2LFQ.pearson.svg"), svgPHC)
print(testWilcox(quartMaxLog2LFQ,names(table(labelM[,lGroup]))[1],names(table(labelM[,lGroup]))[2],"quartMaxLog2LFQ"))
