#!/bin/sh
#SBATCH --account=nn9036k --job-name=brenn
#SBATCH --time=160:00:00
##SBATCH --partition=bigmem
#SBATCH --ntasks=1 --cpus-per-task=7
#SBATCH --mem-per-cpu=8G
#SBATCH --mail-user=animesh.sharma@ntnu.no
#SBATCH --mail-type=ALL
#SBATCH --output=brennLog
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
module purge
#mkdir /cluster/projects/nn9036k/dotnet80303
#cd /cluster/projects/nn9036k/dotnet80303
#wget https://download.visualstudio.microsoft.com/download/pr/60218cc4-13eb-41d5-aa0b-5fd5a3fb03b8/6c42bee7c3651b1317b709a27a741362/dotnet-sdk-8.0.303-linux-x64.tar.gz
#tar xvzf dotnet-sdk-8.0.303-linux-x64.tar.gz
/cluster/projects/nn9036k/dotnet80303/dotnet --version
#mkdir /cluster/projects/nn9036k/Brent
#cd /cluster/projects/nn9036k/Brent
#rsync -Parv   ash022@login.nird-lmd.sigma2.no:PD/Animesh/Brent/*.d .
#rsync -Parv   ash022@login.nird-lmd.sigma2.no:PD/Animesh/Brent/*.xml .
#rsync -Parv   ash022@login.nird-lmd.sigma2.no:PD/Animesh/Brent/*.fasta .
/cluster/projects/nn9036k/dotnet80303/dotnet /cluster/projects/nn9036k/MaxQuant_v2.6.3.0/bin/MaxQuantCmd.dll -n /cluster/projects/nn9036k/Brent/mqpar.linux.xml
/cluster/projects/nn9036k/dotnet80303/dotnet /cluster/projects/nn9036k/MaxQuant_v2.6.3.0/bin/MaxQuantCmd.dll  /cluster/projects/nn9036k/Brent/mqpar.linux.xml
