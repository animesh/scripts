
#4 different doses of carbamazepine (2, 4, 6, 8 mg/kg) and celecoxib (30, 45, 60, 75, 90 mg/kg) alone were given to mice

anticonvulsant <- data.frame(x = c (2,4,6,8), n = rep(8,4), y = c(0,3,6,8))
anticonvulsant$Ymat <- cbind(anticonvulsant$y, anticonvulsant$n - anticonvulsant$y)
fmp <- glm(Ymat ~ x, family = binomial(link=probit), data = anticonvulsant)
fml <- glm(Ymat ~ x, family = binomial, data = anticonvulsant)
ld50 <- function(b) -b[1]/b[2]
ldp <- ld50(coef(fmp)); ldl <- ld50(coef(fml))
c(ldp, ldl)
cxbv<-c(ldp, ldl)
cxbv
summary(fmp)
 
cbzd=rnorm(25,4.766291,1.0523)


#fixed dose of celcoxib (30mg/kg) was combined with 4 different doses of carbamazepine (2, 4, 6, 8 mg/kg)

anticonvulsant <- data.frame(x = c (2,4,6,8), n = rep(8,4), y = c(5,7,8,8))
anticonvulsant$Ymat <- cbind(anticonvulsant$y, anticonvulsant$n - anticonvulsant$y)
fmp <- glm(Ymat ~ x, family = binomial(link=probit), data = anticonvulsant)
fml <- glm(Ymat ~ x, family = binomial, data = anticonvulsant)
ld50 <- function(b) -b[1]/b[2]
ldp <- ld50(coef(fmp)); ldl <- ld50(coef(fml))
c(ldp, ldl)
cbzv_cxb30<-c(ldp, ldl)
cbzv_cxb30

summary(fmp)
