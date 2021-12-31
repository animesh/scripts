#data####
#c:/Users/animeshs/R/bin/Rscript.exe diffExprTestT.r L:/promec/TIMSTOF/LARS/2021/November/SIGRID/combined/txtNoNQd/ group
inpD<-"L:/promec/TIMSTOF/LARS/2021/November/SIGRID/combined/txtNoNQd/"
ttDF<-read.csv(paste0(inpD,"proteinGroups.txtLFQ.intensity.16WT8hWTctrl0.050.50.05grouptTestBH.csv.sort.combined.csv"),row.names = 1)
sel<-"proteinGroups.txtLFQ.intensity.16"
sel2<-"0.050.50.05grouptTestBH.csv"
colnames(ttDF)<-sub(sel,"",colnames(ttDF))
colnames(ttDF)<-sub(sel2,"",colnames(ttDF))
rName<-rownames(ttDF)
ttDF<-sapply(ttDF, as.numeric)
ttDF[is.na(ttDF)]<-0
hist(ttDF)
limma::vennDiagram(ttDF[,1:5]>0)
boxplot(ttDF)
log2LFQimpCorr<-cor(ttDF,use="pairwise.complete.obs",method="spearman")
#rownames(log2LFQimpCorr)<-colnames(hda)
svgPHC<-pheatmap::pheatmap(log2LFQimpCorr,clustering_distance_rows = "euclidean",clustering_distance_cols = "euclidean",fontsize_row=8,cluster_cols=T,cluster_rows=T,fontsize_col  = 8)
dataLog2NormLOESS<-limma::normalizeCyclicLoess(ttDF, weights = NULL, span=0.7, iterations = 3, method = "fast")
boxplot(dataLog2NormLOESS)
#match####
tsDF<-read.csv(paste0(inpD,"proteinGroupsTS.txt"),sep="\t")
hist(tsDF$N..WT.q.value)
hist(tsDF$N..MUT.q.value)
plot(tsDF$N..WT.q.value,tsDF$N..MUT.q.value)
plot(tsDF$N..MUT.q.value,tsDF$N..MUT.Phase)
plot(tsDF$N..WT.q.value,tsDF$N..WT.Phase)
tswapDF<-read.csv(paste0(inpD,"proteinGroupsTSwap.txt"),sep="\t")
hist(tswapDF$N..WT.q.value)
hist(tswapDF$N..MUT.q.value)
plot(tswapDF$N..WT.q.value,tswapDF$N..MUT.q.value)
plot(tswapDF$N..MUT.q.value,tswapDF$N..MUT.Phase)
plot(tswapDF$N..WT.q.value,tswapDF$N..WT.Phase)
tswapDFwt<-read.csv(paste0(inpD,"proteinGroupsTSwapWT.txt"),sep="\t")
hist(tswapDFwt$N..q.value)
plot(tswapDFwt$N..q.value,tswapDFwt$N..Phase)
tswapDFmut<-read.csv(paste0(inpD,"proteinGroupsTSwapMUT.txt"),sep="\t")
hist(tswapDFmut$N..q.value)
plot(tswapDFmut$N..q.value,tswapDFmut$N..Phase)
tswapDFwt2<-read.csv(paste0(inpD,"proteinGroupsTSwapWTl2.txt"),sep="\t")
hist(tswapDFwt2$N..q.value)
plot(tswapDFwt2$N..q.value,tswapDFwt2$N..Phase)
tswapDFmut2<-read.csv(paste0(inpD,"proteinGroupsTSwapMUTl2.txt"),sep="\t")
hist(tswapDFmut2$N..q.value)
plot(tswapDFmut2$N..q.value,tswapDFmut2$N..Phase)
#JTK####
dataM<-read.csv('L:/promec/TIMSTOF/LARS/2021/November/SIGRID/combined/txtNoNQd/proteinGroupsTSwapMUTlabelComb.csv')
dataMT<-t(dataM[,10:500])
annoMT<-rownames(dataMT)
#dataMT<-t(dataMT[1,c(2:13,1,14:21)])
dataMT<-(dataMT[,c(2:13,1,14:21)])
write.csv(dataMT,"dataMT.csv")
group.sizes<-t(dataM[c(2:13,1,14:21),501])
plot(group.sizes,dataMT)
group.sizes<-c(group.sizes,group.sizes,group.sizes)
# Shewchuk algorithms for adaptive precision summation used in jtkdist
# http://www.cs.cmu.edu/afs/cs/project/quake/public/papers/robust-arithmetic.ps
source("F:/OneDrive - NTNU/Downloads/JTKversion3/JTK_CYCLEv3.1.R")
jtkdist(length(group.sizes),group.sizes)
jtkdist(7,3)
periods <- 4:24
jtk.init(periods,3)
print(JTK.DIMS)
flush.console()
st <- system.time({
  res <- apply(dataMT,1,function(z) {
    jtkx(z)
    c(JTK.ADJP,JTK.PERIOD,JTK.LAG,JTK.AMP)
  })
  res <- as.data.frame(t(res))
  bhq <- p.adjust(unlist(res[,1]),"BH")
  res <- cbind(bhq,res)
  colnames(res) <- c("BH.Q","ADJ.P","PER","LAG","AMP")
  results <- cbind(annoMT,res,dataMT)
  results <- results[order(res$ADJ.P,-res$AMP),]
})
print(st)
save(results,file=paste("JTK","rda",sep="."))
write.table(results,file=paste("JTK","txt",sep="."),row.names=F,col.names=T,quote=F,sep="\t")
write.csv(dataMT,"dataMT.csv")
#MetaCycle####
#devtools::install_github('gangwug/MetaCycle')
#https://cran.r-project.org/web/packages/MetaCycle/vignettes/implementation.html
library(MetaCycle)
?meta2d
cycMouseLiverRNA
meta2d(infile, outdir = "metaout", filestyle,
       timepoints, minper = 20,
       maxper = 28, cycMethod = c("ARS", "JTK", "LS"),
       analysisStrategy = "auto", outputFile = TRUE,
       outIntegration = "both", adjustPhase = "predictedPer",
       combinePvalue = "fisher", weightedPerPha = FALSE,
       ARSmle = "auto",
       ARSdefaultPer = 24, outRawData = FALSE, releaseNote = TRUE,
       outSymbol = "", parallelize = FALSE, nCores = 1, inDF = NULL)
