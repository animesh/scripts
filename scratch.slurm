#!/bin/sh
#SBATCH --account=nn9036k --job-name=MQ220610NILU
#SBATCH --partition=bigmem
#SBATCH --time=168:00:00
#SBATCH --ntasks=16 --cpus-per-task=4
##SBATCH --ntasks=10 --cpus-per-task=4
#SBATCH --mem-per-cpu=16G
##SBATCH --mem-per-cpu=4G
#SBATCH --mail-user=animesh.sharma@ntnu.no
#SBATCH --mem-per-cpu=8G
#SBATCH --mail-type=ALL
#SBATCH --output=srunMQ.out


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

module purge
module load MaxQuant/1.6.17.0-foss-2019b
mono --version
module load dotNET-SDK/3.1.300-linux-x64
dotnet --version

#mono /cluster/projects/nn9036k/MaxQuant_2.0.3.1/bin/MaxQuantCmd.exe  /cluster/projects/nn9036k/scripts/mqpar.saga.xml
mono /cluster/projects/nn9036k/MaxQuant_2.0.3.1/bin/MaxQuantCmd.exe -p 30 /cluster/projects/nn9036k/scripts/mqpar.saga.xml
