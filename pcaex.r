M<-matrix(c(0.8,.1,.1,.3,.4,.3,.1,.2,.7),3,3)
k<-5
Mk<-M
for(i in 1:(5-1)){Mk<-Mk%*%M}
pr<-prcomp(Mk,scale=T)
barplot(100*summary(pr)$importance[2,],ylab="%var")

screenplot(pr)
