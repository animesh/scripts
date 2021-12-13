#data####
#c:/Users/animeshs/R/bin/Rscript.exe diffExprTestT.r L:/promec/TIMSTOF/LARS/2021/November/SIGRID/combined/txtNoNQd/ group
inpD<-"L:/promec/TIMSTOF/LARS/2021/November/SIGRID/combined/txtNoNQd/"
inpFL<-list.files(pattern="*grouptTestBH.csv$",path=inpD,full.names=F,recursive=F)
dfID<-NA
for(inpF in inpFL){
    #inpF=inpFL[1]
    print(inpF)
    data<-read.csv(paste0(inpD,inpF))
    hist(data$Log2MedianChange,labels = inpF)
    ID<-data[data$CorrectedPValueBH<0.1&!is.na(data$CorrectedPValueBH),"RowGeneUniProtScorePeps"]
    dfID<-union(dfID,ID)
    data=as.data.frame(data[data$CorrectedPValueBH<0.1&!is.na(data$CorrectedPValueBH),"Log2MedianChange"])
    colnames(data)<-paste0(inpF)
    data$ID<-ID
    assign(inpF,data)
}
#merge####
data<-data.frame(ID=dfID)
for (obj in inpFL) {
    print(obj)
    data<-merge(data,get(obj),by="ID",all=T)
}
data=data[!is.na(data$ID),]
rownames(data)<-data$ID
data=data[,-1]
hist(data[,1])
data<-data[order(rowMeans(data),decreasing=T),]
write.csv(data,paste0(inpD,inpF,".sort.combined.csv"))
sel<-"Log2MedianChange"
sel2<-"grouptTestBH.csv"
hda<-data[,grep(sel,colnames(data))]
hda<-sapply(data,as.numeric)
colnames(hda)<-sub(sel,"",colnames(hda))
colnames(hda)<-sub(sel2,"",colnames(hda))
hist(hda)
hda[is.na(hda)]<-0
limma::vennDiagram(hda[,1:5]>0)
log2LFQimpCorr<-cor(hda,use="pairwise.complete.obs",method="spearman")
#rownames(log2LFQimpCorr)<-colnames(hda)
svgPHC<-pheatmap::pheatmap(log2LFQimpCorr,clustering_distance_rows = "euclidean",clustering_distance_cols = "euclidean",fontsize_row=8,cluster_cols=T,cluster_rows=T,fontsize_col  = 8)
dataLog2NormLOESS<-limma::normalizeCyclicLoess(data, weights = NULL, span=0.7, iterations = 3, method = "fast")
boxplot(dataLog2NormLOESS)
