#C:\users\animeshs\R-4.4.0\bin\Rscript.exe diffExprTestTmatrixXL.r "L:\promec\TIMSTOF\LARS\2022\februar\Sigrid\combined\txt\Copy of Copy of combined with explanatory headings_2 (version 1).xlsx" "EQ:ES"  "CA:CC"
#C:\users\animeshs\R-4.4.0\bin\Rscript.exe diffExprTestTmatrixXL.r "L:\promec\TIMSTOF\LARS\2022\februar\Sigrid\combined\txt\Copy of Copy of combined with explanatory headings_2 (version 1).xlsx" "JW:JY"  "HG:HI"
#setup
#install.packages(c("readxl","writexl","svglite","ggplot2","BiocManager"),repos="http://cran.us.r-project.org",lib=.libPaths())
#BiocManager::install(c("limma","pheatmap"),repos="http://cran.us.r-project.org",lib=.libPaths())
#install.packages("devtools")
#devtools::install_github("jdstorey/qvalue")
print("USAGE:<path to>Rscript diffExprTestTmatrix.r <complete path to excel file> <Groups-1-columns> <Groups-2 columns>")
args = commandArgs(trailingOnly=TRUE)
print(paste("supplied argument(s):", length(args)))
print(args)
if (length(args) != 3) {stop("\n\nNeeds 3 arguments, the excel file containing the data AND columns for GROUP-to-compare", call.=FALSE)}
inpF <- args[1]
#inpF <-"L:/promec/TIMSTOF/LARS/2022/februar/Sigrid/combined/txt/Copy of Copy of combined with explanatory headings_2 (version 1).xlsx"
lGroup <- args[2]
#lGroup<-"EQ:ES"
rGroup <- args[3]
#rGroup<-"CA:CC"
inpD<-dirname(inpF)
fName<-basename(inpF)
lName<-paste(lGroup,rGroup,sep = ".")
lName<-gsub(":","_",lName)
thr=0.0#count
selThr=0.05#pValue-tTest
selThrFC=1#log2-MedianDifference
cvThr=0.05#threshold for coefficient-of-variation
outP=paste(inpF,selThr,selThrFC,cvThr,lName,"VolcanoTestT","pdf",sep = ".")
pdf(outP)
#data####
data <- readxl::read_xlsx(inpF,sheet=1)
colnames(data)<-data[1,]
data<-data[-1,]
colnames(data)
#test####
testT <- function(data,lGroup,rGroup,cvThr){
  #https://stackoverflow.com/a/62062861
  aaZZ <- expand.grid(LETTERS, LETTERS)
  aaZZ <- aaZZ[order(aaZZ$Var1,aaZZ$Var2),]
  outAAZZ <- c(LETTERS, do.call('paste0',aaZZ))
  d1<-data[,match(unlist(strsplit(lGroup,":"))[1],outAAZZ):match(unlist(strsplit(lGroup,":"))[2],outAAZZ)]
  d2<-data[,match(unlist(strsplit(rGroup,":"))[1],outAAZZ):match(unlist(strsplit(rGroup,":"))[2],outAAZZ)]
  dataSellog2grpTtest<-as.data.frame(cbind(d1,d2))
  plot(dataSellog2grpTtest)
  dataSellog2grpTtest<-sapply(dataSellog2grpTtest,as.numeric)
  boxplot(dataSellog2grpTtest)
  hist(dataSellog2grpTtest)
  log2IntimpCorr<-cor(dataSellog2grpTtest,use="pairwise.complete.obs",method="pearson")
  colnames(log2IntimpCorr)<-colnames(dataSellog2grpTtest)
  rownames(log2IntimpCorr)<-colnames(dataSellog2grpTtest)
  annoR<-data.frame(Group=c(rep(lGroup,ncol(d1)),rep(rGroup,ncol(d2))))
  rownames(annoR)<-colnames(dataSellog2grpTtest)
  print(annoR)
  svgPHC<-pheatmap::pheatmap(log2IntimpCorr,clustering_distance_rows = "euclidean",clustering_distance_cols = "euclidean",fontsize_row=8,cluster_cols=T,cluster_rows=T,fontsize_col  = 8,annotation_row = annoR, annotation_col = annoR)
  ggplot2::ggsave(paste0(inpF,lName,"Cluster.svg"), svgPHC)
  if(sum(!is.na(d1))>1&sum(!is.na(d2))>1){
    dataSellog2grpTtest[dataSellog2grpTtest==0]=NA
    hist(dataSellog2grpTtest,breaks=round(max(dataSellog2grpTtest,na.rm=T)))
    row.names(dataSellog2grpTtest)<-row.names(data)
    comp<-paste(lGroup,rGroup,sep = ".")
    comp<-gsub(":","_",comp)
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
    ttest.results = data.frame(data,logFCmedianGrp1,logFCmedianGrp2,PValueMinusLog10=pValNAminusLog10,FoldChanglog2median=logFCmedianFC,CorrectedPValueBH=pValBHna,TtestPval=pValNA,dataSellog2grpTtest,Log2MedianChange=logFCmedian,grp1CV,grp2CV,Uniprot=paste(sapply(strsplit(paste(sapply(strsplit(data$ID, "|",fixed=T), "[", 2)), " "), "[", 1)))
    writexl::write_xlsx(ttest.results,paste0(inpF,sCol,eCol,comp,selThr,selThrFC,cvThr,lName,"tTestBH.xlsx"))
    write.csv(ttest.results,paste0(inpF,sCol,eCol,comp,selThr,selThrFC,cvThr,lName,"tTestBH.csv"),row.names = F)
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
    ggplot2::ggsave(paste0(inpF,sCol,eCol,comp,selThr,selThrFC,cvThr,"VolcanoTest.svg"), p)
    print(p)
    return(ttest.results.return)
  }
}
#compare####
print(paste(lGroup,rGroup))
ttPair=testT(data,lGroup,rGroup,cvThr)
