dline <- read.table("res_line.txt")
resdataap <- read.table("ap.txt")
resdataapip <- read.table("apip.txt")
resdatafl <- read.table("fl.txt")

conc=c(resdataap$ConcPm,resdataapip$ConcPm,resdatafl$ConcPm)
lethal=c(resdataap$Ap,resdataapip$Ap_Ip,resdatafl$Fl)



x <- seq(0, 2000, length=201)
yap <- (dline$AP[1]*x+dline$AP[2])
yapip <- (dline$AP_IP[1]*x+dline$AP_IP[2])
yfl <- (dline$FL[1]*x+dline$FL[2])


plot(conc,lethal)
lines(x, yap, type = "l", col="red")
lines(x, yapip, type = "l", col="green")
lines(x, yfl, type = "l", col="blue")


write.table((cbind(c(x),c(yap))), file = "ap_otp.txt", sep = "\t",col.names = FALSE, row.names = FALSE )


write.table((cbind(c(x),c(yapip))), file = "apip_otp.txt", sep = "\t",col.names = FALSE, row.names = FALSE )

write.table((cbind(c(x),c(yfl))), file = "fl_otp.txt", sep = "\t",col.names = FALSE, row.names = FALSE )

map <- read.table("maplot.txt")
matplot(map)

x <- seq(0, 2000, length=201)
yap <- (dline$AP[1]*x+dline$AP[2])
plot(x, yap, type = "l", col="red")


plot.new()
line(dline$AP[2],dline$AP[1])

lmfit <- lm(Ap~ConcPm, data=resdataap, na.action=na.omit)
summary(lmfit)
plot(resdataap$ConcPm,resdataap$Ap)
abline(coef(lmfit))

lmfit <- lm(Ap_Ip~ConcPm, data=resdataapip, na.action=na.omit)
summary(lmfit)
plot(resdataapip$ConcPm,resdataapip$Ap_Ip)
abline(coef(lmfit))

lmfit <- lm(Fl~ConcPm, data=resdatafl, na.action=na.omit)
summary(lmfit)
plot(resdatafl$ConcPm,resdatafl$Fl)
abline(coef(lmfit))




resdataap$ApT <- resdataap$ConcPm/resdataap$Ap
lmfit <- lm(Ap~ConcPm, data=resdataap, na.action=na.omit)
plot(resdataap$ConcPm, resdataap$ApT)
abline(coef(lmfit))
Bm <- 1/coef(lmfit)[2]
Kd <- Bm*coef(lmfit)[1]
Bm
Kd
nlsfit <- nls(Ap~Bm*ConcPm/(Kd+ConcPm),data=resdataap, start=list(Kd=Kd, Bm=Bm))
summary(nlsfit)
plot(resdataap$ConcPm, resdataap$Ap)
x <- seq(0, 2000, length=10)
y2 <- (coef(nlsfit)["Bm"]*x)/(coef(nlsfit)["Kd"]+x)
y2 <- predict(nlsfit,data.frame(ConcPm=x))
lines(x, y2)
y1 <- (Bm*x)/(Kd+x)
lines(x, y1, lty="dotted", col="red")



lmfit <- lm(Fl~Conc, data=resdata, na.action=na.omit)
summary(lmfit)
plot(resdata$Conc,resdata$Fl)
abline(coef(lmfit))






resapc3$Pbtrans <- resapc3$Pf/resapc3$Pb
lmfit <- lm(Pbtrans~Pf, data=resapc3, na.action=na.omit)
plot(resapc3$Pf, resapc3$Pbtrans)
abline(coef(lmfit))
Bm <- 1/coef(lmfit)[2]
Kd <- Bm*coef(lmfit)[1]
Bm
Kd
nlsfit <- nls(Pb~Bm*Pf/(Kd+Pf),data=resapc3, start=list(Kd=Kd, Bm=Bm))
summary(nlsfit)
plot(resapc3$Pf, resapc3$Pb)
x <- seq(0, 60, length=120)
y2 <- (coef(nlsfit)["Bm"]*x)/(coef(nlsfit)["Kd"]+x)
y2 <- predict(nlsfit,data.frame(conc=x))
lines(x, y2)
y1 <- (Bm*x)/(Kd+x)
lines(x, y1, lty="dotted", col="red")



resfl$Pbtrans <- resfl$Pf/resfl$Pb
lmfit <- lm(Pbtrans~Pf, data=resfl, na.action=na.omit)
plot(resfl$Pf, resfl$Pbtrans)
abline(coef(lmfit))
Bm <- 1/coef(lmfit)[2]
Kd <- Bm*coef(lmfit)[1]
Bm
Kd
nlsfit <- nls(Pb~Bm*Pf/(Kd+Pf),data=resfl, start=list(Kd=Kd, Bm=Bm))
summary(nlsfit)
plot(resfl$Pf, resfl$Pb)
x <- seq(0, 60, length=120)
y2 <- (coef(nlsfit)["Bm"]*x)/(coef(nlsfit)["Kd"]+x)
y2 <- predict(nlsfit,data.frame(conc=x))
lines(x, y2)
y1 <- (Bm*x)/(Kd+x)
lines(x, y1, lty="dotted", col="red")




