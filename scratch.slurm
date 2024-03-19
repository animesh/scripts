#!/bin/sh
#SBATCH --account=nn9036k --job-name=DDAtest
#SBATCH --time=164:00:00
#SBATCH --partition=bigmem
#SBATCH --ntasks=1 --cpus-per-task=32
#SBATCH --mem-per-cpu=8G
#SBATCH --mail-user=animesh.sharma@ntnu.no
#SBATCH --mail-type=ALL
#SBATCH --output=DDAtestLog
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
#https://www.uniprot.org/proteomes/UP000000589
#wget "https://rest.uniprot.org/uniprotkb/stream?format=fasta&includeIsoform=true&query=%28%28proteome%3AUP000000589%29%29" -O /cluster/projects/nn9036k/FastaDB/uniprot-mouse-iso-mar24.fasta
#grep "^>" /cluster/projects/nn9036k/FastaDB/uniprot-mouse-iso-mar24.fasta | wc
#  63191  729185 6766475
dotnet /cluster/projects/nn9036k/MaxQuant_v2.4.14.0/bin/MaxQuantCmd.exe -p 19 /cluster/projects/nn9036k/scripts/mqpar.xml
#git diff
#cp mqpar.xml 240222_DIA/DIA_library/mqpar.linux.xml
#sbatch scratch.slurm 
#tail -f DIAlibLog
