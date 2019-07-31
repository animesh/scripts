#https://github.com/google/deepvariant/blob/r0.8/docs/deepvariant-quick-start.md from https://github.com/google/deepvariant/blob/r0.6/docs/deepvariant-quick-start.md , skipping https://github.com/google/deepvariant/blob/r0.7/docs/deepvariant-quick-start.md
#install gcloud
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
sudo apt-get install apt-transport-https ca-certificates
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
sudo apt-get update && sudo apt-get install google-cloud-sdk
gcloud init
gcloud auth login
#run in parallel
sudo apt -y install parallel
#clone deepvariant
git clone https://github.com/animesh/deepvariant.git
cd deepvariant
#install deepvariant
./build-prereq.sh
#ERROR: markdown 3.1.1 has requirement setuptools>=36, but you'll have setuptools 20.7.0 which is incompatible.
#pip install setuptools-markdown --upgrade --user
./build_and_test.sh
./run-prereq.sh
gsutil cp -R gs://deepvariant/quickstart-testdata .
mkdir -p quickstart-output
gsutil cp -R gs://deepvariant/models/DeepVariant/0.8.0 .
sudo ln -s $PWD/bazel-bin/deepvariant /opt/deepvariant
ls bazel-bin/deepvariant/
sudo ln -s /home/animeshs/deepvariant/bazel-bin/deepvariant /opt/deepvariant/bin
python bazel-bin/deepvariant/make_examples.zip --mode calling  --ref quickstart-testdata/ucsc.hg19.chr20.unittest.fasta --reads quickstart-testdata/NA12878_S1.chr20.10_10p1mb.bam -regions "chr20:10,000,000-10,010,000" --examples quickstart-output/examples.tfrecord.gz
python ./scripts/run_deepvariant.py --model_type=WGS --ref=quickstart-testdata/ucsc.hg19.chr20.unittest.fasta --reads=quickstart-testdata/NA12878_S1.chr20.10_10p1mb.bam -regions "chr20:10,000,000-10,010,000" --output_vcf=quickstart-output/output.vcf.gz  --output_gvcf=quickstart-output/output.g.vcf.gz --num_shards=1
python bazel-bin/deepvariant/make_examples.zip --mode calling --ref "quickstart-testdata/ucsc.hg19.chr20.unittest.fasta" --reads "quickstart-testdata/NA12878_S1.chr20.10_10p1mb.bam" --examples "/tmp/deepvariant_tmp_output/make_examples.tfrecord@1.gz" --regions "chr20:10,000,000-10,010,000" --gvcf "/tmp/deepvariant_tmp_output/gvcf.tfrecord@1.gz"
python ./scripts/run_deepvariant.py --model_type=WGS --ref=quickstart-testdata/ucsc.hg19.chr20.unittest.fasta --reads=quickstart-testdata/NA12878_S1.chr20.10_10p1mb.bam -regions "chr20:10,000,000-10,010,000" --output_vcf=quickstart-output/output.vcf.gz  --output_gvcf=quickstart-output/output.g.vcf.gz --num_shards=1
#https://github.com/google/deepvariant/issues/199
sudo apt autoremove
sudo apt remove containerd.io
scripts/run_wes_case_study_binaries.sh
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
#for loop through entire bam folder and run for chromosome in parallel
#for i in  bam/vcf/*fastq.sam.bam.hg38.tfrecord.1.gz ; do echo $i; j=$(basename $i);   j=${j%%.*}; echo $j ; parallel -j24 python bin/call_variants.zip --outfile bam/vcf/$j.{}.VO  --examples bam/vcf/$j.fastq.sam.bam.hg38.tfrecord.{}.gz --checkpoint  DeepVariant-inception_v3-0.6.0+cl-191676894.data-wgs_standard/model.ckpt ::: {1..22} X Y   ; done
#for i in  bam/vcf/*fastq.sam.bam.hg38.tfrecord.1.gz ; do echo $i; j=$(basename $i);   j=${j%%.*}; echo $j ; parallel -j24 python bin/postprocess_variants.zip --ref ../hg38chr3bwaidx.fasta   --infile bam/vcf/$j.{}.VO --outfile bam/vcf/$j.{}.vcf ::: {1..22} X Y   ; done
#awk '{print $1}' bam/vcf/SRR2185909.vcf | sort -r | uniq -c
#check effect of detected variants
#git clone https://github.com/Ensembl/ensembl-vep.git
#cd ensembl-vep
#for i in  ../deepvariant/bam/*.1.vcf ; do echo $i; j=$(basename $i);   j=${j%%.*}; echo $j ; parallel -j24 ../ensembl-tools/scripts/variant_effect_predictor/variant_effect_predictor.pl -i ../deepvariant/bam/$j.{}.vcf --plugin ProteinSeqs,mutated/$j.{}.ref.fasta,mutated/$j.{}.mut.fasta -o mutated/$j.{}. --cache ::: {1..22} X Y   ; done
#collect variants in a single file with FILENAME in fasta header
#cd mutated
#for i in  *.mut.fasta ;  do  awk '{if(/^>/){print $1,FILENAME}else print}' $i; done >> HeLa.deepvariant.vep.mutated.fasta
#grep "ENSP00000354040.4:p.Ala250GlyfsTer9" -B1 -A1 *fasta
#/mnt/f/HeLa/hap.py/bin/hap.py quickstart-testdata/test_nist.b37_chr20_100kbp_at_10mb.vcf.gz SRR2185909.vcf -f quickstart-testdata/test_nist.b37_chr20_100kbp_at_10mb.bed -r quickstart-testdata/ucsc.hg19.chr20.unittest.fasta -o happyeg.out --engine=vcfeval -l chr20:1-10010000
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
