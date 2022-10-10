#setup####
#sudo apt install gfortran libblas-dev liblapack-dev
options(nwarnings = 1000000)
summary(warnings(1000000))
set.seed(42)
dirLocal <- getwd()
libLocal <- paste(dirLocal,"rLib",sep="/")
reposLibLocal="http://cran.us.r-project.org"
install.packages("infotheo", lib = libLocal, repos = reposLibLocal)
install.packages("BiocManager", lib = libLocal, repos = reposLibLocal)
library("BiocManager", lib = libLocal, repos = reposLibLocal)
BiocManager::install("GenomicRanges", lib = libLocal, repos = reposLibLocal)
BiocManager::install("MatrixGenerics", lib = libLocal, repos = reposLibLocal)
BiocManager::install("matrixStats", lib = libLocal, repos = reposLibLocal)
BiocManager::install("SummarizedExperiment", lib = libLocal, repos = reposLibLocal)
BiocManager::install("lionessR", lib = libLocal, repos = reposLibLocal)
BiocManager::install("igraph", lib = libLocal, repos = reposLibLocal)
BiocManager::install("limma", lib = libLocal, repos = reposLibLocal)
BiocManager::install("reshape2", lib = libLocal, repos = reposLibLocal)
library("infotheo", lib = libLocal)
library("matrixStats", lib = libLocal)
library("GenomicRanges", lib = libLocal)
library("MatrixGenerics", lib = libLocal)
library("SummarizedExperiment", lib = libLocal)
library("lionessR", lib = libLocal)
library("igraph", lib = libLocal)
library("limma", lib = libLocal)
library("reshape2", lib = libLocal)
#data####
M <- read.csv("C:\\Users\\animeshs\\OneDrive - NTNU\\Singh\\dataTmmS42.csv", header = T, row.names = 1)
#select####
cvar <- apply(as.array(as.matrix(M)), 1, sd)
# https://github.com/orgs/community/discussions/26316 for plot , unblock cookies
hist(cvar)
dat <- cbind(cvar, M)
dat <- dat[order(dat[, 1], decreasing = T), ]
dat <- dat[cvar > 1, -1]
dat <- as.matrix(dat)
dat <- as.matrix(M)
dim(dat)
hist(dat)
summary(dat)
rN <- rownames(dat)
cN <- colnames(dat)
#MI####
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
cormat <- lioness(dat, netFunMI)
cormat <- lioness(dat, netFun)
netFunS<-function(x, ...) { stats::cor(t(x), method = "spearman")}
cormat <- lioness(dat, netFunS)
netFunMI <- function(x, ...) { mutinformation(discretize(t(x), disc = "equalwidth", nbins = 100), method = "emp")}
dim(datDisc)
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
fName<-gsub("[^[:alnum:]]", "", strsplit(as.character(list(netFunS))," "))#[[1]][7:10])
saveRDS(cormat,paste0(dirLocal,fName,".cormat.RDS"))
saveRDS(cormat,"C:\\Users\\animeshs\\OneDrive - NTNU\\Singh\\cfunctionxnnstatscortxmethodspearmann.cormat.RDS")
cormat<-readRDS("C:\\Users\\animeshs\\OneDrive - NTNU\\Singh\\cfunctionxnnmutinformationdiscretizetxdiscequalwidthnbins100methodempn.cormat.RDS")
head(cormat)
z <- cormat@assays@data[[1]]
rownames(z) <- rownames(cormat)
head(z)
toptable_edges <- t(matrix(unlist(c(strsplit(row.names(z), "_"))), 2))
head(toptable_edges)
tail(toptable_edges)
z1 <- cbind(toptable_edges, z)
head(z1)
plot(z1[2,])
#sampleN####
## label sample group names
sampleN <- c('MGUS1','MGUS2','MGUS3','MGUS4','MGUS5','MGUS6','MGUS7','MGUS8','MGUS9','Ml1','Ml2','Ml3','Ml4','Ml5','Ml6','MM7','MM8','MM9','MM10','MM11','MM12','MM13','MM14','MM15','MM16','MM17','MM18','MM19','MM20','MM21','MM22','MM23','MM24','MM25','MM26','MM27','MM28','MM29','MM30','MM31','MM32','MM33','MM34','MM35','MM36','MM37')
grpSample <- c('MGUS','MGUS','MGUS','MGUS','MGUS','MGUS','MGUS','MGUS','MGUS','Ml','Ml','Ml','Ml','Ml','Ml','MM','MM','MM','MM','MM','MM','MM','MM','MM','MM','MM','MM','MM','MM','MM','MM','MM','MM','MM','MM','MM','MM','MM','MM','MM','MM','MM','MM','MM','MM','MM')
## add matching sample names in trait object
trait<-data.frame(cbind(sampleN,grpSample))
head(trait)
dim(M)
colnames(M) <- sampleN
#[1] 3956   46
head(M)
#sampleMM####
datMM<-data.frame(M[,trait$grpSample == "MM"])
summary(datMM)
dim(datMM)
nsel = nrow(M)
#nsel <- 500
cvar <- apply(as.array(as.matrix((datMM))), 1, sd)
sum(cvar==0)
length(cvar)
hist(cvar)
datMM <- cbind(cvar, datMM)
datMM <- datMM[order(datMM[,1], decreasing=F),]
#datMM <- datMM[cvar>0, -1]
datMM <- datMM[1:nsel, -1]
datMM <- as.matrix(datMM)
summary(datMM)
dim(datMM)
hist(datMM)
sum(datMM==0)
netyes <- cor(t(datMM))
summary(warnings())
dim(netyes)
hist(netyes)
#sampleMGUS####
datMG<-M[,trait$grpSamp == "MGUS"]
summary(datMG)
cvar <- apply(as.array(as.matrix((datMG))), 1, sd)
sum(cvar==0)
hist(cvar)
datMG <- cbind(cvar, datMG)
datMG <- datMG[order(datMG[,1], decreasing=F),]
#datMG <- datMG[cvar>0, -1]
datMG <- datMG[1:nsel, -1]
datMG <- as.matrix(datMG)
summary(datMG)
dim(datMG)
netno  <- cor(t(datMG))
summary(warnings())
dim(netno)
hist(netno)
netdiff <- netyes-netno
hist(netdiff)
dim(netdiff)
zeroDiff=netdiff==0
sum(zeroDiff)
## convert these adjacency matrices to edgelists
#rep(1:3,nsel)
cormat2 <- rep(1:nsel, each=nsel)
cormat1 <- rep(1:nsel,nsel)
el      <- cbind(cormat1, cormat2, c(netdiff))
hist(el[,3])
melted  <- melt(upper.tri(netdiff))
summary(melted)
melted  <- melted[which(melted$value),]
values  <- netdiff[which(upper.tri(netdiff))]
melted  <- cbind(melted[,1:2], values)
summary(melted)
genes   <- row.names(netdiff)
melted[,1] <- genes[melted[,1]]
melted[,2] <- genes[melted[,2]]
row.names(melted) <- paste(melted[,1], melted[,2], sep="_")
tosub <- melted
hist(tosub[,3])
length(tosub[,3])
corThr<-1
tosel <- row.names(tosub[which(abs(tosub[,3])>corThr),])
length(tosel)
corsub <- cormat[which(row.names(cormat)  %in% tosel) ,]
CC <- corsub@assays@data[[1]]
rownames(CC) <- rownames(corsub)
head(CC)
hist(CC)
dim(CC)
group <- factor(trait[,2])
design <- model.matrix(~0+group)
cont.matrix <- makeContrasts(yesvsno = (groupMM - groupMGUS), levels = design)
fit <- lmFit(CC, design)
fit2 <- contrasts.fit(fit, cont.matrix)
fit2e <- eBayes(fit2)
toptable <- topTable(fit2e, number=nrow(CC), adjust.method="fdr")
head(toptable,10)
hist(toptable$logFC)
hist(toptable$P.Value)
hist(toptable$adj.P.Val)
hist(toptable$t)
summary(toptable$t)
toptable_edges <- t(matrix(unlist(c(strsplit(row.names(toptable), "_"))),2))
N <- nrow(CC)
N<-100
z <- cbind(toptable_edges[1:N,], as.data.frame(toptable$logFC[1:N]))
fdrThr<-0.1
z <- cbind(toptable_edges[toptable$adj.P.Val<fdrThr,], as.data.frame(toptable$logFC[toptable$adj.P.Val<fdrThr]))
summary(z)
hist(z[,3])
tThr<-5
z <- cbind(toptable_edges[abs(toptable$t)>tThr,], as.data.frame(toptable$logFC[abs(toptable$t)>tThr]))
summary(z)
hist(z[,3])
#z <- z[abs(z[,3]) > 1.5, ]
g <- graph.data.frame(z, directed=F)
cl <- components(g)
ccG<-lapply(seq_along(cl$csize)[cl$csize > 2], function(x) V(g)$name[cl$membership %in% x])
length(ccG)
ccG
ccG1<-ccG[[1]]
labelOffset <- strwidth(names(V(g)),units = 'in')
vertex.label.dist = labelOffset*2.6
E(g)$weight <- abs(z[,3])
tt <- unlist(ccG)
tt <- tt[34:length(ccG)]
g <- delete_vertices(g, tt)
plot(g)
E(g)$weight<- as.numeric(z[,3])
E(g)$color[E(g)$weight<0] <- "blue"
E(g)$color[E(g)$weight>0] <- "red"
plot(g, vertex.label.cex=0.7,
     vertex.size=6,
     vertex.label.color = "black",
     vertex.label.font=3, vertex.label.dist = labelOffset*1.6,
     edge.width=10*(abs(as.numeric(z[,3]))-0.7),
     vertex.color=V(g)$color,
     layout = layout_as_tree)
