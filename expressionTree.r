pathD<-"F:/promec/Animesh/MK/"
inpF<-file.path(pathD,"proteinGroups.txt")
data<-read.table(inpF,header=T,sep="\t",row.names = 1)
summary(data)
colName<-"LFQ.intensity."
y<-log2(as.matrix(data[,grep(colName,colnames(data))]))
summary(y)
row.names(y)<-row.names.data.frame(data)
colnames(y)=sub(colName,"",colnames(y))
#colnames(y)=sub("_[0-9]+_","",colnames(y))
summary(y)

inpF<-file.path(pathD,"Class.txt")
label<-read.table(inpF,header=T,sep="\t")
colnames(label)
summary(label)

replicate<-as.factor(label$Patientcode)
location<-as.factor(label$Location)
treatment<-as.factor(label$Treatment)

dataNorm<-t(y)
#set.seed(42)
#dataNorm<-dataNorm+rnorm(1,0,0.01)
summary(dataNorm)
hist(dataNorm)
row.names(dataNorm)
row.names(label)<-formatC(label$Name,width=2, flag="0")
row.names(label)
dataNormLabelExpr<-merge(dataNorm,label,by=0, all.y = TRUE)
dim(dataNormLabelExpr)
summary(dataNormLabelExpr)

#install.packages("randomForest")
library("randomForest")
summary(dataNormLabelExpr)
dataNormLabelExpr$Treatment=as.factor(dataNormLabelExpr$Treatment)
str(dataNormLabelExpr)
#colnames(dataNormLabelExpr.imputed)<-sapply(strsplit(colnames(dataNormLabelExpr.imputed),";"), `[`, 1)
colnames(dataNormLabelExpr) <- gsub(";", "_", colnames(dataNormLabelExpr))
colnames(dataNormLabelExpr) <- gsub("-", "__", colnames(dataNormLabelExpr))
colnames(dataNormLabelExpr) <- gsub(":", "__", colnames(dataNormLabelExpr))
dataNormLabelExpr$Location<-NULL
dataNormLabelExpr$Patientcode<-NULL
dataNormLabelExpr[dataNormLabelExpr==-Inf]=NA
dataNormLabelExpr$Name<-NULL
dataNormLabelExpr$Row.names<-NULL
dataNormLabelExpr<-dataNormLabelExpr[,colSums(is.na(dataNormLabelExpr))<nrow(dataNormLabelExpr)]
#dataNormLabelExpr<-dataNormLabelExpr[dim(dataNormLabelExpr)[2]-1!=rowSums(is.na(dataNormLabelExpr)), ]
#dataNormLabelExpr<-dataNormLabelExpr[,dim(dataNormLabelExpr)[1]-1!=colSums(is.na(dataNormLabelExpr))]
dim(dataNormLabelExpr)
summary(dataNormLabelExpr)
write.csv(dataNormLabelExpr,paste0(pathD,colName,"log2.sel.csv"))
set.seed(1)
dataNormLabelExpr.imputed <- rfImpute(Treatment ~ ., data = dataNormLabelExpr, iter=100)
summary(dataNormLabelExpr.imputed)
#colnames(dataNormLabelExpr.imputed) <- gsub(":", "__", colnames(dataNormLabelExpr.imputed))
write.csv(dataNormLabelExpr.imputed,paste0(pathD,colName,"log2.sel.imp.csv"))

oob.values <- vector(length=10)
for(i in 1:10) {
  temp.model <- randomForest(Treatment ~ ., data=dataNormLabelExpr.imputed, mtry=i, ntree=1000)
  oob.values[i] <- temp.model$err.rate[nrow(temp.model$err.rate),1]
}
oob.values

#marker<-read.table(paste0(pathD,"/marker45.txt"),header=T,sep="\t")
#colnames(marker)
#summary(marker)
#dataNormLabelExprNaM<-dataNormLabelExpr[,grepl( marker$Uniprot , colnames(dataNormLabelExpr ))]
#dataNormLabelExprNaM<-dataNormLabelExpr[marker$Uniprot]
#summary(dataNormLabelExprNaM)

set.seed(1)
model <- randomForest(Treatment ~ . , data=dataNormLabelExpr.imputed)#, mtree=250, ntree=1000, proximity=TRUE)
print(model)
plot(model)
#legend("top",cex=0.8,legend=colnames(model$err.rate),lty=c(1,2,3),col=c(1,2,3),horiz=T)

#oob.error.data <- data.frame(Trees=rep(1:nrow(model$err.rate),times=5),Type=rep(c("HR","IR","LR","VR"),each=nrow(model$err.rate)),Error=c(model$err.rate[,"OOB"],model$err.rate[,"HR"],model$err.rate[,"IR"],model$err.rate[,"LR"],model$err.rate[,"VR"]))
#library(devtools)
#install_github('araastat/reprtree')
#library(reprtree)
#reprtree:::plot.getTree(model)

ind=sample(2,nrow(dataNormLabelExpr.imputed),replace=TRUE,prob=c(0.75,0.25))
dataNormLabelExpr.imputed.training=dataNormLabelExpr.imputed[ind==1,]
dataNormLabelExpr.imputed.test=dataNormLabelExpr.imputed[ind==2,]

library("rpart")
library("rpart.plot")
tree=rpart(data=dataNormLabelExpr.imputed.training,Treatment~.,method="class",control=rpart.control(minsplit=10,minbucket=5),parms=list(split="information"))
rpart.plot(tree,main="Classification tree for the yyt data (using 75% of data as training set)",extra=101)


#names(yyt)=gsub("\\..*","",names(yyt))
predictions=predict(tree,newdata=dataNormLabelExpr.imputed.test,type="class")
actuals=dataNormLabelExpr.imputed.test$Treatment
table(actuals,predictions)

varImpPlot(model,cex=.5)
library('ggplot2')
#errPlot<-ggplot(data=oob.error.datamodel150, aes(x=Trees, y=Error)) +   geom_line(aes(color=Type))
ggsave(paste0(inpF,".varImp.svg"),rpart.plot(tree,main="Classification tree for the yyt data (using 75% of data as training set)",extra=101))#, width=10, height=8)
