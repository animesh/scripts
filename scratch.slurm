#!/bin/sh
#SBATCH --account=nn9036k --job-name=TestFile.d.WRITEFILE
##SBATCH --partition=bigmem
#SBATCH --ntasks=1 --cpus-per-task=20
#SBATCH --mem-per-cpu=8G
#SBATCH --time=48:00:00
#SBATCH --mail-user=animesh.sharma@ntnu.no
#SBATCH --mail-type=ALL
#SBATCH --output=TestFile.d.WRITEFILE.log
#wget "https://objects.githubusercontent.com/github-production-release-asset-2e65be/125283280/6d0978fc-15e7-41d3-9f1b-027a7b889780?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=releaseassetproduction%2F20250530%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20250530T135309Z&X-Amz-Expires=300&X-Amz-Signature=195fa2d2efe5aca54ca53637ec411c012988efd2d0fa6b0b989acd8f2a81d802&X-Amz-SignedHeaders=host&response-content-disposition=attachment%3B%20filename%3DDIA-NN-2.2.0-Academia-Linux.zip&response-content-type=application%2Foctet-stream" -O diannv2p2.zip
#unzip diannv2p2.zip
#mv diann-2.2.0 /cluster/projects/nn9036k/.
#chmod 755 /cluster/projects/nn9036k/diann-2.2.0/diann-linux
#cp /cluster/projects/nn9036k/diann-2.1.0/*.fasta /cluster/projects/nn9036k/diann-2.2.0/.
#wget "https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/reference_proteomes/Eukaryota/UP000000589/UP000000589_10090.fasta.gz"https://rest.uniprot.org/uniprotkb/stream?download=true&format=fasta&query=%28%28proteome%3AUP000001449%29%29"
#mkdir tore
#rsync -Parv TIMSTOF/LARS/2026/260107_Tore/*.d tore/
#rsync -Parv TIMSTOF/LARS/2026/260107_Tore/Th* tore/
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
#::diann.exe --lib "" --threads 32 --verbose 1 --out "L:\promec\TIMSTOF\LARS\2026\260107_Tore\Thalassiosira_pseudonana_PASA-proteins_uniprot.report.parquet" --qvalue 0.01 --matrices  --out-lib "L:\promec\TIMSTOF\LARS\2026\260107_Tore\Thalassiosira_pseudonana_PASA-proteins_uniprot.MC1V3.parquet" --gen-spec-lib --predictor --reannotate --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP- --fasta "L:\promec\TIMSTOF\LARS\2026\260107_Tore\Thalassiosira_pseudonana_PASA-proteins_uniprot.fasta" --fasta-search --min-fr-mz 200 --max-fr-mz 1800 --met-excision --min-pep-len 7 --max-pep-len 30 --min-pr-mz 300 --max-pr-mz 1800 --min-pr-charge 1 --max-pr-charge 4 --cut K*,R* --missed-cleavages 1 --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:1,42.010565,*n --var-mod UniMod:21,79.966331,STY --mass-acc 20.0 --mass-acc-ms1 20 --peptidoforms --reanalyse --rt-profiling 
#diann.exe --f "L:\promec\TIMSTOF\LARS\2026\260107_Tore\260107_Tore_15_5_Slot1-15_1_12397.d " --lib "L:\promec\TIMSTOF\LARS\2026\260107_Tore\Thalassiosira_pseudonana_PASA-proteins_uniprot.MC1V3.predicted.speclib" --threads 32 --verbose 1 --out "L:\promec\TIMSTOF\LARS\2026\260107_Tore\260107_Tore_15_5_Slot1-15_1_12397.dreport.parquet" --qvalue 0.01 --matrices  --out-lib "L:\promec\TIMSTOF\LARS\2026\260107_Tore\260107_Tore_15_5_Slot1-15_1_12397.dreplib.parquet" --gen-spec-lib --reannotate --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP- --fasta "L:\promec\TIMSTOF\LARS\2026\260107_Tore\Thalassiosira_pseudonana_PASA-proteins_uniprot.fasta" --met-excision --min-pep-len 7 --max-pep-len 30 --min-pr-mz 300 --max-pr-mz 1800 --min-pr-charge 1 --max-pr-charge 4 --cut K*,R* --missed-cleavages 1 --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:1,42.010565,*n --var-mod UniMod:21,79.966331,STY --mass-acc 20.0 --mass-acc-ms1 20 --peptidoforms --reanalyse --rt-profiling 
./diann-linux   --f "TestFile.d"  --lib "/cluster/projects/nn9036k/scripts/tore/Thalassiosira_pseudonana_PASA-proteins_uniprot.MC1V3.predicted.speclib" --gen-spec-lib   --threads 80   --verbose 1   --out "TestFile.d.WRITEFILE.report.parquet"   --qvalue 0.01   --matrices   --reannotate   --fasta camprotR_240512_cRAP_20190401_full_tags.fasta   --cont-quant-exclude cRAP-   --fasta "/cluster/projects/nn9036k/scripts/tore/Thalassiosira_pseudonana_PASA-proteins_uniprot.fasta"   --fasta-search  --min-fr-mz 200   --max-fr-mz 1800   --met-excision   --min-pep-len 7  --max-pep-len 30   --min-pr-mz 300   --max-pr-mz 1800   --min-pr-charge 1  --max-pr-charge 4  --cut "K*,R*"  --missed-cleavages 1   --unimod4   --var-mods 3   --var-mod "UniMod:35,15.994915,M"   --var-mod "UniMod:1,42.010565,*n" --var-mod UniMod:21,79.966331,STY --mass-acc 20.0 --mass-acc-ms1 20 --peptidoforms --reanalyse --rt-profiling --high-acc

