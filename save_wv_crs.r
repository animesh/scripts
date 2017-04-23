crs=read.csv('data/crsWP.csv',header=F)
save=read.csv('data/saveWP.csv',header=F)
wv=read.csv('data/wvWP.csv',header=F)

jpeg('result/crs.jpg')
plot(crs)

jpeg('result/save.jpg')
plot(save)

jpeg('result/wv.jpg')
plot(wv)

cor.test(crs$V5,crs$V6)
cor.test(save$V5,save$V6)
cor.test(wv$V5,wv$V6)

t.test(save$V6,wv$V6,paired=T)
t.test(crs$V6,crs$V5,paired=T)
t.test(wv$V6,wv$V5,paired=T)

jpeg('result/boxplotV6.jpg')

boxplot(crs$V6,save$V6,wv$V6)


dev.off( )
com=rbind(crs,save,wv)
com[is.na(com)] <- 0
pcacom<-prcomp(com,scale=T)
plot(pcacom)
summary(pcacom)
biplot(pcacom)



var.test(crs$V6,save$V6)
var.test(crs$V6,wv$V6)
var.test(save$V6,wv$V6)

library(ade4)
mantel.rtest(dist(save), dist(crs), nrepet = 100)

summary(glm(wv$V5~wv$V6))
summary(glm(crs$V5~crs$V6))
summary(glm(save$V5~save$V6))


summary(glm(crs$V6~crs$V5))
summary(glm(save$V6~save$V5))
summary(glm(wv$V6~wv$V5))

jpeg('result/regsaveV6crsV7.jpg')
plot(save$V6~crs$V7)
abline(glm(save$V6~crs$V7))


