#data####
inpD <-"C:/Users/animeshs/OneDrive - NTNU/Pool/"
inpF <- paste0(inpD,"proteinGroups.txt")
data <- read.delim(inpF,sep="\t",header = T)
summary(data)


#clean####
data = data[!data$Reverse=="+",]
data = data[!data$Potential.contaminant=="+",]
data = data[!data$Only.identified.by.site=="+",]
row.names(data)<-data[["Fasta.headers"]]
data[["Uniprot"]]<-sapply(strsplit(row.names(data),";"), `[`, 1)
data[["Uniprot"]]<-sapply(strsplit(data[["Uniprot"]],"|",fixed=TRUE),`[`, 2)
summary(data)


#clean####
selection="LFQ.intensity."
LFQ<-as.matrix(data[,grep(selection,colnames(data))])
colnames(LFQ)=sub(selection,"LFQ",colnames(LFQ))
rownames(LFQ)<-data[["Uniprot"]]
summary(LFQ)


#log2####
log2LFQ<-log2(LFQ)
log2LFQ[log2LFQ==-Inf]=NA
summary(log2LFQ)


#log2noNA####
log2LFQnao<-na.omit(log2LFQ)
summary(log2LFQnao)


#components}
log2LFQt<-t(log2LFQ)
log2LFQtPCA<-prcomp(log2LFQt,scale=TRUE)
log2LFQtPCAsumm<-summary(log2LFQtPCA)
#plot(prcomp(log2LFQt))
plot(log2LFQtPCA$x[,1], log2LFQtPCA$x[,2], pch = 16, col = factor(rownames(log2LFQt)),xlab = paste0("PC1 (", round(100*log2LFQtPCAsumm$importance[2,1],1), "%)"), ylab = paste0("PC2 (", round(100*log2LFQtPCAsumm$importance[2,2],1), "%)"),main=paste("PCA 1/2 with 0 containing proteinGroups removed","\nProtein groups", dim(log2LFQt)[2],"across samples",dim(log2LFQt)[1]))
op <- par(cex = 1)
legend("bottomleft", col = factor(rownames(log2LFQt)), legend = factor(rownames(log2LFQt)), pch = 16)


#NA####
log2LFQselNA=apply(log2LFQ,1,function(x) sum(is.na(x)))
summary(log2LFQselNA)
log2LFQselNA[log2LFQselNA==max(log2LFQselNA)]
log2LFQselNA[log2LFQselNA==min(log2LFQselNA)]
hist(log2LFQselNA)
log2LFQselMean=apply(log2LFQ,1,function(x) mean(x,na.rm=T))
hist(log2LFQselMean)
plot(log2LFQselMean,log2LFQselNA)

#chkPois####
LFQsel=as.data.frame(LFQ[,grep("apim",colnames(LFQ))])
LFQselPool=LFQsel[,grep("pool",colnames(LFQsel))]
LFQsel=LFQsel[,-grep("pool",colnames(LFQsel))]
LFQselMean=apply(LFQsel,1,function(x) mean(x,na.rm=T))
hist(LFQselMean)
plot(log2(LFQselMean)-log2(LFQselPool))
hist(log2(LFQselMean)-log2(LFQselPool))
LFQselVar=apply(LFQsel,1,function(x) var(x,na.rm=T))
hist(LFQselVar)
hist(LFQselVar/LFQselMean)
plot(scale(LFQselVar/LFQselMean))
plot(sort(LFQselVar/LFQselMean))
plot(LFQselVar,LFQselMean)

#brms####
#https://cran.r-project.org/web/packages/brms/vignettes/brms_missings.html#imputation-before-model-fitting
library(mice)
imp <- mice(nhanes, m = 5, print = FALSE)
fit_imp1 <- brm_multiple(bmi ~ age*chl, data = imp, chains = 2)
summary(fit_imp1)
plot(fit_imp1, variable = "^b", regex = TRUE)
round(fit_imp1$rhats, 2)
conditional_effects(fit_imp1, "age:chl")
#during
bform <- bf(bmi | mi() ~ age * mi(chl)) +
  bf(chl | mi() ~ age) + set_rescor(FALSE)
fit_imp2 <- brm(bform, data = nhanes)
summary(fit_imp2)
conditional_effects(fit_imp2, "age:chl", resp = "bmi")
nhanes$se <- rexp(nrow(nhanes), 2)
  bform <- bf(bmi | mi() ~ age * mi(chl)) +
  bf(chl | mi(se) ~ age) + set_rescor(FALSE)
fit_imp3 <- brm(bform, data = nhanes)

#glmnet####
#https://glmnet.stanford.edu/articles/glmnet.html
#install.packages("glmnet", repos = "https://cran.us.r-project.org")
library(glmnet)
data(QuickStartExample)
x <- QuickStartExample$x
y <- QuickStartExample$y
fit <- glmnet(x, y)
plot(fit)
fit <- glmnet(LFQsel,LFQselPool)
plot(fit)
cvfit <- cv.glmnet(LFQsel,LFQselPool)

#TDA####
#https://cran.r-project.org/web/packages/TDA/index.html
#install.packages("TDA", repos = "https://cran.us.r-project.org")
library(TDA)
N<-10000
XX1 <- circleUnif(N / 2)
plot(XX1)
biplot(prcomp(XX1))
XX2 <- circleUnif(N / 2, r = 2) + 3
X <- rbind(XX1, XX2)
plot(X)
maxKDE <- maxPersistence(kde, seq(0.1, 0.6, by = 0.05), X,lim = cbind( c(-2, 5),  c(-2, 5)), by = 0.2, sublevel = FALSE,B = 50, alpha = 0.1, parallel = TRUE,printProgress = TRUE, bandFUN = "bootstrapBand")
print(summary(maxKDE))
plot(maxKDE, main = "Max Persistence - KDE")
TreeKDE <- clusterTree(X, k = 100, h = 0.3, density = "kde",printProgress = FALSE)
plot(TreeKDE)#, type = "kappa", main = "kappa Tree (knn)")
TreeKDE <- clusterTree(X, k = 100, h = 0.3, density = "kde",printProgress = FALSE)
plot(Tree, type = "kappa", main = "kappa Tree (knn)")
plot(TreeKDE, type = "lambda", main = "lambda Tree (kde)")

#QR####
#https://github.com/lme4/lme4


