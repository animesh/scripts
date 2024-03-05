#Rscript.exe diffExprTestT.r
#diff L:\promec\Elite\LARS\2018\mai\Vibeke V\combined\txt\proteinGroups.txt F:\OneDrive - NTNU\Attachments\Copy of vibeke protein groups (003).xlsx ChunMei/combined/txt/proteinGroups.txt
#setup####
#install.packages(c("readxl","writexl","svglite","ggplot2","BiocManager"),repos="http://cran.us.r-project.org",lib=.libPaths())
#BiocManager::install(c("limma","pheatmap"),repos="http://cran.us.r-project.org",lib=.libPaths())
#install.packages("devtools")
#devtools::install_github("jdstorey/qvalue")
#testOld####
dataX<-readxl::read_xlsx("F:/OneDrive - NTNU/Desktop/Vibeke/Copy of vibeke protein groups (003).xlsx")
inpL <-"L:/promec/Elite/LARS/2018/mai/Vibeke V/txtClassLFQ/Groups.txt"
inpF <-"L:/promec/Elite/LARS/2018/mai/Vibeke V/txtMedianLFQ/proteinGroups.txt"
inpF <-"L:/promec/Elite/LARS/2018/mai/Vibeke V/combined/txt/proteinGroups.txt"
inpF <-"L:/promec/Elite/LARS/2018/mai/Vibeke V/combined/txtCLFQ/proteinGroups.txt"
inpF <-"L:/promec/Elite/LARS/2018/mai/Vibeke V/txtClassicLFQ/proteinGroups.txt"
dataX<-read.csv(inpF,header=T,sep="\t",row.names=1)
dataXlfq<-(dataX[,grep("LFQ.intensity.",colnames(dataX))])
summary(dataXlfq)
dataXlfq<-sapply(dataXlfq,as.numeric)
dataXlfq[dataXlfq==0]=NA
hist(dataXlfq)
boxplot(dataXlfq,las=2)
dataXlfqMM<-vsn::justvsn(dataXlfq)
hist(dataXlfqMM)
boxplot(dataXlfqMM,las=2)
write.csv(dataXlfqMM,"L:/promec/Elite/LARS/2018/mai/Vibeke V/Copy of vibeke protein groups (003)MM.csv",row.names = T,quote = F)
log2dataXlfq<-log2(dataX[,grep("LFQ.intensity.",colnames(dataX))])
summary(log2dataXlfq)
log2dataXlfq[log2dataXlfq==-Inf]=NA
log2dataXlfq<-sapply(log2dataXlfq,as.numeric)
colnames(log2dataXlfq)<-sub("LFQ.intensity.","",colnames(dataX)[grep("LFQ.intensity.",colnames(dataX))])
summary(log2dataXlfq)
hist(log2dataXlfq)
boxplot(log2dataXlfq,las=2)
pheatmap::pheatmap(log2dataXlfq[order(rowSums(log2dataXlfq,na.rm = T),decreasing = T),],cluster_cols = T,cluster_rows = F)
boxplot(dataXlfqMM,las=2)
vsn::meanSdPlot(dataXlfqMM)
vsn::meanSdPlot(log2dataXlfq)
vsn::meanSdPlot(dataXlfqMM,ranks = F)
vsn::meanSdPlot(log2dataXlfq,ranks = F)
write.csv(log2dataXlfq,"L:/promec/Elite/LARS/2018/mai/Vibeke V/Copy of vibeke protein groups (003)log2LFQ.csv",row.names = T,quote = F)
dataXlfqCor<-cor(dataXlfqMM,use="pairwise.complete.obs",method="pearson")
pheatmap::pheatmap(dataXlfqCor)
dataXlfqCor<-cor(log2dataXlfq,use="pairwise.complete.obs",method="pearson")
pheatmap::pheatmap(dataXlfqCor)
countTableDAuniGORNAddsMed<-apply(log2dataXlfq,1,function(x) median(x,na.rm=T))
countTableDAuniGORNAddsSD<-apply(log2dataXlfq,1,function(x) sd(x,na.rm=T))
countTableDAuniGORNAdds<-(log2dataXlfq-countTableDAuniGORNAddsMed)#/countTableDAuniGORNAddsSD
hist(countTableDAuniGORNAdds)
boxplot(countTableDAuniGORNAdds,las=2)
countTableDAuniGORNAddsMed<-apply(dataXlfqMM,1,function(x) median(x,na.rm=T))
countTableDAuniGORNAddsSD<-apply(dataXlfqMM,1,function(x) sd(x,na.rm=T))
countTableDAuniGORNAdds<-(dataXlfqMM-countTableDAuniGORNAddsMed)#/countTableDAuniGORNAddsSD
#hist(countTableDAuniGORNAdds)
boxplot(countTableDAuniGORNAdds,las=2)
hist(dataXlfqMM-log2dataXlfq)
boxplot(dataXlfqMM-log2dataXlfq,las=2)
#data####
inpF <-"L:/promec/Elite/LARS/2018/mai/Vibeke V/PDv2p5/Clots/180507_VIBEKEV_C1-(12)_Proteins.txt"
data <- read.table(inpF,stringsAsFactors = FALSE, header = TRUE, quote = "\"", comment.char = "", sep = "\t")
print(colnames(data))
row.names(data)<-paste(row.names(data),data$Accession,data$FASTA.Title.Lines,data$Biological.Process,data$Molecular.Function,data$Cellular.Component,data$Score.Sequest.HT.Sequest.HT,data$Number.of.Protein.Unique.Peptides,sep=";;")
summary(data)
dim(data)
dataMP<-data[data[,"Master"]=="IsMasterProtein",]
#param####
inpD<-dirname(inpF)
fName<-basename(inpF)
selection<-"Abundances.Normalized."
thr=0.0#count
selThr=0.1#pValue-tTest
selThrFC=1#.5#log2-MedianDifference
cvThr=0.05#threshold for coefficient-of-variation
hdr<-gsub("[^[:alnum:]]", "",inpD)
outP=paste(inpF,selection,selThr,selThrFC,cvThr,hdr,"VolcanoTestT","pdf",sep = ".")
pdf(outP)
#maxLFQ####
LFQ<-as.matrix(dataMP[,grep(selection,colnames(dataMP))])
print(colnames(LFQ))
colnames(LFQ)<-sub(".Sample.","",colnames(LFQ))
#protNum<-1:ncol(LFQ)
#protNum<-"LFQ intensity"#1:ncol(LFQ)
#colnames(LFQ)=paste(protNum,sub(selection,"",colnames(LFQ)),sep=";")
colnames(LFQ)=sub(selection,"",colnames(LFQ))
dim(LFQ)
log2LFQ<-log2(LFQ)
log2LFQ[log2LFQ==-Inf]=NA
log2LFQ[log2LFQ==0]=NA
summary(log2LFQ)
hist(log2LFQ,main=paste("Mean:",mean(log2LFQ,na.rm=T),"SD:",sd(log2LFQ,na.rm=T)),breaks=round(max(log2LFQ,na.rm=T)),xlim=range(min(log2LFQ,na.rm=T),max(log2LFQ,na.rm=T)))
par(mar=c(12,3,1,1))
boxplot(log2LFQ,las=2)
rownames(log2LFQ)<-paste(sapply(strsplit(paste(sapply(strsplit(paste(sapply(strsplit(rownames(dataMP), "|",fixed=T), "[", 2)), " "), "[", 1)), ":"), "[", 1))
pheatmap::pheatmap(log2LFQ[order(rowSums(log2LFQ,na.rm = T),decreasing = T),],cluster_cols = T,cluster_rows = F)
countTableDAuniGORNAddsMed<-apply(log2LFQ,1,function(x) median(x,na.rm=T))
countTableDAuniGORNAddsSD<-apply(log2LFQ,1,function(x) sd(x,na.rm=T))
countTableDAuniGORNAdds<-(log2LFQ-countTableDAuniGORNAddsMed)#/countTableDAuniGORNAddsSD
hist(countTableDAuniGORNAdds)
par(mar=c(12,3,1,1))
boxplot(countTableDAuniGORNAdds,las=2)
rowName<-rownames(log2LFQ)
writexl::write_xlsx(as.data.frame(cbind(rowName,log2LFQ,rownames(dataMP))),paste0(inpF,"log2LFQ.xlsx"))
#corHClfq####
scale=3
log2LFQimp<-matrix(rnorm(dim(log2LFQ)[1]*dim(log2LFQ)[2],mean=mean(log2LFQ,na.rm = T)-scale,sd=sd(log2LFQ,na.rm = T)/(scale)), dim(log2LFQ)[1],dim(log2LFQ)[2])
log2LFQimp[log2LFQimp<0]<-0
par(mar=c(12,3,1,1))
boxplot(log2LFQimp,las=2)
colnames(log2LFQimp)<-colnames(log2LFQ)
log2LFQimpCorr<-cor(log2LFQ,use="pairwise.complete.obs",method="pearson")
colnames(log2LFQimpCorr)<-colnames(log2LFQ)
rownames(log2LFQimpCorr)<-colnames(log2LFQ)
svgPHC<-pheatmap::pheatmap(log2LFQimpCorr,clustering_distance_rows = "euclidean",clustering_distance_cols = "euclidean",fontsize_row=6,cluster_cols=T,cluster_rows=T,fontsize_col  = 6)#,annotation_row = annoR,annotation_col = annoR)
ggplot2::ggsave(paste0(inpF,selection,"cluster.svg"), svgPHC,width=10, height=8,dpi = 320)
#justVSN####
#BiocManager::install("vsn")
summary(log2LFQ)
LFQvsnMedVST <- vsn::justvsn(log2LFQ)
hist(LFQvsnMedVST)
vsn::meanSdPlot(LFQvsnMedVST)
vsn::meanSdPlot(LFQvsnMedVST,ranks = FALSE)
boxplot(LFQvsnMedVST,las=2)
countTableDAuniGORNAddsMed<-apply(LFQvsnMedVST,1,function(x) median(x,na.rm=T))
countTableDAuniGORNAddsSD<-apply(LFQvsnMedVST,1,function(x) sd(x,na.rm=T))
countTableDAuniGORNAdds<-(LFQvsnMedVST-countTableDAuniGORNAddsMed)#/countTableDAuniGORNAddsSD
hist(countTableDAuniGORNAdds)
boxplot(countTableDAuniGORNAdds,las=2)
dataLFQtdc<-cor(LFQvsnMedVST,use="pairwise.complete.obs",method="pearson")
pheatmap::pheatmap(dataLFQtdc)
#justVSN####
#BiocManager::install("vsn")
LFQ[LFQ==0]=NA
LFQvsn <- vsn::justvsn(LFQ)
write.csv(LFQvsn,paste0(inpF,"log2LFQvsn.csv"),row.names = T,quote = F)
hist(LFQvsn)
hist(log2LFQ)
vsn::meanSdPlot(log2LFQ)
vsn::meanSdPlot(LFQvsn)
vsn::meanSdPlot(log2LFQ,ranks = FALSE)
vsn::meanSdPlot(LFQvsn,ranks = FALSE)
boxplot(LFQvsn,las=2)
boxplot(log2LFQ,las=2)
hist(LFQvsn)
countTableDAuniGORNAddsMed<-apply(LFQvsn,1,function(x) median(x,na.rm=T))
countTableDAuniGORNAddsSD<-apply(LFQvsn,1,function(x) sd(x,na.rm=T))
countTableDAuniGORNAdds<-(LFQvsn-countTableDAuniGORNAddsMed)#/countTableDAuniGORNAddsSD
hist(countTableDAuniGORNAdds)
par(mar=c(12,3,1,1))
boxplot(countTableDAuniGORNAdds,las=2)
dataLFQtdc<-cor(LFQvsn,use="pairwise.complete.obs",method="pearson")
pheatmap::pheatmap(dataLFQtdc)
#test####
testT <- function(log2LFQ,sel1,sel2,cvThr,dfName){
  #sel1<-"FT"
  #sel2<-"FV"
  #log2LFQ<-log2LFQ#log2LFQsel#log2LFQ[,gsub("-",".",rownames(label[is.na(label$removed)|label$removed==" "|label$removed=='',]))]
  #colnames(log2LFQ)
  #dfName="log2LFQ"#"log2LFQsel"
  d1<-data.frame(log2LFQ[,label[label$pair2test==sel1,"File"]])
  colnames(d1)<-label[label$pair2test==sel1,"File"]
  d2<-data.frame(log2LFQ[,label[label$pair2test==sel2,"File"]])
  colnames(d2)<-label[label$pair2test==sel2,"File"]
  dataSellog2grpTtest<-merge(d1, d2, by = 'row.names', all = TRUE)
  summary(dataSellog2grpTtest)
  rN<-dataSellog2grpTtest[,1]
  geneName<-paste(sapply(strsplit(paste(sapply(strsplit(rN, "name: ",fixed=T), "[", 2)), ";;"), "[", 1))
  geneName<-paste(sapply(strsplit(paste(sapply(strsplit(paste(sapply(strsplit(rN, "|",fixed=T), "[", 2)), ";;"), "[", 1)), ";"), "[", 1))
  uniprotID<-paste(sapply(strsplit(paste(sapply(strsplit(paste(sapply(strsplit(rN, "|",fixed=T), "[", 2)), " "), "[", 1)), ":"), "[", 1))
  geneName[geneName=="NA"]=NA
  proteinFunction<-paste(sapply(strsplit(paste(sapply(strsplit(paste(sapply(strsplit(rN, "|",fixed=T), "[", 2)), ";;"), "[", 2)), ";"), "[", 1))
  proteinFunction[proteinFunction=="NA"]=NA
  proteinProcess<-paste(sapply(strsplit(paste(sapply(strsplit(paste(sapply(strsplit(rN, "|",fixed=T), "[", 2)), ";;"), "[", 3)), ";"), "[", 1))
  proteinProcess[proteinProcess=="NA"]=NA
  proteinComponent<-paste(sapply(strsplit(paste(sapply(strsplit(paste(sapply(strsplit(rN, "|",fixed=T), "[", 2)), ";;"), "[", 4)), ";"), "[", 1))
  proteinComponent[proteinComponent=="NA"]=NA
  dataSellog2grpTtest[,1]<-NULL
  dataSellog2grpTtest[dataSellog2grpTtest==0]=NA
  gene_id=sprintf("ENSG%011d",seq(1:nrow(dataSellog2grpTtest)))
  write.table(cbind(gene_id=gene_id,dataSellog2grpTtest),paste0(inpD,"/",sel1,sel2,dfName,"log2LFQ.tsv"),row.names = F,quote = F,sep="\t")
  dataSellog2grpTtestInt<-2^(dataSellog2grpTtest)
  dataSellog2grpTtestInt[is.na(dataSellog2grpTtestInt)]=0
  write.table(cbind(gene_id=gene_id,dataSellog2grpTtestInt),paste0(inpD,"/",sel1,sel2,dfName,"intLFQ.tsv"),row.names = F,quote = F,sep="\t")
  write.table(cbind(gene_id=gene_id,uniprotID,geneName,proteinFunction,rN),paste0(inpD,"/",sel1,sel2,dfName,"annotation.tsv"),row.names = F,quote = F,sep="\t")
  dataSellog2grpTtest<-as.matrix(dataSellog2grpTtest)
  log2IntimpCorr<-cor(dataSellog2grpTtest,use="pairwise.complete.obs",method="pearson")
  colnames(log2IntimpCorr)<-colnames(dataSellog2grpTtest)
  rownames(log2IntimpCorr)<-colnames(dataSellog2grpTtest)
  annoR<-data.frame(condition=c(rep(sel1,ncol(d1)),rep(sel2,ncol(d2))))
  rownames(annoR)<-colnames(dataSellog2grpTtest)
  print(annoR)
  svgPHC<-pheatmap::pheatmap(log2IntimpCorr,clustering_distance_rows = "euclidean",clustering_distance_cols = "euclidean",fontsize_row=8,cluster_cols=T,cluster_rows=T,fontsize_col  = 8,annotation_row = annoR, annotation_col = annoR)
  ggplot2::ggsave(paste0(inpF,selection,dfName,sel1,sel2,dfName,"Cluster.svg"), svgPHC)
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
      else if(sum(!is.na(x[c(sCol:mCol)]))>1&sum(!is.na(x[c((mCol+1):eCol)]))<1&(sd(x[c(sCol:mCol)],na.rm=T)/mean(x[c(sCol:mCol)],na.rm=T))<cvThr){0}
      else if(sum(!is.na(x[c(sCol:mCol)]))<1&sum(!is.na(x[c((mCol+1):eCol)]))>1&(sd(x[c((mCol+1):eCol)],na.rm=T)/mean(x[c((mCol+1):eCol)],na.rm=T))<cvThr){0}
      else if(sum(!is.na(x[c(sCol:mCol)]))>=2&sum(!is.na(x[c((mCol+1):eCol)]))>=1){
        t.test(as.numeric(x[c(sCol:mCol)]),as.numeric(x[c((mCol+1):eCol)]),na.rm=T,var.equal=T)$p.value}
      else if(sum(!is.na(x[c(sCol:mCol)]))>=1&sum(!is.na(x[c((mCol+1):eCol)]))>=2){
        t.test(as.numeric(x[c(sCol:mCol)]),as.numeric(x[c((mCol+1):eCol)]),na.rm=T,var.equal=T)$p.value}
      else{NA}
    )
    summary(warnings())
    summary(pValNA)
    if(sum(is.na(pValNA))<length(pValNA)){
      hist(pValNA)
      summary(pValNA)
      dfpValNA<-as.data.frame(ceiling(pValNA))
      pValNAdm<-cbind(pValNA,dataSellog2grpTtest,rN)
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
      ttest.results = data.frame(Uniprot=uniprotID,Protein=geneName,Function=proteinFunction,Process=proteinProcess,Component=proteinComponent,logFCmedianGrp1,logFCmedianGrp2,PValueMinusLog10=pValNAminusLog10,FoldChanglog2median=logFCmedianFC,CorrectedPValueBH=pValBHna,TtestPval=pValNA,dataSellog2grpTtest,Log2MedianChange=logFCmedian,grp1CV,grp2CV,RowGeneUniProtScorePeps=rN)
      ttest.results=ttest.results[order(ttest.results$CorrectedPValueBH),]
      writexl::write_xlsx(ttest.results,paste0(inpF,selection,sCol,eCol,comp,selThr,selThrFC,cvThr,dfName,"tTestBH.xlsx"))
      write.csv(ttest.results,paste0(inpF,selection,sCol,eCol,comp,selThr,selThrFC,cvThr,dfName,"tTestBH.csv"),row.names = F)
      ttest.results.return<-ttest.results
      #volcano
      ttest.results$RowGeneUniProtScorePeps<-ttest.results.return$Protein
      ttest.results[is.na(ttest.results)]=selThr
      Significance=ttest.results$CorrectedPValueBH<selThr&ttest.results$CorrectedPValueBH>0&abs(ttest.results$Log2MedianChange)>selThrFC
      dsub <- subset(ttest.results,Significance)
      p <- ggplot2::ggplot(ttest.results,ggplot2::aes(Log2MedianChange,PValueMinusLog10))+ ggplot2::geom_point(ggplot2::aes(color=Significance))
      p<-p + ggplot2::theme_bw(base_size=8) + ggplot2::geom_text(data=dsub,ggplot2::aes(label=RowGeneUniProtScorePeps),hjust=0, vjust=0,size=1,position=ggplot2::position_jitter(width=0.5,height=0.1)) + ggplot2::scale_fill_gradient(low="white", high="darkblue") + ggplot2::xlab("Log2 Median Change") + ggplot2::ylab("-Log10 P-value")
      #f=paste(file,proc.time()[3],".jpg")
      #install.packages("svglite")
      ggplot2::ggsave(paste0(inpF,selection,sCol,eCol,comp,selThr,selThrFC,cvThr,dfName,"VolcanoTest.svg"), p)
      print(p)
      return(sum(Significance))
    }
    else{return(0)}
  }
}
#compare####
summary(log2LFQ)
rownames(log2LFQ)<-rownames(dataMP)
dim(log2LFQ)
label<-data.frame(gsub("[0-9]","",colnames(log2LFQ)))
label$File=colnames(log2LFQ)
colnames(label)=c("pair2test","File")
table(label$pair2test)
for(i in rownames(table(label$pair2test))[2]){
  for(j in rownames(table(label$pair2test))){
    if(j!=i){
      print(paste(i,j))
      ttPair=testT(log2LFQ,j,i,cvThr,"log2LFQ")
      print(ttPair)
    }
  }
}
