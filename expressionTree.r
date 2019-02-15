pathD<-"L:/promec/Animesh/HeLa/ayu/new"
inpF<-file.path(pathD,"P value 0.05.csv")
data<-read.table(inpF,header=T,sep=",",row.names = 1)
summary(data)

#install.packages("randomForest")
library("randomForest")
data$Species=as.factor(data$Species)

treesN=1500
oob.values <- vector(length=treesN)
for(i in 1:treesN) {
  temp.model <- randomForest(Species ~ ., data=data, mtry=i, ntree=treesN)
  oob.values[i] <- temp.model$err.rate[nrow(temp.model$err.rate),1]
}
oob.values

str(data)
set.seed(42)
model <- randomForest(Species ~ ., data=data, proximity=TRUE)
oob.error.data <- data.frame(Trees=rep(1:nrow(model$err.rate), times=4), Type=rep(c("OOB", "Kapha", "Pitta", "Vatta"), each=nrow(model$err.rate)), Error=c(model$err.rate[,"OOB"], model$err.rate[,"K"], model$err.rate[,"P"],    model$err.rate[,"V"]))
library(ggplot2)
ggplot(data=oob.error.data, aes(x=Trees, y=Error)) +   geom_line(aes(color=Type))

library(devtools)
#install_github('araastat/reprtree')
library(reprtree)
reprtree:::plot.getTree(model)

treeN=15
set.seed(1)
treeN.model <- randomForest(Species ~ ., data=data, proximity=TRUE,ntree=treeN)#randomForest(Species ~ ., data=data, proximity=TRUE,iter=6)
treeN.model

oob.error.treeN.model <- data.frame(Trees=rep(1:nrow(treeN.model$err.rate), times=4), Type=rep(c("OOB", "Kapha", "Pitta", "Vatta"), each=nrow(treeN.model$err.rate)), Error=c(treeN.model$err.rate[,"OOB"], treeN.model$err.rate[,"K"], treeN.model$err.rate[,"P"],    treeN.model$err.rate[,"V"]))
ggplot(data=oob.error.treeN.model, aes(x=Trees, y=Error)) +   geom_line(aes(color=Type))
reprtree:::plot.getTree(treeN.model)

#install.packages('svglite')
library('svglite')
errPlot<-ggplot(data=oob.error.treeN.model, aes(x=Trees, y=Error)) +   geom_line(aes(color=Type))
ggsave(file=paste(inpF,".err.svg", sep=""), plot=errPlot, width=10, height=8)
ggsave(file=paste(inpF,".tree.svg", sep=""), plot=reprtree:::plot.getTree(treeN.model))
