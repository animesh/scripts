#C:\users\animeshs\R-4.4.0\bin\Rscript.exe diffExprTestTmatrix.r "L:\promec\Qexactive\LARS\2022\juli\toktam\PDv2p5\Beer\220706_toktam1_Proteins.txt.Abundance.Normalized..log2.csv" "L:\promec\Qexactive\LARS\2022\juli\toktam\PDv2p5\Beer\GroupsR1.txt" Sample Class Rem
#setup
#install.packages(c("readxl","writexl","svglite","ggplot2","BiocManager"),repos="http://cran.us.r-project.org",lib=.libPaths())
#BiocManager::install(c("limma","pheatmap"),repos="http://cran.us.r-project.org",lib=.libPaths())
#install.packages("devtools")
#devtools::install_github("jdstorey/qvalue")
print("USAGE:<path to>Rscript diffExprTestTmatrix.r <complete path to directory containing proteinGroups.txt AND Groups.txt files> <name of group column in Groups.txt annotating data/rows to be used for analysis> <name of column in Groups.txt marking data NOT to be considered in analysis>")
args = commandArgs(trailingOnly=TRUE)
print(paste("supplied argument(s):", length(args)))
print(args)
if (length(args) != 5) {stop("\n\nNeeds at least 4 arguments, the full path of the directory containing BOTH proteinGroups.txt AND Groups.txt files followed by the name of GROUP-to-compare and data-to-REMOVE columns in Groups.txt file", call.=FALSE)}
inpF <- args[1]
#inpF <-"L:\\promec\\Qexactive\\LARS\\2022\\juli\\toktam\\PDv2p5\\Beer\\220706_toktam1_Proteins.txt.Abundance.Normalized..log2.csv"
inpL <- args[2]
#inpL <-"L:\\promec\\Qexactive\\LARS\\2022\\juli\\toktam\\PDv2p5\\Beer\\GroupsR1.txt"
selection <- args[3]
#selection<-"Sample"
lGroup <- args[4]
#lGroup<-"Class"
rGroup <- args[5]
#rGroup<-"Rem"
inpD<-dirname(inpF)
fName<-basename(inpF)
lName<-basename(inpL)
thr=0.0#count
selThr=0.05#pValue-tTest
selThrFC=0.5#log2-MedianDifference
cvThr=0.05#threshold for coefficient-of-variation
hdr<-gsub("[^[:alnum:]]", "",inpD)
outP=paste(inpF,selection,selThr,selThrFC,cvThr,hdr,lGroup,rGroup,lName,"VolcanoTestT","pdf",sep = ".")
pdf(outP)
#data####
data <- read.csv(inpF,row.names=1)
summary(data)
##clean####
#data = data[!data$Reverse=="+",]
#data = data[!data$Potential.contaminant=="+",]
#data = data[!data$Only.identified.by.site=="+",]
dim(data)
log2Int<-as.matrix(data[,grep(selection,colnames(data))])
log2Int[log2Int==-Inf]=NA
hist(log2Int,main=paste("Mean:",mean(log2Int,na.rm=T),"SD:",sd(log2Int,na.rm=T)),breaks=round(max(log2Int,na.rm=T)),xlim=range(min(log2Int,na.rm=T),max(log2Int,na.rm=T)))
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
#label####
label<-read.table(inpL,header=T,sep="\t",row.names=1)#, colClasses=c(rep("factor",3)))
label["pair2test"]<-label[lGroup]
if(rGroup %in% colnames(label)){label["removed"]<-label[rGroup]} else{label["removed"]=NA}
print(label)
#test####
testT <- function(log2LFQ,sel1,sel2,cvThr){
  #sel1<-"S2"
  #sel2<-"S1"
  #log2LFQ<-log2LFQsel#[,gsub("-",".",rownames(label[label$Remove!="Y",]))]
  #colnames(log2LFQ)
  d1<-log2LFQ[,gsub("-",".",rownames(label[label$pair2test==sel1,]))]
  d2<-log2LFQ[,gsub("-",".",rownames(label[label$pair2test==sel2,]))]
  dataSellog2grpTtest<-as.matrix(cbind(d1,d2))
  log2IntimpCorr<-cor(dataSellog2grpTtest,use="pairwise.complete.obs",method="pearson")
  colnames(log2IntimpCorr)<-colnames(dataSellog2grpTtest)
  rownames(log2IntimpCorr)<-colnames(dataSellog2grpTtest)
  annoR<-data.frame(Group=c(rep(sel1,ncol(d1)),rep(sel2,ncol(d2))))
  rownames(annoR)<-colnames(dataSellog2grpTtest)
  print(annoR)
  svgPHC<-pheatmap::pheatmap(log2IntimpCorr,clustering_distance_rows = "euclidean",clustering_distance_cols = "euclidean",fontsize_row=8,cluster_cols=T,cluster_rows=T,fontsize_col  = 8,annotation_row = annoR, annotation_col = annoR)
  ggplot2::ggsave(paste0(inpF,selection,lGroup,rGroup,lName,"Cluster.svg"), svgPHC)
  if(sum(!is.na(d1))>1&sum(!is.na(d2))>1){
    hist(d1,breaks=round(max(dataSellog2grpTtest,na.rm=T)))
    hist(d2,breaks=round(max(dataSellog2grpTtest,na.rm=T)))
    #assign(paste0("hda",sel1,sel2),dataSellog2grpTtest)
    #get(paste0("hda",sel1,sel2))
    dataSellog2grpTtest[dataSellog2grpTtest==0]=NA
    hist(dataSellog2grpTtest,breaks=round(max(dataSellog2grpTtest,na.rm=T)))
    row.names(dataSellog2grpTtest)<-row.names(data)
    comp<-paste0(sel1,sel2)
    sCol<-1
    eCol<-ncol(dataSellog2grpTtest)
    mCol<-ncol(d1)#ceiling((eCol-sCol+1)/2)
    dim(dataSellog2grpTtest)
    options(nwarnings = 1000000)
    pValNA = apply(
      dataSellog2grpTtest, 1, function(x)
        if(sum(!is.na(x[c(sCol:mCol)]))<2&sum(!is.na(x[c((mCol+1):eCol)]))<2){NA}
      else if(sum(is.na(x[c(sCol:mCol)]))==0&sum(is.na(x[c((mCol+1):eCol)]))==0){
        t.test(as.numeric(x[c(sCol:mCol)]),as.numeric(x[c((mCol+1):eCol)]),var.equal=T)$p.value}
      else if(sum(!is.na(x[c(sCol:mCol)]))>1&sum(!is.na(x[c((mCol+1):eCol)]))<1&abs(sd(x[c(sCol:mCol)],na.rm=T)/mean(x[c(sCol:mCol)],na.rm=T))<cvThr){0}
      else if(sum(!is.na(x[c(sCol:mCol)]))<1&sum(!is.na(x[c((mCol+1):eCol)]))>1&abs(sd(x[c((mCol+1):eCol)],na.rm=T)/mean(x[c((mCol+1):eCol)],na.rm=T))<cvThr){0}
      else if(sum(!is.na(x[c(sCol:mCol)]))>=2&sum(!is.na(x[c((mCol+1):eCol)]))>=1){
        t.test(as.numeric(x[c(sCol:mCol)]),as.numeric(x[c((mCol+1):eCol)]),na.rm=T,var.equal=T)$p.value}
      else if(sum(!is.na(x[c(sCol:mCol)]))>=1&sum(!is.na(x[c((mCol+1):eCol)]))>=2){
        t.test(as.numeric(x[c(sCol:mCol)]),as.numeric(x[c((mCol+1):eCol)]),na.rm=T,var.equal=T)$p.value}
      else{NA}
    )
    summary(warnings())
    hist(pValNA)
    summary(pValNA)
    dfpValNA<-as.data.frame(ceiling(pValNA))
    pValNAdm<-cbind(pValNA,dataSellog2grpTtest,row.names(data))
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
    logFCmedianGrp1=if(is.null(dim(dataSellog2grpTtest[,c(sCol:mCol)]))){dataSellog2grpTtest[,c(sCol:mCol)]} else{apply(dataSellog2grpTtest[,c(sCol:mCol)],1,function(x) median(x,na.rm=T))}
    grp1CV=if(is.null(dim(dataSellog2grpTtest[,c(sCol:mCol)]))){dataSellog2grpTtest[,c(sCol:mCol)]} else{apply(dataSellog2grpTtest[,c(sCol:mCol)],1,function(x) sd(x,na.rm=T)/mean(x,na.rm=T))}
    #summary(logFCmedianGrp11-logFCmedianGrp1)
    logFCmedianGrp2=if(is.null(dim(dataSellog2grpTtest[,c((mCol+1):eCol)]))){dataSellog2grpTtest[,c((mCol+1):eCol)]} else{apply(dataSellog2grpTtest[,c((mCol+1):eCol)],1,function(x) median(x,na.rm=T))}
    grp2CV=if(is.null(dim(dataSellog2grpTtest[,c((mCol+1):eCol)]))){dataSellog2grpTtest[,c((mCol+1):eCol)]} else{apply(dataSellog2grpTtest[,c((mCol+1):eCol)],1,function(x) sd(x,na.rm=T)/mean(x,na.rm=T))}
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
    ttest.results = data.frame(Uniprot=data$uniprot,logFCmedianGrp1,logFCmedianGrp2,PValueMinusLog10=pValNAminusLog10,FoldChanglog2median=logFCmedianFC,CorrectedPValueBH=pValBHna,TtestPval=pValNA,dataSellog2grpTtest,Log2MedianChange=logFCmedian,grp1CV,grp2CV,RowGeneUniProtScorePeps=rownames(dataSellog2grpTtest))
    writexl::write_xlsx(ttest.results,paste0(inpF,selection,sCol,eCol,comp,selThr,selThrFC,cvThr,lGroup,rGroup,lName,"tTestBH.xlsx"))
    write.csv(ttest.results,paste0(inpF,selection,sCol,eCol,comp,selThr,selThrFC,cvThr,lGroup,rGroup,lName,"tTestBH.csv"),row.names = F)
    ttest.results.return<-ttest.results
    #volcano
    ttest.results$RowGeneUniProtScorePeps<-rownames(dataSellog2grpTtest)
    ttest.results[is.na(ttest.results)]=selThr
    Significance=ttest.results$CorrectedPValueBH<selThr&ttest.results$CorrectedPValueBH>0&abs(ttest.results$Log2MedianChange)>selThrFC
    sum(Significance)
    dsub <- subset(ttest.results,Significance)
    p <- ggplot2::ggplot(ttest.results,ggplot2::aes(Log2MedianChange,PValueMinusLog10))+ ggplot2::geom_point(ggplot2::aes(color=Significance))
    p<-p + ggplot2::theme_bw(base_size=8) + ggplot2::geom_text(data=dsub,ggplot2::aes(label=Uniprot),hjust=0, vjust=0,size=1,position=ggplot2::position_jitter(width=0.5,height=0.1)) + ggplot2::scale_fill_gradient(low="white", high="darkblue") + ggplot2::xlab("Log2 Median Change") + ggplot2::ylab("-Log10 P-value")
    #f=paste(file,proc.time()[3],".jpg")
    #install.packages("svglite")
    ggplot2::ggsave(paste0(inpF,selection,sCol,eCol,comp,selThr,selThrFC,cvThr,lGroup,rGroup,lName,"VolcanoTest.png"),width=10, height=8,dpi=300, p)
    print(p)
    Significance0=ttest.results$CorrectedPValueBH<selThr&ttest.results$CorrectedPValueBH>=0&abs(ttest.results$Log2MedianChange)>selThrFC
    sum(Significance0)
    dsub0 <- subset(ttest.results,Significance0)
    dsub0<-dsub0[order(dsub0$Log2MedianChange,decreasing = F),]
    rownames(dsub0)<-dsub0$Uniprot
    rownames(annoR)<-paste0("X",colnames(dataSellog2grpTtest))
    dsig0<-dsub0[,colnames(dsub0) %in% rownames(annoR)]
    dsig0[dsig0==selThr]=NA
    dsig0<-dsig0[order(rowSums(dsig0,na.rm=T),decreasing = T),]
    svgPHC<-pheatmap::pheatmap(dsig0,cluster_rows = F,cluster_cols = F,fontsize_row=6,fontsize_col  = 6,annotation_col = annoR)
    ggplot2::ggsave(paste0(inpF,selection,lGroup,rGroup,lName,"heatmapLFQ.png"),width=6, height=8,dpi=300, svgPHC)
    svgPHC<-pheatmap::pheatmap(dsig0,cluster_rows = T,cluster_cols = T,clustering_method = "complete",clustering_distance_cols = "euclidean",clustering_distance_rows = "euclidean",fontsize_row=6,fontsize_col  = 6,annotation_col = annoR)
    ggplot2::ggsave(paste0(inpF,selection,lGroup,rGroup,lName,"ClusterLFQ.euclidean.png"),width=6, height=8,dpi=300, svgPHC)
    return(ttest.results.return)
  }
}
#compare####
head(label)
rownames(label)<-sub("+",".",rownames(label),fixed=T)
head(label)
colnames(log2Int)
colnames(log2Int)<-sub("X","",colnames(log2Int))
print(rownames(label))
print(colnames(log2Int)==rownames(label))
log2LFQsel=log2Int[,rownames(label[is.na(label$removed)|label$removed==" "|label$removed=='',])]
colnames(log2LFQsel)
dim(log2LFQsel)
label=label[is.na(label$removed)|label$removed==" "|label$removed=='',]
table(label$pair2test)
for(i in rownames(table(label$pair2test))){
  for(j in rownames(table(label$pair2test))){
    if(i>j){
      print(paste(i,j))
      ttPair=testT(log2LFQsel,i,j,cvThr)
      #assign(paste0(i,j),ttPair)
    }
  }
}
