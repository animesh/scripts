#!/bin/sh
#SBATCH --account=nn9036k --job-name=TestFile.d.WRITEFILE.BM
##SBATCH --partition=bigmem
#SBATCH --ntasks=1 --cpus-per-task=10
#SBATCH --mem-per-cpu=8G
#SBATCH --time=4:00:00
#SBATCH --mail-user=animesh.sharma@ntnu.no
#SBATCH --mail-type=ALL
#SBATCH --output=TestFile.d.WRITEFILE.log
cd /cluster/projects/nn9036k/diann-2.1.0/
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
#./diann-linux --lib "" --threads 40 --verbose 1 --out "/cluster/projects/nn9036k/FastaDB/UP000005640_9606_unique_gene_C24_MC2_P735_MZ2001800_Mod3.WRITEFILE.parquet" --qvalue 0.01 --matrices  --out-lib "/cluster/projects/nn9036k/FastaDB/UP000005640_9606_unique_gene_C24_MC2_P735_MZ2001800_Mod3.WRITEFILE.predicted.speclib" --gen-spec-lib --predictor --reannotate --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP- --fasta UP000005640_9606_unique_gene.fasta --fasta-search --met-excision --min-pep-len 7 --max-pep-len 35  --min-pr-mz 300  --max-pr-mz 1800  --min-fr-mz 200 --max-fr-mz 1800  --min-pr-charge 2 --max-pr-charge 4 --cut K*,R* --missed-cleavages 2 --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:1,42.010565,*n --mass-acc 15 --mass-acc-ms1 15 --peptidoforms --rt-profiling --high-acc
./diann-linux --f "TestFile.d" --lib "/cluster/projects/nn9036k/FastaDB/UP000005640_9606_unique_gene_C24_MC2_P735_MZ2001800_Mod3.1745847376.report.predicted.predicted.speclib" --threads 40 --verbose 1 --out "TestFile.d.WRITEFILE.oxM.acetN.report.parquet" --qvalue 0.01 --matrices  --out-lib "TestFile.d.WRITEFILE.oxM.acetN.fixcys.lib.parquet"  --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP- --fasta UP000005640_9606_unique_gene.fasta  --met-excision --min-pep-len 7 --max-pep-len 35 --min-pr-mz 300  --max-pr-mz 1800  --min-fr-mz 200 --max-fr-mz 1800  --min-pr-charge 2 --max-pr-charge 4 --cut K*,R* --missed-cleavages 2 --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:1,42.010565,*n --mass-acc 15 --mass-acc-ms1 15 --peptidoforms --rt-profiling --high-acc
#dos2unix slurmDIANN.sh scratch.slurm

