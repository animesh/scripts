jpeg("sol-read-map-asm.jpg");
t=read.table('sr2cs.pairdist.txt',sep='\t')
summary(t)
t=t$V7[t$V7<10000];
plot(density(abs(t)),col="red",xlab="Distance in bp",main="gsMapped unique solexa reads",ylab="Density of Pairs",xlim=c(0,500))
t=read.table('sr2ns.pairdist.txt',sep='\t')
summary(t)
t=t$V7[t$V7<10000];
lines(density(abs(t)),col="blue")
t=read.table('sr2es.pairdist.txt',sep='\t')
summary(t)
t=t$V7[t$V7<10000];
lines(density(abs(t)),col="green")
t=read.table('sr2Cs.pairdist.txt',sep='\t')
summary(t)
t=t$V7[t$V7<10000];
lines(density(abs(t)),col="magenta")
legend(x="topright", legend=c("Newbler=44309960","Celera=52217740","Ensembl=52629598","CLC=47664198"),text.col=c("blue","red","green","magenta"))


