data=read.table('bac-2008-02-13.blat.order')
pdf("plotorderblat.pdf")
plot(data$V9,data$V13)
plot(data$V11,data$V15)
plot(data$V6,data$V8)
plot(data$V16,data$V18)
q(save="no")

