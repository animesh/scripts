#!/bin/sh
#SBATCH --account=nn9036k --job-name=NFTOWER
#SBATCH --time=160:00:00
##SBATCH --partition=bigmem
##SBATCH --ntasks=16 --cpus-per-task=4
##SBATCH --mem-per-cpu=32G
#SBATCH --ntasks=1 --cpus-per-task=5
#SBATCH --mem-per-cpu=8G
#SBATCH --mail-user=animesh.sharma@ntnu.no
#SBATCH --mail-type=ALL
#SBATCH --output=NFTOWER

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
echo "Total of $SLURM_NTASKS cores"i
export TOWER_ACCESS_TOKEN=$TOWER_ACCESS_TOKEN ##set before
nextflow run https\://github.com/nf-core/differentialabundance -name slurm2_saga -params-file nextflow.json -with-tower -r 1.4.0 -profile singularity
#https://tower.nf/user/ash022/watch/25Mu8FLkCpsEwr

