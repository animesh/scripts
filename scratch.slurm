#!/bin/sh
#SBATCH --account=nn9036k --job-name=240319Nico
#SBATCH --time=292:00:00
#SBATCH --partition=bigmem
#SBATCH --ntasks=1 --cpus-per-task=32
#SBATCH --mem-per-cpu=8G
#SBATCH --mail-user=animesh.sharma@ntnu.no
#SBATCH --mail-type=ALL
#SBATCH --output=240319NicolaLog
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
#wget "https://rest.uniprot.org/uniprotkb/stream?format=fasta&includeIsoform=true&query=%28%28proteome%3AUP000005640%29%29" -O /cluster/projects/nn9036k/FastaDB/uniprot-human-iso-jan24.fasta
dotnet /cluster/projects/nn9036k/MaxQuant_v2.4.14.0/bin/MaxQuantCmd.exe  /cluster/projects/nn9036k/scripts/mqpar.xml
#cp mqpar.xml 20240127_PRPF31_DevelopmentalStudy/mqpar.lin.xml
#sbatch scratch.slurm 