#QR####
#https://statisticaloddsandends.wordpress.com/2019/02/01/quantile-regression-in-r/
#install.packages('quantreg', dependencies = TRUE)
library(quantreg)
log2LFQapim<-as.data.frame(log2LFQ[,grep("apim",colnames(log2LFQ))])
heatmap(as.matrix(log2LFQapim))
colnames(log2LFQapim)
log2LFQapim[["LFQ14_TK9_apim_poolet"]]
rqfit <- rq(LFQ14_TK9_apim1 ~ LFQ14_TK9_apim_poolet, data = dataLog2)
rqfit <- rq(log2LFQapim[["LFQ14_TK9_apim_poolet"]]~log2LFQapim[["LFQ4_TK9_apim1"]])
summary(rqfit)
plot(log2LFQapim[["LFQ14_TK9_apim_poolet"]]~log2LFQapim[["LFQ4_TK9_apim1"]], pch = 16, main = "log2LFQapim[[LFQ14_TK9_apim_poolet]]~log2LFQapim[[LFQ4_TK9_apim1]]")
abline(lm(log2LFQapim[["LFQ14_TK9_apim_poolet"]]~log2LFQapim[["LFQ4_TK9_apim1"]]), col = "red", lty = 2)
abline(rq(log2LFQapim[["LFQ14_TK9_apim_poolet"]]~log2LFQapim[["LFQ4_TK9_apim1"]]), col = "blue", lty = 2)
legend("topright", legend = c("lm", "rq"), col = c("red", "blue"), lty = 2)


#overlap-plot}
log2LFQapimSort<-log2LFQapim
log2LFQapimSort<-log2LFQapimSort[order(log2LFQapimSort$LFQ14_TK9_apim_poolet),]
summary(log2LFQapimSort)
plot(log2LFQapimSort$LFQ4_TK9_apim1)
matplot(log2LFQapimSort)


#sort-overlap-plot}
log2LFQapimSort<-log2LFQapim
log2LFQapimSort<-log2LFQapimSort[order(log2LFQapimSort$LFQ14_TK9_apim_poolet),]
summary(log2LFQapimSort)
plot(log2LFQapimSort$LFQ4_TK9_apim1)
matplot(log2LFQapimSort)
log2LFQapimSort<-log2LFQapimSort-log2LFQapimSort[["LFQ14_TK9_apim_poolet"]]
matplot(log2LFQapimSort)


#enrich}
row.names(log2LFQapimSort)
search()



#diff}
dataV<-log2LFQapim
cn<-strsplit(colnames(dataV), "_")
colnames(dataV)<-paste(sapply(cn, "[", 3),sapply(cn, "[", 4))
library(limma)
dataV<-dataV-dataV[["apim poolet"]]
plot(dataV)
hist(dataV)
plot(sort(rowMeans(dataV)))#,rowMedians(dataV))
vennDiagram(dataV-dataV[["apim poolet"]])
selThr<-(-0.58)
vennDiagram(dataV<selThr)
selThr<-0.58
vennDiagram(dataV>selThr)
selThr<-0.58
vennDiagram(abs(dataV)>selThr)
hist(rowSums(as.matrix(dataV)))
hist(data[dataV>selThr,])#protein


#overlap-plot}
library(ggplot2)
ggsave(file=paste0(inpF,"venn.svg"),plot=vennDiagram(dataV<selThr))#,  width=6, height=6)


#sel-WSRT}
dataS<-data[(data$ONO_.WSRT<selThr & data$CCAR_.WSRT<selThr) | (data$ONO_.WSRT<selThr & data$B_.WSRT<selThr) | (data$B_.WSRT<selThr & data$CCAR_.WSRT<selThr) | (data$ONO_.WSRT<selThr & data$NB_.WSRT<selThr) | (data$NB_.WSRT<selThr & data$CCAR_.WSRT<selThr) | (data$NB_.WSRT<selThr & data$B_.WSRT<selThr) ,]
hist(rowSums(as.matrix(dataS[,c(1,2,3,6)])))
vennDiagram(dataS[,c(1,2,3,6)]<selThr)



#map-ID}
dataS<-data
library(org.Hs.eg.db)
uniP<-c("P07237","P28331","Q12931")
select(org.Hs.eg.db, uniP, "ENTREZID", "UNIPROT")
library(clusterProfiler)
#http://data.wikipathways.org/current/gmt/
wp2gene <- read.gmt("L:/promec/Animesh/Lisa/wikipathways-20191010-gmt-Homo_sapiens.gmt")
library(magrittr)
wp2gene <- wp2gene %>% tidyr::separate(ont, c("name","version","wpid","org"), "%")
wpid2gene <- wp2gene %>% dplyr::select(wpid, gene) #TERM2GENE
wpid2name <- wp2gene %>% dplyr::select(wpid, name) #TERM2NAME
wpid2name[grep("apoptosis",wpid2name$name,ignore.case = TRUE),]
wpid2name[grep("stat",wpid2name$name,ignore.case = TRUE),]
wpid2name[grep("mapk",wpid2name$name,ignore.case = TRUE),]
wpid2name[grep("akt",wpid2name$name,ignore.case = TRUE),]
wpid2name[grep("mtor",wpid2name$name,ignore.case = TRUE),]
wpid2name[grep("pi3k",wpid2name$name,ignore.case = TRUE),]
#select(org.Hs.eg.db, uniP, "GENENAME", "UNIPROT")
#select(org.Hs.eg.db, uniP, "SYMBOL", "UNIPROT")
uniP<-data$T..Uniprot
uniP <- lapply(uniP, as.character)
unlist(uniP)
uniP[[1]]
select(org.Hs.eg.db, unlist(uniP[[1]]), "ENTREZID", "UNIPROT")
uniL<-select(org.Hs.eg.db, unlist(uniP), "ENTREZID", "UNIPROT")
wpid2gene[grep(uniL$ENTREZID[1],wpid2gene$gene,ignore.case = TRUE),]
wpid2gene[grep("361",wpid2gene$gene,ignore.case = TRUE),]
uniprots <- Rkeys(org.Hs.egUNIPROT)
uniprots2entrez <- select(org.Hs.eg.db, uniprots, "ENTREZID", "UNIPROT")
dataSez<-merge(dataS, uniprots2entrez, by.x="T..Uniprot", by.y="UNIPROT")
dataSez<-merge(dataS, uniprots2entrez, by.x="T..Entry", by.y="UNIPROT")
dataSezWP<-merge(dataSez, wp2gene, by.x="ENTREZID", by.y="gene")
#rownames(dataSezWP)<-paste(dataSezWP$T..T..Uniprot,dataSezWP$T..T..Line,dataSezWP$name,dataSezWP$ENTREZID,sep = "_")
rownames(dataSezWP)<-paste(dataSezWP$T..T..Uniprot,dataSezWP$T..T..Line,dataSezWP$ENTREZID,dataSezWP$name,sep = "_")
#dataS<-dataSezWP


