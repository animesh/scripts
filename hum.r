pdf("align_hum.pdf")
hum_align=read.table('hum_align',header=T,sep='\t')
summary(hum_align)
hist(hum_align$AlignLength,breaks=100)
plot(hum_align$SubjAccno)
plot(hum_align$QueryAccno)
q(save="no")

