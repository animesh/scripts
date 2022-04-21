#!/bin/sh
#SBATCH --partition=bigmem
##SBATCH --account=nn9036k --job-name=comp40
#SBATCH --account=nn9036k --job-name=comp64BM
#SBATCH --time=120:00:00
#SBATCH --mem-per-cpu=8G
#SBATCH --mail-user=animesh.sharma@ntnu.no
##SBATCH --ntasks=4 --cpus-per-task=10 --ntasks-per-node=4
#SBATCH --ntasks=1 --cpus-per-task=16 --ntasks-per-node=4
#SBATCH --mail-type=ALL
##SBATCH --output=/cluster/projects/nn9036k/scripts/out.slurm
#SBATCH --output=/cluster/projects/nn9036k/scripts/outBM.slurm

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
conda activate spritzbase
module load MaxQuant/1.6.17.0-foss-2019b
module load dotNET-SDK/3.1.300-linux-x64
# 1020  2022-04-21T11:09:12 snakemake -j 24 --use-conda --conda-frontend mamba --resources mem_mb=100000
# 1021  2022-04-21T11:39:57 less /cluster/projects/nn9036k/Spritz/Spritz/workflow/.snakemake/log/2022-04-21T110920.395820.snakemake.log
# 1022  2022-04-21T11:40:28 less ../resources/SpritzModifications.build.log
snakemake -j 64 --use-conda --conda-frontend mamba --resources mem_mb=512000