#apim####
dataSel <- data[,grep("apim", colnames(data),ignore.case=TRUE)]
rownames(dataSel)<-paste0(data$T..Protein.IDs,"_APIM")
dataSel<-dataSel[,c(6:9)]
cn<-strsplit(colnames(dataSel), "_")
colnames(dataSel)<-paste0(sapply(cn, "[", 3),sapply(cn, "[", 4))
vennDiagram(dataSel[,c(1:4)]<selThr,main="APIM",counts.col = "red")
summary(dataSel)
hist(as.matrix(dataSel[,c(2:4)]))
plot(dataSel)


#apim-model####
#https://www.statmethods.net/advstats/glm.html
#fit <- glm(dataSel$apimpoolet~dataSel$apim1x.y+dataSel$apim2+dataSel$apim3)#,family=binomial())
library(quantreg)
qrFit <- rq(dataSel$apimpoolet~dataSel$apim1NA)
summary(qrFit)
plot(summary(qrFit),par="x")
fit <- glm(dataSel$apimpoolet~dataSel$apim1NA+dataSel$apim2+dataSel$apim3)#,family=binomial())
summary(fit) # display results
confint(fit) # 95% CI for the coefficients
exp(coef(fit)) # exponentiated coefficients
exp(confint(fit)) # 95% CI for exponentiated coefficients
predVal<-predict(fit, type="response")# predicted values
cor(predVal,dataSel$apimpoolet)
cor(dataSel)
plot(predVal,dataSel$apimpoolet)
residuals(fit, type="deviance") # residuals


#stat####
dataSel <- dataSezWP[grep("stat", dataSezWP$name,ignore.case=TRUE),]
vennDiagram(dataSel[,c(3,4,5,8)]<selThr,main="STAT",counts.col = "red")
dataSel<-dataSel[,grep("_x.y_",colnames(dataSel))]
dataSel<-dataSel[,-grep("D_x.y_",colnames(dataSel))]
dataSel<-dataSel[,-grep("C_x.y_",colnames(dataSel))]
rownames(dataSel)<-paste0(rownames(dataSel),"_STAT")
dataSelSTAT<-dataSel
summary(dataSelSTAT)


#mapk####
dataSel <- dataSezWP[grep("mapk", dataSezWP$name,ignore.case=TRUE),]
vennDiagram(dataSel[,c(3,4,5,8)]<selThr,main="MAPK",counts.col = "red")
dataSel<-dataSel[,grep("_x.y_",colnames(dataSel))]
dataSel<-dataSel[,-grep("D_x.y_",colnames(dataSel))]
dataSel<-dataSel[,-grep("C_x.y_",colnames(dataSel))]
rownames(dataSel)<-paste0(rownames(dataSel),"_MAPK")
dataSelMAPK<-dataSel
summary(dataSelMAPK)


#ampk####
dataSel <- dataSezWP[grep("ampk", dataSezWP$name,ignore.case=TRUE),]
vennDiagram(dataSel[,c(3,4,5,8)]<selThr,main="AMPK",counts.col = "red")
dataSel<-dataSel[,grep("_x.y_",colnames(dataSel))]
dataSel<-dataSel[,-grep("D_x.y_",colnames(dataSel))]
dataSel<-dataSel[,-grep("C_x.y_",colnames(dataSel))]
rownames(dataSel)<-paste0(rownames(dataSel),"_AMPK")
dataSelAMPK<-dataSel
summary(dataSelAMPK)


#PI3K/AKT/mTOR####
dataSelPI3K <- dataSezWP[(grep("PI3K", dataSezWP$name,ignore.case=TRUE)),]
dataSelAKT <- dataSezWP[(grep("AKT", dataSezWP$name,ignore.case=TRUE)),]
dataSelmTOR <- dataSezWP[(grep("mTOR", dataSezWP$name,ignore.case=TRUE)),]
dataSel_PI3KAKTmTOR <- dataSezWP[(grep("PI3K-Akt-mTOR", dataSezWP$name,ignore.case=TRUE)),]
#dataSel <- dataSezWP[(grep("AKT", dataSezWP$name,ignore.case=TRUE))|(grep("PI3K", dataSezWP$name,ignore.case=TRUE))|(grep("mTOR", dataSezWP$name,ignore.case=TRUE)),]
dataSel<-dataSel_PI3KAKTmTOR#rbind(dataSelPI3K,dataSelAKT,dataSelmTOR)
#pathwayN<-sapply(strsplit(row.names(dataSel),"_"), `[`, 1)
#dataSel<-cbind.data.frame(dataSel,pathwayN)
#dataSel=subset(dataSel, !duplicated(pathwayN))
#dataSel<-as.matrix(dataSel[,-13])
summary(dataSel)
vennDiagram(dataSel[,c(3,4,5,8)]<selThr,main="PI3K/AKT/mTOR",counts.col = "red")
dataSel<-dataSel[,grep("_x.y_",colnames(dataSel))]
dataSel<-dataSel[,-grep("D_x.y_",colnames(dataSel))]
dataSel<-dataSel[,-grep("C_x.y_",colnames(dataSel))]
rownames(dataSel)<-paste0(rownames(dataSel),"_PI3K/AKT/mTOR")
dataSel_PI3KAKTmTOR<-dataSel
summary(dataSel_PI3KAKTmTOR)


#Apoptosis####
dataSel <- dataSezWP[grep("apoptosis", dataSezWP$name,ignore.case=TRUE),]
vennDiagram(dataSel[,c(3,4,5,8)]<selThr,main="Apoptosis",counts.col = "red")
dataSel<-dataSel[,grep("_x.y_",colnames(dataSel))]
dataSel<-dataSel[,-grep("D_x.y_",colnames(dataSel))]
dataSel<-dataSel[,-grep("C_x.y_",colnames(dataSel))]
#data_apop <- data[grep("apoptosis", data$C..Gene.ontology..GO.),]
#data_jak <- data[grep("apoptosis", data$C..Gene.ontology..GO.),]
#data_mapk <- data[grep("apoptosis", data$C..Gene.ontology..GO.),]
#data_jaks <- data[grep("jak", data$C..KEGG.name),]
#data_mapk <- data[grep("mapk signaling pathway", data$C..KEGG.name),]
#data_selr <- data[grep("MAPK signaling pathway", data$C..KEGG.name),]
#data_selr<-rbind.data.frame(data_apop,data_apop,data_mapk)
rownames(dataSel)<-paste0(rownames(dataSel),"_Apopto")
dataSelApoptosis<-dataSel
summary(dataSelApoptosis)



