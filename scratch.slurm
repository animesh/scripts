#!/bin/sh
#SBATCH --account=nn9036k --job-name=combine.ppm15araport
##SBATCH --partition=bigmem
#SBATCH --ntasks=1 --cpus-per-task=20
#SBATCH --mem-per-cpu=8G
#SBATCH --time=12:00:00
#SBATCH --mail-user=animesh.sharma@ntnu.no
#SBATCH --mail-type=ALL
#SBATCH --output=combine.ppm15araport.log
#wget "https://objects.githubusercontent.com/github-production-release-asset-2e65be/125283280/6d0978fc-15e7-41d3-9f1b-027a7b889780?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=releaseassetproduction%2F20250530%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20250530T135309Z&X-Amz-Expires=300&X-Amz-Signature=195fa2d2efe5aca54ca53637ec411c012988efd2d0fa6b0b989acd8f2a81d802&X-Amz-SignedHeaders=host&response-content-disposition=attachment%3B%20filename%3DDIA-NN-2.2.0-Academia-Linux.zip&response-content-type=application%2Foctet-stream" -O diannv2p2.zip
#unzip diannv2p2.zip
#mv diann-2.2.0 /cluster/projects/nn9036k/.
#chmod 755 /cluster/projects/nn9036k/diann-2.2.0/diann-linux
#cp /cluster/projects/nn9036k/diann-2.1.0/*.fasta /cluster/projects/nn9036k/diann-2.2.0/.
#mkdir barbara
#rsync -Parv /nird/datapeak/NS9036K/NORSTORE_OSL_DISK/NS9036K/promec/promec/TIMSTOF/LARS/2026/260528_barbara/260528_Barbara_*.d barbara/.
#cp /nird/datapeak/NS9036K/NORSTORE_OSL_DISK/NS9036K/promec/promec/FastaDB/humanMC2V3defaults.predicted.speclib barbara/.
#cp /nird/datapeak/NS9036K/NORSTORE_OSL_DISK/NS9036K/promec/promec/FastaDB/UP000005640_9606_1protein1gene.fasta barbara/.
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
./diann-linux --f "/cluster/projects/nn9036k/scrbkup/barbara/260528_Barbara_1_Slot2-1_1_13751.d" --f "/cluster/projects/nn9036k/scrbkup/barbara/260528_Barbara_2_Slot2-2_1_13753.d" --f "/cluster/projects/nn9036k/scrbkup/barbara/260528_Barbara_3_Slot2-3_1_13755.d" --f "/cluster/projects/nn9036k/scrbkup/barbara/260528_Barbara_4_Slot2-4_1_13757.d" --f "/cluster/projects/nn9036k/scrbkup/barbara/260528_Barbara_5_Slot2-5_1_13759.d" --f "/cluster/projects/nn9036k/scrbkup/barbara/260528_Barbara_6_Slot2-6_1_13761.d" --f "/cluster/projects/nn9036k/scrbkup/barbara/260528_Barbara_7_Slot2-7_1_13763.d" --f "/cluster/projects/nn9036k/scrbkup/barbara/260528_Barbara_8_Slot2-8_1_13765.d" --f "/cluster/projects/nn9036k/scrbkup/barbara/260528_Barbara_9_Slot2-9_1_13767.d" --f "/cluster/projects/nn9036k/scrbkup/barbara/260528_Barbara_10_Slot2-10_1_13769.d" --f "/cluster/projects/nn9036k/scrbkup/barbara/260528_Barbara_11_Slot2-11_1_13774.d" --f "/cluster/projects/nn9036k/scrbkup/barbara/260528_Barbara_12_Slot2-12_1_13776.d" --f "/cluster/projects/nn9036k/scrbkup/barbara/260528_Barbara_13_Slot2-13_1_13778.d" --f "/cluster/projects/nn9036k/scrbkup/barbara/260528_Barbara_14_Slot2-14_1_13780.d" --f "/cluster/projects/nn9036k/scrbkup/barbara/260528_Barbara_15_Slot2-15_1_13782.d" --f "/cluster/projects/nn9036k/scrbkup/barbara/260528_Barbara_16_Slot2-16_1_13784.d" --f "/cluster/projects/nn9036k/scrbkup/barbara/260528_Barbara_17_Slot2-17_1_13786.d" --f "/cluster/projects/nn9036k/scrbkup/barbara/260528_Barbara_18_Slot2-18_1_13788.d" --f "/cluster/projects/nn9036k/scrbkup/barbara/260528_Barbara_19_Slot2-19_1_13790.d" --f "/cluster/projects/nn9036k/scrbkup/barbara/260528_Barbara_20_Slot2-20_1_13792.d" --f "/cluster/projects/nn9036k/scrbkup/barbara/260528_Barbara_21_Slot2-21_1_13794.d"   --lib /cluster/projects/nn9036k/scrbkup/barbara/humanMC2V3defaults.predicted.speclib  --threads 80 --verbose 1 --out combine.dreport.ppm15.parquet --qvalue 0.01 --matrices  --out-lib combine.dreport-lib.ppm15.parquet --gen-spec-lib --reannotate --fasta /cluster/projects/nn9036k/scrbkup/barbara/UP000005640_9606_1protein1gene.fasta --met-excision --min-pep-len 7 --max-pep-len 30 --min-pr-mz 300 --max-pr-mz 1800 --min-pr-charge 1 --max-pr-charge 4 --cut K*,R* --missed-cleavages 2 --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:1,42.010565,*n --mass-acc 15.0 --mass-acc-ms1 15.0 --use-quant  --high-acc --window 5  --peptidoforms  --reanalyse  --rt-profiling  
#dos2unix  scratch.slurm
#sbatch  scratch.slurm
#tail -f ppm40araport.log

