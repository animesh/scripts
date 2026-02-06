# "c:\Program Files\r\R-4.5.1\bin\Rscript.exe" diffExprTestLIMPA.r
#setup####
#install.packages(c("readxl","writexl","svglite","ggplot2","BiocManager"),repos="http://cran.us.r-project.org",lib=.libPaths())
#BiocManager::install(c("limpa","pheatmap","vsn"))#,repos="http://cran.us.r-project.org",lib=.libPaths())
library(limpa) #https://bioconductor.org/packages/release/bioc/vignettes/limpa/inst/doc/limpa.html
set.seed(42)
#data https://bioshare.bioinformatics.ucdavis.edu/bioshare/view/sc_2023_2025/#
#wget -r --level=10 -nH -nc --cut-dirs=3 --no-parent --reject "wget_index.html" --no-check-certificate --header "Cookie: sessionid=None;" https://bioshare.bioinformatics.ucdavis.edu/bioshare/wget/6a4r34mb3d8ytdh/wget_index.html
#label####
labelF <- "L:/promec/TIMSTOF/LARS/2025/250902_Alessandro/DIANNv2p2/Groups.txt"   # built from exported column names
preLab<-"250902_Alessandro_"
annoData<-read.table(labelF,header=T,sep="\t",row.names=1)#, colClasses=c(rep("factor",3)))
rownames(annoData)<-paste0(preLab,rownames(annoData))
print(annoData)
#data####
inpF<-"L:/promec/TIMSTOF/LARS/2025/250902_Alessandro/DIANNv2p2/report.parquet"
y.peptide <- readDIANN(inpF)
y.peptide <- filterNonProteotypicPeptides(y.peptide)
dpcFit    <- dpc(y.peptide)
#plot####
outP=paste(inpF,"TestLIMPA","pdf",sep = ".")
pdf(outP)
plotDPC(dpcFit)
y.proteinGroup <- dpcQuant(y.peptide, "Protein.Group", dpc = dpcFit)
log2Int<-y.proteinGroup[["E"]]
print(dim(log2Int))
write.csv(log2Int,paste0(inpF,"pg.log2Int.csv"))
boxplot(log2Int,las=2)
svgPHC<-pheatmap::pheatmap(log2Int)
log2IntimpCorr<-cor(log2Int,use="pairwise.complete.obs",method="pearson")
svgPHC<-pheatmap::pheatmap(log2IntimpCorr)
ggplot2::ggsave(paste0(inpF,"log2Intcluster.svg"), svgPHC)
write.csv(log2Int,paste0(inpF,selection,"log2Int.csv"))
#scale####
countTableDAuniGORNAddsMed<-apply(log2Int,1,function(x) median(x,na.rm=T))
hist(countTableDAuniGORNAddsMed)
countTableDAuniGORNAddsSD<-apply(log2Int,1,function(x) sd(x,na.rm=T))
hist(countTableDAuniGORNAddsSD)
countTableDAuniGORNAdds<-(log2Int-countTableDAuniGORNAddsMed)#/countTableDAuniGORNAddsSD
hist(countTableDAuniGORNAdds)
boxplot(countTableDAuniGORNAdds,las=2)
#des####
annoData <- annoData[colnames(y.peptide$E), ]
stopifnot(identical(colnames(y.proteinGroup$E), colnames(y.peptide$E)))
stopifnot(identical(rownames(annoData), colnames(y.peptide$E)))
annoData$Group <- factor(annoData$Group)#, levels = c("GR", "PR"))
levels(annoData$Group) <- make.names(levels(annoData$Group))
#annoData$Group <- factor(targets$year)
design <- model.matrix(~ Group , data = annoData)
head(design)
Group.color <- annoData$Group
levels(Group.color) <- c("blue","orange")
plotMDSUsingSEs(y.proteinGroup, pch = 16, col = as.character(Group.color),main = "MDS by Sample Prep Group", cex = 1, gene.selection = "common")
#test####
fit <- dpcDE(y.proteinGroup, design, plot = TRUE)
fit <- eBayes(fit)
topTable(fit)
write.csv(topTable(fit,number =dim(log2Int)[1]), paste0(inpF,"pg.topTable.csv"))
#dat <- readDIANN(report_file)#,format    = "parquet")#,q.columns = c("Q.Value","Lib.Q.Value","Lib.PG.Q.Value"),q.cutoffs = 0.01)
#dim(dat$genes)
#dat <- filterNonProteotypicPeptides(dat)
#dat <- filterCompoundProteins(dat)
#dat <- filterSingletonPeptides(dat, min.n.peptides = 2)  # optional
#write.csv2(colnames(dat$E), "colnames.txt")
#dpcfit    <- dpc(dat)
#plotDPC(dpcfit)
#y.protein <- dpcQuant(dat, "Protein.Group", dpc = dpcfit)
#boxplot(y.protein[["E"]],las=2)
#svgPHC<-pheatmap::pheatmap(y.protein[["E"]])
#dpcest <- dpc(y.peptide)
#y.protein <- dpcQuant(y.peptide, protein.id, dpc=dpcest)
#fit <- dpcDE(y.protein, design)
#fit <- eBayes(fit)
#topTable(fit)
