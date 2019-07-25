#Everything Is Correlated -> https://www.gwern.net/Everything
#Common statistical tests are linear models (or: how to teach stats) -> https://lindeloev.github.io/tests-as-linear/
#books:
#rmarkdown->https://bookdown.org/yihui/rmarkdown/
#plot->https://plotly-r.com/introduction.html#data-visualization-best-practices , https://serialmentor.com/dataviz/
#analysis->http://compgenomr.github.io/book/clustering-grouping-samples-based-on-their-similarity.html#how-to-choose-k-the-number-of-clusters
#estimator->https://www.r-bloggers.com/blackman-tukey-spectral-estimator-in-r/


#data
inpD <-"F:/promec/Elite/LARS/2018/november/Rolf final/txt/"
data <- read.delim(paste0(inpD,"proteinGroups.txt"),row.names=1,sep="\t",header = T)
decoyPrefix="REV__"
dataClean<-data[-grep(decoyPrefix, rownames(data)),]
contaminantPrefix="CON__"
dataClean=dataClean[!dataClean$Potential.contaminant=="+",]
summary(dataClean)
hdr="LFQ.intensity."
dataLFQ=dataClean[,grep(hdr, names(dataClean))]
dataNorm=log2(dataLFQ)
summary(dataNorm)
dataNormFilter<-dataNorm
dataNormFilter[dataNormFilter==-Inf]=NA
summary(dataNormFilter)
dataNormImpFilter<-dataNormFilter
dataNormImpFilter[is.na(dataNormImpFilter)]<-rnorm(sum(is.na(dataNormImpFilter)),mean=mean(dataNormImpFilter[!is.na(dataNormImpFilter)])-12,sd=sd(!is.na(dataNormImpFilter))/12)
summary(dataNormImpFilter)
hist(as.matrix(dataNormImpFilter))

#t.test -> https://rdrr.io/bioc/DEqMS/f/vignettes/DEqMS-package-vignette.Rmd
pVal = apply(dataNormImpFilter, 1, function(x) t.test(as.numeric(x[c(3:5)]),as.numeric(x[c(1,2,6)]),var.equal=T)$p.value)
logFC = rowMeans(dataNormImpFilter[,c(3:5)])-rowMeans(dataNormImpFilter[,c(1,2,6)])
ttest.results = data.frame(prot=rownames(dataNormImpFilter),logFC=logFC,P.Value = pVal, adj.pval = p.adjust(pVal,method = "BH"))
ttest.results = ttest.results[with(ttest.results, order(P.Value)), ]
head(ttest.results)
write.csv(ttest.results,file=paste0(inpD,hdr,"tTestBH.csv"))
plot(logFC,-log10(pVal),col="orange",)
dsub=data[(grepl("apo",data$Fasta.headers))|(grepl("alb",data$Fasta.headers)),]
dsub=merge(dsub,ttest.results,by="row.names")
rn<-strsplit(dsub$Row.names, ';')
row.names(dsub) <- sapply(rn, "[", 1)#rn[[1]]
library(ggplot2)
g = ggplot(ttest.results,aes(logFC,-log10(P.Value)))+geom_point(aes(color=adj.pval),size=0.15) + theme_bw(base_size=10) +geom_text(data=dsub,aes(label=row.names(dsub)), vjust=0.5, size=1.5) + xlab("Log2 Fold Change (Red-White)")  + ylab("-Log10 P-value") + ggtitle("Differentially expressed proteins") + scale_size_area()+scale_color_gradient(low="#FF9933", high="#99CC66")
plot(g)
ggsave(file=paste0(inpD,hdr,"volcanoPlot.frac.svg"),plot=g)#,  width=6, height=6)

#Variance Stabilizing Transformation -> https://rawgit.com/ChristophH/sctransform/master/inst/doc/variance_stabilizing_transformation.html
prot_attr <- data.frame(mean = rowMeans(dataLFQ), detection_rate = rowMeans(dataLFQ > 0),var = apply(dataLFQ, 1, var))
prot_attr$log_mean <- log10(prot_attr$mean)
prot_attr$log_var <- log10(prot_attr$var)
rownames(prot_attr) <- rownames(dataLFQ)
cell_attr <- data.frame(n_umi = colSums(dataLFQ),n_prot = colSums(dataLFQ > 0))
rownames(cell_attr) <- colnames(dataLFQ)
ggplot(prot_attr, aes(log_mean, log_var)) +  geom_point(alpha=0.3, shape=16) +  geom_density_2d(size = 0.3) +  geom_abline(intercept = 0, slope = 1, color='red')
#TBD:scale accordingly
x = seq(from = 0, to = 12, length.out = 1000)
poisson_model <- data.frame(log_mean = x, detection_rate = 1 - dpois(0, lambda = 10^x))
ggplot(prot_attr, aes(log_mean, detection_rate)) +  geom_point(alpha=0.3, shape=16) + geom_line(data=poisson_model, color='red') +theme_gray(base_size = 8)
