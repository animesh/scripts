#setwd('L:/Results/Ani')
#source("http://bioconductor.org/biocLite.R")
#biocLite("BiocUpgrade")
#biocLite("gage")
#biocLite("pathview")
#biocLite("GeneAnswers")
#biocLite("org.Hs.eg.db")
#biocLite("GO.db")
#biocLite("biomaRt")
#rm(list = ls())
#dev.off() 

## pathview 
library(gage)
library(pathview)
# with MM20CL14 SS data over Hedgehog signaling pathway
hda=readExpData("L:/Elite/Aida/MM20MQv1p5XcompNewRD.txt",row.names=1)
hda=as.matrix(hda)
#cancer related hsa05200
pathview(hda,pathway.id="hsa05200",gene.idtype="UNIPROT",out.suffix="jak")

#check mapping significant
data=nrow(hda.d)
dm=10
km=100
kegg=60
GOmap <-  matrix(c(data-dm, dm,kegg-dm, km), nrow = 2, dimnames = list(DATA = c("mapped", "unmapped"), KEGG = c("mapped", "unmapped")))
fisher.test(GOmap, alternative = "greater")


hda=readExpData("C:/Users/animeshs/OneDrive/SHBER.txt",row.names=1)
hda=as.matrix(hda)
hda.d=hda[,1:3]-hda[,4:6]
summary(hda.d)
pv.out<-pathview(hda.d,pathway.id="hsa03410",gene.idtype="UNIPROT", limit = list(gene = 5, cpd = 1), out.suffix=proc.time())
str(pv.out)
head(pv.out$plot.data.gene)


# test on http://www.nature.com/nri/journal/v5/n5/fig_tab/nri1604_F1.html 
pathview(hda.d,pathway.id="hsa04630",gene.idtype="UNIPROT",out.suffix="jak")
pathview(hda.d,pathway.id="hsa00020",gene.idtype="UNIPROT",out.suffix="joxphos")


# http://www.genome.jp/kegg/pathway/map/map00020.html
pathview(hda,pathway.id="hsa00020",gene.idtype="UNIPROT",out.suffix="TCA")
# http://www.genome.jp/kegg/pathway/map/map00030.html
pathview(hda,pathway.id="hsa00030",gene.idtype="UNIPROT",out.suffix="PPP")
# http://www.genome.jp/kegg/pathway/map/map00190.html 
pathview(hda,pathway.id="hsa00190",gene.idtype="UNIPROT",out.suffix="OxPhos")
# http://www.genome.jp/kegg/pathway/map/map00010.html
pathview(hda,pathway.id="hsa00010",gene.idtype="UNIPROT",out.suffix="Glycolysis")

# Trasfection
hda=readExpData("L:/Elite/LARS/2014/mai/transfection 3rd paralell/ListPV1in20FC2.txt",row.names=1)
hda=as.matrix(hda)
# herpes simplex
pathview(hda,pathway.id="hsa03410",gene.idtype="UNIPROT")
pathview(hda,pathway.id="hsa05168",gene.idtype="UNIPROT")


source("http://bioconductor.org/biocLite.R")
biocLite("GOstats")
library("org.Hs.eg.db")
frame = toTable(org.Hs.egGO)
goframeData = data.frame(frame$go_id, frame$Evidence, frame$gene_id)
head(goframeData)
goFrame=GOFrame(goframeData,organism="Homo sapiens")
goAllFrame=GOAllFrame(goFrame)
library("GSEABase")
gsc <- GeneSetCollection(goAllFrame, setType = GOCollection())
library("GOstats")
universe = Lkeys(org.Hs.egGO)
genes = universe[1:500]
params <- GSEAGOHyperGParams(name="My Custom GSEA based annot Params",
                              geneSetCollection=gsc,
                              geneIds = genes,
                              universeGeneIds = universe,
                              ontology = "MF",
                              pvalueCutoff = 0.05,
                              conditional = FALSE,
                              testDirection = "over")
Over <- hyperGTest(params)
head(summary(Over))


