## source template from Arnar Flatberg
#source("http://bioconductor.org/biocLite.R")
#biocLite("BiocUpgrade")
#biocLite("illuminaHumanv3.db")
#biocLite("lumi")
#biocLite("limma")
#install.packages("pls")
#install.packages("RCurl")
#.libPaths()
#remove.packages('limma')
#detach(package:limma, unload=TRUE)
library(lumi) 
library(limma) 
library(stringr)
library(illuminaHumanv3.db) 

source("http://bioconductor.org/biocLite.R")
biocLite("limma")

data <- lumiR('L:/Elite/kamila/GRC-2010-191-Slupphaug-redo/data/GRC-2010-191-Slupphaug_Sample_Probe_Profile.txt', convertNuID=FALSE, inputAnnotation=FALSE, QC=FALSE)


# normalize and write csv 
dataN <- lumiN(data)
write.table(dataN,file="dataN.txt")
dataNQ <- lumiExpresso(data)
write.exprs(dataNQ, file='dataNQ.txt')

desc <- read.csv('L:/Elite/kamila/GRC-2010-191-Slupphaug-redo/data/GRC-2010-191-Slupphaug_SampleSheet.csv', skip=7, header=TRUE)
sids <- as.character(desc[,1])
rownames(desc) <- sids
data <- data[,sids] # ensure data is in same order as phenodata

ctFn <- 'L:/Elite/kamila/GRC-2010-191-Slupphaug-redo/data/GRC-2010-191-Slupphaug_TableControl.txt'
##data <- addControlData2lumi(ctFn, data) # did not work ## add controldata to Expressionset

ids <- featureNames(data)
probes <- unlist(mget(ids, revmap(illuminaHumanv3ARRAYADDRESS), ifnotfound=NA))
isna <- is.na(probes)

sum(isna==FALSE)
  if (sum(isna) != length(probes)){
      if (any(isna)){
          keep <- isna == FALSE
          data <- data[keep,]
          probes <- probes[keep]
      }
      featureNames(data) <- probes
  }
  fData(data)$ProbeID <- probes
  featureNames(data) <- probes

annotation(data) <- "illuminaHumanv3"


### Initial QC.

x11(); plot(data, what="density")
x11(); plot(data, what="sampleRelation")
x11(); plot(data, what="boxplot")


  data.0 <- data
  presentLim <- 2
  present <- detectionCall(data, Th=0.01, "probe")
  #probe.quality <- unlist(mget(as.character(featureNames(data)), illuminaHumanv4PROBEQUALITY))
  #good.quality <- !((probe.quality == "Bad") | (probe.quality == "No match"))
  keepProbes <- (present >= presentLim)
  data <- data[keepProbes,]

  ## use gene level analysis
    require(genefilter)
    data <- nsFilter(data, var.filter=FALSE)$eset ## aggregate across entrezID annotated probes

remove <- grep("light|heavy", sampleNames(data))
data <- data[,-remove]
desc <- data[-remove, ]

# variance transform
data.T <- lumiT(data, "log2")

# between array normalization
data.N <- lumiN(data.T, "quantile")


#############################################
### Exploratory analysis.
#############################################
## Effect of treatment
nn <- sampleNames(data.N)
cl <- nn
cl[grep("treated", nn)] <- "T"
cl[grep("control", nn)] <- "C"
cl[grep("LR5_treated", nn)] <- "lrT"
cl[grep("LR5_cont", nn)] <- "lrC"
cl <- as.factor(cl)


#############################################
### PCA
#############################################
##source(file.path(sourcePath, "QualPlot.R"))

#############################################
### PLS
#############################################


#############################################
### Differentially expressed genes, limma
#############################################

des <- model.matrix(~-1+cl)
colnames(des) <- levels(cl)
fit <- lmFit(data.N, design=des, method="ls")

cmat <- makeContrasts(lrT - T, 
                      lrC - C, 
                      levels=des)
fit2 <- contrasts.fit(fit, cmat)
fit2 <- eBayes(fit2)
a <- decideTests(fit2, adjust.method="fdr",p.value=0.05,lfc = 0)


#############################################
### Post analysis
#############################################

topTable(fit2)

#install.packages('xlsReadWrite')
#library('WriteXLS')

write.csv(fit2,"o.csv")

############################################
### PCA
#############################################

# data
E <- t(exprs(data.N))


## pca model
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


