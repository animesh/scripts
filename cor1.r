#a=read.table('groel.msa.aln.out')
a=read.table('tseq.aln.out')
#png("plotcor.png")
#plot(a)
#dev.off()
b <- cor(a)
write.table( b , file = "groel_hydro_cor_mat.txt", sep = "\t",col.names
            = FALSE, row.names = FALSE )

