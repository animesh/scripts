#cf. F:\GD\OneDrive\Dokumenter\GitHub\scripts\proteinGroupsTtest.r
#Rscript C:\Users\animeshs\R\bin\Rscript.exe
args = commandArgs(trailingOnly=TRUE)
print(args)
#git checkout 6bc63d134527cf6972218c3d4d39f881ea883753 diffExprTestT.r
if (length(args) != 2) {stop("\n\nNeeds the full path of the directory containing BOTH proteinGroups.txt from MaxQuant & Groups.txt files followed by the name of GROUP column in Groups.txt file whch will be used for the t-test, for example
\"c:/Users/animeshs/R/bin/Rscript.exe diffExprTestT.r L:/promec/TIMSTOF/LARS/2022/februar/Sigrid/combined/txt/ Bio\"
                             ", call.=FALSE)}
#setup####
#install.packages("ggplot2", repos = "https://cloud.r-project.org/")
#install.packages("svglite", repos = "https://cloud.r-project.org/")
#install.packages("writexl", repos = "https://cloud.r-project.org/")
#install.packages("BiocManager", repos = "https://cloud.r-project.org/")
#BiocManager::install(version = "3.14")
#BiocManager::install("limma")
#BiocManager::install("pheatmap")
#BiocManager::install("UniprotR")
inpD <- args[1]
#inpD <-"L:/promec/Elite/LARS/2015/january/Ishita/combined/txt/"
lGroup <- args[2]
#lGroup<-"Bio"
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
write.csv(resultsGO,paste0(inpF,selection,selThr,selThrFC,cvThr,lGroup,"tTestBHGO.csv"))
#dist####
#proteinGroups.txtLFQ.intensity.0.050.50.05BiotTestBHGO.csv
#resultsGO<-read.csv(paste0(inpF,selection,selThr,selThrFC,cvThr,lGroup,"tTestBHGO.csv"),row.names=1)
row.names(resultsGO)<-paste0(row.names(resultsGO),resultsGO$Uniprot)
#log2LFQ<-sigList[,c(grep("MINE|WT",colnames(sigList)))]
log2LFQ<-resultsGO[,c(grep("MINE|WT",colnames(resultsGO)))]
row.names(log2LFQ)<-row.names(resultsGO)
#log2LFQimpCorr<-cor(t(log2LFQ),use="pairwise.complete.obs",method="spearman")
#hist(log2LFQimpCorr)
log2LFQimpCorP<-cor(t(log2LFQ),use="pairwise.complete.obs",method="pearson")
hist(log2LFQimpCorP)
dsubCor<-as.dist(log2LFQimpCorP)
#dsubCor[is.na(dsubCor)]<-0
hist(dsubCor)
#https://stackoverflow.com/questions/5813156/convert-and-save-distance-matrix-to-a-specific-format/5815379#5815379
dsubCorM <- data.frame(t(combn(rownames(log2LFQ),2)), as.numeric(dsubCor))
write.csv(data.frame(dsubCorM),paste0(inpD,"dsubCorM.csv"))
names(dsubCorM) <- c("P1", "P2", "dist")
dsubCorMna<-dsubCorM[!is.na(dsubCorM$dist),]
hist(dsubCorMna$dist)
write.csv(data.frame(dsubCorMna),paste0(inpD,"dsubCorMna.csv"))
corThr<-0
#dsubCorSel<-dsubCorMna[abs(dsubCorMna$dist)>corThr,]
dsubCorSel<-dsubCorMna[dsubCorMna$dist>corThr,]
dsubCorSel$SOURCE<-paste(sapply(strsplit(paste(sapply(strsplit(dsubCorSel$P1, ";",fixed=T), "[", 1)), "-"), "[", 1))
dsubCorSel$TARGET<-paste(sapply(strsplit(paste(sapply(strsplit(dsubCorSel$P2, ";",fixed=T), "[", 1)), "-"), "[", 1))
write.csv(data.frame(dsubCorSel),paste0(inpD,"dsubCorSel",corThr,"p.csv"),quote = F)
#sigList####
sigList<-resultsGO
sigList[is.na(sigList)]<-(Inf)
log2Thr<-0.5
sigList<-sigList[sigList$CorrectedPValueBH<0.1&abs(sigList$Log2MedianChange)>log2Thr,]
hist(sigList$Log2MedianChange)
hist(sigList$CorrectedPValueBH)
plot(sigList$Log2MedianChange,-log10(sigList$CorrectedPValueBH))
sigListUP<-sigList[sigList$CorrectedPValueBH<0.1&sigList$Log2MedianChange>log2Thr,]
write.csv(data.frame(sigListUP),paste0(inpD,"sigListUP",log2Thr,"fc.csv"),quote = F)
uniList<-unlist(strsplit(unlist(strsplit(unlist(strsplit(unlist(strsplit(sigListUP$RowGeneUniProtScorePeps, split = ";")),split = "|",fixed=T)),split = "=",fixed=T)),split = " ",fixed=T))
uniList<-uniList[nchar(uniList)>5&nchar(uniList)<15]
uniList<-uniList[grepl('^[A-Z]', uniList)]
write.csv(uniList,paste0(inpD,"sigListUP",log2Thr,"fcUnlist.csv"),quote = F)
sigListDN<-sigList[sigList$CorrectedPValueBH<0.1&sigList$Log2MedianChange<(-log2Thr),]
write.csv(data.frame(sigListDN),paste0(inpD,"sigListDN",log2Thr,"fc.csv"),quote = F)
uniList<-unlist(strsplit(unlist(strsplit(unlist(strsplit(unlist(strsplit(sigListDN$RowGeneUniProtScorePeps, split = ";")),split = "|",fixed=T)),split = "=",fixed=T)),split = " ",fixed=T))
uniList<-uniList[nchar(uniList)>5&nchar(uniList)<15]
uniList<-uniList[grepl('^[A-Z]', uniList)]
write.csv(uniList,paste0(inpD,"sigListDN",log2Thr,"fcUnlist.csv"),quote = F)
#fisher####
sigListGO <- data.frame(do.call(rbind, Map(cbind, strsplit(sigList$Gene.ontology..GO., "; "), sigList$RowGeneUniProtScorePeps)))
colnames(sigListGO) <- c("GO","ID")
sigListGOtab=as.data.frame(table(sigListGO$GO))
#sigListGO=sigListGO[!is.infinite(sigListGO)]
fulListGO <- data.frame(do.call(rbind, Map(cbind, strsplit(resultsGO$Gene.ontology..GO., "; "), resultsGO$RowGeneUniProtScorePeps)))
colnames(fulListGO) <- c("GO","ID")
fulListGO=fulListGO[!is.na(fulListGO$GO),]
fulListGOtab=as.data.frame(table(fulListGO$GO))
goTab<-merge(fulListGOtab,sigListGOtab,by='Var1')
plot(log2(goTab$Freq.x),log2(goTab$Freq.y))
hist(log2(goTab$Freq.x))
#thioglucosidase https://www.wolframalpha.com/input?i=%28Binomial%5B3787%2C7%5D*Binomial%5B320%2C15%5D%29%2FBinomial%5B4107%2C22%5D
#(15/320)/(22/4107)#enrichment
#(choose(3787,7)*choose(320,15))/choose(4107,22)#(choose(3787,3780)*choose(320,305))/choose(4107,4085)
#fisher.test(rbind(c(7,3780),c(15,305)))$p.value#fisher.test(rbind(c(3460,3482),c(305,3780)))$p.value
#(choose(3787,7)*choose(320,15))/choose(4107,22)+(choose(3787,6)*choose(320,16))/choose(4107,22)+(choose(3787,5)*choose(320,17))/choose(4107,22)+(choose(3787,4)*choose(320,18))/choose(4107,22)+(choose(3787,3)*choose(320,19))/choose(4107,22)+(choose(3787,2)*choose(320,20))/choose(4107,22)+(choose(3787,1)*choose(320,21))/choose(4107,22)+(choose(3787,0)*choose(320,22))/choose(4107,22)
#nitrile
#(choose(3787,6)*choose(320,5))/choose(4107,11)
#fisher.test(rbind(c(6,3781),c(5,305)),alternative="less")$p.value
goTab["lo-enrichment"]=(goTab$Freq.y/nrow(sigList))/(goTab$Freq.x/nrow(resultsGO))
goTab["p-binomial"]=(choose(nrow(sigList),goTab$Freq.y)*choose((nrow(resultsGO)-nrow(sigList)),goTab$Freq.x-goTab$Freq.y))/choose(nrow(resultsGO),(goTab$Freq.x))
hist(as.matrix(goTab["p-binomial"]))
goTab["p-binomBH"]=sapply(goTab["p-binomial"],p.adjust)
hist(as.matrix(goTab["p-binomBH"]))
#goTab["p-fisher"]=fisher.test(rbind(c(goTab$Freq.x-goTab$Freq.y,nrow(resultsGO)-(nrow(sigList)+goTab$Freq.y+goTab$Freq.x)),c(goTab$Freq.y,nrow(sigList)-goTab$Freq.y)))$p.value
pvFE=apply(
  goTab, 1, function(x)
    if(sum(is.na(x[c(2:3)]))==0){fisher.test(rbind(c(as.numeric(x[2])-as.numeric(x[3]),nrow(resultsGO)-(nrow(sigList)+as.numeric(x[2])+as.numeric(x[3]))),c(as.numeric(x[3]),nrow(sigList)-as.numeric(x[3]))))$p.value}
    else{0}
)
goTab["p-fisher"]=pvFE
pvFEBH=p.adjust(pvFE,method="BH")
#fisher(choose(nrow(sigList),goTab$Freq.y)*choose((nrow(resultsGO)-nrow(sigList)),goTab$Freq.x-goTab$Freq.y))/choose(nrow(resultsGO),(goTab$Freq.x))
goTab["p-fisherBH"]=pvFEBH
plot(goTab)#$`lo-enrichment,goTab$`p-binomial`)
sigListGOagg=aggregate(sigListGO["ID"], by=sigListGO["GO"],paste)
goTabID<-merge(goTab,sigListGOagg,by.x="Var1",by.y='GO')
goTabID$ID <- paste0(sapply(goTabID$ID,as.character))
write.csv(goTabID,paste0(inpF,"FisherGOtabID.csv"))
goTabID=goTabID[order(goTabID["p-binomial"]),]
writexl::write_xlsx(goTabID,paste0(inpF,"FisherGOtabID.xlsx"))
#checkFE####
#perGO<-read.csv(paste0(inpF,"FisherGOall.txt"),sep="\t")
#compareGO<-merge(goTab,perGO,by.x="Var1",by.y='C..Category.value',all.x=T)
#sum(compareGO["p-binomial"]-compareGO$N..P.value,na.rm=T)
#pvDiff=compareGO["p-binomial"]-compareGO$N..P.value
#pvDiff[is.na(pvDiff)]=0
#pvDiff=sapply(pvDiff,as.numeric)
#hist(pvDiff)