resflc3$Pbtrans <- resflc3$Pf/resflc3$Pb
lmfit <- lm(Pbtrans~Pf, data=resflc3, na.action=na.omit)
plot(resflc3$Pf, resflc3$Pbtrans)
abline(coef(lmfit))
Bm <- 1/coef(lmfit)[2]
Kd <- Bm*coef(lmfit)[1]
Bm
Kd
nlsfit <- nls(Pb~Bm*Pf/(Kd+Pf),data=resflc3, start=list(Kd=Kd, Bm=Bm))
summary(nlsfit)
plot(resflc3$Pf, resflc3$Pb)
x <- seq(0, 60, length=120)
y2 <- (coef(nlsfit)["Bm"]*x)/(coef(nlsfit)["Kd"]+x)
y2 <- predict(nlsfit,data.frame(conc=x))
lines(x, y2)
y1 <- (Bm*x)/(Kd+x)
lines(x, y1, lty="dotted", col="red")




resm347$Pbtrans <- resm347$Pf/resm347$Pb
lmfit <- lm(Pbtrans~Pf, data=resm347, na.action=na.omit)
plot(resm347$Pf, resm347$Pbtrans)
abline(coef(lmfit))
Bm <- 1/coef(lmfit)[2]
Kd <- Bm*coef(lmfit)[1]
Bm
Kd
nlsfit <- nls(Pb~Bm*Pf/(Kd+Pf),data=resm347, start=list(Kd=Kd, Bm=Bm))
summary(nlsfit)
plot(resm347$Pf, resm347$Pb)
x <- seq(0, 60, length=120)
y2 <- (coef(nlsfit)["Bm"]*x)/(coef(nlsfit)["Kd"]+x)
y2 <- predict(nlsfit,data.frame(conc=x))
lines(x, y2)
y1 <- (Bm*x)/(Kd+x)
lines(x, y1, lty="dotted", col="red")





resm356$Pbtrans <- resm356$Pf/resm356$Pb
lmfit <- lm(Pbtrans~Pf, data=resm356, na.action=na.omit)
plot(resm356$Pf, resm356$Pbtrans)
abline(coef(lmfit))
Bm <- 1/coef(lmfit)[2]
Kd <- Bm*coef(lmfit)[1]
Bm
Kd
nlsfit <- nls(Pb~Bm*Pf/(Kd+Pf),data=resm356, start=list(Kd=Kd, Bm=Bm))
summary(nlsfit)
plot(resm356$Pf, resm356$Pb)
x <- seq(0, 60, length=120)
y2 <- (coef(nlsfit)["Bm"]*x)/(coef(nlsfit)["Kd"]+x)
y2 <- predict(nlsfit,data.frame(conc=x))
lines(x, y2)
y1 <- (Bm*x)/(Kd+x)
lines(x, y1, lty="dotted", col="red")



resdm$Pbtrans <- resdm$Pf/resdm$Pb
lmfit <- lm(Pbtrans~Pf, data=resdm, na.action=na.omit)
plot(resdm$Pf, resdm$Pbtrans)
abline(coef(lmfit))
Bm <- 1/coef(lmfit)[2]
Kd <- Bm*coef(lmfit)[1]
Bm
Kd
nlsfit <- nls(Pb~Bm*Pf/(Kd+Pf),data=resdm, start=list(Kd=Kd, Bm=Bm))
summary(nlsfit)
plot(resdm$Pf, resdm$Pb)
x <- seq(0, 60, length=120)
y2 <- (coef(nlsfit)["Bm"]*x)/(coef(nlsfit)["Kd"]+x)
y2 <- predict(nlsfit,data.frame(conc=x))
lines(x, y2)
y1 <- (Bm*x)/(Kd+x)
lines(x, y1, lty="dotted", col="red")








t.test((resap$Pb/(resap$Pb+resap$Pf)),(resfl$Pb/(resfl$Pb+resfl$Pf)))
t.test((resap$Pb/(resap$Pb+resap$Pf)),(resm347$Pb/(resm347$Pb+resm347$Pf)))
t.test((resap$Pb/(resap$Pb+resap$Pf)),(resm356$Pb/(resm356$Pb+resm356$Pf)))
t.test((resap$Pb/(resap$Pb+resap$Pf)),(resdm$Pb/(resdm$Pb+resdm$Pf)))

t.test((resfl$Pb/(resfl$Pb+resfl$Pf)),(resm347$Pb/(resm347$Pb+resm347$Pf)))
t.test((resfl$Pb/(resfl$Pb+resfl$Pf)),(resm356$Pb/(resm356$Pb+resm356$Pf)))
t.test((resfl$Pb/(resfl$Pb+resfl$Pf)),(resdm$Pb/(resdm$Pb+resdm$Pf)))

t.test((resm347$Pb/(resm347$Pb+resm347$Pf)),(resm356$Pb/(resm356$Pb+resm356$Pf)))
t.test((resm347$Pb/(resm347$Pb+resm347$Pf)),(resdm$Pb/(resdm$Pb+resdm$Pf)))

t.test((resm356$Pb/(resm356$Pb+resm356$Pf)),(resdm$Pb/(resdm$Pb+resdm$Pf)))




names(lmfit)
summary(lmfit)
plot(lmfit)
class(lmfit)
coef(lmfit)



p = res1$WT
q = res1$WT_347
r = res1$WT_356
s = res1$WT_347_356
scores = data.frame(p,q,r,s)
boxplot(scores)
scores = stack(scores)
names(scores)
oneway.test(values ~ ind, data=scores, var.equal=T)
