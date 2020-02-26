#https://www.htslib.org/doc/samtools.html
wget ftp://ftp.ebi.ac.uk/pub/databases/ena/wgs/public/jj/JJOD01.fasta.gz
gunzip JJOD01.fasta.gz
grep "^>" JJOD01.fasta  | awk -F '.' '{print $3}' | sort  | uniq -c | awk '{sum+=$1;print sum}' #OUTPUT 138
samtools faidx JJOD01.fasta
wc JJOD01.fasta.fai #OUTPUT 138
#bwa mem -M -t 12 JJOD01.fasta Aas-gDNA1-O2-PaE_S6_L001_R.s1/Aas-gDNA1-O2-PaE_S6_L001_R1_001.fastq.split.r1.fq Aas-gDNA1-O2-PaE_S6_L001_R.s1/Aas-gDNA1-O2-PaE_S6_L001_R1_001.fastq.split.r2.fq > Aas-gDNA1-O2-PaE_S6_L001_R.s1/Aas-gDNA1-O2-PaE_S6_L001_R1_001.fastq.split.r1.sam
#samtools view -bS ../Aas-gDNA1-O2-PaE_S6_L001_R.s1/Aas-gDNA1-O2-PaE_S6_L001_R1_001.fastq.split.r1.sam | samtools sort -o file.bam
ln -s ../Aas-gDNA1-*/*.r?.fq .
for i in *.r1.fq ; do echo $i; j=$(basename $i);   k=${j%%.*} ; j=$k.fastq.split.r2.fq ; echo $j ; bwa mem -M -t 12 ../JJOD01.fasta $i $j > $k.sam ; samtools view -bS $k.sam | samtools sort -o $k.bam ; samtools index $k.bam ; done

cd $HOME/Pseudomonas/DeepVariant-0.9.0
gcloud auth login
#gsutil cp -R  gs://deepvariant/binaries/DeepVariant/0.9.0/DeepVariant-0.9.0 .
gsutil cp -R gs://deepvariant/models/DeepVariant/0.9.0 .
cd DeepVariant-0.9.0/
./run-prereq.sh
rm /home/animeshs/.local/lib/python2.7/site-packages/tensorflow_*
sudo rm -rf /usr/local/lib/python2.7/dist-packages/tensor*
python2.7 -m pip install tensorflow==1.13.1 --user
export PATH=$PATH:/home/animeshs/.local/bin

for i in ../fastqP/Aas-gDNA1-*.bam ; do echo $i ; python make_examples.zip --mode calling  --ref ../JJOD01.fasta --reads $i --examples $i.nosample.tfrecord.gz ; done
#python call_variants.zip --outfile call_variants_out2.tfrecord.gz   --examples ../fastqP/Aas-gDNA1-S4-PaE_S4_L001_R1_001.bam.examples.tfrecord.gz --checkpoint  0.9.0/DeepVariant-inception_v3-0.9.0+data-wgs_standard/model.ckpt
for i in ../fastqP/*examples.tfrecord.gz ; do echo $i ; python call_variants.zip --outfile $i.call_variants_output.tfrecord.gz  --examples $i --checkpoint 0.9.0/DeepVariant-inception_v3-0.9.0+data-wgs_standard/model.ckpt ; done
#python postprocess_variants.zip --ref ../JJOD01.fasta --infile call_variants_out2.tfrecord.gz --outfile  file.vcf
for i in ../fastqP/*call_variants_output.tfrecord.gz ; do echo $i ; j=$(basename $i); k=${j%%.*} ; echo $k; python postprocess_variants.zip --ref ../JJOD01.fasta --infile $i --outfile  $k.vcf; done

ln -s ../Aas-gDNA1-*/*unpaired.fa ../fastq/.
for i in *.fa ; do echo $i; k=$(basename $i); echo  $k ; bwa mem -M -t 12 ../JJOD01.fasta $i > $k.sam ; samtools view -bS $k.sam | samtools sort -o $k.bam ; samtools index $k.bam ; done
for i in ../fastqP/Aas-gDNA1-*.bam ; do echo $i ; python make_examples.zip --mode calling  --ref ../JJOD01.fasta --reads $i --examples $i.nosample.tfrecord.gz ; done
for i in *.r1.fq ; do echo $i; j=$(basename $i);   k=${j%%.*} ; j=$k.fastq.split.r2.fq ; echo $j ; bwa mem -M -t 12 ../JJOD01.fasta $i $j > $k.sam ; samtools view -bS $k.sam | samtools sort -o $k.bam ; samtools index $k.bam ; done

