pdf("align_mhc.pdf")
mhc_align=read.table('mhc_align',header=T,sep='\t')
summary(mhc_align)
hist(mhc_align$AlignLength,breaks=1000)
plot(mhc_align$SubjAccno)
plot(mhc_align$QueryAccno)
q(save="no")