#sel-data-cols####
data_selr_s<-rbind.data.frame(dataSelApoptosis)#,dataSelMAPK,dataSelSTAT,dataSelAMPK,dataSel_PI3KAKTmTOR)
#data_selr[data_selr==0]=NA
#install.packages("scales")
library(scales)
data_selr=squish(as.matrix(data_selr_s),c(-3,3))
data_selr[is.na(data_selr)]=0
#library(quantable)
#data_selr_s=robustscale(data_selr,dim=1,center = FALSE)#,scale=TRUE,  preserveScale = FALSE)
#data_selr_s=data_selr_s$data
#data_selr$data[is.na(data_selr$data)]<-0
#y$data<-y$data[-(which(rowSums(y$data) == 0)),]
#data_selr<-dataSel
#data_selr<-data_selr$data
#data_selr<-data_selr[-(which(rowSums(data_selr) == 0)),]
summary(data_selr)
hist(as.matrix(data_selr))
#data_selr['pathwayN']<-sapply(strsplit(row.names(data_selr),"_"), `[`, 1)
pathwayN<-sapply(strsplit(row.names(data_selr),"_"), `[`, 1)
data_selr<-cbind.data.frame(data_selr,pathwayN)
#data_selr=subset(data_selr, !duplicated(pathwayN))
#row.names(data_selr)=data_selr$pathwayN
data_selr<-as.matrix(data_selr[,-13])
#pathwayN<-sapply(strsplit(row.names(data_selr),"_"), `[`, 5)
summary(data_selr)
#hist(as.matrix(data_selr))
#

##clust-plot####
#install.packages('pheatmap')
library(pheatmap)
#?pheatmap
#rn<-sub(";","",data_selr$T..T..Gene.names)
data_selr=data_selr[,c(10,11,12,4,5,6,7,8,9,1,2,3)]
#data_selr[data_selr==0]=NA
summary(data_selr)
hist(data_selr)
rn<-sub(";","",rownames(data_selr))
#rn<-strsplit(rn, "apolipoprotein")
#rn<-strsplit(rn, " ")
row.names(data_selr)<-paste(sapply(rn, "[", 1))#,sapply(rn, "[", 3),sapply(rn, "[", 6))
cn<-strsplit(colnames(data_selr), "_")
colnames(data_selr)<-paste(sapply(cn, "[", 1))
#svgPHC<-pheatmap(y,scale="row",clustering_distance_rows = "correlation",clustering_distance_cols = "correlation",fontsize_row=6)#,annotation_col = label,show_rownames=F)
#https://stackoverflow.com/a/44400007/1137129
bk1 <- c(seq(-1,-0.01,by=0.01))
bk2 <- c(seq(0.01,1,by=0.01))
bk <- c(bk1,bk2)  #combine the break limits for purpose of graphing
my_palette <- c(colorRampPalette(colors = c("darkblue", "white"))(n = length(bk1)-1),
              "gray", "gray",
              c(colorRampPalette(colors = c("white","darkred"))(n = length(bk2)-1)))
svgPHC<-pheatmap(data_selr,clustering_distance_rows = "correlation",clustering_distance_cols = "correlation",fontsize_row=6,cluster_cols=FALSE,cluster_rows=TRUE,color = my_palette)#,labels_row =  pathwayN,scale="row",annotation_col = label,show_rownames=F)
#svgPHC<-pheatmap(data_selr,scale="row",clustering_distance_rows = "correlation",clustering_distance_cols = "correlation",fontsize_row=6,cluster_cols=FALSE,labels_row =  pathwayN,cluster_rows=TRUE,color = colorRampPalette(c( "navy", "white","firebrick"))(50),na_col = "grey")#,annotation_col = label,show_rownames=F)
library(ggplot2)
#ggsave(file=paste0(inpF,"corrcoefED.svg"), plot=svgPHC, width=6, height=6)
#plot(svgPHC)
ggsave(file=paste0(inpD,"clusterPlot.ApoptoMAPKSTATAMPKPI3KAKTmTOR.svg"),plot=svgPHC)#,  width=6, height=6)
#ggsave(file=paste0(inpD,hdr,"clusterPlot.Apoptosis.svg"),plot=svgPHC)#,  width=6, height=6)
#ggsave(file=paste0(inpD,hdr,"clusterPlot.MAPK.svg"),plot=svgPHC)#,  width=6, height=6)


#apohc-sel-data-cols####
data_selr_s<-dataSelApoptosis
library(scales)
data_selr=squish(as.matrix(data_selr_s),c(-3,3))
data_selr[is.na(data_selr)]=0
summary(data_selr)
hist(as.matrix(data_selr))
pathwayN<-sapply(strsplit(row.names(data_selr),"_"), `[`, 1)
data_selr<-cbind.data.frame(data_selr,pathwayN)
data_selr=subset(data_selr, !duplicated(pathwayN))
data_selr<-as.matrix(data_selr[,-13])
summary(data_selr)
library(pheatmap)
data_selr=data_selr[,c(10,11,12,4,5,6,7,8,9,1,2,3)]
summary(data_selr)
hist(data_selr)
rn<-sub(";","",rownames(data_selr))
row.names(data_selr)<-paste(sapply(rn, "[", 1))#,sapply(rn, "[", 3),sapply(rn, "[", 6))
cn<-strsplit(colnames(data_selr), "_")
colnames(data_selr)<-paste(sapply(cn, "[", 1))
bk1 <- c(seq(-3,-0.01,by=0.01))
bk2 <- c(seq(0.01,3,by=0.01))
bk <- c(bk1,bk2)  #combine the break limits for purpose of graphing
my_palette <- c(colorRampPalette(colors = c("darkblue", "white"))(n = length(bk1)-1),
              "gray", "gray",
              c(colorRampPalette(colors = c("white","darkred"))(n = length(bk2)-1)))
svgPHC<-pheatmap(data_selr,clustering_distance_rows = "correlation",clustering_distance_cols = "correlation",fontsize_row=6,cluster_cols=FALSE,cluster_rows=TRUE,color = my_palette)#,labels_row =  pathwayN,scale="row",annotation_col = label,show_rownames=F)
library(ggplot2)
ggsave(file=paste0(inpD,"clusterPlot.Apoptosis.svg"),plot=svgPHC)#,

