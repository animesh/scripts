a=read.table('pos_wise_mut.txt')


png("plot.png")
plot(a,xlab="position", ylab = "mutations")
dev.off()
