#setup####
#sudo apt install gfortran libblas-dev liblapack-dev
dirLocal <- "/home/ash022/scripts/Singh/"
libLocal <- paste0(dirLocal,"rLib")
install.packages("infotheo", lib = libLocal)
install.packages("BiocManager", lib = libLocal)
BiocManager::install("GenomicRanges", lib = libLocal)
BiocManager::install("MatrixGenerics", lib = libLocal)
BiocManager::install("matrixStats", lib = libLocal)
BiocManager::install("SummarizedExperiment", lib = libLocal)
BiocManager::install("lionessR", lib = libLocal)
BiocManager::install("igraph", lib = libLocal)
library("infotheo", lib = libLocal)
library("matrixStats", lib = libLocal)
library("GenomicRanges", lib = libLocal)
library("MatrixGenerics", lib = libLocal)
library("SummarizedExperiment", lib = libLocal)
library("lionessR", lib = libLocal)
library("igraph", lib = libLocal)
options(nwarnings = 1000000)
summary(warnings(1000000))
#data####
M <- read.csv(paste0(dirLocal,"dataTmm.csv"), header = T, row.names = 1)
#select####
cvar <- apply(as.array(as.matrix(M)), 1, sd)
# https://github.com/orgs/community/discussions/26316 for plot , unblock cookies
hist(cvar)
dat <- cbind(cvar, M)
dat <- dat[order(dat[, 1], decreasing = T), ]
dat <- dat[cvar > 1, -1]
dat <- as.matrix(dat)
# dat <- as.matrix(M)
dim(dat)
hist(dat)
summary(dat)
rN <- rownames(dat)
cN <- colnames(dat)
#MI####
library("infotheo")
datDisc <- discretize(t(dat), disc = "equalwidth", nbins = 100)
summary(datDisc)
rownames(datDisc) <- cN
colnames(datDisc) <- rN
summary(datDisc)
hist(sapply(datDisc,as.numeric))
datDiscMI <- mutinformation(datDisc, method = "emp")
summary(datDiscMI)
hist(datDiscMI)
#lioness####
# https://github.com/mararie/lionessR/blob/master/vignettes/lionessR.Rmd
library(lionessR) # , help, pos = 2, lib.loc = NULL)
netFunMI <- function(x, ...) { mutinformation(discretize(t(x), disc = "equalwidth", nbins = 100), method = "emp")}
dim(datDisc)
cormat <- lioness(dat, netFunMI)
#cormat <- lioness(dat, netFun)
summary(warnings(1000000))
dim(cormat)
cData <- cormat@assays@data[[1]]
rownames(cData) <- rownames(cormat)
dim(cData)
head(cData)
hist(cData)
cData <- cData[abs(cData[, 3]) > 1.44, ]
hist(cData)
edgeCdata <- t(matrix(unlist(c(strsplit(row.names(cData), "_"))), 2))
# edgeCdata <- unlist(c(strsplit(row.names(cData), "_")))
tail(edgeCdata)
z <- cbind(edgeCdata, cData)
head(z)
plot(z[2,])
g <- igraph::graph.data.frame(g, directed = F)
# plot(g)
dg <- igraph::degree(g)
sortDG <- sort.int(dg, decreasing = T, index.return = F)
max(sortDG)
min(sortDG)
plot(sortDG)
hist(sortDG)
head(sortDG, 25)
tail(sortDG, 25)
netFunMI <- netFun
cormat <- lioness(dat, netFunMI)
net <- stats::cor(t(dat))
agg <- c(net)
nrsamples <- ncol(dat)
samples <- colnames(dat)
lionessOutput <- matrix(NA, nrow(net)*ncol(net), nrsamples+2)
colnames(lionessOutput) <- c("reg", "tar", samples)
lionessOutput[,1] <- rep(row.names(net), ncol(net))
lionessOutput[,2] <- rep(colnames(net), each=nrow(net))
lionessOutput <- as.data.frame(lionessOutput, stringsAsFactors=F)
lionessOutput[,3:ncol(lionessOutput)] <- sapply(lionessOutput[,3:ncol(lionessOutput)], as.numeric)
#sample1####
ss <- c(stats::cor(t(dat[,-1])))
summary(ss)
lionessOutput[,1+2] <- nrsamples*(agg-ss)+ss
summary(lionessOutput[,1+2])
fName<-gsub("[^[:alnum:]]", "", strsplit(as.character(list(netFunMI))," "))#[[1]][7:10])
saveRDS(cormat,paste0(dirLocal,fName,".cormat.RDS"))
head(cormat)
z <- cormat@assays@data[[1]]
rownames(z) <- rownames(cormat)
head(z)
toptable_edges <- t(matrix(unlist(c(strsplit(row.names(z), "_"))), 2))
head(toptable_edges)
#sampleN####
chkGene <- "LAGE3"
for (patients in 1:ncol(z)) {
    print(paste0("patient", patients, chkGene))
    z1 <- cbind(toptable_edges, data.frame(z[, patients]))
    z2 <- z1[abs(z1[, 3]) > 1, ]
    g <- graph.data.frame(z2, directed = F)
    dg <- degree(g)
    print(summary(dg))
    dg_max <- sort.int(dg, decreasing = T, index.return = FALSE)
    dg_df <- as.matrix(dg_max)
    print(dg_df[rownames(dg_df) == chkGene])
    print(head(dg_df))
    save(g, file = paste0("patient", patients, ".MI.RData"))
    write.csv(dg_df, file = paste0("patient", patients, ".MI.csv"))
}
summary(warnings(1000000))
savehistory(file = "setup.Rhistory")
#python####
import pandas as pd
pathDir="C:/Users/animeshs/OneDrive - NTNU/Singh/"
data=pd.read_csv(pathDir+"dataTmm.csv")
mapping = {'G':0,'M':1,'L':0}
data=data.replace({'Group': mapping})
#data=data[data["Group"] != -1]
print(data["Group"])
print ("Data for Modeling :" + str(data.shape))
dat=data.iloc[:,1:47]
datCor=dat.T.corr()
datX1=data.iloc[:,2:47]
datCorX1=datX1.T.corr()
lionessX1=46*(datCor-datCorX1)+datCorX1
lionessX1.iloc[-1,-2]
#matlab####
fo='L:\OneDrive - NTNU\Singh\dataTmm.csv';
data=readtable(fo);
IDX=[1];%Uniprots, Gene Name, Fasta header
sdx=2;
edx=47;
rep=1;
log2data=(table2array(data(:,sdx:edx)));
log2ctr=log2data(:,[1:ceil((edx-sdx+1)/rep):size(log2data,2)]);
log2ctr=repelem(log2ctr,1,ceil((edx-sdx+1)/rep));
log2data=log2data-log2ctr;
log2data(log2data==0)=NaN;
hist(log2data)
pearsonClog2data=corrcoef(log2data.');
hist(pearsonClog2data)
pearsonClog2dataX1=corrcoef(log2data(:,2:end).');
lionessOutputX1 = 46*(pearsonClog2data-pearsonClog2dataX1)+pearsonClog2dataX1;
