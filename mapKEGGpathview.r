#Rscript mapKEGGpathview.r "L:/promec/Elite/LARS/2018/mai/Vibeke V/PDv2p5/Clots/Table 1_median.normalized.values_compl.docx" "hsa04610"
#setup####
if(!require("docxtractr")) install.packages(c("BiocManager","scales","docxtractr"),repos="https://cran.r-project.org")
if(!require("pathview")) BiocManager::install(c("pathview","org.Hs.eg.db"))
#BiocManager::install(update=T)
library(pathview)
args = commandArgs(trailingOnly=TRUE)
if(length(args)==0){
  args<-c("L:/promec/Elite/LARS/2018/mai/Vibeke V/PDv2p5/Clots/Table 1_median.normalized.values_compl.docx","hsa04610")
}
print(paste("supplied argument(s):", length(args)))
print(args)
options(nwarnings = 1000000)
summary(warnings())
inpF <- args[1]
pathKEGG <- args[2]
inpD<-dirname(inpF)
setwd(inpD)
getwd()
pdf(paste0(inpF,".pdf"))
#.libPaths(c(paste0(inpD,"/R/")),.libPaths())
#.libPaths()
#?pathview
#data####
data<-docxtractr::read_docx(inpF)
docxtractr::docx_tbl_count(data)
docxtractr::docx_describe_tbls(data)
docxtractr::docx_extract_tbl(data)
dataS<-docxtractr::docx_extract_tbl(data)
dataS$ILTxF<-as.numeric(gsub("<","",dataS$P.value2ILT.vs..F))
hist(dataS$ILTxF)
dataS$CxILT<-as.numeric(gsub("<","",dataS$P.value2C.vs..ILT))
hist(dataS$CxILT)
dataS$ProteinID<-gsub("Factor ","F",dataS$Protein)
dataS$ProteinID<-paste(sapply(strsplit(dataS$ProteinID, " |-", perl = TRUE), "[", 1))
print(dataS, row.names = FALSE)
dataSel<-dataS[!duplicated(dataS$ProteinID),]
rN<-dataSel$ProteinID
dataSel<-dataSel[,grep("x",colnames(dataSel))]
rownames(dataSel)<-rN#lapply(dataSel, function(x) x[x$==min(x$fifteen),])
#dataSel<-unique(dataSel)
#dataS<-as.matrix(data2[,c(16)],rownames=T)#as.matrix(data[,c(10:15)],rownames=T)
#dataS<-as.matrix(data2[,c(10:15)],rownames=T)
#dataS<-apply(dataS, 2, as.numeric)
#dataS[dataS==0]=NA
#rn<-strsplit(data2$Gene,";")
#rn<-strsplit(data1$Gene,";")
#rn<-paste(sapply(rn, "[", 1))#,sapply(rn, "[", 3),sapply(rn, "[", 6))
#rn<-strsplit(rn, "-")
#row.names(dataS)<-rn
#cn<-strsplit(colnames(dataS), "_")
#colnames(dataS)<-paste(sapply(cn, "[", 1))#,sapply(cn, "[", 4))
#summary(dataS)
plot(dataSel)
#limma::vennDiagram(dataSel<1)
#pathview####
#https://bioconductor.org/packages/release/bioc/vignettes/pathview/inst/doc/pathview.pdf
#data(gse16873.d)
#pv.out <- pathview(gene.data = gse16873.d[, 1], pathway.id = "04110", species = "hsa", out.suffix = "gse16873")
#TCA https://www.genome.jp/pathway/hsa00020+3417
#Urea https://www.genome.jp/pathway/hsa00220+445
#hda=dataS
#rowName<-strsplit(data$Uniprot, ";")
#rowName<-paste(sapply(rowName, "[", 1))
#rowName<-strsplit(rowName, "-")
#protNum<-1:nrow(dataS)
#protName<-sapply(rowName, "[", 1)
#rowName<-paste(protName,protNum,sep=";")
#rownames(hda)<-rowName
#hist(hda)
#hda[is.na(hda)]=0
#hda=hda-hda[,3]
#hda=hda-hda[,2]
#hda=hda-matrixStats::rowMedians(hda)
#hda=hda-median(hda,na.rm=T)+1e-6
write.table(dataSel,paste0(inpF,"dataSel.txt"),sep="\t")
#hda[hda==0]<-NA
#hda=hda[,1]
#hda[is.na(hda)]<-0
#hist(hda)
#heatmap(hda)
#library(scales)
#scale(t(hda))
pspecies<-"hsa"
sfx<-"_x_"#paste(gsub("[^[:alnum:] ]", "",colnames(dataS)), collapse='_' )
dataSelml10<-log10(dataSel)*-1
rownames(dataSelml10)<-rownames(dataSel)
plot(dataSelml10)
idtype<-gene.idtype.list[1]#gene.idtype.list[6]#"UNIPROT"
pathview(dataSelml10,pathway.id=pathKEGG,species=pspecies,gene.idtype=idtype,low=list(gene="white"),mid=list(gene="yellow"),high=list(gene="orange"),both.dirs=list(gene=F), limit = list(gene = 3), bins = list(gene = 3), na.col="grey",out=sfx)
write.csv(dataSelml10,paste0(inpF,sfx,"dataSelml10.csv"))
summary(warnings())

