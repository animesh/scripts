#!/bin/sh
#SBATCH --account=nn9036k --job-name=TestFile.d.MC2V3
#SBATCH --partition=bigmem
#SBATCH --ntasks=1 --cpus-per-task=32
#SBATCH --mem-per-cpu=32G
#SBATCH --time=160:00:00
#SBATCH --mail-user=animesh.sharma@ntnu.no
#SBATCH --mail-type=ALL
#SBATCH --output=TestFile.d.MC2V3.log
cd /cluster/projects/nn9036k/diann-2.7.0
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
module --ignore_cache load dotNET-Core/8.0.411
#wget "https://github.com/vdemichev/DiaNN/releases/download/2.0/DIA-NN-2.7.0-Academia-Linux.zip"
#wget https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/reference_proteomes/Eukaryota/UP000005640/UP000005640_9606.fasta.gz
#gunzip UP000005640_9606.fasta.gz
#mv UP000005640_9606.fasta promec/promec/FastaDB/UP000005640_9606_1protein1gene.fasta
#unzip DIA-NN-2.7.0-Academia-Linux.zip
#mv diann-2.7.0 /cluster/projects/nn9036k/. 
#chmod 755 /cluster/projects/nn9036k/diann-2.7.0/diann-linux 
#cp /cluster/projects/nn9036k/diann-2.5.0/camprotR_240512_cRAP_20190401_full_tags.fasta /cluster/projects/nn9036k/diann-2.7.0/
./diann-linux  --f /cluster/projects/nn9036k/scrbkup/260825_Barbara/260825_Rabina_1_Slot1-1_1_14300.d --f /cluster/projects/nn9036k/scrbkup/260825_Barbara/260825_Rabina_10_Slot1-10_1_14312.d --f /cluster/projects/nn9036k/scrbkup/260825_Barbara/260825_Rabina_11_Slot1-11_1_14313.d --f /cluster/projects/nn9036k/scrbkup/260825_Barbara/260825_Rabina_12_Slot1-12_1_14314.d --f /cluster/projects/nn9036k/scrbkup/260825_Barbara/260825_Rabina_13_Slot1-13_1_14315.d --f /cluster/projects/nn9036k/scrbkup/260825_Barbara/260825_Rabina_14_Slot1-14_1_14316.d --f /cluster/projects/nn9036k/scrbkup/260825_Barbara/260825_Rabina_2_Slot1-2_1_14301.d --f /cluster/projects/nn9036k/scrbkup/260825_Barbara/260825_Rabina_3_Slot1-3_1_14302.d --f /cluster/projects/nn9036k/scrbkup/260825_Barbara/260825_Rabina_4_Slot1-4_1_14303.d --f /cluster/projects/nn9036k/scrbkup/260825_Barbara/260825_Rabina_5_Slot1-5_1_14304.d --f /cluster/projects/nn9036k/scrbkup/260825_Barbara/260825_Rabina_6_Slot1-6_1_14305.d --f /cluster/projects/nn9036k/scrbkup/260825_Barbara/260825_Rabina_7_Slot1-7_1_14306.d --f /cluster/projects/nn9036k/scrbkup/260825_Barbara/260825_Rabina_8_Slot1-8_1_14310.d --f /cluster/projects/nn9036k/scrbkup/260825_Barbara/260825_Rabina_9_Slot1-9_1_14311.d --lib  --threads 128 --verbose 1 --out /cluster/projects/nn9036k/scrbkup/260825_Barbara/phosDIAsaga/lib.report.parquet --qvalue 0.01 --matrices --no-rt-window --out-lib /cluster/projects/nn9036k/scrbkup/260825_Barbara/phosDIAsaga/lib.parquet --gen-spec-lib --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP- --fasta /cluster/projects/nn9036k/FastaDB/uniprotkb_proteome_UP000005640_AND_revi_2026_09_17.fasta --pre-search --pre-filter --met-excision --min-pep-len 7 --max-pep-len 30 --min-pr-mz 300 --max-pr-mz 1800 --min-pr-charge 2 --max-pr-charge 4 --min-fr-mz 200 --max-fr-mz 1800 --cut K*,R* --missed-cleavages 2 --unimod4 --var-mods 5 --var-mod UniMod:35,15.994915,M --var-mod UniMod:7,0.984016,NQ --var-mod UniMod:1,42.010565,*n --var-mod UniMod:21,79.966331,STY --mass-acc 15 --mass-acc-ms1 15 --mass-acc-cal 19 --proteoforms --reanalyse --rt-profiling --direct-quant --global-norm --original-mods