#sel-data-cols####
data_selr_s<-dataSelApoptosis
library(scales)
data_selr=squish(as.matrix(data_selr_s),c(-3,3))
data_selr[is.na(data_selr)]=0
summary(data_selr)
hist(as.matrix(data_selr))
pathwayN<-sapply(strsplit(row.names(data_selr),"_"), `[`, 1)
data_selr<-cbind.data.frame(data_selr,pathwayN)
data_selr=subset(data_selr, !duplicated(pathwayN))
data_selr<-as.matrix(data_selr[,-13])
summary(data_selr)
library(pheatmap)
data_selr=data_selr[,c(10,11,12,4,5,6,7,8,9,1,2,3)]
summary(data_selr)
hist(data_selr)
rn<-sub(";","",rownames(data_selr))
row.names(data_selr)<-paste(sapply(rn, "[", 1))#,sapply(rn, "[", 3),sapply(rn, "[", 6))
cn<-strsplit(colnames(data_selr), "_")
colnames(data_selr)<-paste(sapply(cn, "[", 1))
bk1 <- c(seq(-3,-0.01,by=0.01))
bk2 <- c(seq(0.01,3,by=0.01))
bk <- c(bk1,bk2)  #combine the break limits for purpose of graphing
my_palette <- c(colorRampPalette(colors = c("darkblue", "white"))(n = length(bk1)-1),
              "gray", "gray",
              c(colorRampPalette(colors = c("white","darkred"))(n = length(bk2)-1)))
svgPHC<-pheatmap(data_selr,clustering_distance_rows = "correlation",clustering_distance_cols = "correlation",fontsize_row=6,cluster_cols=FALSE,cluster_rows=TRUE,color = my_palette)#,labels_row =  pathwayN,scale="row",annotation_col = label,show_rownames=F)
library(ggplot2)
ggsave(file=paste0(inpD,"clusterPlot.Apoptosis.svg"),plot=svgPHC)#,

#mapkhc-sel-data-cols####
data_selr_s<-dataSelMAPK
library(scales)
data_selr=squish(as.matrix(data_selr_s),c(-3,3))
data_selr[is.na(data_selr)]=0
summary(data_selr)
hist(as.matrix(data_selr))
pathwayN<-sapply(strsplit(row.names(data_selr),"_"), `[`, 1)
data_selr<-cbind.data.frame(data_selr,pathwayN)
data_selr=subset(data_selr, !duplicated(pathwayN))
data_selr<-as.matrix(data_selr[,-13])
summary(data_selr)
library(pheatmap)
data_selr=data_selr[,c(10,11,12,4,5,6,7,8,9,1,2,3)]
summary(data_selr)
hist(data_selr)
rn<-sub(";","",rownames(data_selr))
row.names(data_selr)<-paste(sapply(rn, "[", 1))#,sapply(rn, "[", 3),sapply(rn, "[", 6))
cn<-strsplit(colnames(data_selr), "_")
colnames(data_selr)<-paste(sapply(cn, "[", 1))
bk1 <- c(seq(-3,-0.01,by=0.01))
bk2 <- c(seq(0.01,3,by=0.01))
bk <- c(bk1,bk2)  #combine the break limits for purpose of graphing
my_palette <- c(colorRampPalette(colors = c("darkblue", "white"))(n = length(bk1)-1),
              "gray", "gray",
              c(colorRampPalette(colors = c("white","darkred"))(n = length(bk2)-1)))
svgPHC<-pheatmap(data_selr,clustering_distance_rows = "correlation",clustering_distance_cols = "correlation",fontsize_row=6,cluster_cols=FALSE,cluster_rows=TRUE,color = my_palette)#,labels_row =  pathwayN,scale="row",annotation_col = label,show_rownames=F)
library(ggplot2)
ggsave(file=paste0(inpD,"clusterPlot.MAPK.svg"),plot=svgPHC)#,

#ampkhc-sel-data-cols####
data_selr_s<-dataSelAMPK
library(scales)
data_selr=squish(as.matrix(data_selr_s),c(-3,3))
data_selr[is.na(data_selr)]=0
summary(data_selr)
hist(as.matrix(data_selr))
pathwayN<-sapply(strsplit(row.names(data_selr),"_"), `[`, 1)
data_selr<-cbind.data.frame(data_selr,pathwayN)
data_selr=subset(data_selr, !duplicated(pathwayN))
data_selr<-as.matrix(data_selr[,-13])
summary(data_selr)
library(pheatmap)
data_selr=data_selr[,c(10,11,12,4,5,6,7,8,9,1,2,3)]
summary(data_selr)
hist(data_selr)
rn<-sub(";","",rownames(data_selr))
row.names(data_selr)<-paste(sapply(rn, "[", 1))#,sapply(rn, "[", 3),sapply(rn, "[", 6))
cn<-strsplit(colnames(data_selr), "_")
colnames(data_selr)<-paste(sapply(cn, "[", 1))
bk1 <- c(seq(-3,-0.01,by=0.01))
bk2 <- c(seq(0.01,3,by=0.01))
bk <- c(bk1,bk2)  #combine the break limits for purpose of graphing
my_palette <- c(colorRampPalette(colors = c("darkblue", "white"))(n = length(bk1)-1),
              "gray", "gray",
              c(colorRampPalette(colors = c("white","darkred"))(n = length(bk2)-1)))
svgPHC<-pheatmap(data_selr,clustering_distance_rows = "correlation",clustering_distance_cols = "correlation",fontsize_row=6,cluster_cols=FALSE,cluster_rows=TRUE,color = my_palette)#,labels_row =  pathwayN,scale="row",annotation_col = label,show_rownames=F)
library(ggplot2)
ggsave(file=paste0(inpD,"clusterPlot.AMPK.svg"),plot=svgPHC)#,

#stathc-sel-data-cols####
data_selr_s<-dataSelSTAT
library(scales)
data_selr=squish(as.matrix(data_selr_s),c(-3,3))
data_selr[is.na(data_selr)]=0
summary(data_selr)
hist(as.matrix(data_selr))
pathwayN<-sapply(strsplit(row.names(data_selr),"_"), `[`, 1)
data_selr<-cbind.data.frame(data_selr,pathwayN)
data_selr=subset(data_selr, !duplicated(pathwayN))
data_selr<-as.matrix(data_selr[,-13])
summary(data_selr)
library(pheatmap)
data_selr=data_selr[,c(10,11,12,4,5,6,7,8,9,1,2,3)]
summary(data_selr)
hist(data_selr)
rn<-sub(";","",rownames(data_selr))
row.names(data_selr)<-paste(sapply(rn, "[", 1))#,sapply(rn, "[", 3),sapply(rn, "[", 6))
cn<-strsplit(colnames(data_selr), "_")
colnames(data_selr)<-paste(sapply(cn, "[", 1))
bk1 <- c(seq(-3,-0.01,by=0.01))
bk2 <- c(seq(0.01,3,by=0.01))
bk <- c(bk1,bk2)  #combine the break limits for purpose of graphing
my_palette <- c(colorRampPalette(colors = c("darkblue", "white"))(n = length(bk1)-1),
              "gray", "gray",
              c(colorRampPalette(colors = c("white","darkred"))(n = length(bk2)-1)))
