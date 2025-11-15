 #..\R-4.5.0\bin\Rscript.exe mapKEGGpathview.r "F:\tk\MSTK\combined\txt\proteinGroups.txt" 1 20 30 uniprot ensembl
suppressPackageStartupMessages({
  if (!requireNamespace("org.Hs.eg.db", quietly = TRUE)) stop("package 'org.Hs.eg.db' required")
  if (!requireNamespace("AnnotationDbi", quietly = TRUE)) stop("package 'AnnotationDbi' required")
})
library("AnnotationDbi", quietly = TRUE)
library("org.Hs.eg.db", quietly = TRUE)
args <- commandArgs(trailingOnly = TRUE)
inpF1 <- if (length(args) >= 1 && nzchar(args[1])) args[1] else "F:/tk/MSTK/combined/txt/proteinGroups.txt"
idC <- if (length(args) >= 2 && nzchar(args[2])) strsplit(args[2], ",")[[1]] else 1
startVC <- if (length(args) >= 3 && nzchar(args[3])) args[3] else 155
endVC <- if (length(args) >= 4 && nzchar(args[4])) args[4] else 173
fromID <- if (length(args) >= 5 && nzchar(args[5])) args[5] else "uniprot"
toID <- if (length(args) >= 5 && nzchar(args[6])) args[6] else "ensembl"
idC <- as.integer(idC)
startVC <- as.integer(startVC)
endVC <- as.integer(endVC)
print(c(inpF1, idC, startVC, endVC, fromID, toID))
setwd(dirname(inpF1))
# read tables
df1 <- read.table(inpF1,sep="\t",header=TRUE,stringsAsFactors=FALSE,check.names=FALSE)
print(dim(df1))
#grep("LFQ",colnames(df1))
vals=seq(from=startVC,to=endVC)
mat <- as.matrix(df1[, vals, drop = FALSE])
rownames(mat) <- as.character(df1[[idC]])
storage.mode(mat) <- "double"
mat[mat == 0] <- NA
rN <- paste(sapply(strsplit(rownames(mat), ";", fixed = TRUE), "[", idPos))
rNs <- strsplit(rN, "|", fixed = TRUE)
allN <- unlist(rNs)
keep <- !is.na(allN) & nzchar(trimws(allN))
allN <- trimws(allN[keep])
mapRow <- rep(seq_along(rNs), lengths(rNs))[keep]
matRep <- mat[mapRow, , drop = FALSE]
rownames(matRep) <- allN
allNE<-AnnotationDbi::select(org.Hs.eg.db, keys = allN, keytype = toupper(fromID), columns = c(toupper(toID)))
matRepID<-merge(matRep, allNE, by.x=0, by.y=toupper(toID), all=TRUE)
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
df<-df1[,startVC:endVC]
row.names(df)<-df1[,idC]
summary(df)
idCX <- as.character(df1[,idC])
idCX[is.na(idCX)] <- ""
lst <- strsplit(idCX, ";", fixed = TRUE)
lens <- sapply(lst, function(x) sum(nzchar(trimws(x))))
lens2 <- ifelse(lens == 0, 1, lens)
df_expanded <- df[rep(seq_len(nrow(df)), lens2), , drop = FALSE]
vals <- unlist(lapply(lst, function(x) { x <- trimws(x); x <- x[nzchar(x)]; if (length(x) == 0) NA_character_ else x }))
df_expanded$idC <- vals
df_expanded
