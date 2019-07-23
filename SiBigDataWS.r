rm(list=ls())
setwd("/home/animeshs/Downloads/")
fileP<-"/home/animeshs/Downloads/"
fileN<-"diabetes.csv"
yy<-read.csv(paste0(fileP, fileN),header=T)
summary(yy[,9])

plot(yy,col=yy$Outcome,main="diabetes")

yyt=as.matrix(yy)
library(ggfortify)
log.yyt=log(yyt[,1:8]+1)
yyt.pca=prcomp(log.yyt,center=TRUE,scale.=TRUE)
autoplot(yyt.pca,data=yyt,colour='Outcome',main="dataset")

#install.packages("randomForest")
library(randomForest)

DIABETESDATA<-yy
str(data)
?kmeans
kmeans(DIABETESDATA,3)


DIABETESDATA = data.frame(DIABETESDATA)
DIABETESDATA.fact = as.factor(DIABETESDATA[,9])
DIABETES8 = data.frame(DIABETESDATA[,1:8])
DIABETESDATA.fact = data.frame(DIABETES8,DIABETESDATA.fact)
DIABETESDATA =DIABETESDATA.fact
names(DIABETESDATA)[9] = "Outcome"

set.seed(2)
ind = sample(2,nrow(DIABETESDATA),replace=TRUE)

DIABETES.training=DIABETESDATA[ind==1,]
DIABETES.test=DIABETESDATA[ind==2,]

?randomForest
random_forest = randomForest(DIABETES.training,Outcome ~ Pregnancies+Glucose+BloodPressure+SkinThickness+Insulin+BMI+DiabetesPedigreeFunction+Age,impurity = 'gini',ntree = 200,replace = TRUE,prob = c(0.80,0.20))

                             
print(random_forest)
