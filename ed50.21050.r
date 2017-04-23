#4 different doses of carbamazepine (2, 4, 6, 8 mg/kg) and flouxetine (30, 45, 60, 75, 90 mg/kg) alone were given to mice

anticonvulsant <- data.frame(x = c (2,4,6,8), n = rep(8,4), y = c(0,6,8,8))
anticonvulsant$Ymat <- cbind(anticonvulsant$y, anticonvulsant$n - anticonvulsant$y)
fmp <- glm(Ymat ~ x, family = binomial(link=probit), data = anticonvulsant)
fml <- glm(Ymat ~ x, family = binomial, data = anticonvulsant)
ld50 <- function(b) -b[1]/b[2]
ldp <- ld50(coef(fmp)); ldl <- ld50(coef(fml))
c(ldp, ldl)
cbzv_flxv<-c(ldp, ldl)
cbzv_flxv


#fixed dose of CBZ with melatonin

anticonvulsant <- data.frame(x = c (2,4,6,8), n = rep(8,4), y = c(1,5,6,8))
anticonvulsant$Ymat <- cbind(anticonvulsant$y, anticonvulsant$n - anticonvulsant$y)
fmp <- glm(Ymat ~ x, family = binomial(link=probit), data = anticonvulsant)
fml <- glm(Ymat ~ x, family = binomial, data = anticonvulsant)
ld50 <- function(b) -b[1]/b[2]
ldp <- ld50(coef(fmp)); ldl <- ld50(coef(fml))
c(ldp, ldl)
cbzv_melv<-c(ldp, ldl)
cbzv_melv
