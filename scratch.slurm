#!/bin/sh
#SBATCH --account=nn9036k --job-name=sigr
#SBATCH --time=144:00:00
##SBATCH --partition=bigmem
##SBATCH --ntasks=16 --cpus-per-task=4
##SBATCH --mem-per-cpu=32G
#SBATCH --ntasks=4 --cpus-per-task=10 --ntasks-per-node=4
##--ntasks=4 --cpus-per-task=10 --ntasks-per-node=4
#SBATCH --mem-per-cpu=4G
#SBATCH --mail-user=animesh.sharma@ntnu.no
#SBATCH --mail-type=ALL
#SBATCH --output=sigrMQSLURMLOG


WORKDIR=/cluster/projects/nn9036k/scripts/sigrid
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

module purge
module load MaxQuant/1.6.17.0-foss-2019b
mono --version
module load dotNET-SDK/3.1.300-linux-x64
dotnet --version

dotnet /cluster/projects/nn9036k/MaxQuant_v2.3.1.0/bin/MaxQuantCmd.exe  -p 20 /cluster/projects/nn9036k/scripts/sigrid/mqpar.linux.xml
#mono MQCMD -p MQPARF
#mono MQCMD -n MQPARF
