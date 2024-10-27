#!/bin/sh
#SBATCH --account=nn9036k --job-name=larsDIANN
#SBATCH --time=160:00:00
##SBATCH --partition=bigmem
#SBATCH --ntasks=1 --cpus-per-task=20
#SBATCH --mem-per-cpu=8G
#SBATCH --mail-user=animesh.sharma@ntnu.no
#SBATCH --mail-type=ALL
#SBATCH --output=larsDIANNLOG

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
#ls -d /cluster/projects/nn9036k/scripts/phoSTYnew/lars/*.d > /cluster/projects/nn9036k/scripts/phoSTYnew/lars/diafiles.txt ; cat /cluster/projects/nn9036k/scripts/phoSTYnew/lars/diafiles.txt
./diann-linux --threads 20 --f "/cluster/projects/nn9036k/scripts/phoSTYnew/lars/241009_Jurkat_zrImac_200lars_ny_Slot1-11_1_8582.d" --f "/cluster/projects/nn9036k/scripts/phoSTYnew/lars/241009_Jurkat_zrImac_100lars_ny_Slot1-10_1_8580.d" --f "/cluster/projects/nn9036k/scripts/phoSTYnew/lars/241009_Jurkat_zrImac_400lars_ny_Slot1-13_1_8586.d" --f "/cluster/projects/nn9036k/scripts/phoSTYnew/lars/241009_Jurkat_zrImac_500lars_ny_Slot1-14_1_8588.d" --f "/cluster/projects/nn9036k/scripts/phoSTYnew/lars/241009_Jurkat_zrImac_300lars_ny_Slot1-12_1_8584.d" --lib "/cluster/projects/nn9036k/FastaDB/phoslibMC1V3mz100to1700c2to3human.predicted.speclib"  --verbose 1 --out "/cluster/projects/nn9036k/scripts/phoSTYnew/lars/phoslibMC1V3mz100to1700c2to3human.predicted.speclibreportLARS.tsv" --qvalue 0.01 --matrices  --min-corr 2.0 --corr-diff 1.0 --time-corr-only --extracted-ms1 --predictor --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP- --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:1,42.010565,*n --var-mod UniMod:21,79.966331,STY --mass-acc 20.0 --mass-acc-ms1 20.0 --peptidoforms 
 