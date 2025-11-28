#..\R-4.5.0\bin\Rscript.exe mapID.r "F:\tk\PXD033510\txt\proteinGroups.txt" 1 178 203 uniprot entrezid #symbol ensembl
suppressPackageStartupMessages({
  if (!requireNamespace("org.Hs.eg.db", quietly=TRUE)) stop("org.Hs.eg.db required")
  if (!requireNamespace("AnnotationDbi", quietly=TRUE)) stop("AnnotationDbi required")
})
library(AnnotationDbi, quietly=TRUE)
library(org.Hs.eg.db, quietly=TRUE)
args <- commandArgs(trailingOnly=TRUE)
inpF1 <- if (length(args)>=1 && nzchar(args[1])) args[1] else "F:/tk/PXD033510/txt/proteinGroups.txt"
idC <- if (length(args)>=2 && nzchar(args[2])) strsplit(args[2],",")[[1]] else 1
startVC <- if (length(args)>=3 && nzchar(args[3])) args[3] else 178
endVC <- if (length(args)>=4 && nzchar(args[4])) args[4] else 203
fromID <- if (length(args)>=5 && nzchar(args[5])) args[5] else "uniprot"
toID <- if (length(args)>=6 && nzchar(args[6])) args[6] else "ensembl"
idC <- as.integer(idC); startVC <- as.integer(startVC); endVC <- as.integer(endVC)
setwd(dirname(inpF1))
df1 <- read.table(inpF1, sep="\t", header=TRUE, stringsAsFactors=FALSE, check.names=FALSE)
id_col_name <- names(df1)[idC]
idCX <- as.character(df1[[idC]]); idCX[is.na(idCX)] <- ""
lst <- strsplit(idCX, ";", fixed=TRUE)
clean_ids <- lapply(lst, function(x){ x <- trimws(x); x <- x[nzchar(x)]; if (length(x)==0) NA_character_ else x })
rep_counts <- sapply(clean_ids, function(x) if (all(is.na(x))) 1L else length(x))
df_vals <- df1[, startVC:endVC, drop=FALSE]
df_expanded <- df_vals[rep(seq_len(nrow(df_vals)), rep_counts), , drop=FALSE]
value_col_names <- colnames(df_vals)
for (col in value_col_names) if (col %in% colnames(df_expanded)) { vnum <- suppressWarnings(as.numeric(df_expanded[[col]])); if (any(!is.na(vnum))) { vnum[vnum==0] <- NA_real_; df_expanded[[col]] <- vnum } }
expanded_ids <- unlist(lapply(clean_ids, function(x) if (all(is.na(x))) NA_character_ else x))
df_expanded[[id_col_name]] <- expanded_ids
src_keys <- unique(na.omit(expanded_ids))
if (length(src_keys) > 0) {
  mapping <- AnnotationDbi::select(org.Hs.eg.db, keys=src_keys, keytype=toupper(fromID), columns=c(toupper(toID)))
  merge_by_src <- toupper(fromID)
  if (!(merge_by_src %in% colnames(mapping))) stop(sprintf("Mapping missing key column '%s'", merge_by_src))
  mapping[[merge_by_src]] <- as.character(mapping[[merge_by_src]])
  df_expanded[[id_col_name]] <- as.character(df_expanded[[id_col_name]])
  df_expanded <- merge(df_expanded, mapping, by.x=id_col_name, by.y=merge_by_src, all.x=TRUE)
} else df_expanded[[toupper(toID)]] <- NA_character_
param_tag <- paste0(".idC", idC, ".start", startVC, ".end", endVC, ".from_", fromID, ".", toID)
out_expanded <- paste0(tools::file_path_sans_ext(basename(inpF1)), param_tag, ".expanded.IDmap.tsv")
write.table(df_expanded, file=out_expanded, row.names=FALSE, col.names=TRUE, quote=FALSE, sep="\t")
cat("expanded:", normalizePath(out_expanded, winslash="\\", mustWork=FALSE), "\n")
ensembl_col <- toupper(toID)
if (ensembl_col %in% colnames(df_expanded)) {
  ensembl_vals <- as.character(df_expanded[[ensembl_col]])
  ensembl_vals <- ensembl_vals[!is.na(ensembl_vals) & nzchar(trimws(ensembl_vals))]
  if (length(ensembl_vals) > 0) {
  # .ids file writing disabled by request
    df_mapped <- df_expanded[!is.na(df_expanded[[ensembl_col]]) & nzchar(trimws(as.character(df_expanded[[ensembl_col]]))), , drop=FALSE]
    if (nrow(df_mapped) > 0) {
      cols_to_write <- c(ensembl_col, intersect(value_col_names, colnames(df_mapped)))
      out_vals <- paste0(tools::file_path_sans_ext(basename(inpF1)), param_tag, ".values.tsv")
      write.table(df_mapped[, cols_to_write, drop=FALSE], file=out_vals, row.names=FALSE, col.names=TRUE, quote=FALSE, sep="\t")
      cat("values:", normalizePath(out_vals, winslash="\\", mustWork=FALSE), "\n")
      value_cols <- intersect(value_col_names, colnames(df_mapped))
      if (length(value_cols) > 0) {
        groups <- split(seq_len(nrow(df_mapped)), df_mapped[[ensembl_col]])
        agg_list <- lapply(groups, function(idxs) {
          sub <- df_mapped[idxs, value_cols, drop=FALSE]
          sapply(seq_along(sub), function(j) { v <- suppressWarnings(as.numeric(sub[[j]])); if (all(is.na(v))) return(NA_real_); v[which.max(abs(v))] })
        })
        if (length(agg_list) > 0) {
          aggMat <- do.call(rbind, agg_list)
          colnames(aggMat) <- value_cols; rownames(aggMat) <- names(agg_list); storage.mode(aggMat) <- "double"
          agg_df <- as.data.frame(aggMat, stringsAsFactors=FALSE)
          agg_out <- cbind(rownames(agg_df), agg_df)
          colnames(agg_out)[1] <- ensembl_col
          out_agg <- paste0(tools::file_path_sans_ext(basename(inpF1)), param_tag, ".aggregated.tsv")
          write.table(agg_out, file=out_agg, row.names=FALSE, col.names=TRUE, quote=FALSE, sep="\t")
          cat("aggregated:", normalizePath(out_agg, winslash="\\", mustWork=FALSE), "\n")
        }
      }
    }
  }
}
total_expanded <- nrow(df_expanded)
mapped_rows <- 0L; unique_ensembl_count <- 0L
if (ensembl_col %in% colnames(df_expanded)) {
  mapped_idx <- which(!is.na(df_expanded[[ensembl_col]]) & nzchar(trimws(as.character(df_expanded[[ensembl_col]]))))
  mapped_rows <- length(mapped_idx)
  if (mapped_rows>0) unique_ensembl_count <- length(unique(as.character(df_expanded[[ensembl_col]][mapped_idx])))
}
unmapped_rows <- total_expanded - mapped_rows
cat(sprintf("Summary: total_expanded=%d, mapped_rows=%d, unmapped_rows=%d, unique_%s=%d\n", total_expanded, mapped_rows, unmapped_rows, tolower(ensembl_col), unique_ensembl_count))
