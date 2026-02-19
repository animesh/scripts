#!/bin/sh
#SBATCH --account=nn9036k --job-name=toreApexPhos
##SBATCH --partition=bigmem
#SBATCH --ntasks=1 --cpus-per-task=20
#SBATCH --mem-per-cpu=8G
#SBATCH --time=96:00:00
#SBATCH --mail-user=animesh.sharma@ntnu.no
#SBATCH --mail-type=ALL
#SBATCH --output=toreApexPhos.log
#wget "https://objects.githubusercontent.com/github-production-release-asset-2e65be/125283280/6d0978fc-15e7-41d3-9f1b-027a7b889780?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=releaseassetproduction%2F20250530%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20250530T135309Z&X-Amz-Expires=300&X-Amz-Signature=195fa2d2efe5aca54ca53637ec411c012988efd2d0fa6b0b989acd8f2a81d802&X-Amz-SignedHeaders=host&response-content-disposition=attachment%3B%20filename%3DDIA-NN-2.2.0-Academia-Linux.zip&response-content-type=application%2Foctet-stream" -O diannv2p2.zip
#unzip diannv2p2.zip
#mv diann-2.2.0 /cluster/projects/nn9036k/.
#chmod 755 /cluster/projects/nn9036k/diann-2.2.0/diann-linux
#cp /cluster/projects/nn9036k/diann-2.1.0/*.fasta /cluster/projects/nn9036k/diann-2.2.0/.
#wget "https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/reference_proteomes/Eukaryota/UP000000589/UP000000589_10090.fasta.gz"https://rest.uniprot.org/uniprotkb/stream?download=true&format=fasta&query=%28%28proteome%3AUP000001449%29%29"
#mkdir tore_apex
#rsync -Parv tore_phos/ TIMSTOF/LARS/2026/260202_tOREb_aPEX/260202_ToreBrembuAPEX_*.d tore_apex/
#rsync -Parv TIMSTOF/LARS/2026/260202_ToreBrembuAPEX/Th* tore/
cd /cluster/projects/nn9036k/diann-2.2.0/
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
#::diann.exe --lib "" --threads 32 --verbose 1 --out "/cluster/projects/nn9036k/scrbkup/tore/Thalassiosira_pseudonana_PASA-proteins_uniprot.report.parquet" --qvalue 0.01 --matrices  --out-lib "/cluster/projects/nn9036k/scrbkup/tore/Thalassiosira_pseudonana_PASA-proteins_uniprot.MC1V3.parquet" --gen-spec-lib --predictor --reannotate --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP- --fasta "/cluster/projects/nn9036k/scrbkup/tore/Thalassiosira_pseudonana_PASA-proteins_uniprot.fasta" --fasta-search --min-fr-mz 200 --max-fr-mz 1800 --met-excision --min-pep-len 7 --max-pep-len 30 --min-pr-mz 300 --max-pr-mz 1800 --min-pr-charge 1 --max-pr-charge 4 --cut K*,R* --missed-cleavages 1 --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:1,42.010565,*n --var-mod UniMod:21,79.966331,STY --mass-acc 20.0 --mass-acc-ms1 20 --peptidoforms --reanalyse --rt-profiling 
./diann-linux --f "/cluster/projects/nn9036k/scrbkup/tore_apex/260202_ToreBrembuAPEX_N5_Slot1-41_1_12790.d" --f "/cluster/projects/nn9036k/scrbkup/tore_apex/260202_ToreBrembuAPEX_N4_Slot1-40_1_12789.d" --f "/cluster/projects/nn9036k/scrbkup/tore_apex/260202_ToreBrembuAPEX_N3_Slot1-39_1_12788.d" --f "/cluster/projects/nn9036k/scrbkup/tore_apex/260202_ToreBrembuAPEX_N2_Slot1-38_1_12787.d" --f "/cluster/projects/nn9036k/scrbkup/tore_apex/260202_ToreBrembuAPEX_N1_Slot1-37_1_12786.d" --f "/cluster/projects/nn9036k/scrbkup/tore_apex/260202_ToreBrembuAPEX_C5_Slot1-46_1_12797.d" --f "/cluster/projects/nn9036k/scrbkup/tore_apex/260202_ToreBrembuAPEX_C4_Slot1-45_1_12796.d" --f "/cluster/projects/nn9036k/scrbkup/tore_apex/260202_ToreBrembuAPEX_C3_Slot1-44_1_12795.d" --f "/cluster/projects/nn9036k/scrbkup/tore_apex/260202_ToreBrembuAPEX_C2_Slot1-43_1_12794.d" --f "/cluster/projects/nn9036k/scrbkup/tore_apex/260202_ToreBrembuAPEX_C1_Slot1-42_1_12793.d" --lib "/cluster/projects/nn9036k/scrbkup/tore/Thalassiosira_pseudonana_PASA-proteins_uniprot.MC1V3.predicted.speclib" --threads 80 --verbose 1 --out "/cluster/projects/nn9036k/scrbkup/tore_apex/260202_ToreBrembuAPEX.higacc.parquet" --qvalue 0.01 --matrices  --out-lib "/cluster/projects/nn9036k/scrbkup/tore_apex/260202_ToreBrembuAPEX.highacc.replib.parquet" --gen-spec-lib --reannotate --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP- --fasta "/cluster/projects/nn9036k/scrbkup/tore/Thalassiosira_pseudonana_PASA-proteins_uniprot.fasta" --met-excision --min-pep-len 7 --max-pep-len 30 --min-pr-mz 300 --max-pr-mz 1800 --min-pr-charge 1 --max-pr-charge 4 --cut K*,R* --missed-cleavages 1 --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:1,42.010565,*n --var-mod UniMod:21,79.966331,STY --mass-acc 20.0 --mass-acc-ms1 20 --use-quant --peptidoforms --reanalyse --rt-profiling --high-acc
