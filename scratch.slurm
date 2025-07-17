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
#https://nf-co.re/sarek/usage#how-can-the-different-steps-be-used
./nextflow run nf-core/sarek -profile singularity --input ./results/csv/variantcalled.csv --outdir ./results --genome GATK.GRCh38 --tools snpeff,vep --step annotate -resume
#--max_memory '256.GB' --max_cpus 128 
#https://academic.oup.com/nargab/article/6/2/lqae031/7658070#460158048:~:text=Listing%204%3A%20Variant%20calling
#--tools strelka,freebayes,ascat,controlfreec,cnvkit,manta,tiddit,msisensorpro #mutect2 needs tumor-sample and normal-sample columns in the input file
#tail -f sarekTK.out 
#git config --global --edit
#git config --add --global core.filemode false
#[core]
#        filemode = true
#file:/cluster/projects/nn9036k/.nextflow/assets/nf-core/sarek
#./tw-agent c18e698f-8a30-4555-9cfc-4d27ce21a7ec  --work-dir=./work
# ls results/variant_calling/haplotypecaller/
#ls -ltrh results/reports/snpeff/haplotypecaller/ | wc
#     31     272    1966
#ls -ltrh results/reports/EnsemblVEP/haplotypecaller/ | wc
#     31     272    1966
