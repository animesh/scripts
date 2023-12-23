#!/bin/sh
#SBATCH --account=nn9036k --job-name=MQSLURMNAME
#SBATCH --time=160:00:00
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
#git checkout 7053ec54f24e12b678835a9131656ec0d1d2185d scratch.slurm
#cat scratch.slurm
#dos2unix scratch.slurm
#bash slurmMQrunTTP.sh /cluster/projects/nn9036k/MaxQuant_2.4.3.0/bin/MaxQuantCmd.exe /cluster/projects/nn9036k/scripts/231123_dia_dda/DIA /cluster/projects/nn9036k/FastaDB mqparTTPdia.xml scratch.slurm
#bash slurmMQrunTTP.sh /cluster/projects/nn9036k/MaxQuant_2.4.3.0/bin/MaxQuantCmd.exe /cluster/projects/nn9036k/scripts/231123_dia_dda/DDA /cluster/projects/nn9036k/FastaDB mqparTTPdda.xml scratch.slurm
#bash slurmMQrunTTP.sh /cluster/projects/nn9036k/MaxQuant_v_2.4.10.0/bin/MaxQuantCmd.exe /cluster/projects/nn9036k/scripts/231123_dia_dda/DIA /cluster/projects/nn9036k/FastaDB mqparTTPdia.xml scratch.slurm
#bash slurmMQrunTTP.sh /cluster/projects/nn9036k/MaxQuant_v_2.4.10.0/bin/MaxQuantCmd.exe /cluster/projects/nn9036k/scripts/231123_dia_dda/DDA /cluster/projects/nn9036k/FastaDB mqparTTPdda.xml scratch.slurm
#bash slurmMQrunTTP.sh /cluster/projects/nn9036k/MaxQuant_v_2.4.9.0/bin/MaxQuantCmd.exe /cluster/projects/nn9036k/scripts/231123_dia_dda/DIA /cluster/projects/nn9036k/FastaDB mqparTTPdia.xml scratch.slurm
#bash slurmMQrunTTP.sh /cluster/projects/nn9036k/MaxQuant_v_2.4.9.0/bin/MaxQuantCmd.exe /cluster/projects/nn9036k/scripts/231123_dia_dda/DDA /cluster/projects/nn9036k/FastaDB mqparTTPdda.xml scratch.slurm
#tail -f mqparTTPd?a.xml.*.results/*/*txt

