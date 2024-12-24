#!/bin/sh
#SBATCH --account=nn9036k --job-name=procDIANN
#SBATCH --time=24:00:00
##SBATCH --partition=bigmem
#SBATCH --ntasks=1 --cpus-per-task=10
#SBATCH --mem-per-cpu=4G
#SBATCH --mail-user=animesh.sharma@ntnu.no
#SBATCH --mail-type=ALL
#SBATCH --output=logDIANN

#wget https://github.com/vdemichev/DiaNN/releases/download/1.9.2/diann-1.9.2.Linux.zip
#unzip diann-1.9.2.Linux.zip
#chmod +x diann-linux

cd /cluster/projects/nn9036k/diann-1.9.2
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
module load GCCcore/13.3.0
#wget https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/reference_proteomes/Eukaryota/UP000005640/UP000005640_9606.fasta.gz
#gunzip UP000005640_9606.fasta.gz
#mv UP000005640_9606.fasta UP000005640_9606_unique_gene.fasta
#wget https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/reference_proteomes/Eukaryota/UP000087266/UP000087266_8030.fasta.gz
#gunzip UP000087266_8030.fasta.gz
#mv UP000087266_8030.fasta UP000087266_8030_unique_gene.fasta
#cat UP000005640_9606_unique_gene.fasta UP000087266_8030_unique_gene.fasta > /cluster/projects/nn9036k/FastaDB/UP000005640_9606_UP000087266_8030_unique_gene.fasta
#grep "^>" /cluster/projects/nn9036k/FastaDB/UP000005640_9606_UP000087266_8030_unique_gene.fasta | wc #  68960  763398 7700217
#./diann-linux --threads 20 --verbose 1 --out "/cluster/projects/nn9036k/FastaDB/UP000005640_9606_UP000087266_8030_unique_gene_MC0_L35_C57_vMod0.report.tsv" --gen-spec-lib --predictor --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --fasta "/cluster/projects/nn9036k/FastaDB/UP000005640_9606_UP000087266_8030_unique_gene.fasta" --fasta-search  --unimod4 --max-pep-len 35 --missed-cleavages 0
#[0:33] 4270041 precursors generated
#[0:32] Library contains 68890 proteins, and 66271 genes
./diann-linux --f "inDIANN" --lib "/cluster/projects/nn9036k/FastaDB/UP000005640_9606_UP000087266_8030_unique_gene_MC1_L35_C57_vMod3_MZ117.report-lib.predicted.speclib" --threads 40 --verbose 1 --out "outDIANN" --qvalue 0.01 --matrices  --min-corr 2.0 --corr-diff 1.0 --time-corr-only --extracted-ms1 --reannotate --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP- --fasta "/cluster/projects/nn9036k/FastaDB/UP000005640_9606_UP000087266_8030_unique_gene.fasta" --met-excision --min-pep-len 7 --max-pep-len 35 --min-pr-mz 100 --max-pr-mz 1700 --min-pr-charge 2 --max-pr-charge 4 --cut K*,R* --missed-cleavages 1 --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:1,42.010565,*n --individual-mass-acc --individual-windows --peptidoforms --rt-profiling --direct-quant --no-norm

