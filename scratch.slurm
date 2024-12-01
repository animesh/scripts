#!/bin/sh
#SBATCH --account=nn9036k --job-name=phosDeoDIANN
#SBATCH --time=160:00:00
##SBATCH --partition=bigmem
#SBATCH --ntasks=1 --cpus-per-task=20
#SBATCH --mem-per-cpu=8G
#SBATCH --mail-user=animesh.sharma@ntnu.no
#SBATCH --mail-type=ALL
#SBATCH --output=phosDeoDIANNLOG

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
#./diann-linux --lib "" --threads 16 --verbose 1 --out "/cluster/projects/nn9036k/FastaDB/phoslibMC1V3mz100to1700c2to3humanreport.tsv" --qvalue 0.01 --matrices  --out-lib "/cluster/projects/nn9036k/FastaDB/phoslibMC1V3mz100to1700c2to3human.parquet" --gen-spec-lib --predictor --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP- --fasta "/cluster/projects/nn9036k/FastaDB/UP000005640_9606.fasta" --fasta-search --min-fr-mz 100 --max-fr-mz 1700 --met-excision --min-pep-len 7 --max-pep-len 30 --min-pr-mz 100 --max-pr-mz 1700 --min-pr-charge 2 --max-pr-charge 3 --cut K*,R* --missed-cleavages 1 --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:1,42.010565,*n --var-mod UniMod:21,79.966331,STY --peptidoforms --reanalyse --relaxed-prot-inf --rt-profiling
#cp /cluster/projects/nn9036k/FastaDB/UP000005640_9606*fasta /cluster/projects/nn9036k/diann-1.9.2/
./diann-linux --threads 20 --f "/cluster/projects/nn9036k/scripts/deoDIA/241125_Deo_1A_PHOSdia_Slot2-40_1_9050.d" --f "/cluster/projects/nn9036k/scripts/deoDIA/241125_Deo_1A_totdia_Slot2-28_1_9032.d" --f "/cluster/projects/nn9036k/scripts/deoDIA/241125_Deo_1B_PHOSdia_Slot2-41_1_9051.d" --f "/cluster/projects/nn9036k/scripts/deoDIA/241125_Deo_1B_totdia_Slot2-29_1_9033.d" --f "/cluster/projects/nn9036k/scripts/deoDIA/241125_Deo_1C_PHOSdia_Slot2-42_1_9052.d" --f "/cluster/projects/nn9036k/scripts/deoDIA/241125_Deo_1C_totdia_Slot2-30_1_9034.d" --f "/cluster/projects/nn9036k/scripts/deoDIA/241125_Deo_2A_PHOSdia_Slot2-43_1_9053.d" --f "/cluster/projects/nn9036k/scripts/deoDIA/241125_Deo_2A_totdia_Slot2-31_1_9046.d" --f "/cluster/projects/nn9036k/scripts/deoDIA/241125_Deo_2B_PHOSdia_Slot2-44_1_9054.d" --f "/cluster/projects/nn9036k/scripts/deoDIA/241125_Deo_2B_totdia_Slot2-32_1_9038.d" --f "/cluster/projects/nn9036k/scripts/deoDIA/241125_Deo_2C_PHOSdia_Slot2-45_1_9055.d" --f "/cluster/projects/nn9036k/scripts/deoDIA/241125_Deo_2C_totdia_Slot2-33_1_9039.d" --f "/cluster/projects/nn9036k/scripts/deoDIA/241125_Deo_4A_PHOSdia_Slot2-46_1_9056.d" --f "/cluster/projects/nn9036k/scripts/deoDIA/241125_Deo_4A_totdia_Slot2-34_1_9040.d" --f "/cluster/projects/nn9036k/scripts/deoDIA/241125_Deo_4B_PHOSdia_Slot2-47_1_9057.d" --f "/cluster/projects/nn9036k/scripts/deoDIA/241125_Deo_4B_totdia_Slot2-35_1_9041.d" --f "/cluster/projects/nn9036k/scripts/deoDIA/241125_Deo_4C_PHOSdia_Slot2-48_1_9058.d" --f "/cluster/projects/nn9036k/scripts/deoDIA/241125_Deo_4C_totdia_Slot2-36_1_9042.d" --f "/cluster/projects/nn9036k/scripts/deoDIA/241125_Deo_6A_PHOSdia_Slot2-49_1_9059.d" --f "/cluster/projects/nn9036k/scripts/deoDIA/241125_Deo_6A_totdia_Slot2-37_1_9043.d" --f "/cluster/projects/nn9036k/scripts/deoDIA/241125_Deo_6B_PHOSdia_Slot2-50_1_9060.d" --f "/cluster/projects/nn9036k/scripts/deoDIA/241125_Deo_6B_totdia_Slot2-38_1_9044.d" --f "/cluster/projects/nn9036k/scripts/deoDIA/241125_Deo_6C_PHOSdia_Slot2-51_1_9061.d" --f "/cluster/projects/nn9036k/scripts/deoDIA/241125_Deo_6C_totdia_Slot2-39_1_9045.d"  --lib "/cluster/projects/nn9036k/FastaDB/phoslibMC1V3mz100to1700c2to3human.predicted.speclib"  --verbose 1 --out "/cluster/projects/nn9036k/FastaDB/deoPhosAlllibMC1V3mz100to1700c2to3human.predicted.speclibreport.tsv" --qvalue 0.01 --matrices  --min-corr 2.0 --corr-diff 1.0 --time-corr-only --extracted-ms1 --predictor --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --fasta UP000005640_9606.fasta  --cont-quant-exclude cRAP- --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:1,42.010565,*n --var-mod UniMod:21,79.966331,STY --mass-acc 20.0 --mass-acc-ms1 20.0 --peptidoforms 

