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
./diann-linux  --f /cluster/projects/nn9036k/scrbkup/moreforsk/260908_Moreforsk_BBE_ren_Slot1-1_1_14438.d --lib  --threads 128 --verbose 3 --out /cluster/projects/nn9036k/scrbkup/moreforsk/lib.report.parquet --qvalue 0.01 --matrices --min-corr 2.0 --time-corr-only --extracted-ms1 --min-cal 500 --min-class 1000 --pre-filter --rt-window-mul 1.7 --rt-window-factor 100 --out-lib /cluster/projects/nn9036k/scrbkup/moreforsk/lib.parquet --gen-spec-lib --reannotate --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP- --fasta /cluster/projects/nn9036k/scrbkup/moreforsk/UP000694546_8049.fasta --pre-search --pre-filter --met-excision --min-pep-len 50 --max-pep-len 100 --min-pr-mz 300 --max-pr-mz 1800 --min-pr-charge 1 --max-pr-charge 4 --min-fr-mz 200 --max-fr-mz 1800 --cut ** --missed-cleavages 100 --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:7,0.984016,NQ --var-mod UniMod:1,42.010565,*n --mass-acc 15 --mass-acc-ms1 15 --mass-acc-cal 19 --proteoforms --rt-profiling --direct-quant --global-norm --dda --original-mods
