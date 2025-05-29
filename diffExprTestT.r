#..\R-4.4.0\bin\Rscript.exe diffExprTestT.r "L:\promec\TIMSTOF\LARS\2025\250507_Alessandro\combined\txt\proteinGroups.txt" "L:\promec\TIMSTOF\LARS\2025\250507_Alessandro\combined\txt\Groups.txt" "Condition" "Remove" "LFQ.intensity." "SB" "LB" 0.1 0.5 0.15
#..\R-4.4.0\bin\Rscript.exe diffExprTestT.r "L:\promec\TIMSTOF\LARS\2025\250507_Alessandro\combined\txt\proteinGroups.txt" "L:\promec\TIMSTOF\LARS\2025\250507_Alessandro\combined\txt\Groups.txt" "Condition" "Remove" "LFQ.intensity." "SA" "LA" 0.1 0.5 0.15   
#setup####
#install.packages(c("readxl","writexl","svglite","ggplot2","BiocManager"),repos="http://cran.us.r-project.org",lib=.libPaths())
#BiocManager::install(c("limma","pheatmap","vsn"))#,repos="http://cran.us.r-project.org",lib=.libPaths())
#install.packages("devtools")
#devtools::install_github("jdstorey/qvalue")
args = commandArgs(trailingOnly=TRUE)
print(paste("supplied argument(s):", length(args)))
print(args)
if (length(args) != 10) {stop("\n\nNeeds NINE arguments, the full path of proteinGroups.txt AND Groups.txt files followed by the name of GROUP-to-compare and data-to-REMOVE columns in Groups.txt file and Intensity columns to include and control-group and thresholds like FDR-threshold, log2Median-FC-threshold, coefficient-of-variation-threshold; for example:

c:/R/bin/Rscript.exe diffExprTestT.r \"C:/Data/combined/txt/proteinGroups.txt\" \"C:/Data/combined/txt/Groups.txt\" Groups Removed Intensity. Control 0.1 1 0.05\n\n
", call.=FALSE)}
inpF <- args[1]
#inpF <-"L:/promec/TIMSTOF/LARS/2024/241118_Deo/tot/combined/txt/proteinGroups.txt"
inpL <- args[2]
#inpL <-"L:/promec/TIMSTOF/LARS/2024/241118_Deo/tot/combined/txt/Groups.txt"
lGroup <- args[3]
#lGroup<-"Bio"
rGroup <- args[4]
#rGroup<-"Rem"
selection <- args[5]
#selection<-"LFQ.intensity."
sample <- args[6]
#sample<-"C6"
control <- args[7]
#control<-"C1"
selThr <- args[8]
selThr <- as.numeric(selThr)
#selThr=0.1#pValue-tTest
selThrFC <- args[9]
selThrFC <- as.numeric(selThrFC)
#selThrFC=0.5#log2-MedianDifference
cvThr <- args[10]
cvThr <- as.numeric(cvThr)
#cvThr=0.1#threshold for coefficient-of-variation
inpD<-dirname(inpF)
fName<-basename(inpF)
lName<-basename(inpL)
hdr<-gsub("[^[:alnum:]]", "",inpD)
outP=paste(inpF,selection,selThr,selThrFC,cvThr,hdr,lGroup,rGroup,lName,sample,control,"VolcanoTestT","pdf",sep = ".")
pdf(outP)
#data####
data <- read.table(inpF,stringsAsFactors = FALSE, header = TRUE, quote = "", comment.char = "", sep = "\t")
##clean####
data = data[!data$Reverse=="+",]
data = data[!data$Potential.contaminant=="+",]
#data = data[!data$Only.identified.by.site=="+",]
row.names(data)<-paste(row.names(data),data[,grep("Fasta.headers",colnames(data))],data[,grep("Protein.IDs",colnames(data))],data[,grep("Protein.names",colnames(data))],data[,grep("Gene.names",colnames(data))],data[,grep("Score",colnames(data))],data[,grep("Peptide.counts..unique.",colnames(data))],sep=";;")
summary(data)
dim(data)
##int####
intdata<-data[,grep(selection,colnames(data))]
log2Int<-as.matrix(log2(intdata))
dim(log2Int)
log2Int[log2Int==-Inf]=NA
hist(log2Int,main=paste("Mean:",mean(log2Int,na.rm=T),"SD:",sd(log2Int,na.rm=T)),breaks=round(max(log2Int,na.rm=T)),xlim=range(min(log2Int,na.rm=T),max(log2Int,na.rm=T)))
colnames(log2Int)<-gsub(selection,"",colnames(log2Int))
summary(log2Int)
par(mar=c(12,3,1,1))
boxplot(log2Int,las=2)
#scale####
countTableDAuniGORNAddsMed<-apply(log2Int,1,function(x) median(x,na.rm=T))
countTableDAuniGORNAddsSD<-apply(log2Int,1,function(x) sd(x,na.rm=T))
countTableDAuniGORNAdds<-(log2Int-countTableDAuniGORNAddsMed)#/countTableDAuniGORNAddsSD
hist(countTableDAuniGORNAdds)
boxplot(countTableDAuniGORNAdds,las=2)
##justVSN####
#BiocManager::install("vsn")
IntVST<-as.matrix(intdata)
IntVST[IntVST==0]=NA
LFQvsn <- vsn::justvsn(IntVST)
hist(LFQvsn)
vsn::meanSdPlot(LFQvsn)
vsn::meanSdPlot(LFQvsn,ranks = FALSE)
colnames(LFQvsn)<-gsub(selection,"",colnames(LFQvsn))
boxplot(LFQvsn,las=2)
countTableDAuniGORNAddsMedVSN<-apply(LFQvsn,1,function(x) median(x,na.rm=T))
countTableDAuniGORNAddsMedVSN<-(LFQvsn-countTableDAuniGORNAddsMedVSN)
hist(countTableDAuniGORNAddsMedVSN)
boxplot(countTableDAuniGORNAddsMedVSN,las=2)
#label####
label<-read.table(inpL,header=T,sep="\t",row.names=1)#, colClasses=c(rep("factor",3)))
label["pair2test"]<-label[lGroup]
if(rGroup %in% colnames(label)){label["removed"]<-label[rGroup]} else{label["removed"]=NA}
print(label)
#anno####
annoFactor<-label[lGroup]
names(annoFactor)<-lGroup
anno<-data.frame(factor(label[,lGroup]))
names(anno)<-lGroup
rownames(anno)<-gsub("-",".",rownames(label))
table(anno)
annoR<-data.frame(factor(annoFactor[rownames(label[is.na(label[rGroup])|label[rGroup]==" "|label[rGroup]=='',]),]))
row.names(annoR)<-gsub("-",".",rownames(label[is.na(label[rGroup])|label[rGroup]==" "|label[rGroup]=='',]))
names(annoR)<-lGroup
summary(annoR)
#corHCint####
scale=3
log2Intimp<-matrix(rnorm(dim(log2Int)[1]*dim(log2Int)[2],mean=mean(log2Int,na.rm = T)-scale,sd=sd(log2Int,na.rm = T)/(scale)), dim(log2Int)[1],dim(log2Int)[2])
log2Intimp[log2Intimp<0]<-0
par(mar=c(12,3,1,1))
boxplot(log2Intimp,las=2)
bk1 <- c(seq(-1,-0.01,by=0.01))
bk2 <- c(seq(0.01,1,by=0.01))
bk <- c(bk1,bk2)  #combine the break limits for purpose of graphing
palette <- c(colorRampPalette(colors = c("white", "yellow"))(n = length(bk1)-1),"yellow", "yellow",c(colorRampPalette(colors = c("yellow","red"))(n = length(bk2)-1)))
colnames(log2Intimp)<-colnames(log2Int)
log2IntimpCorr<-cor(log2Int,use="pairwise.complete.obs",method="pearson")
colnames(log2IntimpCorr)<-colnames(log2Int)
rownames(log2IntimpCorr)<-colnames(log2Int)
svgPHC<-pheatmap::pheatmap(log2IntimpCorr,color = palette,clustering_distance_rows = "euclidean",clustering_distance_cols = "euclidean",fontsize_row=6,cluster_cols=T,cluster_rows=T,fontsize_col  = 6,annotation_row = anno,annotation_col = anno)
ggplot2::ggsave(paste0(inpF,selection,lGroup,rGroup,lName,"log2Intcluster.svg"), svgPHC)
write.csv(log2Int,paste0(inpF,selection,"log2Int.csv"))
#corHCmedNorm####
log2IntimpCorr<-cor(countTableDAuniGORNAdds,use="pairwise.complete.obs",method="pearson")
colnames(log2IntimpCorr)<-colnames(countTableDAuniGORNAdds)
rownames(log2IntimpCorr)<-colnames(countTableDAuniGORNAdds)
svgPHC<-pheatmap::pheatmap(log2IntimpCorr,color = palette,clustering_distance_rows = "euclidean",clustering_distance_cols = "euclidean",fontsize_row=6,cluster_cols=T,cluster_rows=T,fontsize_col  = 6,annotation_row = anno,annotation_col = anno)
ggplot2::ggsave(paste0(inpF,selection,lGroup,rGroup,lName,"log2IntcountTableDAuniGORNAddscluster.svg"), svgPHC)
write.csv(log2Int,paste0(inpF,selection,"log2IntcountTableDAuniGORNAdds.csv"))
#corHCvsnint####
log2IntimpCorr<-cor(LFQvsn,use="pairwise.complete.obs",method="pearson")
colnames(log2IntimpCorr)<-colnames(LFQvsn)
rownames(log2IntimpCorr)<-colnames(LFQvsn)
svgPHC<-pheatmap::pheatmap(log2IntimpCorr,color = palette,clustering_distance_rows = "euclidean",clustering_distance_cols = "euclidean",fontsize_row=6,cluster_cols=T,cluster_rows=T,fontsize_col  = 6,annotation_row = anno,annotation_col = anno)
ggplot2::ggsave(paste0(inpF,selection,lGroup,rGroup,lName,"log2LFQvsncluster.svg"), svgPHC)
write.csv(log2Int,paste0(inpF,selection,"log2LFQvsn.csv"))
#corHCvsnintMedNorm####
log2IntimpCorr<-cor(countTableDAuniGORNAddsMedVSN,use="pairwise.complete.obs",method="pearson")
colnames(log2IntimpCorr)<-colnames(countTableDAuniGORNAddsMedVSN)
rownames(log2IntimpCorr)<-colnames(countTableDAuniGORNAddsMedVSN)
svgPHC<-pheatmap::pheatmap(log2IntimpCorr,color = palette,clustering_distance_rows = "euclidean",clustering_distance_cols = "euclidean",fontsize_row=6,cluster_cols=T,cluster_rows=T,fontsize_col  = 6,annotation_row = anno,annotation_col = anno)
ggplot2::ggsave(paste0(inpF,selection,lGroup,rGroup,lName,"countTableDAuniGORNAddsMedVSNcluster.svg"), svgPHC)
write.csv(log2Int,paste0(inpF,selection,"log2countTableDAuniGORNAddsMedVSN.csv"))
#test####
testT <- function(log2LFQ,sel1,sel2,cvThr,dfName){
  #sel1<-"female"
  #sel2<-"male"
  #log2LFQ<-log2LFQsel#MMdata#log2LFQsel#log2LFQ[,gsub("-",".",rownames(label[is.na(label$removed)|label$removed==" "|label$removed=='',]))]
  #colnames(log2LFQ)
  #dfName="log2LFQselMMdata"#"log2LFQsel"
  d1<-data.frame(log2LFQ[,gsub("-",".",rownames(label[label$pair2test==sel1,]))])
  colnames(d1)<-gsub("-",".",rownames(label[label$pair2test==sel1,]))
  d2<-data.frame(log2LFQ[,gsub("-",".",rownames(label[label$pair2test==sel2,]))])
  colnames(d2)<-gsub("-",".",rownames(label[label$pair2test==sel2,]))
  dataSellog2grpTtest<-merge(d1, d2, by = 'row.names', all = TRUE)
  rN<-dataSellog2grpTtest[,1]
  geneName<-paste(sapply(strsplit(paste(sapply(strsplit(rN, "GN=",fixed=T), "[", 2)), "[; ]"), "[", 1))
  uniprotID<-paste(sapply(strsplit(paste(sapply(strsplit(rN, "\\|",fixed=F), "[", 2)), "\\|"), "[", 1))
  geneName[is.na(geneName)]=uniprotID[is.na(geneName)]
  proteinNames<-paste(sapply(strsplit(paste(sapply(strsplit(rN, "_",fixed=T), "[", 2)), " OS="), "[", 1))
  dataSellog2grpTtest[,1]<-NULL
  dataSellog2grpTtest[dataSellog2grpTtest==0]=NA
  gene_id=sprintf("ENSG%011d",seq(1:nrow(dataSellog2grpTtest)))
  write.table(cbind(gene_id=gene_id,dataSellog2grpTtest),paste0(inpD,"/",sel1,sel2,dfName,"log2LFQ.tsv"),row.names = F,quote = F,sep="\t")
  dataSellog2grpTtestInt<-2^(dataSellog2grpTtest)
  dataSellog2grpTtestInt[is.na(dataSellog2grpTtestInt)]=0
  write.table(cbind(gene_id=gene_id,dataSellog2grpTtestInt),paste0(inpD,"/",sel1,sel2,dfName,"intLFQ.tsv"),row.names = F,quote = F,sep="\t")
  write.table(cbind(gene_id=gene_id,uniprotID,geneName,proteinNames,rN),paste0(inpD,"/",sel1,sel2,dfName,"annotation.tsv"),row.names = F,quote = F,sep="\t")
  dataSellog2grpTtest<-as.matrix(dataSellog2grpTtest)
  log2IntimpCorr<-cor(dataSellog2grpTtest,use="pairwise.complete.obs",method="pearson")
  colnames(log2IntimpCorr)<-colnames(dataSellog2grpTtest)
  rownames(log2IntimpCorr)<-colnames(dataSellog2grpTtest)
  annoR<-data.frame(condition=c(rep(sel1,ncol(d1)),rep(sel2,ncol(d2))))
  rownames(annoR)<-colnames(dataSellog2grpTtest)
  print(annoR)
  boxplot(log2IntimpCorr,las=2)
  svgPHC<-pheatmap::pheatmap(log2IntimpCorr,clustering_distance_rows = "euclidean",clustering_distance_cols = "euclidean",fontsize_row=8,cluster_cols=T,cluster_rows=T,fontsize_col  = 8,annotation_row = annoR, annotation_col = annoR)
  ggplot2::ggsave(paste0(inpF,selection,lGroup,rGroup,lName,dfName,sel1,sel2,dfName,"Cluster.svg"), svgPHC)
  annoR$sample=rownames(annoR)
  write.csv(annoR,paste0(inpD,"/",sel1,sel2,dfName,"samples.csv"),row.names = F,quote = F)
  cInfo<-data.frame(id=paste("co",sel1,sel2,dfName,sep="_"),variable="condition",reference=sel2,target=sel1,blocking="")#condition_control_treated,condition,NS,S,greplicate
  write.csv(cInfo,paste0(inpD,"/",sel1,sel2,dfName,"contrasts.csv"),row.names = F,quote = F)
  #row.names(dataSellog2grpTtest)<-rN
  dim(dataSellog2grpTtest)
  hist(as.numeric(dataSellog2grpTtest),breaks=round(max(dataSellog2grpTtest,na.rm=T)))
  if(sum(!is.na(d1))>1&sum(!is.na(d2))>1){
    sCol<-1
    eCol<-ncol(dataSellog2grpTtest)
    mCol<-ncol(d1)#ceiling((eCol-sCol+1)/2)
    hist(dataSellog2grpTtest[,sCol:mCol],breaks=round(max(dataSellog2grpTtest,na.rm=T)))
    hist(dataSellog2grpTtest[,c((mCol+1):eCol)],breaks=round(max(dataSellog2grpTtest,na.rm=T)))
    #assign(paste0("hda",sel1,sel2),dataSellog2grpTtest)
    #get(paste0("hda",sel1,sel2))
    #rowSums(dataSellog2grpTtest)
    comp<-paste0(sel1,sel2)
    options(nwarnings = 1000000)
    pValNA = apply(
      dataSellog2grpTtest, 1, function(x)
        #if(!isTRUE(x)){NA} # else
        if(sum(!is.na(x[c(sCol:mCol)]))<2&sum(!is.na(x[c((mCol+1):eCol)]))<2){NA}
      else if(is.na(sd(x[c(sCol:mCol)],na.rm=T))&(sd(x[c((mCol+1):eCol)],na.rm=T)==0)){0}#Q9QX47
      else if(is.na(sd(x[c((mCol+1):eCol)],na.rm=T))&(sd(x[c(sCol:mCol)],na.rm=T)==0)){0}
      else if(sum(is.na(x[c(sCol:mCol)]))==0&sum(is.na(x[c((mCol+1):eCol)]))==0){
        t.test(as.numeric(x[c(sCol:mCol)]),as.numeric(x[c((mCol+1):eCol)]),var.equal=T)$p.value}
      else if(sum(!is.na(x[c(sCol:mCol)]))>1&sum(!is.na(x[c((mCol+1):eCol)]))<1&abs(sd(2^x[c(sCol:mCol)],na.rm=T)/mean(2^x[c(sCol:mCol)],na.rm=T))<cvThr){0}
      else if(sum(!is.na(x[c(sCol:mCol)]))<1&sum(!is.na(x[c((mCol+1):eCol)]))>1&abs(sd(2^x[c((mCol+1):eCol)],na.rm=T)/mean(2^x[c((mCol+1):eCol)],na.rm=T))<cvThr){0}
      else if(sum(!is.na(x[c(sCol:mCol)]))>=2&sum(!is.na(x[c((mCol+1):eCol)]))>=1){
        t.test(as.numeric(x[c(sCol:mCol)]),as.numeric(x[c((mCol+1):eCol)]),na.rm=T,var.equal=T)$p.value}
      else if(sum(!is.na(x[c(sCol:mCol)]))>=1&sum(!is.na(x[c((mCol+1):eCol)]))>=2){
        t.test(as.numeric(x[c(sCol:mCol)]),as.numeric(x[c((mCol+1):eCol)]),na.rm=T,var.equal=T)$p.value}
      else{NA}
    )
    summary(warnings())
    if(sum(is.na(pValNA))<length(pValNA)){
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
      grp1CV=if(is.null(dim(dataSellog2grpTtest[,c(sCol:mCol)]))){dataSellog2grpTtest[,c(sCol:mCol)]} else{apply(2^dataSellog2grpTtest[,c(sCol:mCol)],1,function(x) sd(x,na.rm=T)/mean(x,na.rm=T))}
      #summary(logFCmedianGrp11-logFCmedianGrp1)
      logFCmedianGrp2=if(is.null(dim(dataSellog2grpTtest[,c((mCol+1):eCol)]))){dataSellog2grpTtest[,c((mCol+1):eCol)]} else{apply(dataSellog2grpTtest[,c((mCol+1):eCol)],1,function(x) median(x,na.rm=T))}
      grp2CV=if(is.null(dim(dataSellog2grpTtest[,c((mCol+1):eCol)]))){dataSellog2grpTtest[,c((mCol+1):eCol)]} else{apply(2^dataSellog2grpTtest[,c((mCol+1):eCol)],1,function(x) sd(x,na.rm=T)/mean(x,na.rm=T))}
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
      ttest.results = data.frame(Uniprot=uniprotID,Gene=geneName,Protein=proteinNames,logFCmedianGrp1,logFCmedianGrp2,PValueMinusLog10=pValNAminusLog10,FoldChanglog2median=logFCmedianFC,CorrectedPValueBH=pValBHna,TtestPval=pValNA,dataSellog2grpTtest,Log2MedianChange=logFCmedian,grp1CV,grp2CV,RowGeneUniProtScorePeps=rN)
      ttest.results=ttest.results[order(ttest.results$CorrectedPValueBH),]
      writexl::write_xlsx(ttest.results,paste0(inpF,selection,sCol,eCol,comp,selThr,selThrFC,cvThr,lGroup,rGroup,lName,dfName,"tTestBH.xlsx"))
      write.csv(ttest.results,paste0(inpF,selection,sCol,eCol,comp,selThr,selThrFC,cvThr,lGroup,rGroup,lName,dfName,"tTestBH.csv"),row.names = F)
      ttest.results.return<-ttest.results
      #volcano
      ttest.results$RowGeneUniProtScorePeps<-ttest.results.return$Gene
      ttest.results[is.na(ttest.results)]=selThr
      Significance=ttest.results$CorrectedPValueBH<selThr&ttest.results$CorrectedPValueBH>0&abs(ttest.results$Log2MedianChange)>selThrFC
      dsub <- subset(ttest.results,Significance)
      p <- ggplot2::ggplot(ttest.results,ggplot2::aes(Log2MedianChange,PValueMinusLog10))+ ggplot2::geom_point(ggplot2::aes(color=Significance))
      p<-p + ggplot2::theme_bw(base_size=8) + ggplot2::geom_text(data=dsub,ggplot2::aes(label=RowGeneUniProtScorePeps),hjust=0, vjust=0,size=1,position=ggplot2::position_jitter(width=0.5,height=0.1)) + ggplot2::scale_fill_gradient(low="white", high="darkblue") + ggplot2::xlab("Log2 Median Change") + ggplot2::ylab("-Log10 P-value")
      #f=paste(file,proc.time()[3],".jpg")
      #install.packages("svglite")
      ggplot2::ggsave(paste0(inpF,selection,sCol,eCol,comp,selThr,selThrFC,cvThr,lGroup,rGroup,lName,dfName,"VolcanoTest.svg"), p)
      print(p)
      print(sum(Significance))
      return(ttest.results.return)
    }
    else{return(0)}
  }
}
#compare####
colnames(log2Int)
dim(log2Int)
log2LFQsel=log2Int[,gsub("-",".",rownames(label[is.na(label$removed)|label$removed==" "|label$removed=='',]))]
colnames(log2LFQsel)
dim(log2LFQsel)
vsn::meanSdPlot(log2LFQsel)
boxplot(log2LFQsel,las=2)
countTableDAuniGORNAddsMed<-apply(log2LFQsel,1,function(x) median(x,na.rm=T))
countTableDAuniGORNAdds<-(log2LFQsel-countTableDAuniGORNAddsMed)
hist(countTableDAuniGORNAdds)
boxplot(countTableDAuniGORNAdds,las=2)
label=label[is.na(label$removed)|label$removed==" "|label$removed=='',]
table(label$pair2test)
inpFL<-c()
if(sample!=control){
  print(paste(sample,control))
  inpFL<-c(inpFL,paste0(sample,control))
  ttPair=testT(log2LFQsel,sample,control,cvThr,selection)
  assign(paste0(sample,control),ttPair)
}
print(paste("results saved in:",paste0(inpF,selection,selThr,selThrFC,cvThr,lGroup,rGroup,lName,control),"csv, xlsx, and svg files"))
#countTableDAuniGORNAdds####
colnames(countTableDAuniGORNAdds)
dim(countTableDAuniGORNAdds)
log2LFQsel=countTableDAuniGORNAdds[,gsub("-",".",rownames(label[is.na(label$removed)|label$removed==" "|label$removed=='',]))]
colnames(log2LFQsel)
dim(log2LFQsel)
vsn::meanSdPlot(log2LFQsel)
boxplot(log2LFQsel,las=2)
countTableDAuniGORNAddsMed<-apply(log2LFQsel,1,function(x) median(x,na.rm=T))
countTableDAuniGORNAdds<-(log2LFQsel-countTableDAuniGORNAddsMed)
hist(countTableDAuniGORNAdds)
boxplot(countTableDAuniGORNAdds,las=2)
label=label[is.na(label$removed)|label$removed==" "|label$removed=='',]
table(label$pair2test)
inpFL<-c()
if(sample!=control){
  print(paste(sample,control))
  inpFL<-c(inpFL,paste0(sample,control))
  ttPair=testT(log2LFQsel,sample,control,cvThr,paste0(selection,"countTableDAuniGORNAdds"))
  assign(paste0(sample,control,"countTableDAuniGORNAdds"),ttPair)
}
print(paste("results saved in:",paste0(inpF,selection,selThr,selThrFC,cvThr,lGroup,rGroup,lName,control,"countTableDAuniGORNAdds"),"csv, xlsx, and svg files"))
#LFQvsn####
colnames(LFQvsn)
dim(LFQvsn)
log2LFQsel=LFQvsn[,gsub("-",".",rownames(label[is.na(label$removed)|label$removed==" "|label$removed=='',]))]
colnames(log2LFQsel)
dim(log2LFQsel)
vsn::meanSdPlot(log2LFQsel)
boxplot(log2LFQsel,las=2)
countTableDAuniGORNAddsMed<-apply(log2LFQsel,1,function(x) median(x,na.rm=T))
countTableDAuniGORNAdds<-(log2LFQsel-countTableDAuniGORNAddsMed)
hist(countTableDAuniGORNAdds)
boxplot(countTableDAuniGORNAdds,las=2)
label=label[is.na(label$removed)|label$removed==" "|label$removed=='',]
table(label$pair2test)
inpFL<-c()
if(sample!=control){
  print(paste(sample,control))
  inpFL<-c(inpFL,paste0(sample,control))
  ttPair=testT(log2LFQsel,sample,control,cvThr,paste0(selection,"LFQvsn"))
  assign(paste0(sample,control,"LFQvsn"),ttPair)
}
print(paste("results saved in:",paste0(inpF,selection,selThr,selThrFC,cvThr,lGroup,rGroup,lName,control,"LFQvsn"),"csv, xlsx, and svg files"))
#countTableDAuniGORNAddsMedVSN####
colnames(countTableDAuniGORNAddsMedVSN)
dim(countTableDAuniGORNAddsMedVSN)
log2LFQsel=countTableDAuniGORNAddsMedVSN[,gsub("-",".",rownames(label[is.na(label$removed)|label$removed==" "|label$removed=='',]))]
colnames(log2LFQsel)
dim(log2LFQsel)
vsn::meanSdPlot(log2LFQsel)
boxplot(log2LFQsel,las=2)
countTableDAuniGORNAddsMed<-apply(log2LFQsel,1,function(x) median(x,na.rm=T))
countTableDAuniGORNAdds<-(log2LFQsel-countTableDAuniGORNAddsMed)
hist(countTableDAuniGORNAdds)
boxplot(countTableDAuniGORNAdds,las=2)
label=label[is.na(label$removed)|label$removed==" "|label$removed=='',]
table(label$pair2test)
inpFL<-c()
if(sample!=control){
  print(paste(sample,control))
  inpFL<-c(inpFL,paste0(sample,control))
  ttPair=testT(log2LFQsel,sample,control,cvThr,paste0(selection,"countTableDAuniGORNAddsMedVSN"))
  assign(paste0(sample,control,"countTableDAuniGORNAddsMedVSN"),ttPair)
}
print(paste("results saved in:",paste0(inpF,selection,selThr,selThrFC,cvThr,lGroup,rGroup,lName,control,"countTableDAuniGORNAddsMedVSN"),"csv, xlsx, and svg files"))

