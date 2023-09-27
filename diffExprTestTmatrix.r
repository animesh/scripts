#usage####
#F:\R-4.3.1\bin\Rscript.exe diffExprTestTmatrix.r "L:\promec\USERS\Alessandro\230130_Alessandro_35_samples\m16\peptides.txt.protgroup_annotated.tsv.maxquant_peptides.protein_intensities.tsv" "tab" "2:17" "2:4" "5:7" "0.5" "0.05"
#setup
#install.packages(c("readxl","writexl","svglite","ggplot2","BiocManager"),repos="http://cran.us.r-project.org",lib=.libPaths())
#BiocManager::install(c("pheatmap"),repos="http://cran.us.r-project.org",lib=.libPaths())
#L:\promec\USERS\Alessandro\230130_Alessandro_35_samples\m16\peptides.txt
#L:\promec\USERS\Alessandro\230130_Alessandro_35_samples\m16\proteinGroups.txt
#directLFQ Specify the type of the input table you want to use from the dropdown menu. Applies only if you want to use non-default settings, for example if you want to use summarized precursor intensities instead of fragment ion intensities for DIA data:
print("USAGE:<path to>Rscript diffExprTestTmatrix.r <complete path to data-file> <separator> <columns to be used for analysis> <columns for first> <and columns for second-group for t-test> <threshold for absolute log2-median-fold-change>  <threshold for Benjamini-Hochberg corrected p-value>")
args = commandArgs(trailingOnly=TRUE)
print(paste("supplied argument(s):", length(args)))
print(args)
if (length(args)!=7) {stop("\n\nNeeds 5 arguments as mentiond above for example:

c:/Users/animeshs/R-4.2.1-win/bin/Rscript.exe diffExprTestTmatrix.r \"L:\\OneDrive - NTNU\\Aida\\sORF\\mqpar.K8R10.xml.1664621075.results\\peptides.txt.Count.normH2L.csv\" \"tab\" \"2:17\" \"2:4\" \"5:7\" \"0.5\" \"0.05\"
", call.=FALSE)}
inpF <- args[1]
#inpF <-"F:/promec/USERS/Alessandro/230130_Alessandro_35_samples/m16/peptides.txt.protgroup_annotated.tsv.maxquant_peptides.protein_intensities.tsv"
inpL <- args[2]
#inpL <-"tab"
selection <- args[3]
#selection<-"2:17"
lGroup <- args[4]
#lGroup<-"2:4"
rGroup <- args[5]
#rGroup<-"5:7"
selThrFC <- args[6]
#selThrFC=0.5#log2-MedianDifference
selThr <- args[7]
#selThr=0.05#pValue-tTest
inpD<-dirname(inpF)
fName<-basename(inpF)
thr=0.0#count
cvThr=0.1#threshold for coefficient-of-variation
hdr<-gsub("[^[:alnum:]]", "",paste0(inpD,selection,lGroup,rGroup))
outP=paste(inpF,selThr,selThrFC,cvThr,hdr,"VolcanoTestT","pdf",sep = ".")
print(outP)
pdf(outP)
#data####
if(inpL=="tab"){inpL<-"\t"} else{inpL<-","}
data <- read.csv(inpF,sep=inpL)
summary(data)
##clean####
#data = data[!data$Reverse=="+",]
#data = data[!data$Potential.contaminant=="+",]
#data = data[!data$Only.identified.by.site=="+",]
dim(data)
if(length(strsplit(selection,":")[[1]])==2){selCols<-c(strsplit(selection,":")[[1]][1]:strsplit(selection,":")[[1]][2])} else if(length(strsplit(selection,",")[[1]])>2){selCols<-as.numeric(strsplit(selection,",")[[1]])}
log2Int<-as.matrix(log2(data[,selCols]))
log2Int[log2Int==-Inf]=NA
#pairPlot####
#pairs(log2Int)
hist(log2Int,main=paste("Mean:",mean(log2Int,na.rm=T),"SD:",sd(log2Int,na.rm=T)),breaks=round(max(log2Int,na.rm=T)),xlim=range(min(log2Int,na.rm=T),max(log2Int,na.rm=T)))
#boxPlot####
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
#corPearson####
log2IntimpCorr<-cor(log2Int,use="pairwise.complete.obs",method="pearson")
colnames(log2IntimpCorr)<-colnames(log2Int)
rownames(log2IntimpCorr)<-colnames(log2Int)
svgPHC<-pheatmap::pheatmap(log2IntimpCorr,clustering_distance_rows = "euclidean",clustering_distance_cols = "euclidean",fontsize_row=8,cluster_cols=T,cluster_rows=T,fontsize_col  = 8)
#test####
testT <- function(log2LFQ,sel1,sel2,cvThr){
  #sel1<-lGroup
  #sel2<-rGroup
  #log2LFQ<-data#[,gsub("-",".",rownames(label[label$Remove!="Y",]))]
  #colnames(log2LFQ)
  if(length(strsplit(sel1,":")[[1]])==2){sel1<-c(strsplit(sel1,":")[[1]][1]:strsplit(sel1,":")[[1]][2])} else if(length(strsplit(sel1,",")[[1]])>2){sel1<-as.numeric(strsplit(sel1,",")[[1]])}
  if(length(strsplit(sel2,":")[[1]])==2){sel2<-c(strsplit(sel2,":")[[1]][1]:strsplit(sel2,":")[[1]][2])} else if(length(strsplit(sel2,",")[[1]])>2){sel2<-as.numeric(strsplit(sel2,",")[[1]])}
  selection<-gsub("[^[:alnum:] ]", "", selection)
  lGroup<-gsub("[^[:alnum:] ]", "", lGroup)
  rGroup<-gsub("[^[:alnum:] ]", "", rGroup)
  d1<-data[,sel1]
  d1<-as.matrix(log2(d1))
  d1[d1==-Inf]=NA
  d2<-data[,sel2]
  d2<-as.matrix(log2(d2))
  d2[d2==-Inf]=NA
  dataSellog2grpTtest<-as.matrix(cbind(d1,d2))
  if(sum(!is.na(d1))>1&sum(!is.na(d2))>1){
    hist(d1,breaks=round(max(dataSellog2grpTtest,na.rm=T)))
    hist(d2,breaks=round(max(dataSellog2grpTtest,na.rm=T)))
    #assign(paste0("hda",sel1,sel2),dataSellog2grpTtest)
    #get(paste0("hda",sel1,sel2))
    dataSellog2grpTtest[dataSellog2grpTtest==0]=NA
    hist(dataSellog2grpTtest,breaks=round(max(dataSellog2grpTtest,na.rm=T)))
    row.names(dataSellog2grpTtest)<-row.names(data)
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
    logFCmedian = logFCmedianGrp1-logFCmedianGrp2
    logFCmedianFC = 2^(logFCmedian+.Machine$double.xmin)
    logFCmedianFC=squish(logFCmedianFC,c(0.01,100))
    hist(logFCmedianFC)
    log2FCmedianFC=log2(logFCmedianFC)
    hist(log2FCmedianFC)
    ttest.results = data.frame(Uniprot=row.names(dataSellog2grpTtest),logFCmedianGrp1,logFCmedianGrp2,PValueMinusLog10=pValNAminusLog10,FoldChanglog2median=logFCmedianFC,CorrectedPValueBH=pValBHna,TtestPval=pValNA,dataSellog2grpTtest,Log2MedianChange=logFCmedian,grp1CV,grp2CV,data[,-c(sel1,sel2)])
    writexl::write_xlsx(ttest.results,paste0(inpF,selection,sCol,eCol,selThr,selThrFC,cvThr,lGroup,rGroup,"tTestBH.xlsx"))
    write.csv(ttest.results,paste0(inpF,selection,sCol,eCol,selThr,selThrFC,cvThr,lGroup,rGroup,"tTestBH.csv"),row.names = F)
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
    ggplot2::ggsave(paste0(inpF,selection,sCol,eCol,selThr,selThrFC,cvThr,lGroup,rGroup,"VolcanoTest.svg"), p)
    print(p)
    return(Significance)
  }
}
#compare####
colnames(data)
ttPair=testT(data,lGroup,rGroup,cvThr)
print(sum(ttPair))
print(data[ttPair,])
