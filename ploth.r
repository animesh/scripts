NEWBLER = read.table('c10x454.prop')
hist(NEWBLER$V3, xlab = "Contig Length",ylab = "Number of Contig (s)", col="blue", border="black", main = "NEWBLER", breaks=10,xlim=c(0,5000), ylim=c(0,5000))