#(g)
#Next, we perform a LIMMA analysis on gene expression so that we can also color nodes based on their differential expression:

topgeneslist <- unique(c(toptable_edges[1:N,]))
fit <- lmFit(M, design)
fit2 <- contrasts.fit(fit, cont.matrix)
fit2e <- eBayes(fit2)
topDE <- topTable(fit2e, number=nrow(M), adjust="fdr")
hist(topDE$logFC)
topDE <- topDE[which(row.names(topDE) %in% topgeneslist),]
topgenesDE <- cbind(row.names(topDE), topDE$t)
hist(as.numeric(topgenesDE))
#We color nodes based on the t-statistic from the LIMMA analysis:

# add t-statistic to network nodes
nodeorder <- cbind(V(g)$name, 1:length(V(g)))
nodes <- merge(nodeorder, topgenesDE, by.x=1, by.y=1)
nodes <- nodes[order(as.numeric(as.character(nodes[,2]))),]
nodes[,3] <- as.numeric(as.character(nodes[,3]))
nodes <- nodes[,-2]
V(g)$weight <- nodes[,2]

# make a color palette
mypalette4 <- colorRampPalette(c("blue","white","white","red"), space="Lab")(256)
breaks2a <- seq(min(V(g)$weight), 0, length.out=128)
breaks2b <- seq(0.00001, max(V(g)$weight)+0.1,length.out=128)
breaks4 <- c(breaks2a,breaks2b)

