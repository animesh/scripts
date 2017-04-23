#source http://al2na.github.io/genomation/
#install.packages( c("data.table","plyr","reshape2","ggplot2","gridBase","devtools"))
#install packages ("Rtools") from http://cran.r-project.org/bin/windows/Rtools/ and run find_rtools()
#had to restart R after Rtools installation
library(devtools)
find_rtools()
#source("http://bioconductor.org/biocLite.R")
#biocLite(c("GenomicRanges","rtracklayer","impute","Rsamtools"))
#install_github("genomation", username = "al2na")
#library(Rsamtools, quietly = TRUE)

library(Rsamtools)
SL32542 <- scanBam('L:/Elite/gaute/Brede_052313_Raw_Fastq/SL32542.fastq.gz.ca.fastq.bam')
sum(SL32542)