svgPHC<-pheatmap(data_selr,clustering_distance_rows = "correlation",clustering_distance_cols = "correlation",fontsize_row=6,cluster_cols=FALSE,cluster_rows=TRUE,color = my_palette)#,labels_row =  pathwayN,scale="row",annotation_col = label,show_rownames=F)
library(ggplot2)
ggsave(file=paste0(inpD,"clusterPlot.STAT.svg"),plot=svgPHC)#,

#pi3kallhc-sel-data-cols####
data_selr_s<-dataSel_PI3KAKTmTOR
library(scales)
data_selr=squish(as.matrix(data_selr_s),c(-3,3))
data_selr[is.na(data_selr)]=0
summary(data_selr)
hist(as.matrix(data_selr))
pathwayN<-sapply(strsplit(row.names(data_selr),"_"), `[`, 1)
data_selr<-cbind.data.frame(data_selr,pathwayN)
data_selr=subset(data_selr, !duplicated(pathwayN))
data_selr<-as.matrix(data_selr[,-13])
summary(data_selr)
library(pheatmap)
data_selr=data_selr[,c(10,11,12,4,5,6,7,8,9,1,2,3)]
summary(data_selr)
hist(data_selr)
rn<-sub(";","",rownames(data_selr))
row.names(data_selr)<-paste(sapply(rn, "[", 1))#,sapply(rn, "[", 3),sapply(rn, "[", 6))
cn<-strsplit(colnames(data_selr), "_")
colnames(data_selr)<-paste(sapply(cn, "[", 1))
bk1 <- c(seq(-3,-0.01,by=0.01))
bk2 <- c(seq(0.01,3,by=0.01))
bk <- c(bk1,bk2)  #combine the break limits for purpose of graphing
my_palette <- c(colorRampPalette(colors = c("darkblue", "white"))(n = length(bk1)-1),
              "gray", "gray",
              c(colorRampPalette(colors = c("white","darkred"))(n = length(bk2)-1)))
svgPHC<-pheatmap(data_selr,clustering_distance_rows = "correlation",clustering_distance_cols = "correlation",fontsize_row=6,cluster_cols=FALSE,cluster_rows=TRUE,color = my_palette)#,labels_row =  pathwayN,scale="row",annotation_col = label,show_rownames=F)
library(ggplot2)
ggsave(file=paste0(inpD,"clusterPlot.PI3Ketc.svg"),plot=svgPHC)#,


#sel-data-cols####
data_selr_s<-rbind.data.frame(dataSelMAPK)
library(scales)
data_selr=squish(as.matrix(data_selr_s),c(-3,3))
data_selr[is.na(data_selr)]=0
summary(data_selr)
hist(as.matrix(data_selr))
pathwayN<-sapply(strsplit(row.names(data_selr),"_"), `[`, 1)
data_selr<-cbind.data.frame(data_selr,pathwayN)
data_selr<-as.matrix(data_selr[,-13])
summary(data_selr)
library(pheatmap)
data_selr=data_selr[,c(10,11,12,4,5,6,7,8,9,1,2,3)]
summary(data_selr)
hist(data_selr)
rn<-sub(";","",rownames(data_selr))
row.names(data_selr)<-paste(sapply(rn, "[", 1))#,sapply(rn, "[", 3),sapply(rn, "[", 6))
cn<-strsplit(colnames(data_selr), "_")
colnames(data_selr)<-paste(sapply(cn, "[", 1))
bk1 <- c(seq(-1,-0.01,by=0.01))
bk2 <- c(seq(0.01,1,by=0.01))
bk <- c(bk1,bk2)  #combine the break limits for purpose of graphing
my_palette <- c(colorRampPalette(colors = c("darkblue", "white"))(n = length(bk1)-1),
              "gray", "gray",
              c(colorRampPalette(colors = c("white","darkred"))(n = length(bk2)-1)))
svgPHC<-pheatmap(data_selr,clustering_distance_rows = "correlation",clustering_distance_cols = "correlation",fontsize_row=6,cluster_cols=FALSE,cluster_rows=TRUE,color = my_palette)#,labels_row =  pathwayN,scale="row",annotation_col = label,show_rownames=F)
library(ggplot2)
ggsave(file=paste0(inpD,"clusterPlot.MAPK.svg"),plot=svgPHC)#,



#select-hdr-log2####
#hdr="LFQ.intensity."
hdr="Ratio.H.L.6"
datLog2LFQ=log2(data[,grep(hdr, names(data))])
summary(datLog2LFQ)
hist(as.matrix(datLog2LFQ))


#remove-samples####
samples="ENDOSOME"
datLog2LFQ=log2(datLog2LFQ[,-grep(samples, names(datLog2LFQ))])
summary(datLog2LFQ)
hist(as.matrix(datLog2LFQ))


#select-grp####
group="PCI"
datLog2LFQ=log2(datLog2LFQ[,grep(group, names(datLog2LFQ))])
summary(datLog2LFQ)
hist(as.matrix(datLog2LFQ))


#select-grp####
group="PDT"
datLog2LFQ=log2(datLog2LFQ[,grep(group, names(datLog2LFQ))])
summary(datLog2LFQ)
hist(as.matrix(datLog2LFQ))


#select-grp####
group="bleomycin"
datLog2LFQ=log2(datLog2LFQ[,grep(group, names(datLog2LFQ))])
summary(datLog2LFQ)
hist(as.matrix(datLog2LFQ))


#clean####
decoyPrefix="REV"
dataClean<-data[-grep(decoyPrefix, rownames(data)),]
dfNoRev = data[!data$Reverse=="+",]
setdiff(rownames(dataClean),rownames(dfNoRev))
setdiff(rownames(dfNoRev),rownames(dataClean))
decoyPrefix="REV__"
dataClean<-data[-grep(decoyPrefix, rownames(data)),]
setdiff(rownames(dataClean),rownames(dfNoRev))
setdiff(rownames(dfNoRev),rownames(dataClean))
contaminantPrefix="CON__"
#dataClean<-dataClean[-grep(contaminantPrefix, rownames(dataClean)),]
dataClean=dataClean[!dataClean$Potential.contaminant=="+",]
#dataClean=dataClean[!dataClean$Only.identified.by.site=="+",]
summary(dataClean)



#norm####
hdr="LFQ.intensity."
dataNorm=log2(dataClean[,grep(hdr, names(dataClean))])
summary(dataNorm)
hist(as.matrix(dataNorm))


