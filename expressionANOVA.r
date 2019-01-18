pathD<-"L:/promec/USERS/MarianneNymark/181009/PDv2p3/181009_newprep_Charlotte_Alb3b-14_II"
inpF<-file.path(pathD,"181009_newprep_Charlotte_Alb3b-14_II-(1)_Proteins.txt")
data<-read.table(inpF,header=T,sep="\t",row.names = 3)
summary(data)

inpL<-"L:/promec/USERS/MarianneNymark/181009/PDv2p3/181009_newprep_Charlotte_Alb3b-14_II/Groups.txt"
label<-read.table(inpL,header=T,sep="\t")
colnames(label)
summary(label)

y<-log2(as.matrix(data[32:46]))
summary(y)
hist(y)
row.names(y)<-row.names.data.frame(data)
y[is.na(y)]<-0
colnames(y)=sub("Abundances.Normalized.F","",colnames(y))
colnames(y)=sub(".Sample","",colnames(y))
summary(y)

replicate<-as.factor(label$Replicate)
class<-as.factor(label$Group)

dataNorm<-y
set.seed(1)
dataNorm[dataNorm==0]<-rnorm(1,mean=mean(y),sd=sd(y))
summary(dataNorm)

#TukeyHSD(aov(dataNorm["B7G7S4",]~class),"class", ordered = TRUE)[["class"]][10:12]

chkANOVA<-apply(dataNorm,1,function(x){TukeyHSD(aov(x~class),"class")})
chkANOVAnames<-t(sapply(row.names(dataNorm),function(x){chkANOVA[[x]]$`class`[10:12]}))
chkANOVAnames<-apply(chkANOVAnames,2,function(x){p.adjust(x,"BH")})
colnames(chkANOVAnames)<-c("Alb3b-16-Alb3b-14","Alb3b-14-WT", "Alb3b-16-WT")
Uniprot<-sapply(strsplit(row.names(chkANOVAnames),";"), `[`, 1)
write.csv(cbind(chkANOVAnames,Uniprot),file.path(pathD,"chkANOVAnames.csv"))
