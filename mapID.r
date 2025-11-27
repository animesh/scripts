 #..\R-4.5.0\bin\Rscript.exe mapKEGGpathview.r "F:\tk\PXD033510\txt\proteinGroups.txt" 1 20 30 uniprot ensembl
suppressPackageStartupMessages({
  if (!requireNamespace("org.Hs.eg.db", quietly = TRUE)) stop("package 'org.Hs.eg.db' required")
  if (!requireNamespace("AnnotationDbi", quietly = TRUE)) stop("package 'AnnotationDbi' required")
})
library("AnnotationDbi", quietly = TRUE)
library("org.Hs.eg.db", quietly = TRUE)
args <- commandArgs(trailingOnly = TRUE)
inpF1 <- if (length(args) >= 1 && nzchar(args[1])) args[1] else "F:/tk/PXD033510/txt/proteinGroups.txt"
idC <- if (length(args) >= 2 && nzchar(args[2])) strsplit(args[2], ",")[[1]] else 1
startVC <- if (length(args) >= 3 && nzchar(args[3])) args[3] else 178
endVC <- if (length(args) >= 4 && nzchar(args[4])) args[4] else 203
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
#hist(log2(mat), breaks = 100)
## Expand rows by splitting the ID column on ';' and map to target ID (e.g. Ensembl)
# idC is the column index in df1 that contains the source IDs (e.g. UniProt)
id_col_name <- names(df1)[idC]
idCX <- as.character(df1[[idC]])
idCX[is.na(idCX)] <- ""
lst <- strsplit(idCX, ";", fixed = TRUE)
# trim and keep non-empty entries; if none, keep NA so we still replicate the row once
clean_ids <- lapply(lst, function(x) {
  x <- trimws(x)
  x <- x[nzchar(x)]
  if (length(x) == 0) NA_character_ else x
})
# replication counts per original row
rep_counts <- sapply(clean_ids, function(x) if (all(is.na(x))) 1L else length(x))

df_vals <- df1[, startVC:endVC, drop = FALSE]
df_expanded <- df_vals[rep(seq_len(nrow(df_vals)), rep_counts), , drop = FALSE]

# create a column with the individual source IDs (e.g. UniProt accessions)
expanded_ids <- unlist(lapply(clean_ids, function(x) if (all(is.na(x))) NA_character_ else x))
df_expanded[[id_col_name]] <- expanded_ids

# map unique non-NA source IDs to the target ID using AnnotationDbi
src_keys <- unique(na.omit(expanded_ids))
if (length(src_keys) > 0) {
  mapping <- AnnotationDbi::select(org.Hs.eg.db, keys = src_keys, keytype = toupper(fromID), columns = c(toupper(toID), "ENTREZID"))
  # mapping will have a column named toupper(fromID) and a column named toupper(toID)
  # merge mapping back into expanded dataframe by matching the source id
  merge_by_src <- toupper(fromID)
  if (!(merge_by_src %in% colnames(mapping))) {
    stop(sprintf("Mapping did not return expected key column '%s'", merge_by_src))
  }
  # ensure the key column is character for safe merging
  mapping[[merge_by_src]] <- as.character(mapping[[merge_by_src]])
  df_expanded[[id_col_name]] <- as.character(df_expanded[[id_col_name]])
  df_expanded <- merge(df_expanded, mapping, by.x = id_col_name, by.y = merge_by_src, all.x = TRUE)
} else {
  # no keys to map; create empty target column
  df_expanded[[toupper(toID)]] <- NA_character_
  df_expanded$ENTREZID <- NA_character_
}

out_csv <- paste0(tools::file_path_sans_ext(basename(inpF1)), ".expanded.IDmap.csv")
write.csv(df_expanded, file = out_csv, row.names = FALSE)
cat("Wrote expanded and mapped table to:", out_csv, "\n")

