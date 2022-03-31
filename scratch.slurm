#!/bin/sh
##SBATCH --partition=bigmem
#SBATCH --account=nn9036k --job-name=MQ40
<<<<<<< HEAD
##SBATCH --account=nn9036k --job-name=MQ64BM
=======
##SBATCH --account=nn9036k --job-name=MQ40BM
>>>>>>> 2a377b3d1c694272c8a6d4fa8f8959520adb4036
#SBATCH --time=120:00:00
#SBATCH --mem-per-cpu=4G
#SBATCH --mail-user=animesh.sharma@ntnu.no
#SBATCH --ntasks=4 --cpus-per-task=10 --ntasks-per-node=4
##SBATCH --ntasks=1 --cpus-per-task=16 --ntasks-per-node=4
#SBATCH --mail-type=ALL
<<<<<<< HEAD
#SBATCH --output=out.slurm
##SBATCH --output=outBM.slurm
=======
#SBATCH --output=srunMQ40BM.out
>>>>>>> 2a377b3d1c694272c8a6d4fa8f8959520adb4036

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
<<<<<<< HEAD
#mono /cluster/home/ash022/MaxQuant_2.0.3.1/bin/MaxQuantCmd.exe -n /cluster/home/ash022/cluster/scripts/mqpar.saga.xml
mono /cluster/home/ash022/MaxQuant_2.0.3.1/bin/MaxQuantCmd.exe /cluster/home/ash022/cluster/scripts/mqpar.saga.xml
=======
#mono /cluster/projects/nn9036k/MaxQuant_2.0.3.0/bin/MaxQuantCmd.exe /cluster/home/ash022/cluster/Mirta/mqpar.xml
mono /cluster/projects/nn9036k/MaxQuant_2.0.3.0/bin/MaxQuantCmd.exe -p 6 /cluster/home/ash022/cluster/Mirta/mqpar.xml
>>>>>>> 2a377b3d1c694272c8a6d4fa8f8959520adb4036
