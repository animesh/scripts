#F:\R-4.3.1\bin\Rscript.exe diffExprTestT.r "F:\OneDrive - NTNU\IRD\proteinGroups.txt" "f:\OneDrive - NTNU\IRD\Groups.txt" Group Rem
#setup
#install.packages(c("readxl","writexl","svglite","ggplot2","BiocManager"),repos="http://cran.us.r-project.org",lib=.libPaths())
#BiocManager::install(c("limma","pheatmap"),repos="http://cran.us.r-project.org",lib=.libPaths())
#install.packages("devtools")
#devtools::install_github("jdstorey/qvalue")
print("USAGE:<path to Rscript.exe> diffExprTestT.r <complete path to directory containing proteinGroups.txt> <complete path to directory containing Groups.txt files> <name of group column in Groups.txt annotating data/rows to be used for analysis> <name of column in Groups.txt marking data NOT to be considered in analysis>")
args = commandArgs(trailingOnly=TRUE)
print(paste("supplied argument(s):", length(args)))
print(args)
if (length(args) != 4) {stop("\n\nNeeds FOUR arguments, the full path of the directory containing BOTH proteinGroups.txt AND Groups.txt files followed by the name of GROUP-to-compare and data-to-REMOVE columns in Groups.txt file, for example:

c:/Users/animeshs/R-4.2.1-win/bin/Rscript.exe diffExprTestT.r \"L:/promec/TIMSTOF/Data/combined/txt/proteinGroups.txt\" \"L:/promec/TIMSTOF/Data/combined/txt/Groups.txt\" Groups Remove
", call.=FALSE)}
inpF <- args[1]
#inpF <-"L:/promec/HF/Lars/2023/231006 IRD DDA Kristine Solveig/txt/matchedFeatures.txt"
inpL <- args[2]
#inpL <-"L:/promec/HF/Lars/2023/231006 IRD DDA Kristine Solveig/txt/Groups.txt"
lGroup <- args[3]
#lGroup<-"Group"
rGroup <- args[4]
#rGroup<-"Remove"
inpD<-dirname(inpF)
fName<-basename(inpF)
lName<-basename(inpL)
selection<-"Intensity."
thr=0.0#count
selThr=0.05#pValue-tTest
selThrFC=0.5#log2-MedianDifference
cvThr=Inf#threshold for coefficient-of-variation
hdr<-gsub("[^[:alnum:]]", "",inpD)
outP=paste(inpF,selection,selThr,selThrFC,cvThr,hdr,lGroup,rGroup,lName,"VolcanoTestT","pdf",sep = ".")
pdf(outP)
#data####
data <- read.table(inpF,stringsAsFactors = FALSE, header = TRUE, quote = "", comment.char = "", sep = "\t")
##clean####
#data = data[!data$Reverse=="+",]
#data = data[!data$Potential.contaminant=="+",]
#data = data[!data$Only.identified.by.site=="+",]
#row.names(data)<-paste(row.names(data),data[,c(1:(grep(selection,colnames(data))[1]-1))],sep=";;")
summary(data)
dim(data)
LFQ<-as.matrix(data[,grep(selection,colnames(data))])
colnames(LFQ)=sub(selection,"",colnames(LFQ))
dim(LFQ)
log2LFQ<-log2(LFQ)
log2LFQ[log2LFQ==-Inf]=NA
log2LFQ[log2LFQ==0]=NA
summary(log2LFQ)
hist(log2LFQ,main=paste("Mean:",mean(log2LFQ,na.rm=T),"SD:",sd(log2LFQ,na.rm=T)),breaks=round(max(log2LFQ,na.rm=T)),xlim=range(min(log2LFQ,na.rm=T),max(log2LFQ,na.rm=T)))
par(mar=c(12,3,1,1))
boxplot(log2LFQ,las=2)
rowName<-paste(data$Mass,data$Calibrated.retention.time,data$m.z,data$Charge,data$Intensity,data$Sequence,sep=";;")
#writexl::write_xlsx(as.data.frame(cbind(rowName,log2LFQ,rownames(data))),paste0(inpD,"log2LFQ.xlsx"))
data$geneName<-paste(sapply(strsplit(paste(sapply(strsplit(data$Raw.files, ";",fixed=T), "[", 1)), " "), "[", 1))
data$uniprotID<-paste(sapply(strsplit(paste(sapply(strsplit(data$Multiplet.ids, ";",fixed=T), "[", 1)), "-"), "[", 1))
data[data$geneName=="NA","geneName"]=data[data$geneName=="NA","uniprotID"]
#label####
label<-read.table(inpL,header=T,sep="\t",row.names=1)#, colClasses=c(rep("factor",3)))
rownames(label)=sub(selection,"",rownames(label))
label["pair2test"]<-label[lGroup]
if(rGroup %in% colnames(label)){label["removed"]<-label[rGroup]} else{label["removed"]=NA}
print(label)
#anno####
annoFactor<-label[lGroup]
names(annoFactor)<-lGroup
anno<-data.frame(factor(label[,lGroup]))
row.names(anno)<-rownames(label)
names(anno)<-lGroup
table(anno)
annoR<-data.frame(factor(annoFactor[rownames(label[is.na(label$removed)|label$removed==" "|label$removed=='',]),]))
row.names(annoR)<-gsub("\\-","\\.",rownames(label[is.na(label$removed)|label$removed==" "|label$removed=='',]))
names(annoR)<-lGroup
summary(annoR)
#corHClfq####
log2LFQimpCorr<-cor(log2LFQ,use="pairwise.complete.obs",method="pearson")
colnames(log2LFQimpCorr)<-colnames(log2LFQ)
rownames(log2LFQimpCorr)<-colnames(log2LFQ)
svgPHC<-pheatmap::pheatmap(log2LFQimpCorr,clustering_distance_rows = "euclidean",clustering_distance_cols = "euclidean",fontsize_row=8,cluster_cols=T,cluster_rows=T,fontsize_col  = 8,annotation_row = annoR,annotation_col = annoR)
#test####
testT <- function(log2LFQ,sel1,sel2,cvThr){
  #sel1<-"D11N"
  #sel2<-"D20N"
  #log2LFQ<-log2LFQsel#[,gsub("-",".",rownames(label[label$Remove!="Y",]))]
  #log2LFQ<-sapply(log2LFQ, as.numeric)
  #colnames(log2LFQ)
  d1<-as.matrix(log2LFQ[,gsub("-",".",rownames(label[label$pair2test==sel1,]))])
  colnames(d1)<-gsub("-",".",rownames(label[label$pair2test==sel1,]))
  d2<-as.matrix(log2LFQ[,gsub("-",".",rownames(label[label$pair2test==sel2,]))])
  colnames(d2)<-gsub("-",".",rownames(label[label$pair2test==sel2,]))
  dataSellog2grpTtest<-as.matrix(cbind(d1,d2))
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
      else if((sum(x[c(sCol:mCol)],na.rm=T)-sum(x[c((mCol+1):eCol)],na.rm=T))==0){NA}
      else if(!is.na(sd(x[c(sCol:mCol)],na.rm=T))&sd(x[c(sCol:mCol)],na.rm=T)==0){NA}
      else if(!is.na(sd(x[c((mCol+1):eCol)],na.rm=T))&sd(x[c((mCol+1):eCol)],na.rm=T)==0){NA}
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
    if(length(pValNA)!=sum(is.na(pValNA))){
      summary(pValNA)
      hist(pValNA)
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
      #plot(hda)
      limma::vennDiagram(hda>0)
      logFCmedian = logFCmedianGrp1-logFCmedianGrp2
      logFCmedianFC = 2^(logFCmedian+.Machine$double.xmin)
      logFCmedianFC=squish(logFCmedianFC,c(0.01,100))
      hist(logFCmedianFC)
      log2FCmedianFC=log2(logFCmedianFC)
      hist(log2FCmedianFC)
      ttest.results = data.frame(Uniprot=rowName,Gene=data$geneName,Protein=data$Sequence,logFCmedianGrp1,logFCmedianGrp2,PValueMinusLog10=pValNAminusLog10,FoldChanglog2median=logFCmedianFC,CorrectedPValueBH=pValBHna,TtestPval=pValNA,dataSellog2grpTtest,Log2MedianChange=logFCmedian,grp1CV,grp2CV,RowGeneUniProtScorePeps=rownames(dataSellog2grpTtest))
      ttest.results[is.na(ttest.results)]=selThr
      Significance=ttest.results$CorrectedPValueBH<selThr&ttest.results$CorrectedPValueBH>0&abs(ttest.results$Log2MedianChange)>selThrFC
      sum(Significance)
      dsub <- subset(ttest.results,Significance)
      writexl::write_xlsx(dsub,paste0(inpF,selection,sCol,eCol,comp,selThr,selThrFC,cvThr,lGroup,rGroup,lName,"tTestBH.xlsx"))
      write.csv(dsub,paste0(inpF,selection,sCol,eCol,comp,selThr,selThrFC,cvThr,lGroup,rGroup,lName,"tTestBH.csv"),row.names = F)
      ttest.results.return<-ttest.results
      #volcano
      ttest.results$RowGeneUniProtScorePeps<-data$geneName
      p <- ggplot2::ggplot(ttest.results,ggplot2::aes(Log2MedianChange,PValueMinusLog10))+ ggplot2::geom_point(ggplot2::aes(color=Significance))
      p<-p + ggplot2::theme_bw(base_size=8) + ggplot2::geom_text(data=dsub,ggplot2::aes(label=RowGeneUniProtScorePeps),hjust=0, vjust=0,size=1,position=ggplot2::position_jitter(width=0.5,height=0.1)) + ggplot2::scale_fill_gradient(low="white", high="darkblue") + ggplot2::xlab("Log2 Median Change") + ggplot2::ylab("-Log10 P-value")
      #f=paste(file,proc.time()[3],".jpg")
      #install.packages("svglite")
      ggplot2::ggsave(paste0(inpF,selection,sCol,eCol,comp,selThr,selThrFC,cvThr,lGroup,rGroup,lName,"VolcanoTest.svg"), p)
      print(p)
      return(sum(Significance))
    }
    else{return(0)}
  }
}
#compare####
colnames(log2LFQ)
log2LFQsel=log2LFQ[,gsub("-",".",rownames(label[is.na(label$removed)|label$removed==" "|label$removed=='',]))]
colnames(log2LFQsel)
dim(log2LFQsel)
label=label[is.na(label$removed)|label$removed==" "|label$removed=='',]
table(label$pair2test)
for(i in rownames(table(label$pair2test))){
  for(j in rownames(table(label$pair2test))){
    if(i!=j){
      print(paste(i,j))
      ttPair=testT(log2LFQsel,i,j,cvThr)
      print(ttPair)
    }
  }
}
