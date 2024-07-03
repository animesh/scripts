#!/bin/sh
#SBATCH --account=nn9036k --job-name=veronica
#SBATCH --time=292:00:00
#SBATCH --partition=bigmem
#SBATCH --ntasks=1 --cpus-per-task=32
#SBATCH --mem-per-cpu=8G
#SBATCH --mail-user=animesh.sharma@ntnu.no
#SBATCH --mail-type=ALL
#SBATCH --output=veronicaLog
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
module --ignore-cache load MaxQuant/2.4.0.0-GCCcore-11.2.0
mono --version
module load dotNET-SDK/3.1.300-linux-x64
dotnet --version
#dusage 
#cd /cluster/work/users/ash022/veronica
#rsync -Parv ash022@login1.nird-lmd.sigma2.no:TIMSTOF/LARS/2024/240605_Veronica/*.d .
#rsync -Parv ash022@login1.nird-lmd.sigma2.no:TIMSTOF/LARS/2024/240605_Veronica/mqpar.xml .
#rsync -Parv ash022@login1.nird-lmd.sigma2.no:PD/FastaDB/UP000000589_10090*fasta .
#wget "https://datashare.biochem.mpg.de/s/qe1IqcKbz2j2Ruf/download?path=%2FDiscoveryLibraries&files=mus_musculus.zip"
#unzip download\?path\=%2FDiscoveryLibraries\&files\=mus_musculus.zip 
#mv mus_musculus/* .
maxquantcmd -n mqpar.xml
maxquantcmd  mqpar.xml

