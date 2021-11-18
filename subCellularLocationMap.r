#dataQE####
inpF<-"L:/promec/Qexactive/LARS/2021/november/subcellular/combined/txt/proteinGroups.txt"
data<-read.table(inpF,header=T,sep="\t",row.names=1)
summary(data)
colnames(data)
dataLog2LFQ<-log2(as.matrix(data[65:70]))
row.names(dataLog2LFQ)<-row.names.data.frame(data)
dataLog2LFQ[is.na(dataLog2LFQ)]<-0
dataLog2LFQ[is.infinite(dataLog2LFQ)]<-0
summary(dataLog2LFQ)
colnames(dataLog2LFQ)=sub("LFQ.intensity.","",colnames(dataLog2LFQ))
summary(dataLog2LFQ)
hist(dataLog2LFQ)
dataLog2LFQanova<-posthocANOVA(dataLog2LFQ)
write.csv(dataLog2LFQanova,paste0(inpF,"dataLog2LFQanova",".csv"))
cytID<-paste(sapply(strsplit(row.names(dataLog2LFQanova)[which(dataLog2LFQanova$Nuc.Cyt.PvalueTukeyHSD<0.01&dataLog2LFQanova$Nuc.Cyt.Difference<(-1)&dataLog2LFQanova$Org.Cyt.Difference<(-1)&dataLog2LFQanova$Org.Cyt.PvalueTukeyHSD<0.01)], ";",fixed=T), "[", 1))
cytIDgo<-selGO(cytID,"cytosol")
write.csv(cytIDgo,paste0(inpF,"cytIDgoFC",".csv"))
#combGO<-merge(xWM2,GeneOntologyObj,by="ID")#,all.x = T)
#writexl::write_xlsx(combGO,paste0(inpF,"GOxWM2.xlsx"))
nucID<-paste(sapply(strsplit(row.names(dataLog2LFQanova)[which(dataLog2LFQanova$Nuc.Cyt.PvalueTukeyHSD<0.01&dataLog2LFQanova$Org.Nuc.PvalueTukeyHSD<0.01&dataLog2LFQanova$Org.Nuc.Difference<(-1)&dataLog2LFQanova$Nuc.Cyt.Difference>1)], ";",fixed=T), "[", 1))
nucIDgo<-selGO(nucID,"nuclear")
write.csv(nucIDgo,paste0(inpF,"nucIDgoFC",".csv"))
orgID<-paste(sapply(strsplit(row.names(dataLog2LFQanova)[which(dataLog2LFQanova$Org.Nuc.PvalueTukeyHSD<0.01&dataLog2LFQanova$Org.Cyt.Difference>1&dataLog2LFQanova$Org.Cyt.PvalueTukeyHSD<0.01&dataLog2LFQanova$Org.Nuc.Difference>1)], ";",fixed=T), "[", 1))
orgIDgo<-selGO(orgID,"organelle")
write.csv(orgIDgo,paste0(inpF,"orgIDgoFC",".csv"))
#impute####
dataImp<-data2Log2LFQ
hist(dataImp)
dataImp[dataImp==0]<-rnorm(1,mean=mean(dataLog2LFQ)-2,sd=0.02*sd(dataLog2LFQ))
summary(dataImp)
hist(dataImp)
#factor####
grp<-as.factor(gsub("[^[:alpha:]]", "",colnames(dataImp)))
uniProt<-sapply(strsplit(row.names(dataImp),";"), `[`, 1)
write.csv(cbind(dataImp,uniProt),paste0(inpF,"dataImpuniProt.csv"))
chkTSD<-apply(dataImp,1,function(x){TukeyHSD(aov(x~grp),"replicate", ordered = TRUE)})
chkTSD<-TukeyHSD(aov(dataNorm[100,]~class+replicate),"replicate", ordered = TRUE)
chkTSD$`replicate`
tc=apply(dataNorm,1,function(x){tryCatch(TukeyHSD(aov(x~class+replicate),"replicate", ordered = TRUE),error=function(x){return(rep(1,3))})})
wval=t(sapply(names(tc),function(x){tryCatch(tc[[x]]$`class`,error=function(x){return(rep(1,3))})}))
write.table(wval,outF,sep="\t")
tc$`B7G5L8`
dataNorm[grep("F7A",row.names(data)),]
#try(TukeyHSD(aov((x~factorC*factorS)))))
tcold$`A0A087WNP6;Q4VAA2-2;Q4VAA2;A0A087WRM0;F8WGL9;A0A087WS49`
plot(tc$`A0A087WNP6;Q4VAA2-2;Q4VAA2;A0A087WRM0;F8WGL9;A0A087WS49`)
if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
BiocManager::install("UniProt.ws", version = "3.8")
library("UniProt.ws")
prot <- UniProt.ws(taxId=556484)
protAnnoTest<-select(prot, keys=c('B7FQ84'), columns=c("KEGG","GO"),keytype="UNIPROTKB")
annoData<-data[,c(3,33:47)]
protID<-as.character(annoData$Accession)#? row.names.data.frame(data)
protID<-sapply(strsplit(protID,";"), `[`, 1)
annoData$Accession<-protID
?select
protAnnot<-select(prot, keys=protID, columns=c("KEGG","GO"),keytype="UNIPROTKB")
dim(protAnnot)
dim(data)
dim(prot)
row.names(y)<-protID
row.names(protAnnot)<-protAnnot$UNIPROTKB
annoData<-merge(annoData,protAnnot,by.x="Accession",by.y="UNIPROTKB", all=T)
annoData<-annoData[annoData$Accession!="sp",]
row.names(annoData)<-annoData$Accession
summary(annoData)
annoData$KEGG <- as.factor(annoData$KEGG)
annoData$GO <- as.factor(annoData$GO)
annoData0<-annoData
annoData0[is.na(annoData0)]=0
annoData0<-t(annoData0)
apply(annoData0[,3],2,function(x){anova(lm(as.numeric(log2(x)~GO)))})
#summary(anova(lm(as.numeric(dataNorm[2,])~factorC*factorS)))
summary(aov(as.numeric(log2(annoData[,2]))~GO,data=annoData))
TukeyHSD(aov(as.numeric(log2(annoData[,2]))~GO,data=annoData))
write.csv(annoData,file.path(pathD,"annoData.csv"))
tc=apply(dataNorm,1,function(x){tryCatch(TukeyHSD(aov(x~factorC*factorS),"factorC:factorS", ordered = TRUE),error=function(x){return(rep(1,15))})})
wval=t(sapply(names(tc),function(x){tryCatch(tc[[x]]$`factorC:factorS`[46:60],error=function(x){return(rep(1,15))})}))
write.table(wval,outF,sep="\t")
tc$`F7A0B0;P04370-9;F6ZIA4;P04370-7`
dataNorm[grep("F7A",row.names(data)),]
#try(TukeyHSD(aov((x~factorC*factorS)))))
tcold$`A0A087WNP6;Q4VAA2-2;Q4VAA2;A0A087WRM0;F8WGL9;A0A087WS49`
plot(tc$`A0A087WNP6;Q4VAA2-2;Q4VAA2;A0A087WRM0;F8WGL9;A0A087WS49`)
#dataTIMStof####
inpF2<-"L:/promec/TIMSTOF/LARS/2021/Oktober/210101Fractions/txt/proteinGroups.txt"
data2<-read.table(inpF2,header=T,sep="\t",row.names=1)
summary(data2)
colnames(data2)
data2Log2LFQ<-log2(as.matrix(data2[51:56]))
row.names(data2Log2LFQ)<-row.names.data.frame(data2)
data2Log2LFQ[is.na(data2Log2LFQ)]<-0
data2Log2LFQ[is.infinite(data2Log2LFQ)]<-0
summary(data2Log2LFQ)
colnames(data2Log2LFQ)=sub("LFQ.intensity.","",colnames(data2Log2LFQ))
summary(data2Log2LFQ)
hist(data2Log2LFQ)
data2Log2LFQanova<-posthocANOVA(data2Log2LFQ)
write.csv(data2Log2LFQanova,paste0(inpF,"data2Log2LFQanova",".csv"))
cyt2ID<-paste(sapply(strsplit(row.names(data2Log2LFQanova)[which(data2Log2LFQanova$kje.cyt.PvalueTukeyHSD<0.01&data2Log2LFQanova$mem.cyt.PvalueTukeyHSD<0.01&data2Log2LFQanova$kje.cyt.Difference<(-1)&data2Log2LFQanova$mem.cyt.Difference<(-1))], ";",fixed=T), "[", 1))
cyt2IDgo<-selGO(cyt2ID,"cytosol")
write.csv(cyt2IDgo,paste0(inpF,"cyt2IDgoFC",".csv"))
nuc2ID<-paste(sapply(strsplit(row.names(data2Log2LFQanova)[which(data2Log2LFQanova$kje.cyt.PvalueTukeyHSD<0.01&data2Log2LFQanova$kje.cyt.Difference>1&data2Log2LFQanova$mem.kje.PvalueTukeyHSD<0.01&data2Log2LFQanova$mem.kje.Difference<(-1))], ";",fixed=T), "[", 1))
nuc2IDgo<-selGO(nuc2ID,"nuclear")
write.csv(nuc2IDgo,paste0(inpF,"nuc2IDgoFC",".csv"))
org2ID<-paste(sapply(strsplit(row.names(data2Log2LFQanova)[which(data2Log2LFQanova$mem.kje.PvalueTukeyHSD<0.01&data2Log2LFQanova$mem.cyt.PvalueTukeyHSD<0.01&data2Log2LFQanova$mem.kje.Difference>1&data2Log2LFQanova$mem.cyt.Difference>1)], ";",fixed=T), "[", 1))
org2IDgo<-selGO(org2ID,"organelle")
write.csv(org2IDgo,paste0(inpF,"org2IDgoFC",".csv"))
#TukeyHSD####
#mainMatrix<-data2Log2LFQ
posthocANOVA <- function(mainMatrix) {
  samples<-gsub("[^[:alpha:]]", "",colnames(mainMatrix))
  samples<-substr(samples, 1, 3)
  samples<-t(as.factor(samples))
  options(nwarnings = 1000000)
  resANOVA=apply(mainMatrix, 1,function(x){
    aovt=aov(as.double(x)~as.character(samples))
    pval=summary(aovt)[[1]][["Pr(>F)"]][[1]]
    postHoc<-TukeyHSD(aovt)
    names(postHoc)<-"compare"
    postHoc<-data.frame(postHoc$compare)
    padj<-postHoc["p.adj"]
    diff<-postHoc["diff"]
    paste(pval,padj,diff,paste(rownames(postHoc),collapse="--GROUPS--"),sep="--VALS--")
  })
  pValANOVA<-sapply(strsplit(resANOVA, "--VALS--",fixed=T), "[", 1)
  pValANOVA<-sapply(pValANOVA,as.numeric)
  hist(pValANOVA)
  groupsANOVA<-sapply(strsplit(resANOVA, "--VALS--",fixed=T), "[", 4)
  groupsANOVA<-strsplit(groupsANOVA, "--GROUPS--",fixed=T)
  if(unique(unique(groupsANOVA)[[1]]==unique(groupsANOVA[[1]]))){
    padjv=sapply(strsplit(resANOVA, "--VALS--",fixed=T), "[", 2)
    padjv=data.frame(padjv)
    #eval(padjv)
    padjv=data.frame(do.call("rbind", strsplit(as.character(padjv$padjv), "c|\\(|\\)|\\,")))
    padjv=padjv[,3:ncol(padjv)]
    padjv=sapply(padjv, as.numeric)
    #hist(padjv)
    mlog10padjv=-log10(padjv)
    #hist(mlog10padjv)
    colnames(padjv)<-paste(groupsANOVA[[1]],"PvalueTukeyHSD",sep="-")
    colnames(mlog10padjv)<-paste(groupsANOVA[[1]],"mLog10PvalueTukeyHSD",sep="-")
    diffv=sapply(strsplit(resANOVA, "--VALS--",fixed=T), "[", 3)
    diffv=data.frame(diffv)
    diffv=data.frame(do.call("rbind", strsplit(as.character(diffv$diffv), "c|\\(|\\)|\\,")))
    diffv=diffv[,3:ncol(diffv)]
    diffv=sapply(diffv, as.numeric)
    colnames(diffv)<-paste(groupsANOVA[[1]],"Difference",sep="-")
  }
  #log10(.Machine$double.xmin)
  pValNAminusdif10 = -log10(pValANOVA+.Machine$double.xmin)
  hist(pValNAminusdif10)
  pValBHna = p.adjust(pValANOVA,method = "BH")
  hist(pValBHna)
  pValBHnaMinusdif10 = -log10(pValBHna+.Machine$double.xmin)
  hist(pValBHnaMinusdif10)
  logFCmedianGrp = apply(
    mainMatrix, 1, function(x)
      median(x[c(1:ncol(mainMatrix))],na.rm=T)    )
  hist(logFCmedianGrp)
  logFCmedianGrp[is.nan(logFCmedianGrp)]=0
  logFCmedian = logFCmedianGrp#-logFCmedianGrp
  logFCmedianFC = 2^(logFCmedian+.Machine$double.xmin)
  hist(logFCmedianFC)
  log2FCmedianFC=log2(logFCmedianFC)
  hist(log2FCmedianFC)
  #data2Log2LFQanova=data.frame(mainMatrix,medianVal=logFCmedian,MinusLog10PValue=pValNAminusdif10,medianFold=logFCmedianFC,CorrectedPValueBH=pValBHna,ANOVApVal=pValANOVA,diffv,padjv,mlog10padjv)
  return(data.frame(mainMatrix,medianVal=logFCmedian,MinusLog10PValue=pValNAminusdif10,medianFold=logFCmedianFC,CorrectedPValueBH=pValBHna,ANOVApVal=pValANOVA,diffv,padjv,mlog10padjv))
}
#write####
cWM12<-comb[comb$hdaM1>0&comb$hdaM2>0&comb$W>0,]
rN<-rownames(cWM12)
uniProt<-paste(sapply(strsplit(paste(sapply(strsplit(rN, "|",fixed=T), "[", 2)), "-"), "[", 1))
geneName<-paste(sapply(strsplit(paste(sapply(strsplit(paste(sapply(strsplit(rN, "GN=",fixed=T), "[", 2)), " "), "[", 1)), ";",fixed=T), "[", 1))
writexl::write_xlsx(cbind(rN,cWM12,uniProt,geneName),paste0(inpF,"cWM12.xlsx"))
cWM12UP<-cWM12[cWM12$hdaM1-cWM12$W>0&cWM12$hdaM2-cWM12$W>0&cWM12$W>0,]
rN<-rownames(cWM12UP)
uniProt<-paste(sapply(strsplit(paste(sapply(strsplit(rN, "|",fixed=T), "[", 2)), "-"), "[", 1))
geneName<-paste(sapply(strsplit(paste(sapply(strsplit(paste(sapply(strsplit(rN, "GN=",fixed=T), "[", 2)), " "), "[", 1)), ";",fixed=T), "[", 1))
cWM12UPM1<-cWM12UP$hdaM1-cWM12UP$W
cWM12UPM2<-cWM12UP$hdaM2-cWM12UP$W
cWM12UPmean<-(cWM12UPM1+cWM12UPM2)/2
df<-cbind(rN,cWM12UP,cWM12UPM1,cWM12UPM2,cWM12UPmean,uniProt,geneName)
df<-df[order(df$cWM12UPmean,decreasing = T),]
writexl::write_xlsx(df,paste0(inpF,"cWM12UP.xlsx"))
cWM12down<-cWM12[cWM12$hdaM1-cWM12$W<0&cWM12$hdaM2-cWM12$W<0&cWM12$W>0,]
rN<-rownames(cWM12down)
uniProt<-paste(sapply(strsplit(paste(sapply(strsplit(rN, "|",fixed=T), "[", 2)), "-"), "[", 1))
geneName<-paste(sapply(strsplit(paste(sapply(strsplit(paste(sapply(strsplit(rN, "GN=",fixed=T), "[", 2)), " "), "[", 1)), ";",fixed=T), "[", 1))
cWM12downM1<-cWM12down$hdaM1-cWM12down$W
cWM12downM2<-cWM12down$hdaM2-cWM12down$W
cWM12downmean<-(cWM12downM1+cWM12downM2)/2
df<-cbind(rN,cWM12down,cWM12downM1,cWM12downM2,cWM12downmean,uniProt,geneName)
df<-df[order(df$cWM12downmean,decreasing = F),]
writexl::write_xlsx(df,paste0(inpF,"cWM12down.xlsx"))
xWM1<-comb[comb$hdaM1>0&comb$hdaM2==0&comb$W>0,]
xWM1down<-xWM1[xWM1$hdaM1-xWM1$W<0,]
xWM1up<-xWM1[xWM1$hdaM1-xWM1$W>0,]
xWM2<-comb[comb$hdaM2>0&comb$hdaM1==0&comb$W>0,]
xWM2down<-xWM2[xWM2$hdaM2-xWM2$W<0,]
xWM2up<-xWM2[xWM2$hdaM2-xWM2$W>0,]
xW<-comb[comb$hdaM1==0&comb$hdaM2==0&comb$W>0,]
writexl::write_xlsx(cbind(rownames(xW),xW),paste0(inpF,"W42.xlsx"))
xM<-comb[comb$hdaM1>0&comb$hdaM2>0&comb$W==0,]
writexl::write_xlsx(cbind(rownames(xM),xM),paste0(inpF,"M242.xlsx"))
#mito####
download.file(url="ftp://ftp.broadinstitute.org/distribution/metabolic/papers/Pagliarini/MitoCarta3.0/Human.MitoCarta3.0.xls",destfile = paste0(inpF,"mito.xlsx"))
mito<-readxl::read_xlsx(paste0(inpF,"mito.xlsx"))
#GO####
#install.packages("UniprotR")
selGO <- function(uniProt,term) {
  #uniProt<-orgID
  #term<-"cytosol"
  GeneOntologyObj <- UniprotR::GetProteinGOInfo(uniProt)
  GeneOntologyObj$ID <- rownames(GeneOntologyObj)
  write.csv(GeneOntologyObj,paste0(inpF,term,"GeneOntologyObj.csv"))
  length(grep(term,GeneOntologyObj$Gene.ontology..cellular.component.,ignore.case=T))
  GeneOntologyObj$term <- apply(GeneOntologyObj, 1, function(x)as.integer(any(grep(term,x,ignore.case=T))))
  sum(GeneOntologyObj$term)
  return(GeneOntologyObj)
}
#enrichR####
#https://github.com/hawn-lab/workshops_UW_Seattle/tree/master/2021.07.14_GSEA
install.packages("msigdbr")
install.packages("fgsea")
install.packages("BiocManager")
BiocManager::install("clusterProfiler")
H<-msigdbr(species = "Homo sapiens", category = "H")
signif.entrez <- unique(signif$entrezgene_id)
H.entrez <- select(H, gs_name, entrez_gene)
enrich.H <- enricher(gene = signif.entrez, TERM2GENE = H.entrez)
enrich.H.df <- enrich.H@result %>%
  #separate ratios into 2 columns of data
  separate(BgRatio, into=c("size.term","size.category"), sep="/") %>%
  separate(GeneRatio, into=c("size.overlap.term", "size.overlap.category"),
           sep="/") %>%
  #convert to numeric
  mutate_at(vars("size.term","size.category",
                 "size.overlap.term","size.overlap.category"),
            as.numeric) %>%
  #Calculate k/K
  mutate("k.K"=size.overlap.term/size.term)
