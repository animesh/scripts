#https://daehwankimlab.github.io/hisat2/main/
mkdir $HOME/AAG
cd $HOME/AAG
wget https://cloud.biohpc.swmed.edu/index.php/s/hisat2-220-Linux_x86_64/download
wget https://cloud.biohpc.swmed.edu/index.php/s/grch38_tran/download
tar xvzf download
export PATH=$PATH:$PWD/hisat2-2.1.0
hisat2 -p 12 -U 20151016.A-AAG_1_R1.fastq.gz,20151016.A-AAG_2_R1.fastq.gz,20151016.A-AAG_3_R1.fastq.gz --dta -x grch38_tran/genome_tran -S AAG.sam 2>summary.AAG.txt
cat summary.AAG.txt
#69508633 reads; of these:
#  69508633 (100.00%) were unpaired; of these:
#    8610041 (12.39%) aligned 0 times
#    51807251 (74.53%) aligned exactly 1 time
#    9091341 (13.08%) aligned >1 times
#87.61% overall alignment rate
hisat2 -p 12 -U 20151016.A-WTCas9_1_R1.fastq.gz,20151016.A-WTCas9_2_R1.fastq.gz,20151016.A-WTCas9_3_R1.fastq.gz --dta -x grch38_tran/genome_tran -S WTCas9.sam 2>summary.WTCas9.txt
cat summary.WTCas9.txt
#68662826 reads; of these:
#  68662826 (100.00%) were unpaired; of these:
#    8486789 (12.36%) aligned 0 times
#    51238820 (74.62%) aligned exactly 1 time
#    8937217 (13.02%) aligned >1 times
87.64% overall alignment rate
#for i in *.fa ; do echo $i; k=$(basename $i); echo  $k ; bwa mem -M -t 12 ../*.fasta $i > $k.sam ; samtools view -bS $k.sam | samtools sort -o $k.bam ; samtools index $k.bam ; done
samtools view -bS AAG.sam > AAG.bam
samtools view AAG.bam | less -S
samtools sort AAG.bam -o AAG_sorted.bam
samtools view AAG_sorted.bam | less -S
samtools view -bS WTCas9.sam > WTCas9.bam
samtools sort WTCas9.bam -o WTCas9_sorted.bam
#http://bioinf.wehi.edu.au/subread/
#https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3664803/
wget https://netcologne.dl.sourceforge.net/project/subread/subread-2.0.0/subread-2.0.0-Linux-x86_64.tar.gz
featureCounts -T 1 -t exon -g gene_id -O -a Homo_sapiens.GRCh38.84.gtf -b -o count-1smp.txt AAG_sorted.bam
featureCounts -T 1 -t exon -g gene_id -O -a Homo_sapiens.GRCh38.84.gtf -b -o count-1smp.txt WTCas9_sorted.bam
