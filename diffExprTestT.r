#cf. F:\GD\OneDrive\Dokumenter\GitHub\scripts\proteinGroupsTtest.r
#Rscript C:\Users\animeshs\R\bin\Rscript.exe
args = commandArgs(trailingOnly=TRUE)
print(args)
if (length(args) != 2) {stop("\n\nNeeds the full path of the directory containing BOTH proteinGroups.txt from MaxQuant & Groups.txt files followed by the name of GROUP column in Groups.txt file whch will be used for the t-test, for example
\"c:/Users/animeshs/R/bin/Rscript.exe diffExprTestT.r L:/promec/Elite/LARS/2015/january/Ishita/combined/txt/ Bio\"
                             ", call.=FALSE)}
#setup####
#install.packages("ggplot2")
#install.packages("svglite")
#install.packages("limma")
#install.packages("writexl")
#install.packages("pheatmap")
inpD <- args[1]
#inpD <-"L:/promec/Elite/LARS/2015/january/Ishita/combined/txt/"
lGroup <- args[2]
#lGroup<-"group"
inpF<-paste0(inpD,"proteinGroups.txt")
inpL<-paste0(inpD,"Groups.txt")
selection<-"LFQ.intensity."
thr=0.0#count
selThr=0.05#pValue-tTest
selThrFC=0.5#log2-MedianDifference
cvThr=0.05#threshold for coefficient-of-variation
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
testT <- function(log2LFQ,sel1,sel2,cvThr){
  #sel1<-"MINE"
  #sel2<-"WT"
  #log2LFQ<-medianLog2LFQ
  log2LFQ<-sapply(log2LFQ, as.numeric)
  d1<-log2LFQ[,gsub("-",".",rownames(label[label$pair2test==sel1,]))]
  d2<-log2LFQ[,gsub("-",".",rownames(label[label$pair2test==sel2,]))]
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
    ttest.results = data.frame(Uniprot=rowName,Gene=data$Gene.names,Protein=data$Protein.names,logFCmedianGrp1,logFCmedianGrp2,PValueMinusLog10=pValNAminusLog10,FoldChanglog2median=logFCmedianFC,CorrectedPValueBH=pValBHna,TtestPval=pValNA,dataSellog2grpTtest,Log2MedianChange=logFCmedian,grp1CV,grp2CV,RowGeneUniProtScorePeps=rownames(dataSellog2grpTtest))
    writexl::write_xlsx(ttest.results,paste0(inpF,selection,sCol,eCol,comp,selThr,selThrFC,cvThr,lGroup,"tTestBH.xlsx"))
    write.csv(ttest.results,paste0(inpF,selection,sCol,eCol,comp,selThr,selThrFC,cvThr,lGroup,"tTestBH.csv"),row.names = F)
    ttest.results.return<-ttest.results
    #volcano
    ttest.results$RowGeneUniProtScorePeps<-data$geneName
    ttest.results[is.na(ttest.results)]=selThr
    Significance=ttest.results$CorrectedPValueBH<selThr&ttest.results$CorrectedPValueBH>0&abs(ttest.results$Log2MedianChange)>selThrFC
    sum(Significance)
    dsub <- subset(ttest.results,Significance)
    p <- ggplot2::ggplot(ttest.results,ggplot2::aes(Log2MedianChange,PValueMinusLog10))+ ggplot2::geom_point(ggplot2::aes(color=Significance))
    p<-p + ggplot2::theme_bw(base_size=8) + ggplot2::geom_text(data=dsub,ggplot2::aes(label=RowGeneUniProtScorePeps),hjust=0, vjust=0,size=1,position=ggplot2::position_jitter(width=0.5,height=0.1)) + ggplot2::scale_fill_gradient(low="white", high="darkblue") + ggplot2::xlab("Log2 Median Change") + ggplot2::ylab("-Log10 P-value")
    #f=paste(file,proc.time()[3],".jpg")
    #install.packages("svglite")
    ggplot2::ggsave(paste0(inpF,selection,sCol,eCol,comp,selThr,selThrFC,cvThr,lGroup,"VolcanoTest.svg"), p)
    print(p)
    return(ttest.results.return)
    }
}
#medianMINEandWT####
colnames(log2LFQ)
table(label$Bio)
medianLog2LFQ <- data.frame(matrix(ncol=length(names(table(label$Bio))),nrow=nrow(log2LFQ)))
colnames(medianLog2LFQ) <- names(table(label$Bio))
rownames(medianLog2LFQ)<-rownames(log2LFQ)
for(i in names(table(label$Bio))){
  print(i)
  log2LFQvals<-log2LFQ[,gsub("-",".",rownames(label[label$Bio==i,]))]
  print(summary(log2LFQvals))
  medianLog2LFQ[i]<-apply(log2LFQvals,1, function(x) median(x,na.rm=T))
  print(summary(medianLog2LFQ[i]))
}
#GO####
selGO <- function(uniProt,term) {
  #uniProt<-ttMINE2WT$Uniprot "Q9LF24"#orgID
  #term<-"GO"
  GeneOntologyObj <- UniprotR::GetProteinGOInfo(uniProt)
  GeneOntologyObj$ID <- rownames(GeneOntologyObj)
  write.csv(GeneOntologyObj,paste0(inpF,term,"GeneOntologyObj.csv"))
  length(grep(term,GeneOntologyObj$Gene.ontology..cellular.component.,ignore.case=T))
  GeneOntologyObj$term <- apply(GeneOntologyObj, 1, function(x)as.integer(any(grep(term,x,ignore.case=T))))
  sum(GeneOntologyObj$term)
  return(GeneOntologyObj)
}
#testMINE2WT####
label <- data.frame(matrix(ncol=1,nrow=length(colnames(medianLog2LFQ))))
label$pair2test<-sapply(strsplit(colnames(medianLog2LFQ), "_",fixed=T), "[", 1)
rownames(label)<-colnames(medianLog2LFQ)
rownames(label)
table(label$pair2test)
rownames(label[label$pair2test=="MINE",])
rownames(label[label$pair2test=="WT",])
ttMINE2WT=testT(medianLog2LFQ,"MINE","WT",cvThr)
GeneOntologyObj=selGO(ttMINE2WT$Uniprot,"GO")
GeneOntologyObj$Uniprot<-rownames(GeneOntologyObj)
resultsGO<-merge(ttMINE2WT,GeneOntologyObj,by="Uniprot")
writexl::write_xlsx(resultsGO,paste0(inpF,selection,selThr,selThrFC,cvThr,lGroup,"tTestBHGO.xlsx"))
