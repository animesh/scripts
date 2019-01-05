pathD<-"F:/promec/USERS/MarianneNymark/181009/PDv2p3/181009_newprep_Charlotte_Alb3b-14_II"
inpF<-file.path(pathD,"181009_newprep_Charlotte_Alb3b-14_II-(1)_Proteins.txt")
data<-read.table(inpF,header=T,sep="\t",row.names = 3)
summary(data)

y<-log2(as.matrix(data[32:46]))
summary(y)
hist(y)
row.names(y)<-row.names.data.frame(data)
y[is.na(y)]<-0
colnames(y)=sub("Abundances.Normalized.F","",colnames(y))
colnames(y)=sub(".Sample","",colnames(y))
summary(y)


inpL<-"F:/promec/USERS/MarianneNymark/181009/PDv2p3/181009_newprep_Charlotte_Alb3b-14_II/Groups.txt"
label<-read.table(inpL,header=T,sep="\t")
colnames(label)
summary(label)

colnames(y)
yy<-rbind(y,t(label))
yy<-t(yy)
write.csv(yy,file.path(pathD,"yy.csv"))


if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")
BiocManager::install("UniProt.ws", version = "3.8")
library("UniProt.ws")
prot <- UniProt.ws(taxId=556484)

#protAnnot<-select(prot, keys=c('B7FQ84'), columns=c("KEGG","GO"),keytype="UNIPROTKB")
protID<-row.names.data.frame(data)
protID<-sapply(strsplit(protID,";"), `[`, 1)
protAnnot<-select(prot, keys=protID, columns=c("KEGG","GO"),keytype="UNIPROTKB")
dim(protAnnot)
dim(data)
dim(prot)

if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")
BiocManager::install("pRoloc", version = "3.8")
library(pRoloc)
