#!/bin/sh
#SBATCH --account=nn9036k --job-name=libC2MC2V3defaults
##SBATCH --partition=bigmem
#SBATCH --ntasks=1 --cpus-per-task=20
#SBATCH --mem-per-cpu=8G
#SBATCH --time=160:00:00
#SBATCH --mail-user=animesh.sharma@ntnu.no
#SBATCH --mail-type=ALL
#SBATCH --output=libC2MC2V3defaults.log
cd /cluster/home/ash022/cluster/diann-2.5.1
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
#wget https://github.com/vdemichev/DiaNN/releases/download/2.0/DIA-NN-2.5.1-Academia-Linux.zip
#unzip DIA-NN-2.5.1-Academia-Linux.zip
#chmod 755 diann-linux
#cp ../diann-2.5.0/camprotR_240512_cRAP_20190401_full_tags.fasta .
#cp /nird/datapeak/NS9036K/NORSTORE_OSL_DISK/NS9036K/promec/promec/FastaDB/uniprotkb_proteome_UP001652741_2026_05_28_sonali.combined.fasta .
#wc uniprotkb_proteome_UP001652741_2026_05_28_sonali.combined.fasta
#   8242331   15046582  523473229 /home/animeshs/promec/promec/FastaDB/uniprotkb_proteome_UP001652741_2026_05_28_sonali.combined.fasta
./diann-linux --lib  --threads 40 --verbose 1 --out  --qvalue 0.01 --matrices --out-lib sonaliC2MC2defaults.parquet --gen-spec-lib --predictor --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP- --fasta uniprotkb_proteome_UP001652741_2026_05_28_sonali.combined.fasta --fasta-search --met-excision --min-pep-len 7 --max-pep-len 30 --min-pr-mz 300 --max-pr-mz 1800 --min-pr-charge 2 --max-pr-charge 4 --min-fr-mz 200 --max-fr-mz 1800 --cut K*,R* --missed-cleavages 2 --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:7,0.984016,NQ --var-mod UniMod:1,42.010565,*n --rt-profiling --original-mods

