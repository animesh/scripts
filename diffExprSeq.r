#"F:\OneDrive - NTNU\R-4.3.2\bin\Rscript.exe" C:\Users\animeshs\OneDrive\Desktop\Scripts\diffExprSeq.r L:\promec\Animesh\TK\hg38lall\star_salmon\
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
#inpD<-"L:/promec/Animesh/TK/hg38lall/star_salmon/"
inpF<-"salmon.merged.gene_counts_length_scaled.tsv"
countTable = read.table(paste0(inpD,inpF),header=TRUE,row.names=1)
colnames(countTable)
summary(countTable)
#pdf(paste(inpD,inpF,"plots","pdf",sep = "."))
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
#sampleInfo####
colnames(repColLFQ)
condition = factor( c("NS","NS","S","S","S","NS","NS"))
sInfo<-data.frame(sample=colnames(repColLFQ)[-1],fastq_1=paste0(colnames(repColLFQ)[-1],"_1.fq.gz"),fastq_2=paste0(colnames(repColLFQ)[-1],"_2.fq.gz"),condition=condition)#sample,fastq_1,fastq_2,condition,bio,batch,replicate,greplicate#TK1049,TK10_49_1.fq.gz,TK10_49_2.fq.gz,NS,TK10,A,1,1
write.csv(sInfo,paste0(inpD,"samples.csv"),row.names = F,quote = F)
#contrastInfo####
cInfo<-data.frame(id="con_NS_S",variable="condition",reference="NS",target="S",blocking="")#condition_control_treated,condition,NS,S,greplicate
write.csv(cInfo,paste0(inpD,"contrasts.csv"),row.names = F,quote = F)
#nextflow run nf-core/differentialabundance  --max_memory '80.GB' --max_cpus 20  --input samples.csv --contrasts contrasts.csv --matrix salmon.merged.gene_counts_length_scaled.tsv.sampleSum.tsv --gtf /cluster/projects/nn9036k/scripts/hg38v110/Homo_sapiens.GRCh38.110.gtf  -profile singularity --outdir diffExprHG38lallSum
#dos2unix scratch.slurm 
#sbatch scratch.slurm 
#tail -f HG38diffExpr
#rsync -Parv ash022@login-1.saga.sigma2.no:/cluster/projects/nn9036k/scripts/diffExprHG38lallSum/ /cygdrive/f/promec/Animesh/TK/diffExprHG38lallSum/
