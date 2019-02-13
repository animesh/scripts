pathD<-"L:/promec/Animesh/HeLa/ayu/new"
inpF<-file.path(pathD,"P value 0.02.csv")
data<-read.table(inpF,header=T,sep=",",row.names = 1)
summary(data)

#install.packages("randomForest")
library("randomForest")

data$Species=as.factor(data$Species)

oob.values <- vector(length=10)
for(i in 1:10) {
  temp.model <- randomForest(Species ~ ., data=data, mtry=i, ntree=1000)
  oob.values[i] <- temp.model$err.rate[nrow(temp.model$err.rate),1]
}
oob.values

str(data)
set.seed(1)
#data.imputed <- rfImpute(Species ~ ., data = data, iter=6)
model <- randomForest(Species ~ ., data=data, proximity=TRUE)
oob.error.data <- data.frame(Trees=rep(1:nrow(model$err.rate), times=4), Type=rep(c("OOB", "Kapha", "Pitta", "Vatta"), each=nrow(model$err.rate)), Error=c(model$err.rate[,"OOB"], model$err.rate[,"K"], model$err.rate[,"P"],    model$err.rate[,"V"]))
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
