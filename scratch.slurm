#!/bin/sh
#SBATCH --account=nn9036k --job-name=resultsTKvep
#SBATCH --time=240:00:00
#SBATCH --partition=bigmem
#SBATCH --ntasks=1 --cpus-per-task=32
#SBATCH --mem-per-cpu=16G
#SBATCH --mail-user=animesh.sharma@ntnu.no
#SBATCH --mail-type=ALL
#SBATCH --output=resultsTKvep.log
WORKDIR=$PWD
cd ${WORKDIR}
export PATH=$PATH:$PWD
echo "we are running from this directory: $SLURM_SUBMIT_DIR"
echo " the name of the job is: $SLURM_JOB_NAME"
echo "Th job ID is $SLURM_JOB_ID"
echo "The job was run on these nodes: $SLURM_JOB_NODELIST"
echo "Number of nodes: $SLURM_JOB_NUM_NODES"
echo "We are using $SLURM_CPUS_ON_NODE cores"
echo "We are using $SLURM_CPUS_ON_NODE cores per node"
echo "Total of $SLURM_NTASKS cores"
#export http_proxy=proxy.saga:3128
#export https_proxy=proxy.saga:3128
module load Java/17
java --version
#module load Miniconda3/22.11.1-1
#conda config --prepend channels bioconda
#conda config --show channels
#mamba install python=3.11 nf-core nextflow
#pip install nf-core
#nf-core --version
#nf-core, version 3.3.2
#export GITHUB_TOKEN="ghp_your_actual_token_here"
#nf-core pipelines download sarek   --revision 3.9.0   --container-system singularity   --container-cache-utilisation amend   --outdir ./sarek_download   --compress none --force
#nf-core create
#cd nf-core-spritz/
#git checkout dev
#git remote add origin https://github.com/animesh/spritz_nf.git
#git push --all origin
#ln -s /cluster/projects/nn9036k/scripts/TK9/*.gz .
#git show afe994d381dd5414f6a3fad8966910246b9c3ed4
#vim samples.csv
#conda activate nf-core
#nextflow  self-update
/cluster/home/ash022/scripts/nextflow -v
#nextflow version 26.04.6.12646
#nextflow run hello
#nextflow pull nf-core/sarek
#https://nf-co.re/sarek/3.4.0/docs/usage  -r <pipeline version eg 3.4> for Reproducibility
#nf-core/rnaseq  --outdir hg38varall --input samples.csv   -profile singularity -resume
#rm -rf  ~/.nextflow
#export GITHUB_TOKEN="ghp_your_actual_token_here"
#
#openjdk 17.0.4 2022-07-19
/cluster/home/ash022/scripts/nextflow run https://github.com/nf-core/sarek --revision 3.9.0 --input /cluster/projects/nn9036k/TK/sra/fastq/samples.csv --outdir resultsTKvep -profile singularity --tools haplotypecaller,vep --max_memory '512.GB' --max_cpus 32 -resume 
#cd /cluster/projects/nn9036k/scripts
#cat /cluster/projects/nn9036k/TK/sra/fastq/ena_fastq_urls.txt
#https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR310/070/SRR31089070/SRR31089070_1.fastq.gz
#https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR310/070/SRR31089070/SRR31089070_2.fastq.gz
#https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR310/071/SRR31089071/SRR31089071_1.fastq.gz
#https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR310/071/SRR31089071/SRR31089071_2.fastq.gz
#https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR310/072/SRR31089072/SRR31089072_1.fastq.gz
#https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR310/072/SRR31089072/SRR31089072_2.fastq.gz
#https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR310/073/SRR31089073/SRR31089073_1.fastq.gz
#https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR310/073/SRR31089073/SRR31089073_2.fastq.gz
#https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR310/074/SRR31089074/SRR31089074_1.fastq.gz
#https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR310/074/SRR31089074/SRR31089074_2.fastq.gz
#https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR310/075/SRR31089075/SRR31089075_1.fastq.gz
#https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR310/075/SRR31089075/SRR31089075_2.fastq.gz
#https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR310/076/SRR31089076/SRR31089076_1.fastq.gz
#https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR310/076/SRR31089076/SRR31089076_2.fastq.gz
#wget -i /cluster/projects/nn9036k/TK/sra/fastq/ena_fastq_urls.txt
#rsync -Parv   login.nird-lmd.sigma2.no:PD/Animesh/TK/*.f*q*.gz TK/.
#rename "R1.fastq.gz" "_1.fq.gz" *.fastq.gz
#rename "R2.fastq.gz" "_2.fq.gz" *.fastq.gz
#ls -ltrh TK/*.fq.gz | wc
#ls -1 TK/*_1.fq.gz | awk -F '_' '{print $1$2$5}' | sed 's/TK\///g' > S1
#ls -1 TK/*_1.fq.gz | awk -F '_' '{print $1}' | sed 's/TK\///g' > S2
#printf 'lane_%s\n' {1..30} > S3
#ls -1 $PWD/TK/*1.fq.gz  > S4
#ls -1 $PWD/TK/*2.fq.gz  > S5
#echo "patient,sample,lane,fastq_1,fastq_2" > samples.csv
#paste -d ',' S? >> samples.csv
#cat /cluster/projects/nn9036k/TK/sra/fastq/samples.csv 
#patient,sample,fastq_1,fastq_2,lane
#TK18,SRR31089070,/cluster/projects/nn9036k/TK/sra/fastq/SRR31089070_1.fastq.gz,/cluster/projects/nn9036k/TK/sra/fastq/SRR31089070_2.fastq.gz,NA
#TK16,SRR31089071,/cluster/projects/nn9036k/TK/sra/fastq/SRR31089071_1.fastq.gz,/cluster/projects/nn9036k/TK/sra/fastq/SRR31089071_2.fastq.gz,NA
#TK14,SRR31089072,/cluster/projects/nn9036k/TK/sra/fastq/SRR31089072_1.fastq.gz,/cluster/projects/nn9036k/TK/sra/fastq/SRR31089072_2.fastq.gz,NA
#TK13,SRR31089073,/cluster/projects/nn9036k/TK/sra/fastq/SRR31089073_1.fastq.gz,/cluster/projects/nn9036k/TK/sra/fastq/SRR31089073_2.fastq.gz,NA
#TK12,SRR31089074,/cluster/projects/nn9036k/TK/sra/fastq/SRR31089074_1.fastq.gz,/cluster/projects/nn9036k/TK/sra/fastq/SRR31089074_2.fastq.gz,NA
#TK10,SRR31089075,/cluster/projects/nn9036k/TK/sra/fastq/SRR31089075_1.fastq.gz,/cluster/projects/nn9036k/TK/sra/fastq/SRR31089075_2.fastq.gz,NA
#TK9,SRR31089076,/cluster/projects/nn9036k/TK/sra/fastq/SRR31089076_1.fastq.gz,/cluster/projects/nn9036k/TK/sra/fastq/SRR31089076_2.fastq.gz,NA
#cd /cluster/projects/nn9036k/TK/sra/fastq 
#dos2unix scratch.slurm /cluster/projects/nn9036k/TK/sra/fastq/samples.csv
#sbatch scratch.slurm  
#tail -f resultsTKvep.log

