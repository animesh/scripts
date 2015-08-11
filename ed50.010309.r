#4 different doses of carbamazepine alone (2, 4, 6, 8 mg/kg) and carbamazepine with tramadol (20mg/kg), flouxetine (20mg/kg) and melatonin (50mg/kg) given to mice

anticonvulsant <- data.frame(x = c (2,4,6,8), n = rep(8,4), y = c(0,3,6,8))
anticonvulsant$Ymat <- cbind(anticonvulsant$y, anticonvulsant$n - anticonvulsant$y)
fmp <- glm(Ymat ~ x, family = binomial(link=probit), data = anticonvulsant)
fml <- glm(Ymat ~ x, family = binomial, data = anticonvulsant)
ld50 <- function(b) -b[1]/b[2]
ldp <- ld50(coef(fmp)); ldl <- ld50(coef(fml))
c(ldp, ldl)
cbzv<-c(ldp, ldl)
cbzv

anticonvulsant <- data.frame(x = c (2,4,6,8), n = rep(8,4), y = c(0,6,7,8))
anticonvulsant$Ymat <- cbind(anticonvulsant$y, anticonvulsant$n - anticonvulsant$y)
fmp <- glm(Ymat ~ x, family = binomial(link=probit), data = anticonvulsant)
fml <- glm(Ymat ~ x, family = binomial, data = anticonvulsant)
ld50 <- function(b) -b[1]/b[2]
ldp <- ld50(coef(fmp)); ldl <- ld50(coef(fml))
c(ldp, ldl)
cbzv_tmd<-c(ldp, ldl)
cbzv_tmd

anticonvulsant <- data.frame(x = c (2,4,6,8), n = rep(8,4), y = c(0,6,8,8))
anticonvulsant$Ymat <- cbind(anticonvulsant$y, anticonvulsant$n - anticonvulsant$y)
fmp <- glm(Ymat ~ x, family = binomial(link=probit), data = anticonvulsant)
fml <- glm(Ymat ~ x, family = binomial, data = anticonvulsant)
ld50 <- function(b) -b[1]/b[2]
ldp <- ld50(coef(fmp)); ldl <- ld50(coef(fml))
c(ldp, ldl)
cbzv_flx<-c(ldp, ldl)
cbzv_flx

anticonvulsant <- data.frame(x = c (2,4,6,8), n = rep(8,4), y = c(1,5,7,8))
anticonvulsant$Ymat <- cbind(anticonvulsant$y, anticonvulsant$n - anticonvulsant$y)
fmp <- glm(Ymat ~ x, family = binomial(link=probit), data = anticonvulsant)
fml <- glm(Ymat ~ x, family = binomial, data = anticonvulsant)
ld50 <- function(b) -b[1]/b[2]
ldp <- ld50(coef(fmp)); ldl <- ld50(coef(fml))
c(ldp, ldl)
cbzv_melt<-c(ldp, ldl)
cbzv_melt


cbz = c(0,3,6,8)
cbz_tmd = c(0,6,7,8)
cbz_flx = c(0,6,8,8)
cbz_mel = c(1,5,7,8)

t.test(cbz_tmd, cbz);
t.test(cbz_flx, cbz);
t.test(cbz_mel, cbz);
t.test(cbz_tmd, cbz_mel);
t.test(cbz_flx, cbz_mel);
t.test(cbz_tmd, cbz_flx);


