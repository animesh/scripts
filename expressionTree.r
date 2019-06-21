pathD<-"F:/promec/Animesh/Lymphoma/"
inpF<-file.path(pathD,"proteinGroups.txt")
data<-read.table(inpF,header=T,sep="\t",row.names = 1)
summary(data)
y<-log2(as.matrix(data[205:239]))
summary(y)
row.names(y)<-row.names.data.frame(data)
colnames(y)=sub("Ratio.H.L.normalized.161205_","",colnames(y))
colnames(y)=sub("_[0-9]+_","",colnames(y))
summary(y)

inpF<-file.path(pathD,"code.txt")
label<-read.table(inpL,header=T,sep="\t")
colnames(label)
summary(label)

replicate<-as.factor(label$Code)
class<-as.factor(label$Code2)

dataNorm<-t(y)
set.seed(42)
dataNorm<-dataNorm+rnorm(1,0,0.01)
summary(dataNorm)
hist(dataNorm)
row.names(dataNorm)
row.names(label)<-label$Name
row.names(label)
row.names(dataNorm)
dataNormLabel<-merge(dataNorm,label,by=0, all.y = TRUE)
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
dataNormLabelExpr=dataNormLabel#[,c(2:5209,5215)]
summary(dataNormLabelExpr)
dataNormLabelExpr$Code2=as.factor(dataNormLabelExpr$Code2)
str(dataNormLabelExpr)
oob.values <- vector(length=10)
for(i in 1:10) {
  temp.model <- randomForest(Code2 ~ ., data=dataNormLabelExpr, mtry=i, ntree=1000)
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

marker<-read.table(paste0(pathD,"/marker45.txt"),header=T,sep="\t")
colnames(marker)
summary(marker)

set.seed(1)
dataNormLabelExpr$Code<-NULL
dataNormLabelExpr$Name<-NULL
dataNormLabelExpr$Row.names<-NULL
dataNormLabelExprNa<-sapply(dataNormLabelExpr, function(x) ifelse(is.nan(x), NA, x))
dataNormLabelExprNa<-dataNormLabelExpr[is.nan(dataNormLabelExpr$`A0A024QZX5;A0A087X1N8;P35237`)]
dataNormLabelExprNaM<-dataNormLabelExpr[,grepl( marker$Uniprot , colnames(dataNormLabelExpr ))]
((dataNormLabelExprNaM))
dataNormLabelExprNaM<-dataNormLabelExpr[marker$Uniprot]
summary(dataNormLabelExprNaM)

marker36data<-read.table(paste0(pathD,"/marker36data.txt"),header=T,sep="\t")
colnames(marker36data)
summary(marker36data)

marker36data$C..Code<-NULL
marker36data$T..Name<-NULL
marker36data$C..Code2<-as.factor(marker36data$C..Code2)
summary(marker36data)

marker36data.imputed <- rfImpute(C..Code2 ~ ., data = marker36data, iter=100)
summary(marker36data.imputed)
set.seed(1)
model <- randomForest(C..Code2 ~ ., data=marker36data.imputed,  proximity=TRUE)

A0A024QZX5;A0A087X1N8;P35237
dataNormLabelExpr.imputed$A0A024QZX5;A0A087X1N8;P35237

colnames(dataNormLabelExpr.imputed)<-sapply(strsplit(colnames(dataNormLabelExpr.imputed),";"), `[`, 1)
colnames(dataNormLabelExpr.imputed)<-sub(":","_",colnames(dataNormLabelExpr.imputed))
colnames(dataNormLabelExpr.imputed)<-sub("-","_",colnames(dataNormLabelExpr.imputed))
str(dataNormLabelExpr.imputed)

set.seed(1)
model <- randomForest(Group4 ~ ., data=dataNormLabelExpr.imputed,  proximity=TRUE)

set.seed(1)
model <- randomForest(C..Code2 ~ ., data=marker36data.imputed,  proximity=TRUE,ntree=1000)

oob.error.data <- data.frame(Trees=rep(1:nrow(model$err.rate),times=5),Type=rep(c("HR","IR","LR","VR"),each=nrow(model$err.rate)),Error=c(model$err.rate[,"OOB"],model$err.rate[,"HR"],model$err.rate[,"IR"],model$err.rate[,"LR"],model$err.rate[,"VR"]))
library(ggplot2)
ggplot(data=oob.error.data, aes(x=Trees, y=Error)) +   geom_line(aes(color=Type))
library(devtools)
#install_github('araastat/reprtree')
library(reprtree)
reprtree:::plot.getTree(model)

ind=sample(2,nrow(yyt),replace=TRUE,prob=c(0.75,0.25))
yyt.training=yyt[ind==1,]
yyt.test=yyt[ind==2,]

library("rpart")
library("rpart.plot")
tree=rpart(data=yyt.training,V4500~.,method="class",control=rpart.control(minsplit=10,minbucket=5),parms=list(split="information"))
rpart.plot(tree,main="Classification tree for the yyt data (using 75% of data as training set)",extra=101)


library(randomForest)
set.seed(42)
yyt=as.data.frame(marker36data.imputed)
names(yyt)=gsub("\\..*","",names(yyt))
random_forest=randomForest(data=yyt,C~.,impurity='gini',ntree=1000,replace=TRUE)
print(random_forest)
plot(random_forest)
legend("top",cex=0.8,legend=colnames(random_forest$err.rate),lty=c(1,2,3),col=c(1,2,3),horiz=T)

predictions=predict(random_forest,newdata=yyt,type="class")
actuals=yyt$C
table(actuals,predictions)

impVal=(importance(random_forest))
write.csv(impVal,paste0(pathD,"/marker36dataImp.txt"))

?varImpPlot
varImpPlot(random_forest,cex=.5)
#qplot(RCN1,GALNT2,data=yyt,colour=class,size=I(3))

set.seed(1)
model150 <- randomForest(Species ~ ., data=data, proximity=TRUE,ntree=150)#randomForest(Species ~ ., data=data, proximity=TRUE,iter=6)
oob.error.datamodel150 <- data.frame(Trees=rep(1:nrow(model150$err.rate), times=4), Type=rep(c("OOB", "Kapha", "Pitta", "Vatta"), each=nrow(model150$err.rate)), Error=c(model150$err.rate[,"OOB"], model150$err.rate[,"K"], model150$err.rate[,"P"],    model150$err.rate[,"V"]))
ggplot(data=oob.error.datamodel150, aes(x=Trees, y=Error)) +   geom_line(aes(color=Type))
install.packages('svglite')
library('svglite')
errPlot<-ggplot(data=oob.error.datamodel150, aes(x=Trees, y=Error)) +   geom_line(aes(color=Type))
ggsave(file=paste(inpF,".err.svg", sep=""), plot=errPlot, width=10, height=8)
ggsave(file=paste(inpF,".tree.svg", sep=""), plot=reprtree:::plot.getTree(model150))
