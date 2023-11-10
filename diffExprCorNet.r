#setup####
inpD <-"F:/OneDrive - NTNU/Aida/XPO/"
.libPaths( c( .libPaths(), inpD) )
.libPaths()
par(mfrow=c(1,2))
warnings()
#data####
selThr=0.3
selThrFC=0.5
hdr<-gsub("[^[:alnum:] ]", "",inpD)
setwd(inpD)
getwd()
inpF<-paste0(inpD,"Supplementary Table 2.xlsx")
#install.packages("readxl")
#install.packages("ellipsis")
#devtools::install_github("r-lib/ellipsis")
data <- readxl::read_excel(inpF,sheet = 2)
#transform####
dataLog2<-sapply(data, as.numeric)
#select####
colnames(dataLog2)
dataComb<-data.frame(dataLog2[,grep("^M",colnames(dataLog2))])
dataComb<-sapply(dataComb,as.numeric)
boxplot(dataComb)
head(data$`T: T: Gene names`)
rownames(dataComb)<-paste(data$`T: T: Gene names`,data$`T: T: Protein IDs`,1:nrow(dataComb),sep=";")
hist(dataComb)
#selGen####
dataCombT<-t(dataComb)
genSel <- "XPO1"
summary(dataCombT[,colnames(dataCombT)[grep(genSel,colnames(dataCombT))]])
#dataCombTcorXPO1=cor(dataCombT[,"XPO1;O14980;C9JKM9;C9IZS4;C9JQ02;C9JV99;F8WF71;C9JF49;C9IYM2;H7BZC5;3853"],dataCombT)
#hist(dataCombTcorXPO1)
#cor####
dataCombTcor=t(dataCombT[,-c(grep(genSel,colnames(dataCombT)))])
resCor=apply(dataCombTcor, 1,function(x)
  if((sum(!is.na(x))>0)){
    cort=cor.test(as.numeric(x),as.numeric(dataCombT[,colnames(dataCombT)[grep(genSel,colnames(dataCombT))]]),use="pairwise.complete.obs",method="pearson")
    cort=unlist(cort)
    paste(cort[[1]],cort[[2]],cort[[3]],cort[[4]],sep="--VALS--")
  }
  else{NA}
)
pValCor<-sapply(strsplit(resCor, "--VALS--",fixed=T), "[", 3)
pValNA<-sapply(pValCor,as.numeric)
hist(pValNA)
cValCor<-sapply(strsplit(resCor, "--VALS--",fixed=T), "[", 4)
cValNA<-sapply(cValCor,as.numeric)
hist(cValNA)
tValCor<-sapply(strsplit(resCor, "--VALS--",fixed=T), "[", 1)
tValNA<-sapply(tValCor,as.numeric)
hist(tValNA)
yValCor<-sapply(strsplit(resCor, "--VALS--",fixed=T), "[", 2)
yValNA<-sapply(yValCor,as.numeric)
hist(yValNA)
summary(warnings())
summary(pValNA)
summary(cValNA)
if(sum(is.na(pValNA))==nrow(dataCombTcor)){pValNA[is.na(pValNA)]=1}
hist(pValNA)
dfpValNA<-as.data.frame(ceiling(pValNA))
pValNAdm<-cbind(pValNA,dataCombTcor,row.names(dataCombTcor))
pValNAminusLog10 = -log10(pValNA+.Machine$double.xmin)
hist(pValNAminusLog10)
library(scales)
pValNAminusLog10=squish(pValNAminusLog10,c(0,5))
hist(pValNAminusLog10)
length(pValNA)-(sum(is.na(pValNA))+sum(ceiling(pValNA)==0,na.rm = T))
pValBHna = p.adjust(pValNA,method = "BH")
hist(pValBHna)
pValBHnaMinusLog10 = -log10(pValBHna+.Machine$double.xmin)
hist(pValBHnaMinusLog10)
geneName<-paste(sapply(strsplit(paste(sapply(strsplit(row.names(dataCombTcor), ";",fixed=T), "[", 1)), "-"), "[", 1))
uniprotID<-paste(sapply(strsplit(paste(sapply(strsplit(row.names(dataCombTcor), ";",fixed=T), "[", 2)), "-"), "[", 1))
corTest.results = data.frame(Uniprot=uniprotID,Gene=geneName,PValueMinusLog10=pValNAminusLog10,CorrectedPValueBH=pValBHna,CorTestPval=pValNA,Cor=cValNA,dataCombTcor,Fasta=row.names(dataCombTcor))
writexl::write_xlsx(corTest.results,paste0(inpF,genSel,"CorTestBH.xlsx"))
#dist####
log2LFQimpCorr<-cor(t(dataComb),use="pairwise.complete.obs",method="spearman")
hist(log2LFQimpCorr)
dsubCor<-as.dist(log2LFQimpCorr)
#dsubCor[is.na(dsubCor)]<-0
#https://stackoverflow.com/questions/5813156/convert-and-save-distance-matrix-to-a-specific-format/5815379#5815379
dsubCorM <- data.frame(t(combn(rownames(log2LFQimpCorr),2)), as.numeric(dsubCor))
names(dsubCorM) <- c("P1", "P2", "dist")
dsubCorMna<-dsubCorM[!is.na(dsubCorM$dist),]
write.csv(data.frame(dsubCorMna),paste0(inpD,"dsubCorMna.csv"))
dsubCorM50p<-dsubCorMna[abs(dsubCorMna$dist)>0.5,]
dsubCorM50p$SOURCE<-paste(sapply(strsplit(paste(sapply(strsplit(dsubCorM50p$P1, ";",fixed=T), "[", 1)), "-"), "[", 1))
dsubCorM50p$TARGET<-paste(sapply(strsplit(paste(sapply(strsplit(dsubCorM50p$P2, ";",fixed=T), "[", 1)), "-"), "[", 1))
write.csv(data.frame(dsubCorM50p),paste0(inpD,"dsubCorM50p.csv"))
dsubCorM75p<-dsubCorMna[abs(dsubCorMna$dist)>0.75,]
dsubCorM75p$SOURCE<-paste(sapply(strsplit(paste(sapply(strsplit(dsubCorM75p$P1, ";",fixed=T), "[", 1)), "-"), "[", 1))
dsubCorM75p$TARGET<-paste(sapply(strsplit(paste(sapply(strsplit(dsubCorM75p$P2, ";",fixed=T), "[", 1)), "-"), "[", 1))
write.csv(data.frame(dsubCorM75p),paste0(inpD,"dsubCorM75p.csv"),quote = F)
#dsubCor<-dist(dsub,method="euclidean")
hist(dsubCor)
summary(dsubCor)
#check
nrow(dsub)*(nrow(dsub)-1)/2==length(dsubCor)
#dsubCor<-as.dist(cor(t(dsub),use="pairwise.complete.obs",method="pearson"))
#heatmap####
p<-pheatmap::pheatmap(dsub,clustering_distance_rows=dsubCor,clustering_distance_cols = "binary",cluster_cols=T,cluster_rows=T,fontsize_col=4,fontsize_row=4)
ggplot2::ggsave(paste0(inpF,hdr,selection,sCol,eCol,comp,selThr,selThrFC,cvThr,"HeatMapTestChosenDist.svg"), p)
pE<-as.matrix(100*dsub$Count/dsub$Length)
rownames(pE)<-uniprot
hist(pE)
dsubCor<-dist(pE,method="euclidean")
dsubCorM<-as.matrix(dist(pE,method="euclidean",diag = T,upper = T))
hist(dsubCor)
#check
nrow(dsub)*(nrow(dsub)-1)/2==length(dsubCor)
#dsubCor<-as.dist(cor(t(dsub),use="pairwise.complete.obs",method="pearson"))
p<-pheatmap::pheatmap(dsub,clustering_distance_rows=dsubCor,clustering_distance_cols = "binary",cluster_cols=T,cluster_rows=T,fontsize_col=4,fontsize_row=4)
ggplot2::ggsave(paste0(inpF,hdr,selection,sCol,eCol,comp,selThr,selThrFC,cvThr,"HeatMapTestChosenDistE.svg"), p)
#lMGUS####
#dataLog2MGUS<-dataLog2[,grep("MGUS[1-9]+",colnames(dataLog2))]
#dataLog2MM<-dataLog2[,grep("MM[1-9]+",colnames(dataLog2))]
#dataComb<-rbind(t(dataLog2MM[1,]),t(dataLog2MGUS[1,]))
dataComb<-data.frame(dataLog2[,grep("MGUS[1-9]+|MM[1-9]+",colnames(dataLog2))])#cbind(t(dataLog2MM[1,]),t(dataLog2MGUS[1,]))
#sample<-factor(substr(colnames(dataComb), start = 1, stop = 2))
#hist(dataComb[,1])
boxplot(dataComb)
rownames(dataComb)<-paste(data$`T: T: Gene names`,data$`T: T: Protein IDs`,1:nrow(dataComb),sep=";")
#dataComb<-rbind(dataComb,sample)
#write.csv(dataComb,paste0(inpF,"id.csv"))
#dataComb$Uniprot<-data$`T: T: Protein IDs`
dataComb<-data.frame(t(dataComb))
#dataComb$Group<-factor(c("G","G","G","G","G","G","G","G","G","L","L","L","L","L","L","M","M","M","M","M","M","M","M","M","M","M","M","M","C","C","M","M","M","M","C","M","M","M","M","M","M","M","M","M","M","C"))
dataComb$Group<-factor(c("G","G","G","G","G","G","G","G","G","L","L","L","L","L","L","M","M","M","M","M","M","M","M","M","M","M","M","M","M","M","M","M","M","M","M","M","M","M","M","M","M","M","M","M","M","M"))
plot(dataComb$LAMP1.P11279.P11279.2.7,dataComb$STOM.P27105.P27105.2.F8VSL7.1055)
text(dataComb$LAMP1.P11279.P11279.2.7,dataComb$STOM.P27105.P27105.2.F8VSL7.1055,dataComb$Group,cex = 0.5,pos=2, col="red")
text(dataComb$LAMP1.P11279.P11279.2.7,dataComb$STOM.P27105.P27105.2.F8VSL7.1055,row.names(dataComb),cex = 0.5,pos=4, col="blue")
dataComb[is.na(dataComb)]<-"NaN"
write.csv(dataComb,paste0(inpF,"trp.id.csv"))
#boxplot(dataComb$C4orf27.Q9NWY4.A8MVJ9.1200~dataComb$Group)
#stripchart(dataComb$C4orf27.Q9NWY4.A8MVJ9.1200~dataComb$Group,method = "jitter", vertical=TRUE,add=TRUE,pch = 19, col = "blue")
#MGUS
dataComb3P<-data.frame(dataComb$LAMP1.P11279.P11279.2.7,dataComb$TFRC.P02786.G3V0E5.H7C3V5.F8WBE5.Q9UP52.2.Q9UP52.3.Q9UP52.1,dataComb$STOM.P27105.P27105.2.F8VSL7.1055,dataComb$Group)
plot(dataComb3P)
#install.packages("scatterplot3d")
cols <- c("darkblue", "orange", "darkgreen")
with(dataComb3P,scatterplot3d::scatterplot3d(dataComb$LAMP1.P11279.P11279.2.7,dataComb$TFRC.P02786.G3V0E5.H7C3V5.F8WBE5.Q9UP52.2.Q9UP52.3.Q9UP52.1,dataComb$STOM.P27105.P27105.2.F8VSL7.1055,main="Scatter plot 3D",xlab = "LAMP1",ylab = "TFRC",zlab = "STOM",pch = 16,color=cols[as.numeric(dataComb$Group)]))
legend("right", legend = levels(dataComb$Group),col =  c("darkblue", "orange", "darkgreen"), pch = 16)
boxplot(dataComb$ITGB1.P05556.P05556.2.P05556.5.P05556.4.P05556.3.E7EQW5.C9JPK5.Q5T3E6.E9PLR6.E7EUI6.H7C4N8.E7ERX5.511~dataComb$Group)
stripchart(dataComb$ITGB1.P05556.P05556.2.P05556.5.P05556.4.P05556.3.E7EQW5.C9JPK5.Q5T3E6.E9PLR6.E7EUI6.H7C4N8.E7ERX5.511~dataComb$Group,method = "jitter", vertical=TRUE,add=TRUE,pch = 19, col = "blue")
boxplot(dataComb$LAMP1.P11279.P11279.2.7~dataComb$Group)
stripchart(dataComb$LAMP1.P11279.P11279.2.7~dataComb$Group,method = "jitter", vertical=TRUE,add=TRUE,pch = 19, col = "blue")
boxplot(dataComb$TFRC.P02786.G3V0E5.H7C3V5.F8WBE5.Q9UP52.2.Q9UP52.3.Q9UP52.1~dataComb$Group)
stripchart(dataComb$TFRC.P02786.G3V0E5.H7C3V5.F8WBE5.Q9UP52.2.Q9UP52.3.Q9UP52.1~dataComb$Group,method = "jitter", vertical=TRUE,add=TRUE,pch = 19, col = "blue")
boxplot(dataComb$STOM.P27105.P27105.2.F8VSL7.1055~dataComb$Group)
stripchart(dataComb$STOM.P27105.P27105.2.F8VSL7.1055~dataComb$Group,method = "jitter", vertical=TRUE,add=TRUE,pch = 19, col = "blue")
#LIKE
plot(dataComb$STOM.P27105.P27105.2.F8VSL7.1055,dataComb$ITGB1.P05556.P05556.2.P05556.5.P05556.4.P05556.3.E7EQW5.C9JPK5.Q5T3E6.E9PLR6.E7EUI6.H7C4N8.E7ERX5.511)
text(dataComb$STOM.P27105.P27105.2.F8VSL7.1055,dataComb$ITGB1.P05556.P05556.2.P05556.5.P05556.4.P05556.3.E7EQW5.C9JPK5.Q5T3E6.E9PLR6.E7EUI6.H7C4N8.E7ERX5.511,dataComb$Group,cex = 0.5,pos=4, col="red")
boxplot(dataComb$PANX1.Q96RD7.2.Q96RD7.124~dataComb$Group)
stripchart(dataComb$TFRC.P02786.G3V0E5.H7C3V5.F8WBE5.Q9UP52.2.Q9UP52.3.Q9UP52.1~dataComb$Group,method = "jitter", vertical=TRUE,add=TRUE,pch = 19, col = "blue")
boxplot(dataComb$NBEAL2.Q6ZNJ1.2.Q6ZNJ1.Q6ZNJ1.3.H0Y764.H7C3Y7.H7C354.H7C408.22~dataComb$Group)
stripchart(dataComb$NBEAL2.Q6ZNJ1.2.Q6ZNJ1.Q6ZNJ1.3.H0Y764.H7C3Y7.H7C354.H7C408.22~dataComb$Group,method = "jitter", vertical=TRUE,add=TRUE,pch = 19, col = "blue")
plot(dataComb$NBEAL2.Q6ZNJ1.2.Q6ZNJ1.Q6ZNJ1.3.H0Y764.H7C3Y7.H7C354.H7C408.22,dataComb$PANX1.Q96RD7.2.Q96RD7.124)
#boxplot(dataComb$STOM.P27105.P27105.2.F8VSL7.1055~dataComb$Group)
#stripchart(dataComb$STOM.P27105.P27105.2.F8VSL7.1055~dataComb$Group,method = "jitter", vertical=TRUE,add=TRUE,pch = 19, col = "blue")
#boxplot(dataComb$TPM3.P06753.2.A0A087WWU8.P06753.5.Q5VU61.D6R904.D6RFM2.1125~dataComb$Group)
#stripchart(dataComb$TPM3.P06753.2.A0A087WWU8.P06753.5.Q5VU61.D6R904.D6RFM2.1125~dataComb$Group,method = "jitter", vertical=TRUE,add=TRUE,pch = 19, col = "blue")
#boxplot(dataComb$CIRBP.Q14011.K7EMY9.K7EPM4.K7EQR7.D6W5Y5.Q14011.2.K7ENX8.K7EJV5.K7ELT6.K7EJV1.K7ER40.K7ELV6.K7EQX4.K7ENN6.K7EIF7.K7EQL0.F6WMK9.Q14011.3.27~dataComb$Group)
#stripchart(dataComb$CIRBP.Q14011.K7EMY9.K7EPM4.K7EQR7.D6W5Y5.Q14011.2.K7ENX8.K7EJV5.K7ELT6.K7EJV1.K7ER40.K7ELV6.K7EQX4.K7ENN6.K7EIF7.K7EQL0.F6WMK9.Q14011.3.27~dataComb$Group,method = "jitter", vertical=TRUE,add=TRUE,pch = 19, col = "blue")
#boxplot(dataComb$SCP2.P22307.7.P22307.8.P22307.P22307.6.P22307.2.H0YF61.E9PLD1.P22307.3.H0YCB0.2~dataComb$Group)
#stripchart(dataComb$SCP2.P22307.7.P22307.8.P22307.P22307.6.P22307.2.H0YF61.E9PLD1.P22307.3.H0YCB0.2~dataComb$Group,method = "jitter", vertical=TRUE,add=TRUE,pch = 19, col = "orange")
#boxplot(dataComb$NDUFA5.A0A087X1G1.H7BYD0.Q16718.2.Q16718.A0A087WXR5.F8WAS3.C9IZN5.55~dataComb$Group)
#stripchart(dataComb$NDUFA5.A0A087X1G1.H7BYD0.Q16718.2.Q16718.A0A087WXR5.F8WAS3.C9IZN5.55~dataComb$Group,method = "jitter", vertical=TRUE,add=TRUE,pch = 19, col = "orange")
#dataComb50p<-dataComb[,which(colMeans(!is.na(dataComb)) > 0.9999)]
#dataComb50cv<-dataComb[,which(col(!is.na(dataComb)) > 0.9999)]
#p <- ggplot2::ggplot(dataComb, ggplot2::aes(x="TFRC;1",y=rownames(dataComb),fill=Group)) +  ggplot2::geom_boxplot() + ggplot2::geom_jitter(color="black", size=0.4,width=0.1, alpha=0.9)
#p <- ggplot2::ggplot(dataComb, ggplot2::aes(x="TFRC;1",y=TFRC.1,fill=Group)) +  ggplot2::geom_boxplot() + ggplot2::geom_jitter(color="black", size=1,width=0.1, alpha=0.5)
#p
#data$Gene<-sapply(strsplit(as.character(data$RowGeneUniProtScorePeps),";;"), "[", 5)
#data$Gene<-sapply(strsplit(data$Gene,";"), "[", 1)
#data$GN<-sapply(strsplit(as.character(data$RowGeneUniProtScorePeps),"GN="), "[", 2)
#data$GN<-sapply(strsplit(data$GN,"[:; ]"), "[", 1)
#data$ChkG<-data$GN==data$Gene
summary(dataComb)
#log2LFQ[log2LFQ==-Inf]=NA
#hist(dataComb$TFRC.1)
#writexl::write_xlsx(dataComb,paste0(inpF,"gene.xlsx"))
```
```{r PCA}
#https://cran.r-project.org/web/packages/FactoMineR/FactoMineR.pdf
#install.packages("FactoMineR")
#https://www.youtube.com/watch?v=pks8m2ka7Pk&list=PLnZgp6epRBbTsZEFXi_p6W48HhNyqwxIu&index=6
dataComb<-data.frame(dataLog2[,grep("MGUS[1-9]+|MM[1-9]+",colnames(dataLog2))])#cbind(t(dataLog2MM[1,]),t(dataLog2MGUS[1,]))
rownames(dataComb)<-paste(data$`T: T: Gene names`,data$`T: T: Protein IDs`,1:nrow(dataComb),sep=";")
dataComb<-data.frame(t(dataComb))
#FactoMineR::PCA(dataComb)
FactoMineR::PCA(dataComb[,1:10])
dataComb$Group<-factor(c("G","G","G","G","G","G","G","G","G","L","L","L","L","L","L","M","M","M","M","M","M","M","M","M","M","M","M","M","C","C","M","M","M","M","C","M","M","M","M","M","M","M","M","M","M","C"))
#dataComb<-data.frame(t(dataComb))
FactoMineR::PCA(dataComb,quanti.sup = 1:10,quali.sup = 3957)
summary(.Last.value)
resPCA<-FactoMineR::PCA(dataComb,quali.sup = 3957)
summary(resPCA)
FactoMineR::dimdesc(resPCA,proba = 0.01)
#http://factominer.free.fr/missMDA/appendix_These_Audigier.pdf
#install.packages("missMDA")
missMDA::plot.MIMCA(t(dataComb[,1:10]),graph=F)
```
```{r featSel}
#https://youtu.be/_6XvNMmpU7Q?t=1280
#todo: allow handling missing data? For example, using the rfImpute call/combine the highly correlated features rather than dropping them completely
install.packages("FeatureTerminatoR")
dataCombCC<-dataComb
dataCombCC[is.na(dataCombCC)]<-0
rfeFit<-FeatureTerminatoR::rfeTerminator(dataCombCC,x_cols = 1:3956, y_cols = "Group",alter_df = TRUE, eval_funcs = rfFuncs)
print(rfeFit$rfe_model_fit_results)
print(rfeFit$rfe_model_fit_results$optVariables)
print(rfeFit$rfe_reduced_data)
```
```{r featRem}
mcFit<-FeatureTerminatoR::mutlicol_terminator(dataCombCC,x_cols = 1:3956, y_cols =  "Group",alter_df = TRUE,cor_sig = 0.6)
mcFit$corr_quant_chart
dataCombCCrf<-mcFit$feature_removed_df
```

```{r MW}
upMM<-read.csv(paste0(inpD,"uniprot-yourlist_M20210713A084FC58F6BBA219896F365D15F2EB440C40315.txt"),sep="\t")
upMM$Group<-"up"
upMM<-upMM[upMM$Mass>0,]
summary(as.numeric(upMM$Mass))
downMM<-read.csv(paste0(inpD,"uniprot-yourlist_M202107134ABAA9BC7178C81CEBC9459510EDDEA30C7678U.txt"),sep="\t")
downMM$Group<-"down"
downMM<-downMM[downMM$Mass>0,]
combMM<-rbind(upMM,downMM)
dataMM<-read.csv(paste0(inpD,"combMM.txt"),sep="\t")
boxplot(dataMM$Mass~dataMM$C..Group)
stripchart(dataMM$Mass~dataMM$C..Group,method = "jitter", vertical=TRUE,add=TRUE,pch = 19, col = "orange")
boxplot(dataMM$Length~dataMM$C..Group)
stripchart(dataMM$Length~dataMM$C..Group,method = "jitter", vertical=TRUE,add=TRUE,pch = 19, col = "blue")
t.test(dataMM$Mass~dataMM$C..Group)
t.test(dataMM$Length~dataMM$C..Group)
```

```{r gMGUSt, echo = FALSE}
comp<-"MGUS"
dataSellog2grpTtest<-as.matrix(dataComb[,grep(comp,colnames(dataComb))])
dataSellog2grpTtest[dataSellog2grpTtest==0]=NA
summary(dataSellog2grpTtest)
boxplot(dataSellog2grpTtest)
row.names(dataSellog2grpTtest)<-row.names(dataComb)
sCol<-1
eCol<-9
mCol<-5
cvThr<-0.05
t.test(as.numeric(dataSellog2grpTtest[1,c(sCol:mCol)]),as.numeric(dataSellog2grpTtest[1,c((mCol+1):eCol)]),na.rm=T)$p.value
chkr<-2
sum(!is.na(dataSellog2grpTtest[chkr,c(1:eCol)]))
t.test(as.numeric(dataSellog2grpTtest[chkr,c(sCol:mCol)]),as.numeric(dataSellog2grpTtest[chkr,c((mCol+1):eCol)]),na.rm=T,var.equal=T)$p.value
dim(dataSellog2grpTtest)
options(nwarnings = 1000000)
pValNA = apply(
  dataSellog2grpTtest, 1, function(x)
    if(sum(!is.na(x[c(sCol:mCol)]))<2&sum(!is.na(x[c((mCol+1):eCol)]))<2){NA}
    else if(sum(is.na(x[c(sCol:mCol)]))==0&sum(is.na(x[c((mCol+1):eCol)]))==0){
      t.test(as.numeric(x[c(sCol:mCol)]),as.numeric(x[c((mCol+1):eCol)]),var.equal=T)$p.value}
    else if(sum(!is.na(x[c(sCol:mCol)]))>1&sum(!is.na(x[c((mCol+1):eCol)]))<1&(sd(x[c(sCol:mCol)],na.rm=T)/mean(x[c(sCol:mCol)],na.rm=T))<cvThr){0}
    else if(sum(!is.na(x[c(sCol:mCol)]))<1&sum(!is.na(x[c((mCol+1):eCol)]))>1&(sd(x[c((mCol+1):eCol)],na.rm=T)/mean(x[c((mCol+1):eCol)],na.rm=T))<cvThr){0}
    else if(sum(!is.na(x[c(sCol:mCol)]))>=2&sum(!is.na(x[c((mCol+1):eCol)]))>=1){
      t.test(as.numeric(x[c(sCol:mCol)]),as.numeric(x[c((mCol+1):eCol)]),na.rm=T,var.equal=T)$p.value}
    else if(sum(!is.na(x[c(sCol:mCol)]))>=1&sum(!is.na(x[c((mCol+1):eCol)]))>=2){
      t.test(as.numeric(x[c(sCol:mCol)]),as.numeric(x[c((mCol+1):eCol)]),na.rm=T,var.equal=T)$p.value}
  else{NA}
  )
