#C:\Users\animeshs\R-4.2.3\bin\Rscript.exe diffExprTestT.r L:\promec\TIMSTOF\LARS\2023\230217_Caroline\combined\txt\ Bio
args = commandArgs(trailingOnly=TRUE)
print(args)
if (length(args) != 2) {stop("\n\nNeeds the full path of the directory containing BOTH proteinGroups.txt from MaxQuant & Groups.txt files followed by the name of GROUP column in Groups.txt file whch will be used for the rank-test, for example
\"c:/Users/animeshs/R/bin/Rscript.exe diffExprTestRank.r F:/combined/txt/ Bio\"
                             ", call.=FALSE)}
#setup####
#install.packages("writexl")
#install.packages("pheatmap")
#install.packages("ggplot2")
#install.packages("svglite")
#install.packages("BiocManager")
#BiocManager::install("limma")
inpD <- args[1]
#inpD <-"L:/promec/TIMSTOF/LARS/2023/230217_Caroline/combined/txt/"
lGroup <- args[2]
#lGroup<-"Bio"
inpF<-paste0(inpD,"proteinGroups.txt")
inpL<-paste0(inpD,"Copy of Groups_CP.txt")
selection<-"LFQ.intensity."
thr=0.0#count
selThr=0.1#pValue-rTest
selThrFC=0.5#log2-MedianDifference
cvThr=Inf#threshold for coefficient-of-variation
testName="1way"
hdr<-gsub("[^[:alnum:] ]", "",inpD)
outP=paste(inpF,selection,selThr,selThrFC,cvThr,hdr,lGroup,"VolcanoTestT","pdf",sep = ".")
pdf(outP)
#data####
data <- read.table(inpF,stringsAsFactors = FALSE, header = TRUE, quote = "", comment.char = "", sep = "\t")
##clean####
#data = data[!data$Reverse=="+",]
#data = data[!data$Potential.contaminant=="+",]
#data = data[!data$Only.identified.by.site=="+",]
row.names(data)<-paste(row.names(data),data$Fasta.headers,data$Protein.IDs,data$Protein.names,data$Gene.names,data$Score,data$Peptide.counts..unique.,sep=";;")
summary(data)
dim(data)
hist(as.matrix(log2(data[,grep("Intensity",colnames(data))])))
summary(log2(data[,grep("Intensity",colnames(data))]))
LFQ<-as.matrix(data[,grep(selection,colnames(data))])
#protNum<-1:ncol(LFQ)
#protNum<-"LFQ intensity"#1:ncol(LFQ)
#colnames(LFQ)=paste(protNum,sub(selection,"",colnames(LFQ)),sep=";")
colnames(LFQ)=sub(selection,"",colnames(LFQ))
dim(LFQ)
log2LFQ<-log2(LFQ)
colnames(log2LFQ)<-colnames(LFQ)
log2LFQ[log2LFQ==-Inf]=NA
log2LFQ[log2LFQ==0]=NA
summary(log2LFQ)
hist(log2LFQ)
rowName<-paste(sapply(strsplit(paste(sapply(strsplit(data$Fasta.headers, "|",fixed=T), "[", 2)), "-"), "[", 1))
writexl::write_xlsx(as.data.frame(cbind(rowName,log2LFQ,rownames(data))),paste0(inpD,"log2LFQ.xlsx"))
data$geneName<-paste(sapply(strsplit(paste(sapply(strsplit(data$Gene.names, ";",fixed=T), "[", 1)), " "), "[", 1))
data$uniprotID<-paste(sapply(strsplit(paste(sapply(strsplit(data$Protein.IDs, ";",fixed=T), "[", 1)), "-"), "[", 1))
data[data$geneName=="NA","geneName"]=data[data$geneName=="NA","uniprotID"]
#label####
label<-read.table(inpL,header=T,sep="\t",row.names=1)#, colClasses=c(rep("factor",3)))
rownames(label)=sub(selection,"",rownames(label))
label["pair2test"]<-label[lGroup]
#label["pair2test"]<-label["Bio"]
print(label)
#corHC####
scale=3
log2LFQimp<-matrix(rnorm(dim(log2LFQ)[1]*dim(log2LFQ)[2],mean=mean(log2LFQ,na.rm = T)-scale,sd=sd(log2LFQ,na.rm = T)/(scale)), dim(log2LFQ)[1],dim(log2LFQ)[2])
log2LFQimp[log2LFQimp<0]<-0
bk1 <- c(seq(-1,-0.01,by=0.01))
bk2 <- c(seq(0.01,1,by=0.01))
bk <- c(bk1,bk2)  #combine the break limits for purpose of graphing
my_palette <- c(colorRampPalette(colors = c("darkblue", "white"))(n = length(bk1)-1),"gray", "gray",c(colorRampPalette(colors = c("white","darkred"))(n = length(bk2)-1)))
colnames(log2LFQimp)<-colnames(log2LFQ)
log2LFQimpCorr<-cor(log2LFQ,use="pairwise.complete.obs",method="spearman")
colnames(log2LFQimpCorr)<-colnames(log2LFQ)
rownames(log2LFQimpCorr)<-colnames(log2LFQ)
svgPHC<-pheatmap::pheatmap(log2LFQimpCorr,clustering_distance_rows = "euclidean",clustering_distance_cols = "euclidean",fontsize_row=8,cluster_cols=T,cluster_rows=T,fontsize_col  = 8)
ggplot2::ggsave(paste0(inpF,selection,selThr,selThrFC,cvThr,lGroup,"HeatMap.svg"), svgPHC)
#test####
testT <- function(log2LFQt,sel1,sel2,cvThr,testName){
  #sel1<-"Omego1"
  #sel2<-"Cntr1"
  #log2LFQt<-log2LFQ
  #testName<-"paired"
  colnames(log2LFQt)
  #log2LFQt<-sapply(log2LFQt, as.numeric)
  d1<-log2LFQt[,gsub("-",".",rownames(label[label$pair2test==sel1,]))]
  d2<-log2LFQt[,gsub("-",".",rownames(label[label$pair2test==sel2,]))]
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
    d1c<-d1
    d2c<-d2
    d1c[is.na(d1c)]<-0
    d2c[is.na(d2c)]<-0
    logFCt =d1c-d2c
    logFCt[logFCt==0]<-NA
    pValNA = apply(
      logFCt, 1, function(x)
      if(sum(!is.na(x))<2){NA}
      #else if(sum(!is.na(x))<2){1}
      else{
        t.test(as.numeric(x),na.rm=T)$p.value}
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
    logFCmedianGrp1 = apply(dataSellog2grpTtest[,c(sCol:mCol)],1, function(x) median(x,na.rm=T))
    logFCmedianGrp1=if(is.null(dim(dataSellog2grpTtest[,c(sCol:mCol)]))){dataSellog2grpTtest[,c(sCol:mCol)]} else{apply(dataSellog2grpTtest[,c(sCol:mCol)],1,function(x) median(x,na.rm=T))}
    #summary(logFCmedianGrp11-logFCmedianGrp1)
    logFCmedianGrp2=if(is.null(dim(dataSellog2grpTtest[,c((mCol+1):eCol)]))){dataSellog2grpTtest[,c((mCol+1):eCol)]} else{apply(dataSellog2grpTtest[,c((mCol+1):eCol)],1,function(x) median(x,na.rm=T))}
    logFCmedianGrp1[is.na(logFCmedianGrp1)]=0
    logFCmedianGrp2[is.na(logFCmedianGrp2)]=0
    hda<-cbind(logFCmedianGrp1,logFCmedianGrp2)
    plot(hda)
    limma::vennDiagram(hda>0)
    logFCmedian = apply(logFCt,1,function(x) median(x,na.rm=T))
    logFCaverage = apply(logFCt,1,function(x) mean(x,na.rm=T))
    logFCmedianFC = 2^(logFCmedian+.Machine$double.xmin)
    logFCmedianFC=squish(logFCmedianFC,c(0.01,100))
    hist(logFCmedianFC)
    log2FCmedianFC=log2(logFCmedianFC)
    hist(log2FCmedianFC)
    ttest.results = data.frame(Uniprot=rowName,Gene=data$Gene.names,Protein=data$Protein.names,PValueMinusLog10=pValNAminusLog10,FoldChanglog2median=logFCmedianFC,logFCmedianGrp1,logFCmedianGrp2,tTestPval=pValNA,CorrectedPValueBH=pValBHna,Log2MedianChange=logFCmedian,Log2AverageChange=logFCaverage,dataSellog2grpTtest,RowGeneUniProtScorePeps=rownames(dataSellog2grpTtest))
    writexl::write_xlsx(ttest.results,paste0(inpF,selection,sCol,eCol,comp,selThr,selThrFC,cvThr,lGroup,testName,"tTestBH.xlsx"))
    write.csv(ttest.results,paste0(inpF,selection,sCol,eCol,comp,selThr,selThrFC,cvThr,lGroup,testName,"tTestBH.csv"),row.names = F)
    ttest.results$RowGeneUniProtScorePeps<-data$geneName
    ttest.results[is.na(ttest.results)]=selThr
    Significance=ttest.results$CorrectedPValueBH<selThr&ttest.results$CorrectedPValueBH>0&abs(ttest.results$Log2MedianChange)>selThrFC
    sum(Significance)
    dsub <- subset(ttest.results,Significance)
    p <- ggplot2::ggplot(ttest.results,ggplot2::aes(Log2MedianChange,PValueMinusLog10))+ ggplot2::geom_point(ggplot2::aes(color=Significance))
    p<-p + ggplot2::theme_bw(base_size=8) + ggplot2::geom_text(data=dsub,ggplot2::aes(label=RowGeneUniProtScorePeps),hjust=0, vjust=0,size=1,position=ggplot2::position_jitter(width=0.5,height=0.1)) + ggplot2::scale_fill_gradient(low="white", high="darkblue") + ggplot2::xlab("Log2 Median Change") + ggplot2::ylab("-Log10 P-value")
    #f=paste(file,proc.time()[3],".jpg")
    #install.packages("svglite")
    ggplot2::ggsave(paste0(inpF,selection,sCol,eCol,comp,selThr,selThrFC,cvThr,lGroup,testName,"VolcanoTest.svg"), p)
    print(p)
    return(ttest.results)
  }
}
#testttOmego1Cntr12####
table(label$pair2test)
rownames(label[label$pair2test=="Omego1",])
rownames(label[label$pair2test=="Cntr1",])
label<-label[order(label$Rep),]
log2LFQs <- log2LFQ[,order(label$Rep)]
ttOmego1Cntr12=testT(log2LFQs,"Omego1","Cntr1",cvThr,testName)
