pathD<-"L:/promec/Animesh/Lymphoma/"
inpF<-file.path(pathD,"proteinGroups.txt")
data<-read.table(inpF,header=T,sep="\t",row.names = 1)
summary(data)


y<-log2(as.matrix(data[205:239]))
summary(y)
hist(y)
row.names(y)<-row.names.data.frame(data)
y[is.na(y)]<-0
colnames(y)=sub("Ratio.H.L.normalized.161205_","",colnames(y))
#colnames(y)=sub("_[0-9]+_","",colnames(y))
summary(y)

inpL<-inpF<-file.path(pathD,"Group3.txt")
label<-read.table(inpL,header=T,sep="\t")
colnames(label)
summary(label)

replicate<-as.factor(label$transformasjon)
class<-as.factor(label$Group4)

dataNorm<-t(y)
set.seed(42)
dataNorm<-dataNorm+rnorm(1,0,0.01)
summary(dataNorm)
hist(dataNorm)
row.names(dataNorm)
row.names(label)<-label$Name
row.names(label)
row.names(dataNorm)
dataNormLabel<-merge(dataNorm,label,by=0, all=TRUE)
dim(dataNormLabel)
TukeyHSD(aov(dataNormLabel$`P51149;C9J592;C9J8S3;C9J4V0;C9IZZ0;C9J4S4;C9J7D1`~dataNormLabel$Group4))[["dataNormLabel$Group4"]][19:24]
dataNorm<-dataNormLabel[,-c(5210:5215)]
dataNorm<-dataNorm[,-1]
dim(dataNorm)
dataNorm[is.na(dataNorm)]<-0
set.seed(42)
dataNorm<-dataNorm+rnorm(1,0,0.01)


chkANOVA<-apply(dataNorm,2,function(x){TukeyHSD(aov(x~dataNormLabel$Group4))})
chkANOVAnames<-t(sapply(colnames(dataNorm),function(x){chkANOVA[[x]]$`dataNormLabel$Group4`[19:24]}))
#chkANOVAnames<-apply(chkANOVAnames,2,function(x){p.adjust(x,"BH")})
colnames(chkANOVAnames)<-c("IR-HR","LR-HR","VR-HR","LR-IR","VR-IR","VR-LR")
Uniprot<-sapply(strsplit(row.names(chkANOVAnames),";"), `[`, 1)
write.csv(cbind(chkANOVAnames,Uniprot),file.path(pathD,"chkANOVAnames.csv"))
