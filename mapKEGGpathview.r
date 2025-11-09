 #..\R-4.5.0\bin\Rscript.exe mapKEGGpathview.r "L:/promec/TIMSTOF/LARS/2023/230217_Caroline/mRNA/CPM1.txt.Omego_T3_vs_Control_T3_mRNA_diff_expr_CPM1.Omego_T6_vs_Control_T6_mRNA_diff_expr_CPM1.Omego_T12_vs_Control_T12_mRNA_diff_expr_CPM1.logFC.genesselect.IDmap.absmax.csv" "hsa05135,hsa04140" 1 1 "L:/promec/TIMSTOF/LARS/2023/230217_Caroline/combined/txt/proteinGroups.txtLFQ.intensity.110Omego1Cntr1h00.050.5InfBiotTestBH.xlsx.110Omego3Cntr3h00.110Omego6Cntr6h00.110Omego12Cntr12h00.Log2MedianChange.RowGeneUniProtScorePepsselect.IDmap.absmax.csv" "L:/promec/TIMSTOF/LARS/2023/230217_Caroline/mapKEGGpathview.out"
suppressPackageStartupMessages({
  if (!requireNamespace("pathview", quietly = TRUE)) stop("package 'pathview' required")
  if (!requireNamespace("readxl", quietly = TRUE)) stop("package 'readxl' required")
  if (!requireNamespace("scales", quietly = TRUE)) stop("package 'readxl' required")
  if (!requireNamespace("org.Hs.eg.db", quietly = TRUE)) stop("package 'readxl' required")
  if (!requireNamespace("AnnotationDbi", quietly = TRUE)) stop("package 'readxl' required")
})
library("pathview", quietly = TRUE)
library("org.Hs.eg.db", quietly = TRUE)
args <- commandArgs(trailingOnly = TRUE)
inpF1 <- if (length(args) >= 1 && nzchar(args[1])) args[1] else "L:/promec/TIMSTOF/LARS/2023/230217_Caroline/mRNA/CPM1.txt.Omego_T3_vs_Control_T3_mRNA_diff_expr_CPM1.Omego_T6_vs_Control_T6_mRNA_diff_expr_CPM1.Omego_T12_vs_Control_T12_mRNA_diff_expr_CPM1.logFC.genesselect.IDmap.absmax.csv"
pathway <- if (length(args) >= 2 && nzchar(args[2])) strsplit(args[2], ",")[[1]] else c("hsa05135","hsa04140")
idPos1 <- if (length(args) >= 3 && nzchar(args[3])) args[3] else 1
idPos2 <- if (length(args) >= 4 && nzchar(args[4])) args[4] else 1
inpF2 <- if (length(args) >= 5 && nzchar(args[5])) args[5] else "L:/promec/TIMSTOF/LARS/2023/230217_Caroline/combined/txt/proteinGroups.txtLFQ.intensity.110Omego1Cntr1h00.050.5InfBiotTestBH.xlsx.110Omego3Cntr3h00.110Omego6Cntr6h00.110Omego12Cntr12h00.Log2MedianChange.RowGeneUniProtScorePepsselect.IDmap.absmax.csv"
outF <- if (length(args) >= 5 && nzchar(args[6])) args[6] else "L:/promec/TIMSTOF/LARS/2023/230217_Caroline/mapKEGGpathview.out"
setwd(dirname(outF))
# read tables
df1 <- read.csv(inpF1)
df2 <- read.csv(inpF2)
idPos1 <- as.integer(idPos1)
idPos2 <- as.integer(idPos2)
df<-merge(df1, df2, by.x=idPos1, by.y=idPos2, all=TRUE)
hda <- df[,grep("og", colnames(df), fixed=TRUE)]
rownames(hda) <- df[,1]
print(summary(hda))
write.csv(hda,paste0(outF,".csv"), row.names=TRUE)
#hda[is.infinite(hda)] <- NA
hda[hda < 0] <- 1*-1
hda[hda > 0] <- 1
#hda[is.na(hda)] <- 0
#hda<-unique(hda)
#hda<-mat
#hda <- scales::rescale(as.matrix(hda), c(-1*5, 5))
#hist(hda, breaks=100, main="Rescaled logFC values", xlab="Rescaled logFC")
#pathview(hda, pathway.id = "04140", species = "hsa", gene.idtype = "ENSEMBL")
#pathview(hda, pathway.id = "04140", species = "hsa", gene.idtype = "ENTREZ")
message("Output :", outF)
message("Processing pathway: ", paste(pathway, collapse = ", "))
for (p in pathway) {
  message("Processing ", p)
  out_sfx <- paste(outF,"IDpos",idPos1,idPos2,p,sep = ".")
  #message("Input values for ENTREZ 5291: ", paste(hda["5291",], collapse=", "))
  pv <- try(pathview(gene.data = hda, pathway.id = p, species = "hsa", gene.idtype = "ENTREZ",low = list(gene = "cyan"), mid = list(gene = "white"), high = list(gene = "orange"),both.dirs = list(gene = TRUE), na.col = "grey",limit = list(gene = max(abs(hda), na.rm = TRUE))), silent = TRUE)
  #pv <- try(pathview(gene.data = hda, pathway.id = p, species = "hsa", gene.idtype = "ENSEMBL",low = list(gene = "blue"), mid = list(gene = "white"), high = list(gene = "orange"),both.dirs = list(gene = TRUE), na.col = "grey",limit = list(gene = max(abs(hda), na.rm = TRUE))), silent = TRUE)
  #if (!is.null(pv$plot.data.gene) && "5291" %in% (pv$plot.data.gene$kegg.names)) {message("Pathview output for 5291: ", paste(pv$plot.data.gene[pv$plot.data.gene$kegg.names=="5291",], collapse=", "))}
  if (inherits(pv, "try-error") || is.null(pv$plot.data.gene) || nrow(pv$plot.data.gene) == 0) {
    message("No mapping from UNIPROT for ", p, "; attempting ENTREZID fallback...")}
    # attempt UNIPROT -> ENTREZID mapping and aggregate
  if (inherits(pv, "try-error") || is.null(pv)) { message("pathview failed for ", p); next }
  if (!is.null(pv$plot.data.gene) && nrow(pv$plot.data.gene) > 0) {
    gdf <- as.data.frame(pv$plot.data.gene, stringsAsFactors = FALSE)
    gdf <- cbind(pathway = p, entry = rownames(pv$plot.data.gene), gdf)
    #gdf[] <- lapply(gdf, function(x) {if (is.list(x)) sapply(x, function(y) paste(y, collapse=";")) else x})
    gdf[] <- lapply(gdf, function(x) {if (is.list(x)) sapply(x, toString) else x})
    write.csv(gdf, paste0(out_sfx, "_gene.csv"),row.names = FALSE)
    message("Wrote: ",paste0(out_sfx, "_gene.csv"))
  }
  if (!is.null(pv$plot.data.cpd) && nrow(pv$plot.data.cpd) > 0) {
    cdf <- as.data.frame(pv$plot.data.cpd, stringsAsFactors = FALSE)
    cdf <- cbind(pathway = p, entry = rownames(pv$plot.data.cpd), cdf)
    write.csv(cdf, paste0(out_sfx, "_cpd.csv"), row.names = FALSE)
    message("Wrote: ", paste0(out_sfx, "_cpd.csv"))
  }
}

message("Done")