summary(warnings())
hist(pValNA)
summary(pValNA)
dfpValNA<-as.data.frame(ceiling(pValNA))
pValNAdm<-cbind(pValNA,dataSellog2grpTtest,row.names(data))
pValNAminusLog10 = -log10(pValNA+.Machine$double.xmin)
hist(pValNAminusLog10)
library(scales)
pValNAminusLog10=squish(pValNAminusLog10,c(0,5))
hist(pValNAminusLog10)
length(pValNA)-(sum(is.na(pValNA))+sum(ceiling(pValNA)==0,na.rm = T))
pValBHna = p.adjust(pValNA,method = "BH")
hist(pValBHna)
pValBHnaMinusLog10 = -log10(pValBHna+.Machine$double.xmin)
hist(pValBHnaMinusLog10)
logFCmedianGrp1 = apply(dataSellog2grpTtest[,c(sCol:mCol)],1, function(x) median(x,na.rm=T))
logFCmedianGrp1=if(is.null(dim(dataSellog2grpTtest[,c(sCol:mCol)]))){dataSellog2grpTtest[,c(sCol:mCol)]} else{apply(dataSellog2grpTtest[,c(sCol:mCol)],1,function(x) median(x,na.rm=T))}
#summary(logFCmedianGrp11-logFCmedianGrp1)
logFCmedianGrp2=if(is.null(dim(dataSellog2grpTtest[,c((mCol+1):eCol)]))){dataSellog2grpTtest[,c((mCol+1):eCol)]} else{apply(dataSellog2grpTtest[,c((mCol+1):eCol)],1,function(x) median(x,na.rm=T))}
logFCmedianGrp1[is.na(logFCmedianGrp1)]=0
logFCmedianGrp2[is.na(logFCmedianGrp2)]=0
hda<-cbind(logFCmedianGrp1,logFCmedianGrp2)
plot(hda)
limma::vennDiagram(hda>0)
logFCmedian = logFCmedianGrp1-logFCmedianGrp2
logFCmedianFC = 2^(logFCmedian+.Machine$double.xmin)
logFCmedianFC=squish(logFCmedianFC,c(0.01,100))
hist(logFCmedianFC)
log2FCmedianFC=log2(logFCmedianFC)
hist(log2FCmedianFC)
rowName<-row.names(dataSellog2grpTtest)
comp<-gsub("[^[:alnum:] ]", "", comp)
ttest.results = data.frame(Uniprot=rowName,PValueMinusLog10=pValNAminusLog10,FoldChanglog2median=logFCmedianFC,CorrectedPValueBH=pValBHna,TtestPval=pValNA,dataSellog2grpTtest,Log2MedianChange=logFCmedian,RowGeneUniProtScorePeps=rownames(dataSellog2grpTtest))
writexl::write_xlsx(ttest.results,paste0(inpF,selection,sCol,eCol,comp,selThr,selThrFC,cvThr,"tTestBH.xlsx"))
write.csv(ttest.results,paste0(inpF,selection,sCol,eCol,comp,selThr,selThrFC,cvThr,"tTestBH.csv"),row.names = F)
data$RowGeneUniProtScorePeps<-data$Gene.names
ttest.results[is.na(ttest.results)]=selThr
Significance=ttest.results$CorrectedPValueBH<selThr&ttest.results$CorrectedPValueBH>0&abs(ttest.results$Log2MedianChange)>selThrFC
sum(Significance)
dsub <- subset(ttest.results,Significance)
p <- ggplot2::ggplot(ttest.results,ggplot2::aes(Log2MedianChange,PValueMinusLog10))+ ggplot2::geom_point(ggplot2::aes(color=Significance))
p<-p + ggplot2::theme_bw(base_size=8) + ggplot2::geom_text(data=dsub,ggplot2::aes(label=RowGeneUniProtScorePeps),hjust=0, vjust=0,size=1) + ggplot2::scale_fill_gradient(low="white", high="darkblue") + ggplot2::xlab("Log2 Median Change") + ggplot2::ylab("-Log10 P-value")
#f=paste(file,proc.time()[3],".jpg")
ggplot2::ggsave(paste0(inpF,selection,sCol,eCol,comp,selThr,selThrFC,cvThr,"VolcanoTest.svg"), p)
print(p)
p <- ggplot2::ggplot(ttest.results,ggplot2::aes(Log2MedianChange,PValueMinusLog10))+ ggplot2::geom_point(ggplot2::aes(color=Significance))
p<-p + ggplot2::theme_bw(base_size=8) + ggplot2::geom_text(data=dsub,ggplot2::aes(label=""),hjust=0, vjust=0,size=1) + ggplot2::scale_fill_gradient(low="white", high="darkblue") + ggplot2::xlab("Log2 Median Change") + ggplot2::ylab("-Log10 P-value")
#f=paste(file,proc.time()[3],".jpg")
ggplot2::ggsave(paste0(inpF,selection,sCol,eCol,comp,selThr,selThrFC,cvThr,"VolcanoTestNoLabel.svg"), p)
print(p)
```

```{r TCGAsurvivalKM}
#https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7304035/
#BiocManager::install("TCGAbiolinks")
#library(TCGAbiolinks)
#clinical_patient_Cancer <- GDCquery_clinic("MMRF-COMMPASS","clinical")
#dataNorm <- TCGAanalyze_Normalization(tabDF = dataMMRF, geneInfo = geneInfo)
tabSurvKM<-TCGAanalyze_SurvivalKM(clinical_patient_Cancer,dataComb,Genelist =c("UNG") ,Survresult = F,ThreshTop=0.67,ThreshDown=0.33)
#https://academic.oup.com/bib/advance-article/doi/10.1093/bib/bbab050/6209690
install.packages("BiocManager")
BiocManager::install(c("EDASeq","genefilter", "sva", "limma","GenomicFeatures","EnsDb.Hsapiens.v79"))
install.packages("devtools")
remotes::install_github("RDocTaskForce/testextra")
remotes::install_github("RDocTaskForce/parsetools")
devtools::install_github("halpo/purrrogress")
install.packages("rmarkdown")
install.packages("knitr")
install.packages("sweave")
install.packages("xtable")
install.packages("DT")
BiocManager::install("BiocStyle")
library(TCGAbiolinks)
library(SummarizedExperiment)
library(dplyr)
library(DT)
library(ggplot2)
devtools::install_github("marziasettino/MMRFBiolinks", build_vignettes = TRUE)
devtools::load_all("C:\\Users\\animeshs\\R\\library\\MMRFBiolinks\\html\\.")
vignette(package="MMRFBiolinks")
browseVignettes("MMRFBiolinks")
library("MMRFBiolinks")
data(package = "MMRFBiolinks")
clinical <- MMRFGDC_QueryClinic(type = "clinical")
#write.csv(data.frame(clinical),paste0(inpD,"clinical.csv"))
save(file=paste0(inpD,"clinical.rds"),clinical)
load(paste0(inpD,"clinical.rds"))
colnames(clinical)
clinical$bcr_patient_barcode
assign(data(package = "MMRFBiolinks",dataMM),dM)
data(package = "MMRFBiolinks",dataGE)
MMRFclin <- MMRFGDC_QueryClinic(type = "clinical")
save(file=paste0(inpD,"MMRFclin.rds"),MMRFclin)
listSamples <- MMRFclin$bcr_patient_barcode#c("MMRF_2473","MMRF_2111",                 "MMRF_2362","MMRF_1824","MMRF_1458","MRF_1361","MMRF_2203","MMRF_2762","MMRF_2680","MMRF_1797")
query <- GDCquery(project = "MMRF-COMMPASS",
                               data.category = "Transcriptome Profiling",
                               data.type = "Gene Expression Quantification",
                               experimental.strategy = "RNA-Seq",
                               workflow.type="HTSeq - FPKM",
                               barcode = listSamples)
