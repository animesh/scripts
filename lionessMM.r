#setup####
libLocal <- "/home/ash022/scripts/MM/rLib"
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
M <- read.csv("/home/ash022/scripts/MM/dataTmm.csv", header = T, row.names = 1)
dat <- as.matrix(M)
summary(dat)

MI####
netFunMI <- function(x, ...) {
    mutinformation(dinfotheoiscretize(t(x), disc = "equalwidth", nbins = 100), method = "emp")
}
cormat <- lioness(dat, netFunMI)
head(cormat)
z <- cormat@assays@data[[1]]
rownames(z) <- rownames(cormat)
head(z)
toptable_edges <- t(matrix(unlist(c(strsplit(row.names(z), "_"))), 2))
head(toptable_edges)

#setup####
libLocal <- "/home/ash022/scripts/MM/rLib"
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
M <- read.csv("/home/ash022/scripts/MM/dataTmm.csv", header = T, row.names = 1)
dat <- as.matrix(M)
summary(dat)

netFunMI <- function(x, ...) {
    mutinformation(discretize(t(x), disc = "equalwidth", nbins = 100), method = "emp")
}
cormat <- lioness(dat, netFunMI)
head(cormat)
z <- cormat@assays@data[[1]]
rownames(z) <- rownames(cormat)
head(z)
toptable_edges <- t(matrix(unlist(c(strsplit(row.names(z), "_"))), 2))
head(toptable_edges)

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
chkGene <- "LAGE3"
for (patients in 1:ncol(z)) {
    print(paste0("patient", patients, chkGene))
    z1 <- cbind(toptable_edges, data.frame(z[, patients]))
    z2 <- z1[abs(z1[, 3]) > 2, ]
    g <- graph.data.frame(z2, directed = F)
    dg <- degree(g)
    print(summary(dg))
    dg_max <- sort.int(dg, decreasing = T, index.return = FALSE)
    dg_df <- as.matrix(dg_max)
    print(dg_df[rownames(dg_df) == chkGene])
    print(head(dg_df))
    save(g, file = paste0("patient", patients, ".MI2.RData"))
    write.csv(dg_df, file = paste0("patient", patients, ".MI2.csv"))
}
summary(warnings(1000000))
savehistory(file = "setup.Rhistory")
chkGene <- "LAGE3"
for (patients in 1:ncol(z)) {
    print(paste0("patient", patients, chkGene))
    z1 <- cbind(toptable_edges, data.frame(z[, patients]))
    z2 <- z1[abs(z1[, 3]) > 3, ]
    g <- graph.data.frame(z2, directed = F)
    dg <- degree(g)
    print(summary(dg))
    dg_max <- sort.int(dg, decreasing = T, index.return = FALSE)
    dg_df <- as.matrix(dg_max)
    print(dg_df[rownames(dg_df) == chkGene])
    print(head(dg_df))
    save(g, file = paste0("patient", patients, ".MI3.RData"))
    write.csv(dg_df, file = paste0("patient", patients, ".MI3.csv"))
}
summary(warnings(1000000))
savehistory(file = "setup.Rhistory")
chkGene <- "LAGE3"
for (patients in 1:ncol(z)) {
    print(paste0("patient", patients, chkGene))
    z1 <- cbind(toptable_edges, data.frame(z[, patients]))
    z2 <- z1[abs(z1[, 3]) > 3.5, ]
    g <- graph.data.frame(z2, directed = F)
    dg <- degree(g)
    print(summary(dg))
    dg_max <- sort.int(dg, decreasing = T, index.return = FALSE)
    dg_df <- as.matrix(dg_max)
    print(dg_df[rownames(dg_df) == chkGene])
    print(head(dg_df))
    save(g, file = paste0("patient", patients, ".MI3.5.RData"))
    write.csv(dg_df, file = paste0("patient", patients, ".MI3.5.csv"))
}
summary(warnings(1000000))
savehistory(file = "setup.Rhistory")
chkGene <- "LAGE3"
for (patients in 1:ncol(z)) {
    print(paste0("patient", patients, chkGene))
    z1 <- cbind(toptable_edges, data.frame(z[, patients]))
    z2 <- z1[abs(z1[, 3]) > 5, ]
    g <- graph.data.frame(z2, directed = F)
    dg <- degree(g)
    print(summary(dg))
    dg_max <- sort.int(dg, decreasing = T, index.return = FALSE)
    dg_df <- as.matrix(dg_max)
    print(dg_df[rownames(dg_df) == chkGene])
    print(head(dg_df))
    save(g, file = paste0("patient", patients, ".MI5.RData"))
    write.csv(dg_df, file = paste0("patient", patients, ".MI5.csv"))
}
summary(warnings(1000000))
savehistory(file = "setup.Rhistory")
chkGene <- "LAGE3"
for (patients in 1:ncol(z)) {
    print(paste0("patient", patients, chkGene))
    z1 <- cbind(toptable_edges, data.frame(z[, patients]))
    z2 <- z1[abs(z1[, 3]) > 6, ]
    g <- graph.data.frame(z2, directed = F)
    dg <- degree(g)
    print(summary(dg))
    dg_max <- sort.int(dg, decreasing = T, index.return = FALSE)
    dg_df <- as.matrix(dg_max)
    print(dg_df[rownames(dg_df) == chkGene])
    print(head(dg_df))
    save(g, file = paste0("patient", patients, ".MI6.RData"))
    write.csv(dg_df, file = paste0("patient", patients, ".MI6.csv"))
}
summary(warnings(1000000))
savehistory(file = "setup.Rhistory")
chkGene <- "LAGE3"
for (patients in 1:ncol(z)) {
    print(paste0("patient", patients, chkGene))
    z1 <- cbind(toptable_edges, data.frame(z[, patients]))
    z2 <- z1[abs(z1[, 3]) > 10, ]
    g <- graph.data.frame(z2, directed = F)
    dg <- degree(g)
    print(summary(dg))
    dg_max <- sort.int(dg, decreasing = T, index.return = FALSE)
    dg_df <- as.matrix(dg_max)
    print(dg_df[rownames(dg_df) == chkGene])
    print(head(dg_df))
    save(g, file = paste0("patient", patients, ".MI10.RData"))
    write.csv(dg_df, file = paste0("patient", patients, ".MI10.csv"))
}
summary(warnings(1000000))
savehistory(file = "setup.Rhistory")
chkGene <- "LAGE3"
for (patients in 1:ncol(z)) {
    print(paste0("patient", patients, chkGene))
    z1 <- cbind(toptable_edges, data.frame(z[, patients]))
    z2 <- z1[abs(z1[, 3]) > 100, ]
    g <- graph.data.frame(z2, directed = F)
    dg <- degree(g)
    print(summary(dg))
    dg_max <- sort.int(dg, decreasing = T, index.return = FALSE)
    dg_df <- as.matrix(dg_max)
    print(dg_df[rownames(dg_df) == chkGene])
    print(head(dg_df))
    save(g, file = paste0("patient", patients, ".MI100.RData"))
    write.csv(dg_df, file = paste0("patient", patients, ".MI100.csv"))
}
summary(warnings(1000000))
savehistory(file = "setup.Rhistory")
chkGene <- "LAGE3"
for (patients in 1:ncol(z)) {
    print(paste0("patient", patients, chkGene))
    z1 <- cbind(toptable_edges, data.frame(z[, patients]))
    z2 <- z1[abs(z1[, 3]) > 25, ]
    g <- graph.data.frame(z2, directed = F)
    dg <- degree(g)
    print(summary(dg))
    dg_max <- sort.int(dg, decreasing = T, index.return = FALSE)
    dg_df <- as.matrix(dg_max)
    print(dg_df[rownames(dg_df) == chkGene])
    print(head(dg_df))
    save(g, file = paste0("patient", patients, ".MI25.RData"))
    write.csv(dg_df, file = paste0("patient", patients, ".MI25.csv"))
}
summary(warnings(1000000))
savehistory(file = "setup.Rhistory")
chkGene <- "LAGE3"
for (patients in 1:ncol(z)) {
    print(paste0("patient", patients, chkGene))
    z1 <- cbind(toptable_edges, data.frame(z[, patients]))
    z2 <- z1[abs(z1[, 3]) > 15, ]
    g <- graph.data.frame(z2, directed = F)
    dg <- degree(g)
    print(summary(dg))
    dg_max <- sort.int(dg, decreasing = T, index.return = FALSE)
    dg_df <- as.matrix(dg_max)
    print(dg_df[rownames(dg_df) == chkGene])
    print(head(dg_df))
    save(g, file = paste0("patient", patients, ".MI15.RData"))
    write.csv(dg_df, file = paste0("patient", patients, ".MI15.csv"))
}
summary(warnings(1000000))
savehistory(file = "setup.Rhistory")
chkGene <- "LAGE3"
for (patients in 1:ncol(z)) {
    print(paste0("patient", patients, chkGene))
    z1 <- cbind(toptable_edges, data.frame(z[, patients]))
    z2 <- z1[abs(z1[, 3]) > 20, ]
    g <- graph.data.frame(z2, directed = F)
    dg <- degree(g)
    print(summary(dg))
    dg_max <- sort.int(dg, decreasing = T, index.return = FALSE)
    dg_df <- as.matrix(dg_max)
    print(dg_df[rownames(dg_df) == chkGene])
    print(head(dg_df))
    save(g, file = paste0("patient", patients, ".MI20.RData"))
    write.csv(dg_df, file = paste0("patient", patients, ".MI20.csv"))
}
summary(warnings(1000000))
savehistory(file = "setup.Rhistory")
