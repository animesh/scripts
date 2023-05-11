#C:\Users\animeshs\R-4.2.3\bin\Rscript.exe proteinGroupsPASER.r  C:\Users\animeshs\230504_hela_test\PASER\old\census_labelfree_out_20461_stat.txt
Sys.setenv(TZ="GMT")
print("USAGE:Rscript proteinGroupsPASER.r <complete path to file>")
print("default values: NORM_INTENSITY_")
#parse argument(s)
args = commandArgs(trailingOnly=TRUE)
print(paste("supplied argument(s):", length(args)))
print(args[1])
#read
#inpF<-"C:/Users/animeshs/230504_hela_test/PASER/old/census_labelfree_out_20461_stat.txt"
if(length(args)==0){print(paste("No proteinGroups file supplied"))} else if (length(args)>0){inpF<-args[1]}
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
