#!/bin/sh
##SBATCH --partition=bigmem
#SBATCH --account=nn9036k --job-name=QIRseqRNA
##SBATCH --account=nn9036k --job-name=QIRseqRNABM
#SBATCH --time=1:00:00
#SBATCH --mail-user=animesh.sharma@ntnu.no
##SBATCH --ntasks=1 --cpus-per-task=16 --ntasks-per-node=4
##SBATCH --mem-per-cpu=16G
#SBATCH --ntasks=1 --cpus-per-task=NCPU
#SBATCH --mem-per-cpu=1G
#SBATCH --mail-type=ALL
#SBATCH --output=OUTDIRlog

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
module load Qualimap/2.3-foss-2022b-R-4.2.2
qualimap --java-mem-size=NCPUG rnaseq -a uniquely-mapped-reads -bam SORTBAMFILE -gtf /cluster/projects/nn9036k/scripts/hg38v110star/Homo_sapiens.GRCh38.110.gtf -outdir OUTDIR -oc counts.txt -outformat PDF:HTML -p non-strand-specific  -pe -s -outfile report.rnaseq.hg38.gtf110.NCPU.pe.nonstrand.pdf


