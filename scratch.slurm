#!/bin/sh
#SBATCH --account=nn9036k --job-name=GH37NFTK
#SBATCH --time=168:00:00
#SBATCH --partition=bigmem
#SBATCH --ntasks=1 --cpus-per-task=32
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

nextflow run nf-core/rnaseq  --max_memory '256.GB' --max_cpus 64  --outdir HG37all --input samples.csv --genome GRCh37 -profile singularity -resume

#rsync -Parv  login.nird-lmd.sigma2.no:PD/Animesh/TK/TK9R/*gz .
#rename  'R1.fastq.gz' '_1.fq.gz' *
#rename  'R2.fastq.gz' '_2.fq.gz' *
#ls -1 *2.fq.gz  > S2
#ls -1 *1.fq.gz  > S1
#printf 'auto\n%.0s' {1..30} > S3
#echo "sample,fastq_1,fastq_2,strandedness" > samples.csv
#paste -d ','  S? >> samples.csv
#cat samples.csv

