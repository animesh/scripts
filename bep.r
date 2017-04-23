pdf("solexa-map-plot.pdf");
t=read.table('sr2cspp',sep='\t')
plot(density(t2$V7),col="blue",xlab="Distance in bp",main="Solexa read mapping",ylab="Density of Pairs")
t2=read.table('sr2nspp',sep='\t')
lines(density(t$V3),col="red")
legend(x="topright", legend=c("Celera","Newbler"),text.col=c("blue","red"))
dens=(density(t$V3))
peak=dens$x[which(dens$y==max(dens$y))]  
abline(v=peak,lty=6,col=gray(0.4))
text(peak,0,labels=round(peak),cex=.6,adj = c(0,0))
dens=(density(t2$V7))
peak=dens$x[which(dens$y==max(dens$y))]  
abline(v=peak,lty=6,col=gray(0.4))
text(peak,0,labels=round(peak),cex=.6,adj = c(1,1))
median(t$V3)
sd(t$V3)
mean(t$V3)
median(t2$V7)
sd(t2$V7)
hist(t$V3,breaks=100000,xlim=range(0,1000))
hist(t2$V7,breaks=500000,xlim=range(0,1000))

