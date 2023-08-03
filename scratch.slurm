#!/bin/sh
##SBATCH --partition=bigmem
#SBATCH --account=nn9036k --job-name=starBAMQISLURMJOB
##SBATCH --account=nn9036k --job-name=SLURMJOBBM
#SBATCH --time=48:00:00
#SBATCH --mail-user=animesh.sharma@ntnu.no
##SBATCH --ntasks=1 --cpus-per-task=16 --ntasks-per-node=4
##SBATCH --mem-per-cpu=16G
#SBATCH --ntasks=1 --cpus-per-task=10
#SBATCH --mem-per-cpu=4G
#SBATCH --mail-type=ALL
#SBATCH --output=QIlog

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

export http_proxy=proxy.saga:3128
export https_proxy=proxy.saga:3128

module purge
module load  Qualimap/2.3-foss-2022b-R-4.2.2 

#git checkout 81a692e86fe29617d94bd49ea883542229fbfb94 slurmQI.sh scratch.slurm
#dos2unix slurmQI.sh scratch.slurm
#ls -1 $PWD/TK/star.1691068198.results/*sort*.bam > bamFP
#cat bamFP  | awk -F '/' '{print $8}' | awk -F '.' '{print $1}' > sampleName
#cat sampleName | awk -F '_' '{print $1}' > groupName
#paste sampleName bamFP groupName > TK/dataTK.qi.star.t2t.list


qualimap --java-mem-size=40G multi-bamqc -r -d $PWD/TK/dataTK.qi.star.t2t.list -gff $PWD/CHM13v2-T2T/GCF_009914755.1_T2T-CHM13v2.0_genomic.gtf -outdir $PWD/TK/multibamqcSTARslurmT2T -outformat PDF:HTML

