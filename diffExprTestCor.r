#"c:\Program Files\r\R-4.5.1\bin\Rscript.exe" diffExprTestCor.r "L:\promec\TIMSTOF\LARS\2025\250902_Alessandro\DIANNv2p2\report.gg_matrix.tsv" "L:\promec\TIMSTOF\LARS\2025\250902_Alessandro\DIANNv2p2\Groups.txt" "F..promec.TIMSTOF.LARS.2025.250902_Alessandro.250902_Alessandro_" ".d" "LFQvsn" "Rem" "Progression.free.survival..months._2023_taha"
#install.packages(c("readxl","writexl","svglite","ggplot2","BiocManager"),repos="http://cran.us.r-project.org",lib=.libPaths())
#BiocManager::install(c("limma","pheatmap","vsn"))#,repos="http://cran.us.r-project.org",lib=.libPaths())
print("USAGE:<path to>Rscript diffExprTestCor.r <complete path to directory containing proteinGroups.txt> AND <SurvivalUpdates.xlsx file>  \"intensity columns to consider\" \"Group information of samples\" \"Remove samples if any\" \"correlation column\"")
args = commandArgs(trailingOnly=TRUE)
print(paste("supplied argument(s):", length(args)))
print(args)
if (length(args) != 7) {stop("\n\nNeeds the full path of the directory containing BOTH DIA-NN result matrix AND Survival data files followed by \"intensity columns to consider\" \"suffix to remove\"  \"Group information of samples\" \"Remove samples if any\" \"correlation column\"", call.=FALSE)}
#thesholds####
thr=3#count
selThr=0.25#pValue-CorTest
selThrCor=0.5##correlation-CorTest
print(paste("Thresholds used - ", thr ,"#count-valid-samples," ,selThr,"#pValue-CorTest,",selThrCor,"#correlation-CorTest"))
#args####
inpF <- args[1]
#inpF <-"L:/promec/TIMSTOF/LARS/2025/250902_Alessandro/DIANNv2p2/report.gg_matrix.tsv"
inpL <- args[2]
#inpL <-"L:/promec/TIMSTOF/LARS/2025/250902_Alessandro/DIANNv2p2/Groups.txt"
selection<-args[3]
#selection<-"F..promec.TIMSTOF.LARS.2025.250902_Alessandro.250902_Alessandro_"
sufFix <- args[4]
#sufFix<-".d"
transform<-args[5]
#transform<-"LFQvsn"
rGroup <- args[6]
#rGroup<-"Rem"
scaleF <- args[7]
#scaleF<-"Progression.free.survival..months._2023_taha"
inpD<-dirname(inpF)
fName<-basename(inpF)
lName<-basename(inpL)
hdr<-gsub("[^[:alnum:]]", "",inpD)
outP=paste(inpF,selection,selThr,selThrCor,hdr,rGroup,lName,"VolcanoTestCor","pdf",sep = ".")
pdf(outP)
#label####
label<-read.table(inpL,stringsAsFactors = FALSE, header = TRUE, quote = "", comment.char = "", sep = "\t")
label<-data.frame(label)
#cor(label$cell.number/label$cur.area,label$ratio.correction.factor)
rownames(label)=sub(selection,"",label$Name)
if(rGroup %in% colnames(label)){label["removed"]<-label[rGroup]} else{label["removed"]=NA}
print(label)
rownames(label)<-sub("-",".",rownames(label))
#plot(label)
label[,scaleF]<-as.numeric(label[,scaleF])
hist(label[,scaleF],breaks=25)
#write.table(label,paste0(inpL,".txt"),sep="\t",row.names = F,quote = F)
#data####
data <- read.table(inpF,stringsAsFactors = FALSE, header = TRUE, quote = "", comment.char = "", sep = "\t",fileEncoding="UTF-8-BOM")
print(colnames(data))
##clean####
#data = data[!data$Reverse=="+",]
#data = data[!data$Potential.contaminant=="+",]
#data = data[!data$Only.identified.by.site=="+",]
row.names(data)<-paste(row.names(data),data$N.Sequences,data$Genes,data$N.Proteotypic.Sequences,sep = ";;")
data$rowName<-row.names(data)
data$geneName<-paste(sapply(strsplit(paste(sapply(strsplit(data$Genes, ";",fixed=T), "[", 1)), "-"), "[", 1))
data$uniprotID<-paste(sapply(strsplit(paste(sapply(strsplit(data$Genes, ";",fixed=T), "[", 1)), " "), "[", 1))
data[data$geneName=="NA","geneName"]=data[data$geneName=="NA","uniprotID"]
summary(data)
dim(data)
#sel####
intDat<-data[,grep(selection,colnames(data))]
log2LFQ<-as.matrix(log2(intDat))
log2LFQ[log2LFQ==-Inf]=NA
colnames(log2LFQ)=sub(selection,"",colnames(log2LFQ))
colnames(log2LFQ)=sub(sufFix,"",colnames(log2LFQ))
hist(log2LFQ,main=paste("Mean:",mean(log2LFQ,na.rm=T),"SD:",sd(log2LFQ,na.rm=T)),breaks=round(max(log2LFQ,na.rm=T)),xlim=range(min(log2LFQ,na.rm=T),max(log2LFQ,na.rm=T)))
summary(log2(data[,grep(selection,colnames(data))]))
par(mar=c(12,3,1,1))
boxplot(log2LFQ,las=2,main="log2LFQensity")
countTableDAuniGORNAddsMedVSN<-apply(log2LFQ,1,function(x) median(x,na.rm=T))
countTableDAuniGORNAddsMedVSN<-(log2LFQ-countTableDAuniGORNAddsMedVSN)
hist(countTableDAuniGORNAddsMedVSN)
boxplot(countTableDAuniGORNAddsMedVSN,las=2)
#writeCSVcor####
corFac=data.frame(t(label[,scaleF]))
names(corFac)<-rownames(label)
write.csv(as.data.frame(cbind(data$rowName,log2LFQ,corFac)),paste0(inpF,selection,"log2.csv"))
#corHClfq####
log2LFQimpCorr<-cor(log2LFQ,use="pairwise.complete.obs",method="pearson")
colnames(log2LFQimpCorr)<-colnames(log2LFQ)
rownames(log2LFQimpCorr)<-colnames(log2LFQ)
summary(log2LFQimpCorr)
hist(log2LFQimpCorr)
heatmap(log2LFQimpCorr)
##justVSN####
#BiocManager::install("vsn")
IntVST<-as.matrix(intDat)
IntVST[IntVST==0]=NA
LFQvsn <- vsn::justvsn(IntVST)
hist(LFQvsn)
vsn::meanSdPlot(LFQvsn)
vsn::meanSdPlot(LFQvsn,ranks = FALSE)
colnames(LFQvsn)<-gsub(selection,"",colnames(LFQvsn))
colnames(LFQvsn)=gsub(sufFix,"",colnames(LFQvsn))
boxplot(LFQvsn,las=2)
countTableDAuniGORNAddsMedVSN<-apply(LFQvsn,1,function(x) median(x,na.rm=T))
countTableDAuniGORNAddsMedVSN<-(LFQvsn-countTableDAuniGORNAddsMedVSN)
hist(countTableDAuniGORNAddsMedVSN)
boxplot(countTableDAuniGORNAddsMedVSN,las=2)
#test####
testCor <- function(log2LFQ,corVal,rN,comp){
  #hist(label[,scaleF])
  #hist(log2LFQ)
  #colnames(log2LFQ)
  d1<-get(transform)
  #d2<-data.frame(label[,scaleF])
  d2<-corVal
  #rownames(d2)<-rownames(label)
  rownames(d2)<-rN
  d2<-data.frame(d2[colnames(d1),])
  rownames(d2)<-colnames(d1)
  d2<-t(d2)
  summary(d2)
  hist(d2)
  colnames(d2)
  colnames(d1)<-paste(colnames(d1),d2,sep=";;")
  if(sum(!is.na(d1))>thr&sum(!is.na(d2))>thr){
    hist(d1)
    hist(d2)
    options(nwarnings = 1000000)
    resCor=apply(d1, 1,function(x)
      if((sum(!is.na(x))<thr)){NA}
      #if(sum(!is.na(x))<2){NA}
      else if(sum(!is.na(x-d2))>=thr){
        cort=cor.test(as.numeric(x),as.numeric(d2),use="pairwise.complete.obs",method="pearson")
        cort=unlist(cort)
        paste(cort[[1]],cort[[2]],cort[[3]],cort[[4]],sep="--VALS--")
      }
      else{NA}
    )
    pValCor<-sapply(strsplit(resCor, "--VALS--",fixed=T), "[", 3)
    #pValCor<-sapply(strsplit(resCor, "--VALS--",fixed=T), "[", 1)
    pValNA<-sapply(pValCor,as.numeric)
    #hist(pValNA)
    cValCor<-sapply(strsplit(resCor, "--VALS--",fixed=T), "[", 4)
    #cValCor<-sapply(strsplit(resCor, "--VALS--",fixed=T), "[", 2)
    cValNA<-sapply(cValCor,as.numeric)
    #hist(cValNA)
    tValCor<-sapply(strsplit(resCor, "--VALS--",fixed=T), "[", 1)
    tValNA<-sapply(tValCor,as.numeric)
    #hist(tValNA)
    yValCor<-sapply(strsplit(resCor, "--VALS--",fixed=T), "[", 2)
    yValNA<-sapply(yValCor,as.numeric)
    #hist(yValNA)
    summary(warnings())
    summary(pValNA)
    summary(cValNA)
    #dfcValNA<-as.data.frame(cValNA)
    if(sum(is.na(pValNA))==nrow(d1)){pValNA[is.na(pValNA)]=1}
    hist(pValNA)
    dfpValNA<-as.data.frame(ceiling(pValNA))
    pValNAdm<-cbind(pValNA,d1,row.names(data))
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
    corTest.results = data.frame(Uniprot=data$rowName,Protein=data$geneName,PValueMinusLog10=pValNAminusLog10,CorrectedPValueBH=pValBHna,CorTestPval=pValNA,Cor=cValNA,d1,Fasta=row.names(data))
    writexl::write_xlsx(corTest.results,paste0(inpF,comp,selThr,selThrCor,rGroup,lName,transform,selection,"CorTestBH.xlsx"))
    write.csv(corTest.results,paste0(inpF,comp,selThr,selThrCor,rGroup,lName,transform,selection,"CorTestBH.csv"),row.names = F)
    corTest.results.return<-corTest.results
    #volcano
    corTest.results$RowGeneUniProtScorePeps<-data$geneName
    #corTest.results[is.na(corTest.results)]=selThr
    summary(corTest.results$CorrectedPValueBH)
    summary(corTest.results$Cor)
    Significance=corTest.results$CorrectedPValueBH<selThr&abs(corTest.results$Cor)>selThrCor
    dsub <- subset(corTest.results,Significance)
    p <- ggplot2::ggplot(corTest.results,ggplot2::aes(Cor,PValueMinusLog10))+ ggplot2::geom_point(ggplot2::aes(color=Significance))
    p<-p + ggplot2::theme_bw(base_size=8) + ggplot2::geom_text(data=dsub,ggplot2::aes(label=RowGeneUniProtScorePeps),hjust=0, vjust=0,size=1,position=ggplot2::position_jitter(width=0.5,height=0.1)) + ggplot2::scale_fill_gradient(low="white", high="darkblue") + ggplot2::xlab("Correlation") + ggplot2::ylab("-Log10 P-value")
    #f=paste(file,proc.time()[3],".jpg")
    #install.packages("svglite")
    ggplot2::ggsave(paste0(inpF,comp,selThr,selThrCor,rGroup,lName,transform,selection,"VolcanoTestCor.svg"), p)
    print(p)
    return(sum(Significance,na.rm = T))
  }
}
#compare####
label=label[is.na(label$removed)|label$removed==" "|label$removed=='',]
rtPair=testCor(get(transform),data.frame(label[,scaleF]),rownames(label),transform)
print(rtPair)
