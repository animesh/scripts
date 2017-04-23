> data<-read.csv('seqcomp.csv')
> cor(data$CDS,data$UTR)
[1] 0.3133213
> cor(data$CDS,data$DUTR)
[1] -0.1555705
> cor(data$UTR,data$DUTR)
[1] 0.3163645
> t.test(data$CDS,data$DUTR)
t = 4.0836, df = 42.243, p-value = 0.0001934
> t.test(data$CDS,data$UTR)
t = 3.7797, df = 40.814, p-value = 0.0005031
