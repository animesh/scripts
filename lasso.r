#https://github.com/alexcoad/Econometrics

###################################################################
# Lasso on scoreboard data
###################################################################

library(readxl)
sb_raw <- read_excel("SB2023_World2500.xlsx")
sb     <- sb_raw

# take a first look at the data
dim(sb); head(sb)


################################
# DATA CLEANING & PREPARATION

# 1) Tidy up the column names

colnames(sb) <- c("rank", "company", "year", "ctry", "region", "industry", "rnd", "rnd_gr", "sales", "sales_gr", "rnd_int", "capex", "capex_gr", "capex_int", "opprof",  "opprof_gr", "profbty", "empl", "empl_gr", "mcap", "mcap_gr")


# 2) Convert variables to factor variables (i.e. categorical variables)

sb$industry <- as.factor(sb$industry)
levels(sb$industry)

sb$ctry <- as.factor(sb$ctry)
levels(sb$ctry)

sb$region <- as.factor(sb$region)
levels(sb$region)


# 3) log (or IHS) transformations for some variables

for (i in c("rnd", "sales", "empl", "mcap")) {
  # Create a new column name for the log-transformed variable
  new_col_name <- paste("log", i, sep="_")

  # Assign the log-transformed values to the new column
  sb[[new_col_name]] <- log(sb[[i]])

  # Print the new column name and its values
  cat("Variable:", new_col_name, "\n")
}

summary(sb_raw$opprof)
# lots of zeroes, take the IHS instead of logs
sb$ihs_opprof <- asinh(sb$opprof)

summary(sb_raw$capex)
# 2 cases of zeroes, take the log(1+x)
sb$log_capex <- log(1 + sb$capex)


# 4) remove unnecessary variables: rank, company name, year (always 2022)

sb <- sb[, 4:27]



# 5) Lasso requires that there are no missing values

colSums(is.na(sb))

# drop 185 NAs for empl_gr
sb <- sb[complete.cases(sb$empl_gr), ]
dim(sb)
colSums(is.na(sb))

# lots of NAs for mcap_gr, let's just leave this variable out
sb[, 18]
sb <- sb[, -18]

sb <- na.omit(sb)
dim(sb)



###########################################################
# Dep Var = R&D_intensity  

ycol <- which(names(sb)=="rnd_int")
# This is our DV
ysb  <- sb$rnd_int

# create sparse model matrix without intercept
library(Matrix)
xsb <- sparse.model.matrix( ~ ., data = sb[, -ycol])[, -1]

class(xsb)
dim(xsb)


library(gamlr) # in case you don't already have this loaded
fitsb <- gamlr(x=xsb, y=ysb, lmr = 1e-6)
plot(fitsb, main = "DV = R&D Intensity")



# examine the gamlr object
fitsb
# summary(fitsb)
names(fitsb)
dim(fitsb$beta)

# look at models at segments 1, 2, 99 and 100
fitsb$beta[,c(1:2,99:100)]
fitsb$alpha[c(1:2,99:100)]


# examine the best-fitting model
bsb <- coef(fitsb) ## the coefficients selected under AICc
which.min(AICc(fitsb))  ## model 54 fits best
fitsb$lambda[54]
head(bsb)        ## lots of coefficients are zero in model 54
bsb <- bsb[-1,]  ## we can drop the intercept term
sum(bsb != 0)    ## there are 20 nonzero coefficients
# look at the 5 most negative and positive coefficients
head(sort(bsb),5) 
tail(sort(bsb),5) 


# check coefficients for specific variables
bsb[c("profbty", "sales_gr", "log_mcap", "empl_gr")]


# Focus on the 2 largest R&D investors (i.e. Alphabet & Meta)
sb_raw[ c(1, 2) , c(2, 7, 11) ]
# Actual R&D intensity = 14.0% for Alphabet, 28.8% for Meta

# The predict command uses the AICc by default
( yhat <- predict(fitsb, xsb[ c(1, 2) ,]) )
drop(yhat) # use "drop" to remove sparse formatting
# Predicted R&D intensity = 3.53% for Alphabet, 18.59% for Meta




# Code from Leiden Group
# Read data setwd("M:\\R\\data\\Haks\\lasso") 
library(foreign) 
library(globaltest) 
D <- read.spss("data/data.spss", to.data.frame=TRUE) 
X <- D[,-(1:3)]  
X <- X[,-46]

plot(1:100)


# Data exploration using globaltest (three times a pairwise comparison) library(globaltest) 
# res1 <- gt(Donor, D[-(1:3)], data=D, levels=c("TB", "TST+")) 
pdf("globaltest TB vs TST+.pdf") 
features(res1) 
title(main="TB vs TST+") 
dev.off() 
res2 <- gt(Donor, D[-(1:3)], data=D, levels=c("TB", "TST-")) 
pdf("globaltest TB vs TST-.pdf") 
features(res2) 
title(main="TB vs TST-") 
dev.off() 
res3 <- gt(Donor, D[-(1:3)], data=D, levels=c("TST+", "TST-")) 
pdf("globaltest TST+ vs TST-.pdf") 
features(res3) 
title(main="TST+ vs TST-") 
dev.off() 
 # load the lasso: 
