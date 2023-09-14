#!/bin/sh
#SBATCH --account=nn9036k --job-name=S3517
#SBATCH --time=164:00:00
##SBATCH --partition=bigmem
#SBATCH --ntasks=4 --cpus-per-task=10
#SBATCH --mem-per-cpu=4G
#SBATCH --mail-user=animesh.sharma@ntnu.no
#SBATCH --mail-type=ALL
#SBATCH --output=S35MQSLURMLOG


WORKDIR=/cluster/home/ash022/scripts/S35-2/
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
module --ignore-cache load MaxQuant/2.4.0.0-GCCcore-11.2.0
mono --version
module --ignore-cache load dotNET-SDK/3.1.300-linux-x64
dotnet --version

dotnet /cluster/projects/nn9036k/MaxQuant_v2.4/bin/MaxQuantCmd.exe -p 13 /cluster/projects/nn9036k/scripts/S35-2/mqpar.linux.xml
#mono MQCMD -p MQPARF
#mono MQCMD -n MQPARF
