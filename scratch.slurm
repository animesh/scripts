#!/bin/sh
#SBATCH --account=nn9036k --job-name=HG38diffExpr
#SBATCH --time=48:00:00
##SBATCH --partition=bigmem
#SBATCH --ntasks=1 --cpus-per-task=20
#SBATCH --mem-per-cpu=4G
#SBATCH --mail-user=animesh.sharma@ntnu.no
#SBATCH --mail-type=ALL
#SBATCH --output=HG38diffExpr

#cd /cluster/home/ash022/scripts/TK
WORKDIR=$PWD
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
module load Miniconda3/22.11.1-1
#conda config --prepend channels bioconda
#conda config --show channels
#mamba install python=3.11 nf-core nextflow
#nf-core create
#cd nf-core-spritz/
#git checkout dev
#git remote add origin https://github.com/animesh/spritz_nf.git
#git push --all origin
#ln -s /cluster/projects/nn9036k/scripts/TK9/*.gz .
#vim samples.csv
conda activate nf-core
nextflow  -v
nextflow  self-update
nextflow  -v
#nextflow run hello
#nextflow pull nf-core/rnaseq
#nextflow run nf-core/rnaseq  --max_memory '256.GB' --max_cpus 32  --outdir nfch13all --input samples.csv --genome CHM13 -profile singularity -resume
#nextflow run nf-core/rnaseq  --max_memory '256.GB' --max_cpus 30  --outdir CH13lall --input samples.csv --gtf /cluster/projects/nn9036k/scripts/CHM13v2-T2T/GCF_009914755.1_T2T-CHM13v2.0_genomic.gtf --fasta /cluster/projects/nn9036k/scripts/CHM13v2-T2T/GCF_009914755.1_T2T-CHM13v2.0_genomic.fna  --genome null  --igenomes_ignore  -profile singularity -resume
#nextflow run nf-core/differentialabundance -profile test,singularity --outdir testFiddExpr
#https://nf-co.re/rnaseq/3.13.2/docs/usage -r <pipeline version eg 1.3.1> for Reproducibility
#nextflow run nf-core/differentialabundance  --max_memory '80.GB' --max_cpus 20  --input samples.csv --contrasts contrasts.csv --matrix hg38lall/star_salmon/salmon.merged.gene_counts_length_scaled.tsv --gtf /cluster/projects/nn9036k/scripts/hg38v110/Homo_sapiens.GRCh38.110.gtf  -profile test,singularity --outdir testFiddExpr
nextflow run nf-core/differentialabundance  --max_memory '80.GB' --max_cpus 20  --input samples.csv --contrasts contrasts.csv --matrix hg38lall/star_salmon/salmon.merged.gene_counts_length_scaled.tsv --gtf /cluster/projects/nn9036k/scripts/hg38v110/Homo_sapiens.GRCh38.110.gtf  -profile singularity --outdir diffExprHG38lall

#rsync -Parv  login.nird-lmd.sigma2.no:PD/Animesh/TK/TK9R/*gz .
#rename  'R1.fastq.gz' '_1.fq.gz' *
#rename  'R2.fastq.gz' '_2.fq.gz' *
#ls -1 *2.fq.gz  > S2
#ls -1 *1.fq.gz  > S1
#printf 'auto\n%.0s' {1..30} > S3
#ls -1 *_1.fq.gz | awk -F '_' '{print $1$2$5}' > S0
#echo "sample,fastq_1,fastq_2,strandedness" > samples.csv
#paste -d ','  S? >> samples.csv
#cat samples.csv
#mv diffExprHG38lall diffExprHG38lallBatch
#ls -ltrh diffExprHG38lall*/tables/diff*
