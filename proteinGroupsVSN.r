#..\..\R-4.5.0\bin\Rscript proteinGroupsVSN.r "L:\promec\TIMSTOF\LARS\2026\260518_Sonali\DIANNv2P2.63.260612_140833.64.highacc\report.pg_matrix.tsv" "F..promec.TIMSTOF.LARS.2026.260518_Sonali.260518_Sonali_"
#install.packages(c("BiocManager"),repos="http://cran.us.r-project.org",lib=.libPaths())
#BiocManager::install(c("vsn"))
print("USAGE:<path to>Rscript diffExprTestCor.r <complete path to proteinGroups.txt> and <intensity columns to consider>")
args = commandArgs(trailingOnly=TRUE)
print(paste("supplied argument(s):", length(args)))
print(args)
if (length(args) != 2) {stop("\n\nNeeds the full path to proteinGroups.txt and the intensity columns to consider", call.=FALSE)}
#args####
inpF <- args[1]
#inpF <- "proteinGroups.txt"
selection<-args[2]
#selection<-"LFQ"
outP=paste(inpF,selection,"vsn","pdf",sep = ".")
pdf(outP)
#data####
data <- read.table(inpF,stringsAsFactors = FALSE, header = TRUE, quote = "", comment.char = "", sep = "\t")
print(colnames(data))
summary(data)
dim(data)
#sel####
IntVST<-as.matrix(data[,grep(selection,colnames(data))])
IntVST[IntVST==0]=NA
summary(IntVST)
boxplot(log2(IntVST),las=2,main="log2IntVST")
#IntVST<-IntVST[rowSums(is.na(IntVST)) != ncol(IntVST), ]
#IntVST<-IntVST[, colSums(is.na(IntVST)) != nrow(IntVST)]
metaCol<-colnames(data)[-c(grep(selection,colnames(data))), drop = FALSE]
row.names(IntVST)<-apply(data[,c(metaCol),drop = FALSE], 1, paste, collapse = ";_;")
##justVSN####
LFQvsn <- vsn::justvsn(IntVST,minDataPointsPerStratum=0)
colnames(LFQvsn) <- paste0("vsn_", colnames(LFQvsn))
hist(LFQvsn)
vsn::meanSdPlot(LFQvsn)
vsn::meanSdPlot(LFQvsn,ranks = FALSE)
boxplot(LFQvsn,las=2,main="vsn")
for (i in 1:ncol(LFQvsn)) {
  if (sum(!is.na(LFQvsn[,i]))>0) {
    y=LFQvsn[,i]
    x=log2(IntVST[,i])
    modXY <- lm(y ~ x) # For 0 intercept: lm(y ~ x - 1)
    modXYsum <- summary(modXY)
    plot(x,y,xlab=colnames(IntVST)[i],ylab=colnames(LFQvsn)[i],main=paste(i,modXYsum$call[2],modXYsum$df[2]),pch=19,cex=0.5)
    abline(modXY, col = "blue", lwd = 2)
    r_2 <- modXYsum$r.squared
    b <- modXYsum$coefficients[1]
    legend("topleft",  legend = c(paste("R² =", r_2), paste("β =", b)))
  }
}
pow2LFQvsn <- 2^LFQvsn
colnames(pow2LFQvsn) <- paste0("pow2_", colnames(pow2LFQvsn))
metaData <- do.call(rbind, strsplit(row.names(LFQvsn), split = ";_;"))
colnames(metaData) <- metaCol
write.table(cbind(metaData, IntVST, LFQvsn, pow2LFQvsn),file=paste(inpF,selection,"vsn","txt",sep = "."),row.names = FALSE,sep = "\t",quote = FALSE)