#TCGAbiolinks::GDCdownload(query, method = "api", files.per.chunk = 10)
#TCGAbiolinks::GDCdownload(query, method = "client", files.per.chunk = 10)
GDCdownload(query, method = "api", files.per.chunk = 10)
dataTCGA<- TCGAbiolinks::GDCprepare(query)
save(file=paste0(inpD,"data.rds"),dataTCGA)
load(paste0(inpD,"data.rds"))
MMRnaseqSE <- MMRFGDC_prepare(query,
                              save = TRUE ,
                              save.filename = paste0(hdr ,"data.rda"),
                              directory = "GDCdata",
                              summarizedExperiment = TRUE)
MMRFdataPrepro <- TCGAanalyze_Preprocessing(MMRnaseqSE)
library(MMRFBiolinks)
load(paste0(inpD,hdr ,".rda"))
MMRnaseqSE <- data
MMRFdataPrepro <- TCGAbiolinks::TCGAanalyze_Preprocessing(dataTCGA)
save(file=paste0(inpD,"MMRFdataPrepro.rds"),MMRFdataPrepro)
tabSurvKM <- TCGAbiolinks::TCGAanalyze_SurvivalKM(MMRFclin,MMRFdataPrepro,Genelist = rownames(MMRFdataPrepro)[3],Survresult = F,ThreshTop=0.9999999,ThreshDown=0.00000001)
TCGAanalyze_SurvivalKM(MMRFclin,MMRFdataPrepro,Genelist = c("ENSG00000196976"),Survresult = T,ThreshTop=0.76,ThreshDown=0.33) #	Q14657	LAGE3
ENSG00000172315<-TCGAanalyze_SurvivalKM(MMRFclin,MMRFdataPrepro,Genelist = rownames(MMRFdataPrepro)[3],Survresult = F,ThreshTop=0.9999999,ThreshDown=0.00000001)
TCGAanalyze_SurvivalKM(MMRFclin,MMRFdataPrepro,Genelist = c("ENSG00000172315"),Survresult = T,ThreshTop=0.76,ThreshDown=0.33) #Q96S44	 TP53RK C20orf64, PRPK
ENSG00000170270<-TCGAanalyze_SurvivalKM(clinical,MMRFdataPrepro,Genelist = rownames(MMRFdataPrepro)[3],Survresult = F,ThreshTop=0.9999999,ThreshDown=0.00000001)
TCGAanalyze_SurvivalKM(MMRFclin,MMRFdataPrepro,Genelist = c("ENSG00000170270"),Survresult = T,ThreshTop=0.76,ThreshDown=0.33) #	Q9BXV9	GON7 C14orf142
ENSG00000275619<-TCGAanalyze_SurvivalKM(clinical,MMRFdataPrepro,Genelist = rownames(MMRFdataPrepro)[3],Survresult = F,ThreshTop=0.9999999,ThreshDown=0.00000001)
TCGAanalyze_SurvivalKM(MMRFclin,MMRFdataPrepro,Genelist = c("ENSG00000275619"),Survresult = T,ThreshTop=0.76,ThreshDown=0.33) #	Q9BXV9	GON7 C14orf142
ENSG00000092094<-TCGAanalyze_SurvivalKM(clinical,MMRFdataPrepro,Genelist = rownames(MMRFdataPrepro)[3],Survresult = F,ThreshTop=0.9999999,ThreshDown=0.00000001)
TCGAanalyze_SurvivalKM(MMRFclin,MMRFdataPrepro,Genelist = c("ENSG00000092094"),Survresult = T,ThreshTop=0.76,ThreshDown=0.33) #		Q9NPF4	OSGEP GCPL1
TCGAanalyze_SurvivalKM(MMRFclin,MMRFdataPrepro,Genelist = c("ENSG00000136932"),Survresult = T,ThreshTop=0.76,ThreshDown=0.33) #			Q9BU70	TRMO C9orf156, HSPC219
TCGAanalyze_SurvivalKM(MMRFclin,MMRFdataPrepro,Genelist = c("ENSG00000145996"),Survresult = T,ThreshTop=0.76,ThreshDown=0.33) #			Q5VV42	CDKAL1
TCGAanalyze_SurvivalKM(MMRFclin,MMRFdataPrepro,Genelist = c("ENSG00000128694"),Survresult = T,ThreshTop=0.76,ThreshDown=0.33) #		Q9NPF4	OSGEP GCPL1