# select bins for colors
bincol <- rep(NA, length(V(g)))
for(i in 1:length(V(g))){
  bincol[i] <- min(which(breaks4>V(g)$weight[i]))
}
bincol <- mypalette4[bincol]

# add colors to nodes
V(g)$color <- bincol
par(mar=c(0,0,0,0))
plot(g, vertex.label.cex=0.7, vertex.size=6,
     vertex.label.color = "black",
     vertex.label.font=3,
     edge.width=10*(abs(as.numeric(z[,3]))-0.7), vertex.color=V(g)$color)
#plot(simplify(g)) # remove loops and multiple edges
#plot(delete.vertices(simplify(g))) # additionally delete isolated nodes
#sampleMl####
datMl<-M[,trait$grpSamp == "Ml"]
summary(datMl)
cvar <- apply(as.array(as.matrix((datMl))), 1, sd)
sum(cvar==0)
hist(cvar)
datMl <- cbind(cvar, datMl)
datMl <- datMl[order(datMl[,1], decreasing=F),]
#datMl <- datMl[cvar>0, -1]
datMl <- datMl[1:nsel, -1]
datMl <- as.matrix(datMl)
summary(datMl)
dim(datMl)
netno  <- cor(t(datMl))
summary(warnings())
dim(netno)
hist(netno)
netdiff <- netyes-netno
hist(netdiff)
dim(netdiff)
zeroDiff=netdiff==0
sum(zeroDiff)
## convert these adjacency matrices to edgelists
#rep(1:3,nsel)
cormat2 <- rep(1:nsel, each=nsel)
cormat1 <- rep(1:nsel,nsel)
el      <- cbind(cormat1, cormat2, c(netdiff))
hist(el[,3])
melted  <- melt(upper.tri(netdiff))
summary(melted)
melted  <- melted[which(melted$value),]
values  <- netdiff[which(upper.tri(netdiff))]
melted  <- cbind(melted[,1:2], values)
summary(melted)
genes   <- row.names(netdiff)
melted[,1] <- genes[melted[,1]]
melted[,2] <- genes[melted[,2]]
row.names(melted) <- paste(melted[,1], melted[,2], sep="_")
tosub <- melted
hist(tosub[,3])
length(tosub[,3])
corThr<-1
tosel <- row.names(tosub[which(abs(tosub[,3])>corThr),])
length(tosel)
corsub <- cormat[which(row.names(cormat)  %in% tosel) ,]
CC <- corsub@assays@data[[1]]
rownames(CC) <- rownames(corsub)
head(CC)
hist(CC)
dim(CC)
group <- factor(trait[,2])
design <- model.matrix(~0+group)
cont.matrix <- makeContrasts(yesvsno = (groupMM - groupMl), levels = design)
fit <- lmFit(CC, design)
fit2 <- contrasts.fit(fit, cont.matrix)
fit2e <- eBayes(fit2)
toptable <- topTable(fit2e, number=nrow(CC), adjust.method="fdr")
head(toptable,10)
hist(toptable$logFC)
hist(toptable$P.Value)
hist(toptable$adj.P.Val)
hist(toptable$t)
summary(toptable$t)
toptable_edges <- t(matrix(unlist(c(strsplit(row.names(toptable), "_"))),2))
N <- nrow(CC)
N<-100
z <- cbind(toptable_edges[1:N,], as.data.frame(toptable$logFC[1:N]))
fdrThr<-0.1
z <- cbind(toptable_edges[toptable$adj.P.Val<fdrThr,], as.data.frame(toptable$logFC[toptable$adj.P.Val<fdrThr]))
summary(z)
hist(z[,3])
tThr<-5
z <- cbind(toptable_edges[abs(toptable$t)>tThr,], as.data.frame(toptable$logFC[abs(toptable$t)>tThr]))
summary(z)
hist(z[,3])
#z <- z[abs(z[,3]) > 1.5, ]
g <- graph.data.frame(z, directed=F)
cl <- components(g)
ccG<-lapply(seq_along(cl$csize)[cl$csize > 2], function(x) V(g)$name[cl$membership %in% x])
length(ccG)
ccG
ccG1<-ccG[[1]]
labelOffset <- strwidth(names(V(g)),units = 'in')
vertex.label.dist = labelOffset*2.6
E(g)$weight <- abs(z[,3])
tt <- unlist(ccG)
tt <- tt[34:length(ccG)]
g <- delete_vertices(g, tt)
plot(g)
E(g)$weight <- as.numeric(z[,3])
E(g)$color[E(g)$weight<0] <- "blue"
E(g)$color[E(g)$weight>0] <- "red"
plot(g, vertex.label.cex=0.7,
     vertex.size=6,
     vertex.label.color = "black",
     vertex.label.font=3, vertex.label.dist = labelOffset*1.6,
     edge.width=10*(abs(as.numeric(z[,3]))-0.7),
     vertex.color=V(g)$color,
     layout = layout_as_tree)
