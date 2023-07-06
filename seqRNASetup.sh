#https://daehwankimlab.github.io/hisat2/main/
sudo apt install hisat2
mkdir $HOME/seqRNA
cd $HOME/seqRNA
wget https://cloud.biohpc.swmed.edu/index.php/s/grch38_tran/download
tar xvzf download
for i in *.fastq.gz ; do echo $i; j=$(basename $i); k=${j%%.fastq*}; echo  $k ; hisat2 -p 12 -U  $i --dta -x grch38_tran/genome_tran -S $k.sam 2>$k.hisat.summary.txt ; done
cat *hisat.summary.txt
23595066 reads; of these:
  23595066 (100.00%) were unpaired; of these:
    2516579 (10.67%) aligned 0 times
    20113653 (85.25%) aligned exactly 1 time
    964834 (4.09%) aligned >1 times
89.33% overall alignment rate
23045784 reads; of these:
  23045784 (100.00%) were unpaired; of these:
    3171893 (13.76%) aligned 0 times
    18925665 (82.12%) aligned exactly 1 time
    948226 (4.11%) aligned >1 times
86.24% overall alignment rate
22021976 reads; of these:
  22021976 (100.00%) were unpaired; of these:
    2771764 (12.59%) aligned 0 times
    18320861 (83.19%) aligned exactly 1 time
    929351 (4.22%) aligned >1 times
87.41% overall alignment rate
find . -iname "*R1.sam" | parallel -j 6 "samtools view -bS {} > {}.bam"
find . -iname "*sam.bam" | parallel -j 6 "samtools sort {} -o {}.sort.bam"
#https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3664803/
sudo apt install subread
wget https://ftp.ensembl.org/pub/release-109/gtf/homo_sapiens/Homo_sapiens.GRCh38.109.gtf.gz
gunzip Homo_sapiens.GRCh38.109.gtf.gz
featureCounts -T 6  -t exon -g gene_id -O -a Homo_sapiens.GRCh38.109.gtf -o count.thread6.txt Mut_1_R1.sam.bam.sort.bam  Mut_3_R1.sam.bam.sort.bam    WT_2_R1.sam.bam.sort.bam Mut_2_R1.sam.bam.sort.bam  WT_1_R1.sam.bam.sort.bam  WT_3_R1.sam.bam.sort.bam
//========================== featureCounts setting ===========================\\
||                                                                            ||
||             Input files : 6 BAM files                                      ||
||                                                                            ||
||                           Mut_1_R1.sam.bam.sort.bam                        ||
||                           Mut_3_R1.sam.bam.sort.bam                        ||
||                           WT_2_R1.sam.bam.sort.bam                         ||
||                           Mut_2_R1.sam.bam.sort.bam                        ||
||                           WT_1_R1.sam.bam.sort.bam                         ||
||                           WT_3_R1.sam.bam.sort.bam                         ||
||                                                                            ||
||             Output file : count.thread12.txt                               ||
||                 Summary : count.thread12.txt.summary                       ||
||              Paired-end : no                                               ||
||        Count read pairs : no                                               ||
||              Annotation : Homo_sapiens.GRCh38.109.gtf (GTF)                ||
||      Dir for temp files : ./                                               ||
||                                                                            ||
||                 Threads : 6                                                ||
||                   Level : meta-feature level                               ||
||      Multimapping reads : not counted                                      ||
|| Multi-overlapping reads : counted                                          ||
||   Min overlapping bases : 1                                                ||
||                                                                            ||
\\============================================================================//
cat count.thread6.txt.summary
Status  Mut_1_R1.sam.bam.sort.bam       Mut_3_R1.sam.bam.sort.bam       WT_2_R1.sam.bam.sort.bam        Mut_2_R1.sam.bam.sort.bam       WT_1_R1.sam.bam.sort.bam        WT_3_R1.sam.bam.sort.bam
Assigned        17450968        17718036        17692974        19297862        19054137        17107431
Unassigned_Unmapped     2593875 2698730 3171893 3290612 2516579 2771764
Unassigned_Read_Type    0       0       0       0       0       0
Unassigned_Singleton    0       0       0       0       0       0
Unassigned_MappingQuality       0       0       0       0       0       0
Unassigned_Chimera      0       0       0       0       0       0
Unassigned_FragmentLength       0       0       0       0       0       0
Unassigned_Duplicate    0       0       0       0       0       0
Unassigned_MultiMapping 3239527 3451981 3272731 3593488 3149088 3251964
Unassigned_Secondary    0       0       0       0       0       0
Unassigned_NonSplit     0       0       0       0       0       0
Unassigned_NoFeatures   1121732 1089495 1232691 1354616 1059516 1213430
Unassigned_Overlapping_Length   0       0       0       0       0       0
Unassigned_Ambiguity    0       0       0       0       0       0

python fcnts2dseq.py count.thread12.txt
Rscript --vanilla diffExprSeq.r
