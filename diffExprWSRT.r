fo='L:\\promec\\TIMSTOF\\LARS\\2026\\260518_Sonali\\DIANNv2P2.63.260612_140833.64.highacc\\Outcome_data_with_PRM_median_ratios.xlsx';
testtype='WSRT';
data=readxl::read_xlsx(fo,sheet=1);
print(dim(data))
dataSel1=t(data[data$"quality"=="HQ",])
print(dim(dataSel1))
dataSel2=t(data[data$"quality"=="LQ",])
print(dim(dataSel2))
sCol<-1
mCol<-ncol(dataSel1)#ceiling((eCol-sCol+1)/2)
eCol<-ncol(dataSel1)+ncol(dataSel2)
dataSellog2grpWSRT<-merge(dataSel1, dataSel2, by = 'row.names', all = TRUE)
rN<-dataSellog2grpWSRT[,1]
dataSellog2grpWSRT<-dataSellog2grpWSRT[,-1]
dataSellog2grpWSRT<-sapply(dataSellog2grpWSRT, function(x) as.numeric(as.character(x)))
pValNA = apply(
  dataSellog2grpWSRT, 1, function(x)
  if(sum(!is.na(x[c(sCol:mCol)]))<2&sum(!is.na(x[c((mCol+1):eCol)]))<2){NA}
  else if(is.na(sd(x[c(sCol:mCol)],na.rm=T))&(sd(x[c((mCol+1):eCol)],na.rm=T)==0)){0}#Q9QX47
  else if(is.na(sd(x[c((mCol+1):eCol)],na.rm=T))&(sd(x[c(sCol:mCol)],na.rm=T)==0)){0}
  else if(sum(is.na(x[c(sCol:mCol)]))==0&sum(is.na(x[c((mCol+1):eCol)]))==0){
    wilcox.test(as.numeric(x[c(sCol:mCol)]),as.numeric(x[c((mCol+1):eCol)]),exact=F)$p.value}
  else if(sum(!is.na(x[c(sCol:mCol)]))>1&sum(!is.na(x[c((mCol+1):eCol)]))<1&abs(sd(2^x[c(sCol:mCol)],na.rm=T)/mean(2^x[c(sCol:mCol)],na.rm=T))<cvThr){0}
  else if(sum(!is.na(x[c(sCol:mCol)]))<1&sum(!is.na(x[c((mCol+1):eCol)]))>1&abs(sd(2^x[c((mCol+1):eCol)],na.rm=T)/mean(2^x[c((mCol+1):eCol)],na.rm=T))<cvThr){0}
  else if(sum(!is.na(x[c(sCol:mCol)]))>=2&sum(!is.na(x[c((mCol+1):eCol)]))>=1){
    wilcox.test(as.numeric(x[c(sCol:mCol)]),as.numeric(x[c((mCol+1):eCol)]),correct=T,exact=F)$p.value}
  else if(sum(!is.na(x[c(sCol:mCol)]))>=1&sum(!is.na(x[c((mCol+1):eCol)]))>=2){
    wilcox.test(as.numeric(x[c(sCol:mCol)]),as.numeric(x[c((mCol+1):eCol)]),correct=T,exact=F)$p.value}
  else{NA}
)
hist(pValNA,breaks=100,main=paste("Mean:",mean(pValNA,na.rm=T),"SD:",sd(pValNA,na.rm=T)),xlim=c(0,1))
pValNAdm<-data.frame(cbind(pValNA,dataSellog2grpWSRT,rN))
fw=paste0(fo,testtype,".xlsx")
writexl::write_xlsx(pValNAdm,fw)
print(summary(warnings()))
print(fw)

