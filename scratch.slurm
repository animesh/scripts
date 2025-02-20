#!/bin/sh
#SBATCH --account=nn9036k --job-name=histmetacetDIANN
#SBATCH --time=160:00:00
##SBATCH --partition=bigmem
#SBATCH --ntasks=1 --cpus-per-task=20
#SBATCH --mem-per-cpu=8G
#SBATCH --mail-user=animesh.sharma@ntnu.no
#SBATCH --mail-type=ALL
#SBATCH --output=logDIANNhistmetacet

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
#cp  $HOME/PD/TIMSTOF/LARS/2025/250213_HistonePTM/250213_H1_DDA_Slot1-19_1_9546.d.FPv22/250213_H1_DDA_Slot1_19_1_9546/protein.fas /cluster/projects/nn9036k/FastaDB/selectFP.UP000005640_9606_unique_gene.fasta
./diann-linux --f "/cluster/home/ash022/scripts/hismet/250213_H1_DIA_Slot1-19_1_9548.d" --lib "" --threads 80 --verbose 1 --out "/cluster/home/ash022/scripts/hismet/prop.acro.met.acet.report.parquet" --qvalue 0.01 --matrices  --out-lib "/cluster/home/ash022/scripts/hismet/prop.acro.met.acet.lib.parquet" --gen-spec-lib --predictor --fasta "/cluster/projects/nn9036k/FastaDB/selectFP.UP000005640_9606_unique_gene.fasta" --fasta-search --min-fr-mz 100 --max-fr-mz 1700 --met-excision --min-pep-len 7 --max-pep-len 30 --min-pr-mz 100 --max-pr-mz 1700 --min-pr-charge 1 --max-pr-charge 4 --cut K*,R* --missed-cleavages 2 --unimod4 --var-mods 7 --var-mod UniMod:35,15.994915,M --var-mod UniMod:1,42.010565,K --var-mod UniMod:58,56.026215,K --var-mod UniMod:209,112.052430,K --var-mod UniMod:34,14.015650,K --var-mod UniMod:36,28.031300,K --var-mod UniMod:37,42.046950,K  --mass-acc 20.0 --mass-acc-ms1 20 --individual-mass-acc --individual-windows --peptidoforms --reanalyse --rt-profiling