#GSEA####
H.ensembl.ls <- H %>%
  select(gs_name, ensembl_gene) %>%
  group_by(gs_name) %>%
  summarise(all.genes = list(unique(ensembl_gene))) %>%
  deframe()
FC.vec <- FC$mean.delta
names(FC.vec) <- FC$ensembl_gene_id
gsea.H <- fgseaSimple(pathways = H.ensembl.ls,
                      stats = FC.vec,
                      scoreType = scoreType,
                      nperm=1000)
#combine####
nucGOcomb<-merge(nucIDgo,nuc2IDgo,by="ID",all = T)
write.csv(nucGOcomb,paste0(inpF,"nucGOcomb",".csv"))
cytGOcomb<-merge(cytIDgo,cyt2IDgo,by="ID",all = T)
write.csv(cytGOcomb,paste0(inpF,"cytGOcomb",".csv"))
orgGOcomb<-merge(orgIDgo,org2IDgo,by="ID",all = T)
write.csv(orgGOcomb,paste0(inpF,"orgGOcomb",".csv"))
#count
nucGOcomb[is.na(nucGOcomb)]<-(-1)
limma::vennDiagram(nucGOcomb[,c("term.x","term.y")]>0)
cytGOcomb[is.na(cytGOcomb)]<-(-1)
limma::vennDiagram(cytGOcomb[,c("term.x","term.y")]>0)
orgGOcomb[is.na(orgGOcomb)]<-(-1)
limma::vennDiagram(orgGOcomb[,c("term.x","term.y")]>0)
#https://www.cell.com/the-innovation/fulltext/S2666-6758(21)00066-7?_returnURL=https://linkinghub.elsevier.com/retrieve/pii/S2666675821000667%3Fshowall%3Dtrue
library(clusterProfiler)
data(geneList, package="DOSE")
## fold change > 2 as DE genes
de <- names(geneList)[abs(geneList) > 2]
ego <- enrichGO(de, OrgDb = "org.Hs.eg.db", ont="BP", readable=TRUE)
## use simplify to remove redundant terms
ego2 <- simplify(ego, cutoff=0.7, by="p.adjust", select_fun=min)
kk <- gseKEGG(geneList, organism = "hsa")
gmt <- ‘wikipathways-20210310-gmt-Homo_sapiens.gmt’
wp <- read.gmt.wp(gmt)
ewp <- GSEA(geneList, TERM2GENE=wp[,c("wpid", "gene")], TERM2NAME=wp[,c("wpid", "name")])
library(ChIPseeker)
## the file can be downloaded using ‘downloadGSMbedFiles("GSM1295076")’
file <- "GSM1295076_CBX6_BF_ChipSeq_mergedReps_peaks.bed.gz"
gr <- readPeakFile(file)
library(TxDb.Hsapiens.UCSC.hg19.knownGene)
TxDb <- TxDb.Hsapiens.UCSC.hg19.knownGene
genes <- seq2gene(gr, tssRegion=c(-1000, 1000), flankDistance = 3000, TxDb)
library(clusterProfiler)
g <- bitr(genes, ‘ENTREZID’, ‘SYMBOL’, ‘org.Hs.eg.db’)
## downloaded from
https://maayanlab.cloud/Enrichr/geneSetLibrary?mode=text&libraryName=ENCODE_and_ChEA_Consensus_TFs_from_ChIP-X
encode <- read.gmt("ENCODE_and_ChEA_Consensus_TFs_from_ChIP-X.txt")
enricher(g$SYMBOL, TERM2GENE=encode)
data(DE_GSE8057)
xx <- compareCluster(Gene∼time+treatment, data=DE_GSE8057, fun = enricher,
                     TERM2GENE=wp[,c("wpid", "gene")], TERM2NAME=wp[,c("wpid", "name")])
