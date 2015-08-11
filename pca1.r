setwd("D:\\animesh\\projects\\research\\nonlinear")
'java weka.classifiers.meta.ClassificationViaRegression -t data4.arff -W weka.classifiers.trees.M5P -- -M 4.0]

data_tr$V1 <- data_xor$V1
data_tr$V2 <- data_xor$V2
data_tr$V3 <- data_xor$V3




data_xor <- read.table("xora.txt")

ftr = data.frame(data_xor$V1,data_xor$V2,data_xor$V3,data_xor$V4,data_xor$V5,data_xor$V6,data_xor$V7,data_xor$V8,data_xor$V9,data_xor$V)


ftr = read.table("xora.txt_featv.dat")

svd_ftr <- svd(ftr)

plot(t(svd_ftr$v[,1]),t(svd_ftr$v[,2]))

write.table(t(svd_ftr$v), file = "datavt", sep = "\t",col.names = FALSE, row.names = FALSE )