#(g)
#Next, we perform a LIMMA analysis on gene expression so that we can also color nodes based on their differential expression:

topgeneslist <- unique(c(toptable_edges[1:N,]))
fit <- lmFit(M, design)
fit2 <- contrasts.fit(fit, cont.matrix)
fit2e <- eBayes(fit2)
topDE <- topTable(fit2e, number=nrow(M), adjust="fdr")
hist(topDE$logFC)
topDE <- topDE[which(row.names(topDE) %in% topgeneslist),]
topgenesDE <- cbind(row.names(topDE), topDE$t)
hist(as.numeric(topgenesDE))
#We color nodes based on the t-statistic from the LIMMA analysis:

# add t-statistic to network nodes
nodeorder <- cbind(V(g)$name, 1:length(V(g)))
nodes <- merge(nodeorder, topgenesDE, by.x=1, by.y=1)
nodes <- nodes[order(as.numeric(as.character(nodes[,2]))),]
nodes[,3] <- as.numeric(as.character(nodes[,3]))
nodes <- nodes[,-2]
V(g)$weight <- nodes[,2]
mypalette4 <- colorRampPalette(c("blue","white","white","red"), space="Lab")(256)
breaks2a <- seq(min(V(g)$weight), 0, length.out=128)
breaks2b <- seq(0.00001, max(V(g)$weight)+0.1,length.out=128)
breaks4 <- c(breaks2a,breaks2b)
bincol <- rep(NA, length(V(g)))
for(i in 1:length(V(g))){
  bincol[i] <- min(which(breaks4>V(g)$weight[i]))
}
bincol <- mypalette4[bincol]
V(g)$color <- bincol
par(mar=c(0,0,0,0))
plot(g, vertex.label.cex=0.7, vertex.size=6,
     vertex.label.color = "black",
     vertex.label.font=3,
     edge.width=10*(abs(as.numeric(z[,3]))-0.7), vertex.color=V(g)$color)
