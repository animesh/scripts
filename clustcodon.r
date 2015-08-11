d=read.table('L:/Elite/gaute/test/CDS_CU_EntrezID.txt',sep='\t',header=TRUE)
summary(d)
hc = hclust(na.omit(d))
cutree(hc)
