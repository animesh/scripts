#C:\Users\animeshs\R-4.2.3\bin\Rscript.exe proteinGroupsPASER.r  C:\Users\animeshs\230504_hela_test\PASER\old\census_labelfree_out_20461_stat.txt C:\Users\animeshs\230504_hela_test\PASER\old\proteinGroups.txt
#set PATH=%PATH%;C:\ProgramData\Bruker\Miniconda3\envs\timsEngine\Library\bin
#set PATH=%PATH%;C:\ProgramData\Bruker\Miniconda3\envs\timsEngine
#set PATH=%PATH%;C:\ProgramData\Bruker\Miniconda3\envs\timsEngine\Scripts
#for /d %j in ("D:\Data\LARS\230508_IRD\*glu*.d") do (simulator -i %j --pid 5450 --wid 21 -s dda -q)
#for /d %j in ("D:\Data\LARS\230419_evosep\2320419_plasma_pCA_?_S1*.d") do (simulator -i %j --pid 5449 --wid 19 -s dda -q)#--pid 5449 --wid 18 -s dia
#for /d %j in ("D:\Data\LARS\230508_IRD\*try*.d") do (simulator -i %j --pid 5450 --wid 20 -s dda -q)
Sys.setenv(TZ="GMT")
print("USAGE:Rscript proteinGroupsPASER.r <complete path to file>")
print("default values: NORM_INTENSITY_")
#parse argument(s)
args = commandArgs(trailingOnly=TRUE)
print(paste("supplied argument(s):", length(args)))
print(args)
#read
#inpF<-"C:/Users/animeshs/230504_hela_test/PASER/old/census_labelfree_out_20461_stat.txt"
if(length(args)==0){print(paste("No proteinGroups file supplied"))} else if (length(args)>0){
  inpF<-args[1]
  inpF2<-args[2]
}
print(paste("Using proteinGroups file",inpF,"with dimension(s)"))
options(nwarnings = 1000000)
headers = read.csv(inpF,header = F, comment.char = "P",as.is = T)
#df = read.csv(inpF, skip = nrow(headers), header = T)
#colnames(df)= headers
data <- read.csv(inpF,sep="\t",skip = nrow(headers), header = T)#comment.char = 'H')#,skip = 1
colnames(data)
#summary(data)#$NORM_Q.VALUE)
data<-data[!is.na(data$NORM_Q.VALUE),]
dim(data)
print("Removed NA(s)")
#data = as.data.frame(data[!grepl("contaminant",data$ACCESSION),])
#dim(data)
#print("Removed Potential.contaminant(s)")
protNum<-1:nrow(data)
row.names(data)<-paste(protNum,data$ACCESSION,protNum,sep=";")
print("Converted Accession to rownames")
#select
log2normInt=log2(data[,c(44:47)])
log2normInt[log2normInt==-Inf]=NA
plot(log2normInt)
print(cor(log2normInt,use = "pairwise.complete.obs"))
log2normInt[is.na(log2normInt)]=0
plot(log2normInt[,1]-data[,c(48)])
par(mar=c(12,3,1,1))
boxplot(log2normInt,las=2,main="log2normIntensity")
selection<-"NORM_INTENSITY_"
LFQ<-(data[,grep(selection,colnames(data))])
LFQ<-sapply(LFQ, as.numeric)
summary(LFQ)
colnames(LFQ)=sub(selection,"",colnames(LFQ))
#colnames(LFQ)=sub("Sample","",colnames(LFQ))
colnames(LFQ)=sub(":","",colnames(LFQ))
colnames(LFQ)=sub("\\(","",colnames(LFQ))
colnames(LFQ)=sub("\\)","",colnames(LFQ))
dim(LFQ)
summary(warnings())
#read MQ
#inpF2<-"C:/Users/animeshs/230504_hela_test/PASER/old/proteinGroups.txt"
data2 <- read.table(inpF2,stringsAsFactors = FALSE, header = TRUE, quote = "", comment.char = "", sep = "\t")
#compare IDs
ID2 <- strsplit(data2$Protein.IDs, split = ";")
ID2=data.frame(ID2 = rep(data2$Protein.IDs, sapply(ID2, length)), ID2s = unlist(ID2))
ID <- strsplit(data$ACCESSION, split = ";")
ID=data.frame(ID = rep(data$ACCESSION, sapply(ID, length)), IDs = unlist(ID))
IDu=data.frame(IDu=union(ID$IDs,ID2$ID2s))
print(IDu)
IDd1=data.frame(IDd1=setdiff(ID$IDs,ID2$ID2s))
print(IDd1)
IDd2=data.frame(IDd2=setdiff(ID2$ID2s,ID$IDs))
print(IDd2)
IDc=data.frame(IDc=intersect(ID$IDs,ID2$ID2s))
print(IDc)
#data combine
pgIDs <- strsplit(data$ACCESSION, ";")
dataLFQs <- data.frame(
  uniprots = unlist(pgIDs),
  p1 = rep(data$NORM_INTENSITY_1, lengths(pgIDs)),
  p2 = rep(data$NORM_INTENSITY_2, lengths(pgIDs)),
  p3 = rep(data$NORM_INTENSITY_3, lengths(pgIDs)),
  p4 = rep(data$NORM_INTENSITY_4, lengths(pgIDs)))
pgIDs <- strsplit(data2$Protein.IDs, ";")
data2LFQs <- data.frame(
  uniprots = unlist(pgIDs),
  s1 = rep(data2$LFQ.intensity.24_plasma_pCA_1_S1.B1_1_4355, lengths(pgIDs)),
  s2 = rep(data2$LFQ.intensity.24_plasma_pCA_2_S1.B2_1_4356, lengths(pgIDs)),
  s3 = rep(data2$LFQ.intensity.24_plasma_pCA_3_S1.B3_1_4357, lengths(pgIDs)),
  s4 = rep(data2$LFQ.intensity.24_plasma_pCA_4_S1.B4_1_4358, lengths(pgIDs)))
dataIDc<-merge(IDc,dataLFQs,by.x="IDc",by.y="uniprots")
dataIDc<-merge(dataIDc,data2LFQs,by.x="IDc",by.y="uniprots")
dataIDcLog2<-log2(dataIDc[,-1])
dataIDcLog2[dataIDcLog2==-Inf]=NA
print(cor(dataIDcLog2,use = "pairwise.complete.obs")*cor(dataIDcLog2,use = "pairwise.complete.obs"))
plot(dataIDcLog2)
write.csv(cbind(uniprots=dataIDc$IDc,dataIDcLog2),file="combined.csv")