tokenStop<- 1
tabSurvKMcomplete <- NULL
for( i in 1: round(nrow(MMRFdataPrepro)/500)){
    message( paste( i, "of ", round(nrow(MMRFdataPrepro)/100)))
    tokenStart <- tokenStop
    tokenStop <-100*i
    tabSurvKM <- TCGAanalyze_SurvivalKM(MMRFclin,
                                         MMRFdataPrepro,
                                         Genelist = rownames(MMRFdataPrepro)[tokenStart:tokenStop],
                                        Survresult = F,ThreshTop=0.76,ThreshDown=0.33)
    tabSurvKMcomplete <- rbind(tabSurvKMcomplete,tabSurvKM)
}
write.csv(tabSurvKMcomplete,paste0(inpD,"tabSurvKMcomplete.csv"))
tabSurvKMcompletePV1p <- tabSurvKMcomplete[tabSurvKMcomplete$pvalue < 0.01,]
```
```{r coMMpaSS}
coMM<-read.csv2(paste0(inpD,"CoMMpass_IA13a_E74GTF_Salmon_Gene_TPM_Sequential_GeneNames.txt"),sep="\t")
coMMai<-read.csv2(paste0(inpD,"MMRF_CoMMpass_IA13a_E74GTF_Salmon_Gene_Counts_Sequential_AllIncluded.txt"),sep="\t")
hist(as.numeric(coMM[grep("ENSG00000000003",coMM[,1]),4:ncol(coMM)]))
coMMai[grep("ENSG00000000003",coMM[,1]),3]
```

```{r plotKM}
library(TCGAbiolinks)
library(SummarizedExperiment)
library(dplyr)
library(DT)
library(ggplot2)
library("MMRFBiolinks")
query <- GDCquery(project = "MMRF-COMMPASS",
data.category = "Transcriptome Profiling",
data.type = "Gene Expression Quantification",
experimental.strategy = "RNA-Seq",
workflow.type="HTSeq - FPKM",
barcode = listSamples)
MMRFGDC_QueryClinic(type = "clinical")#has more information compared to the previous dataset (e.g Best overall response)
MMRFclin <- MMRFGDC_QueryClinic(type = "clinical")
listSamples <- MMRFclin$bcr_patient_barcode#c("MMRF_2473","MMRF_2111",                 "MMRF_2362","MMRF_1824","MMRF_1458","MRF_1361","MMRF_2203","MMRF_2762","MMRF_2680","MMRF_1797")
query <- GDCquery(project = "MMRF-COMMPASS",
data.category = "Transcriptome Profiling",
data.type = "Gene Expression Quantification",
experimental.strategy = "RNA-Seq",
workflow.type="HTSeq - FPKM",
barcode = listSamples)
MMRFGDC_QuerySummary(query)
MMRFclin[MMRFclin$bcr_patient_barcode=="MMRF_2137","treatments"]
barplot(summary(as.factor(unlist(MMRFclin$treatments))))
#TCGAbiolinks::GDCdownload(query, method = "api", files.per.chunk = 10)
#TCGAbiolinks::GDCdownload(query, method = "client", files.per.chunk = 10)
GDCdownload(query, method = "api", files.per.chunk = 10)
MMRnaseqSE <- MMRFGDC_prepare(query,
save = TRUE ,
save.filename = paste0(hdr ,"data.rda"),
directory = "GDCdata",
summarizedExperiment = TRUE)
MMRFdataPrepro <- TCGAanalyze_Preprocessing(MMRnaseqSE)
TCGAanalyze_SurvivalKM(clinical,MMRFdataPrepro,Genelist = c("ENSG00000196976"),Survresult = T,ThreshTop=0.76,ThreshDown=0.33) #	Q14657	LAGE3
TCGAanalyze_SurvivalKM(MMRFclin,MMRFdataPrepro,Genelist = c("ENSG00000196976"),Survresult = T,ThreshTop=0.76,ThreshDown=0.33) #	Q14657	LAGE3
ENSG00000172315<-TCGAanalyze_SurvivalKM(clinical,MMRFdataPrepro,Genelist = rownames(MMRFdataPrepro)[3],Survresult = F,ThreshTop=0.9999999,ThreshDown=0.00000001)
ENSG00000172315<-TCGAanalyze_SurvivalKM(MMRFclin,MMRFdataPrepro,Genelist = rownames(MMRFdataPrepro)[3],Survresult = F,ThreshTop=0.9999999,ThreshDown=0.00000001)
TCGAanalyze_SurvivalKM(MMRFclin,MMRFdataPrepro,Genelist = c("ENSG00000196976"),Survresult = T,ThreshTop=0.76,ThreshDown=0.33) #	Q14657	LAGE3
TCGAanalyze_SurvivalKM(MMRFclin,MMRFdataPrepro,Genelist = c("ENSG00000172315"),Survresult = T,ThreshTop=0.76,ThreshDown=0.33) #Q96S44	 TP53RK C20orf64, PRPK
TCGAanalyze_SurvivalKM(MMRFclin,MMRFdataPrepro,Genelist = c("ENSG00000170270"),Survresult = T,ThreshTop=0.76,ThreshDown=0.33) #	Q9BXV9	GON7 C14orf142
TCGAanalyze_SurvivalKM(MMRFclin,MMRFdataPrepro,Genelist = c("ENSG00000275619"),Survresult = T,ThreshTop=0.76,ThreshDown=0.33) #	Q9BXV9	GON7 C14orf142
TCGAanalyze_SurvivalKM(MMRFclin,MMRFdataPrepro,Genelist = c("ENSG00000092094"),Survresult = T,ThreshTop=0.76,ThreshDown=0.33) #		Q9NPF4	OSGEP GCPL1
save(file=paste0(inpD,".MMRFdataPrepro.rds"),MMRFdataPrepro)
save(file=paste0(inpD,"MMRFclin.rds"),MMRFclin)
TCGAanalyze_SurvivalKM(MMRFclin,MMRFdataPrepro,Genelist = c("ENSG00000136932"),Survresult = T,ThreshTop=0.76,ThreshDown=0.33) #			Q9BU70	TRMO C9orf156, HSPC219
TCGAanalyze_SurvivalKM(MMRFclin,MMRFdataPrepro,Genelist = c("ENSG00000145996"),Survresult = T,ThreshTop=0.76,ThreshDown=0.33) #			Q5VV42	CDKAL1
TCGAanalyze_SurvivalKM(MMRFclin,MMRFdataPrepro,Genelist = c("ENSG00000128694"),Survresult = T,ThreshTop=0.76,ThreshDown=0.33) #		Q9NPF4	OSGEP GCPL1
savehistory("L:/promec/Animesh/Aida/R.history")
```
```{r loadPlotDrugKM}
load(paste0(inpD,"MMRFBiolinks/plotKM/MMRFclin.rds"))
load(paste0(inpD,"MMRFBiolinks/plotKM/MMRFdataPrepro.rds"))
TCGAbiolinks::TCGAanalyze_SurvivalKM(MMRFclin,MMRFclin,Genelist = c("ENSG00000196449"),Survresult = T,ThreshTop=0.76,ThreshDown=0.33) #	Q86U90 (YRDC_HUMAN)
#MMRFclinDrug$treatments
MMRFclinDrug<- MMRFclin[which(unlist(MMRFclin[,"treatments"]) %in% c("Dexamethasone")==TRUE),]
MMRFclinDrug<- MMRFclinDrug[!is.na(MMRFclinDrug$bcr_patient_barcode),]
TCGAbiolinks::TCGAanalyze_SurvivalKM(MMRFclin,MMRFdataPrepro,Genelist = c("ENSG00000196449"),Survresult = T,ThreshTop=0.76,ThreshDown=0.33) #	Q86U90 (YRDC_HUMAN)
TCGAbiolinks::TCGAanalyze_SurvivalKM(MMRFclin,MMRFdataPrepro,Genelist = c("ENSG00000196449"),Survresult = T,ThreshTop=0.66,ThreshDown=0.33) #	Q86U90 (YRDC_HUMAN)
```

```{r bcr_patient_barcode}
cor(MMRFclin$days_to_last_follow_up,MMRFclin$days_to_death,use = "complete")
dClin<-cbind(Name=gsub("MMRF_","",MMRFclin$bcr_patient_barcode),Follow=MMRFclin$days_to_last_follow_up,Days=MMRFclin$days_to_death,Censor=MMRFclin$vital_status)
write.table(dClin,paste0(inpD,"MMRFclinBFD.txt"),row.names = F,sep="\t",quote = F)
```

```{r ENSG00000196449}
dENSG00000196449<-read.table(paste0(inpD,"ENSG00000196449.txt"),sep="\t",header=T)
hist(dENSG00000196449$ENSG00000196449)
hist(dENSG00000196449$T..Name)
```

```{r distrib}
hist(log2(MMRFdataPrepro))
```

```{r writeDataKM}
dfMMRFclin <- apply(data.frame(MMRFclin),2,as.character)
write.csv(dfMMRFclin,paste0(inpD,"MMRFclin.csv"),quote = T)
write.csv(MMRFdataPrepro,paste0(inpD,"MMRFdataPrepro.csv"))
```
```{r drugs}
library(MMRFBiolinks)
barplot(summary(as.factor(clinMMGateway$trtname)),horiz = T)
summary(as.factor(clinMMGateway$trtname))
MMRFRG_GetBorInfo(clinMMGateway)
MMRFRG_TimeBorPlot(clinMMGateway,"Dexamethasone","days")
MMRFBiolinks::MMRFRG_BorPlot(clinMMGateway,filename = "GBP")
#daratumumab is more immunemodulating vs bortezomib based treatments.
#https://ashpublications.org/blood/article/128/22/194/100519/Molecular-Predictors-of-Outcome-and-Drug-Response
MMRFGDC_QuerySummary(query)
```

```{r mapID2pathway}
library(org.Hs.eg.db)
uniP<-c("P07237","P28331","Q12931")
select(org.Hs.eg.db, uniP, "ENTREZID", "UNIPROT")
#http://data.wikipathways.org/current/gmt/
wp2gene <- clusterProfiler::read.gmt(paste0(inpD,"wikipathways-20210310-gmt-Homo_sapiens.gmt"))
wp2gene[grep("apoptosis",wp2gene$term,ignore.case = TRUE),]
uniP<-data$Uniprot.x
uniP <- lapply(uniP, as.character)
unlist(uniP)
uniP[[1]]
select(org.Hs.eg.db, unlist(uniP[[334]]), "ENTREZID", "UNIPROT")
uniL<-select(org.Hs.eg.db, unlist(uniP), "ENTREZID", "UNIPROT")
wp2gene[grep(uniL$ENTREZID[334],wp2gene$gene,ignore.case = TRUE),]
uniprots <- Rkeys(org.Hs.egUNIPROT)
uniprots2entrez <- select(org.Hs.eg.db, uniprots, "ENTREZID", "UNIPROT")
dataSez<-merge(sort=F,data, uniprots2entrez, by.x="Uniprot.x", by.y="UNIPROT")
dataSezWP<-merge(sort=F,dataSez, wp2gene, by.x="ENTREZID", by.y="gene")
#rownames(dataSezWP)<-paste(dataSezWP$T..T..Uniprot,dataSezWP$T..T..Line,dataSezWP$ENTREZID,dataSezWP$name,sep = "_")
#dataS<-dataSezWP
```

```{r completeKM}
load(paste0(inpD,"MMRFBiolinks/plotKM/MMRFclin.rds"))
load(paste0(inpD,"MMRFBiolinks/plotKM/MMRFdataPrepro.rds"))
tabSurvKMcomplete <- NULL
for( i in 1: nrow(MMRFdataPrepro)){
    message( paste( i, "of ", nrow(MMRFdataPrepro), rownames(MMRFdataPrepro)[i]))
    tabSurvKM=TCGAbiolinks::TCGAanalyze_SurvivalKM(MMRFclin,MMRFdataPrepro,Genelist=rownames(MMRFdataPrepro)[i],Survresult = F,ThreshTop=0.76,ThreshDown=0.33,p.cut=2)
    tabSurvKMcomplete <- rbind(tabSurvKMcomplete,tabSurvKM)
}
hist(tabSurvKMcomplete$pvalue,breaks = 100)
write.csv(tabSurvKMcomplete,paste0(inpD,"completeKM.csv"))
```

```{r loadMapCompleteKM}
completeKMload<-tabSurvKMcomplete
tabSurvKMcomplete<-read.csv("L:/promec/Animesh/Aida/completeKM.csv")
hist(tabSurvKMcomplete$pvalue,breaks = 100)
tabSurvKMcomplete[tabSurvKMcomplete[,1]=="ENSG00000196976",]#http://10.20.93.118:3838/plotKM/
#X       pvalue Group2.Deaths Group2.Deaths.with.Top Group2.Deaths.with.Down Mean.Group2.Top
#5521 ENSG00000196976 1.449573e-05           100                     61                      39        37.74869
#     Mean.Group2.Down Mean.Group1
#5521         12.88386    22.53076
ensG<-tabSurvKMcomplete$X
ensG <- lapply(ensG, as.character)
unlist(ensG)
ensG[[1]]
#BiocManager::install("org.Hs.eg.db")
library(org.Hs.eg.db)
keytypes(org.Hs.eg.db)
select(org.Hs.eg.db, unlist(ensG[[1]]), c('ENTREZID','SYMBOL','GENENAME'), "ENSEMBL")
ensL<-select(org.Hs.eg.db, unlist(ensG), c('ENTREZID','SYMBOL','GENENAME'), "ENSEMBL")
#uniprots <- Rkeys(org.Hs.egUNIPROT)
dataSez<-merge(sort=F,tabSurvKMcomplete, ensL, by.x="X", by.y="ENSEMBL",all=T)
#dataSez<-merge(sort=F,dataSez, wp2gene, by.x="ENTREZID", by.y="gene")
write.csv(dataSez,paste0(inpD,"completeKMmap.csv"))
#install.packages("writexl")
#install.packages("readxl")
writexl::write_xlsx(dataSez,paste0(inpD,"completeKMmap.xlsx"))
```

```{r geneListTestFE, echo = FALSE}
#ORA: ORA’s propensity for type I error rate inflation when genes tend to be co-expressed within sets
#listG<-as.data.frame(toupper(c("TPD52", "BCM", "LILRB4", "FADS2", "C11orf58", "GAA", "CGREF1", "TSG101", "ZNRF2", "COG4", "UPF3B")))
match<-table(wp2gene[grep("Apoptosis%WikiPathways_20210310%WP254%Homo sapiens",wp2gene$term),])
fisher.test(rbind(c(sum(match),nrow(match)-sum(match)),c(nrow(wp2gene)
,nrow(wp2gene)-nrow(match))), alternative="less")$p.value

