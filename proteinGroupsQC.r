#install.packages(c("readxl","writexl","svglite","ggplot2"),repos="http://cran.us.r-project.org",lib=.libPaths())
#..\R-4.5.0\bin\Rscript.exe  .\proteinGroupsQC.r "L:\promec\TIMSTOF\LARS\2023\230310 Sonali\combined\txtNoDN\proteinGroups.txt" "L:\promec\TIMSTOF\LARS\2023\230310 Sonali\combined\txtNoDN\SurvivalUpdates_other parameters_new_14092023.xlsx" "Intensity." "Group" "Remove" 0.5
#..\R-4.5.0\bin\Rscript.exe  .\proteinGroupsQC.r "L:\promec\TIMSTOF\LARS\2023\230310 Sonali\combined\txtNoDN\proteinGroups.txt" "L:\promec\TIMSTOF\LARS\2023\230310 Sonali\combined\txtNoDN\SurvivalUpdates_other parameters_new_14092023.xlsx" "Intensity." "Group" "Remove" 0.5
print("USAGE:<path to>Rscript proteinGroupsQC <complete path to directory containing proteinGroups.txt> AND <SurvivalUpdates.xlsx file>  \"intensity columns to consider\" \"Group information of samples\" \"Remove samples if any\" \"missing values threshold\"")
args = commandArgs(trailingOnly=TRUE)
print(paste("supplied argument(s):", length(args)))
print(args)
if (length(args) != 6) {stop("\n\nNeeds the full path of the directory containing BOTH proteinGroups.txt AND Survival.txt files followed by \"intensity columns to consider\" \"Group information of samples\" \"Remove samples if any\" \"correlation column\"", call.=FALSE)}
#args####
inpF <- args[1]
#inpF <-"L:/promec/TIMSTOF/LARS/2023/230310 Sonali//combined/txtNoDN/proteinGroups.txt"
inpL <- args[2]
#inpL <-"L:/promec/TIMSTOF/LARS/2023/230310 Sonali//combined/txtNoDN/SurvivalUpdates_other parameters_new_14092023.xlsx"
selection<-args[3]
#selection<-"LFQ.intensity."
lGroup <- args[4]
#lGroup<-"Group"
rGroup <- args[5]
#rGroup<-"Remove"
scaleF <- args[6]
scaleF = as.numeric(scaleF)
#scaleF<-0.5
inpD<-dirname(inpF)
fName<-basename(inpF)
lName<-basename(inpL)
outP=paste(inpF,selection,lGroup,rGroup,lName,scaleF,"QC","pdf",sep = ".")
pdf(outP)
#label####
label<-readxl::read_excel(inpL)#, colClasses=c(rep("factor",3)))
label<-data.frame(label)
#cor(label$cell.number/label$cur.area,label$ratio.correction.factor)
rownames(label)=sub(selection,"",label$Name)
label["pair2test"]<-label[lGroup]
if(rGroup %in% colnames(label)){label["removed"]<-label[rGroup]} else{label["removed"]=NA}
label[is.na(label[lGroup]),"removed"]<-"R"
print(label)
table(label["removed"])
table(label[lGroup])
table(label[is.na(label["removed"]),lGroup])
rownames(label)<-sub("-",".",rownames(label))
annoFactor<-label[lGroup]
names(annoFactor)<-lGroup
anno<-data.frame(factor(label[,lGroup]))
row.names(anno)<-rownames(label)
names(anno)<-lGroup
table(anno)
annoR<-data.frame(factor(annoFactor[rownames(label[is.na(label$removed)|label$removed==" "|label$removed=='',]),]))
row.names(annoR)<-rownames(label[is.na(label$removed)|label$removed==" "|label$removed=='',])
names(annoR)<-lGroup
summary(annoR)
#data####
data <- read.table(inpF,stringsAsFactors = FALSE, header = TRUE, quote = "", comment.char = "", sep = "\t")
##clean####
data = data[!data$Reverse=="+",]
data = data[!data$Potential.contaminant=="+",]
#data = data[!data$Only.identified.by.site=="+",]
row.names(data)<-paste(row.names(data),data$Protein.IDs,data$Fasta.headers,data$Peptide.counts..all.,data$Sequence.coverage....,data$Score,sep = ";;")
data$rowName<-paste(sapply(strsplit(paste(sapply(strsplit(data$Fasta.headers, "|",fixed=T), "[", 2)), "-"), "[", 1))
data$geneName<-paste(sapply(strsplit(paste(sapply(strsplit(data$Fasta.headers, "_",fixed=T), "[", 2)), "OS="), "[", 1))
data$uniprotID<-paste(sapply(strsplit(paste(sapply(strsplit(data$Protein.IDs, ";",fixed=T), "[", 1)), "-"), "[", 1))
data[data$geneName=="NA","geneName"]=data[data$geneName=="NA","uniprotID"]
print(dim(data))
log2Int<-as.matrix(log2(data[,grep("Intensity.",colnames(data))]))
log2Int[log2Int==-Inf]=NA
colnames(log2Int)=sub("Intensity.","",colnames(log2Int))
hist(log2Int,main=paste("Mean:",mean(log2Int,na.rm=T),"SD:",sd(log2Int,na.rm=T)),breaks=round(max(log2Int,na.rm=T)),xlim=range(min(log2Int,na.rm=T),max(log2Int,na.rm=T)))
par(mar=c(12,3,1,1))
boxplot(log2Int,las=2,main="Log2Intensity")
#maxLFQ####
LFQ<-as.matrix(data[,grep(selection,colnames(data))])
#LFQ<-LFQ[,2:ncol(LFQ)]
#protNum<-1:ncol(LFQ)
#protNum<-"LFQ intensity"#1:ncol(LFQ)
#colnames(LFQ)=paste(protNum,sub(selection,"",colnames(LFQ)),sep=";")
colnames(LFQ)=sub(selection,"",colnames(LFQ))
LFQ<- LFQ[,colnames(LFQ)!="peptides"]
print(dim(LFQ))
log2LFQ<-log2(LFQ)
log2LFQ[log2LFQ==-Inf]=NA
hist(log2LFQ,main=paste("Mean:",mean(log2LFQ,na.rm=T),"SD:",sd(log2LFQ,na.rm=T)),breaks=round(max(log2Int,na.rm=T)),xlim=range(min(log2Int,na.rm=T),max(log2Int,na.rm=T)))
par(mar=c(12,3,1,1))
boxplot(log2LFQ,las=2,main=selection)
#corHClfq####
log2LFQimpCorr<-cor(log2LFQ,use="pairwise.complete.obs",method="pearson")
colnames(log2LFQimpCorr)<-colnames(log2LFQ)
rownames(log2LFQimpCorr)<-colnames(log2LFQ)
hist(log2LFQimpCorr)
heatmap(log2LFQimpCorr)
#test####
calGroups <- function(log2LFQ,sel1,sel2){
  #sel1<-"EP"
  #sel2<-scaleF
  #selection<-selection
  #hist(log2LFQ)
  #colnames(log2LFQ)
  d1<-data.frame(log2LFQ[,gsub("-",".",rownames(label[label$pair2test==sel1&!is.na(label$pair2test),]))])
  rNd1<-rownames(d1)
  d1<-sapply(d1, as.numeric)
  rownames(d1)<-rNd1
  colnames(d1)<-rownames(label[label$pair2test==sel1&!is.na(label$pair2test),])
  hist(d1,main=sel1)
  missValP<-ncol(d1)*scaleF
  print(missValP)
  if(sum(!is.na(d1))>missValP){
    comp<-paste(sel1,sel2,sep="-")
    print(comp)
    options(nwarnings = 1000000)
    resCalc=apply(d1, 1,function(x)
      if((sum(!is.na(x))>=missValP)){1}
      else if(sum(!is.na(x))==0){NA}
      else{0}
    )
    summary(warnings())
    #print(sum(is.na(resCalc)))
    #print(sum(resCalc==0,na.rm = T))
    hist(resCalc)
    dfCalc<-as.data.frame(resCalc)
    write.csv(dfCalc,paste(outP,comp,".csv",sep="."))
    return(dfCalc)
  }
}
#compare####
label=label[is.na(label$removed)|label$removed==" "|label$removed=='',]
table(label$pair2test)
print(paste("Total",selection,dim(log2LFQ)))
cnt=0
for(i in 1:length(rownames(table(label$pair2test)))){
  cnt=cnt+1
  i=rownames(table(label$pair2test))[cnt]
  rtPair=calGroups(log2LFQ,i,scaleF)
  print(paste("Total Protein groups: ",sum(rtPair,na.rm = T)+sum(rtPair==0,na.rm = T)))
  print(paste("Protein groups passing threshold",scaleF,": ",sum(rtPair,na.rm = T)))
  #assign(i,rtPair)
}