?meta3d
meta3d(datafile, designfile, outdir = "metaout", filestyle,
       design_libColm, design_subjectColm, minper = 20, maxper = 28,
       cycMethodOne = "JTK", timeUnit = "hour", design_hrColm,
       design_dayColm = NULL, design_minColm = NULL,
       design_secColm = NULL, design_groupColm = NULL,
       design_libIDrename = NULL, adjustPhase = "predictedPer",
       combinePvalue = "fisher", weightedMethod = TRUE,
       outIntegration = "both", ARSmle = "auto", ARSdefaultPer = 24,
       dayZeroBased = FALSE, outSymbol = "", parallelize = FALSE,
       nCores = 1)
head(cycMouseLiverRNA[,1:5])
row_index <- sample(1:nrow(cycHumanBloodDesign), 4)
cycHumanBloodDesign[row_index,]
sample_id <- cycHumanBloodDesign[row_index,1]
head(cycHumanBloodData[,c("ID_REF", sample_id)])
#testD####
testD <- read.csv("dataMT.csv")
timev <- group.sizes#1:21
#timev[1:6] <- timev[1:6] +1#group.sizes-1#1:21
outD <- meta2d(infile="csv", filestyle="csv", timepoints = timev, outputFile=FALSE, inDF=testD)
min(outD[["meta"]][["LS_BH.Q"]])
min(outD[["meta"]][["LS_pvalue"]])
plot(outD[["meta"]][["LS_BH.Q"]],outD[["meta"]][["LS_pvalue"]])
plot(outD[["meta"]][["LS_pvalue"]],p.adjust(outD[["meta"]][["LS_pvalue"]],"BH"))
min(p.adjust(outD[["meta"]][["LS_pvalue"]],"BH"))
plot(p.adjust(outD[["meta"]][["LS_pvalue"]],"BH"),outD[["meta"]][["LS_BH.Q"]])
#IDH1####
data <-read.csv(paste0(inpD,"proteinGroupsMUT.txt"),sep="\t")
testD <-data[,c(36,1:21)]
summary(testD)
#testD[is.null(testD)]<-NA
testD[testD==0]<-NA
testD<-testD[complete.cases(testD),]#<-NA
summary(testD)
timev <- group.sizes-1#+1#1:21
timev[1:6] <- timev[1:6] +1#group.sizes-1#1:21
outD <- meta2d(infile="csv", filestyle="csv", timepoints = timev, outputFile=FALSE, inDF=testD)
min(outD[["meta"]][["LS_BH.Q"]])
hist(outD[["meta"]][["LS_pvalue"]])
min(outD[["meta"]][["LS_pvalue"]])
plot(outD[["meta"]][["LS_BH.Q"]],outD[["meta"]][["LS_pvalue"]])
plot(outD[["meta"]][["LS_pvalue"]],p.adjust(outD[["meta"]][["LS_pvalue"]],"BH"))
min(p.adjust(outD[["meta"]][["LS_pvalue"]],"BH"))
plot(p.adjust(outD[["meta"]][["LS_pvalue"]],"BH"),outD[["meta"]][["LS_BH.Q"]])
write.csv(outD[["meta"]],paste0(inpD,"proteinGroupsMUT_LS24.csv"))
#MUT####
data <-read.csv(paste0(inpD,"proteinGroupsMUT.txt"),sep="\t")
testD <-data[,c(36,1:21)]
summary(testD)
#testD[is.null(testD)]<-NA
#testD[testD==0]<-NA
#testD<-testD[complete.cases(testD),]#<-NA
#summary(testD)
timev <- group.sizes-1#+1#1:21
timev[1:6] <- timev[1:6] +1#group.sizes-1#1:21
outD <- meta2d(infile="csv", filestyle="csv", timepoints = timev, outputFile=FALSE, inDF=testD)
min(outD[["meta"]][["LS_BH.Q"]])
hist(outD[["meta"]][["LS_pvalue"]])
min(outD[["meta"]][["LS_pvalue"]])
plot(outD[["meta"]][["LS_BH.Q"]],outD[["meta"]][["LS_pvalue"]])
plot(outD[["meta"]][["LS_pvalue"]],p.adjust(outD[["meta"]][["LS_pvalue"]],"BH"))
min(p.adjust(outD[["meta"]][["LS_pvalue"]],"BH"))
plot(p.adjust(outD[["meta"]][["LS_pvalue"]],"BH"),outD[["meta"]][["LS_BH.Q"]])
write.csv(outD[["meta"]],paste0(inpD,"proteinGroupsMUT_LS024.csv"))
#WT####
data <-read.csv(paste0(inpD,"proteinGroupsWT.txt"),sep="\t")
testD <-data[,c(36,1:21)]
summary(testD)
#testD[is.null(testD)]<-NA
#testD[testD==0]<-NA
#testD<-testD[complete.cases(testD),]#<-NA
#summary(testD)
timev <- group.sizes-1#+1#1:21
timev[1:6] <- timev[1:6] +1#group.sizes-1#1:21
outD <- meta2d(infile="csv", filestyle="csv", timepoints = timev, outputFile=FALSE, inDF=testD)
min(outD[["meta"]][["LS_BH.Q"]])
hist(outD[["meta"]][["LS_pvalue"]])
min(outD[["meta"]][["LS_pvalue"]])
plot(outD[["meta"]][["LS_BH.Q"]],outD[["meta"]][["LS_pvalue"]])
plot(outD[["meta"]][["LS_pvalue"]],p.adjust(outD[["meta"]][["LS_pvalue"]],"BH"))
min(p.adjust(outD[["meta"]][["LS_pvalue"]],"BH"))
plot(p.adjust(outD[["meta"]][["LS_pvalue"]],"BH"),outD[["meta"]][["LS_BH.Q"]])
write.csv(outD[["meta"]],paste0(inpD,"proteinGroupsWT_LS024.csv"))