```

```{r string-DB, echo = FALSE}
#https://www.bioconductor.org/packages/release/bioc/vignettes/STRINGdb/inst/doc/STRINGdb.pdf
#library("BiocManager",lib="C:/Users/animeshs/GD/R_libs")
#BiocManager::install("STRINGdb")#,lib="C:/Users/animeshs/GD/R_libs")
library("STRINGdb")#,lib="C:/Users/animeshs/GD/R_libs")
string_db <- STRINGdb$new(species=9606, version="11",score_threshold=0, input_directory="")
ung2 = string_db$mp( "ung2" )
pcna = string_db$mp( "pcna" )
string_db$get_neighbors(c(ung2, pcna))
string_db$get_interactions(c(ung2, pcna))
string_db$get_paralogs(pcna)
string_db$get_homologs_besthits(ung2)
string_db$get_homologs_besthits(c(ung2,pcna),target_species_id=10090)#,bitscore_threshold=60)
```

```{r add-gene, echo = FALSE}
chkStrSdb<-string_db$map(list11,"gene")#,removeUnmappedRows = TRUE )
chkStrPlot<-string_db$plot_network(chkStrSdb$STRING_id)#[1:10])
#example1_mapped_pval05 <- string_db$add_diff_exp_color( subset(example1_mapped, pvalue<0.05), logFcColStr="logFC" )
#payload_id <- string_db$post_payload( example1_mapped_pval05$STRING_id,colors=example1_mapped_pval05$color )
#string_db$plot_network( hits, payload_id=payload_id )
list5<-as.data.frame(toupper(c("SMG5","UPF1","UPF2","VPS28","VPS37B")))
colnames(list5)<-"gene"
list16<-rbind(list5,list11)
summary(list16)
chkStrSdbX<-string_db$map(list16,"gene")#,removeUnmappedRows = TRUE )
chkStrPlotX<-string_db$plot_network(chkStrSdbX$STRING_id)#[1:10])
#example1_mapped_pval05 <- string_db$add_diff_exp_color( subset(example1_mapped, pvalue<0.05), logFcColStr="logFC" )
#payload_id <- string_db$post_payload( example1_mapped_pval05$STRING_id,colors=example1_mapped_pval05$color )
#string_db$plot_network( hits, payload_id=payload_id )
hits <- chkStrSdbX$STRING_id#[1:10]
enrichment <- string_db$get_enrichment( hits )
head(enrichment)#, n=20)
backgroundX <- chkStrSdbX$STRING_id#[1:2000]
string_db$set_background(backgroundX)
string_db <- STRINGdb$new(score_threshold=200,backgroundV=backgroundX)
annotations <- string_db$get_annotations( hits )
head(annotations, n=20)es
clustersList <- string_db$get_clusters(chkStrSdbX$STRING_id)#[1:600])
length(clustersList)
#par(mfrow=c(ceiling(sqrt(length(clustersList))),floor(sqrt(length(clustersList)))))
#for(i in seq(1:length(clustersList))){ string_db$plot_network(clustersList[[i]]) }
```


```{r geneRanked, echo = FALSE}
#GSEA [60] or pre-ranked CAMERA [66], apply a VST such as voom [39] to arrive at library-size normalized logCPMs for raw counts
```

```{r geneSamples, echo = FALSE}
#If the question of interest is to test for association of any gene in the set with the phenotype (self-contained null hypothesis), we recommend ROAST or GSVA that both test a directional hypothesis (genes in the set tend to be either predominantly up- or down-regulated). Both methods can be applied for simple or extended experimental designs, where ROAST is the more natural choice for the comparison of sample groups and also allows one to test a mixed hypothesis (genes in the set tend to be differentially expressed, regardless of the direction).
```

```{r geneN1, echo = FALSE}
#GSVA
```


```{r overlap}
dataV<-data[,grep(pattern = "WSRT",colnames(data))]
cn<-strsplit(colnames(dataV), "_")
colnames(dataV)<-paste(sapply(cn, "[", 3),sapply(cn, "[", 4))
library(limma)
vennDiagram(dataV<selThr)
#hist(rowSums(as.matrix(dataV)))
table(dataSezWP[dataSezWPs[,1]<selThr,31])#MONO
wikiT<-as.matrix(table(dataSezWP[dataSezWPs[,2]<selThr,31]))#MCCAR
sum(wikiT)#1941
wikiT[row.names(wikiT)=="WP411"]#58
wikiTot<-as.matrix(table(dataSezWP[,31]))
sum(wikiTot)#4972
wikiTot[row.names(wikiTot)=="WP411"]#71
wikiWP4204 <- matrix(c(6,11,3400,1700), nrow = 2,dimnames =list(wikiP=c("full", "selected"),pWiki=c("selected", "other")))
fisher.test(wikiWP4204, alternative = "less")
sel<-628
dat<-5086
ovl<-6
tp<-17
ovl<-10
tp<-106
ovl<-4
tp<-13
(tp/dat)/(ovl/sel)
ovl+sel-ovl+tp-ovl+dat-((sel-ovl)+(tp-ovl)+ovl)
wikiP <-matrix(c(ovl, tp-ovl,sel-ovl,dat-((sel-ovl)+(tp-ovl)+ovl)),nrow = 2,dimnames = list(P = c("S", "NS"),D = c("S", "NS")))
fisher.test(wikiP)#, alternative = "greater")
```

```{r overlap-plot}
library(ggplot2)
ggsave(file=paste0(inpF,"venn.svg"),plot=vennDiagram(dataV<selThr))#,  width=6, height=6)
```

```{r sel-WSRT}
dataS<-data[(data$ONO_.WSRT<selThr & data$CCAR_.WSRT<selThr) | (data$ONO_.WSRT<selThr & data$B_.WSRT<selThr) | (data$B_.WSRT<selThr & data$CCAR_.WSRT<selThr) | (data$ONO_.WSRT<selThr & data$NB_.WSRT<selThr) | (data$NB_.WSRT<selThr & data$CCAR_.WSRT<selThr) | (data$NB_.WSRT<selThr & data$B_.WSRT<selThr) ,]
hist(rowSums(as.matrix(dataS[,c(1,2,3,6)])))
vennDiagram(dataS[,c(1,2,3,6)]<selThr)
```


```{r apim, echo = FALSE}
dataSel <- data[,grep("apim", colnames(data),ignore.case=TRUE)]
rownames(dataSel)<-paste0(data$T..Protein.IDs,"_APIM")
dataSel<-dataSel[,c(6:9)]
cn<-strsplit(colnames(dataSel), "_")
colnames(dataSel)<-paste0(sapply(cn, "[", 3),sapply(cn, "[", 4))
vennDiagram(dataSel[,c(1:4)]<selThr,main="APIM",counts.col = "red")
summary(dataSel)
hist(as.matrix(dataSel[,c(2:4)]))
plot(dataSel)
```

```{r apim-model, echo = FALSE}
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
```

```{r stat, echo = FALSE}
dataSel <- dataSezWP[grep("stat", dataSezWP$name,ignore.case=TRUE),]
vennDiagram(dataSel[,c(3,4,5,8)]<selThr,main="STAT",counts.col = "red")
dataSel<-dataSel[,grep("_x.y_",colnames(dataSel))]
dataSel<-dataSel[,-grep("D_x.y_",colnames(dataSel))]
dataSel<-dataSel[,-grep("C_x.y_",colnames(dataSel))]
rownames(dataSel)<-paste0(rownames(dataSel),"_STAT")
dataSelSTAT<-dataSel
summary(dataSelSTAT)
```

```{r mapk, echo = FALSE}
dataSel <- dataSezWP[grep("mapk", dataSezWP$name,ignore.case=TRUE),]
vennDiagram(dataSel[,c(3,4,5,8)]<selThr,main="MAPK",counts.col = "red")
dataSel<-dataSel[,grep("_x.y_",colnames(dataSel))]
dataSel<-dataSel[,-grep("D_x.y_",colnames(dataSel))]
dataSel<-dataSel[,-grep("C_x.y_",colnames(dataSel))]
rownames(dataSel)<-paste0(rownames(dataSel),"_MAPK")
dataSelMAPK<-dataSel
summary(dataSelMAPK)
```

```{r ampk, echo = FALSE}
dataSel <- dataSezWP[grep("ampk", dataSezWP$name,ignore.case=TRUE),]
vennDiagram(dataSel[,c(3,4,5,8)]<selThr,main="AMPK",counts.col = "red")
dataSel<-dataSel[,grep("_x.y_",colnames(dataSel))]
dataSel<-dataSel[,-grep("D_x.y_",colnames(dataSel))]
dataSel<-dataSel[,-grep("C_x.y_",colnames(dataSel))]
rownames(dataSel)<-paste0(rownames(dataSel),"_AMPK")
dataSelAMPK<-dataSel
summary(dataSelAMPK)
```

```{r PI3K/AKT/mTOR, echo = FALSE}
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
```

```{r Apoptosis, echo = FALSE}
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
```


```{r sel-data-cols, echo = FALSE}
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
#```

