#!/bin/sh
##SBATCH --partition=bigmem
#SBATCH --account=nn9036k --job-name=nfTK
##SBATCH --account=nn9036k --job-name=nextflowBM
#SBATCH --time=120:00:00
#SBATCH --mail-user=animesh.sharma@ntnu.no
##SBATCH --ntasks=1 --cpus-per-task=16 --ntasks-per-node=4
##SBATCH --mem-per-cpu=16G
#SBATCH --ntasks=1 --cpus-per-task=36
#SBATCH --mem-per-cpu=2G
#SBATCH --mail-type=ALL
#SBATCH --output=nfTKlog

WORKDIR=${SLURM_SUBMIT_DIR}
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

module purge
module load FastQC/0.11.9-Java-11

#ls -1 $PWD/TK/*1.fq.gz > r1
#ls -1 $PWD/TK/*2.fq.gz > r2
#awk -F '/' '{print $6}' | sed 's|TK|auto|' > orient 
#echo "sample,fastq_1,fastq_2,strandedness" > TK/sample.csv 
#paste -d ','  sample r1 r2 orient >> TK/sample.csv
#cat TK/sample.csv
#ln -s $HOME/.nextflow/assets/nf-core/rnaseq/conf .

$HOME/bin/nextflow run nf-core/rnaseq  --outdir $PWD/TK/nextflowHG37 --input $PWD/TK/sample.csv --genome GRCh37 -profile singularity

