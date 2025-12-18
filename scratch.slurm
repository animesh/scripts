#!/bin/sh
#SBATCH --account=nn9036k --job-name=ppm15DIAmix
#SBATCH --partition=bigmem
#SBATCH --ntasks=1 --cpus-per-task=32
#SBATCH --mem-per-cpu=72G
#SBATCH --time=96:00:00
#SBATCH --mail-user=animesh.sharma@ntnu.no
#SBATCH --mail-type=ALL
#SBATCH --output=BMppm15DIAmix.log
# wget "https://github.com/vdemichev/DiaNN/releases/download/2.0/DIA-NN-2.3.1-Academia-Linux.zip"
# sha256sum ./DIA-NN-2.3.1-Academia-Linux.zip 
#614dba4449e06358469fbe443826658749f610d6e015ed4c771ec645e8457eb4  ./DIA-NN-2.3.1-Academia-Linux.zip
# unzip ./DIA-NN-2.3.1-Academia-Linux.zip
cd /cluster/home/ash022/scripts/diann-2.3.1
#cp /cluster/projects/nn9036k/diann-2.3.0/camprotR_240512_cRAP_20190401_full_tags.fasta . 
#rsync -Parv /mnt/f/*.d  ash022@login.saga.sigma2.no:/cluster/work/users/ash022/hecoli/.
#rsync -Parv /mnt/f/*.fasta  ash022@login.saga.sigma2.no:/cluster/work/users/ash022/hecoli/.
#rsync -Parv /mnt/f/*.quant  ash022@login.saga.sigma2.no:/cluster/work/users/ash022/hecoli/.
#https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/reference_proteomes/Eukaryota/UP000005640/UP000005640_9606.fasta.gz
#https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/reference_proteomes/Bacteria/UP000000625/UP000000625_83333.fasta.gz
#chmod 755 diann-linux 
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
module load GCCcore/14.3.0
./diann-linux --f "/cluster/work/users/ash022/hecoli/250107_Hela_coli_5_1_DIA_c_Slot1-47_1_9403.d " --f "/cluster/work/users/ash022/hecoli/250107_Hela_coli_5_1_DIA_b_Slot1-47_1_9397.d" --f "/cluster/work/users/ash022/hecoli/250107_Hela_coli_5_1_DIA_a_Slot1-47_1_9391.d" --f "/cluster/work/users/ash022/hecoli/250107_Hela_coli_5_1_DDA_c_Slot1-47_1_9385.d" --f "/cluster/work/users/ash022/hecoli/250107_Hela_coli_5_1_DDA_b_Slot1-47_1_9379.d" --f "/cluster/work/users/ash022/hecoli/250107_Hela_coli_5_1_DDA_a_Slot1-47_1_9373.d" --f "/cluster/work/users/ash022/hecoli/250107_Hela_coli_4_1_DIA_c_Slot1-48_1_9404.d" --f "/cluster/work/users/ash022/hecoli/250107_Hela_coli_4_1_DIA_b_Slot1-48_1_9398.d" --f "/cluster/work/users/ash022/hecoli/250107_Hela_coli_4_1_DIA_a_Slot1-48_1_9392.d" --f "/cluster/work/users/ash022/hecoli/250107_Hela_coli_4_1_DDA_c_Slot1-48_1_9386.d" --f "/cluster/work/users/ash022/hecoli/250107_Hela_coli_4_1_DDA_b_Slot1-48_1_9380.d" --f "/cluster/work/users/ash022/hecoli/250107_Hela_coli_4_1_DDA_a_Slot1-48_1_9374.d" --f "/cluster/work/users/ash022/hecoli/250107_Hela_coli_2_1_DIA_c_Slot1-50_1_9405.d" --f "/cluster/work/users/ash022/hecoli/250107_Hela_coli_2_1_DIA_b_Slot1-50_1_9399.d" --f "/cluster/work/users/ash022/hecoli/250107_Hela_coli_2_1_DIA_a_Slot1-50_1_9393.d" --f "/cluster/work/users/ash022/hecoli/250107_Hela_coli_2_1_DDA_c_Slot1-50_1_9387.d" --f "/cluster/work/users/ash022/hecoli/250107_Hela_coli_2_1_DDA_b_Slot1-50_1_9381.d" --f "/cluster/work/users/ash022/hecoli/250107_Hela_coli_2_1_DDA_a_Slot1-50_1_9375.d" --f "/cluster/work/users/ash022/hecoli/250107_Hela_coli_1_1_DIA_c_Slot1-51_1_9406.d" --f "/cluster/work/users/ash022/hecoli/250107_Hela_coli_1_1_DIA_b_Slot1-51_1_9400.d" --f "/cluster/work/users/ash022/hecoli/250107_Hela_coli_1_1_DIA_a_Slot1-51_1_9394.d" --f "/cluster/work/users/ash022/hecoli/250107_Hela_coli_1_1_DDA_c_Slot1-51_1_9388.d" --f "/cluster/work/users/ash022/hecoli/250107_Hela_coli_1_1_DDA_b_Slot1-51_1_9382.d" --f "/cluster/work/users/ash022/hecoli/250107_Hela_coli_1_1_DDA_a_Slot1-51_1_9376.d" --f "/cluster/work/users/ash022/hecoli/250107_Hela_coli_10_1_DIA_c_Slot1-46_1_9402.d" --f "/cluster/work/users/ash022/hecoli/250107_Hela_coli_10_1_DIA_b_Slot1-46_1_9396.d" --f "/cluster/work/users/ash022/hecoli/250107_Hela_coli_10_1_DIA_a_Slot1-46_1_9390.d" --f "/cluster/work/users/ash022/hecoli/250107_Hela_coli_10_1_DDA_c_Slot1-46_1_9384.d" --f "/cluster/work/users/ash022/hecoli/250107_Hela_coli_10_1_DDA_b_Slot1-46_1_9378.d" --f "/cluster/work/users/ash022/hecoli/250107_Hela_coli_10_1_DDA_a_Slot1-46_1_9372.d" --f "/cluster/work/users/ash022/hecoli/250107_200ngHelaQC_DDA_Slot1-54_1_9370.d" --lib "" --threads 128 --verbose 5 --out "/cluster/work/users/ash022/hecoli/report.parquet" --qvalue 0.01 --matrices  --out-lib "/cluster/work/users/ash022/hecoli/report-lib.parquet" --gen-spec-lib --reannotate --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP- --fasta "/cluster/work/users/ash022/hecoli/UP000000625_83333.fasta" --fasta "/cluster/work/users/ash022/hecoli/UP000005640_9606.fasta" --pre-search --pre-filter --met-excision --min-pep-len 7 --max-pep-len 30 --min-pr-mz 300 --max-pr-mz 1800 --min-pr-charge 1 --max-pr-charge 4 --min-fr-mz 200 --max-fr-mz 1800 --cut K*,R* --missed-cleavages 2 --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:7,0.984016,NQ --var-mod UniMod:1,42.010565,*n --mass-acc 15 --mass-acc-ms1 15 --individual-mass-acc --individual-windows --peptidoforms  --use-quant --rt-profiling  --reanalyse
#dos2unix scratch.slurm
#tail -f BMppm15DIAmix.log 

