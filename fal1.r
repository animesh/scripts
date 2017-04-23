cphyll <- read.table("chlorophyll.txt")
nodule <- read.table("nodule.txt")
wsf <- read.table("weight_sf.txt")
wrf <- read.table("weight_rf.txt")

boxplot(nodule)
boxplot(nodule)
boxplot(wsf)
boxplot(wrf)

wilcox.test(cphyll$Uninoculated,cphyll$GN25)
wilcox.test(nodule$Uninoculated,nodule$GN25)
wilcox.test(wsf$Uninoculated,wsf$GN25)
wilcox.test(wrf$Uninoculated,wrf$GN25)

wilcox.test(cphyll$GN25,cphyll$GN25pFJ4)
wilcox.test(nodule$GN25,nodule$GN25pFJ4)
wilcox.test(wsf$GN25,wsf$GN25pFJ4)
wilcox.test(wrf$GN25,wrf$GN25pFJ4)

wilcox.test(cphyll$GN25,cphyll$GN25pFJ9)
wilcox.test(nodule$GN25,nodule$GN25pFJ9)
wilcox.test(wsf$GN25,wsf$GN25pFJ9)
wilcox.test(wrf$GN25,wrf$GN25pFJ9)

wilcox.test(cphyll$Uninoculated,cphyll$GN25pFJ4)
wilcox.test(nodule$Uninoculated,nodule$GN25pFJ4)
wilcox.test(wsf$Uninoculated,wsf$GN25pFJ4)
wilcox.test(wrf$Uninoculated,wrf$GN25pFJ4)

wilcox.test(cphyll$Uninoculated,cphyll$GN25pFJ9)
wilcox.test(nodule$Uninoculated,nodule$GN25pFJ9)
wilcox.test(wsf$Uninoculated,wsf$GN25pFJ9)
wilcox.test(wrf$Uninoculated,wrf$GN25pFJ9)

wilcox.test(cphyll$GN25,cphyll$GN25.Um)
wilcox.test(nodule$GN25,nodule$GN25.Um)
wilcox.test(wsf$GN25,wsf$GN25.Um)
wilcox.test(wrf$GN25,wrf$GN25.Um)

wilcox.test(cphyll$GN25pFJ4,cphyll$GN25pFJ4.Um)
wilcox.test(nodule$GN25pFJ4,nodule$GN25pFJ4.Um)
wilcox.test(wsf$GN25pFJ4,wsf$GN25pFJ4.Um)
wilcox.test(wrf$GN25pFJ4,wrf$GN25pFJ4.Um)

wilcox.test(cphyll$GN25pFJ9,cphyll$GN25pFJ9.Um)
wilcox.test(nodule$GN25pFJ9,nodule$GN25pFJ9.Um)
wilcox.test(wsf$GN25pFJ9,wsf$GN25pFJ9.Um)
wilcox.test(wrf$GN25pFJ9,wrf$GN25pFJ9.Um)

wilcox.test(cphyll$Uninoculated,cphyll$Um)
wilcox.test(nodule$Uninoculated,nodule$Um)
wilcox.test(wsf$Uninoculated,wsf$Um)
wilcox.test(wrf$Uninoculated,wrf$Um)


t.test(cphyll$Uninoculated,cphyll$GN25)
t.test(nodule$Uninoculated,nodule$GN25)
t.test(wsf$Uninoculated,wsf$GN25)
t.test(wrf$Uninoculated,wrf$GN25)

t.test(cphyll$GN25,cphyll$GN25pFJ4)
t.test(nodule$GN25,nodule$GN25pFJ4)
t.test(wsf$GN25,wsf$GN25pFJ4)
t.test(wrf$GN25,wrf$GN25pFJ4)

t.test(cphyll$GN25,cphyll$GN25pFJ9)
t.test(nodule$GN25,nodule$GN25pFJ9)
t.test(wsf$GN25,wsf$GN25pFJ9)
t.test(wrf$GN25,wrf$GN25pFJ9)

t.test(cphyll$Uninoculated,cphyll$GN25pFJ4)
t.test(nodule$Uninoculated,nodule$GN25pFJ4)
t.test(wsf$Uninoculated,wsf$GN25pFJ4)
t.test(wrf$Uninoculated,wrf$GN25pFJ4)

t.test(cphyll$Uninoculated,cphyll$GN25pFJ9)
t.test(nodule$Uninoculated,nodule$GN25pFJ9)
t.test(wsf$Uninoculated,wsf$GN25pFJ9)
t.test(wrf$Uninoculated,wrf$GN25pFJ9)

t.test(cphyll$GN25,cphyll$GN25.Um)
t.test(nodule$GN25,nodule$GN25.Um)
t.test(wsf$GN25,wsf$GN25.Um)
t.test(wrf$GN25,wrf$GN25.Um)

t.test(cphyll$GN25pFJ4,cphyll$GN25pFJ4.Um)
t.test(nodule$GN25pFJ4,nodule$GN25pFJ4.Um)
t.test(wsf$GN25pFJ4,wsf$GN25pFJ4.Um)
t.test(wrf$GN25pFJ4,wrf$GN25pFJ4.Um)

t.test(cphyll$GN25pFJ9,cphyll$GN25pFJ9.Um)
t.test(nodule$GN25pFJ9,nodule$GN25pFJ9.Um)
t.test(wsf$GN25pFJ9,wsf$GN25pFJ9.Um)
t.test(wrf$GN25pFJ9,wrf$GN25pFJ9.Um)

t.test(cphyll$Uninoculated,cphyll$Um)
t.test(nodule$Uninoculated,nodule$Um)
t.test(wsf$Uninoculated,wsf$Um)
t.test(wrf$Uninoculated,wrf$Um)


str(cphyll)
summary(cphyll)
