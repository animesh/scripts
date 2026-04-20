# "c:\Program Files\r\R-4.5.2\bin\Rscript.exe" diffExprTestLIMPA.r
#setup####
#BiocManager::install(c("limpa","pheatmap"))#,repos="http://cran.us.r-project.org",lib=.libPaths())
library(limpa) #https://bioconductor.org/packages/release/bioc/vignettes/limpa/inst/doc/limpa.html
set.seed(42)
#label####
labelF <- "L:/promec/TIMSTOF/LARS/2024/240605_Veronica/saga/txt/Groups.txt"   # built from exported column names
annoData<-read.table(labelF,header=T,sep="\t",row.names=1)#, colClasses=c(rep("factor",3)))
print(annoData)
#data####
inpF<-"L:/promec/TIMSTOF/LARS/2024/240605_Veronica/saga/txt/peptides.txt"
y.peptide <- readMaxQuant(inpF)
dpcFit    <- dpc(y.peptide)
#plot####
outP=paste(inpF,"TestLIMPA","pdf",sep = ".")
pdf(outP)
plotDPC(dpcFit)
y.proteinGroup <- dpcQuant(y.peptide, "Leading razor protein", dpc = dpcFit)
log2Int<-y.proteinGroup[["E"]]
print(dim(log2Int))
write.csv(log2Int,paste0(inpF,"pg.log2Int.csv"))
log2IntimpCorr<-cor(log2Int,use="pairwise.complete.obs",method="pearson")
svgPHC<-pheatmap::pheatmap(log2IntimpCorr)
ggplot2::ggsave(paste0(inpF,"log2Int.corr.svg"), svgPHC)
#des####
annoData <- annoData[colnames(y.peptide$E), , drop = FALSE]
stopifnot(identical(colnames(y.proteinGroup$E), colnames(y.peptide$E)))
stopifnot(identical(rownames(annoData), colnames(y.peptide$E)))
# Explicit 6 biological groups in the order we want
grp_levels <- c("CT26_1", "CT26_2", "CT26_3", "KPC_1", "KPC_2", "KPC_3")
annoData$Group <- factor(annoData$Cell_Rep, levels = grp_levels)
stopifnot(!any(is.na(annoData$Group)))
annoData$Group <- factor(make.names(as.character(annoData$Group)),levels = make.names(grp_levels))
# use ~0 + Group so each column is a group mean directly
design <- model.matrix(~ 0 + Group, data = annoData)
colnames(design) <- levels(annoData$Group)
print(head(design))
print(colnames(design))
print(table(annoData$Group))
# Colors for MDS (same 6 groups)
Group.color <- annoData$Group
levels(Group.color) <- c("blue", "orange", "darkgreen", "cyan", "magenta", "pink")
plotMDSUsingSEs(y.proteinGroup,pch = 16,col = as.character(Group.color),main = "MDS by Cell_Rep group",cex = 1,gene.selection = "common")
# Base fit
fit0 <- dpcDE(y.proteinGroup, design, plot = TRUE)
# Explicit 10 contrasts
contr <- makeContrasts(
  # 1) Overall cell-line comparison
  CellLine_KPC_vs_CT26 =
    (KPC_1 + KPC_2 + KPC_3)/3 - (CT26_1 + CT26_2 + CT26_3)/3,
  # 2-4) Overall experiment comparisons
  Exp2_vs_1_overall =
    (KPC_2 + CT26_2)/2 - (KPC_1 + CT26_1)/2,
  Exp3_vs_1_overall =
    (KPC_3 + CT26_3)/2 - (KPC_1 + CT26_1)/2,
  Exp3_vs_2_overall =
    (KPC_3 + CT26_3)/2 - (KPC_2 + CT26_2)/2,
  # 5-7) KPC-specific comparisons
  KPC_2_vs_1 = KPC_2 - KPC_1,
  KPC_3_vs_1 = KPC_3 - KPC_1,
  KPC_3_vs_2 = KPC_3 - KPC_2,
  # 8-10) CT26-specific comparisons
  CT26_2_vs_1 = CT26_2 - CT26_1,
  CT26_3_vs_1 = CT26_3 - CT26_1,
  CT26_3_vs_2 = CT26_3 - CT26_2,
  levels = design
)
print(contr)
fit <- contrasts.fit(fit0, contr)
fit <- eBayes(fit)
print(topTable(fit, coef = "CT26_3_vs_2"))
write.csv(as.data.frame(contr),paste0(inpF, ".pg.contrast_matrix.csv"))
# Write one full result file per contrast
for (cn in colnames(contr)) {
  tt <- topTable(fit,coef = cn,number = nrow(log2Int),sort.by = "P")
  write.csv(tt,paste0(inpF, ".pg.", cn, ".csv"))
}
