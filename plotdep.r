pdf("depth.pdf");
scf=read.table('Pwgs6dhmovlcod.posmap.frgscf.500.depth')
deg=read.table('Pwgs6dhmovlcod.posmap.frgdeg.500.depth')
hist(scf$V6,breaks=100,main="Scf")
hist(deg$V6,breaks=100000,main="Deg",xlim=range(0,40))
plot(density(abs(scf$V6)),col="blue",xlab="Depth",main="Scf Vs Deg",ylab="Density of Depth",xlim=range(0,40))
legend(x="topright", legend=c("scf","deg"),text.col=c("blue","red"))
lines(density(deg$V6),col="red")
summary(scf$V6)
summary(scf$V3)
summary(deg$V3)
summary(deg$V6)

