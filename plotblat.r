data=read.table('run33e10b200p90chrrat.blat')
pdf("plotblat.pdf")
hist(data$V17,breaks=1000)
hist(data$V16,breaks=1000000)
hist(data$V13,breaks=25)
q(save="no")

