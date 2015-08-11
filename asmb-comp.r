
jpeg("asmb-comp.jpg");
t=read.table('nre',sep='\t')
plot(abs(t$V4),col="blue",type="l",xlab="Match #",main="ATACked assemblies",ylab="Cumulated length",xlim=range(0,10000))
summary(t)
t=read.table('cre',sep='\t')
summary(t)
lines((abs(t$V4)),col="red")
t=read.table('crn',sep='\t')
lines((abs(t$V4)),col="orange")
t=read.table('Cre.t10000',sep='\t')
lines((abs(t$V4)),col="green")
t=read.table('Crc.t10000',sep='\t')
lines((abs(t$V4)),col="magenta")
t=read.table('Crn.t10000',sep='\t')
lines((abs(t$V4)),col="grey")
legend(x="topright", legend=c("New2Ens=603801781","Cel2Ens=557036331","Cel2New=555895947","CLC2Ens=460246966","CLC2Cel=436981900","CLC2New=352453200"),text.col=c("blue","red","orange","green","magenta","grey"))


