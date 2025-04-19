#!/bin/sh
#SBATCH --account=nn9036k --job-name=TestFile.d.jobName
#SBATCH --time=160:00:00
##SBATCH --partition=bigmem
#SBATCH --ntasks=1 --cpus-per-task=20
#SBATCH --mem-per-cpu=8G
#SBATCH --mail-user=animesh.sharma@ntnu.no
#SBATCH --mail-type=ALL
#SBATCH --output=TestFile.d.logDIANNhistmetacet
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
./diann-linux --f "TestFile.d" --lib "/cluster/home/ash022/scripts/acet/UP000005640_9606_unique_gene.met.acet.fixprop.report-lib.predicted.speclib"   --threads 80 --verbose 1 --out "TestFile.d.met.acet.report.parquet" --qvalue 0.01 --matrices  --out-lib "TestFile.d.met.acet.fixprop.lib.parquet"  --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP- --fasta UP000005640_9606_unique_gene.fasta --min-fr-mz 200 --max-fr-mz 1800 --met-excision --min-pep-len 7 --max-pep-len 35 --min-fr-mz 300 --max-fr-mz 1800 --met-excision --min-pep-len 7 --max-pep-len 35 --min-pr-mz 300 --max-pr-mz 1800 --min-pr-charge 2 --max-pr-charge 4 --cut K*,R* --missed-cleavages 2 --unimod4 ‐‐fixed‐mod UniMod:58,56.026215,n --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:1,42.010565,K --var-mod UniMod:209,112.052430,K --var-mod UniMod:34,14.015650,K --var-mod UniMod:36,28.031300,K --var-mod UniMod:37,42.046950,K --mass-acc 15 --mass-acc-ms1 15 --proteoforms  --no-cut-after-mod UniMod:58 --rt-profiling
