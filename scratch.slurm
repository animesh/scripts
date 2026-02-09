#!/bin/sh
#SBATCH --account=nn9036k --job-name=TestFile.d.WRITEFILE
##SBATCH --partition=bigmem
#SBATCH --ntasks=1 --cpus-per-task=20
#SBATCH --mem-per-cpu=8G
#SBATCH --time=24:00:00
#SBATCH --mail-user=animesh.sharma@ntnu.no
#SBATCH --mail-type=ALL
#SBATCH --output=TestFile.d.WRITEFILE.log
#wget "https://github.com/vdemichev/DiaNN/releases/download/2.0/DIA-NN-2.3.2-Academia-Linux.zip"
#unzip DIA-NN-2.3.2-Academia-Linux.zip
#cp -rf diann-2.3.2  /cluster/projects/nn9036k/.
#cp /cluster/projects/nn9036k/diann-2.3.0/camprotR_240512_cRAP_20190401_full_tags.fasta /cluster/projects/nn9036k/diann-2.3.2/
#chmod 755 /cluster/projects/nn9036k/diann-2.3.2/diann-linux
cd /cluster/projects/nn9036k/diann-2.3.2/
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
#rsync -Parv TIMSTOF/LARS/2026/260203_Tore_Phos/ tore_phos/
#bash slurmDIANN.sh /cluster/projects/nn9036k/scripts/tore_phos/
#::diann.exe --lib "" --threads 32 --verbose 1 --out "L:\promec\TIMSTOF\LARS\2026\260107_Tore\Thalassiosira_pseudonana_PASA-proteins_uniprot.report.parquet" --qvalue 0.01 --matrices  --out-lib "L:\promec\TIMSTOF\LARS\2026\260107_Tore\Thalassiosira_pseudonana_PASA-proteins_uniprot.MC1V3.parquet" --gen-spec-lib --predictor --reannotate --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP- --fasta "L:\promec\TIMSTOF\LARS\2026\260107_Tore\Thalassiosira_pseudonana_PASA-proteins_uniprot.fasta" --fasta-search --min-fr-mz 200 --max-fr-mz 1800 --met-excision --min-pep-len 7 --max-pep-len 30 --min-pr-mz 300 --max-pr-mz 1800 --min-pr-charge 1 --max-pr-charge 4 --cut K*,R* --missed-cleavages 1 --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:1,42.010565,*n --var-mod UniMod:21,79.966331,STY --mass-acc 20.0 --mass-acc-ms1 20 --peptidoforms --reanalyse --rt-profiling 
#./diann-linux   --lib "" --threads 80 --verbose 1 --out "/cluster/projects/nn9036k/scripts/tore/Thalassiosira_pseudonana_PASA-proteins_uniprot.v2p3p2.MC1V3.predicted.speclib.parquet" --qvalue 0.01 --matrices  --out-lib "/cluster/projects/nn9036k/scripts/tore/Thalassiosira_pseudonana_PASA-proteins_uniprot.v2p3p2.MC1V3.predicted.speclib.parquetlib.parquet" --gen-spec-lib --predictor  --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP- --fasta "/cluster/projects/nn9036k/scripts/tore/Thalassiosira_pseudonana_PASA-proteins_uniprot.fasta" --fasta-search --met-excision --min-pep-len 7 --max-pep-len 30 --min-pr-mz 300 --max-pr-mz 1800 --min-pr-charge 1 --max-pr-charge 4 --min-fr-mz 200 --max-fr-mz 1800 --cut K*,R* --missed-cleavages 1 --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:7,0.984016,NQ --var-mod UniMod:1,42.010565,*n --var-mod UniMod:21,79.966331,STY --peptidoforms --reanalyse --rt-profiling  
#diann.exe --f "C:\Users\animeshs\260203_Tore_Phos\260129_ToreBrembuPHOS_2b_Slot1-2_1_12738.d" --f "C:\Users\animeshs\260203_Tore_Phos\260129_ToreBrembuPHOS_1_Slot1-1_1_12687.d" --f "C:\Users\animeshs\260203_Tore_Phos\260129_ToreBrembuPHOS_1b_Slot1-1_1_12737.d" --lib "Z:\Download\Thalassiosira_pseudonana_PASA-proteins_uniprot.v2p3p2.MC1V3.predicted.speclib.parquetlib.predicted.speclib" --threads 12 --verbose 1 --out "C:\Users\animeshs\260203_Tore_Phos\260129_ToreBrembuPHOS_2b_Slot1-2_1_12738.d\report.v2p3p2.parquet" --qvalue 0.01 --matrices  --out-lib "C:\Users\animeshs\260203_Tore_Phos\260129_ToreBrembuPHOS_2b_Slot1-2_1_12738.d\report-lib.v2p3p2.parquet" --gen-spec-lib --reannotate --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP- --fasta "C:\Users\animeshs\260203_Tore_Phos\Thalassiosira_pseudonana_PASA-proteins_uniprot.fasta" --met-excision --min-pep-len 7 --max-pep-len 30 --min-pr-mz 300 --max-pr-mz 1800 --min-pr-charge 1 --max-pr-charge 4 --min-fr-mz 200 --max-fr-mz 1800 --cut K*,R* --missed-cleavages 1 --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:7,0.984016,NQ --var-mod UniMod:1,42.010565,*n --var-mod UniMod:21,79.966331,STY --mass-acc 20 --mass-acc-ms1 20 --peptidoforms --reanalyse --rt-profiling
./diann-linux --f "TestFile.d" --lib "/cluster/projects/nn9036k/scripts/tore/Thalassiosira_pseudonana_PASA-proteins_uniprot.v2p3p2.MC1V3.predicted.speclib.parquetlib.predicted.speclib" --threads 80 --verbose 1 --out "TestFile.d.WRITEFILE.report.v2p3p2.parquet" --qvalue 0.01 --matrices  --out-lib "TestFile.d.WRITEFILE.report-lib.v2p3p2.parquet" --gen-spec-lib --reannotate --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP- --fasta "/cluster/projects/nn9036k/scripts/tore/Thalassiosira_pseudonana_PASA-proteins_uniprot.fasta" --met-excision --min-pep-len 7 --max-pep-len 30 --min-pr-mz 300 --max-pr-mz 1800 --min-pr-charge 1 --max-pr-charge 4 --min-fr-mz 200 --max-fr-mz 1800 --cut K*,R* --missed-cleavages 1 --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:7,0.984016,NQ --var-mod UniMod:1,42.010565,*n --var-mod UniMod:21,79.966331,STY --mass-acc 20 --mass-acc-ms1 20 --peptidoforms --reanalyse --rt-profiling
#./diann-linux   --f "TestFile.d"  --lib "/cluster/projects/nn9036k/scripts/tore/Thalassiosira_pseudonana_PASA-proteins_uniprot.MC1V3.predicted.speclib" --gen-spec-lib   --threads 80   --verbose 1   --out "TestFile.d.WRITEFILE.report.parquet"   --qvalue 0.01   --matrices   --reannotate   --fasta camprotR_240512_cRAP_20190401_full_tags.fasta   --cont-quant-exclude cRAP-   --fasta "/cluster/projects/nn9036k/scripts/tore/Thalassiosira_pseudonana_PASA-proteins_uniprot.fasta"   --fasta-search  --min-fr-mz 200   --max-fr-mz 1800   --met-excision   --min-pep-len 7  --max-pep-len 30   --min-pr-mz 300   --max-pr-mz 1800   --min-pr-charge 1  --max-pr-charge 4  --cut "K*,R*"  --missed-cleavages 1   --unimod4   --var-mods 3   --var-mod "UniMod:35,15.994915,M"   --var-mod "UniMod:1,42.010565,*n" --var-mod UniMod:21,79.966331,STY --mass-acc 20.0 --mass-acc-ms1 20 --peptidoforms --reanalyse --rt-profiling --high-acc

