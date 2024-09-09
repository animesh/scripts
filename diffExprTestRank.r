#C:\users\animeshs\R-4.4.0\bin\Rscript.exe diffExprTestRank.r "L:\promec\TIMSTOF\LARS\2024\240827_Bead_test\combined\txtDDA\proteinGroups.txt" "L:\promec\TIMSTOF\LARS\2024\240827_Bead_test\combined\txtDDA\Groups.txt" "Bio" "Rem"
#setup####
#install.packages(c("readxl","writexl","svglite","ggplot2","BiocManager"),repos="http://cran.us.r-project.org",lib=.libPaths())
#BiocManager::install(c("limma","pheatmap"),repos="http://cran.us.r-project.org",lib=.libPaths())
#install.packages("devtools")
#devtools::install_github("jdstorey/qvalue")
print("USAGE:<path to>Rscript diffExprTestRank.r <complete path to directory containing proteinGroups.txt> <Groups.txt file> <name of group column in Groups.txt annotating data/rows to be used for analysis> <name of column in Groups.txt marking data NOT to be considered in analysis>")
args = commandArgs(trailingOnly=TRUE)
print(paste("supplied argument(s):", length(args)))
print(args)
if (length(args) != 4) {stop("\n\nNeeds 4 arguments, the full path of the directory containing BOTH proteinGroups.txt AND Groups.txt files followed by the name column to use for Intensity, GROUP-to-compare, column to correct for, and data-to-REMOVE columns in Groups.txt file, for example: c:/Users/animeshs/R-4.2.1-win/bin/Rscript.exe diffExprTestRank.r L:/promec/TIMSTOF/LARS/2023/Data/combined/txtMC3MS3010/proteinGroups.txt L:/promec/TIMSTOF/LARS/2023/Data/combined/txtMC0/Groups.txt Group Rem", call.=FALSE)}
#args####
inpF <- args[1]
#inpF <-"L:/promec/TIMSTOF/LARS/2024/240827_Bead_test/combined/txtDDA/proteinGroups.txt"
inpL <- args[2]
#inpL <-"L:/promec/TIMSTOF/LARS/2024/240827_Bead_test/combined/txtDDA/Groups.txt"
lGroup <- args[3]
#lGroup<-"Bio"
rGroup <- args[4]
#rGroup<-"Rem"
inpD<-dirname(inpF)
fName<-basename(inpF)
lName<-basename(inpL)
selection<-"Intensity."
thr=0.0#count
selThr=0.1#pValue-WilcoxTest
selThrFC=0.01#log2-MedianMinMaxDifference
cvThr=Inf#threshold for coefficient-of-variation
scale=3#impute
set.seed(scale)
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
data$geneName<-paste(sapply(strsplit(paste(sapply(strsplit(data$Fasta.headers, "GN=",fixed=T), "[", 2)), " "), "[", 1))
data$uniprotID<-paste(sapply(strsplit(paste(sapply(strsplit(data$Protein.IDs, ";",fixed=T), "[", 1)), " "), "[", 1))
data[data$geneName=="NA","geneName"]=data[data$geneName=="NA","uniprotID"]
row.names(data)<-paste(row.names(data),data$uniprotID,data$geneName,data$Fasta.headers,data$Score,data$Peptide.counts..unique.,sep=";;")
summary(data)
dim(data)
#minmaxScale####
minmaxScale <- function(log2LFQsel) {
  summary(log2LFQsel)
  maxM=matrix(rep(apply(log2LFQsel,2,function(x) max(x,na.rm=T)),each=nrow(log2LFQsel)),nrow=nrow(log2LFQsel),ncol=ncol(log2LFQsel))
  minM=matrix(rep(apply(log2LFQsel,2,function(x) min(x,na.rm=T)),each=nrow(log2LFQsel)),nrow=nrow(log2LFQsel),ncol=ncol(log2LFQsel))
  log2LFQselScale=(log2LFQsel-minM)/(maxM-minM)
  return(log2LFQselScale)
}
#test####
testWilcox <- function(log2LFQmm,sel1,sel2,fName){
  #log2LFQmm<-log2LFQselMM
  #sel1<-"aptes"
  #sel2<-setdiff(names(table(label[,lGroup])),sel1)
  #fName<-"minMaxLog2LFQ"
  d1<-data.frame(log2LFQmm[,rownames(label[label[,lGroup]==sel1,])])
  rNd1<-rownames(d1)
  d1<-sapply(d1, as.numeric)
  rownames(d1)<-rNd1
  #colnames(d1)<-rownames(label[label$pair2test==sel1,])
  hist(d1)
  #summary(d1)
  d2<-data.frame(log2LFQmm[,rownames(label[label[,lGroup] %in% sel2,])])
  rNd2<-rownames(d2)
  d2<-sapply(d2, as.numeric)
  rownames(d2)<-rNd2
  #summary(d2)
  hist(d2)
  dataSellog2grpwilcoxTest<-as.matrix(cbind(d1,d2))
  rowName<-paste(sapply(strsplit(row.names(log2LFQmm), ";;",fixed=T), "[", 2))
  rowName2<-paste(sapply(strsplit(row.names(log2LFQmm), ";;",fixed=T), "[", 3))
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
    logFCmedianGrp1[is.na(logFCmedianGrp1)]=.Machine$double.xmin
    logFCmedianGrp2[is.na(logFCmedianGrp2)]=.Machine$double.xmin
    hda<-cbind(logFCmedianGrp1,logFCmedianGrp2)
    plot(hda)
    limma::vennDiagram(hda>.Machine$double.xmin)
    log2meanDiff = logFCmeanGrp1-logFCmeanGrp2
    logFCmedian = logFCmedianGrp1-logFCmedianGrp2
    logFCmedianFC = 2^(logFCmedian+.Machine$double.xmin)
    logFCmedianFC=squish(logFCmedianFC,c(0.01,100))
    hist(logFCmedianFC)
    log2FCmedianFC=log2(logFCmedianFC)
    hist(log2FCmedianFC)
    logFCmedianGrp1[logFCmedianGrp1==.Machine$double.xmin]=NA
    logFCmedianGrp2[logFCmedianGrp2==.Machine$double.xmin]=NA
    wilcoxTest.results = data.frame(Uniprot=rowName,Gene=rowName2,logFCmedianGrp1,logFCmedianGrp2,PValueMinusLog10=pValNAminusLog10,FoldChanglog2median=logFCmedianFC,CorrectedPValueBH=pValBHna,WilcoxTestPval=pValNA,dataSellog2grpwilcoxTest,Log2MedianChange=logFCmedian,grp1CV,grp2CV,log2meanDiff,RowGeneUniProtScorePeps=rownames(dataSellog2grpwilcoxTest))
    wilcoxTest.results.return<-wilcoxTest.results
    wilcoxTest.results<-wilcoxTest.results[sort.list(wilcoxTest.results$logFCmedianGrp1,decreasing=T),]
    writexl::write_xlsx(wilcoxTest.results,paste0(inpF,fName,selection,scale,lGroup,sCol,sel1,mCol,paste(sel2,collapse=""),eCol,selThr,selThrFC,cvThr,rGroup,lName,"WilcoxTestBH.xlsx"))
    write.csv(wilcoxTest.results,paste0(inpF,fName,selection,scale,lGroup,sCol,sel1,mCol,paste(sel2,collapse=""),eCol,selThr,selThrFC,cvThr,rGroup,lName,"WilcoxTestBH.csv"),row.names = F)
    #select
    cat(paste(sel1,paste(wilcoxTest.results[!is.na(wilcoxTest.results$logFCmedianGrp1),"Uniprot"],collapse=","),sum(!is.na(wilcoxTest.results$logFCmedianGrp1)),sep = "\t"),file=paste0(inpF,fName,"combine.txt"),sep="\n",append=TRUE)
    #write.csv(cbind(sel1,sum(!is.na(wilcoxTest.results$logFCmedianGrp1)),paste(wilcoxTest.results[!is.na(wilcoxTest.results$logFCmedianGrp1),"Uniprot"],collapse=" ")),paste0(inpF,"combine.csv"))
    #volcano
    wilcoxTest.results.ret<-wilcoxTest.results
    wilcoxTest.results$RowGeneUniProtScorePeps<-data$geneName
    wilcoxTest.results[is.na(wilcoxTest.results)]=selThr
    Significance=(wilcoxTest.results$CorrectedPValueBH<selThr)&(wilcoxTest.results$Log2MedianChange>selThrFC)
    dsub <- subset(wilcoxTest.results,Significance)
    p <- ggplot2::ggplot(wilcoxTest.results,ggplot2::aes(Log2MedianChange,PValueMinusLog10))+ ggplot2::geom_point(ggplot2::aes(color=Significance))
    p<-p + ggplot2::theme_bw(base_size=8) + ggplot2::geom_text(data=dsub,ggplot2::aes(label=RowGeneUniProtScorePeps),hjust=0, vjust=0,size=1,position=ggplot2::position_jitter(width=0.5,height=0.1)) + ggplot2::scale_fill_gradient(low="white", high="darkblue") + ggplot2::xlab("Log2 Median Change") + ggplot2::ylab("-Log10 P-value")
    #f=paste(file,proc.time()[3],".jpg")
    #install.packages("svglite")
    ggplot2::ggsave(paste0(inpF,fName,selection,scale,lGroup,sCol,sel1,mCol,paste(sel2,collapse=""),eCol,selThr,selThrFC,cvThr,rGroup,lName,"WilcoxTestBH.svg"), p)
    print(p)
    return(wilcoxTest.results.ret)
  }
}
#log2selection####
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
hist(log2LFQ,main=paste("Mean:",mean(log2LFQ,na.rm=T),"SD:",sd(log2LFQ,na.rm=T)),breaks=round(max(log2LFQ,na.rm=T)),xlim=range(min(log2LFQ,na.rm=T),max(log2LFQ,na.rm=T)))
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
#log2LFQminMax####
log2LFQselMM<-minmaxScale(log2LFQ)
summary(log2LFQselMM)
par(mar=c(12,3,1,1))
boxplot(log2LFQselMM,las=2,main=paste(selection,"minMax"))
write.csv(log2LFQselMM,paste0(inpF,lName,lGroup,selection,scale,".log2LFQselMM.minMax.csv"))
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
svgPHC<-pheatmap::pheatmap(log2LFQselScaleimpCorr,annotation_row = annoR,annotation_col = annoR,clustering_distance_rows = "euclidean",clustering_distance_cols = "euclidean",fontsize_row=6,cluster_cols=T,cluster_rows=T,fontsize_col=6)
ggplot2::ggsave(paste0(inpF,lName,lGroup,selection,scale,"heatmap.minMax.pearson.svg"), svgPHC)
#compare####
colnames(log2LFQ)
log2LFQsel=log2LFQ[,gsub("-",".",rownames(label[is.na(label$removed)|label$removed==" "|label$removed=='',]))]
colnames(log2LFQsel)
dim(log2LFQsel)
label=label[is.na(label$removed)|label$removed==" "|label$removed=='',]
table(label$pair2test)
for(i in (names(table(label[,lGroup])))){
  print(i)
  print(label[label[,lGroup]==i,])
  assign(i,testWilcox(log2LFQsel,i,setdiff(names(table(label[,lGroup])),i),"log2Int"))
}
#merge####
dataFC<-data.frame(rowSums(log2LFQsel,na.rm=T))
colnames(dataFC)<-"sum"
dataFC["RowGeneUniProtScorePeps"]<-row.names(data)
dim(dataFC)
summary(dataFC)
for (obj in (names(table(label[,lGroup])))) {
  print(obj)
  dataT<-get(obj)
  dataC<-data.frame(cbind(dataT$RowGeneUniProtScorePeps,dataT$logFCmedianGrp1))
  colnames(dataC)<-c("RowGeneUniProtScorePeps",paste0(obj,"log2MedInt"))
  dataFC<-merge(dataFC,dataC,by='RowGeneUniProtScorePeps',all=T)
}
dataFC<-dataFC[order(dataFC$sum,decreasing=T),]
rN<-dataFC[,"RowGeneUniProtScorePeps"]
geneName<-paste(sapply(strsplit(paste(sapply(strsplit(rN, "GN=",fixed=T), "[", 2)), "[; ]"), "[", 1))
uniprotID<-paste(sapply(strsplit(paste(sapply(strsplit(rN, "\\|",fixed=F), "[", 2)), "\\|"), "[", 1))
geneName[is.na(geneName)]=uniprotID[is.na(geneName)]
proteinNames<-paste(sapply(strsplit(paste(sapply(strsplit(rN, "_",fixed=T), "[", 2)), " OS="), "[", 1))
writexl::write_xlsx(cbind(uniprotID,geneName,proteinNames,dataFC),paste0(inpF,fName,selection,selThr,selThrFC,cvThr,rGroup,lName,"log2Intmerge.xlsx"))
write.csv(cbind(uniprotID,geneName,proteinNames,dataFC),paste0(inpF,fName,selection,selThr,selThrFC,cvThr,rGroup,lName,"log2Intmerge.csv"),row.names = F)
#completeCases####
dataFCnar<-dataFC
dataFCnar[is.na(dataFCnar)]<-0
writexl::write_xlsx(dataFCnar,paste0(inpF,fName,selection,selThr,selThrFC,cvThr,rGroup,lName,"log2IntcompleteCase.xlsx"))
write.csv(dataFCnar,paste0(inpF,fName,selection,selThr,selThrFC,cvThr,rGroup,lName,"log2IntcompleteCase.csv"),row.names = F)
write.table(dataFCnar,paste0(inpF,fName,selection,selThr,selThrFC,cvThr,rGroup,lName,"log2IntcompleteCase.txt"),row.names = F,sep="\t",quote=F)
limma::vennDiagram(dataFCnar[,3:length(dataFCnar)]>0)
#comparelog2LFQselMM####
colnames(log2LFQselMM)
log2LFQsel=log2LFQselMM[,gsub("-",".",rownames(label[is.na(label$removed)|label$removed==" "|label$removed=='',]))]
colnames(log2LFQsel)
dim(log2LFQsel)
label=label[is.na(label$removed)|label$removed==" "|label$removed=='',]
table(label$pair2test)
for(i in (names(table(label[,lGroup])))){
  print(i)
  print(label[label[,lGroup]==i,])
  assign(i,testWilcox(log2LFQsel,i,setdiff(names(table(label[,lGroup])),i),"log2LFQselMM"))
}
#merge####
dataFC<-data.frame(rowSums(log2LFQsel,na.rm=T))
colnames(dataFC)<-"sum"
dataFC["RowGeneUniProtScorePeps"]<-row.names(data)
dim(dataFC)
summary(dataFC)
for (obj in (names(table(label[,lGroup])))) {
  print(obj)
  dataT<-get(obj)
  dataC<-data.frame(cbind(dataT$RowGeneUniProtScorePeps,dataT$logFCmedianGrp1))
  colnames(dataC)<-c("RowGeneUniProtScorePeps",paste0(obj,"log2MedInt"))
  dataFC<-merge(dataFC,dataC,by='RowGeneUniProtScorePeps',all=T)
}
dataFC<-dataFC[order(dataFC$sum,decreasing=T),]
rN<-dataFC[,"RowGeneUniProtScorePeps"]
geneName<-paste(sapply(strsplit(paste(sapply(strsplit(rN, "GN=",fixed=T), "[", 2)), "[; ]"), "[", 1))
uniprotID<-paste(sapply(strsplit(paste(sapply(strsplit(rN, "\\|",fixed=F), "[", 2)), "\\|"), "[", 1))
geneName[is.na(geneName)]=uniprotID[is.na(geneName)]
proteinNames<-paste(sapply(strsplit(paste(sapply(strsplit(rN, "_",fixed=T), "[", 2)), " OS="), "[", 1))
writexl::write_xlsx(cbind(uniprotID,geneName,proteinNames,dataFC),paste0(inpF,fName,selection,selThr,selThrFC,cvThr,rGroup,lName,"log2LFQselMMmerge.xlsx"))
write.csv(cbind(uniprotID,geneName,proteinNames,dataFC),paste0(inpF,fName,selection,selThr,selThrFC,cvThr,rGroup,lName,"log2LFQselMMmerge.csv"),row.names = F)
#completeCases####
dataFCnar<-dataFC
dataFCnar[is.na(dataFCnar)]<-0
writexl::write_xlsx(dataFCnar,paste0(inpF,fName,selection,selThr,selThrFC,cvThr,rGroup,lName,"log2LFQselMMcompleteCase.xlsx"))
write.table(dataFCnar,paste0(inpF,fName,selection,selThr,selThrFC,cvThr,rGroup,lName,"log2LFQselMMcompleteCase.txt"),row.names = F,sep="\t",quote=F)
limma::vennDiagram(dataFCnar[,3:length(dataFCnar)]>0)
