a=read.table('rest_of_list.txt.aln.aln2hydro.txt')

a=read.table('groel.msa.aln.aln2hydro.txt')
b <- cor(a, method="pearson")
write.table( b , file = "groel.msa.aln.hydro.cor.txt", sep = "\t",col.names  = FALSE, row.names = FALSE )
c<-symnum(clS <- cor(a, method = "spearman"))
write.table( c , file = "rest_of_list_hydro_cor_mat.txt", sep = "\t",col.names  = FALSE, row.names = FALSE )
d<-cov(a)
e<-cov2cor(d)
write.table( e , file = "rest_of_list_hydro_cor_mat.txt", sep = "\t",col.names  = FALSE, row.names = FALSE )
