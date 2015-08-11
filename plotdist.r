data=read.table('bac-2008-02-13.blat.orderwl.txt')
dataa=read.table('bac-2008-02-13.blat.order.txt')

pdf("plotdist.pdf")

plot(data$V9,data$V13)
plot(dataa$V9,dataa$V13)

hist(data$V22,breaks=10000)
hist(dataa$V22,breaks=10000)

hist(data$V23,breaks=25)
hist(dataa$V23,breaks=25)

plot(dataa$V6,dataa$V8);
plot(dataa$V16,dataa$V18);


q(save="no")

