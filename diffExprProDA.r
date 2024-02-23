#git checkout fe5f9e92f3fe5ca0c75e9d8acfd211feb7358066 diffExprProDA.r
#Rscript diffExprProDA.r
#https://github.com/const-ae/proDA
#remotes::install_github("const-ae/proDA")
#data####
inputMQfile <-"L:/promec/Animesh/Mathilde/rawdata_from animesh 2.txt"
pdf(paste0(inputMQfile,".pdf"))
maxquant_protein_table <- read.delim(inputMQfile,stringsAsFactors = FALSE)
intensity_colnames <- grep("^LFQ\\.intensity\\.", colnames(maxquant_protein_table), value=TRUE)
#intensity_colnames <- grep("^Intensity\\.", colnames(maxquant_protein_table), value=TRUE)
head(intensity_colnames)
abundance_matrix <- as.matrix(maxquant_protein_table[, intensity_colnames])
colnames(abundance_matrix) <- sub("^LFQ\\.intensity\\.", "", intensity_colnames)
#colnames(abundance_matrix) <- sub("^Intensity\\.", "", intensity_colnames)
rownames(abundance_matrix) <- maxquant_protein_table$Protein.IDs
abundance_matrix[46:48, 1:6]
abundance_matrix[abundance_matrix == 0] <- NA
abundance_matrix <- log2(abundance_matrix)
abundance_matrix[46:48, 1:6]
par(mar=c(12,3,1,1))
barplot(colSums(is.na(abundance_matrix)),las=2)
boxplot(abundance_matrix,las=2)
normalized_abundance_matrix <- proDA::median_normalization(abundance_matrix)
boxplot(normalized_abundance_matrix,las=2)
vsn::meanSdPlot(normalized_abundance_matrix)
vsn::meanSdPlot(normalized_abundance_matrix,ranks = FALSE)
countTableDAuniGORNAddsMed<-apply(normalized_abundance_matrix,1,function(x) median(x,na.rm=T))
countTableDAuniGORNAddsSD<-apply(normalized_abundance_matrix,1,function(x) sd(x,na.rm=T))
countTableDAuniGORNAdds<-(normalized_abundance_matrix-countTableDAuniGORNAddsMed)#/countTableDAuniGORNAddsSD
hist(countTableDAuniGORNAdds)
boxplot(countTableDAuniGORNAdds,las=2)
log2LFQimpCorr<-cor(normalized_abundance_matrix,use="pairwise.complete.obs",method="pearson")
colnames(log2LFQimpCorr)<-colnames(normalized_abundance_matrix)
rownames(log2LFQimpCorr)<-colnames(normalized_abundance_matrix)
svgPHC<-pheatmap::pheatmap(log2LFQimpCorr,clustering_distance_rows = "euclidean",clustering_distance_cols = "euclidean",fontsize_row=4,cluster_cols=T,cluster_rows=T,fontsize_col  = 8,na_col = "grey")
ggplot2::ggsave(file=paste0(inputMQfile,"log2selectClust.proDA.svg"),plot=svgPHC,width=6, height=10,dpi = 320)#,
#justVSN####
#BiocManager::install("vsn")
IntVST<-normalized_abundance_matrix
IntVST[IntVST==0]=NA
LFQvsn <- vsn::justvsn(IntVST)
hist(LFQvsn)
vsn::meanSdPlot(LFQvsn)
vsn::meanSdPlot(LFQvsn,ranks = FALSE)
boxplot(LFQvsn,las=2)
countTableDAuniGORNAddsMed<-apply(LFQvsn,1,function(x) median(x,na.rm=T))
countTableDAuniGORNAddsSD<-apply(LFQvsn,1,function(x) sd(x,na.rm=T))
countTableDAuniGORNAdds<-(LFQvsn-countTableDAuniGORNAddsMed)#/countTableDAuniGORNAddsSD
hist(countTableDAuniGORNAdds)
par(mar=c(12,3,1,1))
boxplot(countTableDAuniGORNAdds,las=2)
dataLFQtdc<-cor(LFQvsn,use="pairwise.complete.obs",method="pearson")
pheatmap::pheatmap(dataLFQtdc)
#da <- proDA::dist_approx(normalized_abundance_matrix)
#head(da$mean)
#da$mean[da$mean<50]# <- NA
#pheatmap::pheatmap(da$mean)
experimental_design <- read.table("L:/promec/Animesh/Mathilde/Groups.DEP.txt",sep="\t",header=TRUE)#UbiLength_ExpDesign
sample_info_df <- data.frame(name=gsub("-",".",experimental_design$label,fixed = T),condition=experimental_design$condition,replicate=experimental_design$replicate)
summary(sample_info_df$name %in% colnames(normalized_abundance_matrix))
normalized_abundance_matrix_sel<-normalized_abundance_matrix[,c(sample_info_df$name)]
dim(normalized_abundance_matrix_sel)
fit <- proDA::proDA(normalized_abundance_matrix_sel, design = ~ condition,col_data = sample_info_df, reference_level = "STNTC")
fit
#pheatmap::pheatmap(proDA::dist_approx(fit, by_sample = FALSE)$mean)
for(i in rownames(table(sample_info_df$condition))[-nrow(table(sample_info_df$condition))]){
  fOut=paste0("L:/promec/Animesh/Mathilde/proDA_",i,rownames(table(sample_info_df$condition))[nrow(table(sample_info_df$condition))],".csv")
  print(paste(i,fOut))
  test_res <- proDA::test_diff(fit, paste0("condition",i))
  plot(test_res$diff,test_res$adj_pval)
  write.csv(test_res, file = fOut)
}


