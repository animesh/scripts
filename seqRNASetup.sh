#https://daehwankimlab.github.io/hisat2/main/
sudo apt install hisat2
mkdir $HOME/AAG
cd $HOME/AAG
wget https://cloud.biohpc.swmed.edu/index.php/s/grch38_tran/download
tar xvzf download
for i in *.fastq.gz ; do echo $i; j=$(basename $i); k=${j%%.fastq*}; echo  $k ; hisat2 -p 12 -U  $i --dta -x grch38_tran/genome_tran -S $k.sam 2>$k.hisat.summary.txt ; done
cat *hisat.summary.txt
#23595066 reads; of these:
#  23595066 (100.00%) were unpaired; of these:
#    2526499 (10.71%) aligned 0 times
#    17997552 (76.28%) aligned exactly 1 time
#    3071015 (13.02%) aligned >1 times
#89.29% overall alignment rate
#23045784 reads; of these:
#  23045784 (100.00%) were unpaired; of these:
#    3180880 (13.80%) aligned 0 times
#    16926106 (73.45%) aligned exactly 1 time
#    2938798 (12.75%) aligned >1 times
#86.20% overall alignment rate
#22021976 reads; of these:
#  22021976 (100.00%) were unpaired; of these:
#    2781176 (12.63%) aligned 0 times
#    16350956 (74.25%) aligned exactly 1 time
#    2889844 (13.12%) aligned >1 times
#87.37% overall alignment rate
find . -iname "*R1.sam" | parallel -j 6 "samtools view -bS {} > {}.bam"
find . -iname "*sam.bam" | parallel -j 6 "samtools sort {} -o {}.sort.bam"
#https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3664803/
sudo apt install subread
wget http://ftp.ensembl.org/pub/release-84/gtf/homo_sapiens/Homo_sapiens.GRCh38.84.gtf.gz
gunzip Homo_sapiens.GRCh38.84.gtf.gz
featureCounts -T 12 -b -t exon -g gene_id -O -a Homo_sapiens.GRCh38.84.gtf -o count.thread12.txt 20151016.A-AAG_1_R1.sam.bam.sort.bam  20151016.A-AAG_3_R1.sam.bam.sort.bam    20151016.A-WTCas9_2_R1.sam.bam.sort.bam 20151016.A-AAG_2_R1.sam.bam.sort.bam  20151016.A-WTCas9_1_R1.sam.bam.sort.bam  20151016.A-WTCas9_3_R1.sam.bam.sort.bam
The '-b' option has been deprecated.
 FeatureCounts will automatically examine the file format.
//========================== featureCounts setting ===========================\\
||                                                                            ||
||             Input files : 6 BAM files                                      ||
||                           S 20151016.A-AAG_1_R1.sam.bam.sort.bam           ||
||                           S 20151016.A-AAG_3_R1.sam.bam.sort.bam           ||
||                           S 20151016.A-WTCas9_2_R1.sam.bam.sort.bam        ||
||                           S 20151016.A-AAG_2_R1.sam.bam.sort.bam           ||
||                           S 20151016.A-WTCas9_1_R1.sam.bam.sort.bam        ||
||                           S 20151016.A-WTCas9_3_R1.sam.bam.sort.bam        ||
||                                                                            ||
||             Output file : count.thread12.txt                               ||
||                 Summary : count.thread12.txt.summary                       ||
||              Annotation : Homo_sapiens.GRCh38.84.gtf (GTF)                 ||
||      Dir for temp files : ./                                               ||
||                                                                            ||
||                 Threads : 12                                               ||
||                   Level : meta-feature level                               ||
||              Paired-end : no                                               ||
||         Strand specific : no                                               ||
||      Multimapping reads : not counted                                      ||
|| Multi-overlapping reads : counted                                          ||
||       Overlapping bases : 0.0%                                             ||
||                                                                            ||
\\===================== http://subread.sourceforge.net/ ======================//
cat count.thread12.txt.summary
#Status	20151016.A-AAG_1_R1.sam.bam.sort.bam	20151016.A-AAG_3_R1.sam.bam.sort.bam	20151016.A-WTCas9_2_R1.sam.bam.sort.bam	20151016.A-AAG_2_R1.sam.bam.sort.bam	20151016.A-WTCas9_1_R1.sam.bam.sort.bam	20151016.A-WTCas9_3_R1.sam.bam.sort.bam
#Assigned	17304566	17578737	17535538	19124128	18899504	16955954
#Unassigned_Ambiguity	0	0	0	0	0	0
#Unassigned_MultiMapping	3160934	3368978	3190555	3498247	3056648	3166688
#Unassigned_NoFeatures	1267366	1228095	1389556	1527824	1213892	1364461
#Unassigned_Unmapped	2602811	2708066	3180880	3301087	2526499	2781176
#Unassigned_MappingQuality	0	0	0	0	0	0
#Unassigned_FragmentLength	0	0	0	0	0	0
#Unassigned_Chimera	0	0	0	0	0	0
#Unassigned_Secondary	0	0	0	0	0	0
#Unassigned_Nonjunction	0	0	0	0	0	0
#Unassigned_Duplicate	0	0	0	0	0	0
python fcnts2dseq.py count.thread12.txt
Rscript --vanilla diffExprSeq.r