#select####
dataNormFilter<-dataNorm
dataNormFilter[dataNormFilter==-Inf]=NA
summary(dataNormFilter)
selThr<-2
dataNormFilter$Red = apply(dataNormFilter,1,function(x) sum(is.na(x[3:5])))
dataNormFilter$White = apply(dataNormFilter,1,function(x) sum(is.na(x[c(1,2,6)])))
dataNormFilter.Select = dataNormFilter[dataNormFilter$Red<selThr | dataNormFilter$White<selThr,1:6]
summary(dataNormFilter.Select)



#euler,echo=F}
#install.packages('eulerr')
library(eulerr)
#install.packages('ggplot2')
library(ggplot2)
euler(dataNormFilter[,8:7]<2,shape="ellipse")$original.values
vplot<-plot(euler(dataNormFilter[,8:7]<selThr,shape="ellipse"),quantities=TRUE, col="black",fill=c("white","red"),main="Identified Protein Groups in Salmon Types")
plot(vplot)
#iinstall.packages("ggplot2")
#library(ggplot2)
#install.packages("svglite")
#library(svglite)
ggsave(file=paste0(inpD,hdr,"venn.svg"),plot=vplot)#,  width=6, height=6)



#imputeFilter####
dataNormImpFilter<-dataNormFilter.Select
summary(dataNormImpFilter)
set.seed(1)
#dataNormImpFilter[is.na(dataNormImpFilter)]<-rnorm(sum(is.na(dataNormImpFilter)),mean=mean(dataNormImpFilter[!is.na(dataNormImpFilter)])-3,sd=sd(!is.na(dataNormImpFilter))/3)
dataNormImpFilter[is.na(dataNormImpFilter)]<-rnorm(sum(is.na(dataNormImpFilter)),mean=mean(dataNormImpFilter[!is.na(dataNormImpFilter)])-12,sd=sd(!is.na(dataNormImpFilter))/12)
summary(dataNormImpFilter)
hist(as.matrix(dataNormImpFilter))


#PCA####
dataNormImpCom<-dataNormImpFilter
plot(princomp(dataNormImpCom))
#biplot(prcomp(as.matrix(t(dataNormImpCom)),scale = T))
#biplot(prcomp(dataNormImpCom,scale = F))
#biplot(prcomp(dataNormImpCom,scale = T),col=c(1,8), cex=c(0.5, 0.4))


#t-test####
pVal = apply(dataNormImpFilter, 1, function(x) t.test(as.numeric(x[c(3:5)]),as.numeric(x[c(1,2,6)]),var.equal=T)$p.value)
logFC = rowMeans(dataNormImpFilter[,c(3:5)])-rowMeans(dataNormImpFilter[,c(1,2,6)])
ttest.results = data.frame(gene=rownames(dataNormImpFilter),logFC=logFC,P.Value = pVal, adj.pval = p.adjust(pVal,method = "BH"))
#ttest.results$PSMcount = psm.count.table[ttest.results$gene,"count"]
ttest.results = ttest.results[with(ttest.results, order(P.Value)), ]
head(ttest.results)
write.csv(ttest.results,file=paste0(inpD,hdr,"tTestBH.csv"))
plot(logFC,-log10(pVal),col="orange",)



#t-test-plot####
dsub=subset(ttest.results,ttest.results$P.Value<0.05&abs(ttest.results$logFC)>0.58)
#rn<-do.call(rbind, strsplit(rownames(dsub), '\\.'))
rn<-strsplit(rownames(dsub), ';')
row.names(dsub) <- sapply(rn, "[", 1)#rn[[1]]
g = ggplot(ttest.results,aes(logFC,-log10(P.Value)))+geom_point(aes(color=adj.pval),size=0.15) + theme_bw(base_size=10) +geom_text(data=dsub,aes(label=row.names(dsub)), vjust=0.5, size=1.5) + xlab("Log2 Fold Change (Red-White)")  + ylab("-Log10 P-value") + ggtitle("Differentially expressed proteins") + scale_size_area()+scale_color_gradient(low="#FF9933", high="#99CC66")
plot(g)
#install.packages('svglite')
ggsave(file=paste0(inpD,hdr,"volcanoPlot.svg"),plot=g)#,  width=6, height=6)


#t-test-fraction-plot####
#dsub=data[grep("apo",data$Fasta.headers),]
dsub=data[(grepl("apo",data$Fasta.headers))|(grepl("alb",data$Fasta.headers)),]
dsub=merge(dsub,ttest.results,by="row.names")
rn<-strsplit(dsub$Row.names, ';')
row.names(dsub) <- sapply(rn, "[", 1)#rn[[1]]
g = ggplot(ttest.results,aes(logFC,-log10(P.Value)))+geom_point(aes(color=adj.pval),size=0.15) + theme_bw(base_size=10) +geom_text(data=dsub,aes(label=row.names(dsub)), vjust=0.5, size=1.5) + xlab("Log2 Fold Change (Red-White)")  + ylab("-Log10 P-value") + ggtitle("Differentially expressed proteins") + scale_size_area()+scale_color_gradient(low="#FF9933", high="#99CC66")
plot(g)
ggsave(file=paste0(inpD,hdr,"volcanoPlot.frac.svg"),plot=g)#,  width=6, height=6)


#fraction-clust-plot####
#install.packages('pheatmap')
library(pheatmap)
#?pheatmap
y<-as.matrix(dsub[,grepl("Fraction\\.[0-9]+",colnames(dsub))])
#yy<-as.matrix(data[grepl("albumin",data$Fasta.headers),])

y[is.na(y)]<-0
rn<-sub(";","",dsub$Fasta.headers)
#rn<-strsplit(rn, "apolipoprotein")
rn<-strsplit(rn, " ")
row.names(y)<-paste(sapply(rn, "[", 1),sapply(rn, "[", 3),sapply(rn, "[", 6))
summary(y)
#svgPHC<-pheatmap(y,scale="row",clustering_distance_rows = "correlation",clustering_distance_cols = "correlation",fontsize_row=6)#,annotation_col = label,show_rownames=F)
svgPHC<-pheatmap(y,scale="row",clustering_distance_rows = "correlation",clustering_distance_cols = "correlation",fontsize_row=6,cluster_cols=FALSE)#,annotation_col = label,show_rownames=F)
#ggsave(file=paste0(inpF,"corrcoefED.svg"), plot=svgPHC, width=6, height=6)
plot(svgPHC)
ggsave(file=paste0(inpD,hdr,"clusterPlot.frac.svg"),plot=svgPHC)#,  width=6, height=6)



#ROTS####
#iocManager::install("ROTS")#, version = "3.8")
dataNormImpCom<-dataNormImpFilter#[is.na(dataNormImpCom)]=5
summary(dataNormImpCom)
factors<-c(1,1,2,2,2,1)
library(ROTS)
results = ROTS(data = dataNormImpCom, groups = factors , B = 250 , K = 250 , seed = 42)
write.csv(summary(results, fdr = 1),file=paste0(inpD,hdr,"rots.csv"))
names(results)
summary(results, fdr = 0.05)
plot(results, fdr = 0.2, type = "pca")
plot(results, type = "volcano",fdr = 0.5)
plot(results, fdr = 0.2, type = "heatmap")


