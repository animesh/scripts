rm(list=ls())
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

data<-yy
str(data)

# removing lines with zeros:
data1 = data[!data$Glucose==0, ]
data1 = data1[!data1$BMI==0, ]
data1$Outcome <- factor(data1$Outcome)
str(data1)
summary(data1)

# split the data
ind=sample(2,nrow(data1),replace=TRUE,prob=c(0.8,0.2))
data.training=data1[ind==1,]
data.test=data1[ind==2,]

# notmality of the data
pairs(data.training)
summary(data.training)

shapiro.test(data.training$Pregnancies)
hist(data.training$Pregnancies)

shapiro.test(data.training$Glucose)
hist(data.training$Glucose)

shapiro.test(data.training$BloodPressure)
hist(data.training$BloodPressure)

shapiro.test(data.training$SkinThickness)
hist(data.training$SkinThickness)

shapiro.test(data.training$Insulin)
hist(data.training$Insulin)

shapiro.test(data.training$BMI)
hist(data.training$BMI)

shapiro.test(data.training$DiabetesPedigreeFunction)
hist(data.training$DiabetesPedigreeFunction)

shapiro.test(data.training$Age)
hist(data.training$Age)


model  <- glm(data=data.training, Outcome ~ BMI  , family  = "binomial")
model1 <- glm(data=data.training, Outcome ~ Glucose  , family  = "binomial")
model2 <- glm(data=data.training, Outcome ~ Glucose + BMI  , family  = "binomial")
model3 <- glm(data=data.training, Outcome ~ Age , family  = "binomial")
model4 <- glm(data=data.training, Outcome ~ Glucose + BMI + Age , family  = "binomial")


summary(model)
summary(model1)
summary(model2)
summary(model3)
summary(model4) #best model

plot(fitted(model1) ~ Glucose , data=data.training)
curve(exp(-5.690114+0.040457 *x)/
        (1+exp(-5.690114+0.040457 *x)), col= "green",add=TRUE) #estimates of the summery (model1)


model4 <- glm(data=data.training, Outcome ~ Glucose + BMI + Age, family  = "binomial")
summary(model4)

predict(model4, data.test, type = "response")

prob <- data.frame(predict(model4, data.test, type = "response"))
names(prob) <- c('var1')
prob$new <- ifelse(prob$var1 > 0.5, 1,0)
prob$Outcome <- data.test$Outcome

table = table(prob$new,prob$Outcome)

perc =(table[1]+table[4]) / sum(table)
perc

library(caret)
confusionMatrix(as.factor(as.numeric(prob$var1>0.5)), as.factor(prob$Outcome))

