#..\R\bin\Rscript.exe diffExprANOVA.r "L:\promec\TIMSTOF\LARS\2022\august\220819 Toktam\combined\txt\proteinGroups.txt" "L:\promec\TIMSTOF\LARS\2022\august\220819 Toktam\combined\txt\Groups.txt" Sample
options(nwarnings = 1000000)
summary(warnings())
print("USAGE:<path to>Rscript diffExprANOVA.r <complete path to proteinGroups.txt> <complete path to label.txt file> <name of group column in label.txt>")
args = commandArgs(trailingOnly=TRUE)
print(paste("supplied argument(s):", length(args)))
print(args)
if (length(args) != 3) {stop("\n\nNeeds TWO arguments, the full path of the directory containing BOTH proteinGroups.txt&label.txt files followed by the name of GROUP column in label.txt file respectively, for example:
../R/bin/Rscript.exe diffExprANOVA.r \"L:/promec/TIMSTOF/LARS/2022/august/220819 Toktam/combined/txt/proteinGroups.txt\" \"L:/promec/TIMSTOF/LARS/2022/august/220819 Toktam/combined/txt/Groups.txt\" Sample", call.=FALSE)}
#setup####
inFile <- args[1]
#inFile<-"L:/promec/TIMSTOF/LARS/2022/august/220819 Toktam/combined/txt/proteinGroups.txt"
print(inFile)
inLabel <- args[2]
#inLabel<-"L:/promec/TIMSTOF/LARS/2022/august/220819 Toktam/combined/txt/Groups.txt"
print(inLabel)
lGroup <- args[3]
#lGroup<-"Sample"
print(lGroup)
inpF<-inFile
inpL<-inLabel
inpD<-dirname(inpF)
fName<-basename(inpF)
lName<-basename(inpL)
hdr<-gsub("[^[:alnum:] ]", "",inpD)
selection<-"LFQ.intensity."
#data####
data <- read.table(inpF,stringsAsFactors = FALSE, header = TRUE, quote = "", comment.char = "", sep = "\t")
##clean####
data = data[!data$Reverse=="+",]
data = data[!data$Potential.contaminant=="+",]
data = data[!data$Only.identified.by.site=="+",]
row.names(data)<-paste(row.names(data),data$Fasta.headers,data$Protein.IDs,data$Score,data$Peptide.counts..unique.,sep=";;")
summary(data)
dim(data)
rowName<-paste(sapply(strsplit(paste(sapply(strsplit(data$Fasta.headers, "|",fixed=T), "[", 2)), "-"), "[", 1))
data$uniprotID<-paste(sapply(strsplit(paste(sapply(strsplit(data$Protein.IDs, ";",fixed=T), "[", 1)), "-"), "[", 1))
data$geneName<-paste(sapply(strsplit(paste(sapply(strsplit(data$Fasta.headers, "GN=",fixed=T), "[", 2)), " "), "[", 1))
data[data$geneName=="NA","geneName"]=data[data$geneName=="NA","uniprotID"]
data$Protein.name<-paste(sapply(strsplit(paste(sapply(strsplit(data$Fasta.headers, "GN=",fixed=T), "[", 1)), ";",fixed=T), "[", 1))
summary(data)
dim(data)
##LFQ####
log2LFQ<-as.matrix(data[,grep(selection,colnames(data))])
colnames(log2LFQ)=sub(selection,"",colnames(log2LFQ))
log2LFQ<-log2(log2LFQ)
log2LFQ[log2LFQ==-Inf]=0
log2LFQ[is.na(log2LFQ)]<-0
#log2LFQ[log2LFQ==-Inf]=NA
summary(log2LFQ)
dim(log2LFQ)
write.csv(as.data.frame(cbind(fastaHdr=rownames(log2LFQ),log2LFQ)),paste0(inFile,"log2LFQ.csv"),row.names=F)
#samples####
label<-read.table(inLabel,header=T,sep="\t",row.names=1)#, colClasses=c(rep("factor",3)))
rownames(label)=sub(selection,"",rownames(label))
colnames(log2LFQ)
samples<-label[lGroup]
rownames(samples)=sub(selection,"",rownames(samples))
rownames(samples)<-gsub("-",".",rownames(samples))
samples<-as.character(samples[order(colnames(log2LFQ)),])
print(samples)
#test####
#x<-log2LFQ[1,]
#pValANOVA=apply(log2LFQ, 1,function(x) summary(aov(as.double(x)~as.character(samples)))[[1]][["Pr(>F)"]][[1]])
resANOVA=apply(log2LFQ, 1,function(x){
  samplez<-samples[!is.na(x)]
    if(length(unique(samplez))>2){
    x<-x[!is.na(x)]
    aovt=aov(as.double(x)~samplez)
    pval=summary(aovt)[[1]][["Pr(>F)"]][[1]]
    postHoc<-TukeyHSD(aovt)
    names(postHoc)<-"compare"
    postHoc<-data.frame(postHoc$compare)
    padj<-postHoc["p.adj"]
    diff<-postHoc["diff"]
    paste(pval,padj,diff,paste(rownames(postHoc),collapse="--GROUPS--"),sep="--VALS--")
    }
  }
)
pValANOVA<-sapply(strsplit(resANOVA, "--VALS--",fixed=T), "[", 1)
summary(warnings())
pValANOVA<-sapply(pValANOVA,as.numeric)
#hist(pValANOVA)
groupsANOVA<-sapply(strsplit(resANOVA, "--VALS--",fixed=T), "[", 4)
groupsANOVA<-strsplit(groupsANOVA, "--GROUPS--",fixed=T)
if(unique(unique(groupsANOVA)[[1]]==unique(groupsANOVA[[1]]))){
  padjv=sapply(strsplit(resANOVA, "--VALS--",fixed=T), "[", 2)
  padjv=data.frame(padjv)
  #eval(padjv)
  padjv=data.frame(do.call("rbind", strsplit(as.character(padjv$padjv), "c|\\(|\\)|\\,")))
  padjv=padjv[,3:ncol(padjv)]
  padjv=sapply(padjv, as.numeric)
  #hist(padjv)
  mlog10padjv=-log10(padjv)
  #hist(mlog10padjv)
  colnames(padjv)<-paste(groupsANOVA[[1]],"PvalueTukeyHSD",sep="-")
  colnames(mlog10padjv)<-paste(groupsANOVA[[1]],"mLog10PvalueTukeyHSD",sep="-")
  diffv=sapply(strsplit(resANOVA, "--VALS--",fixed=T), "[", 3)
  diffv=data.frame(diffv)
  diffv=data.frame(do.call("rbind", strsplit(as.character(diffv$diffv), "c|\\(|\\)|\\,")))
  diffv=diffv[,3:ncol(diffv)]
  diffv=sapply(diffv, as.numeric)
  #hist(diffv)
  colnames(diffv)<-paste(groupsANOVA[[1]],"Difference",sep="-")
  #hist(padjv$X2)
  #eval(padjv$padjv[1])
  #strsplit(as.character(padjv[,1]), " ",fixed=T)
  #split(padjv, " ")
  #unique(sapply(strsplit(groupsANOVA, "---",fixed=T), "[", c(1)))
}
#summary(warnings())
#tc=apply(log2LFQ, 1, function(x)   tryCatch(TukeyHSD(aov(x~samples,"Sample", ordered = TRUE)),error=function(x){return(rep(1,20))})}) tryCatch(TukeyHSD(aov(x~factorC,"factorC")),error=function(x){return(rep(1,20))})})
#outdata <- matrixData(main=as.data.frame(pValANOVA))
#anova(lm(as.numeric(dataNorm[2,])~factorC*factorS))
#aov((as.numeric(dataNorm[2,])~factorC*factorS))
#TukeyHSD(aov((as.numeric(dataNorm[2,])~factorC*factorS)))
#tc=apply(dataNorm,1,function(x){
  #tc=apply(dataNorm, 1, function(x)
