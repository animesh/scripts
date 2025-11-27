#!/bin/sh
#SBATCH --account=nn9036k --job-name=TK9match
##SBATCH --partition=bigmem
#SBATCH --ntasks=1 --cpus-per-task=20
#SBATCH --mem-per-cpu=2G
#SBATCH --time=12:00:00
#SBATCH --mail-user=animesh.sharma@ntnu.no
#SBATCH --mail-type=ALL
#SBATCH --output=TK9match.log
#rsync -Parv /home/animeshs/promec/fastq  ash022@login.saga.sigma2.no:/cluster/projects/nn9036k/TK/sra
module load parallel/20240322-GCCcore-13.2.0
cd /cluster/projects/nn9036k/scripts/
echo "we are running from this directory: $SLURM_SUBMIT_DIR"
echo " the name of the job is: $SLURM_JOB_NAME"
echo "Th job ID is $SLURM_JOB_ID"
echo "The job was run on these nodes: $SLURM_JOB_NODELIST"
echo "Number of nodes: $SLURM_JOB_NUM_NODES"
echo "We are using $SLURM_CPUS_ON_NODE cores"
echo "We are using $SLURM_CPUS_ON_NODE cores per node"
echo "Total of $SLURM_NTASKS cores"
#https://trace.ncbi.nlm.nih.gov/Traces/?view=run_browser&acc=SRR31089076&display=data-access
bash compareFastq.sh "/cluster/projects/nn9036k/TK/TK9*__*.fq.gz" "/cluster/projects/nn9036k/TK/sra/fastq/SRR31089076"
#https://trace.ncbi.nlm.nih.gov/Traces/?view=run_browser&acc=SRR31089075&display=data-access
#bash compareFastq.sh "/cluster/projects/nn9036k/TK/TK10_??_*.fq.gz" "/cluster/projects/nn9036k/TK/sra/fastq/SRR31089075"
#https://trace.ncbi.nlm.nih.gov/Traces/?view=run_browser&acc=SRR31089074&display=data-access
#bash compareFastq.sh "/cluster/projects/nn9036k/TK/TK12_R*_*.fq.gz" "/cluster/projects/nn9036k/TK/sra/fastq/SRR31089074"
#https://trace.ncbi.nlm.nih.gov/Traces/?view=run_browser&acc=SRR31089073&display=data-access
#bash compareFastq.sh "/cluster/projects/nn9036k/TK/TK13*_*_*.fq.gz" "/cluster/projects/nn9036k/TK/sra/fastq/SRR31089073"
#https://trace.ncbi.nlm.nih.gov/Traces/?view=run_browser&acc=SRR31089072&display=data-access
#bash compareFastq.sh "/cluster/projects/nn9036k/TK/TK14*_*_*.fq.gz" "/cluster/projects/nn9036k/TK/sra/fastq/SRR31089072"
#https://trace.ncbi.nlm.nih.gov/Traces/?view=run_browser&acc=SRR31089071&display=data-access
#bash compareFastq.sh "/cluster/projects/nn9036k/TK/TK16*_*_*.fq.gz" "/cluster/projects/nn9036k/TK/sra/fastq/SRR31089071"
#https://trace.ncbi.nlm.nih.gov/Traces/?view=run_browser&acc=SRR31089070&display=data-access
#bash compareFastq.sh "/cluster/projects/nn9036k/TK/TK18*_*_*.fq.gz" "/cluster/projects/nn9036k/TK/sra/fastq/SRR31089070"
echo "Job finished"

