#curl -O "proteinGroups.txt" "https://zenodo.org/records/14557756/files/proteinGroups.txt?download=1"  
#Rscript mapID.r "proteinGroups.txt" 1 76 81 uniprot ensembl max org.Hs.eg.db
suppressPackageStartupMessages({
  if (!requireNamespace("AnnotationDbi", quietly=TRUE)) stop("AnnotationDbi required")
})
library(AnnotationDbi, quietly=TRUE)
args <- commandArgs(trailingOnly=TRUE)
if (length(args) < 1 || !nzchar(args[1])) {
  stop("Usage: Rscript mapID.r <input_file> [id_col] [startVC] [endVC] [fromID] [toID]\nPlease provide the input file path as the first argument.")
}
inpF1 <- args[1]
setwd(dirname(inpF1))
df1 <- read.table(inpF1, sep="\t", header=TRUE, stringsAsFactors=FALSE, check.names=FALSE)
# id column (default 1)
idC <- if (length(args)>=2 && nzchar(args[2])) strsplit(args[2],",")[[1]] else 1
idC <- as.integer(idC)
# defaults for value columns: start immediately after id column, end at last column
startVC <- if (length(args)>=3 && nzchar(args[3])) as.integer(args[3]) else (idC[1] + 1L)
endVC <- if (length(args)>=4 && nzchar(args[4])) as.integer(args[4]) else ncol(df1)
fromID <- if (length(args)>=5 && nzchar(args[5])) args[5] else "uniprot"
toID <- if (length(args)>=6 && nzchar(args[6])) args[6] else "ensembl"
# aggregation function for selecting representative value (max of abs by default)
agg_fun <- if (length(args) >= 7 && nzchar(args[7])) tolower(args[7]) else "max"
if (!(agg_fun %in% c("max", "min", "mean", "median"))) {
  stop("Aggregation function must be one of: max, min, mean, median")
}
# annotation DB package (default human org.Hs.eg.db); can be overridden as 8th arg
anno_db_pkg <- if (length(args) >= 8 && nzchar(args[8])) args[8] else "org.Hs.eg.db"
if (!requireNamespace(anno_db_pkg, quietly=TRUE)) stop(sprintf("%s required", anno_db_pkg))
# get the AnnotationDb object from the package namespace
anno_db <- get(anno_db_pkg, envir=asNamespace(anno_db_pkg))
cat(sprintf("Using annotation DB: %s\n", anno_db_pkg))

# report chosen arguments
cat(sprintf("Arguments: input=%s, idC=%s, startVC=%d, endVC=%d, fromID=%s, toID=%s, agg_fun=%s\n",
            normalizePath(inpF1, winslash="\\", mustWork=FALSE), paste(idC, collapse=","), startVC, endVC, fromID, toID, agg_fun))
id_col_name <- names(df1)[idC]
idCX <- as.character(df1[[idC]]); idCX[is.na(idCX)] <- ""
lst <- strsplit(idCX, ";", fixed=TRUE)
clean_ids <- lapply(lst, function(x){ x <- trimws(x); x <- x[nzchar(x)]; if (length(x)==0) NA_character_ else x })
rep_counts <- sapply(clean_ids, function(x) if (all(is.na(x))) 1L else length(x))
df_vals <- df1[, startVC:endVC, drop=FALSE]
# replace literal 0s with NA in the original value matrix before expansion
# and count how many conversions occur per column
conversions_by_col <- integer(length = ncol(df_vals))
names(conversions_by_col) <- colnames(df_vals)
total_converted <- 0L
for (i in seq_along(colnames(df_vals))) {
  col <- colnames(df_vals)[i]
  vnum_orig <- suppressWarnings(as.numeric(df_vals[[col]]))
  if (any(!is.na(vnum_orig))) {
    num_converted <- sum(!is.na(vnum_orig) & vnum_orig == 0)
    if (num_converted > 0) {
      vnum <- vnum_orig
      vnum[vnum == 0] <- NA_real_
      df_vals[[col]] <- vnum
    }
    conversions_by_col[i] <- num_converted
    total_converted <- total_converted + num_converted
  } else {
    conversions_by_col[i] <- 0L
  }
}
# report conversion counts
total_cells <- nrow(df_vals) * ncol(df_vals)
pct <- if (total_cells > 0) round(100 * total_converted / total_cells, 2) else 0
cat(sprintf("Converted %d zero values to NA in df_vals (out of %d total cells; %0.2f%%)\n", total_converted, total_cells, pct))
if (total_converted > 0) {
  for (i in seq_along(conversions_by_col)) {
    if (conversions_by_col[i] > 0) cat(sprintf("  %s: %d\n", names(conversions_by_col)[i], conversions_by_col[i]))
  }
}
cat(sprintf("Input rows (df1): %d\n", nrow(df1)))
df_expanded <- df_vals[rep(seq_len(nrow(df_vals)), rep_counts), , drop=FALSE]
value_col_names <- colnames(df_vals)
expanded_ids <- unlist(lapply(clean_ids, function(x) if (all(is.na(x))) NA_character_ else x))
df_expanded[[id_col_name]] <- expanded_ids
src_keys <- unique(na.omit(expanded_ids))
if (length(src_keys) > 0) {
  mapping <- AnnotationDbi::select(anno_db, keys=src_keys, keytype=toupper(fromID), columns=c(toupper(toID)))
  merge_by_src <- toupper(fromID)
  if (!(merge_by_src %in% colnames(mapping))) stop(sprintf("Mapping missing key column '%s'", merge_by_src))
  mapping[[merge_by_src]] <- as.character(mapping[[merge_by_src]])
  df_expanded[[id_col_name]] <- as.character(df_expanded[[id_col_name]])
  df_expanded <- merge(df_expanded, mapping, by.x=id_col_name, by.y=merge_by_src, all.x=TRUE)
} else df_expanded[[toupper(toID)]] <- NA_character_
# parameter tag for output filenames (exclude annotation DB pkg per request)
param_tag <- paste0(".idC", paste(idC, collapse="-"), ".start", startVC, ".end", endVC, ".from_", fromID, ".", toID, ".agg_", agg_fun)
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
          sapply(seq_along(sub), function(j) {
            v <- suppressWarnings(as.numeric(sub[[j]]))
            if (all(is.na(v))) return(NA_real_)
            if (agg_fun == "max") {
              v[which.max(abs(v))]
            } else if (agg_fun == "min") {
              v[which.min(abs(v))]
            } else if (agg_fun == "mean") {
              mean(v, na.rm=TRUE)
            } else if (agg_fun == "median") {
              median(v, na.rm=TRUE)
            } else {
              NA_real_
            }
          })
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
