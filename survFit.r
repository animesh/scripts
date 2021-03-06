#
# Ensure that factors work in prediction
#
options(na.action=na.exclude) # preserve missings
options(contrasts=c('contr.treatment', 'contr.poly')) #ensure constrast type
library(survival)
aeq <- function(x,y, ...) all.equal(as.vector(x), as.vector(y), ...)

tfit <- coxph(Surv(time, status) ~ age + factor(ph.ecog), lung)
p1 <- predict(tfit, type='risk')

lung2 <- lung[lung$ph.ecog!=1,]
p2 <- predict(tfit, type='risk', newdata=lung2)

aeq(p1[is.na(lung$ph.ecog) | lung$ph.ecog!=1], p2)

# Same, for survreg
tfit <- survreg(Surv(time, status) ~ age + factor(ph.ecog), lung)
p1 <- predict(tfit, type='response')
p2 <- predict(tfit, type='response', newdata=lung2)
aeq(p1[is.na(lung$ph.ecog) | lung$ph.ecog!=1], p2)


# Now repeat it tossing the missings
options(na.action=na.omit) 
tfit2 <- coxph(Surv(time, status) ~ age + factor(ph.ecog), lung)
p3 <- predict(tfit2, type='risk')
p4 <- predict(tfit2, type='risk', newdata=lung2, na.action=na.omit)

aeq(p3[lung$ph.ecog[!is.na(lung$ph.ecog)] !=1] , p4)

tfit2 <- survreg(Surv(time, status) ~ age + factor(ph.ecog), lung)
p3 <- predict(tfit2, type='response')
p4 <- predict(tfit2, type='response', newdata=lung2, na.action=na.omit)

aeq(p3[lung$ph.ecog[!is.na(lung$ph.ecog)] !=1] , p4)

options(na.action=na.exclude) # preserve missings
options(contrasts=c('contr.treatment', 'contr.poly')) #ensure constrast type
library(survival)

#
# The residual methods treat a sparse frailty as a fixed offset with
#   no variance
#
aeq <- function(x,y, ...) all.equal(as.vector(x), as.vector(y), ...)

kfit1 <- coxph(Surv(time, status) ~ age + sex + 
	           frailty(id, dist='gauss'), kidney)
tempf <- predict(kfit1, type='terms')[,3]
temp  <- kfit1$frail[match(kidney$id, sort(unique(kidney$id)))]
#all.equal(unclass(tempf), unclass(temp))
all.equal(as.vector(tempf), as.vector(temp))

# Now fit a model with explicit offset
kfitx <- coxph(Surv(time, status) ~ age + sex + offset(tempf),kidney,
	       eps=1e-7)

# These are not precisely the same, due to different iteration paths
aeq(kfitx$coef, kfit1$coef)

# This will make them identical
kfitx <- coxph(Surv(time, status) ~ age + sex  + offset(temp),kidney,
	       iter=0, init=kfit1$coef)
aeq(resid(kfit1), resid(kfitx))
aeq(resid(kfit1, type='score'), resid(kfitx, type='score'))
aeq(resid(kfit1, type='schoe'), resid(kfitx, type='schoe'))

# These are not the same, due to a different variance matrix
#  The frailty model's variance is about 2x the naive "assume an offset" var
# The score residuals are equal, however.
aeq(resid(kfit1, type='dfbeta'), resid(kfitx, type='dfbeta'))
zed <- kfitx
zed$var <- kfit1$var
aeq(resid(kfit1, type='dfbeta'), resid(zed, type='dfbeta'))


temp1 <- resid(kfit1, type='score')
temp2 <- resid(kfitx, type='score')
aeq(temp1, temp2)

#
# Now for some tests of predicted values
#
aeq(predict(kfit1, type='expected'), predict(kfitx, type='expected'))
aeq(predict(kfit1, type='lp'), predict(kfitx, type='lp'))

temp1 <- predict(kfit1, type='terms', se.fit=T)
temp2 <- predict(kfitx, type='terms', se.fit=T)
aeq(temp1$fit[,1:2], temp2$fit)
aeq(temp1$se.fit[,1:2], temp2$se.fit)  #should be false
mean(temp1$se.fit[,1:2]/ temp2$se.fit)
aeq(as.vector(temp1$se.fit[,3])^2, 
	  as.vector(kfit1$fvar[match(kidney$id, sort(unique(kidney$id)))]))

print(temp1)
kfit1
kfitx

rm(temp1, temp2, kfitx, zed, tempf)
#
# The special case of a single sparse frailty
#

kfit1 <- coxph(Surv(time, status) ~ frailty(id, dist='gauss'), kidney)
tempf <- predict(kfit1, type='terms')
temp  <- kfit1$frail[match(kidney$id, sort(unique(kidney$id)))]
all.equal(as.vector(tempf), as.vector(temp))

# Now fit a model with explicit offset
kfitx <- coxph(Surv(time, status) ~ offset(tempf),kidney, eps=1e-7)

aeq(resid(kfit1), resid(kfitx))
aeq(resid(kfit1, type='deviance'), resid(kfitx, type='deviance'))

#
# Some tests of predicted values
#
aeq <- function(x,y) all.equal(as.vector(x), as.vector(y))
aeq(predict(kfit1, type='expected'), predict(kfitx, type='expected'))
aeq(predict(kfit1, type='lp'), predict(kfitx, type='lp'))

temp1 <- predict(kfit1, type='terms', se.fit=T)
aeq(temp1$fit, kfitx$linear)
aeq(temp1$se.fit^2, 
	  kfit1$fvar[match(kidney$id, sort(unique(kidney$id)))])

temp1
kfit1