#imputeFilter-ttest####
pairwise.t.test(as.matrix(dataNormImpFilter),c(0,0,1,1,1,0))#[1,3:5],dataNormImpFilter[1,c(1,2,6)])


#write-output####
write.table(dataNorm,file=paste0(inpD,"log2data.txt"), sep = "\t")
#dump(dataNorm,file=paste0(inpD,"dataNorm.R"))



#impute####
#install.packages('mice')
library(mice)
#install.packages('randomForest')
library(randomForest)
dataNormImp=mice(dataNorm, method="rf")
dataNormImpCom <- complete(dataNormImp,1)
row.names(dataNormImpCom)<-row.names(dataNorm)
summary(dataNormImpCom)


#write-output####
write.csv(dataNormImpCom,file=paste0(inpD,"log2dataImp.csv"))
#write.csv(factors,file=paste0(inpD,"dataNormImpComFactor.csv"))
dataNormImpCom <- read.csv(paste0(inpD,"log2dataImp.csv"),row.names=1,header = T)
#factors<-read.csv(paste0(inpD,"dataNormImpComFactor.csv"))
#dump(dataNorm,file=paste0(inpD,"dataNorm.R"))




#DEqMS}
#https://rdrr.io/bioc/DEqMS/f/vignettes/DEqMS-package-vignette.Rmd
#install.packages("BiocManager")
#BiocManager::install("DEqMS")
library(DEqMS)
dat.log=dataNormImpFilter
boxplot(dat.log,las=2,main="")
cond = as.factor(c("w","w","r","r","r","w"))
design = model.matrix(~0+cond) # 0 means no intercept for the linear model
colnames(design) = gsub("cond","",colnames(design))
x <- c("r-w")
contrast =  makeContrasts(contrasts=x,levels=design)
fit1 <- lmFit(dat.log, design)
fit2 <- contrasts.fit(fit1,contrasts = contrast)
fit3 <- eBayes(fit2)
df.prot=dataClean[dataNormFilter$Red<selThr | dataNormFilter$White<selThr,]
library(matrixStats)
count_columns = "MS.MS.count."
#psm.count.table = data.frame(count = rowMins(as.matrix(df.prot[,grep(count_columns, names(df.prot))])))+1
#rownames(fit3$coefficients)
fit3$count = rowMins(as.matrix(df.prot[,grep(count_columns, names(df.prot))]))+1
fit4 = spectraCounteBayes(fit3)
# n=30 limits the boxplot to show only proteins quantified by <= 30 PSMs.
VarianceBoxplot(fit4,n=30,main=inpD,xlab="PSM count")
VarianceScatterplot(fit4,main=inpD)
DEqMS.results = outputResult(fit4,coef_col = 1)
#if you are not sure which coef_col refers to the specific contrast,type
head(fit4$coefficients)
# a quick look on the DEqMS results table
head(DEqMS.results)
# Save it into a tabular text file
write.table(DEqMS.results,paste0(inpD,hdr,"DEqMS.results.txt"),sep = "\t",row.names = F,quote=F)
#install.packages("ggrepel")
library(ggrepel)
# Use ggplot2 allows more flexibility in plotting
DEqMS.results$log.sca.pval = -log10(DEqMS.results$sca.P.Value)
ggplot(DEqMS.results, aes(x = logFC, y =log.sca.pval )) +
    geom_point(size=0.5 )+
    theme_bw(base_size = 16) + # change theme
    xlab(expression("log2(red/white)")) + # x-axis label
    ylab(expression(" -log10(P-value)")) + # y-axis label
    geom_vline(xintercept = c(-1,1), colour = "red") + # Add fold change cutoffs
    geom_hline(yintercept = 2, colour = "red") + # Add significance cutoffs
    geom_vline(xintercept = 0, colour = "black") + # Add 0 lines
    scale_colour_gradient(low = "black", high = "black", guide = FALSE)+
    geom_text_repel(data=subset(DEqMS.results, abs(logFC)>1&log.sca.pval > 2),
                    aes( logFC, log.sca.pval ,label=gene)) # add gene label

#fit4$p.value = fit4$sca.p
#volcanoplot(fit4,coef=1, style = "p-value", highlight = 10,names=rownames(fit4$coefficients))


#DEqMS-peptides}
fit3$count = rowMins(as.matrix(df.prot[,grepl("^Peptides\\.[0-9]+", names(df.prot))]))+1
min(fit3$count)

fit4 = spectraCounteBayes(fit3)
VarianceBoxplot(fit4, n=20, main = hdr,xlab="peptide count + 1")
DEqMS.results = outputResult(fit4,coef_col = 1)
DEqMS.results$Gene.name = df.prot[DEqMS.results$gene,]$Gene.names
head(DEqMS.results)
write.table(DEqMS.results,paste0(inpD,hdr,"R-W.DEqMS.pep.results.txt"),sep = "\t",row.names = F,quote=F)
head(DEqMS.results)
VarianceBoxplot(fit4,n=20)
#peptideProfilePlot(dat=df.prot)#,col=2,gene="TGFBR2")
VarianceScatterplot(fit4, xlab="log2(LFQ)")
limma.prior = fit4$s2.prior
abline(h = log(limma.prior),col="green",lwd=3 )
legend("topright",legend=c("DEqMS prior variance","Limma prior variance"),
        col=c("red","green"),lwd=3)
op <- par(mfrow=c(1,2), mar=c(4,4,4,1), oma=c(0.5,0.5,0.5,0))
Residualplot(fit4,  xlab="log2(PSM count)",main="DEqMS")
x = fit3$count
y = log(limma.prior) - log(fit3$sigma^2)
plot(log2(x),y,ylim=c(-6,2),ylab="Variance(estimated-observed)", pch=20, cex=0.5,
     xlab = "log2(PSMcount)",main="Limma")
#install.packages("LSD")
library(LSD)
op <- par(mfrow=c(1,2), mar=c(4,4,4,1), oma=c(0.5,0.5,0.5,0))
x = fit3$count
y = fit3$s2.post
heatscatter(log2(x),log(y),pch=20, xlab = "log2(PSMcount)",
     ylab="log(Variance)",
     main="Posterior Variance in Limma")

y = fit4$sca.postvar
heatscatter(log2(x),log(y),pch=20, xlab = "log2(PSMcount)",
     ylab="log(Variance)",
     main="Posterior Variance in DEqMS")


