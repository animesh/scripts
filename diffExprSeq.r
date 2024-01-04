#"F:\OneDrive - NTNU\R-4.3.2\bin\Rscript.exe" C:\Users\animeshs\OneDrive\Desktop\Scripts\diffExprSeq.r L:\promec\Animesh\TK\hg37all\star_salmon\
#nextflow run nf-core/differentialabundance  --max_memory '80.GB' --max_cpus 20  --input samples.csv --contrasts contrasts.csv --matrix salmon.merged.gene_counts_length_scaled.tsv.sampleSum.tsv   -profile singularity --outdir diffExprHG37allSum
#rsync -Parv ash022@login-1.saga.sigma2.no:/cluster/projects/nn9036k/scripts/diffExprHG37allSum/ /cygdrive/f/promec/Animesh/TK/diffExprHG37allSum/
args = commandArgs(trailingOnly=TRUE)
print(paste("supplied argument(s):", length(args)))
print(args)
#setup####
#install.packages("BiocManager")
#install.packages("pheatmap")
#BiocManager::install("limma")
#BiocManager::install("edgeR")
library(limma)
library(edgeR)
#data####
inpD <- args[1]
#inpD<-"L:/promec/Animesh/TK/hg37all/star_salmon/"
inpF<-"salmon.merged.gene_counts_length_scaled.tsv"
countTable = read.table(paste0(inpD,inpF),header=TRUE,row.names=1)
colnames(countTable)
summary(countTable)
pdf(paste(inpD,inpF,"plots","pdf",sep = "."))
#select####
countTableSel=countTable[,grep("TK",colnames(countTable))]
summary(countTableSel)
colnames(countTableSel)
colnames(countTableSel)=gsub("TK9","TK9_",colnames(countTableSel))
colnames(countTableSel)
colnames(countTableSel)=gsub("TK10","TK10_",colnames(countTableSel))
colnames(countTableSel)
colnames(countTableSel)=gsub("TK12","TK12_",colnames(countTableSel))
colnames(countTableSel)
colnames(countTableSel)=gsub("TK13","TK13_",colnames(countTableSel))
colnames(countTableSel)
colnames(countTableSel)=gsub("TK14","TK14_",colnames(countTableSel))
colnames(countTableSel)
colnames(countTableSel)=gsub("TK16","TK16_",colnames(countTableSel))
colnames(countTableSel)
colnames(countTableSel)=gsub("TK18","TK18_",colnames(countTableSel))
colnames(countTableSel)
summary(countTableSel)
hist(sapply(countTableSel,as.numeric))
par(mar=c(12,3,1,1))
boxplot(countTableSel,las=2,main="countTableSel")
#sampleSum####
label<-data.frame(Bio=sapply(strsplit(colnames(countTableSel),"_",fixed=T),'[[',1))
label$Group<-colnames(countTableSel)
table(label$Bio)
table(label$Group)
repColLFQ <- data.frame(matrix(ncol=length(names(table(label$Bio))),nrow=nrow(countTableSel)))
colnames(repColLFQ) <- names(table(label$Bio))
rownames(repColLFQ)<-rownames(countTableSel)
for(i in names(table(label$Bio))){
  print(i)
  valsLFQ<-data.frame(countTableSel[,label[label$Bio==i,"Group"]])
  print(summary(valsLFQ))
  repColLFQ[i]<-apply(valsLFQ,1, function(x) sum(x,na.rm=T))
  print(summary(repColLFQ[i]))
  hist(as.matrix(repColLFQ[i]))
}
summary(repColLFQ)
hist(repColLFQ[,1])
hist(sapply(repColLFQ,as.numeric))
boxplot(repColLFQ,las=2,main="sampleSum")
repColLFQ$gene_id <- rownames(repColLFQ)
repColLFQ<-repColLFQ[,c(ncol(repColLFQ),1:(ncol(repColLFQ)-1))]
write.table(repColLFQ,paste0(inpD,inpF,".sampleSum.tsv"),row.names = F,quote = F,sep="\t")
countTableTest = read.table(paste0(inpD,inpF,".sampleSum.tsv"),header=TRUE,row.names=1)
#sampleSumlog2####
log2countTableSel=log2(countTableTest)
log2countTableSel[log2countTableSel==-Inf]<-NA
summary(log2countTableSel)
boxplot(log2countTableSel,las=2,main="log2countTableSel")
hist(log2countTableSel[,1])
hist(sapply(log2countTableSel,as.numeric))
#sampleInfo####
colnames(repColLFQ)
condition = factor( c("NS","NS","S","S","S","NS","NS"))
sInfo<-data.frame(sample=colnames(repColLFQ)[-1],fastq_1=paste0(colnames(repColLFQ)[-1],"_1.fq.gz"),fastq_2=paste0(colnames(repColLFQ)[-1],"_2.fq.gz"),condition=condition)#sample,fastq_1,fastq_2,condition,bio,batch,replicate,greplicate#TK1049,TK10_49_1.fq.gz,TK10_49_2.fq.gz,NS,TK10,A,1,1
write.csv(sInfo,paste0(inpD,"samples.csv"),row.names = F,quote = F)
#contrastInfo####
cInfo<-data.frame(id="con_NS_S",variable="condition",reference="NS",target="S",blocking="")#condition_control_treated,condition,NS,S,greplicate
write.csv(cInfo,paste0(inpD,"contrasts.csv"),row.names = F,quote = F)
#sampleMax####
repColLFQ <- data.frame(matrix(ncol=length(names(table(label$Bio))),nrow=nrow(countTableSel)))
colnames(repColLFQ) <- names(table(label$Bio))
rownames(repColLFQ)<-rownames(countTableSel)
for(i in names(table(label$Bio))){
  print(i)
  valsLFQ<-data.frame(countTableSel[,label[label$Bio==i,"Group"]])
  print(summary(valsLFQ))
  repColLFQ[i]<-apply(valsLFQ,1, function(x) max(x,na.rm=T))
  print(summary(repColLFQ[i]))
  hist(as.matrix(repColLFQ[i]))
}
summary(repColLFQ)
hist(repColLFQ[,1])
hist(sapply(repColLFQ,as.numeric))
boxplot(repColLFQ,las=2,main="sampleMAx")
repColLFQ$gene_id <- rownames(repColLFQ)
repColLFQ<-repColLFQ[,c(ncol(repColLFQ),1:(ncol(repColLFQ)-1))]
write.table(repColLFQ,paste0(inpD,inpF,".sampleMax.tsv"),row.names = F,quote = F,sep="\t")
countTableTest = read.table(paste0(inpD,inpF,".sampleMax.tsv"),header=TRUE,row.names=1)
#sampleSumlog2####
log2countTableSel=log2(countTableTest)
log2countTableSel[log2countTableSel==-Inf]<-NA
summary(log2countTableSel)
boxplot(log2countTableSel,las=2,main="log2countTableSel")
hist(log2countTableSel[,1])
hist(sapply(log2countTableSel,as.numeric))
#sampleMedian####
summary(countTableSel)
countTableSelNA<-countTableSel
countTableSelNA[countTableSelNA==0]<-NA
summary(countTableSelNA)
repColLFQ <- data.frame(matrix(ncol=length(names(table(label$Bio))),nrow=nrow(countTableSelNA)))
colnames(repColLFQ) <- names(table(label$Bio))
rownames(repColLFQ)<-rownames(countTableSelNA)
for(i in names(table(label$Bio))){
  print(i)
  valsLFQ<-data.frame(countTableSelNA[,label[label$Bio==i,"Group"]])
  print(summary(valsLFQ))
  repColLFQ[i]<-apply(valsLFQ,1, function(x) median(x,na.rm=T))
  print(summary(repColLFQ[i]))
  hist(as.matrix(repColLFQ[i]))
}
summary(repColLFQ)
repColLFQ[is.na(repColLFQ)]<-0
summary(repColLFQ)
hist(repColLFQ[,1])
hist(sapply(repColLFQ,as.numeric))
boxplot(repColLFQ,las=2,main="sampleMedian")
repColLFQ$gene_id <- rownames(repColLFQ)
repColLFQ<-repColLFQ[,c(ncol(repColLFQ),1:(ncol(repColLFQ)-1))]
write.table(repColLFQ,paste0(inpD,inpF,".sampleMedian.tsv"),row.names = F,quote = F,sep="\t")
countTableTest = read.table(paste0(inpD,inpF,".sampleMedian.tsv"),header=TRUE,row.names=1)
#sampleMedlog2####
log2countTableSel=log2(countTableTest)
log2countTableSel[log2countTableSel==-Inf]<-NA
summary(log2countTableSel)
boxplot(log2countTableSel,las=2,main="log2countTableSel")
hist(log2countTableSel[,1])
hist(sapply(log2countTableSel,as.numeric))
#sampleMean####
summary(countTableSelNA)
repColLFQ <- data.frame(matrix(ncol=length(names(table(label$Bio))),nrow=nrow(countTableSelNA)))
colnames(repColLFQ) <- names(table(label$Bio))
rownames(repColLFQ)<-rownames(countTableSelNA)
for(i in names(table(label$Bio))){
  print(i)
  valsLFQ<-data.frame(countTableSelNA[,label[label$Bio==i,"Group"]])
  print(summary(valsLFQ))
  repColLFQ[i]<-apply(valsLFQ,1, function(x) mean(x,na.rm=T))
  print(summary(repColLFQ[i]))
  hist(as.matrix(repColLFQ[i]))
}
summary(repColLFQ)
repColLFQ[is.na(repColLFQ)]<-0
summary(repColLFQ)
hist(repColLFQ[,1])
hist(sapply(repColLFQ,as.numeric))
boxplot(repColLFQ,las=2,main="sampleMean")
repColLFQ$gene_id <- rownames(repColLFQ)
repColLFQ<-repColLFQ[,c(ncol(repColLFQ),1:(ncol(repColLFQ)-1))]
write.table(repColLFQ,paste0(inpD,inpF,".sampleMean.tsv"),row.names = F,quote = F,sep="\t")
countTableTest = read.table(paste0(inpD,inpF,".sampleMean.tsv"),header=TRUE,row.names=1)
#sampleMedlog2####
log2countTableSel=log2(countTableTest)
log2countTableSel[log2countTableSel==-Inf]<-NA
summary(log2countTableSel)
boxplot(log2countTableSel,las=2,main="log2countTableSel")
hist(log2countTableSel[,1])
hist(sapply(log2countTableSel,as.numeric))
#voom
des = model.matrix(~-1+condition)
colnames(des) = levels(condition)
cmat <- makeContrasts(S - NS, levels=des)
dge <- DGEList(counts=repColLFQ)
dge <- calcNormFactors(dge)
v <- voom(dge,design=des, normalize.method = "quantile",plot=TRUE)
#v <- voom(dge,design=des, plot=TRUE)
heatmap(cor(v[["E"]]))
pheatmap::pheatmap(cor(v[["E"]]))
range(log2(v[["E"]]),na.rm=T)
hist(v[["E"]])
boxplot(v[["E"]])
log2v=log2(abs(v[["E"]]))
boxplot(log2v)
hist(log2v)
summary(log2v)
colnames(log2v)
write.csv(log2v,file=paste0(inpD,inpF,".log2v.quant.norm.csv"))
hist(v[["weights"]])
write.csv(v[["weights"]],file=paste0(inpD,inpF,".weights.quant.norm.csv"))
fit <- lmFit(v,design=des)
fit <- contrasts.fit(fit, cmat)
fit <- eBayes(fit)
a <- decideTests(fit,adjust.method="fdr", p.value=0.05, lfc=0)
sma = summary(a)
print(sma)
dmm <- dim(maxLFQ)
res <- topTable(fit,n=dmm[1],coef=1)
plot(res$logFC,-log10(res$adj.P.Val))
resMerged<-merge(res,v[["E"]],by="row.names")
resMerged<-resMerged[order(resMerged$P.Value),]
write.csv(resMerged,file=paste0(inpD,inpF,"sum.voom.csv"),row.names = F)
#still variance , need to explore VTS https://bioconductor.org/packages/devel/bioc/vignettes/DESeq2/inst/doc/DESeq2.html , https://bioconductor.org/packages/devel/bioc/vignettes/DESeq2/inst/doc/DESeq2.html#collapsing-technical-replicates , https://rnabio.org/module-03-expression/0003/02/01/Expression/ , http://cole-trapnell-lab.github.io/cufflinks/cuffcompare/index.html#cuffcompare-output-files , https://www.nature.com/articles/s41587-022-01440-w Removing unwanted variation from large-scale RNA sequencing data with PRPS? https://github.com/animesh/TCGA_PanCancer_UnwantedVariation
#ribosom https://string-db.org/cgi/globalenrichment?taskId=b8Wq4Li11Zpx&sessionId=bYMNhNKAgVfp or odorant receptors? also checkout Cancer Transcriptome Analysis Toolkit Using Trinity https://www.youtube.com/watch?v=9ky5NwV45qY https://github.com/trinityrnaseq/trinityrnaseq/wiki#contact_us or try Gene modelling with https://academic.oup.com/dnaresearch/article/30/4/dsad017/7227702?login=true ? also check https://gist.github.com/animesh/1d70401d56eb5b81b9aff4d28d7f1895
