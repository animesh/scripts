##########################################
###
### Read files
###
#######################################

fn1 = "Tid 0 K1K4 1304291r2r.csv"
fn2 = "Tid 0 K2K5, 130429.csv"

X1 = read.csv(fn1, sep="\t")
X2 = read.csv(fn2, sep="\t")

values1 <- X1[,4:5]
isna1 <- is.na(values1) 
values1[isna1] <- 0
values11 <- sqrt(values1[,1]*values1[,2])
names(values11) <- as.character(X1[,1])
rownames(values1) <- as.character(X1[,1])


values2 <- X2[,4]
values2[is.na(values2)] <- 0
names(values2) <- as.character(X2[,1])


common.proteins <- intersect(names(values2), names(values11))

tmpval <- values1[,1]
tmpval[tmpval==0] <- 10e9
inv.values1 <- 1/tmpval
names(inv.values1) <- names(values11)

x11(); plot(inv.values1[common.proteins], values2[common.proteins], xlim=c(0, 4), ylim=c(0,4), main="V1")


tmpval <- values1[,2]
tmpval[tmpval==0] <- 10e9
inv.values2 <- 1/tmpval
names(inv.values2) <- names(values11)

x11(); plot(inv.values2[common.proteins], values2[common.proteins], xlim=c(0, 4), ylim=c(0,4), main="V2")


inv.values <- (inv.values1[common.proteins] + inv.values2[common.proteins])/2
inv.values <- sqrt(inv.values1[common.proteins]*inv.values2[common.proteins])

symbols <- names(inv.values)
psym <- symbols
psym[] <- ""
pcol <- psym
pcol[] <- "gray"
v2 <- values2[common.proteins]
v1 <- inv.values
sign <- v2>=2.5 | v1>=2.5
#sign <- v2 + v1 >= 3.5
psym[sign] <- symbols[sign]
pcol[sign] <- "darkred"



x11(); plot(v1, v2, xlim=c(0, 4), ylim=c(0,4), main="", xlab="K2K5", ylab="K1K4", col=pcol, pch=19)
text(v1, v2, psym, pos=4, cex=0.8)

vals.for.fit <- v2 > 0.01 & v1 > 0.01
y <- v2[vals.for.fit]
x <- v1[vals.for.fit]
mod <- lm(y~x)

lines(c(0,3.8), c(mod$coefficients[1], 3.8*mod$coefficients[2]), col="green3")
text(3.8, 3.8*mod$coefficients[2], "r^2 = 0.74", pos=3, col="green3", cex=1.1)


library(geneplotter)
savepdf("Kplot1")
savepng("Kplot1")

tab <- data.frame(K2K5=v1, K1K4=v2, Mean=(v1+v2)/2, Gmean=sqrt((v1*v2)))
write.table(tab, file="results.txt", sep="\t", quote=FALSE)




###
### K1 , time 0 vs time 4 and time 0 vs time 12
###


##########################################
###
### Read files
###
#######################################
#function <- gm(x) exp(mean(log(x)))

library(gdata)
fn0 <- "data_timepoints/130429_tobias_k1k4_ax_0t_1r2r.xlsx"
fn12 <- "data_timepoints/130429_tobias_k1k4_ax_12t_1r2r.xlsx"
fn5 <-  "data_timepoints/130429_tobias_k1k4_ax_5t_1r2r.xlsx"

X0 <- read.xls(fn0)
X5 <- read.xls(fn5)
X12 <- read.xls(fn12)

values0 <- X0[,grep("Heavy", colnames(X0))]
isna0 <- is.na(values0) 
values0[isna0] <- 0
values0 <- sqrt(values0[,1]*values0[,2])
names(values0) <- as.character(X0[,1])

values5 <- X5[,grep("Heavy", colnames(X5))]
isna5 <- is.na(values5) 
values5[isna5] <- 0
values5 <- sqrt(values5[,1]*values5[,2])
names(values5) <- as.character(X5[,1])

values12 <- X12[,grep("Heavy", colnames(X12))]
isna12 <- is.na(values12) 
values12[isna12] <- 0
values12 <- sqrt(values12[,1]*values12[,2])
names(values12) <- as.character(X12[,1])


###### PLOT 1 ###############
common.proteins <- intersect(names(values0), names(values5))
v1 <- values0[common.proteins]
v2 <- values5[common.proteins]

symbols <- names(v1)
psym <- symbols
psym[] <- ""
pcol <- psym
pcol[] <- "gray"
sign <- v2>=2.5 | v1>=2.5
#sign <- v2 + v1 >= 3.5
psym[sign] <- symbols[sign]
pcol[sign] <- "darkred"



x11(); plot(v1, v2, xlim=c(0, 4), ylim=c(0,4), main="", xlab="K1K4 - timpoint 0", ylab="K1K4 - timpoint 5", col=pcol, pch=19)
text(v1, v2, psym, pos=4, cex=0.8)

vals.for.fit <- v2 > 0.01 & v1 > 0.01
y <- v2[vals.for.fit]
x <- v1[vals.for.fit]
mod <- lm(y~x)

lines(c(0,3.8), c(mod$coefficients[1], 3.8*mod$coefficients[2]), col="green3")
text(3.8, 3.8*mod$coefficients[2], "r^2 = 0.16", pos=3, col="green3", cex=1.1)


library(geneplotter)
savepdf("Kplot_K1K4_T0T5")
savepng("Kplot_K1K4_T0T5")

tab <- data.frame(K2K5=v1, K1K4=v2, Mean=(v1+v2)/2, Gmean=sqrt((v1*v2)))
write.table(tab, file="resultsK1K4_T0T5.txt", sep="\t", quote=FALSE)


###### PLOT 2 ###############
common.proteins <- intersect(names(values0), names(values12))
v1 <- values0[common.proteins]
v2 <- values12[common.proteins]

symbols <- names(v1)
psym <- symbols
psym[] <- ""
pcol <- psym
pcol[] <- "gray"
sign <- v2>=2.5 | v1>=2.5
#sign <- v2 + v1 >= 3.5
psym[sign] <- symbols[sign]
pcol[sign] <- "darkred"



x11(); plot(v1, v2, xlim=c(0, 4), ylim=c(0,4), main="", xlab="K1K4 - timpoint 0", ylab="K1K4 - timpoint 12", col=pcol, pch=19)
text(v1, v2, psym, pos=4, cex=0.8)

vals.for.fit <- v2 > 0.01 & v1 > 0.01
y <- v2[vals.for.fit]
x <- v1[vals.for.fit]
mod <- lm(y~x)

lines(c(0,3.8), c(mod$coefficients[1], 3.8*mod$coefficients[2]), col="green3")
text(3.8, 3.8*mod$coefficients[2], "r^2 = 0.47", pos=3, col="green3", cex=1.1)


library(geneplotter)
savepdf("Kplot_K1K4_T0T12")
savepng("Kplot_K1K4_ToT12")

tab <- data.frame(K2K5=v1, K1K4=v2, Mean=(v1+v2)/2, Gmean=sqrt((v1*v2)))
write.table(tab, file="resultsK1K4_T0T12.txt", sep="\t", quote=FALSE)



# From BI-2013-Geir Arnar's codebase