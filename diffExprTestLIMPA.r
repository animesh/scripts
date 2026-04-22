# "c:\Program Files\r\R-4.5.2\bin\Rscript.exe" diffExprTestLIMPA.r
#setup####
#install.packages(c("svglite","ggplot2","BiocManager"),repos="http://cran.us.r-project.org",lib=.libPaths())
#BiocManager::install(c("limpa","pheatmap"))#,repos="http://cran.us.r-project.org",lib=.libPaths())
library(limpa) #https://bioconductor.org/packages/release/bioc/vignettes/limpa/inst/doc/limpa.html
set.seed(1)
#label####
labelF <- "L:/promec/TIMSTOF/LARS/2024/240605_Veronica/saga/txt/Groups.txt"   # built from exported column names
annoData<-read.table(labelF,header=T,sep="\t",row.names=1)#, colClasses=c(rep("factor",3)))
print(annoData)
#data####
inpF<-"L:/promec/TIMSTOF/LARS/2024/240605_Veronica/saga/txt/peptides.txt"
y.peptide <- readMaxQuant(inpF)
#y.peptide$E <- makePeptideExperimentFromMaxQuant(data, "Sequence", "Gene.names", "Leading.razor.protein")
#y.peptide[["genes"]] <- y.peptide$E@rowData$genes
summary(y.peptide[["genes"]])
summary(y.peptide[["E"]])
dpcFit    <- dpc(y.peptide)
#plot####
outP=paste(inpF,"TestLIMPA","pdf",sep = ".")
pdf(outP)
plotDPC(dpcFit)
y.proteinGroup <- dpcQuant(y.peptide, "Leading razor protein", dpc = dpcFit)
log2Int<-y.proteinGroup[["E"]]
print(dim(log2Int))
write.csv(log2Int,paste0(inpF,"pg.log2Int.csv"))
svgPHC<-pheatmap::pheatmap(log2Int)
log2IntimpCorr<-cor(log2Int,use="pairwise.complete.obs",method="pearson")
svgPHC<-pheatmap::pheatmap(log2IntimpCorr)
ggplot2::ggsave(paste0(inpF,"log2Intcluster.svg"), svgPHC)
#des####
annoData <- annoData[colnames(y.peptide$E), , drop=FALSE]
stopifnot(identical(colnames(y.proteinGroup$E), colnames(y.peptide$E)))
stopifnot(identical(rownames(annoData), colnames(y.peptide$E)))
annoData$Cell <- factor(annoData$Cell,levels=c("CT26","KPC"))
annoData$Experiment <- factor(annoData$Rep,levels=c(1,2,3),labels=c("Exp1","Exp2","Exp3"))
annoData$Group <- factor(annoData$Cell_Rep,levels=c("CT26_1","CT26_2","CT26_3","KPC_1","KPC_2","KPC_3"))
levels(annoData$Group) <- make.names(levels(annoData$Group))
design <- model.matrix(~0 + Group,data = annoData)
colnames(design) <- levels(annoData$Group)
head(design)
Group.color <- annoData$Group
print(length(levels(Group.color)))
levels(Group.color) <- c("blue","orange","darkgreen","cyan","magenta","pink")
plotMDSUsingSEs(y.proteinGroup,pch = 16,col = as.character(Group.color),main = "MDS by Cell_Rep Group",cex = 1,gene.selection = "common")
#test####
fit0 <- dpcDE(y.proteinGroup,design,plot = TRUE)
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
fit <- contrasts.fit(fit0,contr)
fit <- eBayes(fit)
print(contr)
print(topTable(fit,coef = "CT26_3_vs_2"))
write.csv(as.data.frame(contr),paste0(inpF,"pg.contrast_matrix_main.csv"))
for(cn in colnames(contr)){
  tt<-topTable(fit,coef = cn,number = dim(log2Int)[1],sort.by = "P")
  write.csv(tt,paste0(inpF,"pg.",cn,".csv"))
}
#interaction####
contrInt <- makeContrasts(
  Interaction_Exp2_vs_1 =
    (KPC_2 - KPC_1) - (CT26_2 - CT26_1),
  Interaction_Exp3_vs_1 =
    (KPC_3 - KPC_1) - (CT26_3 - CT26_1),
  Interaction_Exp3_vs_2 =
    (KPC_3 - KPC_2) - (CT26_3 - CT26_2),
  levels = design
)
fitInt <- contrasts.fit(fit0,contrInt)
fitInt <- eBayes(fitInt)
print(contrInt)
write.csv(as.data.frame(contrInt),paste0(inpF,"pg.contrast_matrix_interaction.csv"))
for(cn in colnames(contrInt)){
  tt<-topTable(fitInt,coef = cn,number = dim(log2Int)[1],sort.by = "P")
  write.csv(tt,paste0(inpF,"pg.",cn,".csv"))
}
