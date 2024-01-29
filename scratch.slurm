#!/bin/sh
#SBATCH --account=nn9036k --job-name=hg38NFTK
#SBATCH --time=168:00:00
##SBATCH --partition=bigmem
#SBATCH --ntasks=4 --cpus-per-task=16
#SBATCH --mem-per-cpu=8G
#SBATCH --mail-user=animesh.sharma@ntnu.no
#SBATCH --mail-type=ALL
#SBATCH --output=NFSLURMLOG


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
#nextflow pull nf-core/rnaseq
#https://nf-co.re/rnaseq/3.13.2/docs/usage -r <pipeline version eg 1.3.1> for Reproducibility
#nf-core/rnaseq  --max_memory '256.GB' --max_cpus 30  --outdir hg38lall --input samples.csv --gtf /cluster/projects/nn9036k/scripts/hg38v110/Homo_sapiens.GRCh38.110.gtf --fasta /cluster/projects/nn9036k/scripts/hg38v110/genome.fa --genome null  --igenomes_ignore  -profile singularity -resume
nextflow run 'https://github.com/nf-core/rnaseq' -name tkall3p14_slurm -params-file nextflow.json -with-tower -r 3.14.0 -profile singularity
#rsync -Parv   login.nird-lmd.sigma2.no:PD/Animesh/TK/*.f*q*.gz TK/.
#rename "R1.fastq.gz" "_1.fq.gz" *.fastq.gz
#rename "R2.fastq.gz" "_2.fq.gz" *.fastq.gz
#git checkout d7c2643c291dbc481236ba7ab4033f823d4afbd7 scratch.slurm
#cat scratch.slurm
#ls -ltrh TK/*.fq.gz | wc
#ls -1 $PWD/TK/*2.fq.gz  > S2
#ls -1 $PWD/TK/*1.fq.gz  > S1
#printf 'auto\n%.0s' {1..30} > S3
#ls -1 TK/*_1.fq.gz | awk -F '_' '{print $1$2$5}' | sed 's/TK\///g' > S0
#rm -rf SI
#echo "sample,fastq_1,fastq_2,strandedness" > samples.csv
#cat samples.csv
#tail -f nf-1Bpr9p1bhYVOBt.log
#dos2unix scratch.slurm nextflow.json samples.csv