#```{r clust-plot, echo = FALSE}
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
```

```{r apohc-sel-data-cols, echo = FALSE}
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
```
```{r sel-data-cols, echo = FALSE}
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
```
```{r mapkhc-sel-data-cols, echo = FALSE}
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
```
```{r ampkhc-sel-data-cols, echo = FALSE}
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
```
```{r stathc-sel-data-cols, echo = FALSE}
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
```
```{r pi3kallhc-sel-data-cols, echo = FALSE}
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
```

```{r sel-data-cols, echo = FALSE}
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
```


```{r select-hdr-log2, echo = FALSE}
#hdr="LFQ.intensity."
hdr="Ratio.H.L.6"
datLog2LFQ=log2(data[,grep(hdr, names(data))])
summary(datLog2LFQ)
hist(as.matrix(datLog2LFQ))
```

```{r remove-samples, echo = FALSE}
samples="ENDOSOME"
datLog2LFQ=log2(datLog2LFQ[,-grep(samples, names(datLog2LFQ))])
summary(datLog2LFQ)
hist(as.matrix(datLog2LFQ))
```

```{r select-grp, echo = FALSE}
group="PCI"
datLog2LFQ=log2(datLog2LFQ[,grep(group, names(datLog2LFQ))])
summary(datLog2LFQ)
hist(as.matrix(datLog2LFQ))
```

```{r select-grp, echo = FALSE}
group="PDT"
datLog2LFQ=log2(datLog2LFQ[,grep(group, names(datLog2LFQ))])
summary(datLog2LFQ)
hist(as.matrix(datLog2LFQ))
```

```{r select-grp, echo = FALSE}
group="bleomycin"
datLog2LFQ=log2(datLog2LFQ[,grep(group, names(datLog2LFQ))])
summary(datLog2LFQ)
hist(as.matrix(datLog2LFQ))
```

```{r clean, echo = FALSE}
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
```


```{r norm, echo = FALSE}
hdr="LFQ.intensity."
dataNorm=log2(dataClean[,grep(hdr, names(dataClean))])
summary(dataNorm)
hist(as.matrix(dataNorm))
```

```{r select, echo = FALSE}
dataNormFilter<-dataNorm
dataNormFilter[dataNormFilter==-Inf]=NA
summary(dataNormFilter)
selThr<-2
dataNormFilter$Red = apply(dataNormFilter,1,function(x) sum(is.na(x[3:5])))
dataNormFilter$White = apply(dataNormFilter,1,function(x) sum(is.na(x[c(1,2,6)])))
dataNormFilter.Select = dataNormFilter[dataNormFilter$Red<selThr | dataNormFilter$White<selThr,1:6]
summary(dataNormFilter.Select)
```


```{r euler,echo=F}
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
```


```{r imputeFilter, echo = FALSE}
dataNormImpFilter<-dataNormFilter.Select
summary(dataNormImpFilter)
set.seed(1)
#dataNormImpFilter[is.na(dataNormImpFilter)]<-rnorm(sum(is.na(dataNormImpFilter)),mean=mean(dataNormImpFilter[!is.na(dataNormImpFilter)])-3,sd=sd(!is.na(dataNormImpFilter))/3)
dataNormImpFilter[is.na(dataNormImpFilter)]<-rnorm(sum(is.na(dataNormImpFilter)),mean=mean(dataNormImpFilter[!is.na(dataNormImpFilter)])-12,sd=sd(!is.na(dataNormImpFilter))/12)
summary(dataNormImpFilter)
hist(as.matrix(dataNormImpFilter))
```

```{r PCA, echo = FALSE}
dataNormImpCom<-dataNormImpFilter
plot(princomp(dataNormImpCom))
#biplot(prcomp(as.matrix(t(dataNormImpCom)),scale = T))
#biplot(prcomp(dataNormImpCom,scale = F))
#biplot(prcomp(dataNormImpCom,scale = T),col=c(1,8), cex=c(0.5, 0.4))
```

```{r t-test, echo = FALSE}
pVal = apply(dataNormImpFilter, 1, function(x) t.test(as.numeric(x[c(3:5)]),as.numeric(x[c(1,2,6)]),var.equal=T)$p.value)
logFC = rowMeans(dataNormImpFilter[,c(3:5)])-rowMeans(dataNormImpFilter[,c(1,2,6)])
ttest.results = data.frame(gene=rownames(dataNormImpFilter),logFC=logFC,P.Value = pVal, adj.pval = p.adjust(pVal,method = "BH"))
#ttest.results$PSMcount = psm.count.table[ttest.results$gene,"count"]
ttest.results = ttest.results[with(ttest.results, order(P.Value)), ]
head(ttest.results)
write.csv(ttest.results,file=paste0(inpD,hdr,"tTestBH.csv"))
plot(logFC,-log10(pVal),col="orange",)
```


```{r t-test-plot, echo = FALSE}
dsub=subset(ttest.results,ttest.results$P.Value<0.05&abs(ttest.results$logFC)>0.58)
#rn<-do.call(rbind, strsplit(rownames(dsub), '\\.'))
rn<-strsplit(rownames(dsub), ';')
row.names(dsub) <- sapply(rn, "[", 1)#rn[[1]]
g = ggplot(ttest.results,aes(logFC,-log10(P.Value)))+geom_point(aes(color=adj.pval),size=0.15) + theme_bw(base_size=10) +geom_text(data=dsub,aes(label=row.names(dsub)), vjust=0.5, size=1.5) + xlab("Log2 Fold Change (Red-White)")  + ylab("-Log10 P-value") + ggtitle("Differentially expressed proteins") + scale_size_area()+scale_color_gradient(low="#FF9933", high="#99CC66")
plot(g)
#install.packages('svglite')
ggsave(file=paste0(inpD,hdr,"volcanoPlot.svg"),plot=g)#,  width=6, height=6)
```

```{r t-test-fraction-plot, echo = FALSE}
#dsub=data[grep("apo",data$Fasta.headers),]
dsub=data[(grepl("apo",data$Fasta.headers))|(grepl("alb",data$Fasta.headers)),]
dsub=merge(sort=F,dsub,ttest.results,by="row.names")
rn<-strsplit(dsub$Row.names, ';')
row.names(dsub) <- sapply(rn, "[", 1)#rn[[1]]
g = ggplot(ttest.results,aes(logFC,-log10(P.Value)))+geom_point(aes(color=adj.pval),size=0.15) + theme_bw(base_size=10) +geom_text(data=dsub,aes(label=row.names(dsub)), vjust=0.5, size=1.5) + xlab("Log2 Fold Change (Red-White)")  + ylab("-Log10 P-value") + ggtitle("Differentially expressed proteins") + scale_size_area()+scale_color_gradient(low="#FF9933", high="#99CC66")
plot(g)
ggsave(file=paste0(inpD,hdr,"volcanoPlot.frac.svg"),plot=g)#,  width=6, height=6)
```

```{r fraction-clust-plot, echo = FALSE}
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
```


```{r ROTS, echo = FALSE}
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
```

```{r imputeFilter-ttest, echo = FALSE}
pairwise.t.test(as.matrix(dataNormImpFilter),c(0,0,1,1,1,0))#[1,3:5],dataNormImpFilter[1,c(1,2,6)])
```

```{r write-output, echo = FALSE}
write.table(dataNorm,file=paste0(inpD,"log2data.txt"), sep = "\t")
#dump(dataNorm,file=paste0(inpD,"dataNorm.R"))
```


```{r impute, echo = FALSE}
#install.packages('mice')
library(mice)
#install.packages('randomForest')
library(randomForest)
dataNormImp=mice(dataNorm, method="rf")
dataNormImpCom <- complete(dataNormImp,1)
row.names(dataNormImpCom)<-row.names(dataNorm)
summary(dataNormImpCom)
```

```{r write-output, echo = FALSE}
write.csv(dataNormImpCom,file=paste0(inpD,"log2dataImp.csv"))
#write.csv(factors,file=paste0(inpD,"dataNormImpComFactor.csv"))
dataNormImpCom <- read.csv(paste0(inpD,"log2dataImp.csv"),row.names=1,header = T)
#factors<-read.csv(paste0(inpD,"dataNormImpComFactor.csv"))
#dump(dataNorm,file=paste0(inpD,"dataNorm.R"))
```



```{r DEqMS}
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
```

```{r DEqMS-peptides}
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
#CoRegNet####
#https://bioconductor.org/packages/release/bioc/vignettes/CoRegNet/inst/doc/CoRegNet.html
library(CoRegNet)
data(CIT_BLCA_EXP,HumanTF,CIT_BLCA_Subgroup)
dim(CIT_BLCA_EXP)
#showing 6 first TF in the gene expression dataset
head(intersect(rownames(CIT_BLCA_EXP),HumanTF))
grn = hLICORN(CIT_BLCA_EXP, TFlist=HumanTF)
influence = regulatorInfluence(grn,CIT_BLCA_EXP)
coregs= coregulators(grn)
display(grn,CIT_BLCA_EXP,influence,clinicalData=CIT_BLCA_Subgroup)
#mmCoRegNet####
library(CoRegNet)
dataCombCRN<-data.frame(dataComb)
dataCombCRN$uniprotID<-rownames(dataCombCRN)
dataCombCRN$geneName<-paste(sapply(strsplit(paste(sapply(strsplit(dataCombCRN$uniprotID, ";",fixed=T), "[", 1)), " "), "[", 1))
dataCombCRN$geneName[duplicated(dataCombCRN$geneName)] <- paste(sapply(strsplit(paste(sapply(strsplit(dataCombCRN$uniprotID, ";",fixed=T), "[", 2:3)), " "), "[", 1))
#dataCombCRN[dataCombCRN$geneName=="NA","geneName"]=paste(sapply(strsplit(paste(sapply(strsplit(dataCombCRN$uniprotID, ";",fixed=T), "[", 2:3)), " "), "[", 1))
dataCombCRN[dataCombCRN$geneName=="NA","geneName"]=dataCombCRN[dataCombCRN$geneName=="NA","uniprotID"]
rownames(dataCombCRN)<-dataCombCRN$geneName
dim(dataCombCRN)
dataCombCRN<-dataCombCRN[,1:46]
dim(dataCombCRN)
intersect(rownames(dataCombCRN),HumanTF)
dataCombCRN[is.na(dataCombCRN)]<-0
grnMM = hLICORN(dataCombCRN, TFlist=HumanTF)
saveRDS(grnMM,file=paste0(inpD,"grnM.rds"))
readRDS(grnMM,file=paste0(inpD,"grnM.rds"))
print(grnMM)
influence = regulatorInfluence(grnMM,dataCombCRN)
coregs= coregulators(grnMM)
display(grnMM,dataCombCRN,influence)#,clinicalData=dataCombCRN_Subgroup)
#parallel####
library(parallel)
no_cores <- detectCores(logical = TRUE)/2
options("mc.cores"=no_cores)
grn =hLICORN(head(CIT_BLCA_EXP,200), TFlist=HumanTF)
print(grn)
options("mc.cores"=no_cores*2)
grn =hLICORN(head(CIT_BLCA_EXP,200), TFlist=HumanTF)
print(grn)
#mmImpCoRegNet####
data<-read.csv(paste0(inpD,"mm.csv"))
dataT<-t(data)
dataT<-data.frame(dataT[1:3956,])
rN<-rownames(dataT)
rN<-gsub("_", "",rN)
dataT<-sapply(dataT,as.numeric)
hist(dataT)
colnames(dataT)
rownames(dataT)<-rN
boxplot(dataT)
rN<-sapply(strsplit(row.names(dataT), ".",fixed=T), "[",1)
uP2<-sapply(strsplit(row.names(dataT), ".",fixed=T), "[",2)
uP3<-sapply(strsplit(row.names(dataT), ".",fixed=T), "[",3)
rN[rN=="NA"]<-uP2[rN=="NA"]
rN[duplicated(rN)]<-paste(rN[duplicated(rN)],uP2[duplicated(rN)],uP3[duplicated(rN)],sep="xxx")
rN<-data.frame(rN)
row.names(dataT)<-rN[,"rN"]
write.csv(dataT,paste0(inpD,"dataTmm.csv"))
intersect(rownames(dataT),HumanTF)
grnMMimp = hLICORN(dataT, TFlist=HumanTF)
saveRDS(grnMMimp,file=paste0(inpD,"grnMMimp.rds"))
readRDS(grnMMimp,file=paste0(inpD,"grnMMimp.rds"))
print(grnMMimp)
influence = regulatorInfluence(grnMMimp,dataT)
coregs= coregulators(grnMMimp)
display(grnMMimp,dataT,influence)#,clinicalData=dataCombCRN_Subgroup)
#aracne####
BiocManager::install("aracne.networks")
library(aracne.networks)
data(package="aracne.networks")$results[, "Item"]
#lionessR####
install.packages("BiocManager")
#install.packages("jsonlite")
M<-read.csv(paste0(inpD,"dataTmm.csv"),header=T,row.names=1)
library(lionessR)#, help, pos = 2, lib.loc = NULL)
cormat <- lionessR::lioness(as.matrix(M))
save.image(paste0(inpD,"dataTmm.cormat.RData"))
class(cormat)
rownames(cormat)
gLioness<-cormat@assays@data[[1]]
BiocManager::install("igraph")
giLioness<-igraph::graph.data.frame(gLioness, directed=F)
BiocManager::install("lionessR")
M<-dataT
nsel = nrow(M)
#M <- exp
cvar <- apply(as.array(as.matrix(M)), 1, sd)
dat <- cbind(cvar, M)
dat <- dat[order(dat[,1], decreasing=T),]
dat <- dat[1:nsel, -1]
dat <- as.matrix(dat)

