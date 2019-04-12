#https://github.com/google/deepvariant/blob/r0.6/docs/deepvariant-quick-start.md
#source deepvariantSetup.sh 
#cd deepvariant
#python bin/make_examples.zip   --mode calling     --ref "${REF}"     --reads "${BAM}"   --regions "chr20:10,000,000-10,010,000"   --examples "${OUTPUT_DIR}/examples.tfrecord.gz"
#python bin/call_variants.zip  --outfile "${CALL_VARIANTS_OUTPUT}"  --examples "${OUTPUT_DIR}/examples.tfrecord.gz"  --checkpoint 0.6.0/DeepVariant-inception_v3-0.6.0+cl-191676894.data-wgs_standard/model.ckpt
#python bin/postprocess_variants.zip   --ref "${REF}"   --infile "${CALL_VARIANTS_OUTPUT}"   --outfile "${FINAL_OUTPUT_VCF}"
#python $HOME/hap.py-install/bin/hap.py quickstart-testdata/test_nist.b37_chr20_100kbp_at_10mb.vcf.gz   "${FINAL_OUTPUT_VCF}"   -f quickstart-testdata/test_nist.b37_chr20_100kbp_at_10mb.bed   -r "${REF}"   -o "${OUTPUT_DIR}/happy.output"   --engine=vcfeval   -l chr20:10000000-10010000
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
