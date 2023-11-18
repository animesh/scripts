#setup####
#https://www.r-bloggers.com/2021/04/random-forest-in-r/
#install.packages("randomForest")
#install.packages('caret')
#install.packages('ggplot2')
#data####
inpF="F:/OneDrive - NTNU/Aida/ML/dataTmmS42T.csv"
data=read.csv(inpF)
dim(data)
dGroup="Class"
print(dGroup)
data[,dGroup] <- as.factor(data[,dGroup])
print(table(data[,dGroup]))#mapping = {'MGUS':1,'MM':2,'Ml':3}
#model####
set.seed(42)
ind <- sample(2, nrow(data), replace = TRUE, prob = c(0.8, 0.2))
train <- data[ind==1,]
test <- data[ind==2,]
rf <- randomForest::randomForest(Class ~ ., data=train, proximity=TRUE)
print(rf)
#plot####
plot(rf)
hist(randomForest::treesize(rf),
     main = "No. of Nodes for the Trees",
     col = "green")
#proximityPCA####
rfProx<-rf$proximity
biplot(princomp(rfProx))
rfProxPrComp<- prcomp(rfProx, center = TRUE, scale. = FALSE)
plot(rfProxPrComp)
dfrfProxPrComp<- data.frame(rfProxPrComp$x[,1:2], Class = train$Class)
ggplot2::ggplot(dfrfProxPrComp, ggplot2::aes(x= PC1, y = PC2)) +
  ggplot2::geom_point(ggplot2::aes(color = Class))
#chkFeature####
geneImp<-randomForest::importance(rf)
#randomForest::partialPlot(rf, train, "LAMP1.7", "MGUS")
#randomForest::partialPlot(rf, train, "LAMP1.7", "MM")
#randomForest::MDSplot(rf, train[,dGroup])
#randomForest::MDSplot(rf, data[,dGroup])
#randomForest::MDSplot(rf, test[,dGroup])
#predict####
p1 <- predict(rf, train)
caret::confusionMatrix(p1, train[,dGroup])
p2 <- predict(rf, test)
caret::confusionMatrix(p2, test[,dGroup])
#impFeature####
randomForest::varImpPlot(rf,
                         sort = T,
                         n.var = 10,
                         main = "Top 10 - Variable Importance")
