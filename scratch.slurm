#!/bin/sh
#SBATCH --partition=bigmem
#SBATCH --account=nn9036k --job-name=DNTBM
#SBATCH --time=144:00:00
#SBATCH --mem=512G
#SBATCH --mail-user=animesh.sharma@ntnu.no
#SBATCH --ntasks=1 --cpus-per-task=16 
#SBATCH --mail-type=ALL
#SBATCH --output=/cluster/projects/nn9036k/scripts/outDNTBM.slurm
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
conda activate nf-core
nextflow run 'https://github.com/nf-core/denovotranscript' -r 558ff4b639039ac8ec9bece3490841aa17eec971 -profile singularity --input samples.csv --outdir DNTK --max_memory '512.GB' --max_cpus 32 -resume


