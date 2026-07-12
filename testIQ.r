#install.packages("iq")
suppressPackageStartupMessages({
  library(data.table)
  library(iq)
  library(ggplot2)
})

############################################################
# Input files
############################################################
#wget https://ftp.pride.ebi.ac.uk/pride/data/archive/2014/09/PXD000279/dynamicrangebenchmark.zip
peptide_file <- "peptides.txt"
protein_file <- "proteinGroups.txt"

############################################################
# Read peptides.txt
############################################################

pep <- fread(
  peptide_file,
  sep="\t",
  quote="",
  na.strings=c("", "NA")
)

############################################################
# Remove contaminants / reverse
############################################################

pep <- pep[
  (is.na(Reverse) | Reverse != "+") &
    (is.na("Potential contaminant") | "Potential contaminant" != "+")
]

############################################################
# Intensity columns
############################################################

intensity_cols <- grep("^Intensity ", names(pep), value=TRUE)

############################################################
# Long format
############################################################

pep_long <- melt(
  pep,
  id.vars=c(
    "Sequence",
    "Leading razor protein"
  ),
  measure.vars=intensity_cols,
  variable.name="sample",
  value.name="intensity"
)

pep_long[, sample := sub("^Intensity ", "", sample)]

pep_long <- pep_long[
  !is.na(intensity) &
    intensity > 0
]

############################################################
# iQ expects log2 intensities
############################################################

pep_long[, intensity := log2(intensity)]

############################################################
# Rename columns for iq
############################################################

setnames(
  pep_long,
  c(
    "Leading razor protein",
    "Sequence"
  ),
  c(
    "protein",
    "peptide"
  )
)

############################################################
# Run iQ (fast_MaxLFQ algorithm)
############################################################

# iq's fast_MaxLFQ expects a specific list of 4 vectors of equal length
norm_data <- list(
  protein_list = pep_long$protein,
  sample_list  = pep_long$sample,
  id           = pep_long$peptide,
  quant        = pep_long$intensity
)

# Run the C++ optimized MaxLFQ implementation
protein_table <- fast_MaxLFQ(norm_data)

# Extract estimates (log2 values) and convert to data.table
iq_lfq <- as.data.table(
  protein_table$estimate,
  keep.rownames="Leading razor protein"
)

boxplot(
  iq_lfq[, -1, with=FALSE],
  las=2,
  main="iQ log2 LFQ intensities"
)

write.csv(
  as.data.frame(iq_lfq),
  paste0(peptide_file,"iQ_log2_LFQ.csv")
)
############################################################
# Read proteinGroups.txt
############################################################

pg <- fread(
  protein_file,
  sep="\t",
  quote="",
  na.strings=c("", "NA")
)

pg <- pg[
  (is.na(Reverse) | Reverse != "+") &
    (is.na("Potential contaminant") | "Potential contaminant" != "+") &
    (is.na("Only identified by site") | "Only identified by site" != "+")
]

############################################################
# Expand Protein IDs
############################################################

lfq_cols <- grep("^LFQ intensity ", names(pg), value=TRUE)

pg_long <- pg[
  ,
  c("Protein IDs", lfq_cols),
  with=FALSE
]

pg_long[
  ,
  ProteinID_list := strsplit("Protein IDs", ";")
]

pg_long[, ProteinID_list := strsplit(`Protein IDs`, ";")]
pg_long <- pg_long[, .(ProteinID = trimws(unlist(ProteinID_list))), by=c("Protein IDs", lfq_cols)]


setnames(
  pg_long,
  old=lfq_cols,
  new=sub("^LFQ intensity ", "", lfq_cols)
)

############################################################
# Merge
############################################################

setnames(
  iq_lfq,
  "Leading razor protein",
  "ProteinID"
)

comparison <- merge(
  iq_lfq,
  pg_long,
  by="ProteinID"
)

############################################################
# Output directories
############################################################

dir.create("comparison_plots", showWarnings=FALSE)
dir.create("comparison_tables", showWarnings=FALSE)

############################################################
# Compare each sample
############################################################

samples <- setdiff(
  intersect(names(iq_lfq), names(pg_long)), 
  "ProteinID"
)

metrics <- list()

for(s in samples){
  
  iq <- comparison[[paste0(s, ".x")]]
  mq_raw <- comparison[[paste0(s, ".y")]]
  
  keep <- !is.na(iq) &
    !is.na(mq_raw) &
    mq_raw > 0
  
  iq <- iq[keep]
  mq_raw <- mq_raw[keep]
  
  mq <- log2(mq_raw)
  
  diff <- iq - mq
  
  metrics[[s]] <- data.table(
    Sample=s,
    N=length(iq),
    Pearson=cor(iq,mq),
    Spearman=cor(iq,mq,method="spearman"),
    MAE=mean(abs(diff)),
    RMSE=sqrt(mean(diff^2)),
    Bias=mean(diff),
    MedianDiff=median(diff)
  )
  
  protein_diff <- data.table(
    Protein=comparison$ProteinID[keep],
    IQ_Log2=iq,
    MQ_Log2=mq,
    Difference=diff,
    MQ_Raw=mq_raw
  )
  
  fwrite(
    protein_diff,
    file=file.path(
      "comparison_tables",
      paste0(s,"_differences.tsv")
    ),
    sep="\t"
  )
  
  p <- ggplot(
    protein_diff,
    aes(MQ_Log2, IQ_Log2)
  ) +
    geom_point(alpha=0.35, size=0.7) +
    geom_abline(slope=1, intercept=0, colour="red") +
    geom_smooth(method="lm", se=FALSE, colour="blue") +
    theme_bw() +
    labs(
      x="MaxQuant log2 LFQ",
      y="iQ log2 LFQ",
      title=s
    )
  
  ggsave(
    file.path("comparison_plots", paste0(s,"_scatter.pdf")),
    p,
    width=6,
    height=6
  )
  
  p <- ggplot(
    protein_diff,
    aes(Difference)
  ) +
    geom_histogram(bins=80) +
    geom_vline(xintercept=0, colour="red") +
    theme_bw() +
    labs(
      x="iQ - MaxQuant (log2)",
      title=s
    )
  
  ggsave(
    file.path("comparison_plots", paste0(s,"_difference_histogram.pdf")),
    p,
    width=6,
    height=4
  )
  
  density_df <- rbind(
    data.table(Value=iq, Method="iQ"),
    data.table(Value=mq, Method="MaxQuant")
  )
  
  p <- ggplot(
    density_df,
    aes(Value, colour=Method)
  ) +
    geom_density() +
    theme_bw() +
    labs(
      x="log2 LFQ",
      title=s
    )
  
  ggsave(
    file.path("comparison_plots", paste0(s,"_density.pdf")),
    p,
    width=6,
    height=4
  )
}

metrics <- rbindlist(metrics)

fwrite(
  metrics,
  "comparison_tables/summary_metrics.tsv",
  sep="\t"
)

print(metrics)
