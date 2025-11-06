 #..\R-4.5.0\bin\Rscript.exe mapKEGGpathview.r <input.xlsx> <pathway1,pathway2,...> <idPos> <scale>
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
inpF1 <- if (length(args) >= 1 && nzchar(args[1])) args[1] else "L:/promec/TIMSTOF/LARS/2023/230217_Caroline/mRNA/Omego_T1_vs_Control_T1_mRNA_diff_expr_CPM1.txt.Omego_T3_vs_Control_T3_mRNA_diff_expr_CPM1.Omego_T6_vs_Control_T6_mRNA_diff_expr_CPM1.Omego_T12_vs_Control_T12_mRNA_diff_expr_CPM1.logFC.genesselect.xlsx"
pathway <- if (length(args) >= 2 && nzchar(args[2])) strsplit(args[2], ",")[[1]] else c("hsa05135","hsa04140")
idPos <- if (length(args) >= 3 && nzchar(args[3])) args[3] else 1
scale <- if (length(args) >= 4 && nzchar(args[4])) args[4] else 1
# read table
df <- readxl::read_xlsx(inpF1)
# detect name column and numeric columns
ID <- which(sapply(df, function(x) any(grepl(";;", as.character(x)))))[1]
if (is.na(ID)) ID <- 1
vals <- which(sapply(df, function(x) suppressWarnings(any(!is.na(as.numeric(as.character(x)))))))
vals <- setdiff(vals, ID)
if (length(vals) == 0) stop("No numeric columns detected in input")
mat <- as.matrix(df[, vals, drop = FALSE])
rownames(mat) <- as.character(df[[ID]])
storage.mode(mat) <- "double"
mat[mat == 0] <- NA
rN <- paste(sapply(strsplit(rownames(mat), ";;", fixed = TRUE), "[", idPos))
rNs <- strsplit(rN, ";", fixed = TRUE)
allN <- unlist(rNs)
keep <- !is.na(allN) & nzchar(trimws(allN))
allN <- trimws(allN[keep])
mapRow <- rep(seq_along(rNs), lengths(rNs))[keep]
matRep <- mat[mapRow, , drop = FALSE]
rownames(matRep) <- allN
allNE<-AnnotationDbi::select(org.Hs.eg.db, keys = allN, keytype = 'ENSEMBL', columns = c('ENTREZID'))
#allNE[is.na(allNE$ENTREZID), 'ENTREZID'] <- allNE[is.na(allNE$ENTREZID), 'UNIPROT']
matRepID<-merge(matRep, allNE, by.x=0, by.y='ENSEMBL', all=TRUE)
write.csv(matRepID, file=paste0(tools::file_path_sans_ext(basename(inpF1)), ".IDmap.csv"), row.names=FALSE)
matRepID <- matRepID[!is.na(matRepID$ENTREZID), , drop = FALSE]
# combine rows with the same ENTREZID by taking the value with maximum absolute magnitude per column
entrezID <- as.character(matRepID$ENTREZID)
entrezIDs <- split(seq_len(nrow(matRepID)), entrezID)
aggMat <- do.call(rbind, lapply(entrezIDs, function(idxs) {
  sub <- matRepID[idxs, , drop = FALSE]
  apply(sub, 2, function(col) {
    v <- suppressWarnings(as.numeric(col))
    if (all(is.na(v))) return(NA_real_)
    v[which.max(abs(v))]
    #v[which.min(abs(v))]
  })
}))
storage.mode(aggMat) <- "double"
rownames(aggMat) <- names(entrezIDs)
hda <- aggMat[,grep("logFC", colnames(aggMat), fixed=TRUE)]
print(summary(hda))
write.csv(hda, file=paste0(tools::file_path_sans_ext(basename(inpF1)), ".IDmap.absmax.csv"), row.names=TRUE)
hda[is.infinite(hda)] <- NA
hda[hda < 0] <- 1*-1
hda[hda > 0] <- 1
#hda[is.na(hda)] <- 0
#hda<-unique(hda)
#hda<-mat
#hda <- scales::rescale(as.matrix(hda), c(-1*5, 5))
#hist(hda, breaks=100, main="Rescaled logFC values", xlab="Rescaled logFC")
#pathview(hda, pathway.id = "04140", species = "hsa", gene.idtype = "ENSEMBL")
#pathview(hda, pathway.id = "04140", species = "hsa", gene.idtype = "ENTREZ")
outDir <- dirname(normalizePath(inpF1))
preFix <- tools::file_path_sans_ext(basename(inpF1))
message("Input: ", inpF1)
message("Output dir: ", outDir)
message("Processing pathway: ", paste(pathway, collapse = ", "))
for (p in pathway) {
  message("Processing ", p)
  out_sfx <- paste("IDpos",idPos,"scale",scale, sep = ".")
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
    write.csv(gdf, paste0(gsub("[:\\/*?\"<>|]","_", p), "_", out_sfx, "_gene.csv"))
    message("Wrote: ",paste0(gsub("[:\\/*?\"<>|]","_", p), "_", out_sfx, "_gene.csv"))
  }
  if (!is.null(pv$plot.data.cpd) && nrow(pv$plot.data.cpd) > 0) {
    cdf <- as.data.frame(pv$plot.data.cpd, stringsAsFactors = FALSE)
    cdf <- cbind(pathway = p, entry = rownames(pv$plot.data.cpd), cdf)
    write.csv(cdf, paste0(gsub("[:\\/*?\"<>|]","_", p), "_", out_sfx, "_cpd.csv"), row.names = FALSE)
    message("Wrote: ", paste0(gsub("[:\\/*?\"<>|]","_", p), "_", out_sfx, "_cpd.csv"))
  }
}

message("Done")
