pdf("align_result.pdf")

fugu_align=read.table('fugu_align',header=T,sep='\t')
summary(fugu_align)
hist(fugu_align$AlignLength,breaks=100)
plot(fugu_align$SubjAccno)

medaka_align=read.table('medaka_align',header=T,sep='\t')
summary(medaka_align)
hist(medaka_align$AlignLength,breaks=100)
plot(medaka_align$SubjAccno)

sb_align=read.table('sb_align',header=T,sep='\t')
summary(sb_align)
hist(sb_align$AlignLength,breaks=100)
plot(sb_align$SubjAccno)

tetraodon_align=read.table('tetraodon_align',header=T,sep='\t')
summary(tetraodon_align)
hist(tetraodon_align$AlignLength,breaks=100)
plot(tetraodon_align$SubjAccno)

zf_align=read.table('zf_align',header=T,sep='\t')
summary(zf_align)
hist(zf_align$AlignLength,breaks=100)
plot(zf_align$SubjAccno)

q(save="no")
