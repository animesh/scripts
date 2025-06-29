#!/bin/sh
#SBATCH --account=nn9036k --job-name=sarekTK
#SBATCH --partition=bigmem
#SBATCH --ntasks=1 --cpus-per-task=32
#SBATCH --mem-per-cpu=8G
#SBATCH --time=160:00:00
#SBATCH --mail-user=animesh.sharma@ntnu.no
#SBATCH --mail-type=ALL
#SBATCH --output=sarekTK.out
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
module load Java/21.0.2
java --version
#awk -F '_|,' '{print $1}' samples.csv > pat.txt
#sed -i 's|sample|patient|' pat.txt
#paste -d ',' pat.txt samples.csv > samples2.csv
#seq 1 30 >> lan.txt
#paste -d ','  lan.txt samples2.csv  > samples.csv
#curl -s https://get.nextflow.io | bash
./nextflow run nf-core/sarek  -profile singularity --input ./samples.csv --outdir ./results --genome GATK.GRCh38
#tail -f sarekTK.out 
