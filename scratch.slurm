#!/bin/sh
#SBATCH --account=nn9036k --job-name=mDIA
#SBATCH --time=292:00:00
#SBATCH --partition=bigmem
#SBATCH --ntasks=1 --cpus-per-task=32
#SBATCH --mem-per-cpu=8G
#SBATCH --mail-user=animesh.sharma@ntnu.no
#SBATCH --mail-type=ALL
#SBATCH --output=mDIALog
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
module --ignore-cache load MaxQuant/2.5.2.0 
dotnet --version
#dusage 
#cd /cluster/work/users/ash022/mDIA
#rsync -Parv  ash022@login.nird-lmd.sigma2.no:TIMSTOF/Raw/LARS/240222_DIA/240222_Kamilla_Maike_*dia*d .
#wget "https://datashare.biochem.mpg.de/s/qe1IqcKbz2j2Ruf/download?path=%2FDiscoveryLibraries&files=mus_musculus.zip"
#unzip download\?path\=%2FDiscoveryLibraries\&files\=mus_musculus.zip 
#mv mus_musculus/* .
#cp /cluster/home/ash022/scripts/mqpar.xml .
#cp /cluster/home/ash022/scripts/scratch.slurm  .
maxquantcmd -n mqpar.xml
maxquantcmd mqpar.xml
