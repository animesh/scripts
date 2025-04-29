fo='L:\\promec\\Animesh\\Jana\\proteinGroups.txt';#MaxQuant Output
testtype='WSRT';
data=read.table(fo,stringsAsFactors=F,header=T,quote="",comment.char="",sep="\t");
print(dim(data))
IDX=c(1,6,7);#Uniprots, Protein, Gene
sdx=150;#LFQ start column
edx=167;#end
rep=3;#jump between repeats
log2data=log2(as.matrix(data[,sdx:edx])+1);
print(dim(log2data))
log2ctr=log2data[,seq(ncol(log2data)-2,ncol(log2data))];
log2ctrReps=do.call(cbind, replicate(ncol(log2data)/rep, log2ctr, simplify = FALSE))
log2compare=log2data-log2ctrReps;
idnm=data[,IDX];
id=colnames(data[,sdx:edx]);
pv=matrix(0L,nrow(data),ncol(log2data)/rep-1);
ln=matrix(0L,nrow(data),1);
hdr=matrix(0L,1,ncol(log2data)/rep-1)
for(j in 1:ncol(pv)){
    hdr[j]=paste0('pValue_',j,id[j*rep],testtype);
    print(hdr[j]);
    for(i in 1:nrow(log2data)){
        tmparr=log2compare[i,seq(j*rep-2,j*rep)];
        tmparr[tmparr==0]=NA;
        ln[i]=i;
        if(sum(!is.na(tmparr))>0){pv[i,j]=wilcox.test(tmparr)$p.value;}
        else{pv[i,j]=NA;}
    }
}
colnames(pv)<-hdr;
print(summary(pv))
fw=paste0(fo,testtype,"log2.csv")
write.csv(as.data.frame(cbind(idnm,pv,log2compare,log2data)),row.names=FALSE,fw)
print(summary(warnings()))
print(fw)