#  tryCatch(TukeyHSD(aov(x~factorC*factorS),"factorC:factorS", ordered = TRUE),error=function(x){return(rep(1,15))})})
#wval=t(sapply(names(tc),function(x){tryCatch(tc[[x]]$`factorC:factorS`[46:60],error=function(x){return(rep(1,15))})}))
#write.table(wval,outF,sep="\t")
#tc$`F7A0B0;P04370-9;F6ZIA4;P04370-7`
#dataNorm[grep("F7A",row.names(data)),]
#try(TukeyHSD(aov((x~factorC*factorS)))))
#tcold$`A0A087WNP6;Q4VAA2-2;Q4VAA2;A0A087WRM0;F8WGL9;A0A087WS49`
#plot(tc$`A0A087WNP6;Q4VAA2-2;Q4VAA2;A0A087WRM0;F8WGL9;A0A087WS49`)
#write.table(t(tc),sep = "\t")
#outF = paste0(inpF,"anovaTukey.txt")
#class(tc)
#names(tc)
#do.call(rbind, lapply(names(tc), function(x) data.frame(c(ID=x, tc$x$`factorC:factorS`))))
#lapply(names(tc), function(x) write.table(t(t(tcold[[x]]$`factorC:factorS`)[4,]),outF,sep = "\t"))
#write.table(t(sapply(tc,
#                     function(x){tryCatch(x$`factorC:factorS`)})),sep="\t")
#function(x){tryCatch(x$`factorC:factorS`,error=function(x){return(NULL)})})),outF,sep="\t")
#write.table(t(t(tc$x$`factorC:factorS`)[4,]),sep = "\t")
#write.table(t(t(tc$`A0A087WNP6;Q4VAA2-2;Q4VAA2;A0A087WRM0;F8WGL9;A0A087WS49`$`factorC:factorS`)[4,]),sep = "\t")
#dump(tc, file=outF)
#log10(.Machine$double.xmin)
pValNAminusdif10 = -log10(pValANOVA+.Machine$double.xmin)
#hist(pValNAminusdif10)
pValBHna = p.adjust(pValANOVA,method = "BH")
#hist(pValBHna)
pValBHnaMinusdif10 = -log10(pValBHna+.Machine$double.xmin)
#hist(pValBHnaMinusdif10)
logFCmedianGrp = apply(
  log2LFQ, 1, function(x)
    median(x[c(1:ncol(log2LFQ))],na.rm=T)    )
#hist(logFCmedianGrp)
logFCmedianGrp[is.nan(logFCmedianGrp)]=0
logFCmedian = logFCmedianGrp#-logFCmedianGrp
logFCmedianFC = 2^(logFCmedian+.Machine$double.xmin)
#hist(logFCmedianFC)
log2FCmedianFC=log2(logFCmedianFC)
#hist(log2FCmedianFC)
aov.results = data.frame(Uniprot=rowName,Gene=data$geneName,Protein=data$Protein.name,Uniprots=data$Protein.IDs,FastaHDRs=data$Fasta.headers,log2LFQ,medianVal=logFCmedian,MinusLog10PValue=pValNAminusdif10,medianFold=logFCmedianFC,CorrectedPValueBH=pValBHna,ANOVApVal=pValANOVA,diffv,padjv,mlog10padjv)#,resANOVA)
dim(aov.results)
#write####
write.csv(aov.results,paste0(inFile,lName,lGroup,selection,"ANOVA.csv"),row.names=F)
print(paste0(inFile,lGroup,selection,hdr,".ANOVA.csv"))
summary(warnings())
