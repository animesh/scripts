#for i in /cluster/work/users/ash022/veronica/*He*.d ; do echo $i ; timsconvert --chunk_size 5000000000 --verbose --input $i ;  done
#sage sage.json -f human_crap.fasta --batch-size 40 /cluster/work/users/ash022/*.mzML
#cp lfq.tsv $HOME/PD/TIMSTOF/LARS/2024/240605_Veronica/HeLa/
inpF <-"TIMSTOF/LARS/2024/240605_Veronica/HeLa/lfq.tsv"
data<-read.csv(inpF,header=TRUE,sep="\t")
summary(data)
#plot(data)
#hist(data$charge)
dataLFQ<-data[,grep("X",colnames(data))]
plot(dataLFQ)
log2dataLFQ<-log2(dataLFQ)
plot(log2dataLFQ)