#sampleMLMG####
netyes  <- cor(t(datMl))
netno  <- cor(t(datMG))
summary(warnings())
netdiff <- netyes-netno
hist(netdiff)
dim(netdiff)
zeroDiff=netdiff==0
sum(zeroDiff)
## convert these adjacency matrices to edgelists
#rep(1:3,nsel)
cormat2 <- rep(1:nsel, each=nsel)
cormat1 <- rep(1:nsel,nsel)
el      <- cbind(cormat1, cormat2, c(netdiff))
hist(el[,3])
melted  <- melt(upper.tri(netdiff))
summary(melted)
melted  <- melted[which(melted$value),]
values  <- netdiff[which(upper.tri(netdiff))]
melted  <- cbind(melted[,1:2], values)
summary(melted)
genes   <- row.names(netdiff)
melted[,1] <- genes[melted[,1]]
melted[,2] <- genes[melted[,2]]
row.names(melted) <- paste(melted[,1], melted[,2], sep="_")
tosub <- melted
hist(tosub[,3])
length(tosub[,3])
corThr<-1
tosel <- row.names(tosub[which(abs(tosub[,3])>corThr),])
length(tosel)
corsub <- cormat[which(row.names(cormat)  %in% tosel) ,]
CC <- corsub@assays@data[[1]]
rownames(CC) <- rownames(corsub)
head(CC)
hist(CC)
dim(CC)
group <- factor(trait[,2])
design <- model.matrix(~0+group)
cont.matrix <- makeContrasts(yesvsno = (groupMl - groupMGUS), levels = design)
fit <- lmFit(CC, design)
fit2 <- contrasts.fit(fit, cont.matrix)
fit2e <- eBayes(fit2)
toptable <- topTable(fit2e, number=nrow(CC), adjust.method="fdr")
head(toptable,10)
hist(toptable$logFC)
hist(toptable$P.Value)
hist(toptable$adj.P.Val)
hist(toptable$t)
summary(toptable$t)
toptable_edges <- t(matrix(unlist(c(strsplit(row.names(toptable), "_"))),2))
N <- nrow(CC)
N<-100
z <- cbind(toptable_edges[1:N,], as.data.frame(toptable$logFC[1:N]))
fdrThr<-0.1
z <- cbind(toptable_edges[toptable$adj.P.Val<fdrThr,], as.data.frame(toptable$logFC[toptable$adj.P.Val<fdrThr]))
summary(z)
hist(z[,3])
tThr<-5
z <- cbind(toptable_edges[abs(toptable$t)>tThr,], as.data.frame(toptable$logFC[abs(toptable$t)>tThr]))
summary(z)
hist(z[,3])
#z <- z[abs(z[,3]) > 1.5, ]
g <- graph.data.frame(z, directed=F)
cl <- components(g)
ccG<-lapply(seq_along(cl$csize)[cl$csize > 2], function(x) V(g)$name[cl$membership %in% x])
length(ccG)
ccG
ccG1<-ccG[[1]]
labelOffset <- strwidth(names(V(g)),units = 'in')
vertex.label.dist = labelOffset*2.6
E(g)$weight <- abs(z[,3])
tt <- unlist(ccG)
tt <- tt[34:length(ccG)]
g <- delete_vertices(g, tt)
plot(g)
E(g)$weight <- as.numeric(z[,3])
E(g)$color[E(g)$weight<0] <- "blue"
E(g)$color[E(g)$weight>0] <- "red"
plot(g, vertex.label.cex=0.7,
     vertex.size=6,
     vertex.label.color = "black",
     vertex.label.font=3, vertex.label.dist = labelOffset*1.6,
     edge.width=10*(abs(as.numeric(z[,3]))-0.7),
     vertex.color=V(g)$color,
     layout = layout_as_tree)
