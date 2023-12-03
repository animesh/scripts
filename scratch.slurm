#!/bin/sh
#SBATCH --account=nn9036k --job-name=MQSLURMNAME
#SBATCH --time=24:00:00
##SBATCH --partition=bigmem
##SBATCH --ntasks=16 --cpus-per-task=4
##SBATCH --mem-per-cpu=32G
#SBATCH --ntasks=1 --cpus-per-task=5
#SBATCH --mem-per-cpu=8G
#SBATCH --mail-user=animesh.sharma@ntnu.no
#SBATCH --mail-type=ALL
#SBATCH --output=MQSLURMLOG
WORKDIR=MQWD
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
module load dotNET-SDK/3.1.300-linux-x64
dotnet --version
dotnet MQCMD MQPARF


#rsync -Parv login.nird-lmd.sigma2.no:PD/TIMSTOF/LARS/2023/231123_dia_dda/*.d 231123_dia_dda/DIA/.
#for i in mqparTTPdia.xml.1701590929.results/*/*.slurm; do echo $i; grep "1G" $i ; sed -i  's/1G/8G/' $i; grep "8G" $i;  sbatch $i; done
