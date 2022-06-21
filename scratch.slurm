#!/bin/sh
##SBATCH --partition=bigmem
#SBATCH --account=nn9036k --job-name=comp40nilu
##SBATCH --account=nn9036k --job-name=comp64BM
#SBATCH --time=120:00:00
#SBATCH --mail-user=animesh.sharma@ntnu.no
##SBATCH --mem-per-cpu=16G
#SBATCH --mem-per-cpu=4G
#SBATCH --ntasks=4 --cpus-per-task=10 --ntasks-per-node=4
##SBATCH --ntasks=1 --cpus-per-task=16 --ntasks-per-node=4
#SBATCH --mail-type=ALL
#SBATCH --output=/cluster/projects/nn9036k/220610_NILU/out.slurm
##SBATCH --output=/cluster/projects/nn9036k/scripts/outBM.slurm

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
module load Java/13.0.2
/cluster/projects/nn9036k/FP18/fragpipe/bin/fragpipe --headless --threads 40 --ram 128 --workflow /cluster/projects/nn9036k/220610_NILU/Open.workflow --manifest /cluster/projects/nn9036k/220610_NILU/manifest.fp-manifest --workdir /cluster/projects/nn9036k/220610_NILU/FP18
#/cluster/projects/nn9036k/FP18/fragpipe/bin/fragpipe --headless --threads 64 --ram 1024 --workflow /cluster/projects/nn9036k/febSig/Open.workflow --manifest /cluster/projects/nn9036k/febSig/manifest.fp-manifest --workdir /cluster/projects/nn9036k/febSig/FPv18n
