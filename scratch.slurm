#!/bin/sh
#SBATCH --account=nn9036k --job-name=mitra
#SBATCH --time=292:00:00
#SBATCH --partition=bigmem
#SBATCH --ntasks=1 --cpus-per-task=16
#SBATCH --mem-per-cpu=32G
#SBATCH --mail-user=animesh.sharma@ntnu.no
#SBATCH --mail-type=ALL
#SBATCH --output=mitraLog
WORKDIR=$PWD
cd ${WORKDIR}
echo "we are running from this directory: $SLURM_SUBMIT_DIR"
echo " the name of the job is: $SLURM_JOB_NAME"
echo "Th job ID is $SLURM_JOB_ID"
echo "The job was run on these nodes: $SLURM_JOB_NODELIST"
echo "Number of nodes: $SLURM_JOB_NUM_NODES"
echo "We are using $SLURM_CPUS_ON_NODE cores"
echo "We are using $SLURM_CPUS_ON_NODE cores per node"
echo "Total of $SLURM_NTASKS cores"
export LMOD_DISABLE_SAME_NAME_AUTOSWAP=no
module load Boost/1.83.0-GCC-13.2.0
/cluster/projects/nn9036k/dotnet80303/dotnet --version
#dusage
#cd /cluster/projects/nn9036k/whale
#rsync -Parv ash022@login1.nird-lmd.sigma2.no:TIMSTOF/LARS/2024/240819_Mitra/*M*.d .
#rsync -Parv ash022@login1.nird-lmd.sigma2.no:TIMSTOF/LARS/2024/240819_Mitra/*.fasta .
#rsync -Parv ash022@login1.nird-lmd.sigma2.no:TIMSTOF/LARS/2024/240819_Mitra/*.xml .
/cluster/projects/nn9036k/dotnet80303/dotnet -n /cluster/projects/nn9036k/MaxQuant_v2.6.3.0/bin/MaxQuantCmd.dll -n mqpar.xml
/cluster/projects/nn9036k/dotnet80303/dotnet /cluster/projects/nn9036k/MaxQuant_v2.6.3.0/bin/MaxQuantCmd.dll mqpar.xml
#/cluster/projects/nn9036k/dotnet80303/dotnet /cluster/projects/nn9036k/MaxQuant_v2.6.3.0/bin/MaxQuantCmd.dll -p mqpar.xml
