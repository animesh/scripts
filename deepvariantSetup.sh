#https://github.com/google/deepvariant/blob/r0.6/docs/deepvariant-quick-start.md
#source deepvariantSetup.sh
#cd deepvariant
PATH=$PATH:$HOME/HeLa/rtg-tools-3.10.1-linux-x64/rtg-tools-3.10.1
BUCKET="gs://deepvariant"
BIN_VERSION="0.6.1"
MODEL_VERSION="0.6.0"
MODEL_CL="191676894"
BIN_BUCKET="${BUCKET}/binaries/DeepVariant/${BIN_VERSION}/DeepVariant-${BIN_VERSION}+cl-*"
MODEL_NAME="DeepVariant-inception_v3-${MODEL_VERSION}+cl-${MODEL_CL}.data-wgs_standard"
MODEL_BUCKET="${BUCKET}/models/DeepVariant/${MODEL_VERSION}/${MODEL_NAME}"
DATA_BUCKET="${BUCKET}/quickstart-testdata"
OUTPUT_DIR=quickstart-output
REF=quickstart-testdata/ucsc.hg19.chr20.unittest.fasta
BAM=quickstart-testdata/NA12878_S1.chr20.10_10p1mb.bam
MODEL="${MODEL_NAME}/model.ckpt"
LOGDIR=./logs
N_SHARDS=3
CALL_VARIANTS_OUTPUT="${OUTPUT_DIR}/call_variants_output.tfrecord.gz"
FINAL_OUTPUT_VCF="${OUTPUT_DIR}/output.vcf.gz"
python bin/call_variants.zip --outfile SRR2185909.fastq.sam.bam.hg38.tfrecord.20.gz_VO  --examples SRR2185909.fastq.sam.bam.hg38.tfrecord.20.gz --checkpoint  DeepVariant-inception_v3-0.6.0+cl-191676894.data-wgs_standard/model.ckpt
python bin/postprocess_variants.zip --ref ../hg38chr3bwaidx.fasta   --infile SRR2185909.fastq.sam.bam.hg38.tfrecord.20.gz_VO --outfile SRR2185909.vcf
/mnt/f/HeLa/hap.py/bin/hap.py quickstart-testdata/test_nist.b37_chr20_100kbp_at_10mb.vcf.gz SRR2185909.vcf -f quickstart-testdata/test_nist.b37_chr20_100kbp_at_10mb.bed -r quickstart-testdata/ucsc.hg19.chr20.unittest.fasta -o happyeg.out --engine=vcfeval -l chr20:1-10010000
awk '{print $1}' SRR2185909.vcf | sort -r | uniq -c
#for loop test with single file SRR2185909
for i in  chksrr/* ; do echo $i; j=$(basename $i);   j=${j%%.*} ; echo $j ;  done
for i in  chksrr/*fastq.sam.bam.hg38.tfrecord.1.gz ; do echo $i; j=$(basename $i);   j=${j%%.*}; echo $j ; parallel -j24 python bin/call_variants.zip --outfile chksrr/$j.{}.VO  --examples chksrr/$j.fastq.sam.bam.hg38.tfrecord.{}.gz --checkpoint  DeepVariant-inception_v3-0.6.0+cl-191676894.data-wgs_standard/model.ckpt ::: {1..22} X Y   ; done
for i in  chksrr/*fastq.sam.bam.hg38.tfrecord.1.gz ; do echo $i; j=$(basename $i);   j=${j%%.*}; echo $j ; parallel -j24 python bin/postprocess_variants.zip --ref ../hg38chr3bwaidx.fasta   --infile chksrr/$j.{}.VO --outfile chksrr/$j.{}.vcf ::: {1..22} X Y   ; done
#python bin/make_examples.zip   --mode calling     --ref "${REF}"     --reads "${BAM}"   --regions "chr20:10,000,000-10,010,000"   --examples "${OUTPUT_DIR}/examples.tfrecord.gz"
#python bin/call_variants.zip  --outfile "${CALL_VARIANTS_OUTPUT}"  --examples "${OUTPUT_DIR}/examples.tfrecord.gz"  --checkpoint 0.6.0/DeepVariant-inception_v3-0.6.0+cl-191676894.data-wgs_standard/model.ckpt
#python bin/postprocess_variants.zip   --ref "${REF}"   --infile "${CALL_VARIANTS_OUTPUT}"   --outfile "${FINAL_OUTPUT_VCF}"
#python $HOME/hap.py-install/bin/hap.py quickstart-testdata/test_nist.b37_chr20_100kbp_at_10mb.vcf.gz   "${FINAL_OUTPUT_VCF}"   -f quickstart-testdata/test_nist.b37_chr20_100kbp_at_10mb.bed   -r "${REF}"   -o "${OUTPUT_DIR}/happy.output"   --engine=vcfeval   -l chr20:10000000-10010000
#git clone https://github.com/Illumina/hap.py
#sudo apt install openjdk-8-jdk
#python install.py . --with-rtgtools
#/mnt/f/HeLa/hap.py/bin/hap.py quickstart-testdatatest_nist.b37_chr20_100kbp_at_10mb.vcf.gz examplesroot.vcf -f quickstart-testdata/test_nist.b37_chr20_100kbp_at_10mb.bed -r quickstart-testdata/ucsc.hg19.chr20.unittest.fasta -o happyeg.out --engine=vcfeval -l chr20:10000000-10010000
#for i in /mnt/z/ncbi/sra/dbGaP-12668/*.fastq ; do echo $i ; bwa mem -M -t 8 /home/animeshs/HeLa/hg38chr3bwaidx $i > $i.sam ; done
#for i in bam/* ; do echo $i; j=$(basename $i);   j=${j%%.*} ; echo $j ; time seq 0 $((N_SHARDS-1)) | parallel --eta --halt 2 --joblog "${LOGDIR}/log" --res "${LOGDIR}" python bin/make_examples.zip --mode calling   --ref ../hg38chr3bwaidx.fasta  --reads $i --examples $i.hg38.tfrecord@${N_SHARDS}.gz --sample_name $j --regions '"chr1"'  --task {} ; done
#for i in bam/*.sam.bam ; do echo $i; j=$(basename $i);   j=${j%%.*} ; echo $j ; parallel python bin/make_examples.zip --mode calling   --ref ../hg38chr3bwaidx.fasta  --reads $i --examples $i.hg38.tfrecord.{}.gz --sample_name $j --regions '"chr{}"'  ::: {2..22} X Y   ; done
#for i in bam/*.sam.bam ; do echo $i; j=$(basename $i);   j=${j%%.*} ; echo $j ; parallel python bin/make_examples.zip --mode calling   --ref ../hg38chr3bwaidx.fasta  --reads $i --examples $i.hg38.tfrecord.{}.gz --sample_name $j --regions '"chr{}"'  ::: {1..22} X Y   ; done
#bcftools mpileup -Ou -P 1.1e-5 --max-depth 1000 -f ../hg38chr3bwaidx.fasta /mnt/z/ncbi/sra/dbGaP-12668/SRR*.fastq.sam.bam | bcftools call -mv -Oz -o calls.vcf.gz
#for a single file SRR2185909
