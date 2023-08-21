#source https://raw.githubusercontent.com/animesh/compbio_tutorials/main/scripts/06_scRNseq_two_lines_from_fastq_to_count_matrix.Rmd
#mamba create -n kb-python python=3.7
#conda activate kb-python
#pip install kb-python gget ffq
#kb ref   -i index.idx   -g t2g.txt   -f1 transcriptome.fa   $(gget ref --ftp -w dna,gtf homo_sapiens)
#ls -1d  *.fq.gz | grep -E "1|2" | tr "\n" " "
#kb count   -i index.idx   -g t2g.txt   -x BULK   -t 36   -m 72G  --parity paired -o kbp_out TK10_49_1.fq.gz TK10_49_2.fq.gz TK10_50_1.fq.gz TK10_50_2.fq.gz TK10_51_1.fq.gz TK10_51_2.fq.gz TK12_R1_1.fq.gz TK12_R1_2.fq.gz TK12_R2_1.fq.gz TK12_R2_2.fq.gz TK12_R3_1.fq.gz TK12_R3_2.fq.gz TK13_1_1.fq.gz TK13_1_2.fq.gz TK13_2_1.fq.gz TK13_2_2.fq.gz TK13_3_1.fq.gz TK13_3_2.fq.gz TK14_1_1.fq.gz TK14_1_2.fq.gz TK14_2_1.fq.gz TK14_2_2.fq.gz TK14_3_1.fq.gz TK14_3_2.fq.gz TK16_R1_1.fq.gz TK16_R1_2.fq.gz TK16_R2_1.fq.gz TK16_R2_2.fq.gz TK16_R3_1.fq.gz TK16_R3_2.fq.gz TK18_R1_1.fq.gz TK18_R1_2.fq.gz TK18_R2_1.fq.gz TK18_R2_2.fq.gz TK18_R3_1.fq.gz TK18_R3_2.fq.gz
#https://www.google.com/search?q=Assuming+multiplexed+samples.+For+demultiplexed+samples%2C+provide+a+batch+textfile.&oq=Assuming+multiplexed+samples.+For+demultiplexed+samples%2C+provide+a+batch+textfile.&aqs=edge..69i57.2169j0j1&sourceid=chrome&ie=UTF-8
#-x 10xv2 \
library(Matrix, quietly=T) # load libraries
library(DropletUtils, quietly=T)
library(dplyr)
library(ggplot2)
raw_mtx <- readMM('cells_x_genes.mtx')
genes <- read.csv('cells_x_genes.genes.txt', sep = '\t', header = F)
barcodes<- read.csv('cells_x_genes.barcodes.txt', sep = '\t', header = raw_mtx<- t(raw_mtx)
rownames(raw_mtx) <- genes[,1] # attach gene_ids
colnames(raw_mtx) <- barcodes[,1]
tot_counts <- colSums(raw_mtx)
df <- tibble(total = tot_counts,rank = row_number(desc(total))) %>% distinct() %>% arrange(rank)
ggplot(df, aes(total, rank)) +geom_path() +scale_x_log10() +scale_y_log10() +annotation_logticks() +labs(y = "Barcode rank", x = "Total UMI count")
out <- emptyDrops(raw_mtx) # get probability that each barcode is a cell
keep <- out$FDR <= 0.05 # define threshold probability for calling a cell
keep[is.na(keep)] <- FALSE
filt_mtx <- raw_mtx[,keep] # subset raw mtx to remove empty drops
dim(filt_mtx)
#ffq SRR9990627
#$(ffq --ftp SRR10668798 | jq -r '.[] | .url' | tr '\n' ' ')
