#for %i in ("L:\promec\TIMSTOF\LARS\2022\july\Elise\combined\txt\corrected_order_TSH_update*.txt") do ("..\R\bin\Rscript.exe" "diffExprTestRank.r" "L:\promec\TIMSTOF\LARS\2022\july\Elise\combined\txt\proteinGroups.txt" "%i" "Intensity." "Cnt_vs_rec_cancer" "Cell" "Remove")
#setup
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
#inpF <-"L:/promec/TIMSTOF/LARS/2022/july/Elise/combined/txt/proteinGroups.txt"
inpL <- args[2]
#inpL <-"L:/promec/TIMSTOF/LARS/2022/july/Elise/combined/txt/corrected_order_TSH_update_lower.txt"
selection<-args[3]
#selection<-"Intensity."#"LFQ.intensity."
lGroup <- args[4]
#lGroup<-"Cnt_vs_rec_cancer"
scaleF <- args[5]
#scaleF<-"Cell"
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
##clean####
#data = data[!data$Reverse=="+",]
#data = data[!data$Potential.contaminant=="+",]
#data = data[!data$Only.identified.by.site=="+",]
row.names(data)<-paste(row.names(data),data$Fasta.headers,data$Protein.IDs,data$Protein.names,data$Gene.names,data$Score,data$Peptide.counts..unique.,sep=";;")
summary(data)
dim(data)
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
log2IntimpCorr<-cor(log2Int,use="pairwise.complete.obs",method="spearman")
colnames(log2IntimpCorr)<-colnames(log2Int)
rownames(log2IntimpCorr)<-colnames(log2Int)
summary(log2IntimpCorr)
hist(log2IntimpCorr)
svgPHC<-pheatmap::pheatmap(log2IntimpCorr,annotation_row = anno, annotation_col = anno,clustering_distance_rows = "euclidean",clustering_distance_cols = "euclidean",fontsize_row=4,cluster_cols=T,cluster_rows=T,fontsize_col=4)
ggplot2::ggsave(paste0(inpF,lName,lGroup,"heatmap.spearman.intensity.svg"), svgPHC)
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
rowName<-paste(sapply(strsplit(paste(sapply(strsplit(data$Fasta.headers, "|",fixed=T), "[", 2)), "-"), "[", 1))
writexl::write_xlsx(as.data.frame(cbind(rowName,log2LFQ,rownames(data))),paste0(inpD,selection,"log2.xlsx"))
data$geneName<-paste(sapply(strsplit(paste(sapply(strsplit(data$Gene.names, ";",fixed=T), "[", 1)), " "), "[", 1))
data$uniprotID<-paste(sapply(strsplit(paste(sapply(strsplit(data$Protein.IDs, ";",fixed=T), "[", 1)), "-"), "[", 1))
data[data$geneName=="NA","geneName"]=data[data$geneName=="NA","uniprotID"]
#corHClfq####
log2LFQimp<-matrix(rnorm(dim(log2LFQ)[1]*dim(log2LFQ)[2],mean=mean(log2LFQ,na.rm = T)-scale,sd=sd(log2LFQ,na.rm = T)/(scale)), dim(log2LFQ)[1],dim(log2LFQ)[2])
log2LFQimp[log2LFQimp<0]<-0
par(mar=c(12,3,1,1))
boxplot(log2LFQimp,las=2,main=paste("imp",selection))
colnames(log2LFQimp)<-colnames(log2LFQ)
log2LFQimpCorr<-cor(log2LFQ,use="pairwise.complete.obs",method="spearman")
colnames(log2LFQimpCorr)<-colnames(log2LFQ)
rownames(log2LFQimpCorr)<-colnames(log2LFQ)
summary(log2LFQimpCorr)
hist(log2LFQimpCorr)
svgPHC<-pheatmap::pheatmap(log2LFQimpCorr,annotation_row = annoR,annotation_col = annoR,clustering_distance_rows = "euclidean",clustering_distance_cols = "euclidean",fontsize_row=4,cluster_cols=T,cluster_rows=T,fontsize_col=4)
ggplot2::ggsave(paste0(inpF,lName,lGroup,selection,"heatmap.log2LFQ.spearman.svg"), svgPHC)
#ratioCor####
dim(log2LFQ)
#log2LFQ[,"standard_a_Slot2.54_1_1984"]
colnames(log2LFQ)
log2LFQselect=log2LFQ[,gsub("-",".",rownames(label[is.na(label$removed)|label$removed==" "|label$removed=='',]))]
log2LFQsel=log2LFQselect
dim(log2LFQsel)
hist(log2LFQsel)
ratioFactor<-data.matrix(label[scaleF])
row.names(ratioFactor)<-rownames(label)
ratioFactor<-ratioFactor[rownames(label[is.na(label$removed)|label$removed==" "|label$removed=='',]),]
hist(ratioFactor)
summary(log2LFQsel)
log2LFQselCor<-log2LFQsel
summary(log2LFQselCor)
for(i in colnames(log2LFQsel)){
  print(i)
  print(ratioFactor[i])
  print(summary(log2LFQsel[,i]))
  print(summary(log2LFQsel[,i]-log2(ratioFactor[i])))
  log2LFQselCor[,i]<-log2LFQsel[,i]-log2(ratioFactor[i])
  print(summary(log2LFQselCor[,i]))
}
summary(log2LFQselCor)
hist(log2LFQselCor)
boxplot(log2LFQselCor,las=2,main=paste(selection,scaleF,"log2LFQselCor"))
write.csv(log2LFQselCor,paste0(inpF,lName,lGroup,selection,scaleF,".log2LFQselCor.csv"))
log2IntimpCorr<-cor(log2LFQselCor,use="pairwise.complete.obs",method="spearman")
colnames(log2IntimpCorr)<-colnames(log2LFQselCor)
rownames(log2IntimpCorr)<-colnames(log2LFQselCor)
svgPHC<-pheatmap::pheatmap(log2IntimpCorr,annotation_row = annoR,annotation_col = annoR,clustering_distance_rows = "euclidean",clustering_distance_cols = "euclidean",fontsize_row=4,cluster_cols=T,cluster_rows=T,fontsize_col=4)
ggplot2::ggsave(paste0(inpF,lName,lGroup,selection,scaleF,"heatmap.log2IntimpCorr.spearman.svg"), svgPHC)
#minmaxScale####
colnames(log2LFQselCor)
log2LFQsel<-log2LFQselCor
summary(log2LFQsel)
maxM=matrix(rep(apply(log2LFQsel,2,function(x) max(x,na.rm=T)),each=nrow(log2LFQsel)),nrow=nrow(log2LFQsel),ncol=ncol(log2LFQsel))
minM=matrix(rep(apply(log2LFQsel,2,function(x) min(x,na.rm=T)),each=nrow(log2LFQsel)),nrow=nrow(log2LFQsel),ncol=ncol(log2LFQsel))
log2LFQselScale=(log2LFQsel-minM)/(maxM-minM)
summary(log2LFQselScale)
log2LFQselMM<-log2LFQselScale
summary(log2LFQselMM)
par(mar=c(12,3,1,1))
boxplot(log2LFQselScale,las=2,main=paste(selection,"minMax"))
write.csv(log2LFQselScale,paste0(inpF,lName,lGroup,selection,scaleF,".log2LFQselScale.minMax.csv"))
#corHCminmax####
hist(log2LFQselScale)
log2LFQselScaleimp<-matrix(rnorm(dim(log2LFQselScale)[1]*dim(log2LFQselScale)[2],mean=mean(log2LFQselScale,na.rm = T)-scale,sd=sd(log2LFQselScale,na.rm = T)/(scale)), dim(log2LFQselScale)[1],dim(log2LFQselScale)[2])
hist(log2LFQselScaleimp)
par(mar=c(12,3,1,1))
boxplot(log2LFQselScaleimp,las=2,main=paste(selection,"minMaxImp"))
#log2LFQselScaleimp[log2LFQselScaleimp<0]<-0
#colnames(log2LFQselScaleimp)<-colnames(log2LFQselScale)
log2LFQselScaleimpCorr<-cor(log2LFQselScale,use="pairwise.complete.obs",method="spearman")
hist(log2LFQselScaleimpCorr)
colnames(log2LFQselScaleimpCorr)<-colnames(log2LFQselScale)
rownames(log2LFQselScaleimpCorr)<-colnames(log2LFQselScale)
svgPHC<-pheatmap::pheatmap(log2LFQselScaleimpCorr,annotation_row = annoR,annotation_col = annoR,clustering_distance_rows = "euclidean",clustering_distance_cols = "euclidean",fontsize_row=4,cluster_cols=T,cluster_rows=T,fontsize_col=4)
ggplot2::ggsave(paste0(inpF,lName,lGroup,selection,scaleF,"heatmap.minMax.spearman.svg"), svgPHC)
#test####
testWilcox <- function(log2LFQ,log2LFQselCor,log2LFQselect,sel1,sel2,cvThr,cmpData){
  #sel1<-i#"PIN"
  #sel2<-j#"PNI"#HGcancer"
  #cmpData<-"rawInt"
  #log2LFQ<-log2LFQselScale#[,gsub("-",".",rownames(label[label$Remove!="Y",]))]
  #hist(log2LFQ)
  #colnames(log2LFQ)
  d1<-data.frame(log2LFQ[,gsub("-",".",rownames(label[label$pair2test==sel1,]))])
  rNd1<-rownames(d1)
  d1<-sapply(d1, as.numeric)
  rownames(d1)<-rNd1
  colnames(d1)<-rownames(label[label$pair2test==sel1,])
  summary(d1)
  d2<-data.frame(log2LFQ[,gsub("-",".",rownames(label[label$pair2test %in% sel2,]))])
  rNd2<-rownames(d2)
  d2<-sapply(d2, as.numeric)
  rownames(d2)<-rNd2
  colnames(d2)<-rownames(label[label$pair2test %in% sel2,])
  summary(d2)
  dataSellog2grpwilcoxTest<-as.matrix(cbind(d1,d2))
  hist(log2LFQselCor)
  e1<-data.frame(log2LFQselCor[,gsub("-",".",rownames(label[label$pair2test==sel1,]))])
  rNe1<-rownames(e1)
  e1<-sapply(e1, as.numeric)
  rownames(e1)<-rNe1
  colnames(e1)<-rownames(label[label$pair2test==sel1,])
  summary(e1)
  e2<-data.frame(log2LFQselCor[,gsub("-",".",rownames(label[label$pair2test %in% sel2,]))])
  rNe2<-rownames(e2)
  e2<-sapply(e2, as.numeric)
  rownames(e2)<-rNe2
  colnames(e2)<-rownames(label[label$pair2test %in% sel2,])
  summary(e2)
  datalog2LFQselCor<-as.matrix(cbind(e1,e2))
  hist(log2LFQsel)
  f1<-data.frame(log2LFQselect[,gsub("-",".",rownames(label[label$pair2test==sel1,]))])
  rNf1<-rownames(f1)
  f1<-sapply(f1, as.numeric)
  rownames(f1)<-rNf1
  colnames(f1)<-rownames(label[label$pair2test==sel1,])
  summary(f1)
  f2<-data.frame(log2LFQselect[,gsub("-",".",rownames(label[label$pair2test %in% sel2,]))])
  rNf2<-rownames(f2)
  f2<-sapply(f2, as.numeric)
  rownames(f2)<-rNf2
  colnames(f2)<-rownames(label[label$pair2test %in% sel2,])
  summary(f2)
  datalog2LFQsel<-as.matrix(cbind(f1,f2))
  hist(datalog2LFQsel)
  if(sum(!is.na(d1))>1&sum(!is.na(d2))>1){
    hist(d1)
    hist(d2)
    #assign(paste0("hda",sel1,sel2),dataSellog2grpwilcoxTest)
    #get(paste0("hda",sel1,sel2))
    hist(dataSellog2grpwilcoxTest)
    row.names(dataSellog2grpwilcoxTest)<-row.names(data)
    comp<-paste0(sel1)#,sel2)
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
    #ratioCor
    log2LFQselCormedianGrp1=if(is.null(dim(datalog2LFQselCor[,c(sCol:mCol)]))){datalog2LFQselCor[,c(sCol:mCol)]} else{apply(datalog2LFQselCor[,c(sCol:mCol)],1,function(x) median(x,na.rm=T))}
    log2LFQselCormeanGrp1=if(is.null(dim(datalog2LFQselCor[,c(sCol:mCol)]))){datalog2LFQselCor[,c(sCol:mCol)]} else{apply(datalog2LFQselCor[,c(sCol:mCol)],1,function(x) mean(x,na.rm=T))}
    grplog2LFQselCor1CV=if(is.null(dim(datalog2LFQselCor[,c(sCol:mCol)]))){datalog2LFQselCor[,c(sCol:mCol)]} else{apply(datalog2LFQselCor[,c(sCol:mCol)],1,function(x) sd(x,na.rm=T)/mean(x,na.rm=T))}
    #summary(log2LFQselCormedianGrp11-log2LFQselCormedianGrp1)
    log2LFQselCormedianGrp2=if(is.null(dim(datalog2LFQselCor[,c((mCol+1):eCol)]))){datalog2LFQselCor[,c((mCol+1):eCol)]} else{apply(datalog2LFQselCor[,c((mCol+1):eCol)],1,function(x) median(x,na.rm=T))}
    log2LFQselCormeanGrp2=if(is.null(dim(datalog2LFQselCor[,c((mCol+1):eCol)]))){datalog2LFQselCor[,c((mCol+1):eCol)]} else{apply(datalog2LFQselCor[,c((mCol+1):eCol)],1,function(x) mean(x,na.rm=T))}
    grplog2LFQselCor2CV=if(is.null(dim(datalog2LFQselCor[,c((mCol+1):eCol)]))){datalog2LFQselCor[,c((mCol+1):eCol)]} else{apply(datalog2LFQselCor[,c((mCol+1):eCol)],1,function(x) sd(x,na.rm=T)/mean(x,na.rm=T))}
    log2LFQselCormedianGrp1[is.na(log2LFQselCormedianGrp1)]=0
    log2LFQselCormedianGrp2[is.na(log2LFQselCormedianGrp2)]=0
    log2meanDiffCor = log2LFQselCormeanGrp1-log2LFQselCormeanGrp2
    log2medianDiffCor = log2LFQselCormedianGrp1-log2LFQselCormedianGrp2
    #select
    log2LFQselmedianGrp1=if(is.null(dim(datalog2LFQsel[,c(sCol:mCol)]))){datalog2LFQsel[,c(sCol:mCol)]} else{apply(datalog2LFQsel[,c(sCol:mCol)],1,function(x) median(x,na.rm=T))}
    log2LFQselmeanGrp1=if(is.null(dim(datalog2LFQsel[,c(sCol:mCol)]))){datalog2LFQsel[,c(sCol:mCol)]} else{apply(datalog2LFQsel[,c(sCol:mCol)],1,function(x) mean(x,na.rm=T))}
    grplog2LFQsel1CV=if(is.null(dim(datalog2LFQsel[,c(sCol:mCol)]))){datalog2LFQsel[,c(sCol:mCol)]} else{apply(datalog2LFQsel[,c(sCol:mCol)],1,function(x) sd(x,na.rm=T)/mean(x,na.rm=T))}
    #summary(log2LFQselmedianGrp11-log2LFQselmedianGrp1)
    log2LFQselmedianGrp2=if(is.null(dim(datalog2LFQsel[,c((mCol+1):eCol)]))){datalog2LFQsel[,c((mCol+1):eCol)]} else{apply(datalog2LFQsel[,c((mCol+1):eCol)],1,function(x) median(x,na.rm=T))}
    log2LFQselmeanGrp2=if(is.null(dim(datalog2LFQsel[,c((mCol+1):eCol)]))){datalog2LFQsel[,c((mCol+1):eCol)]} else{apply(datalog2LFQsel[,c((mCol+1):eCol)],1,function(x) mean(x,na.rm=T))}
    grplog2LFQsel2CV=if(is.null(dim(datalog2LFQsel[,c((mCol+1):eCol)]))){datalog2LFQsel[,c((mCol+1):eCol)]} else{apply(datalog2LFQsel[,c((mCol+1):eCol)],1,function(x) sd(x,na.rm=T)/mean(x,na.rm=T))}
    log2LFQselmedianGrp1[is.na(log2LFQselmedianGrp1)]=0
    log2LFQselmedianGrp2[is.na(log2LFQselmedianGrp2)]=0
    log2meanDiffSel = log2LFQselmeanGrp1-log2LFQselmeanGrp2
    log2medianDiffSel = log2LFQselmedianGrp1-log2LFQselmedianGrp2
    wilcoxTest.results = data.frame(Uniprot=rowName,Gene=data$Gene.names,Protein=data$Protein.names,logFCmedianGrp1,logFCmedianGrp2,PValueMinusLog10=pValNAminusLog10,FoldChanglog2median=logFCmedianFC,CorrectedPValueBH=pValBHna,WilcoxTestPval=pValNA,dataSellog2grpwilcoxTest,Log2MedianChange=logFCmedian,grp1CV,grp2CV,log2meanDiff,log2LFQselmeanGrp1,grplog2LFQsel1CV,log2medianDiffSel,log2meanDiffSel,log2LFQselCormeanGrp1,grplog2LFQselCor1CV,log2meanDiffCor,log2medianDiffCor,RowGeneUniProtScorePeps=rownames(dataSellog2grpwilcoxTest))
    writexl::write_xlsx(wilcoxTest.results,paste0(inpF,selection,scaleF,sCol,eCol,comp,selThr,selThrFC,cvThr,lGroup,rGroup,lName,cmpData,"WilcoxTestBH.xlsx"))
    write.csv(wilcoxTest.results,paste0(inpF,selection,scaleF,sCol,eCol,comp,selThr,selThrFC,cvThr,lGroup,rGroup,lName,cmpData,"WilcoxTestBH.csv"),row.names = F)
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
    ggplot2::ggsave(paste0(inpF,selection,scaleF,sCol,eCol,comp,selThr,selThrFC,cvThr,lGroup,rGroup,lName,cmpData,"VolcanoTestWilcox.svg"), p)
    print(p)
    return(wilcoxTest.results.return)
  }
}
#compare####
summary(log2LFQselScale)
colnames(log2LFQselScale)
dim(log2LFQselScale)
hist(log2LFQselCor)
hist(log2LFQselScale)
wilcox.test(seq(1,4),seq(5,9))
wilcox.test(seq(0.1,0.4,0.1),seq(0.5,0.9,0.1))
label=label[is.na(label$removed)|label$removed==" "|label$removed=='',]
table(label$pair2test)
cnt=0
for(i in 1:length(rownames(table(label$pair2test)))){
  cnt=cnt+1
  i=rownames(table(label$pair2test))[cnt]
  j=rownames(table(label$pair2test))[-cnt]
  print(paste(i,j))
  rtPair=testWilcox(log2LFQselCor,log2LFQselCor,log2LFQselect,i,j,cvThr,"rawInt")
  #assign(paste0(i,j),ttPair)
}
cnt=0
for(i in 1:length(rownames(table(label$pair2test)))){
  cnt=cnt+1
  i=rownames(table(label$pair2test))[cnt]
  j=rownames(table(label$pair2test))[-cnt]
  print(paste(i,j))
  rtPair=testWilcox(log2LFQselScale,log2LFQselCor,log2LFQselect,i,j,cvThr,"minMax")
  #assign(paste0(i,j),ttPair)
}
