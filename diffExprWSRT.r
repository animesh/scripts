fo='L:\\promec\\HF\\Lars\\2020\\AUGUST\\siri\\combined\\txt_PHOSTY\\proteinGroups.txt';#MaxQuant Output
testtype='WSRT';
data=read.table(fo,stringsAsFactors=F,header=T,quote="",comment.char="",sep="\t");
summary(data)
IDX=c(1,7,8);#Uniprots, Gene Name, Fasta header
sdx=108;#LFQ start column
edx=119;#end
rep=3;#jump between repeats
log2data=log2(as.matrix(data[,sdx:edx])+1);
summary(log2data)
log2ctr=log2data[,seq(1,ncol(log2data),by=ceiling((edx-sdx+1)/rep))];
log2ctr=matrix(rep(as.numeric(t(log2ctr)),each=ceiling((edx-sdx+1)/rep)),nrow=nrow(log2ctr),byrow=TRUE)
summary(log2ctr)
log2data=log2data-log2ctr;
log2data[log2data==0]=NaN;
hist(log2data)
summary(log2data)
idnm=data[,IDX];
id=colnames(data[,sdx:edx]);
pv=matrix(0L,nrow(data),ceiling((edx-sdx+1)/rep));
summary(pv)
ln=matrix(0L,nrow(data),1);
summary(ln)
hdr=matrix(0L,1,ncol(log2data)/rep)
summary(hdr)
for(j in 1:ncol(log2data)/rep){
    hdr[j]=paste0('Col_',j,id[j],testtype);
    print(hdr[j]);
    for(i in 1:nrow(log2data)){
      tmparr=log2data[i,seq(j,ncol(log2data),by=ncol(log2data)/rep)];
      ln[i]=i;
       if(sum(is.na(tmparr))<length(tmparr)){pv[i,j]=wilcox.test(tmparr)$p.value;}
       else{pv[i,j]=1;}
    }
}
colnames(pv)<-hdr;
hist(pv)
write.csv(as.data.frame(cbind(idnm,pv,log2data)),row.names=FALSE,paste0(fo,testtype,"log2.csv"))
