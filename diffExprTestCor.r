#install.packages(c("readxl","writexl","svglite","ggplot2"),repos="http://cran.us.r-project.org",lib=.libPaths())
#F:\R-4.3.1\bin\Rscript.exe diffExprTestCor.r "L:\promec\TIMSTOF\LARS\2023\230310 Sonali\combined\txtNoDN\proteinGroups.txt" "L:\promec\TIMSTOF\LARS\2023\230310 Sonali\combined\txtNoDN\SurvivalUpdates.xlsx" "LFQ.intensity." "Group" "Remove" "eyed.stage"
print("USAGE:<path to>Rscript diffExprTestCor.r <complete path to directory containing proteinGroups.txt> AND <SurvivalUpdates.xlsx file>  \"intensity columns to consider\" \"Group information of samples\" \"Remove samples if any\" \"correlation column\"")
args = commandArgs(trailingOnly=TRUE)
print(paste("supplied argument(s):", length(args)))
print(args)
if (length(args) != 6) {stop("\n\nNeeds the full path of the directory containing BOTH proteinGroups.txt AND Survival.txt files followed by \"intensity columns to consider\" \"Group information of samples\" \"Remove samples if any\" \"correlation column\"", call.=FALSE)}
#thesholds####
thr=3#count
selThr=0.1#pValue-CorTest
selThrCor=0.75##correlation-CorTest
print(paste("Thresholds used - ", thr ,"#count-valid-samples," ,selThr,"#pValue-CorTest,",selThrCor,"#correlation-CorTest"))
#args####
inpF <- args[1]
#inpF <-"L:/promec/TIMSTOF/LARS/2023/230310 Sonali//combined/txtNoDN/proteinGroups.txt"
inpL <- args[2]
#inpL <-"L:/promec/TIMSTOF/LARS/2023/230310 Sonali//combined/txtNoDN/SurvivalUpdates.xlsx"
selection<-args[3]
#selection<-"LFQ.intensity."
lGroup <- args[4]
#lGroup<-"Group"
rGroup <- args[5]
#rGroup<-"Remove"
scaleF <- args[6]
#scaleF<-"Fertilisation"
inpD<-dirname(inpF)
fName<-basename(inpF)
lName<-basename(inpL)
hdr<-gsub("[^[:alnum:]]", "",inpD)
outP=paste(inpF,selection,selThr,selThrCor,hdr,lGroup,rGroup,lName,"VolcanoTestCor","pdf",sep = ".")
pdf(outP)
#label####
label<-readxl::read_excel(inpL)#, colClasses=c(rep("factor",3)))
label<-data.frame(label)
#cor(label$cell.number/label$cur.area,label$ratio.correction.factor)
rownames(label)=sub(selection,"",label$Name)
label["pair2test"]<-label[lGroup]
if(rGroup %in% colnames(label)){label["removed"]<-label[rGroup]} else{label["removed"]=NA}
label[is.na(label[lGroup]),"removed"]<-"R"
print(label)
table(label["removed"])
table(label[lGroup])
table(label[is.na(label["removed"]),lGroup])
rownames(label)<-sub("-",".",rownames(label))
plot(label)
hist(label$Fertilisation)
hist(label$eyed.stage)
hist(label$Hatching)
hist(label$Spine.stage)
label$pH<-as.numeric(label$pH)
hist(label$pH)
hist(label$RWH)
label$Osmolality<-as.numeric(label$Osmolality)
hist(label$Osmolality)
label$AST<-as.numeric(label$AST)
hist(label$AST)
plot(label$Fertilisation,label$eyed.stage)#,na.rm=T)
plot(label$Fertilisation,label$Hatching)#,na.rm=T)
plot(label$eyed.stage~label$Hatching)#abline(lm(label$eyed.stage~label$Hatching))#,na.rm=T)
cor.test(label$eyed.stage,label$Hatching)
write.table(label,paste0(inpL,".txt"),sep="\t",row.names = F,quote = F)
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
row.names(data)<-paste(row.names(data),data$Protein.IDs,data$Fasta.headers,data$Peptide.counts..all.,data$Sequence.coverage....,data$Score,sep = ";;")
data$rowName<-paste(sapply(strsplit(paste(sapply(strsplit(data$Fasta.headers, "|",fixed=T), "[", 2)), "-"), "[", 1))
data$geneName<-paste(sapply(strsplit(paste(sapply(strsplit(data$Fasta.headers, "_",fixed=T), "[", 2)), "OS="), "[", 1))
data$uniprotID<-paste(sapply(strsplit(paste(sapply(strsplit(data$Protein.IDs, ";",fixed=T), "[", 1)), "-"), "[", 1))
data[data$geneName=="NA","geneName"]=data[data$geneName=="NA","uniprotID"]
summary(data)
dim(data)
log2Int<-as.matrix(log2(data[,grep("Intensity.",colnames(data))]))
log2Int[log2Int==-Inf]=NA
colnames(log2Int)=sub("Intensity.","",colnames(log2Int))
hist(log2Int,main=paste("Mean:",mean(log2Int,na.rm=T),"SD:",sd(log2Int,na.rm=T)),breaks=round(max(log2Int,na.rm=T)),xlim=range(min(log2Int,na.rm=T),max(log2Int,na.rm=T)))
summary(log2(data[,grep("Intensity",colnames(data))]))
par(mar=c(12,3,1,1))
boxplot(log2Int,las=2,main="Log2Intensity")
#maxLFQ####
LFQ<-as.matrix(data[,grep(selection,colnames(data))])
#LFQ<-LFQ[,2:ncol(LFQ)]
#protNum<-1:ncol(LFQ)
#protNum<-"LFQ intensity"#1:ncol(LFQ)
#colnames(LFQ)=paste(protNum,sub(selection,"",colnames(LFQ)),sep=";")
colnames(LFQ)=sub(selection,"",colnames(LFQ))
dim(LFQ)
LFQ<- LFQ[,colnames(LFQ)!="peptides"]
dim(LFQ)
log2LFQ<-log2(LFQ)
log2LFQ[log2LFQ==-Inf]=NA
summary(log2LFQ)
hist(log2LFQ,main=paste("Mean:",mean(log2LFQ,na.rm=T),"SD:",sd(log2LFQ,na.rm=T)),breaks=round(max(log2Int,na.rm=T)),xlim=range(min(log2Int,na.rm=T),max(log2Int,na.rm=T)))
par(mar=c(12,3,1,1))
boxplot(log2LFQ,las=2,main=selection)
writexl::write_xlsx(as.data.frame(cbind(data$rowName,log2LFQ,rownames(data))),paste0(inpD,selection,"log2.xlsx"))
#corHClfq####
log2LFQimpCorr<-cor(log2LFQ,use="pairwise.complete.obs",method="pearson")
colnames(log2LFQimpCorr)<-colnames(log2LFQ)
rownames(log2LFQimpCorr)<-colnames(log2LFQ)
summary(log2LFQimpCorr)
hist(log2LFQimpCorr)
heatmap(log2LFQimpCorr)
#test####
testCor <- function(log2LFQ,sel1,sel2){
  #sel1<-"EP"
  #sel2<-"Fertilisation"
  #selection<-selection
  #log2LFQ<-log2LFQselCor
  #hist(log2LFQ)
  #colnames(log2LFQ)
  d1<-data.frame(log2LFQ[,gsub("-",".",rownames(label[label$pair2test==sel1&!is.na(label$pair2test),]))])
  rNd1<-rownames(d1)
  d1<-sapply(d1, as.numeric)
  rownames(d1)<-rNd1
  colnames(d1)<-rownames(label[label$pair2test==sel1&!is.na(label$pair2test),])
  hist(d1)
  summary(d1)
  d2<-data.frame((label[label$pair2test==sel1&!is.na(label$pair2test),sel2]))
  d2<-sapply(d2, as.numeric)
  rownames(d2)<-rownames(label[label$pair2test==sel1&!is.na(label$pair2test),])
  d2<-t(d2)
  summary(d2)
  hist(d2)
  colnames(d2)
  colnames(d1)<-paste(colnames(d1),d2,sep=";;")
  if(sum(!is.na(d1))>thr&sum(!is.na(d2))>thr){
    hist(d1)
    hist(d2)
    comp<-paste0(sel1,sel2)
    options(nwarnings = 1000000)
    resCor=apply(d1, 1,function(x)
      if(sum(!is.na(x))<thr){NA}
      #if(sum(!is.na(x))<2){NA}
      else{
        cort=cor.test(as.numeric(x),as.numeric(d2),use="pairwise.complete.obs",method="pearson")
        cort=unlist(cort)
      paste(cort[[1]],cort[[2]],cort[[3]],cort[[4]],sep="--VALS--")
    }
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
    writexl::write_xlsx(corTest.results,paste0(inpF,comp,selThr,selThrCor,lGroup,rGroup,lName,selection,"CorTestBH.xlsx"))
    write.csv(corTest.results,paste0(inpF,comp,selThr,selThrCor,lGroup,rGroup,lName,selection,"CorTestBH.csv"),row.names = F)
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
    ggplot2::ggsave(paste0(inpF,comp,selThr,selThrCor,lGroup,rGroup,lName,selection,"VolcanoTestCor.svg"), p)
    print(p)
    return(sum(Significance,na.rm = T))
  }
}
#compare####
cor.test(seq(0.,0.4,0.1),seq(0.5,0.9,0.1))
label=label[is.na(label$removed)|label$removed==" "|label$removed=='',]
table(label$pair2test)
cnt=0
for(i in 1:length(rownames(table(label$pair2test)))){
  cnt=cnt+1
  i=rownames(table(label$pair2test))[cnt]
  print(paste(i))
  rtPair=testCor(log2LFQ,i,scaleF)
  print(rtPair)
  #assign(i,rtPair)
}
