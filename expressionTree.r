pathD<-"L:/promec/Animesh/Lymphoma/"
inpF<-file.path(pathD,"proteinGroups.txt")
data<-read.table(inpF,header=T,sep="\t",row.names = 1)
summary(data)
y<-log2(as.matrix(data[205:239]))
summary(y)
row.names(y)<-row.names.data.frame(data)
colnames(y)=sub("Ratio.H.L.normalized.161205_","",colnames(y))
colnames(y)=sub("_[0-9]+_","",colnames(y))
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
chkANOVA<-apply(dataNorm,1,function(x){TukeyHSD(aov(x~class),"class")})
chkANOVAnames<-t(sapply(row.names(dataNorm),function(x){chkANOVA[[x]]$`class`[10:12]}))
chkANOVAnames<-apply(chkANOVAnames,2,function(x){p.adjust(x,"BH")})
colnames(chkANOVAnames)<-c("Alb3b-16-Alb3b-14","Alb3b-14-WT", "Alb3b-16-WT")
Uniprot<-sapply(strsplit(row.names(chkANOVAnames),";"), `[`, 1)
write.csv(cbind(chkANOVAnames,Uniprot),file.path(pathD,"chkANOVAnames.csv"))

#install.packages("randomForest")
library("randomForest")
dataNormLabelExpr=dataNormLabel[,c(2:5209,5215)]
summary(dataNormLabelExpr)
dataNormLabelExpr$Group4=as.factor(dataNormLabelExpr$Group4)
str(dataNormLabelExpr)
oob.values <- vector(length=10)
for(i in 1:10) {
  temp.model <- randomForest(Group4 ~ ., data=dataNormLabelExpr, mtry=i, ntree=1000)
  oob.values[i] <- temp.model$err.rate[nrow(temp.model$err.rate),1]
}
oob.values

str(data)
sum(dataNormLabelExpr[1,])
dim(dataNormLabelExpr)[2]
dataNormLabelExpr<-dataNormLabelExpr[dim(dataNormLabelExpr)[2]-1!=rowSums(is.na(dataNormLabelExpr)), ]
bad <- sapply(dataNormLabelExpr, function(x) all(is.nan(x)))
dataNormLabelExpr<-dataNormLabelExpr[,!bad]
dim(dataNormLabelExpr)

set.seed(1)
dataNormLabelExpr.imputed <- rfImpute(Group4 ~ ., data = dataNormLabelExpr, iter=6)

set.seed(1)
model <- randomForest(Group4 ~ ., data=dataNormLabelExpr.imputed,  proximity=TRUE)

A0A024QZX5;A0A087X1N8;P35237
dataNormLabelExpr.imputed$A0A024QZX5;A0A087X1N8;P35237

colnames(dataNormLabelExpr.imputed)<-sapply(strsplit(colnames(dataNormLabelExpr.imputed),";"), `[`, 1)
colnames(dataNormLabelExpr.imputed)<-sub(":","_",colnames(dataNormLabelExpr.imputed))
colnames(dataNormLabelExpr.imputed)<-sub("-","_",colnames(dataNormLabelExpr.imputed))
str(dataNormLabelExpr.imputed)

set.seed(1)
model <- randomForest(Group4 ~ ., data=dataNormLabelExpr.imputed,  proximity=TRUE)

set.seed(1)
model <- randomForest(Group4 ~ ., data=dataNormLabelExpr.imputed,  proximity=TRUE,ntree=1000)

oob.error.data <- data.frame(Trees=rep(1:nrow(model$err.rate),times=5),Type=rep(c("HR","IR","LR","VR"),each=nrow(model$err.rate)),Error=c(model$err.rate[,"OOB"],model$err.rate[,"HR"],model$err.rate[,"IR"],model$err.rate[,"LR"],model$err.rate[,"VR"]))
library(ggplot2)
ggplot(data=oob.error.data, aes(x=Trees, y=Error)) +   geom_line(aes(color=Type))
library(devtools)
#install_github('araastat/reprtree')
library(reprtree)
reprtree:::plot.getTree(model)

set.seed(1)
model150 <- randomForest(Species ~ ., data=data, proximity=TRUE,ntree=150)#randomForest(Species ~ ., data=data, proximity=TRUE,iter=6)
oob.error.datamodel150 <- data.frame(Trees=rep(1:nrow(model150$err.rate), times=4), Type=rep(c("OOB", "Kapha", "Pitta", "Vatta"), each=nrow(model150$err.rate)), Error=c(model150$err.rate[,"OOB"], model150$err.rate[,"K"], model150$err.rate[,"P"],    model150$err.rate[,"V"]))
ggplot(data=oob.error.datamodel150, aes(x=Trees, y=Error)) +   geom_line(aes(color=Type))
install.packages('svglite')
library('svglite')
errPlot<-ggplot(data=oob.error.datamodel150, aes(x=Trees, y=Error)) +   geom_line(aes(color=Type))
ggsave(file=paste(inpF,".err.svg", sep=""), plot=errPlot, width=10, height=8)
ggsave(file=paste(inpF,".tree.svg", sep=""), plot=reprtree:::plot.getTree(model150))
