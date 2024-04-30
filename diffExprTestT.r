#git checkout master diffExprTestT.r
#Rscript.exe diffExprTestT.r L:\promec\TIMSTOF\LARS\2024\240207_Deo\combined\txt\proteinGroups.txt L:\promec\TIMSTOF\LARS\2024\240207_Deo\combined\txt\GroupsG.txt Bio Rem
#setup
#install.packages(c("readxl","writexl","svglite","ggplot2","BiocManager"),repos="http://cran.us.r-project.org",lib=.libPaths())
#BiocManager::install(c("limma","pheatmap"))#,repos="http://cran.us.r-project.org",lib=.libPaths())
#install.packages("devtools")
#devtools::install_github("jdstorey/qvalue")
print("USAGE:<path to Rscript.exe> diffExprTestT.r <complete path to directory containing proteinGroups.txt> <complete path to directory containing Groups.txt files> <name of group column in Groups.txt annotating data/rows to be used for analysis> <name of column in Groups.txt marking data NOT to be considered in analysis>")
args = commandArgs(trailingOnly=TRUE)
print(paste("supplied argument(s):", length(args)))
print(args)
if (length(args) != 4) {stop("\n\nNeeds FOUR arguments, the full path of the directory containing BOTH proteinGroups.txt AND Groups.txt files followed by the name of GROUP-to-compare and data-to-REMOVE columns in Groups.txt file, for example:

c:/R/bin/Rscript.exe diffExprTestT.r \"C:/Data/combined/txt/proteinGroups.txt\" \"C:/Data/combined/txt/Groups.txt\" Groups Remove
", call.=FALSE)}
inpF <- args[1]
#inpF <-"L:/promec/TIMSTOF/LARS/2024/240207_Deo/combined/txt/proteinGroups.txt"
inpL <- args[2]
#inpL <-"L:/promec/TIMSTOF/LARS/2024/240207_Deo/combined/txt/GroupsG.txt"
lGroup <- args[3]
#lGroup<-"Bio"
rGroup <- args[4]
#rGroup<-"Rem"
inpD<-dirname(inpF)
fName<-basename(inpF)
lName<-basename(inpL)
selection<-"LFQ.intensity."
thr=0.0#count
selThr=0.1#pValue-tTest
selThrFC=1#log2-MedianDifference
cvThr=0.05#threshold for coefficient-of-variation
hdr<-gsub("[^[:alnum:]]", "",inpD)
outP=paste(inpF,selection,selThr,selThrFC,cvThr,hdr,lGroup,rGroup,lName,"VolcanoTestT","pdf",sep = ".")
pdf(outP)
#data####
data <- read.table(inpF,stringsAsFactors = FALSE, header = TRUE, quote = "", comment.char = "", sep = "\t")
##clean####
data = data[!data$Reverse=="+",]
data = data[!data$Potential.contaminant=="+",]
#data = data[!data$Only.identified.by.site=="+",]
row.names(data)<-paste(row.names(data),data$Fasta.headers,data$Protein.IDs,data$Score,data$Peptide.counts..unique.,sep=";;")
summary(data)
dim(data)
log2Int<-as.matrix(log2(data[,grep("Intensity",colnames(data))]))
log2Int[log2Int==-Inf]=NA
hist(log2Int,main=paste("Mean:",mean(log2Int,na.rm=T),"SD:",sd(log2Int,na.rm=T)),breaks=round(max(log2Int,na.rm=T)),xlim=range(min(log2Int,na.rm=T),max(log2Int,na.rm=T)))
summary(log2(data[,grep("Intensity",colnames(data))]))
#corHCint####
scale=3
log2Intimp<-matrix(rnorm(dim(log2Int)[1]*dim(log2Int)[2],mean=mean(log2Int,na.rm = T)-scale,sd=sd(log2Int,na.rm = T)/(scale)), dim(log2Int)[1],dim(log2Int)[2])
log2Intimp[log2Intimp<0]<-0
bk1 <- c(seq(-3,-0.01,by=0.01))
bk2 <- c(seq(0.01,3,by=0.01))
bk <- c(bk1,bk2)  #combine the break limits for purpose of graphing
my_palette <- c(colorRampPalette(colors = c("darkblue", "white"))(n = length(bk1)-1),"gray", "gray",c(colorRampPalette(colors = c("white","darkred"))(n = length(bk2)-1)))
colnames(log2Intimp)<-colnames(log2Int)
log2IntimpCorr<-cor(log2Int,use="pairwise.complete.obs",method="spearman")
colnames(log2IntimpCorr)<-colnames(log2Int)
rownames(log2IntimpCorr)<-colnames(log2Int)
svgPHC<-pheatmap::pheatmap(log2IntimpCorr,clustering_distance_rows = "euclidean",clustering_distance_cols = "euclidean",fontsize_row=8,cluster_cols=T,cluster_rows=T,fontsize_col  = 8)
#maxLFQ####
LFQ<-as.matrix(data[,grep(selection,colnames(data))])
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
rowName<-paste(sapply(strsplit(paste(sapply(strsplit(data$Fasta.headers, "|",fixed=T), "[", 2)), "-"), "[", 1))
writexl::write_xlsx(as.data.frame(cbind(rowName,log2LFQ,rownames(data))),paste0(inpD,"log2LFQ.xlsx"))
#label####
label<-read.table(inpL,header=T,sep="\t",row.names=1)#, colClasses=c(rep("factor",3)))
rownames(label)=sub(selection,"",rownames(label))
label["pair2test"]<-label[lGroup]
if(rGroup %in% colnames(label)){label["removed"]<-label[rGroup]} else{label["removed"]=NA}
print(label)
#corHClfq####
log2LFQimp<-matrix(rnorm(dim(log2LFQ)[1]*dim(log2LFQ)[2],mean=mean(log2LFQ,na.rm = T)-scale,sd=sd(log2LFQ,na.rm = T)/(scale)), dim(log2LFQ)[1],dim(log2LFQ)[2])
log2LFQimp[log2LFQimp<0]<-0
colnames(log2LFQimp)<-colnames(log2LFQ)
log2LFQimpCorr<-cor(log2LFQ,use="pairwise.complete.obs",method="spearman")
colnames(log2LFQimpCorr)<-colnames(log2LFQ)
rownames(log2LFQimpCorr)<-colnames(log2LFQ)
svgPHC<-pheatmap::pheatmap(log2LFQimpCorr,clustering_distance_rows = "euclidean",clustering_distance_cols = "euclidean",fontsize_row=8,cluster_cols=T,cluster_rows=T,fontsize_col  = 8)
#test####
testT <- function(log2LFQselect,sel1,sel2,cvThr){
  #sel1<-"G25_CDK12"
  #sel2<-"G25_IgG"
  #log2LFQselect<-log2LFQ[,gsub("-",".",rownames(label[is.na(label$removed)|label$removed==" "|label$removed=='',]))]
  #colnames(log2LFQselect)
  d1<-data.frame(log2LFQselect[,gsub("-",".",rownames(label[label$pair2test==sel1,]))])
  colnames(d1)<-gsub("-",".",rownames(label[label$pair2test==sel1,]))
  d2<-data.frame(log2LFQselect[,gsub("-",".",rownames(label[label$pair2test==sel2,]))])
  colnames(d2)<-gsub("-",".",rownames(label[label$pair2test==sel2,]))
  dataSellog2grpTtest<-merge(d1, d2, by = 'row.names', all = TRUE)
  rN<-dataSellog2grpTtest[,1]
  geneName<-paste(sapply(strsplit(paste(sapply(strsplit(paste(sapply(strsplit(rN, "GN=",fixed=T), "[", 2)), "PE="), "[", 1)), ";"), "[", 1))
  uniprotID<-paste(sapply(strsplit(paste(sapply(strsplit(paste(sapply(strsplit(rN, "|",fixed=T), "[", 2)), " "), "[", 1)), "-"), "[", 1))
  dataSellog2grpTtest[,1]<-NULL
  dataSellog2grpTtest[dataSellog2grpTtest==0]=NA
  dataSellog2grpTtest<-as.matrix(dataSellog2grpTtest)
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
      logFCmedian = logFCmedianGrp1-logFCmedianGrp2
      logFCmedianFC = 2^(logFCmedian+.Machine$double.xmin)
      logFCmedianFC=squish(logFCmedianFC,c(0.01,100))
      hist(logFCmedianFC)
      log2FCmedianFC=log2(logFCmedianFC)
      hist(log2FCmedianFC)
      ttest.results.return = data.frame(Uniprot=uniprotID,Gene=geneName,logFCmedianGrp1,logFCmedianGrp2,PValueMinusLog10=pValNAminusLog10,FoldChanglog2median=logFCmedianFC,CorrectedPValueBH=pValBHna,TtestPval=pValNA,dataSellog2grpTtest,Log2MedianChange=logFCmedian,grp1CV,grp2CV,RowGeneUniProtScorePeps=rN)
      ttest.results<-ttest.results.return
      ttest.results.return<-ttest.results.return[order(ttest.results.return$Log2MedianChange,decreasing = T),]
      ttest.results.return<-ttest.results.return[order(ttest.results.return$CorrectedPValueBH),]
      writexl::write_xlsx(ttest.results.return,paste0(inpF,selection,sCol,eCol,comp,selThr,selThrFC,cvThr,lGroup,rGroup,lName,"tTestBH.xlsx"))
      write.csv(ttest.results.return,paste0(inpF,selection,sCol,eCol,comp,selThr,selThrFC,cvThr,lGroup,rGroup,lName,"tTestBH.csv"),row.names = F)
      #volcano
      ttest.results$RowGeneUniProtScorePeps<-geneName
      ttest.results[is.na(ttest.results)]=selThr
      Significance=ttest.results$CorrectedPValueBH<selThr&ttest.results$CorrectedPValueBH>0&abs(ttest.results$Log2MedianChange)>selThrFC
      dsub <- subset(ttest.results,Significance)
      p <- ggplot2::ggplot(ttest.results,ggplot2::aes(Log2MedianChange,PValueMinusLog10))+ ggplot2::geom_point(ggplot2::aes(color=Significance))
      p<-p + ggplot2::theme_bw(base_size=8) + ggplot2::geom_text(data=dsub,ggplot2::aes(label=RowGeneUniProtScorePeps),hjust=0, vjust=0,size=1,position=ggplot2::position_jitter(width=0.5,height=0.1)) + ggplot2::scale_fill_gradient(low="white", high="darkblue") + ggplot2::xlab("Log2 Median Change") + ggplot2::ylab("-Log10 P-value")
      #f=paste(file,proc.time()[3],".jpg")
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
  for(j in rownames(table(label$pair2test))[4]){
    if(i!=j){
      print(paste(i,j))
      ttPair=testT(log2LFQsel,i,j,cvThr)
      print(ttPair)
    }
  }
}
