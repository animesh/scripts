#options(download.file.method = "wininet")
#install.packages("devtools")
#devtools::install_github("cox-labs/PerseusR")
library(PerseusR)
args = commandArgs(trailingOnly=TRUE)
if (length(args) != 2) {stop("NOTE: NaN imputed with 0 AND using Samples/last-categorical-annotation-row as groups, DONT supply any argument(s)!", call.=FALSE)}
inFile <- args[1]
outFile <- args[2]
#mCol <- args[3]
#inFile<-"L:/GD/tools/aovPerseusR/matrix.txt"
#outFile<-"L:/GD/tools/aovPerseusR/matrix.out"
mdata <- read.perseus(inFile)
mainMatrix <- main(mdata)
#dim(mainMatrix)
#summary(mainMatrix)
mdata@imputeData[is.na(mainMatrix)]="True"
mainMatrix[is.na(mainMatrix)]<-0
#mainMatrix<-mainMatrix[complete.cases(mainMatrix),]
#samples<-mdata@annotRows$Grouping
samples<-t(mdata@annotRows[ncol(mdata@annotRows)])
#aovt=aov(as.double(mainMatrix[2,])~as.character(samples))
#dim(mainMatrix)
options(nwarnings = 1000000)
#pValANOVA=apply(mainMatrix, 1,function(x) summary(aov(as.double(x)~as.character(samples)))[[1]][["Pr(>F)"]][[1]])
resANOVA=apply(mainMatrix, 1,function(x){
    aovt=aov(as.double(x)~as.character(samples))
    pval=summary(aovt)[[1]][["Pr(>F)"]][[1]]
    postHoc<-TukeyHSD(aovt)
    names(postHoc)<-"compare"
    postHoc<-data.frame(postHoc$compare)
    padj<-postHoc["p.adj"]
    diff<-postHoc["diff"]
    paste(pval,padj,diff,paste(rownames(postHoc),collapse="--GROUPS--"),sep="--VALS--")
  }
)
pValANOVA<-sapply(strsplit(resANOVA, "--VALS--",fixed=T), "[", 1)
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
#tc=apply(mainMatrix, 1, function(x)   tryCatch(TukeyHSD(aov(x~samples,"Sample", ordered = TRUE)),error=function(x){return(rep(1,20))})}) tryCatch(TukeyHSD(aov(x~factorC,"factorC")),error=function(x){return(rep(1,20))})})
#outMdata <- matrixData(main=as.data.frame(pValANOVA))
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
  mainMatrix, 1, function(x)
    median(x[c(1:ncol(mainMatrix))],na.rm=T)    )
#hist(logFCmedianGrp)

logFCmedianGrp[is.nan(logFCmedianGrp)]=0

logFCmedian = logFCmedianGrp#-logFCmedianGrp
logFCmedianFC = 2^(logFCmedian+.Machine$double.xmin)
#hist(logFCmedianFC)
log2FCmedianFC=log2(logFCmedianFC)
#hist(log2FCmedianFC)
aov.results = data.frame(mainMatrix,medianVal=logFCmedian,MinusLog10PValue=pValNAminusdif10,medianFold=logFCmedianFC,CorrectedPValueBH=pValBHna,ANOVApVal=pValANOVA,diffv,padjv,mlog10padjv)#,resANOVA)
#dim(aov.results)
#dim(mainMatrix)
dfANOVA=data.frame(matrix("AOV", nrow = (ncol(aov.results)-ncol(mainMatrix)), ncol = ncol(mdata@annotRows)))
colnames(dfANOVA)=colnames(mdata@annotRows)
dfANOVA=rbind(mdata@annotRows,dfANOVA)
#dim(dfANOVA)
#df[nrow(df) + 1,] = rep("ANOVA",ncol(df))
write.perseus(aov.results, outFile,imputeData=mdata@imputeData,qualityData = mdata@qualityData,annotCols=mdata@annotCols,annotRows=dfANOVA)
