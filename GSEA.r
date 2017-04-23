## human gene set profiles
data=read.csv("L:/Elite/gaute/test/SHBER.csv")

## mapping Uniprot to Gene Name
library(org.Hs.eg.db)
egmap <- revmap(org.Hs.egUNIPROT)[as.character(data$Entry)]
genelist <- as.vector(toTable(egmap)$gene_id)

##basic GO profile
library(goProfiles)
basicProfile(genelist, onto = "MF",level = 2, orgPackage = "org.Hs.eg.db")

##enrichment of GO categories
library('GeneAnswers')
humga<-geneAnswersBuilder(genelist, "org.Hs.eg.db", categoryType='GO.BP', testType='hyperG',  pvalueT=0.1, FDR.correction=TRUE, geneExpressionProfile=data)
geneAnswersReadable(humga)

## arabidopsis
#source("http://bioconductor.org/biocLite.R")
#biocLite("org.At.tair.db")
#library("GO.db")
#library(AnnotationDbi")

at=read.csv("L:/Elite/LARS/2013/desember/ishita/Min2PepRatio.TAIR.csv")
egmap <- as.vector(at$TAIR)

library(org.At.tair.db)
basicProfile(genelist=egmap, onto = "BP", level = 1, orgPackage = "org.At.tair.db")
basicProfile(genelist=egmap, onto = "MF", level = 2, orgPackage = "org.At.tair.db")

library('GeneAnswers')
x <- geneAnswersBuilder(egmap, 'org.At.tair.db', categoryType='GO.BP', testType='hyperG',  pvalueT=0.1, FDR.correction=TRUE, geneExpressionProfile=at)
geneAnswersReadable(x)

## testing some SILAC data
sc=read.table('M:/SILACrd.txt',header=TRUE)
egmap <- revmap(org.Hs.egSYMBOL)[as.character(sc$Symbol)]
basicProfile(as.vector((toTable(egmap)$gene_id)), onto = "BP",level = 2, orgPackage = "org.Hs.eg.db")