#(g)
#Next, we perform a LIMMA analysis on gene expression so that we can also color nodes based on their differential expression:

topgeneslist <- unique(c(toptable_edges[1:N,]))
fit <- lmFit(M, design)
fit2 <- contrasts.fit(fit, cont.matrix)
fit2e <- eBayes(fit2)
topDE <- topTable(fit2e, number=nrow(M), adjust="fdr")
hist(topDE$logFC)
topDE <- topDE[which(row.names(topDE) %in% topgeneslist),]
topgenesDE <- cbind(row.names(topDE), topDE$t)
hist(as.numeric(topgenesDE))
#We color nodes based on the t-statistic from the LIMMA analysis:

# add t-statistic to network nodes
nodeorder <- cbind(V(g)$name, 1:length(V(g)))
nodes <- merge(nodeorder, topgenesDE, by.x=1, by.y=1)
nodes <- nodes[order(as.numeric(as.character(nodes[,2]))),]
nodes[,3] <- as.numeric(as.character(nodes[,3]))
nodes <- nodes[,-2]
V(g)$weight <- nodes[,2]
mypalette4 <- colorRampPalette(c("blue","white","white","red"), space="Lab")(256)
breaks2a <- seq(min(V(g)$weight), 0, length.out=128)
breaks2b <- seq(0.00001, max(V(g)$weight)+0.1,length.out=128)
breaks4 <- c(breaks2a,breaks2b)
bincol <- rep(NA, length(V(g)))
for(i in 1:length(V(g))){
  bincol[i] <- min(which(breaks4>V(g)$weight[i]))
}
bincol <- mypalette4[bincol]
V(g)$color <- bincol
par(mar=c(0,0,0,0))
plot(g, vertex.label.cex=0.7, vertex.size=6,
     vertex.label.color = "black",
     vertex.label.font=3,
     edge.width=10*(abs(as.numeric(z[,3]))-0.7), vertex.color=V(g)$color)
#personNet####
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
#save####
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
