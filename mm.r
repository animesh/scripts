res1 <- read.table("WT347356.txt")


resap <- read.table("ap.txt")
resapt <- read.table("apt.txt")
resdm <- read.table("dm.txt")
resfl <- read.table("fl.txt")
resm347 <- read.table("m347.txt")
resm356 <- read.table("m356.txt")
reswt <- read.table("wtt.txt")



df$ytrans <- df$conc/df$vel


resflc3 <- resfl[-c(3),]



t.test(res1$WT,res1$WT_347)
t.test(res1$WT,res1$WT_356)
t.test(res1$WT,res1$WT_347_356)
t.test(res1$WT_347,res1$WT_356)
t.test(res1$WT_347,res1$WT_347_356)
t.test(res1$WT_356,res1$WT_347_356)


p = res1$WT
q = res1$WT_347
r = res1$WT_356
s = res1$WT_347_356
scores = data.frame(p,q,r,s)
boxplot(scores)
scores = stack(scores)
names(scores)
oneway.test(values ~ ind, data=scores, var.equal=T)