library(penalized)  
# Make random train/test set. # Set the seed (drawn randomly) for reproducability 
set.seed(-273185307) 
splt <- function(ix) ix[sample(length(ix), round(2*length(ix)/3))] 
train <- 1:nrow(D) %in% c(splt(which(D$Donor == "TB")), splt(which(D$Donor == "TST+")), splt(which(D$Donor == "TST-"))) 
test <- !train 
 # lasso analysis: TB vs TST+ 
TR1 <- X[train & D$Donor %in% c("TB", "TST+"),]      
# extract TB and TST+ only 
resp1 <- factor(D$Donor[train & D$Donor %in% c("TB", "TST+")]) 
res1 <- profL1(resp1, TR1, standardize=FALSE, minlambda1=.2)    
# plot cross-validated likelihood as a function of lambda 
plot(res1$lambda, res1$cvl, type="l") 
best1 <- optL1(resp1, TR1, standardize=FALSE)   
#  optimize cross-validated likelihood as a function of lambda 
coef(best1$full)       
# extract the coefficients 
TST1 <- X[test & D$Donor %in% c("TB", "TST+"),]      
# get the test set 
predictions1 <- predict(best1$full, TST1)        
# test set predictions 
truth1 <- D$Donor[test & D$Donor %in% c("TB", "TST+")]    
# the truth for the test set 
plot(truth1, predictions1)     
#  ROC curve 
ROC1 <- as.data.frame(t(sapply(sort(predictions1), function(pr) {   
 sens <- sum(predictions1 <= pr & truth1 == "TB") / sum(truth1 == "TB")   
 spec <- sum(predictions1 > pr & truth1 == "TST+") / sum(truth1 == "TST+")   
 c(sens=sens, spec=spec)  
}))) 
plot(c(0,1-ROC1$spec, 1), c(0,ROC1$sens, 1), type="l", xlab="1-specificity", ylab="sensitivity", main="TB vs TST+") 
AUC1 <- mean(outer(predictions1[truth1=="TB"], predictions1[truth1=="TST+"], "<")) 
AUC1        #  area under the curve  
# lasso analysis: TB vs TST- (comments see above) 
TR2 <- X[train & D$Donor %in% c("TB", "TST-"),] 
resp2 <- factor(D$Donor[train & D$Donor %in% c("TB", "TST-")]) 
res2 <- profL1(resp2, TR2, standardize=FALSE, minl=.2) 
plot(res2$lambda, res2$cvl, type="l") 
best2 <- optL1(resp2, TR2, standardize=FALSE) 
coef(best2$full) 
TST2 <- X[test & D$Donor %in% c("TB", "TST-"),] 
predictions2 <- predict(best2$full, TST2) 
truth2 <- D$Donor[test & D$Donor %in% c("TB", "TST-")] 
plot(truth2, predictions2) 
ROC2 <- as.data.frame(t(sapply(sort(predictions2), function(pr) {   
 sens <- sum(predictions2 <= pr & truth2 == "TB") / sum(truth2 == "TB")   
 spec <- sum(predictions2 > pr & truth2 == "TST-") / sum(truth2 == "TST-") 
 c(sens=sens, spec=spec) 
}))) 
plot(c(0,1-ROC2$spec, 1), c(0,ROC2$sens, 1), type="l", xlab="1-specificity", ylab="sensitivity", main="TB vs TST-")  
AUC2 <- mean(outer(predictions2[truth2=="TB"], predictions2[truth2=="TST-"], "<")) 
AUC2 
 # lasso analysis:  TST+ vs TST- (comments see above) 
TR3 <- X[train & D$Donor %in% c("TST+", "TST-"),] 
resp3 <- factor(D$Donor[train & D$Donor %in% c("TST+", "TST-")]) 
res3 <- profL1(resp3, TR3, standardize=FALSE, minsteps=70)    
# optimum rond lambda=0 ?? plot(res3$lambda, res3$cvl, type="l") 
best3 <- optL1(resp3, TR3, standardize=FALSE) 

