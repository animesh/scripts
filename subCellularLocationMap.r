pathD<-"L:/promec/USERS/MarianneNymark/181009/PDv2p3/181009_newprep_Charlotte_Alb3b-14_II"
inpF<-file.path(pathD,"181009_newprep_Charlotte_Alb3b-14_II-(1)_Proteins.txt")
data<-read.table(inpF,header=T,sep="\t",row.names = 3)
summary(data)

inpL<-"L:/promec/USERS/MarianneNymark/181009/PDv2p3/181009_newprep_Charlotte_Alb3b-14_II/Groups.txt"
label<-read.table(inpL,header=T,sep="\t")
colnames(label)
summary(label)

y<-log2(as.matrix(data[32:46]))
summary(y)
hist(y)
row.names(y)<-row.names.data.frame(data)
y[is.na(y)]<-0
colnames(y)=sub("Abundances.Normalized.F","",colnames(y))
colnames(y)=sub(".Sample","",colnames(y))
summary(y)


replicate<-as.factor(label$Replicate)
class<-as.factor(label$Group)

dataNorm<-y
set.seed(1)
dataNorm[dataNorm==0]<-rnorm(1,mean=mean(y),sd=sd(y))
summary(dataNorm)

chkANOVA<-apply(dataNorm,1,function(x){TukeyHSD(aov(x~class),"class", ordered = TRUE)})
chkANOVAnames<-t(sapply(row.names(dataNorm),function(x){chkANOVA[[x]]$`class`[10:12]}))
chkANOVAnames<-apply(chkANOVAnames,2,function(x){p.adjust(chkANOVAnames[,1],"BH")})
colnames(chkANOVAnames)<-c("Alb3b-14-WT", "Alb3b-16-WT", "Alb3b-16-Alb3b-14")
Uniprot<-sapply(strsplit(row.names(chkANOVAnames),";"), `[`, 1)
write.csv(cbind(chkANOVAnames,Uniprot),file.path(pathD,"chkANOVAnames.csv"))


chkTSD<-apply(dataNorm,1,function(x){TukeyHSD(aov(x~class+replicate),"replicate", ordered = TRUE)})

chkTSD<-TukeyHSD(aov(dataNorm[100,]~class+replicate),"replicate", ordered = TRUE)
chkTSD$`replicate`
?TukeyHSD
row.names(dataNorm)<-data$Accession
tc=apply(dataNorm,1,function(x){tryCatch(TukeyHSD(aov(x~class+replicate),"replicate", ordered = TRUE),error=function(x){return(rep(1,3))})})
wval=t(sapply(names(tc),function(x){tryCatch(tc[[x]]$`class`,error=function(x){return(rep(1,3))})}))
write.table(wval,outF,sep="\t")
tc$`B7G5L8`
dataNorm[grep("F7A",row.names(data)),]
#try(TukeyHSD(aov((x~factorC*factorS)))))
tcold$`A0A087WNP6;Q4VAA2-2;Q4VAA2;A0A087WRM0;F8WGL9;A0A087WS49`
plot(tc$`A0A087WNP6;Q4VAA2-2;Q4VAA2;A0A087WRM0;F8WGL9;A0A087WS49`)


y<-log2(as.matrix(data[33:47]))
summary(y)
hist(y)
row.names(y)<-row.names.data.frame(data)
y[is.na(y)]<-0
colnames(y)=sub("Abundances.Normalized.F","",colnames(y))
colnames(y)=sub(".Sample","",colnames(y))
summary(y)
plot(y[,1])
plot(y)

inpL<-"L:/promec/USERS/MarianneNymark/181009/PDv2p3/181009_newprep_Charlotte_Alb3b-14_II/Groups.txt"
label<-read.table(inpL,header=T,sep="\t")
colnames(label)
summary(label)

colnames(y)
yy<-rbind(y,t(label))
yy<-t(yy)
write.csv(yy,file.path(pathD,"yy.csv"))


if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")
BiocManager::install("UniProt.ws", version = "3.8")
library("UniProt.ws")
prot <- UniProt.ws(taxId=556484)

protAnnoTest<-select(prot, keys=c('B7FQ84'), columns=c("KEGG","GO"),keytype="UNIPROTKB")
annoData<-data[,c(3,33:47)]
protID<-as.character(annoData$Accession)#¤ row.names.data.frame(data)
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


if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")
BiocManager::install("pRoloc", version = "3.8")
library(pRoloc)