# Create a simple file with only the mapped Ensembl IDs (one per line),
# dropping rows without an Ensembl mapping. Write unique IDs only.
ensembl_col <- toupper(toID)
if (ensembl_col %in% colnames(df_expanded)) {
  ensembl_vals <- as.character(df_expanded[[ensembl_col]])
  ensembl_vals <- ensembl_vals[!is.na(ensembl_vals) & nzchar(trimws(ensembl_vals))]
  if (length(ensembl_vals) > 0) {
    ensembl_vals_unique <- unique(ensembl_vals)
    out_ids <- paste0(tools::file_path_sans_ext(basename(inpF1)), ".", tolower(ensembl_col), ".ids.txt")
    write.table(ensembl_vals_unique, file = out_ids, row.names = FALSE, col.names = FALSE, quote = FALSE, sep = "\t")
    cat("Wrote", length(ensembl_vals_unique), "unique", ensembl_col, "IDs to:", out_ids, "\n")

    # Also write a table with Ensembl ID in first column plus the original value columns
    # Identify the original value column names from the input slice (startVC:endVC)
    value_col_names <- colnames(df_vals)
    # Filter expanded dataframe to rows that have a mapped Ensembl ID
    df_mapped <- df_expanded[!is.na(df_expanded[[ensembl_col]]) & nzchar(trimws(as.character(df_expanded[[ensembl_col]]))), , drop = FALSE]
    if (nrow(df_mapped) > 0) {
      # select Ensembl first, then the value columns (if present)
      cols_to_write <- c(ensembl_col, intersect(value_col_names, colnames(df_mapped)))
      out_vals <- paste0(tools::file_path_sans_ext(basename(inpF1)), ".", tolower(ensembl_col), ".values.tsv")
      write.table(df_mapped[, cols_to_write, drop = FALSE], file = out_vals, row.names = FALSE, col.names = TRUE, quote = FALSE, sep = "\t")
      cat("Wrote", nrow(df_mapped), "rows with Ensembl IDs and values to:", out_vals, "\n")
    } else {
      cat("No rows with non-NA", ensembl_col, "found; no values file written.\n")
    }

    # Aggregate rows by Ensembl ID: for each value column take the value with maximum absolute magnitude
    value_cols <- intersect(value_col_names, colnames(df_mapped))
    if (length(value_cols) > 0) {
      groups <- split(seq_len(nrow(df_mapped)), df_mapped[[ensembl_col]])
      agg_list <- lapply(groups, function(idxs) {
        sub <- df_mapped[idxs, value_cols, drop = FALSE]
        sapply(seq_along(sub), function(j) {
          v <- suppressWarnings(as.numeric(sub[[j]]))
          if (all(is.na(v))) return(NA_real_)
          v[which.max(abs(v))]
        })
      })
      if (length(agg_list) > 0) {
        aggMat <- do.call(rbind, agg_list)
        rownames(aggMat) <- names(agg_list)
        agg_df <- as.data.frame(aggMat, stringsAsFactors = FALSE)
        # ensure Ensembl ID is a column
        agg_out <- cbind(ENSEMBL = rownames(agg_df), agg_df)
        out_agg <- paste0(tools::file_path_sans_ext(basename(inpF1)), ".", tolower(ensembl_col), ".aggregated.tsv")
        write.table(agg_out, file = out_agg, row.names = FALSE, col.names = TRUE, quote = FALSE, sep = "\t")
        cat("Wrote aggregated values by", ensembl_col, "to:", out_agg, "\n")
      }
    }
    # Create a log2-transformed version of the aggregated table
    if (exists("agg_out") && nrow(agg_out) > 0) {
      # copy and transform numeric columns (leave ENSEMBL as-is)
      log2_df <- agg_out
      if (ncol(log2_df) > 1) {
        for (j in 2:ncol(log2_df)) {
          # coerce to numeric, convert non-positive or non-finite to NA, then take log2
          vals_num <- suppressWarnings(as.numeric(log2_df[[j]]))
          vals_num[!is.finite(vals_num) | vals_num <= 0] <- NA_real_
          log2_vals <- suppressWarnings(log2(vals_num))
          log2_vals[!is.finite(log2_vals)] <- NA_real_
          log2_df[[j]] <- log2_vals
        }
      }
      out_log2 <- paste0(tools::file_path_sans_ext(basename(inpF1)), ".", tolower(ensembl_col), ".aggregated.log2.tsv")
      write.table(log2_df, file = out_log2, row.names = FALSE, col.names = TRUE, quote = FALSE, sep = "\t")
      cat("Wrote log2-transformed aggregated table to:", out_log2, "\n")
    }
  } else {
    cat("No non-NA", ensembl_col, "values found; no ID file written.\n")
  }
} else {
  cat("Column", ensembl_col, "not found in expanded table; cannot write ID-only file.\n")
}

# Summary counts: mapped / unmapped and unique Ensembl count
total_expanded <- nrow(df_expanded)
mapped_rows <- 0L
unique_ensembl_count <- 0L
if (ensembl_col %in% colnames(df_expanded)) {
  mapped_idx <- which(!is.na(df_expanded[[ensembl_col]]) & nzchar(trimws(as.character(df_expanded[[ensembl_col]]))))
  mapped_rows <- length(mapped_idx)
  if (mapped_rows > 0) {
    unique_ensembl_count <- length(unique(as.character(df_expanded[[ensembl_col]][mapped_idx])))
  }
}
unmapped_rows <- total_expanded - mapped_rows
summary_msg <- sprintf("Summary: total_expanded=%d, mapped_rows=%d, unmapped_rows=%d, unique_%s=%d", total_expanded, mapped_rows, unmapped_rows, tolower(ensembl_col), unique_ensembl_count)
cat(summary_msg, "\n")

# also write summary to a small log file
summary_file <- paste0(tools::file_path_sans_ext(basename(inpF1)), ".mapping_summary.txt")
writeLines(c(summary_msg), con = summary_file)
cat("Wrote mapping summary to:", summary_file, "\n")