## head or tail to print first or last n rows
head(ego, 2)
## ID Description GeneRatio BgRatio pvalue
## GO:0140014 GO:0140014 mitotic nuclear division 34/194 286/18866 2.171838e-26
## GO:0000280 GO:0000280 nuclear division 36/194 428/18866 1.099719e-22
## p.adjust qvalue
## GO:0140014 6.700119e-23 5.710790e-23
## GO:0000280 1.696316e-19 1.445841e-19
## geneID
## GO:0140014 CDCA8/CDC20/KIF23/CENPE/MYBL2/CCNB2/NDC80/NCAPH/DLGAP5/UBE2C/NUSAP1/TPX2/TACC3/NEK2/UBE2S/CDK1/MAD2L1/KIF18A/CDT1/BIRC5/KIF11/TTK/NCAPG/AURKB/CHEK1/TRIP13/PRC1/KIFC1/KIF18B/AURKA/CCNB1/KIF4A/PTTG1/BMP4
## GO:0000280 CDCA8/CDC20/KIF23/CENPE/MYBL2/CCNB2/NDC80/TOP2A/NCAPH/ASPM/DLGAP5/UBE2C/NUSAP1/TPX2/TACC3/NEK2/UBE2S/CDK1/MAD2L1/KIF18A/CDT1/BIRC5/KIF11/TTK/NCAPG/AURKB/CHEK1/TRIP13/PRC1/KIFC1/KIF18B/AURKA/CCNB1/KIF4A/PTTG1/BMP4
## Count
## GO:0140014 34
## GO:0000280 36
## subset result using ‘[’ and ‘$’
ego[1:2, c("ID", "Description", "pvalue", "p.adjust")]
## ID Description pvalue p.adjust
## GO:0140014 GO:0140014 mitotic nuclear division 2.171838e-26 6.700119e-23
## GO:0000280 GO:0000280 nuclear division 1.099719e-22 1.696316e-19
head(ego$Description)
## [1] "mitotic nuclear division"
## [2] "nuclear division"
## [3] "organelle fission"
## [4] "mitotic sister chromatid segregation"
## [5] "sister chromatid segregation"
## [6] "chromosome segregation"
## genes annotated by specific term
ego[["GO:0140014"]]
## [1] "CDCA8" "CDC20" "KIF23" "CENPE" "MYBL2" "CCNB2" "NDC80" "NCAPH"
## [9] "DLGAP5" "UBE2C" "NUSAP1" "TPX2" "TACC3" "NEK2" "UBE2S" "CDK1"
## [17] "MAD2L1" "KIF18A" "CDT1" "BIRC5" "KIF11" "TTK" "NCAPG" "AURKB"
## [25] "CHEK1" "TRIP13" "PRC1" "KIFC1" "KIF18B" "AURKA" "CCNB1" "KIF4A"
## [33] "PTTG1" "BMP4"
dim(ego)
## [1] 197 9
ego2 <- filter(ego, p.adjust < 0.001, Count > 10)
dim(ego2)
## [1] 44 9
ego3 <- mutate(ego, richFactor = Count / as.numeric(sub("/\\d+", "", BgRatio)))
ewp2 <- arrange(ewp, desc(abs(NES))) %>%
  group_by(sign(NES)) %>%
  slice(1:5)
library(ggplot2)
library(forcats)
ggplot(ego3, showCategory = 10,
       aes(richFactor, fct_reorder(Description, richFactor))) +
  geom_segment(aes(xend=0, yend = Description)) +
  geom_point(aes(color=p.adjust, size = Count)) +
  scale_color_gradientn(colours=c("#f7ca64", "#46bac2", "#7e62a3"),
                        trans = "log10",
                        guide=guide_colorbar(reverse=TRUE, order=1)) +
  scale_size_continuous(range=c(2, 10)) +
  theme_dose(12) +
  xlab("Rich Factor") +
  lab(NULL) +
  ggtitle("Biological Processes")
ggplot(ewp2, showCategory=10,
       aes(NES, fct_reorder(Description, NES), fill=qvalues)) +
  geom_col() +
  scale_fill_gradientn(colours=c("#b3eebe", "#46bac2", "#371ea3"),
                       guide=guide_colorbar(reverse=TRUE)) +
  theme_dose(12) +
  xlab("Normalized Enrichment Score") +
  ylab(NULL) +
  ggtitle("WikiPathways")
#compare https://github.com/animesh/enrichment4GTEx_clusterProfiler