##  two condition-specific networks
groupMM    <- c(15:46)
groupMGUS  <- c(1:9)
groupMGUSl <- c(10:15)


netMM              <- cor(t(dat[,groupMM]))
netMGUS            <- cor(t(dat[,groupMGUS]))
netdiff_MM_MGUS    <- netMM-netMGUS

netMGUS            <- cor(t(dat[,groupMGUS]))
netMGUSl           <- cor(t(dat[,groupMGUSl]))
netdiff_MGUS_MGUSl <- netMGUSl-netMGUS

netMM              <- cor(t(dat[,groupMM]))
netMGUSl           <- cor(t(dat[,groupMGUSl]))
netdiff_MM_MGUSl   <- netMM-netMGUSl


#netyes <- cor(t(dat[,groupMM]))
#netno <- cor(t(dat[,groupMGUS]))
#netdiff <- netyes-netno


## convert these adjacency matrices to edgelists
cormat2 <- rep(1:nsel, each=nsel)
cormat1 <- rep(1:nsel,nsel)


el <- cbind(cormat1, cormat2, c(netdiff_MM_MGUS))


melted <- melt(upper.tri(netdiff_MM_MGUS))
melted <- melted[which(melted$value),]
values <- netdiff_MM_MGUS[which(upper.tri(netdiff_MM_MGUS))]
melted <- cbind(melted[,1:2], values)
genes <- row.names(netdiff_MM_MGUS)
melted[,1] <- genes[melted[,1]]
melted[,2] <- genes[melted[,2]]
row.names(melted) <- paste(melted[,1], melted[,2], sep="_")
tosub <- melted
tosel <- row.names(tosub[which(abs(tosub[,3])>0.5),])
library(lionessR)
cormat <- lioness(M)
corsub <- cormat[which(row.names(cormat)  %in% tosel) ,]
CC <- corsub@assays@data[[1]]
rownames(CC) <- rownames(corsub)


data(regulonblca)
write.regulon(regulonblca, n = 10)
data(regulonblca)
write.regulon(regulonblca, regulator="399")
#aracne####
BiocManager::install("RegEnrich")
library(RegEnrich)
object = RegenrichSet(expr = dataT, # expression data (matrix)
                      colData = sampleInfo, # sample information (data frame)
                      reg = regulators, # regulators
                      method = "limma", # differentila expression analysis method
                      design = designMatrix, # desing model matrix
                      contrast = contrast, # contrast
                      networkConstruction = "COEN", # network inference method
                      enrichTest = "FET") # enrichment analysis method
data(Lyme_GSE63085)
FPKM = Lyme_GSE63085$FPKM
data(TFs)
comG<-intersect(TFs$TF_name,rownames(dataT))
