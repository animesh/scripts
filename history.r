#plot
par(mfrow=c(1,2))
#.libPaths( c( .libPaths(), "C:/Users/animeshs/GD/R_libs") )
.libPaths()
getwd()
setwd("C:/Users/animeshs")
getwd()
#grep "pathview" *.rmd | awk -F ':' '{print $1}' | sort | uniq -c
#rm(list = ls())
#detach("package:pathview", unload=TRUE)
#plot
par(mfrow=c(1,2))
#.libPaths( c( .libPaths(), "C:/Users/animeshs/GD/R_libs") )
.libPaths()
getwd()
setwd("F:/promec/Animesh")
getwd()
#grep "pathview" *.rmd | awk -F ':' '{print $1}' | sort | uniq -c
#rm(list = ls())
#detach("package:pathview", unload=TRUE)
data<-read.csv(paste(getwd(),"200921_fraksjonANIONfrak4_URT1_20200923030614.raw.profile.intensity0.charge0.MS.txt",sep="/"),sep='\t')
hist(as.numeric(data[,2]))
hist(log2(as.numeric(data[,4])))
#https://stackoverflow.com/questions/10180132/consolidate-duplicate-rows
#dataagg<-aggregate(dataX.0.00.1'], by=data['X.0.00'], sum)
dataAnion<-data[-grep("Scan",data$Scan1),c(2,4)]
dataAnion$intensity<-as.numeric(dataAnion$intensity)
dataAnion$MZ<-strtrim(dataAnion$MZ,7)
summary(dataAnion)
data<-read.csv(paste(getwd(),"200921_fraksjonFTcation_URT1_20200923005518.raw.profile.intensity0.charge0.MS.txt",sep="/"),sep='\t')
hist(as.numeric(data[,2]))
hist(log2(as.numeric(data[,4])))
#hist(dataA[,2])
#plot(dataA[,2],dataA[,1])
#dataAnion<-tapply(dataA$X0.00.1, dataA$X0.00, sum)
#row.names(dataaggA)
dataCation<-data[-grep("Scan",data$Scan1),c(2,4)]
dataCation$intensity<-as.numeric(dataCation$intensity)
dataCation$MZ<-strtrim(dataCation$MZ,7)
summary(dataCation)
#sapply(dataAnion, as.numeric)
dataAnionAgg7lMax<-tapply(dataAnion$intensity,dataAnion$MZ,max)
summary(dataAnionAgg7lMax)
dataAnionAgg7lMaxF<-as.data.frame(dataAnionAgg7lMax)
hist(log2(dataAnionAgg7lMaxF$dataAnionAgg7lMax))
dataAnionAgg7lMaxF$MZ<-row.names(dataAnionAgg7lMaxF)
dataAnionAgg7lMaxF<-dataAnionAgg7lMaxF[dataAnionAgg7lMaxF$dataAnionAgg7lMax>10e6,]
row.names(dataAnionAgg7lMaxF)
write.csv(dataAnionAgg7lMaxF,paste(getwd(),"200921_fraksjonANIONfrak4_URT1_20200923030614.raw.profile.intensity0.charge0.MS.dataagg7lMaxF10e6.csv",sep="/"),row.names = F)
#sapply(dataAnion, as.numeric)
dataCationAgg7lMax<-tapply(dataCation$intensity,dataCation$MZ,max)
summary(dataCationAgg7lMax)
dataCationAgg7lMaxF<-as.data.frame(dataCationAgg7lMax)
hist(log2(dataCationAgg7lMaxF$dataCationAgg7lMax))
dataCationAgg7lMaxF$MZ<-row.names(dataCationAgg7lMaxF)
dataCationAgg7lMaxF<-dataCationAgg7lMaxF[dataCationAgg7lMaxF$dataCationAgg7lMax>10e6,]
row.names(dataCationAgg7lMaxF)
write.csv(dataCationAgg7lMaxF,paste(getwd(),"200921_fraksjonFTcation_URT1_20200923005518.raw.profile.intensity0.charge0.MS.dataagg7lMaxF10e6.csv",sep="/"),row.names = F)
ion<-merge(dataCationAgg7lMaxF,by.x="MZ",dataAnionAgg7lMaxF,by.y="MZ",all = T)
write.csv(ion,paste(getwd(),"200921_fraksjonION_URT1.raw.profile.intensity0.charge0.MS.dataagg7lMaxF10e6.csv",sep="/"))
View(ion)
hmdI<-read.csv(paste(getwd(),"search (7).csv",sep="/"))
hmdI<-read.csv(paste(getwd(),"search (7).csv",sep="/"))
hist(hmdI[,1])
hmdI[,1]<-sprintf(hmdI[,1], fmt = '%#.3f')
hist(hmdI[,10])
hmdIon<-merge(ion,by.x="MZ",hmdI,by.y="query_mass",all = T)
write.csv(hmdIon,paste(getwd(),"200921_hmdIon_URT1.raw.profile.intensity0.charge0.MS.dataagg7lMaxF10e6.csv",sep="/"))
metanr_packages <- function(){
metr_pkgs <- c("impute", "pcaMethods", "globaltest", "GlobalAncova", "Rgraphviz", "preprocessCore", "genefilter", "SSPA", "sva", "limma", "KEGGgraph", "siggenes","BiocParallel", "MSnbase", "multtest","RBGL","edgeR","fgsea","devtools","crmn")
list_installed <- installed.packages()
new_pkgs <- subset(metr_pkgs, !(metr_pkgs %in% list_installed[, "Package"]))
if(length(new_pkgs)!=0){if (!requireNamespace("BiocManager", quietly = TRUE))
install.packages("BiocManager")
BiocManager::install(new_pkgs)
print(c(new_pkgs, " packages added..."))
}
if((length(new_pkgs)<1)){
print("No new packages added...")
}
}
install.packages("pacman")
pacman::p_load(c("impute", "pcaMethods", "globaltest", "GlobalAncova", "Rgraphviz", "preprocessCore", "genefilter", "SSPA", "sva", "limma", "KEGGgraph", "siggenes","BiocParallel", "MSnbase", "multtest","RBGL","edgeR","fgsea"))
metanr_packages <- function(){
metr_pkgs <- c("impute", "pcaMethods", "globaltest", "GlobalAncova", "Rgraphviz", "preprocessCore", "genefilter", "SSPA", "sva", "limma", "KEGGgraph", "siggenes","BiocParallel", "MSnbase", "multtest","RBGL","edgeR","fgsea","devtools","crmn")
list_installed <- installed.packages()
new_pkgs <- subset(metr_pkgs, !(metr_pkgs %in% list_installed[, "Package"]))
if(length(new_pkgs)!=0){if (!requireNamespace("BiocManager", quietly = TRUE))
install.packages("BiocManager")
BiocManager::install(new_pkgs)
print(c(new_pkgs, " packages added..."))
}
if((length(new_pkgs)<1)){
print("No new packages added...")
}
}
metanr_packages()
metanr_packages <- function(){
metr_pkgs <- c("impute", "pcaMethods", "globaltest", "GlobalAncova", "Rgraphviz", "preprocessCore", "genefilter", "SSPA", "sva", "limma", "KEGGgraph", "siggenes","BiocParallel", "MSnbase", "multtest","RBGL","edgeR","fgsea","devtools","crmn")
list_installed <- installed.packages()
new_pkgs <- subset(metr_pkgs, !(metr_pkgs %in% list_installed[, "Package"]))
if(length(new_pkgs)!=0){if (!requireNamespace("BiocManager", quietly = TRUE))
install.packages("BiocManager")
BiocManager::install(new_pkgs)
print(c(new_pkgs, " packages added..."))
}
if((length(new_pkgs)<1)){
print("No new packages added...")
}
}
metanr_packages()
install.packages("devtools")
devtools::install_github("xia-lab/MetaboAnalystR", build = TRUE, build_vignettes = FALSE)
install.packages("devtools")
install.packages("devtools")
devtools::install_github("xia-lab/MetaboAnalystR", build = TRUE, build_vignettes = FALSE)
devtools::install_github("xia-lab/MetaboAnalystR", build = TRUE, build_vignettes = FALSE)
#plot
par(mfrow=c(1,2))
#library/packages
.libPaths( c( .libPaths(), "C:/Users/animeshs/GD/R-4.0.1/library") )
.libPaths()
#[1] "C:/Users/animeshs/GD/R-4.0.1/library"
#install.packages("lattice", repos="http://cran.r-project.org", lib="~/local/R_libs/")
#.libPaths( c( .libPaths(), "C:/Users/animeshs/GD/R_libs") )
#install.packages("writexl")
#install.packages("readxl")
#install.packages("BiocManager")
#BiocManager::install("limma")
#install.packages("matrixStats")
#directory/home
setwd("C:/Users/animeshs/GD/scripts")
getwd()
chkrVector<-c(22.39459,20.48316,21.87155,NA,20.34495)
chkrDF<-as.data.frame(chkrVector)
plot(chkrDF)
hist(as.matrix(chkrDF))
chkrDF[,1]
apply(chkrDF, 2, function(x) t.test(as.numeric(x[c(1:3)]),as.numeric(x[4:5]),na.rm=T,var.equal=T)$p.value)
t.test(as.numeric(chkrVector[c(1:3)]),as.numeric(chkrVector[4:5]),na.rm=T,var.equal=T)$p.value
t.test(as.numeric(c(22.39459,20.48316,21.87155)),as.numeric(c(NA,20.34495)),na.rm=T,var.equal=T)$p.value
t.test(c(22.39459,20.48316,21.87155),c(NA,20.34495),na.rm=T,var.equal=T)$p.value
t.test(c(22.39459,20.48316,21.87155),c(NA,17.97),na.rm=T,var.equal=T)$p.value
t.test(c(21.4316,21.77155),c(NA,17.7),na.rm=T,var.equal=T)$p.value
t.test(c(21.4316,21.77155),c(17.6,17.7),na.rm=T,var.equal=F)$p.value
BiocManager::install("limma")
dir
ls()
BiocManager::install("limma")
BiocManager::install("limma")
devtools::install_github("bartongroup/proteusLabelFree")
pacman::p_load(c("impute", "pcaMethods", "globaltest", "GlobalAncova", "Rgraphviz", "preprocessCore", "genefilter", "SSPA", "sva", "limma", "KEGGgraph", "siggenes","BiocParallel", "MSnbase", "multtest","RBGL","edgeR","fgsea"))
devtools::install_github("xia-lab/MetaboAnalystR", build = TRUE, build_vignettes = FALSE)
sessionInfo()
sessionInfo()
BiocManager::install("mzR")
devtools::install_github("xia-lab/MetaboAnalystR", build = TRUE, build_vignettes = FALSE)
BiocManager::install("ctc")
devtools::install_github("xia-lab/MetaboAnalystR", build = TRUE, build_vignettes = FALSE)
BiocManager::install(gdata)
install.packages("gdata")
devtools::install_github("xia-lab/MetaboAnalystR", build = TRUE, build_vignettes = FALSE)
Sys.setenv(R_REMOTES_NO_ERRORS_FROM_WARNINGS="true")
devtools::install_github("xia-lab/MetaboAnalystR", build = TRUE, build_vignettes = FALSE)
install.packages("glasso")
devtools::install_github("xia-lab/MetaboAnalystR", build = TRUE, build_vignettes = FALSE)
install.packages("huge")
devtools::install_github("xia-lab/MetaboAnalystR", build = TRUE, build_vignettes = FALSE)
install.packages("ppcor")
devtools::install_github("xia-lab/MetaboAnalystR", build = TRUE, build_vignettes = FALSE)
install.packages("plotly")
devtools::install_github("xia-lab/MetaboAnalystR", build = TRUE, build_vignettes = FALSE)
library(MetaboAnalystR)
savehistory("C:/Users/animeshs/GD/scripts/history.r")