#find ../fastq/ -iname "*.bam" | parallel -j 12 "python make_examples.zip --mode calling  --ref ../JJOD01.fasta --reads {} --examples {}.examples.tfrecord.gz  --sample_name pse.{}.sample"
#find ../fastq/ -iname "*.examples.tfrecord.gz" | parallel -j 12 "python call_variants.zip --outfile {}.examples.tfrecord.cvo.gz --examples {} --checkpoint 0.9.0/DeepVariant-inception_v3-0.9.0+data-wgs_standard/model.ckpt"
#python call_variants.zip --outfile call_variants_output.tfrecord.gz   --examples Aas-gDNA1-S4-PaE_S4_L001_R1_001.bam.examples.tfrecord.gz --checkpoint  0.9.0/DeepVariant-inception_v3-0.9.0+data-wgs_standard/model.ckpt
for i in ../fastq/*examples.tfrecord.gz ; do echo $i ; python call_variants.zip --outfile $i.call_variants_output.tfrecord.gz  --examples $i --checkpoint 0.9.0/DeepVariant-inception_v3-0.9.0+data-wgs_standard/model.ckpt ; done
for i in ../fastq/*call_variants_output.tfrecord.gz ; do echo $i ; j=$(basename $i); k=${j%%.*} ; echo $k; python postprocess_variants.zip --ref ../JJOD01.fasta --infile $i --outfile  $k.vcf; done

ln -s ../Aas-gDNA1-*/*unpaired.fa .
for i in *.fa ; do echo $i; k=$(basename $i); echo  $k ; bwa mem -M -t 12 ../JJOD01.fasta $i > $k.sam ; samtools view -bS $k.sam | samtools sort -o $k.bam ; samtools index $k.bam ; done
for i in *.r1.fq ; do echo $i; j=$(basename $i);   k=${j%%.*} ; j=$k.fastq.split.r2.fq ; echo $j ; bwa mem -M -t 12 ../JJOD01.fasta $i $j > $k.sam ; samtools view -bS $k.sam | samtools sort -o $k.bam ; samtools index $k.bam ; done
for i in ../fastqP/Aas-gDNA1-*.bam ; do echo $i ; python make_examples.zip --mode calling  --ref ../JJOD01.fasta --reads $i --examples $i.nosample.tfrecord.gz ; done
for i in ../fastqP/*W*.nosample.tfrecord.gz ; do echo $i ; python call_variants.zip --outfile $i.call_variants_out.tfrecord.gz   --examples $i --checkpoint  0.9.0/DeepVariant-inception_v3-0.9.0+data-wgs_standard/model.ckpt ; done



#samtools view -bS ../Aas-gDNA1-O2-PaE_S6_L001_R.s1/Aas-gDNA1-O2-PaE_S6_L001_R1_001.fastq.split.r1.sam | samtools sort -o file.bam
#samtools index file.bam
python make_examples.zip --mode calling  --ref ../JJOD01.fasta --reads ../Aas-gDNA1-O2-PaE_S6_L001_R.s1/Aas-gDNA1-O2-PaE_S6_L001_R1_001.fastq.split.r1.sam.bam --examples examples.tfrecord.gz  --sample_name pseudomonas
python call_variants.zip --outfile file.cvo.gz --examples  ../fastqP/Aas-gDNA1-W2-PaE_S8_L001_R1_001.bam.examples.tfrecord.gz --checkpoint ./0.9.0/DeepVariant-inception_v3-0.9.0+data-wgs_standard/model.ckpt
python postprocess_variants.zip --ref ../JJOD01.fasta --infile file.cvo.gz --outfile  file.vcf.gz
for i in ../fastqP/*examples.tfrecord.gz ; do echo $i ; python call_variants.zip --outfile $i.call_variants_output.tfrecord.gz  --examples $i --checkpoint 0.9.0/DeepVariant-inception_v3-0.9.0+data-wgs_standard/model.ckpt ; donef

cp file.bam ../Aas-gDNA1-O2-PaE_S6_L001_R.s1/Aas-gDNA1-O2-PaE_S6_L001_R1_001.fastq.split.r1.sam.bam
cp file.bam.bai ../Aas-gDNA1-O2-PaE_S6_L001_R.s1/Aas-gDNA1-O2-PaE_S6_L001_R1_001.fastq.split.r1.sam.bam.bai
python make_examples.zip --mode calling  --ref ../JJOD01.fasta --reads ../Aas-gDNA1-O2-PaE_S6_L001_R.s1/Aas-gDNA1-O2-PaE_S6_L001_R1_001.fastq.split.r1.sam.bam --examples examples.tfrecord.gz  --sample_name pseudomonas
I0207 16:14:35.644433 140097430558144 make_examples.py:377] ReadRequirements are: min_mapping_quality: 10
min_base_quality: 10
min_base_quality_mode: ENFORCED_BY_CLIENT
I0207 16:14:35.650413 140097430558144 make_examples.py:1324] Preparing inputs
I0207 16:14:35.652965 140097430558144 genomics_reader.py:223] Reading ../Aas-gDNA1-O2-PaE_S6_L001_R.s1/Aas-gDNA1-O2-PaE_S6_L001_R1_001.fastq.split.r1.sam.bam with NativeSamReader
I0207 16:14:35.714081 140097430558144 make_examples.py:1248] Common contigs are

#https://github.com/google/deepvariant/blob/r0.8/docs/deepvariant-quick-start.md from https://github.com/google/deepvariant/blob/r0.6/docs/deepvariant-quick-start.md , skipping https://github.com/google/deepvariant/blob/r0.7/docs/deepvariant-quick-start.md
#pip install tensorflow==1.13.1 --user
#cleanup
sudo apt -y remove containerd.io
sudo apt -y autoremove
#install gcloud
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
sudo apt-get install apt-transport-https ca-certificates
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
sudo apt-get update && sudo apt-get install google-cloud-sdk
gcloud init
gcloud auth login
#to run in parallel
sudo apt -y install parallel
#clone deepvariant
git clone https://github.com/animesh/deepvariant.git
cd deepvariant
#install deepvariant
#ERROR: markdown 3.1.1 has requirement setuptools>=36, but you'll have setuptools 20.7.0 which is incompatible.
pip install setuptools-markdown --upgrade --user
./build-prereq.sh
#test build
./build_and_test.sh
./run-prereq.sh
#sudo ln -s $PWD/bazel-bin/deepvariant /opt/deepvariant
ls bazel-bin/deepvariant/
#sudo ln -s /home/animeshs/deepvariant/bazel-bin/deepvariant /opt/deepvariant/bin
#https://github.com/google/deepvariant/issues/199
scripts/run_wes_case_study_binaries.sh
#running on example dataset
gsutil cp -R gs://deepvariant/quickstart-testdata .
mkdir -p quickstart-output
gsutil cp -R gs://deepvariant/models/DeepVariant/0.8.0 .
#make examples
python bazel-bin/deepvariant/make_examples.zip --mode calling  --ref quickstart-testdata/ucsc.hg19.chr20.unittest.fasta --reads quickstart-testdata/NA12878_S1.chr20.10_10p1mb.bam --regions "chr20:10,000,000-10,010,000" --examples quickstart-output/examples.tfrecord.gz #--gvcf quickstart-output/examples.tfrecord.vcf.gz
#call variants
python ./bazel-bin/deepvariant/call_variants.zip --outfile quickstart-output/examples.tfrecord.cvo.gz --examples quickstart-output/examples.tfrecord.gz --checkpoint 0.8.0/DeepVariant-inception_v3-0.8.0+data-wgs_standard/model.ckpt
#postprocess/generate vcf
python ./bazel-bin/deepvariant/postprocess_variants.zip --ref quickstart-testdata/ucsc.hg19.chr20.unittest.fasta --infile  quickstart-output/examples.tfrecord.cvo.gz --outfile  quickstart-output/examples.vcf
#compare results with gold-standard
#git clone https://github.com/Illumina/hap.py
#cd hap.py
#sudo apt-get install default-jdk ant
#src/sh/make_hg19.sh
#export HGREF=hg19.fa
#python install.py . --with-rtgtools
hap.py/bin/hap.py quickstart-testdata/test_nist.b37_chr20_100kbp_at_10mb.vcf.gz quickstart-output/examples.vcf -f quickstart-testdata/test_nist.b37_chr20_100kbp_at_10mb.bed -r quickstart-testdata/ucsc.hg19.chr20.unittest.fasta -o happyeg.out --engine=vcfeval -l chr20:10000000-10010000
#for loop through entire bam folder and run for chromosome in parallel
#for i in  bam/vcf/*fastq.sam.bam.hg38.tfrecord.1.gz ; do echo $i; j=$(basename $i);   j=${j%%.*}; echo $j ; parallel -j24 python bin/call_variants.zip --outfile bam/vcf/$j.{}.VO  --examples bam/vcf/$j.fastq.sam.bam.hg38.tfrecord.{}.gz --checkpoint  DeepVariant-inception_v3-0.6.0+cl-191676894.data-wgs_standard/model.ckpt ::: {1..22} X Y   ; done
#for i in  bam/vcf/*fastq.sam.bam.hg38.tfrecord.1.gz ; do echo $i; j=$(basename $i);   j=${j%%.*}; echo $j ; parallel -j24 python bin/postprocess_variants.zip --ref ../hg38chr3bwaidx.fasta   --infile bam/vcf/$j.{}.VO --outfile bam/vcf/$j.{}.vcf ::: {1..22} X Y   ; done
#awk '{print $1}' bam/vcf/SRR2185909.vcf | sort -r | uniq -c
#check effect of detected variants
cd $HOME
git clone https://github.com/Ensembl/ensembl-vep.git
cd ensembl-vep
#sudo apt-cache search perl | grep dbi
sudo apt install libdbi-perl
sudo apt install libmodule-build-perl
perl INSTALL.pl
#NB: Remember to use --refseq when running the VEP with this cache!
#300
# - downloading ftp://ftp.ensembl.org/pub/release-96/variation/indexed_vep_cache/homo_sapiens_vep_96_GRCh38.tar.gz
#303
# - downloading ftp://ftp.ensembl.org/pub/release-97/variation/indexed_vep_cache/homo_sapiens_refseq_vep_97_GRCh37.tar.gz
# ftp://ftp.ensembl.org/pub/grch37/release-97/gtf/homo_sapiens/Homo_sapiens.GRCh37.87.gtf.gz
# ftp://ftp.ensembl.org/pub/grch37/release-97/fasta/homo_sapiens/dna/Homo_sapiens.GRCh37.dna.primary_assembly.fa.gz
#306
# - downloading ftp://ftp.ensembl.org/pub/release-97/variation/indexed_vep_cache/homo_sapiens_vep_97_GRCh38.tar.gz
# https://www.ensembl.org/info/docs/tools/vep/script/vep_tutorial.html
#install ensembl-tools
cd $HOME
git clone https://github.com/Ensembl/ensembl-tools.git
cd ensembl-tools/scripts/variant_effect_predictor
git checkout release/88
git pull
ssh massturbinator
cd $HOME/ensembl-tools/scripts/variant_effect_predictor/
export PERL5LIB=$HOME/ensembl-vep:$PERL5LIB
perl INSTALL.pl
apt-cache search perl | grep archive
perl INSTALL.pl --NO_HTSLIB
sudo apt install libdbd-mysql-perl
#http://www.ensembl.org/info/docs/tools/vep/script/vep_cache.html#cache
#map ensembl ftp
sudo apt install curlftpfs
mkdir $HOME/vep
curlftpfs -r ftp.ensemblgenomes.org /home/animeshs/vep
ls $HOME/vep
ls /home/animeshs/vep/pub/bacteria/
for i in /home/animeshs/vep/pub/bacteria/current/variation/vep/* ; do echo $i ; ls -ltrh $i/*seudomonas* ; done >> /home/animeshs/promec/promec/Animesh/PA.txt
cp /home/animeshs/vep/pub/bacteria/current/variation/vep/bacteria_67_collection/pseudomonas_aeruginosa_vep_46_PUPa3_1.0.tar.gz /home/animeshs/promec/promec/Animesh/.
mkdir /home/animeshs/promec/promec/Animesh/vep
cd /home/animeshs/promec/promec/Animesh/vep
tar xvzf ../pseudomonas_aeruginosa_vep_46_PUPa3_1.0.tar.gz
cp -rf /home/animeshs/promec/promec/Animesh/vep/pseudomonas_aeruginosa $HOME/.vep/.
ls $HOME/.vep
less /home/animeshs/.vep/pseudomonas_aeruginosa/46_PUPa3_1.0/contig03.1/1-1000000.gz
less pseudomonas_aeruginosa/46_PUPa3_1.0/info.txt
perl fas2tablen.pl ../JJOD01.fasta > ../JJOD01.txt
perl deepvariantSetup.pl ../JJOD01.fasta ../Aas-gDNA1-S1-PaE_S1_L001_Rx.vcf > ../Aas-gDNA1-S1-PaE_S1_L001_Rx.reform.vcf
history|awk '{$1="";print substr($0,2)}' >> /home/animeshs/promec/promec/Animesh/history.txt
#http://www.ensembl.org/info/docs/tools/vep/script/vep_options.html
perl variant_effect_predictor.pl -i /home/animeshs/promec/promec/Animesh/Aas-gDNA1-S1-PaE_S1_L001_Rx.reform.vcf --plugin ProteinSeqs,ref.fasta,mut.fasta -o muta --species pseudomonas_aeruginosa --offline --cache_version 46
grep "^>" mut.fasta | wc
# 120895  120895 2555762
grep "^>" ref.fasta | wc
#4723    4723   47230
#http://bacteria.ensembl.org/Pseudomonas_aeruginosa/Tools/VEP/Results?tl=LJkul5SrSpbV0wI6-19708946
#./vep --appris --biotype --buffer_size 5000 --distance 5000 --is_multispecies 1 --mane --species pseudomonas_aeruginosa --symbol --transcript_version --tsl --cache --input_file [input_data] --output_file [output_file]
#http://bacteria.ensembl.org/Pseudomonas_aeruginosa/Tools/VEP/Results?tl=LJkul5SrSpbV0wI6-19708946
for i in /home/animeshs/ensembl-tools/scripts/variant_effect_predictor/Pseudomonas/*vcf;do echo $i; j=$(basename $i);   k=${j%%.*} ; j=$k.reform.vcf ; echo $j ; perl /home/animeshs/promec/promec/Animesh/scripts/deepvariantSetup.pl /home/animeshs/ensembl-tools/scripts/variant_effect_predictor/Pseudomonas/JJOD01.fasta $i > $j ; done
for i in *reform.vcf; do echo $i; j=$(basename $i); echo $j; perl variant_effect_predictor.pl -i $i --plugin ProteinSeqs,$j.ref.fasta,$j.mut.fasta -o $j.mut --species pseudomonas_aeruginosa --offline --cache_version 46 1>$j.1.out 2>$j.2.out 0>$j.0.out >> $j.null.out ; done


#example file
./variant_effect_predictor.pl -i ../../../deepvariant/quickstart-output/examples.vcf --plugin ProteinSeqs,ref.fasta,mut.fasta -o mutated --cache
#overwrite
$HOME/ensembl-tools/scripts/variant_effect_predictor/variant_effect_predictor.pl -i SRR2185909.vcf  --plugin ProteinSeqs,ref.fasta,mut.fasta -o mutated --cache --force_overwrite
#test files
#for i in  ../deepvariant/bam/*.1.vcf ; do echo $i; j=$(basename $i);   j=${j%%.*}; echo $j ; parallel -j24 ../ensembl-tools/scripts/variant_effect_predictor/variant_effect_predictor.pl -i ../deepvariant/bam/$j.{}.vcf --plugin ProteinSeqs,mutated/$j.{}.ref.fasta,mutated/$j.{}.mut.fasta -o mutated/$j.{}. --cache ::: {1..22} X Y   ; done
#collect variants in a single file with FILENAME in fasta header
#cd mutated
#for i in  *.mut.fasta ;  do  awk '{if(/^>/){print $1,FILENAME}else print}' $i; done >> HeLa.deepvariant.vep.mutated.fasta
#grep "ENSP00000354040.4:p.Ala250GlyfsTer9" -B1 -A1 *fasta
