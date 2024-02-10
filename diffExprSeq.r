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
vstLFQ<-apply(countTableTest,2,function(x) ceiling(x))
hist(vstLFQ)
vstLFQ<-DESeq2::vst(vstLFQ)
dim(vstLFQ)
summary(vstLFQ)
hist(vstLFQ)
boxplot(vstLFQ)
#but first filter low counts and normalize! finally compare with diffabudnace results and then map ENSG to https://amigo.geneontology.org/amigo/term/GO:0022626 and create heatmap
#hg38lallDA####
countTableDA = read.table(paste0("L:/promec/Animesh/TK/diffExprHG38lallSumOld/tables/processed_abundance/all.vst.tsv"),header=TRUE,row.names=1)
#countTableDAredo = read.table(paste0("L:/promec/Animesh/TK/diffExprHG38lallSumNew/tables/processed_abundance/all.vst.tsv"),header=TRUE,row.names=1)
#diffDA<-(countTableDAredo-countTableDA)
#summary(diffDA)
boxplot(countTableDA)
hist(as.numeric(countTableDA$TK10))
#annoENSG = read.table("https://biit.cs.ut.ee/gprofiler_beta//static/gprofiler_full_hsapiens.ENSG.gmt",header=FALSE,sep=",")#row.names=1,
#annoENSGRNA<-annoENSG[grepl("^GO:0022626",annoENSG$V1),]
#http://api.geneontology.org/api/bioentity/function/GO:0022626/genes
#download.file("https://biit.cs.ut.ee/gprofiler_beta//static/gprofiler_full_hsapiens.ENSG.gmt","L:/promec/Animesh/TK/gprofiler_full_hsapiens.ENSG.gmt")
#download.file("https://ftp.ensembl.org/pub/release-110/tsv/homo_sapiens/Homo_sapiens.GRCh38.110.uniprot.tsv.gz","F:/OneDrive - NTNU/Desktop/Homo_sapiens.GRCh38.110.uniprot.tsv.gz")
annoENSG = read.table("F:/OneDrive - NTNU/Desktop/Homo_sapiens.GRCh38.110.uniprot.tsv.gz",header=T)#,sep=",")#row.names=1,
colnames(countTableDA)
countTableDAuni<-merge(countTableDA,annoENSG,by.x='row.names',by.y='gene_stable_id',all.x=T)
#download.file("https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/idmapping/by_organism/HUMAN_9606_idmapping_selected.tab.gz","F:/OneDrive - NTNU/Desktop/HUMAN_9606_idmapping_selected.tab.gz")
annoUniprot = read.table("F:/OneDrive - NTNU/Desktop/HUMAN_9606_idmapping_selected.tab.gz",header=F,sep="\t")#row.names=1,
countTableDAuniGO<-merge(countTableDAuni,annoUniprot,by.x='xref',by.y='V1',all.x=T)
write.csv(countTableDAuniGO,"F:/OneDrive - NTNU/Desktop/countTableDAuniGO.csv",row.names = F,quote = F)
countTableDAuniGO<-read.csv("F:/OneDrive - NTNU/Desktop/TK/countTableDAuniGO.csv")
countTableDAuniGORNA<-countTableDAuniGO[grep("GO:0022626",countTableDAuniGO$V7),]
countTableDAuniGORNAdata<-countTableDAuniGORNA[,grep("TK",colnames(countTableDAuniGORNA))]
countTableDAuniGORNAdata$Uniprot<-countTableDAuniGORNA$xref
countTableDAuniGORNAdd<-countTableDAuniGORNAdata[!duplicated(countTableDAuniGORNAdata), ]
row.names(countTableDAuniGORNAdd)<-countTableDAuniGORNAdd$Uniprot
countTableDAuniGORNAdd<-countTableDAuniGORNAdd[,-ncol(countTableDAuniGORNAdd)]
countTableDAuniGORNAddsMed<-apply(countTableDAuniGORNAdd,1,function(x) median(x,na.rm=T))
countTableDAuniGORNAddsSD<-apply(countTableDAuniGORNAdd,1,function(x) sd(x,na.rm=T))
countTableDAuniGORNAdds<-(countTableDAuniGORNAdd-countTableDAuniGORNAddsMed)/countTableDAuniGORNAddsSD
hist(countTableDAuniGORNAdds$TK10)
write.csv(countTableDAuniGORNAdds,"F:/OneDrive - NTNU/Desktop/countTableDAuniGORNAdds.csv",row.names = T,quote = F)
svgPHC<-pheatmap::pheatmap(countTableDAuniGORNAdds,cluster_cols = T,cluster_rows = T,clustering_distance_rows = "euclidean",clustering_distance_cols = "euclidean",fontsize_row=4,fontsize_col  = 8)
ggplot2::ggsave("F:/OneDrive - NTNU/Desktop/countTableDAuniGORNAdds.svg", svgPHC,width=10, height=8,dpi = 320)
countTableDAuniGORNAddsTK124<-countTableDAuniGORNAdd[,grep("TK12|TK13|TK14",colnames(countTableDAuniGORNAdd))]
pValNA = apply(
  countTableDAuniGORNAddsTK124, 1, function(x)
    if(sum(!is.na(x)<2)){NA}
    else{
    t.test(as.numeric(x[c(2,3)]),as.numeric(x[c(1)]),var.equal=T,alternative= "greater")$p.value}
)
summary(warnings())
hist(pValNA)
summary(pValNA)
countTableDAuniGORNAddsTK124$Pval<-pValNA
pValBHna = p.adjust(pValNA,method = "BH")
hist(pValBHna)
summary(pValBHna)
plot(pValBHna,pValNA,main=cor(pValBHna,pValNA,method = "spearman"))
countTableDAuniGORNAddsTK124$corrPval<-pValBHna
countTableDAuniGORNAddsTK124$Uniprot<-countTableDAuniGORNA$xref
write.csv(countTableDAuniGORNAddsTK124,"F:/OneDrive - NTNU/Desktop/TK/countTableDAuniGORNAddsTK124.csv",row.names = T,quote = F)
dataSel11<-read.csv("F:/OneDrive - NTNU/Desktop/TK/sel11smapL.txt",header=T,sep="\t")
dataAnno<-read.csv("L:/promec/Animesh/TK/diffExprHG38lallSumOld/tables/annotation/Homo_sapiens.anno.tsv",header=T,sep="\t")
dataSel11anno<-merge(dataSel11,dataAnno,by.x="Name",by.y="gene_name",all.x=T)
dataSel11annoENSG<-dataSel11anno[,grep("Name|gene_id",colnames(dataSel11anno))]
dataSel11annoENSG<-dataSel11annoENSG[!duplicated(dataSel11annoENSG),]
dataVST<-read.csv("L:/promec/Animesh/TK/diffExprHG38lallSumOld/tables/processed_abundance/all.vst.tsv",header=T,sep="\t")
dataSel11annoENSGvst<-merge(dataSel11annoENSG,dataVST,by="gene_id",all.x=T)
write.csv(dataSel11annoENSGvst,"F:/OneDrive - NTNU/Desktop/TK/sel11smapLdata.csv")
rownames(dataSel11annoENSGvst)<-dataSel11annoENSGvst$Name
dataSel11annoENSGvst<-dataSel11annoENSGvst[,grep("TK",colnames(dataSel11annoENSGvst))]
countTableDAuniGORNAddsMed<-apply(dataSel11annoENSGvst,1,function(x) median(x,na.rm=T))
countTableDAuniGORNAddsSD<-apply(dataSel11annoENSGvst,1,function(x) sd(x,na.rm=T))
dataSel11annoENSGvst<-(dataSel11annoENSGvst-countTableDAuniGORNAddsMed)/countTableDAuniGORNAddsSD
hist(dataSel11annoENSGvst$TK10)
pheatmap::pheatmap(dataSel11annoENSGvst)
svgPHC<-pheatmap::pheatmap(dataSel11annoENSGvst,cluster_cols = T,cluster_rows = T,clustering_distance_rows = "euclidean",clustering_distance_cols = "euclidean",fontsize_row=8,fontsize_col  = 8)
ggplot2::ggsave("F:/OneDrive - NTNU/Desktop/TK/sel11smapLdata.svg", svgPHC,width=10, height=8,dpi = 320)
write.csv(dataSel11annoENSGvst,"F:/OneDrive - NTNU/Desktop/TK/sel11smapLdataZ.csv",row.names = T,quote = F)


