#!/bin/sh
#SBATCH --account=nn9036k --job-name=TKVARS3P4HG38NF
#SBATCH --time=168:00:00
##SBATCH --partition=bigmem
#SBATCH --ntasks=4 --cpus-per-task=16
#SBATCH --mem-per-cpu=8G
#SBATCH --mail-user=animesh.sharma@ntnu.no
#SBATCH --mail-type=ALL
#SBATCH --output=TKVARS3P4HG38NF


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

export http_proxy=proxy.saga:3128
export https_proxy=proxy.saga:3128
module load Miniconda3/22.11.1-1
#conda config --prepend channels bioconda
#conda config --show channels
#mamba install python=3.11 nf-core nextflow
#nf-core create
#cd nf-core-spritz/
#git checkout dev
#git remote add origin https://github.com/animesh/spritz_nf.git
#git push --all origin
#ln -s /cluster/projects/nn9036k/scripts/TK9/*.gz .
#vim samples.csv
conda activate nf-core
#nextflow  self-update
nextflow  -v
#nextflow run hello
#nextflow pull nf-core/sarek
#https://nf-co.re/sarek/3.4.0/docs/usage  -r <pipeline version eg 3.4> for Reproducibility
#nf-core/rnaseq  --max_memory '256.GB' --max_cpus 30  --outdir hg38varall --input samples.csv   -profile singularity  --tools vep -resume
nextflow run 'https://github.com/nf-core/sarek' -params-file nextflow.json -with-tower -r 3.4.0 -profile singularity
#nextflow run https://github.com/nf-core/sarek -name marvelous_kimura -params-file https://api.tower.nf/ephemeral/gGO6qmeGxQ6OUZJDOXPC1g.json -with-tower -r 3.4.0 -profile singularity
#cd /cluster/projects/nn9036k/scripts
#rsync -Parv   login.nird-lmd.sigma2.no:PD/Animesh/TK/*.f*q*.gz TK/.
#rename "R1.fastq.gz" "_1.fq.gz" *.fastq.gz
#rename "R2.fastq.gz" "_2.fq.gz" *.fastq.gz
#ls -ltrh TK/*.fq.gz | wc
ls -1 TK/*_1.fq.gz | awk -F '_' '{print $1$2$5}' | sed 's/TK\///g' > S1
ls -1 TK/*_1.fq.gz | awk -F '_' '{print $1}' | sed 's/TK\///g' > S2
printf 'lane_%s\n' {1..30} > S3
ls -1 $PWD/TK/*1.fq.gz  > S4
ls -1 $PWD/TK/*2.fq.gz  > S5
echo "patient,sample,lane,fastq_1,fastq_2" > samples.csv
paste -d ',' S? >> samples.csv
cat samples.csv
#tail -f nf-1Bpr9p1bhYVOBt.log
#dos2unix scratch.slurm nextflow.json samples.csv

