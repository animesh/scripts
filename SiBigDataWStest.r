fileP<-"/home/animeshs/Downloads/"
fileN<-"diabetes.csv"
yy<-read.csv(paste0(fileP, fileN),header=T)
summary(yy[,9])
#diab[,9]=as.numeric(diab[,9]-1)
plot(yy,col=yy$Outcome,main="diabetes")

yyt=as.matrix(yy)
#yyt[,9]=as.factor(yyt[,9])
library(ggfortify)
log.yyt=log(yyt[,1:8]+1)
yyt.pca=prcomp(log.yyt,center=TRUE,scale.=TRUE) 
autoplot(yyt.pca,data=yyt,colour='Outcome',main="dataset")

dimnames(yyt)=NULL
summary(yyt)


library(keras)
#install_keras()
use_session_with_seed(2)
ind=sample(2,nrow(yyt),replace=TRUE,prob=c(0.75,0.25))

yyt.training=yyt[ind==1,1:8]
yyt.test=yyt[ind==2,1:8]

yyt.trainingtarget=yyt[ind==1,9]
yyt.testtarget=yyt[ind==2,9]

yyt.trainLabels=to_categorical(yyt.trainingtarget)
yyt.testLabels=to_categorical(yyt.testtarget)

model=keras_model_sequential()
model %>%
  layer_dense(input_shape=c(8),units=8,activation='relu',kernel_initializer="glorot_normal",use_bias=TRUE) %>%
      layer_dense(input_shape=c(6),units=6) %>%
      layer_dense(input_shape=c(4),units=4) %>%
  layer_dense(units=2,activation='softmax',kernel_initializer="glorot_normal",use_bias=TRUE)
summary(model)

model %>% compile(loss='categorical_crossentropy',optimizer='adam',metrics='accuracy')
history=model %>% fit(yyt.training,yyt.trainLabels,epochs=100,batch_size=nrow(yyt.training),validation_split=0.2)

plot(history)
predicted.classes=model %>% predict_classes(yyt.test)
table(yyt.testtarget,predicted.classes)
