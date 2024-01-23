args = commandArgs(trailingOnly=TRUE)
print(paste("supplied argument(s):", length(args)))
print(args)
if (length(args) != 1) {stop("\n\nNeeds the full path to proteinGroups.txt \"", call.=FALSE)}
#thesholds####
thr=3#count
selThr=0.1#pValue-CorTest
selThrCor=0.75##correlation-CorTest
print(paste("Thresholds used - ", thr ,"#count-valid-samples," ,selThr,"#pValue-CorTest,",selThrCor,"#correlation-CorTest"))
#args####
inpF <- args[1]
#inpF <-"L:/promec/TIMSTOF/LARS/2024/Kine_Samset_Hoem/DDA/240103_KineSamsetHoem/txt243lin/txt/proteinGroups.txt"
selection<-"LFQ.intensity."
cortype<-"spearman"
inpD<-dirname(inpF)
fName<-basename(inpF)
hdr<-gsub("[^[:alnum:]]", "",inpD)
outP=paste(inpF,selection,selThr,selThrCor,hdr,cortype,"VolcanoTestCor","pdf",sep = ".")
pdf(outP)
#data####
data <- read.table(inpF,stringsAsFactors = FALSE, header = TRUE, quote = "", comment.char = "", sep = "\t")
##clean####
data = data[!data$Reverse=="+",]
data = data[!data$Potential.contaminant=="+",]
#data = data[!data$Only.identified.by.site=="+",]
row.names(data)<-paste(row.names(data),data$Protein.IDs,data$Fasta.headers,data$Peptide.counts..all.,data$Sequence.coverage....,data$Score,sep = ";;")
data$rowName<-paste(sapply(strsplit(paste(sapply(strsplit(data$Fasta.headers, "|",fixed=T), "[", 2)), "-"), "[", 1))
data$geneName<-paste(sapply(strsplit(paste(sapply(strsplit(data$Fasta.headers, "_",fixed=T), "[", 2)), "OS="), "[", 1))
data$uniprotID<-paste(sapply(strsplit(paste(sapply(strsplit(data$Protein.IDs, ";",fixed=T), "[", 1)), "-"), "[", 1))
data[data$geneName=="NA","geneName"]=data[data$geneName=="NA","uniprotID"]
summary(data)
dim(data)
#maxLFQ####
LFQ<-as.matrix(data[,grep(selection,colnames(data))])
LFQ0<-LFQ[,1]+1
summary(LFQ0)
#colnames(LFQ0)<-colnames(LFQ)[1]
virLFQ<-LFQ[,c(4,6,8,11,3)]
ctrLFQ<-LFQ[,c(5,7,9,10,2)]
diffLFQ<-virLFQ-ctrLFQ
diffLFQ0<-diffLFQ/(LFQ0)
hist(diffLFQ0)
summary(diffLFQ0)
diffLFQ0[diffLFQ0==0]=NA
summary(diffLFQ0)
hist(diffLFQ0)
par(mar=c(12,3,1,1))
boxplot(diffLFQ0,las=2,main=selection)
#writeCSVcor####
corFac=data.frame(t(c(1,2,4,6,24)))
names(corFac)<-colnames(diffLFQ0)
write.csv(as.data.frame(cbind(data$rowName,diffLFQ0,corFac)),paste0(inpF,selection,"diffLFQ0.csv"))
#corHClfq####
log2LFQimpCorr<-cor(diffLFQ0,use="pairwise.complete.obs",method="pearson")
colnames(log2LFQimpCorr)<-gsub(selection,"",colnames(diffLFQ0))
rownames(log2LFQimpCorr)<-gsub(selection,"",colnames(diffLFQ0))
summary(log2LFQimpCorr)
hist(log2LFQimpCorr)
heatmap(log2LFQimpCorr)
d1<-diffLFQ0
hist(d1)
summary(d1)
d2<-corFac
summary(d2)
colnames(d2)
colnames(d1)<-paste(colnames(d1),d2,sep=";;")
hist(d1)
comp<-paste0("vir2ctr","time")
options(nwarnings = 1000000)
resCor=apply(d1, 1,function(x)
  if((sum(!is.na(x))<thr)){NA}
  #if(sum(!is.na(x))<2){NA}
  else if(sum(!is.na(x-d2))>=thr){
    cort=cor.test(as.numeric(x),as.numeric(d2),use="pairwise.complete.obs",method=cortype)
    cort=unlist(cort)
    paste(cort[[1]],cort[[2]],cort[[3]],cort[[4]],sep="--VALS--")
  }
  else{NA}
)
pValCor<-sapply(strsplit(resCor, "--VALS--",fixed=T), "[", 2)
pValNA<-sapply(pValCor,as.numeric)
hist(pValNA)
cValCor<-sapply(strsplit(resCor, "--VALS--",fixed=T), "[", 3)
cValNA<-sapply(cValCor,as.numeric)
hist(cValNA)
tValCor<-sapply(strsplit(resCor, "--VALS--",fixed=T), "[", 1)
tValNA<-sapply(tValCor,as.numeric)
hist(tValNA)
yValCor<-sapply(strsplit(resCor, "--VALS--",fixed=T), "[", 4)
yValNA<-sapply(yValCor,as.numeric)
hist(yValNA)
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
writexl::write_xlsx(corTest.results,paste0(inpF,comp,selThr,selThrCor,selection,cortype,"CorTestBH.xlsx"))
write.csv(corTest.results,paste0(inpF,comp,selThr,selThrCor,selection,cortype,"CorTestBH.csv"),row.names = F)
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
ggplot2::ggsave(paste0(inpF,comp,selThr,selThrCor,selection,cortype,".VolcanoTestCor.svg"), p)
print(p)
