#..\R-4.5.0\bin\Rscript.exe .\proteinGroupsNormGene.r "L:\promec\Animesh\Aida\txt207\proteinGroupsHCL.txt"
print("USAGE:Rscript proteinGroups.r <complete path to txt file>")
inpF<-file.path("L:/promec/Animesh/Aida/txt207/proteinGroupsHCL.txt")
selection=c(1:10)
id1="T..Gene.names"
id2="T..Protein.IDs"
selGene1="BRD4"
selGene2="FKBP12"
options(nwarnings = 1000000)
outF<-paste(inpF,selection[1],selection[length(selection)],id1,id2,selGene1,selGene2,sep = ".")
pdf(paste(outF,"pdf",sep = "."))
par(mar=c(12,3,1,1))
data<-read.table(inpF,header=T,sep="\t")
data[is.na(data)]<-0
#if(require("writexl")){writexl::write_xlsx(as.data.frame(data),paste0(inpF,".xlsx"))}#'String exceeds Excel's limit of 32,767 characters.'
dim(data)
intensity<-as.matrix(data[,selection])
print(intensity[grep(selGene1,data[,id1]),])
print(intensity[grep(selGene2,data[,id1]),])
print(data.frame(colSums(intensity!=0)))
boxplot(intensity,las=2,main=selection)
intensityselGene1<-intensity-do.call(rbind, replicate(nrow(data), intensity[grep(selGene1,data[,id1]),], simplify=FALSE))
print(intensityselGene1[grep(selGene1,data[,id1]),])
print(intensityselGene1[grep(selGene2,data[,id1]),])
boxplot(intensityselGene1,las=2,main=selection)
Gene<-sapply(strsplit(paste0(data[,id1],data[,id2],rownames(data)),";"), `[`, 1)
Gene<-sapply(strsplit(Gene,"|",fixed=TRUE),`[`, 1)
Gene<-sapply(strsplit(Gene," ",fixed=TRUE),`[`, 1)
rownames(intensityselGene1)<-Gene
print(rownames(intensityselGene1)[grep(selGene1,data[,id1])])
print(rownames(intensityselGene1)[grep(selGene2,data[,id1])])
write.csv(intensityselGene1,paste0(outF,".intensityselGene1.csv"))
svgPHC <- pheatmap::pheatmap(intensityselGene1,clustering_distance_rows = "euclidean",clustering_distance_cols = "euclidean",fontsize_row=10,cluster_cols=T,cluster_rows=T,fontsize_col=10)
ggplot2::ggsave(paste0(outF,"Cluster.svg"), svgPHC)
dev.off()
summary(warnings())