pv.out <- pathview(hda.d,pathway.id="hsa03410",gene.idtype="UNIPROT", limit = list(gene = 5, cpd = 1), out.suffix="fcnn", kegg.native = TRUE)
str(pv.out)
head(pv.out$plot.data.gene)


## MS to SNP

source("http://bioconductor.org/biocLite.R")
biocLite("sapFinder")
library("sapFinder")
browseVignettes("sapFinder")
vcf <- system.file("extdata/sapFinder_test.vcf",
                   package="sapFinder")
annotation <- system.file("extdata/sapFinder_test_ensGene.txt",
                          package="sapFinder")
refseq <- system.file("extdata/sapFinder_test_ensGeneMrna.fa",
                      package="sapFinder")
outdir <- "db_dir"
prefix <- "sapFinder_test"
db.files <- dbCreator(vcf=vcf, annotation=annotation,
                      refseq=refseq, outdir=outdir,prefix=prefix)


#DEMO

#load data

#KEGG view: gene data only
i <- 1
pv.out <- pathview(gene.data = gse16873.d[, 1], pathway.id =
                     demo.paths$sel.paths[i], species = "hsa", out.suffix = "gse16873",
                   kegg.native = TRUE)
str(pv.out)
head(pv.out$plot.data.gene)
#result PNG file in current directory

#Graphviz view: gene data only
data(gse16873.d)
data(demo.paths)
pv.out <- pathview(gene.data = gse16873.d[, 1], pathway.id = demo.paths$sel.paths[i], species = "hsa", out.suffix = "gse16873",kegg.native = FALSE, sign.pos = demo.paths$spos[i])
#result PDF file in current directory

png('test.png')
plot(sin(seq(-10,10,0.1)),type = "l", cex = .1, col = "dark red")
dev.off()

?plot

# from Luo
hda=as.matrix(hda)
hda.d=hda[,1:3]-hda[,4:6]
pathview(hda.d,pathway.id="hsa03410",gene.idtype="UNIPROT", limit = list(gene = 5, cpd = 1), out.suffix="fc")

## PCA
data=read.csv("L:/Elite/gaute/test/SHBER.csv")
gene=as.character(data[,1])
data=data[,-1]
prco=prcomp(data)
sco <- prco$x
loa <- prco$rotation
plot(sco[,1], sco[,2], col=row.names(data))
plot(loa[,1], loa[,2], col=row.names(data))
     

library(org.Hs.eg.db)
egmap <- revmap(org.Hs.egUNIPROT)[as.character(gene)]

x <- org.Hs.egGO
mapped_genes <- mappedkeys(x)
xx <- as.list(x[mapped_genes])
goids <- xx[2:3]
names(goids[[1]])

mod <- prcomp(E)

## scores (sample space)
scores <- mod$x
## loadings (gene space)
loads <- mod$rotation

## gene symbols
sym <- as.character(mget(colnames(E), illuminaHumanv3SYMBOL))

# plot
pc1 = 1 # ok, checked
pc2 = 2
# score plot (sample space)
x11()
expVar <- 100 *mod$sdev / sum(mod$sdev) 
hist(expVar)
plot(scores[,pc1], scores[,pc2], col=cl, pch=19, main="Score-plot (Sample map)", xlab=paste("PC:", expVar[pc1]), ylab=paste("PC:", expVar[pc2]))
text(scores[,pc1], scores[,pc2], rownames(E), pos=3)


# loadings (gene space)
plot.factor.name <- "lrT - T"
col <- factor(a[,plot.factor.name])
plot(loads[,pc1], loads[,pc2], col=col, pch='.', main="Gene weights", xlab=paste("PC:", expVar[pc1]), ylab=paste("PC:", expVar[pc2]))
text(loads[,pc1], loads[,pc2], sym, pos=3, cex=0.4)



# extract a quad 
kk <- loads[,pc1] > 0 & loads[,pc2] > 0
plot(kk)


# GO mapping
x <- org.Hs.egGO
mapped_genes <- mappedkeys(x)
xx <- as.list(x[mapped_genes])
goids <- xx[2:3]
names(goids[[1]])