coef(best3$full) 
TST3 <- X[test & D$Donor %in% c("TST+", "TST-"),] 
predictions3 <- predict(best3$full, TST3) 
truth3 <- D$Donor[test & D$Donor %in% c("TST+", "TST-")] 
plot(truth3, predictions3) 
ROC3 <- as.data.frame(t(sapply(sort(predictions3), function(pr) {   
 sens <- sum(predictions3 <= pr & truth3 == "TST+") / sum(truth3 == "TST+")   
 spec <- sum(predictions3 > pr & truth3 == "TST-") / sum(truth3 == "TST-") 
 c(sens=sens, spec=spec) 
}))) 
plot(c(0,1-ROC3$spec, 1), c(0,ROC3$sens, 1), type="l", xlab="1-specificity", ylab="sensitivity", main="TST+ vs TST-")  
AUC3 <- mean(outer(predictions3[truth3=="TST+"], predictions3[truth3=="TST-"], "<")) 
AUC3 
# how do the TST+ samples do in the TB vs TST- comparison 
TST2B <- X[test,] 
predictions2B <- predict(best2$full, TST2B) 
truth2B <- D$Donor[test] 
plot(factor(truth2B[truth2B %in% c("TB", "TST+","TST-")]), predictions2B[truth2B %in% c("TB", "TST+","TST-")], main="TB vs TST-", ylab="predicted probability") 
 # how do the TST- samples do in the TB vs TST+ comparison 
TST1B <- X[test,] 
predictions1B <- predict(best1$full, TST1B) 
truth1B <- D$Donor[test] 
plot(factor(truth1B[truth1B %in% c("TB", "TST+","TST-")]), predictions1B[truth1B %in% c("TB", "TST+","TST-")], main="TB vs TST+", ylab="predicted probability") 
# how do the TB samples do in the TST+ vs TST- comparison 
TST3B <- X[test,] 
predictions3B <- predict(best3$full, TST3B) 
truth3B <- D$Donor[test] 
plot(factor(truth3B[truth3B %in% c("TB", "TST+","TST-")]), predictions3B[truth3B %in% c("TB", "TST+","TST-")], main="TST+ vs TST-", ylab="predicted probability") 
 # correllation between predictions: 
plot(predictions1B, predictions2B, xlab="Test set predictions from TB vs TST+ model", ylab="Test set predictions from TB vs TST- model")  
 # compare ridge analysis (similar to lasso analysis; comments see above): 
# TB vs TST+ best1R <- optL2(resp1, TR1, standardize=FALSE) 
coef(best1R$full) 
predictions1R <- predict(best1R$full, TST1) 
plot(truth1, predictions1R) 
ROC1R <- as.data.frame(t(sapply(sort(predictions1R), function(pr) {   
 sens <- sum(predictions1R <= pr & truth1 == "TB") / sum(truth1 == "TB")   
 spec <- sum(predictions1R > pr & truth1 == "TST+") / sum(truth1 == "TST+") 
 c(sens=sens, spec=spec) 
}))) 
plot(c(0,1-ROC1R$spec, 1), c(0,ROC1R$sens, 1), type="l", xlab="1-specificity", ylab="sensitivity", main="TB vs TST+ (ridge)")  
AUC1R <- mean(outer(predictions1R[truth1=="TB"], predictions1R[truth1=="TST+"], "<")) 
AUC1R 
 # TB vs TST- 
best2R <- optL2(resp2, TR2, standardize=FALSE) 
coef(best2R$full) 
predictions2R <- predict(best2R$full, TST2) 
plot(truth2, predictions2R) 
ROC2R <- as.data.frame(t(sapply(sort(predictions2R), function(pr) {   
 sens <- sum(predictions2R <= pr & truth2 == "TB") / sum(truth2 == "TB") 
 spec <- sum(predictions2R > pr & truth2 == "TST-") / sum(truth2 == "TST-")   
 c(sens=sens, spec=spec) 
}))) 
plot(c(0,1-ROC2R$spec, 1), c(0,ROC2R$sens, 1), type="l", xlab="1-specificity", ylab="sensitivity", main="TB vs TST- (ridge)") 
AUC2R <- mean(outer(predictions2R[truth2=="TB"], predictions2R[truth2=="TST-"], "<")) 
AUC2R  
#TST+ vs TST- 
best3R <- optL2(resp3, TR3, standardize=FALSE) 
coef(best3R$full) 
predictions3R <- predict(best3R$full, TST3) 
plot(truth3, predictions3R) 
ROC3R <- as.data.frame(t(sapply(sort(predictions3R), function(pr) {   
 sens <- sum(predictions3R <= pr & truth3 == "TST+") / sum(truth3 == "TST+")   
 spec <- sum(predictions3R > pr & truth3 == "TST-") / sum(truth3 == "TST-")  
 c(sens=sens, spec=spec) 
}))) 
plot(c(0,1-ROC3R$spec, 1), c(0,ROC3R$sens, 1), type="l", xlab="1-specificity", ylab="sensitivity", main="TST+ vs TST- (ridge)")  
AUC3R <- mean(outer(predictions3R[truth3=="TST+"], predictions3R[truth3=="TST-"], "<")) 
AUC3R
