#!/bin/sh
#SBATCH --account=nn9036k --job-name=elite
#SBATCH --time=128:00:00
#SBATCH --mem-per-cpu=4G
#SBATCH --ntasks=1 --cpus-per-task=4 --ntasks-per-node=1
#SBATCH --mail-user=animesh.sharma@ntnu.no
#SBATCH --mail-type=ALL
#SBATCH --output=elite.out

 
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

$HOME/gopath/bin/drive push  --no-prompt -force -verbose /trd-project1/NS9036K/NORSTORE_OSL_DISK/NS9036K/promec/promec/Elite/

