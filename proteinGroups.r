pathD<-"L:/promec/Animesh/Tobias/txt/"
inpF<-file.path(pathD,"proteinGroups.txt")
data<-read.table(inpF,header=T,sep="\t",row.names = 1)
summary(data)

inpL<-file.path(pathD,"Groups.txt")
label<-read.table(inpL,header=T,sep="\t")
colnames(label)
summary(label)

log2ratioHL<-log2(as.matrix(data[82:95]))
dim(log2ratioHL)
summary(log2ratioHL)
hist(log2ratioHL)

log2ratioHLnorm<-log2(as.matrix(data[96:109]))
dim(log2ratioHLnorm)
summary(log2ratioHLnorm)
hist(log2ratioHLnorm)

pdf(paste(inpF,".ratiohist.pdf", sep=""))
log2rH <- hist(log2ratioHL,breaks=30)
log2rnH <- hist(log2ratioHLnorm,breaks=30)
plot( log2rnH, col=rgb(0,0,1,1/5), xlim=c(-10,10))
plot( log2rH, col=rgb(1,0,0,1/5), xlim=c(-10,10), add=T)  # second
dev.off()

row.names(y)<-row.names.data.frame(data)
y[is.na(y)]<-0
colnames(y)=sub("LFQ.intensity.H.","",colnames(y))
#colnames(y)=sub(".Sample","",colnames(y))
summary(y)

log2ratio<-rbind(log2ratioHL,log2ratioHLnorm)
library(ggplot2)
ggplot(aes(log2ratio) + geom_density(alpha = 0.2))

replicate<-as.factor(label$Bio)
class<-as.factor(label$Cell)

dataNorm<-y
set.seed(1)
dataNorm[dataNorm==0]<-rnorm(1,mean=mean(y),sd=sd(y))
summary(dataNorm)

#TukeyHSD(aov(dataNorm["B7G7S4",]~class),"class", ordered = TRUE)[["class"]][10:12]
chkANOVA<-apply(dataNorm,1,function(x){TukeyHSD(aov(x~class),"class")})
chkANOVAnames<-t(sapply(row.names(dataNorm),function(x){chkANOVA[[x]]$`class`[10:12]}))
chkANOVAnames<-apply(chkANOVAnames,2,function(x){p.adjust(x,"BH")})
colnames(chkANOVAnames)<-c("SUDHL5","JURKAT")
Uniprot<-sapply(strsplit(row.names(chkANOVAnames),";"), `[`, 1)
write.csv(cbind(chkANOVAnames,Uniprot),file.path(pathD,"chkANOVAnames.csv"))
